### Engine

These are thing related to the actual engine, and not specific to any subsystem.

- [ ] - namespace all to `null0` in wasm
- [ ] - WASI? It's a lot more complicated, but it would make more built-in language stuff work (`echo`, `readFile`, etc)
- [ ] - `main()` instead of `load()` for C/nim/etc? Might make it seem more "regular"
- [ ] - drop `update()` time param and use `time()` to get clock-time, or WASI equiv
- [ ] - `random()`, or WASI equiv
- [ ] - retroarch core that can do cheats, for enabling extended features like networking, save/restore, and GL stuff
- [ ] - hot-reloading: reload the code on change, but keep the state/position
- [ ] - Interpreted main.wasm: Make a few, like quickjs, wren, etc. Would make dev go faster with hot-reloading (no build)
- [ ] - more languages: basic native wasm (rust, zig, C, C++, etc) headers, and a headder for assemblyscript


### Web

This is stuff related to web-runtime & docs

- [ ] - reuse as much as I can from native host, esp sound/graphics
- [ ] - basic web-compopnent with attribs to let you tune how it runs
- [ ] - show icon & info, click-to-run
- [ ] - improve showcase/docs
- [ ] - community site


### Graphics

These are things specific to graphics sub-system, which is mostly [pixie](https://github.com/treeform/pixie).

- [ ] - rethink how graphics work: don't wipe all frames, optimize for opengl (preload images in tilemap, compose at end, in GL space, [do vector in GL-space?](https://github.com/rev22/svgl))
- [ ] - `clear()` should be in engine, and use `fill()` or even better:  GL clear
- [ ] - efficient tilemap, in engine
- [ ] - efficient sprite-animation, in engine
- [ ] - TTF fonts should work in ctx-space (respond to fill change, etc) should these be pre-loaded as images? (to work better with GL/tilemap)
- [ ] - support image-based fonts
- [ ] - figure out what is wrong with `fps()`
- [ ] - transform/scale/tint/etc
- [ ] - layers? If each layer was set to a type (vector, image, text) more info could be shared and it could be better optimized at end

### Sound

This is all the sound stuff. I am thinking [slappy](https://github.com/treeform/slappy) would work well.

- [ ] - basic OGG/WAV files
- [ ] - positional sound
- [ ] - [sfxr](https://www.drpetter.se/project_sfxr.html)
- [ ] - [MOD/XM/etc](https://mikmod.sourceforge.net/)
- [ ] - [TTS](https://discordier.github.io/sam/)
- [ ] - effects/sound-callback (process current output stream or mic)

### File

Things related to filesystem.

- [ ] - read file from cart
- [ ] - overlay-write (write to user dir, but put it in the same location as cart-files)
- [ ] - append write/partial read (for streaming)


### Networking

Things related to networking with other carts & servers.

- [ ] - require CLI/web flag or cheatcode in retroarch
- [ ] - allowed hosts (so you can lock to current or specific list on web)
- [ ] - http(s)
- [ ] - retroarch remote-play
- [ ] - non-retroarch (native/web) remote-play with same players
- [ ] - low-level sockets (see WASI)

### Input

Basic input things.

- [ ] - basic mapped controller input
- [ ] - `keyDown`/`keyUp`/`mouseMove`/`mouseDown`/`mouseUp` for non-controller input (trigger `buttonDown` and `keyDown` for overlapping key, for example)


### Carts

Carts to run in engine.

- [ ] - all API functions should be called in a demo
- [ ] - finish flappybird
- [ ] - host a cart-challenge
- [ ] - some classics (atari/nes/snes era)
- [ ] - Tracker similar to lsdj/M8 that can do tts/sfxr/sample and load (and maybe save) mod

