# this is the shared header for nim-based carts

import std/[macros]

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
  proc update*(frame: int) {.null0.} =
    body

template buttonDown*(body: untyped) {.dirty.} =
  proc buttonDown(button: int, device: int) {.null0.} =
   body

template buttonUp*(body: untyped) {.dirty.} =
  proc buttonUp(button: int, device: int) {.null0.} =
   body

# Similar to echo, but simpler, and works cross-host
proc trace*(text: cstring) {.importc, cdecl.}

