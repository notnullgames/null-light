# Package

version       = "0.0.0"
author        = "David Konsumer"
description   = "A fun and easy cross-language game-engine"
license       = "MIT"
srcDir        = "src"
bin           = @["null0"]


# Dependencies

requires "nim >= 1.6.12"
requires "zippy >= 0.10.10"
requires "docopt >= 0.7.0"
requires "pixie >= 5.0.6"
requires "https://github.com/beef331/wasm3 >= 0.1.10"

import std/os
import std/strutils
import std/strformat

task clean, "Cleans up files":
  exec "rm -f null0 *.wasm *.null0 tests/test_api"

# TODO: lookup type from game.json

task cart, "Build a demo cart":
  let name = paramStr(paramCount())
  let dir = "carts/" & name
  exec(fmt"cd {dir} && nim c main.nim && zip ../../{name}.null0 -r * -x '*.DS_Store' -x '*.nim' && mv main.wasm ../../{name}.wasm")
