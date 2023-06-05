### Engine

These are thing related to the actual engine, and not specific to any subsystem.

- [X] basic cart loading
- [ ] namespace all to `null0` in wasm
- [ ] WASI? It's a lot more complicated, but it would make more built-in language stuff work (`echo`, `readFile`, etc)
- [ ] `main()` instead of `load()` for C/nim/etc? Might make it seem more "regular"
- [ ] drop `update()` time param and use `time()` to get clock-time, or WASI equiv
- [ ] `random()`, or WASI equiv
- [ ] retroarch core that can do cheats, for enabling extended features like networking, save/restore, and GL stuff
- [ ] hot-reloading: reload the code on change, but keep the state
- [ ] Interpreted main.wasm: Make a few, like quickjs, wren, etc. Would make dev go faster with hot-reloading (no build)
- [ ] more languages: basic native wasm (rust, zig, C, C++, etc) headers, and a header for assemblyscript
- [ ] generate more: docs, hosts, cart-headers, etc, could all be mostly generated from central definition
- [ ] embedded host: esp32, no GL, etc.
- [ ] optimize for smaller cart-wasm (clang, etc)


### Web

This is stuff related to web-runtime & docs

- [ ] reuse as much as I can from native host, esp sound/graphics
- [ ] basic web-compopnent with attribs to let you tune how it runs
- [ ] show icon & info, click-to-run (toggle, so sound works on web, animation only happens if focused)
- [ ] improve showcase/docs
- [ ] community site
- [ ] automate publishing carts (via git)


### Graphics

These are things specific to graphics sub-system, which is mostly [pixie](https://github.com/treeform/pixie).

- [X] basic image-loading
- [X] basic vetor drawing
- [X] basic TTF support
- [ ] rethink how graphics work: don't wipe all frames, optimize for opengl (preload images in tilemap, compose at end, in GL-space, [do vector in GL-space](https://github.com/rev22/svgl) instead of pixie?)
- [ ] layers? If each layer was set to a type (vector, image, text) more info could be shared and it could be better optimized at end
- [ ] `clear()` should be in engine, and use `fill()` or even better:  GL clear
- [ ] efficient tilemap, in engine
- [ ] efficient sprite-animation, in engine
- [ ] TTF fonts should work in ctx-space (respond to fill change, etc) should these be pre-loaded as images? (to work better with GL/tilemap)
- [ ] support image-based fonts
- [ ] figure out what is wrong with `fps()`
- [ ] transform/scale/tint/etc
- [ ] basic 3D API, so you can try out/reuse low-level OpenGL code in whatever language you like
- [ ] image-level GLSL shaders
- [ ] allow changing the window resolution?
- [ ] allow trigger fullscreen

### Sound

This is all the sound stuff. I am thinking [slappy](https://github.com/treeform/slappy) would work well.

- [ ] basic OGG/WAV files
- [ ] positional sound
- [ ] [sfxr](https://www.drpetter.se/project_sfxr.html)
- [ ] [MOD/XM/etc](https://mikmod.sourceforge.net/)
- [ ] [TTS](https://discordier.github.io/sam/)
- [ ] effects/sound-callback (process current output stream or mic)
- [ ] Think about embeddded (ogg/mod is pretty heavy for micro)

### File

Things related to filesystem.

- [ ] overlay-write (write to user dir, but put it in the same location as cart-files)
- [ ] read file from cart/write-overlay
- [ ] append write/partial read (for streaming)


### Networking

Things related to networking with other carts & servers.

- [ ] require CLI/web flag or cheatcode in retroarch
- [ ] allowed hosts (so you can lock to current or specific list on web)
- [ ] http(s)
- [ ] retroarch remote-play
- [ ] non-retroarch (native/web) remote-play with same players
- [ ] low-level sockets (see WASI)

### Input

Basic input things.

- [ ] basic keyboard mapped controller input
- [ ] gamepad database for smoothing out differences between controllers
- [ ] send the controller number along with `buttonDown`/`buttonUp` for local multiplayer
- [ ] `keyDown`/`keyUp`/`mouseMove`/`mouseDown`/`mouseUp` for non-controller input (trigger `buttonDown` and `keyDown` for overlapping key, for example)


### Carts

Carts to run in engine.

- [ ] all API functions should be called in a demo
- [ ] finish flappybird
- [ ] host a cart-challenge
- [ ] some classics (atari/nes/snes era)
- [ ] Tracker similar to lsdj/M8 that can do tts/sfxr/sample and load (and maybe save) mod

