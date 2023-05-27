import zippy/ziparchives
import pixie
import wasm3
import wasm3/wasm3c
import std/times

type
  Null0Game* = object
    start*: float
    files*: ZipArchiveReader
    images*: seq[Context]
    fonts*: seq[Font]
    env: WasmEnv
    wload: PFunction
    wupdate: PFunction
    wunload: PFunction
    wbuttonUp: PFunction
    wbuttonDown: PFunction

proc `=destroy`*(game: var Null0Game) =
  if game.wunload != nil:
    game.wunload.call(void)

  if game.files != nil:
    game.files.close()

proc update*(game: Null0Game) =
  ## Update the model of the game
  if game.wupdate != nil:
    game.wupdate.call(void, cpuTime() - game.start)

proc draw*(game: Null0Game): Image =
  ## Get the current image of the screen
  if game.images[0] != nil:
    return game.images[0].image

proc readFile*(game: Null0Game, filename: string): string =
  ## Read a file from the current cart
  return game.files.extractFile(filename)

proc newNull0Game*(filename: string, debug: bool = false): Null0Game =
  ## Create a new Game instance
  var game: Null0Game
  game.files = openZipArchive(filename)
  game.images.add(newContext(320, 240))
  let wasmBytes = game.readFile("main.wasm")
  game.start = cpuTime()

  proc exportTrace(text: cstring) =
    echo text

  try:
    game.env = loadWasmEnv(wasmBytes, hostProcs = [
      exportTrace.toWasmHostProc("*", "trace", "v(*)")
    ])

    try:
      game.wload = game.env.findFunction("load")
    except WasmError as e:
      if debug:
        echo "export load: ", e.msg

    try:
      game.wupdate = game.env.findFunction("update")
    except WasmError as e:
      if debug:
        echo "export update: ", e.msg
    
    try:
      game.wunload = game.env.findFunction("unload")
    except WasmError as e:
      if debug:
        echo "export unload: ", e.msg

    try:
      game.wButtonDown = game.env.findFunction("buttonDown")
    except WasmError as e:
      if debug:
        echo "export buttonDown: ", e.msg
    
    try:
      game.wButtonUp = game.env.findFunction("buttonUp")
    except WasmError as e:
      if debug:
        echo "export buttonUp: ", e.msg

    if game.wload != nil:
      game.wload.call(void)
  
  except WasmError as e:
      if debug:
        echo "env: ", e.msg
  
  return game
