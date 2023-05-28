import zippy/ziparchives
import pixie
import wasm3
import wasm3/wasm3c
import std/times

# wrap an import (for wasm)
# TODO: can I generate sig?
template wasm_import*(name: untyped, sig: string, body: untyped):untyped {.dirty.} =
  let name = proc (runtime: PRuntime; ctx: PImportContext; sp: ptr uint64; mem: pointer): pointer {.cdecl.} =
    let wrapper = body
    var s = sp.stackPtrToUint()
    callHost(wrapper, s, mem)
  try:
    checkWasmRes m3_LinkRawFunction(module, "*", name.astToStr, sig, name)
  except WasmError as e:
    if debug:
      echo "import ", name.astToStr, ": ", e.msg

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

proc fromWasm*(result: var WasmVector2, sp: var uint64, mem: pointer) =
  var i: uint32
  i.fromWasm(sp, mem)
  result = cast[ptr WasmVector2](cast[uint64](mem) + i)[]

proc fromWasm*(result: var WasmColor, sp: var uint64, mem: pointer) =
  var i: uint32
  i.fromWasm(sp, mem)
  result = cast[ptr WasmColor](cast[uint64](mem) + i)[]

proc vec2(i: WasmVector2): Vec2 =
  return vec2(float i.x, float i.y)

proc rgba(i: WasmColor): ColorRGBA =
  return rgba(i.r, i.g, i.b, i.a)


# TODO: I can't figure out how to contain these in a shared object, so they are just globals for now
var null0_time_start*: float
var null0_files*: ZipArchiveReader
var null0_images*: seq[Context]
var null0_fonts*: seq[Font]

var null0_export_load:PFunction
var null0_export_update:PFunction
var null0_export_unload:PFunction
var null0_export_buttonDown:PFunction
var null0_export_buttonUp:PFunction


# TODO: currently this only loads zip, support dir & bare wasm
proc null0_load*(filename: string, debug: bool = false) =
  null0_time_start = cpuTime()

  # image 0 is "screen"
  null0_images.add(newContext(320, 240))
  
  null0_files = openZipArchive(filename)
  let wasmBytes = null0_files.extractFile("main.wasm")
  
  var env = m3_NewEnvironment()
  var runtime = env.m3_NewRuntime(uint32 uint16.high, nil)
  var module: PModule
  checkWasmRes m3_ParseModule(env, module.addr, cast[ptr uint8](unsafeAddr wasmBytes[0]), uint32 len(wasmBytes))
  checkWasmRes m3_LoadModule(runtime, module)

  # must create imports before getting exports

  wasm_import(trace, "v(*)"):
    proc (text: cstring) =
      echo text

  wasm_import(set_color, "v(i**)"):
    proc (targetID: uint32, fillColor: WasmColor, borderColor: WasmColor) =
      null0_images[targetID].fillStyle = rgba(fillColor)
      null0_images[targetID].strokeStyle = rgba(borderColor)

  wasm_import(dimensions, "v(ii)"):
    proc (retPointer: uint32, sourceID: uint32): WasmVector2 =
      let v = WasmVector2(x: int32(null0_images[sourceID].image.width), y: int32(null0_images[sourceID].image.height))
      cast[ptr WasmVector2](cast[uint64](mem) + retPointer)[] = v

  wasm_import(draw_image, "v(ii*)"):
    proc (targetID: uint32, sourceID:uint32, position: WasmVector2) =
      null0_images[targetID].image.draw(null0_images[sourceID].image, translate(vec2(position)))

  wasm_import(load_image, "i(*)"):
    proc (filename: cstring): uint32 =
      let i = len(null0_images)
      null0_images.add(newContext(decodeImage(null0_files.extractFile($filename))))
      return uint32 i

  wasm_import(new_image, "i(*)"):
    proc (dimensions: WasmVector2):uint32 =
      null0_images.add(newContext(dimensions.x, dimensions.y))
      return uint32 len(null0_images) - 1

  wasm_import(rectangle, "v(i**i)"):
    proc (targetID: uint32, position:WasmVector2, dimensions:WasmVector2, borderSize:uint32) =
      null0_images[targetID].lineWidth = float32 borderSize
      let shape = rect(vec2(position), vec2(dimensions))
      null0_images[targetID].fillRect(shape)
      if borderSize != 0:
        null0_images[targetID].strokeRect(shape)

  wasm_import(circle, "v(i*ii)"):
    proc (targetID: uint32, position:WasmVector2, radius: uint32, borderSize:uint32) =
      null0_images[targetID].lineWidth = float32 borderSize
      let shape = circle(vec2(position), float32 radius)
      null0_images[targetID].fillCircle(shape)
      if borderSize != 0:
        null0_images[targetID].strokeCircle(shape)

  wasm_import(rectangle_round, "v(i**iiiii)"):
    proc (targetID: uint32, position:WasmVector2, dimensions:WasmVector2, nw: uint32, ne: uint32, se: uint32, sw: uint32, borderSize:uint32) =
      null0_images[targetID].lineWidth = float32 borderSize
      let shape = rect(vec2(position), vec2(dimensions))
      null0_images[targetID].fillRoundedRect(shape, float32 nw, float32 ne, float32 se, float32 sw)
      if borderSize != 0:
        null0_images[targetID].strokeRoundedRect(shape, float32 nw, float32 ne, float32 se, float32 sw)

  wasm_import(ellipse, "v(i**i)"):
    proc (targetID: uint32, position:WasmVector2, dimensions:WasmVector2, borderSize:uint32) =
      null0_images[targetID].lineWidth = float32 borderSize
      null0_images[targetID].fillEllipse(vec2(position), float32 dimensions.x, float32 dimensions.y)
      if borderSize != 0:
        null0_images[targetID].strokeEllipse(vec2(position), float32 dimensions.x, float32 dimensions.y)

  try:
    checkWasmRes m3_FindFunction(addr null0_export_load, runtime, "load")
  except WasmError as e:
    if debug:
      echo "export load: ", e.msg
  try:
    checkWasmRes m3_FindFunction(addr null0_export_unload, runtime, "unload")
  except WasmError as e:
    if debug:
      echo "export unload: ", e.msg
  try:
    checkWasmRes m3_FindFunction(addr null0_export_update, runtime, "update")
  except WasmError as e:
    if debug:
      echo "export update: ", e.msg
  try:
    checkWasmRes m3_FindFunction(addr null0_export_buttonUp, runtime, "buttonUp")
  except WasmError as e:
    if debug:
      echo "export buttonUp: ", e.msg
  try:
    checkWasmRes m3_FindFunction(addr null0_export_buttonDown, runtime, "buttonDown")
  except WasmError as e:
    if debug:
      echo "export buttonDown: ", e.msg

  if null0_export_load != nil:
    null0_export_load.call(void)

proc null0_unload*() =
  if null0_export_unload != nil:
    null0_export_unload.call(void)
  if null0_files != nil:
    null0_files.close()

proc null0_update*() =
  ## Update the model of the game
  if null0_export_update != nil:
    null0_export_update.call(void, float32 cpuTime() - null0_time_start)

