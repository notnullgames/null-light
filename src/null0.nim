# this is the CLI runtime

import docopt
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
  null0_unload()
