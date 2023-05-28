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


# macro for your exports that creates an emscripten export
# TODO: work on no-emscripten
macro null0*(t: typed): untyped =
  if t.kind notin {nnkProcDef, nnkFuncDef}:
    error("Can only export procedures", t)
  let
    newProc = copyNimTree(t)
    codeGen = nnkExprColonExpr.newTree(ident"codegendecl", newLit"EMSCRIPTEN_KEEPALIVE $# $#$#")
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
const YELLOW* = Color(r: 253, g: 249, b: 0, a: 255  )
const GOLD* = Color(r: 255, g: 203, b: 0, a: 255  )
const ORANGE* = Color(r: 255, g: 161, b: 0, a: 255  )
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
const BLANK* = Color(r: 0, g: 0, b: 0, a: 0  )
const MAGENTA* = Color(r: 255, g: 0, b: 255, a: 255)
const RAYWHITE* = Color(r: 245, g: 245, b: 245, a: 255)

const screen*: Image = 0

## Cart-side helpers

proc vec2*(x:int32, y: int32):Vector2 =
  return Vector2(x:x, y:y)

proc rgba(r: uint8, g: uint8, b: uint8, a: uint8): Color =
  return Color(r:r, g:g, b:b, a:a)

proc `-`*(a, b: Vector2): Vector2 =
  return vec2(a.x - b.x, a.y - b.y)

proc `+`*(a, b: Vector2): Vector2 =
  return vec2(a.x + b.x, a.y + b.y)

proc `*`*(a, b: Vector2): Vector2 =
  return vec2(a.x * b.x, a.y * b.y)

proc `/`*(a, b: Vector2): Vector2 =
  return vec2(int32 a.x / b.x, int32 a.y / b.y)

proc `-`*(a:Vector2, b: int32): Vector2 =
  return vec2(a.x - b, a.y - b)

proc `+`*(a:Vector2, b: int32): Vector2 =
  return vec2(a.x + b, a.y + b)

proc `*`*(a:Vector2, b: int32): Vector2 =
  return vec2(a.x * b, a.y * b)

proc `/`*(a:Vector2, b: int32): Vector2 =
  return vec2(int32 a.x / b, int32 a.y / b)

### Host Functions

# Similar to echo, but simpler, and works cross-host
proc trace*(text: cstring) {.importc, cdecl.}

# Load an image/canvas return ID
proc load_image*(filename: cstring): Image {.importc, cdecl.}

# Draw an image on another image
proc draw_image*(targetID: Image, sourceID:Image, position: Vector2) {.importc, cdecl.}

# Get height/width of an image/canvas
proc dimensions*(sourceID: Image): Vector2 {.importc, cdecl.}

# Draw a filled-rectangle on image/canvas
proc rect_filled*(targetID: Image, position:Vector2, dimensions:Vector2, color: Color = BLACK) {.importc, cdecl.}

### Wrappers

proc trace*(thing: auto) =
  trace(cstring $thing)

proc load_image*(filename: string): Image =
  return load_image(cstring filename)

proc draw_image*(sourceID: Image, position: Vector2) =
  draw_image(screen, sourceID, position)

proc draw*(sourceID: Image, position: Vector2) =
  draw_image(screen, sourceID, position)

proc rect_filled*(position:Vector2, dimensions:Vector2, color: Color = BLACK) =
  rect_filled(screen, position, dimensions, color)

proc clear*(targetID: Image, color: Color = BLACK) =
  rect_filled(targetID, vec2(0, 0), vec2(320, 240), color)

proc clear*(color: Color = BLACK) =
  clear(screen, color)
