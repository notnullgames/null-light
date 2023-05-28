import zippy/ziparchives
import pixie
import wasm3
import wasm3/wasm3c
import std/times

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

# TODO: these would be simpler in a macro

proc export_trace(runtime: PRuntime; ctx: PImportContext; sp: ptr uint64; mem: pointer): pointer {.cdecl.} =
  var sp = sp.stackPtrToUint()
  proc procImpl(text: cstring) =
    echo text
  callHost(procImpl, sp, mem)

proc export_load_image(runtime: PRuntime; ctx: PImportContext; sp: ptr uint64; mem: pointer): pointer {.cdecl.} =
  var sp = sp.stackPtrToUint()
  proc procImpl(filename: cstring): uint32 =
    let i = len(null0_images)
    null0_images.add(newContext(decodeImage(null0_files.extractFile($filename))))
    return uint32 i
  callHost(procImpl, sp, mem)

proc export_draw_image(runtime: PRuntime; ctx: PImportContext; sp: ptr uint64; mem: pointer): pointer {.cdecl.} =
  var sp = sp.stackPtrToUint()
  proc procImpl(targetID: uint32, sourceID:uint32, position:WasmVector2) =
    null0_images[targetID].image.draw(null0_images[sourceID].image, translate(vec2(position)))
  callHost(procImpl, sp, mem)

proc export_dimensions(runtime: PRuntime; ctx: PImportContext; sp: ptr uint64; mem: pointer): pointer {.cdecl.} =
  var sp = sp.stackPtrToUint()
  proc procImpl(retPointer: uint32, sourceID: uint32) =
    let v = WasmVector2(x: int32(null0_images[sourceID].image.width), y: int32(null0_images[sourceID].image.height))
    cast[ptr WasmVector2](cast[uint64](mem) + retPointer)[] = v
  callHost(procImpl, sp, mem)

proc export_rect_filled(runtime: PRuntime; ctx: PImportContext; sp: ptr uint64; mem: pointer): pointer {.cdecl.} =
  var sp = sp.stackPtrToUint()
  proc procImpl(targetID: uint32, position:WasmVector2, dimensions:WasmVector2, color: WasmColor) =
    null0_images[targetID].fillStyle = rgba(color)
    null0_images[targetID].fillRect(rect(vec2(position), vec2(dimensions)))
  callHost(procImpl, sp, mem)

proc null0_setup_imports(module: PModule, debug: bool = false) =
  try:
    checkWasmRes m3_LinkRawFunction(module, "*", "trace", "v(*)", export_trace)
  except WasmError as e:
    if debug:
      echo "import trace: ", e.msg
  try:
    checkWasmRes m3_LinkRawFunction(module, "*", "load_image", "i(*)", export_load_image)
  except WasmError as e:
    if debug:
      echo "import load_image: ", e.msg
  try:
    checkWasmRes m3_LinkRawFunction(module, "*", "draw_image", "v(ii*)", export_draw_image)
  except WasmError as e:
    if debug:
      echo "import draw_image: ", e.msg
  try:
    # dimension(returnPtr, image)
    checkWasmRes m3_LinkRawFunction(module, "*", "dimensions", "v(ii)", export_dimensions)
  except WasmError as e:
    if debug:
      echo "import dimensions: ", e.msg
  try:
    checkWasmRes m3_LinkRawFunction(module, "*", "rect_filled", "v(i***)", export_rect_filled)
  except WasmError as e:
    if debug:
      echo "import rect_filled: ", e.msg


  

proc null0_setup_exports(runtime: PRuntime, debug:bool = false) =
  try:
    checkWasmRes m3_FindFunction(null0_export_update.addr, runtime, "update")
  except WasmError as e:
    if debug:
      echo "export update: ", e.msg
  try:
    checkWasmRes m3_FindFunction(null0_export_unload.addr, runtime, "unload")
  except WasmError as e:
    if debug:
      echo "export unload: ", e.msg
  try:
    checkWasmRes m3_FindFunction(null0_export_load.addr, runtime, "load")
  except WasmError as e:
    if debug:
      echo "export load: ", e.msg
  try:
    checkWasmRes m3_FindFunction(null0_export_buttonDown.addr, runtime, "buttonDown")
  except WasmError as e:
    if debug:
      echo "export buttonDown: ", e.msg
  try:
    checkWasmRes m3_FindFunction(null0_export_buttonUp.addr, runtime, "buttonUp")
  except WasmError as e:
    if debug:
      echo "export buttonUp: ", e.msg

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
  null0_setup_imports(module, debug)
  null0_setup_exports(runtime, debug)

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

