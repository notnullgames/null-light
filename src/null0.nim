# this is the CLI runtime

import docopt
import sdl2
import ./api

let doc = """
A fun and easy cross-language game-engine.

Usage:
  null0 new <name> [--lang=<language>]
  null0 watch <cart>
  null0 <cart> [--debug]

Options:
  -h, --help         Show this screen.
  --version          Show version.
  --lang=<language>  The programming language for a new project. [default: nim]
  --debug            Enable extra debugging output
"""

let args = docopt(doc, version = "null0 0.0.0")

if args["--debug"]:
  echo args

if args["new"]:
  echo "new is not implemented, yet."

if args["watch"]:
  echo "watch is not implemented, yet."

if args["<cart>"]:
  null0_load($args["<cart>"], args["--debug"])
  let screenSize = rect(0, 0, 320, 240)
  discard sdl2.init(INIT_EVERYTHING)
  let window = createWindow("null0", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, screenSize.w, screenSize.h, SDL_WINDOW_SHOWN)
  let render = createRenderer(window, -1, Renderer_Accelerated or Renderer_PresentVsync or Renderer_TargetTexture)
  let gameSurface = createRGBSurfaceFrom(cast[pointer](addr null0_images[0].image.data), cint screenSize.w, cint screenSize.h, cint 8, cint screenSize.w, uint32 0, uint32 0, uint32 0, uint32 0)
  let windwSurface = window.getSurface()

  var evt = sdl2.defaultEvent
  var runGame = true

  while runGame:
    while pollEvent(evt):
      if evt.kind == QuitEvent:
        runGame = false
        break
    render.setDrawColor(0, 0, 0, 255)
    render.clear()
    blitSurface(gameSurface, unsafeAddr screenSize, windwSurface, unsafeAddr screenSize)
    discard updateSurface(window)
    render.present()
  null0_unload()
  freeSurface(gameSurface)
  freeSurface(windwSurface)
  destroy render
  destroy window
  
