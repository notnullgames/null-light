import zippy/ziparchives
import pixie
import wasm3
import wasm3/wasm3c
import std/times
import api_graphics

type
  Null0Game* = object
    start*: float
    files*: ZipArchiveReader
    images*: seq[Context]
    fonts*: seq[Font]
    env: WasmEnv
    wload: PFunction
    wupdate: PFunction
    wclose: PFunction
    wbuttonUp: PFunction
    wbuttonDown: PFunction

proc `=destroy`*(game: var Null0Game) =
  if game.wclose != nil:
    game.wclose.call(void)

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

proc newNull0Game*(filename: string): Null0Game =
  ## Create a new Game instance
  var game: Null0Game
  game.files = openZipArchive(filename)
  game.images.add(newContext(320, 240))
  let wasmBytes = game.readFile("main.wasm")

  proc exportTrace(text: cstring) =
    echo text

  game.env = loadWasmEnv(wasmBytes, loadAlloc = true,  hostProcs = [
    exportTrace.toWasmHostProc("*", "trace", "v(*)")
  ])

  game.wload = game.env.findFunction("load")
  game.wupdate = game.env.findFunction("update")
  game.wclose = game.env.findFunction("close")
  game.start = cpuTime()
  if game.wload != nil:
    game.wload.call(void)
  return game
