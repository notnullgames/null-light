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
