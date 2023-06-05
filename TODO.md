### Engine

These are thing related to the actual engine, and not specific to any subsystem.

- [ ] - namespace all to `null0` in wasm
- [ ] - WASI? It's a lot more complicated, but it would make more built-in language stuff work (`echo`, `readFile`, etc)
- [ ] - `main()` instead of `load()` for C/nim/etc? Might make it seem more "regular"
- [ ] - drop `update()` time param and use `time()` to get clock-time, or WASI equiv
- [ ] - `random()`, or WASI equiv
- [ ] - retroarch core that can do save/restore, cheats (for enabling extended features like networking) and GL stuff. maybe remote-play, too?
- [ ] - hot-reloading: reload the code on change, but keep the state/position
- [ ] - Interpreted main.wasm: Make a few, like quickjs, wren, etc. Would make dev go faster with hot-reloading (no build)
- [ ] - more languages: basic native wasm (rust, zig, C, C++, etc) headers, and a headder for assemblyscript

### Input

- [ ] - basic mapped controller input
- [ ] - `keyDown`/`keyUp`/`mouseMove`/`mouseDown`/`mouseUp` for non-controller input (trigger `buttonDown` and `keyDown` for overlapping key, for example)

### Web

This is stuff related to web-runtime

- [ ] - reuse as much as I can from native host
- [ ] - basic web-compopnent with attribs to let you tune how it runs
- [ ] - show icon & info, click-to-run


### Graphics

These are things specific to graphics sub-system, which is mostly [pixie](https://github.com/treeform/pixie).

- [ ] - rethink how graphics work: don't wipe all frames, optimize for opengl (preload images in tilemap, compose at end, in GL space)
- [ ] - `clear()` should be in engine, and use `fill()` or even better:  GL clear
- [ ] - efficient tilemap, in engine
- [ ] - efficient sprite-animation, in engine
- [ ] - fonts should work in ctx-space (respond to fill change, etc) should these be pre-loaded as images? (to work better with GL/tilemap)
- [ ] - figure out what is wrong with `fps()`
- [ ] - transform/scale/tint/etc
- [ ] - layers? If each layer was set to a type (vector, image, text) more info could be shared and it could be better optimized at end

### Sound

This is all the sound stuff. I am thinking [slappy](https://github.com/treeform/slappy) would work well.

- [ ] - basic OGG/WAV files
- [ ] - positional sound
- [ ] - effects/sound-callback (process current output stream or mic)
- [ ] - [sfxr](https://www.drpetter.se/project_sfxr.html)
- [ ] - [MOD/XM/etc](https://mikmod.sourceforge.net/)
- [ ] - [TTS](https://discordier.github.io/sam/)

### Demos

- [ ] - all API functions should be called in a demo
- [ ] - finish flappybird
- [ ] - host a challenge
- [ ] - some classics (atari/nes/snes era)
