import zippy/ziparchives
import pixie
import wasm3
import wasm3/wasm3c
import std/times

# I can't figure out how to contain these in a shared object
# so they are just globals for now
var null0_time_start*: float
var null0_files*: ZipArchiveReader
var null0_images*: seq[Context]
var null0_fonts*: seq[Font]
var null0_env: WasmEnv
var wload: PFunction
var wupdate: PFunction
var wunload: PFunction
var wbuttonUp: PFunction
var wbuttonDown: PFunction

proc exportTrace(text: cstring) =
  ## Similar to echo, but much simpler
  echo text

proc null0_load*(filename: string, debug: bool = false) =
  null0_files = openZipArchive(filename)
  null0_images.add(newContext(320, 240))
  let wasmBytes = null0_files.extractFile("main.wasm")
  null0_time_start = cpuTime()

  try:
    null0_env = loadWasmEnv(wasmBytes, hostProcs = [
      exportTrace.toWasmHostProc("*", "trace", "v(*)")
    ])

    try:
      wload = null0_env.findFunction("load")
    except WasmError as e:
      if debug:
        echo "export load: ", e.msg

    try:
      wupdate = null0_env.findFunction("update")
    except WasmError as e:
      if debug:
        echo "export update: ", e.msg
    
    try:
      wunload = null0_env.findFunction("unload")
    except WasmError as e:
      if debug:
        echo "export unload: ", e.msg

    try:
      wButtonDown = null0_env.findFunction("buttonDown")
    except WasmError as e:
      if debug:
        echo "export buttonDown: ", e.msg
    
    try:
      wButtonUp = null0_env.findFunction("buttonUp")
    except WasmError as e:
      if debug:
        echo "export buttonUp: ", e.msg

    if wload != nil:
      wload.call(void)
  
  except WasmError as e:
    if debug:
      echo "env: ", e.msg

proc null0_unload*() =
  if wunload != nil:
    wunload.call(void)
  if null0_files != nil:
    null0_files.close()

proc null_update*() =
  ## Update the model of the game
  if wupdate != nil:
    wupdate.call(void, cpuTime() - null0_time_start)

proc null_draw*(): Image =
  ## Get the current image of the screen
  if null0_images[0] != nil:
    return null0_images[0].image

