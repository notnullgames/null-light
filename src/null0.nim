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
  null0 watch <cart>
  null0 <cart> [--debug]

Options:
  -h, --help         Show this screen.
  --version          Show version.
  --lang=<language>  The programming language for a new project. [default: nim]
  --debug            Enable extra debugging output
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

if args["watch"]:
  echo "watch is not implemented, yet."

if args["<cart>"]:
  var frame: int
  let windowSize = ivec2(320, 240)
  let window = newWindow("null0", windowSize)
  makeContextCurrent(window)
  loadExtensions()
  let bxy = newBoxy()

  null0_load($args["<cart>"], args["--debug"])

  let ratio = windowSize.x / windowSize.y
  var scale = 1.0
  var offset = vec2(0, 0)
  var fX:float
  var fY:float

  window.onFrame = proc() =
    frame.inc()

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

    null0_update()

    # This is maybe too inneficient, but I need to make a new image for every frame
    bxy.addImage($frame, null0_images[0].image)

    bxy.beginFrame(window.size)
    bxy.saveTransform()
    bxy.translate(offset)
    bxy.scale(scale)
    bxy.drawImage($frame, vec2(0, 0))
    bxy.restoreTransform()
    bxy.endFrame()
    window.swapBuffers()

  while not window.closeRequested:
    pollEvents()

  null0_unload()
  
