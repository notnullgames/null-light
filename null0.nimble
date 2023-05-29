# Package

version = "0.0.0"
author = "David Konsumer"
description = "A fun and easy cross-language game-engine"
license = "MIT"
srcDir = "src"
bin = @["null0"]


# Dependencies

requires "nim >= 1.6.12"

# These are usedd in the engine

requires "zippy"
requires "pixie"
requires "https://github.com/beef331/wasm3.git"

# These are used in the runtime

requires "docopt"
requires "boxy"
requires "windy"
requires "opengl"

import std/os
import std/strutils
import std/strformat

task clean, "Cleans up files":
  exec "rm -f null0 *.wasm *.null0 tests/test_api"

# TODO: lookup cart-type from game.json (this can only build nim, but other builds could be triggered)
# TODO: use zippy to build the cart

task cart, "Build a demo cart":
  let name = paramStr(paramCount())
  let dir = "carts/" & name
  exec(fmt"cd {dir} && nim c main.nim && zip ../../{name}.null0 -r * -x '*.DS_Store' -x '*.nim' && mv main.wasm ../../{name}.wasm")

task cart_run, "Build and run a demo cart":
  let name = paramStr(paramCount())
  let dir = "carts/" & name
  exec(fmt"cd {dir} && nim c main.nim && zip ../../{name}.null0 -r * -x '*.DS_Store' -x '*.nim' && mv main.wasm ../../{name}.wasm")
  exec(fmt"nimble run -- --debug {name}.null0")

task release, "Build a ddownload package for a release":
  discard
