# this is the shared header for nim-based carts

import std/[macros]

# This is how data is passed over the wasm-barrier
type
  Color* {.packed.} = object
    b*: uint8
    g*: uint8
    r*: uint8
    a*: uint8
  Vector2* {.packed.} = object
    x*: int32
    y*: int32
  Image* = uint32
  Font* = uint32
  HorizontalAlignment* = enum
    LeftAlign
    CenterAlign
    RightAlign
  VerticalAlignment* = enum
    TopAlign
    MiddleAlign
    BottomAlign


# macro for your exports that creates an emscripten export
# TODO: work on no-emscripten
macro null0*(t: typed): untyped =
  if t.kind notin {nnkProcDef, nnkFuncDef}:
    error("Can only export procedures", t)
  let
    newProc = copyNimTree(t)
    codeGen = nnkExprColonExpr.newTree(ident"codegendecl",
        newLit"EMSCRIPTEN_KEEPALIVE $# $#$#")
  if newProc[4].kind == nnkEmpty:
    newProc[4] = nnkPragma.newTree(codeGen)
  else:
    newProc[4].add codeGen
  newProc[4].add ident"exportC"
  result = newStmtList()
  result.add:
    quote do:
      {.emit: "/*INCLUDESECTION*/\n#include <emscripten.h>".}
  result.add:
    newProc

# You can use these templates instead of exposing procs for callbacks

template load*(body: untyped) {.dirty.} =
  proc load {.null0.} =
    body

template unload*(body: untyped) {.dirty.} =
  proc unload {.null0.} =
    body

template update*(body: untyped) {.dirty.} =
  proc update*(gameTime: float32) {.null0.} =
    body

template buttonDown*(body: untyped) {.dirty.} =
  proc buttonDown(button: int, device: int) {.null0.} =
    body

template buttonUp*(body: untyped) {.dirty.} =
  proc buttonUp(button: int, device: int) {.null0.} =
    body

const LIGHTGRAY* = Color(r: 200, g: 200, b: 200, a: 255)
const GRAY* = Color(r: 130, g: 130, b: 130, a: 255)
const DARKGRAY* = Color(r: 80, g: 80, b: 80, a: 255)
const YELLOW* = Color(r: 253, g: 249, b: 0, a: 255)
const GOLD* = Color(r: 255, g: 203, b: 0, a: 255)
const ORANGE* = Color(r: 255, g: 161, b: 0, a: 255)
const PINK* = Color(r: 255, g: 109, b: 194, a: 255)
const RED* = Color(r: 230, g: 41, b: 55, a: 255)
const MAROON* = Color(r: 190, g: 33, b: 55, a: 255)
const GREEN* = Color(r: 0, g: 228, b: 48, a: 255)
const LIME* = Color(r: 0, g: 158, b: 47, a: 255)
const DARKGREEN* = Color(r: 0, g: 117, b: 44, a: 255)
const SKYBLUE* = Color(r: 102, g: 191, b: 255, a: 255)
const BLUE* = Color(r: 0, g: 121, b: 241, a: 255)
const DARKBLUE* = Color(r: 0, g: 82, b: 172, a: 255)
const PURPLE* = Color(r: 200, g: 122, b: 255, a: 255)
const VIOLET* = Color(r: 135, g: 60, b: 190, a: 255)
const DARKPURPLE* = Color(r: 112, g: 31, b: 126, a: 255)
const BEIGE* = Color(r: 211, g: 176, b: 131, a: 255)
const BROWN* = Color(r: 127, g: 106, b: 79, a: 255)
const DARKBROWN* = Color(r: 76, g: 63, b: 47, a: 255)
const WHITE* = Color(r: 255, g: 255, b: 255, a: 255)
const BLACK* = Color(r: 0, g: 0, b: 0, a: 255)
const BLANK* = Color(r: 0, g: 0, b: 0, a: 0)
const MAGENTA* = Color(r: 255, g: 0, b: 255, a: 255)
const RAYWHITE* = Color(r: 245, g: 245, b: 245, a: 255)

const screen*: Image = 0

## Cart-side helpers

proc vec2*(x: int32, y: int32): Vector2 =
  return Vector2(x: x, y: y)

proc rgba*(r: uint8, g: uint8, b: uint8, a: uint8): Color =
  return Color(r: r, g: g, b: b, a: a)

proc `-`*(a, b: Vector2): Vector2 =
  return vec2(a.x - b.x, a.y - b.y)

proc `+`*(a, b: Vector2): Vector2 =
  return vec2(a.x + b.x, a.y + b.y)

proc `*`*(a, b: Vector2): Vector2 =
  return vec2(a.x * b.x, a.y * b.y)

proc `/`*(a, b: Vector2): Vector2 =
  return vec2(int32 a.x / b.x, int32 a.y / b.y)

proc `-`*(a: Vector2, b: int32): Vector2 =
  return vec2(a.x - b, a.y - b)

proc `+`*(a: Vector2, b: int32): Vector2 =
  return vec2(a.x + b, a.y + b)

proc `*`*(a: Vector2, b: int32): Vector2 =
  return vec2(a.x * b, a.y * b)

proc `/`*(a: Vector2, b: int32): Vector2 =
  return vec2(int32 a.x / b, int32 a.y / b)

### Host Functions

# Similar to echo, but simpler, and works cross-host
proc trace*(text: cstring) {.importc, cdecl.}

# Create a new image
proc new_image*(dimensions: Vector2): Image {.importc, cdecl.}

# Load an image return ID
proc load_image*(filename: cstring): Image {.importc, cdecl.}

# Draw an image on another image
proc draw_image*(targetID: Image, sourceID: Image, position: Vector2) {.importc, cdecl.}

# Draw a rectangle on image
proc rectangle*(targetID: Image, position: Vector2, dimensions: Vector2, borderSize: uint32 = 0) {.importc, cdecl.}

# Draw a rounded rectangle on image
proc rectangle_round(targetID: Image, position: Vector2, dimensions: Vector2, nw: uint32, ne: uint32, se: uint32, sw: uint32, borderSize: uint32 = 0) {.importc, cdecl.}

# Draw a rectangle on image
proc circle*(targetID: Image, position: Vector2, radius: uint32, borderSize: uint32 = 0) {.importc, cdecl.}

# Draw an ellipse on image
proc ellipse*(targetID: Image, position: Vector2, dimensions: Vector2, borderSize: uint32 = 0) {.importc, cdecl.}

# Set current fill/border color on image
proc set_color*(targetID: Image, fillColor: Color = BLACK, borderColor: Color = BLANK) {.importc, cdecl.}

# Load a font
proc load_font*(filename: cstring, size: uint32 = 20, color: Color = BLACK): Font {.importc, cdecl.}

# Draw text on a screen/canvas dimensions=Vector2(0, 0) wll not wrap
proc draw_text*(targetID: Image, text: cstring, position: Vector2, dimensions: Vector2 = vec2(0, 0), fontID: Font = 0, borderSize: uint32 = 0, hAlign = LeftAlign, vAlign = TopAlign, wrap = true) {.importc, cdecl.}

# Return Frames Per Second
proc fps*():float32 {.importc, cdecl.}

### Wrappers

proc trace*(thing: auto) =
  trace(cstring $thing)

proc load_image*(filename: string): Image =
  return load_image(cstring filename)

proc draw_image*(sourceID: Image, position: Vector2) =
  draw_image(screen, sourceID, position)

proc draw*(sourceID: Image, position: Vector2) =
  draw_image(screen, sourceID, position)

# TODO: there is a fill() operation that does this a bit better
proc clear*(targetID: Image, color: Color = BLACK) =
  set_color(targetID, color)
  rectangle(targetID, vec2(0, 0), vec2(320, 240), 0)

proc clear*(color: Color = BLACK) =
  clear(screen, color)

proc rectangle*(position: Vector2, dimensions: Vector2, borderSize: uint32 = 0) =
  rectangle(screen, position, dimensions, borderSize)

proc rectangle_round*(position: Vector2, dimensions: Vector2, nw: uint32, ne: uint32, se: uint32, sw: uint32, borderSize: uint32 = 0) =
  rectangle_round(screen, position, dimensions, nw, nw, se, sw, borderSize)

proc rectangle_round*(targetID: Image, position: Vector2, dimensions: Vector2, amount: uint32, borderSize: uint32 = 0) =
  rectangle_round(targetID, position, dimensions, amount, amount, amount, amount, borderSize)

proc rectangle_round*(position: Vector2, dimensions: Vector2, amount: uint32, borderSize: uint32 = 0) =
  rectangle_round(screen, position, dimensions, amount, amount, amount, amount, borderSize)

proc circle*(position: Vector2, radius: uint32, borderSize: uint32 = 0) =
  circle(screen, position, radius, borderSize)

proc ellipse*(position: Vector2, dimensions: Vector2, borderSize: uint32 = 0) =
  ellipse(screen, position, dimensions, borderSize = 0)

proc set_color*(fillColor: Color = BLACK, borderColor: Color = BLANK) =
  set_color(screen, fillColor, borderColor)

proc draw_text*(text: cstring, position: Vector2, dimensions: Vector2 = vec2(0, 0), fontID: Font = 0, borderSize: uint32 = 0, hAlign = LeftAlign, vAlign = TopAlign, wrap = true) =
  draw_text(screen, cstring text, position, dimensions, fontID, borderSize, hAlign, vAlign, wrap)

proc draw_text*(fontID: Font = 0, text: string, position: Vector2, targetID: Image = screen, dimensions: Vector2 = vec2(0, 0), borderSize: uint32 = 0, hAlign = LeftAlign, vAlign = TopAlign, wrap = true) =
  draw_text(targetID, cstring text, position, dimensions, fontID, borderSize, hAlign, vAlign, wrap)
