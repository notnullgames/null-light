import std/os
import std/strformat
import std/times
import pixie
import wasm3
import wasm3/wasm3c
import wasm3/wasmconversions
import zippy/ziparchives

type Null0Cart* = object
  time_start*: float
  files*: ZipArchiveReader
  images*: seq[Context]
  fonts*: seq[Font]
  export_load*: PFunction
  export_update*: PFunction
  export_unload*: PFunction
  export_buttonDown*: PFunction
  export_buttonUp*: PFunction
  debug*: bool
  module*: PModule
  runtime*: PRuntime
  env*: PEnv
  dir*: string

# This is how data is passed over the wasm-barrier
type
  WasmVector2 {.packed.} = object
    x: int32
    y: int32
  WasmColor {.packed.} = object
    b: uint8
    g: uint8
    r: uint8
    a: uint8

proc isZip*(bytes: string): bool =
  ## detect if some bytes (at least 4) are a zip file
  return ord(bytes[0]) == 0x50 and ord(bytes[1]) == 0x4B and ord(bytes[2]) == 0x03 and ord(bytes[3]) == 0x04

proc isWasm*(bytes: string): bool =
  ## detect if some bytes (at least 4) are a wasm file
  return ord(bytes[0]) == 0x00 and ord(bytes[1]) == 0x61 and ord(bytes[2]) == 0x73 and ord(bytes[3]) == 0x6d

# wrap an import (for wasm)
# TODO: can I generate sig and get name from proc in body?
template wasm_import*(name: untyped, sig: string, body: untyped): untyped {.dirty.} =
  let name = proc (runtime: PRuntime; ctx: PImportContext; sp: ptr uint64; mem: pointer): pointer {.cdecl.} =
    var null0 = cast[ptr Null0Cart](ctx[].userdata)[]
    let wrapper = body
    var s = sp.stackPtrToUint()
    callHost(wrapper, s, mem)
  try:
    checkWasmRes m3_LinkRawFunctionEx(null0.module, cstring "*", cstring name.astToStr, cstring sig, name, addr null0)
  except WasmError as e:
    if null0.debug:
      echo "import ", name.astToStr, ": ", e.msg

proc fromWasm*(result: var WasmVector2, sp: var uint64, mem: pointer) =
  var i: uint32
  i.fromWasm(sp, mem)
  result = cast[ptr WasmVector2](cast[uint64](mem) + i)[]

proc fromWasm*(result: var WasmColor, sp: var uint64, mem: pointer) =
  var i: uint32
  i.fromWasm(sp, mem)
  result = cast[ptr WasmColor](cast[uint64](mem) + i)[]

proc vec2*(i: WasmVector2): Vec2 =
  return vec2(float i.x, float i.y)

proc rgba*(i: WasmColor): ColorRGBA =
  return rgba(i.r, i.g, i.b, i.a)

proc readFile*(null0: Null0Cart, filename: string): string =
  if null0.files != nil:
    return null0.files.extractFile(filename)
  else:
    # TODO: this is not really secure (no sandboxing.) dirs are for dev/debugging so maybe that is OK
    return readFile(fmt"{null0.dir}/{filename}")

proc load*(null0: var Null0Cart, filename: string, debug: bool = false) = 
  ## Starts the null0 engine on a cart (which can be a wasm/zip file or a directory)
  null0.time_start = cpuTime()
  null0.debug = debug

  # image 0 is "screen"
  null0.images.setLen(0)
  null0.images.add(newContext(320, 240))

  var wasmBytes: string

  if dirExists(filename):
    null0.dir = filename
    wasmBytes = null0.readFile("main.wasm")
  elif fileExists(filename):
    let b = readFile(filename)
    if isZip(b):
      null0.files = openZipArchive(filename)
      wasmBytes = null0.readFile("main.wasm")
    elif isWasm(b):
      wasmBytes = b
      null0.dir = parentDir(filename)
    else:
      echo fmt"{filename} is a file, but it's invalid."
      quit(1)
  else:
    echo fmt"{filename} does not exist."
    quit(1)

  if not isWasm(wasmBytes):
    echo "Your main.wasm is not vaild."
    quit(1)

  if debug:
    echo fmt"{filename} has a valid main.wasm."

  null0.env = m3_NewEnvironment()
  null0.runtime = null0.env.m3_NewRuntime(uint32 uint16.high, nil)
  checkWasmRes m3_ParseModule(null0.env, null0.module.addr, cast[ptr uint8](unsafeAddr wasmBytes[0]), uint32 len(wasmBytes))
  checkWasmRes m3_LoadModule(null0.runtime, null0.module)

  # must create imports before getting exports

  wasm_import(trace, "v(*)"):
    proc (text: cstring) =
      echo text

  wasm_import(set_color, "v(i**)"):
    proc (targetID: uint32, fillColor: WasmColor, borderColor: WasmColor) =
      null0.images[targetID].fillStyle = rgba(fillColor)
      null0.images[targetID].strokeStyle = rgba(borderColor)

  wasm_import(draw_image, "v(ii*)"):
    proc (targetID: uint32, sourceID: uint32, position: WasmVector2) =
      null0.images[targetID].image.draw(null0.images[sourceID].image, translate(vec2(position)))

  wasm_import(load_image, "i(*)"):
    proc (filename: cstring): uint32 =
      let i = len(null0.images)
      null0.images.add(newContext(decodeImage(null0.readfile($filename))))
      return uint32 i

  wasm_import(new_image, "i(*)"):
    proc (dimensions: WasmVector2): uint32 =
      null0.images.add(newContext(dimensions.x, dimensions.y))
      return uint32 len(null0.images) - 1

  wasm_import(rectangle, "v(i**i)"):
    proc (targetID: uint32, position: WasmVector2, dimensions: WasmVector2, borderSize: uint32) =
      null0.images[targetID].lineWidth = float32 borderSize
      let shape = rect(vec2(position), vec2(dimensions))
      null0.images[targetID].fillRect(shape)
      if borderSize != 0:
        null0.images[targetID].strokeRect(shape)

  wasm_import(circle, "v(i*ii)"):
    proc (targetID: uint32, position: WasmVector2, radius: uint32, borderSize: uint32) =
      null0.images[targetID].lineWidth = float32 borderSize
      let shape = circle(vec2(position), float32 radius)
      null0.images[targetID].fillCircle(shape)
      if borderSize != 0:
        null0.images[targetID].strokeCircle(shape)

  wasm_import(rectangle_round, "v(i**iiiii)"):
    proc (targetID: uint32, position: WasmVector2, dimensions: WasmVector2, nw: uint32, ne: uint32, se: uint32, sw: uint32, borderSize: uint32) =
      null0.images[targetID].lineWidth = float32 borderSize
      let shape = rect(vec2(position), vec2(dimensions))
      null0.images[targetID].fillRoundedRect(shape, float32 nw, float32 ne, float32 se, float32 sw)
      if borderSize != 0:
        null0.images[targetID].strokeRoundedRect(shape, float32 nw, float32 ne, float32 se, float32 sw)

  wasm_import(ellipse, "v(i**i)"):
    proc (targetID: uint32, position: WasmVector2, dimensions: WasmVector2, borderSize: uint32) =
      null0.images[targetID].lineWidth = float32 borderSize
      null0.images[targetID].fillEllipse(vec2(position), float32 dimensions.x, float32 dimensions.y)
      if borderSize != 0:
        null0.images[targetID].strokeEllipse(vec2(position), float32 dimensions.x, float32 dimensions.y)

  try:
    checkWasmRes m3_FindFunction(addr null0.export_load, null0.runtime, "load")
  except WasmError as e:
    if debug:
      echo fmt"export load: {e.msg}"
  try:
    checkWasmRes m3_FindFunction(addr null0.export_unload, null0.runtime, "unload")
  except WasmError as e:
    if debug:
      echo fmt"export unload: {e.msg}"
  try:
    checkWasmRes m3_FindFunction(addr null0.export_update, null0.runtime, "update")
  except WasmError as e:
    if debug:
      echo fmt"export update: {e.msg}"
  try:
    checkWasmRes m3_FindFunction(addr null0.export_buttonUp, null0.runtime, "buttonUp")
  except WasmError as e:
    if debug:
      echo fmt"export buttonUp: {e.msg}"
  try:
    checkWasmRes m3_FindFunction(addr null0.export_buttonDown, null0.runtime, "buttonDown")
  except WasmError as e:
    if debug:
      echo fmt"export buttonDown: {e.msg}"

  if null0.export_load != nil:
    null0.export_load.call(void)

proc unload*(null0: Null0Cart) =
  if null0.export_unload != nil:
    null0.export_unload.call(void)
  if null0.files != nil:
    null0.files.close()

proc update*(null0: Null0Cart) =
  ## Update the model of the game
  if null0.export_update != nil:
    null0.export_update.call(void, float32(cpuTime() - null0.time_start))

