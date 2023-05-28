# this is the CLI runtime

import docopt
import boxy
import opengl
import windy

import ./api

let doc = """
A fun and easy cross-language game-engine.

Usage:
  null0 new <name> [--lang=<language>]
  null0 watch [--debug] <cart>
  null0 [--debug] [--screenshot=<screenshot>] <cart>

Options:
  -h, --help                Show this screen.
  --version                 Show version.
  --lang=<language>         The programming language for a new project. [default: nim]
  --debug                   Enable extra debugging output
  --screenshot=<screenshot> Take a screenshot instead of fully running the cart
"""

proc heartTest(image: Image) =
  image.fillPath(
    """
      M 20 60
      A 40 40 90 0 1 100 60
      A 40 40 90 0 1 180 60
      Q 180 120 100 180
      Q 20 120 20 60
      z
    """,
    parseHtmlColor("#FC427B").rgba,
    translate(vec2(60, 20))
  )


let args = docopt(doc, version = "null0 0.0.0")

if args["--debug"]:
  echo args

if args["new"]:
  echo "new is not implemented, yet."
  quit(1)

if args["watch"]:
  echo "watch is not implemented, yet."
  quit(1)

if args["<cart>"]:
  null0_load($args["<cart>"], args["--debug"])

  if args["--screenshot"]:
    null0_update()
    null0_images[0].image.writeFile($args["--screenshot"])
    null0_unload()
    quit(0)

  var frame: int
  let windowSize = ivec2(320, 240)
  let window = newWindow("null0", windowSize)
  makeContextCurrent(window)
  loadExtensions()
  let bxy = newBoxy()
  
  let ratio = windowSize.x / windowSize.y
  var scale = 1.0
  var offset = vec2(0, 0)
  var fX:float
  var fY:float

  window.onFrame = proc() =
    frame.inc()
    null0_update()

    # adjust scale/offset to fill the window nicely
    fX = float(window.size.x)
    fY = float(window.size.y)
    if float(window.size.x) > (fY * ratio):
      scale = window.size.y / windowSize.y
      offset.x = (fX - (float(windowSize.x) * scale)) / 2
      offset.y = 0
    else:
      scale = window.size.x / windowSize.x
      offset.y = (fY - (float(windowSize.y) * scale)) / 2
      offset.x = 0
    
    # TODO: this is clearing all the tiles every frame, which is very inefficient.
    bxy.clearAtlas()
    bxy.addImage("screen" & $frame, null0_images[0].image)

    bxy.beginFrame(window.size)
    bxy.saveTransform()
    bxy.translate(offset)
    bxy.scale(scale)
    bxy.drawImage("screen" & $frame, vec2(0, 0))
    bxy.restoreTransform()
    bxy.endFrame()
    window.swapBuffers()

  while not window.closeRequested:
    pollEvents()

  null0_unload()
  
