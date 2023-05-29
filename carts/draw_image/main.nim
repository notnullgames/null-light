var logo: Image
var offset: Vector2

load:
  trace("Hello from draw_image")
  logo = load_image("icon.png")
  # this throws  malformed Wasm binary
  #offset = (screen.dimensions() / 2) - (logo.dimensions() / 2)
  offset.x = 96

update:
  clear(BLACK)
  offset.y = (int32(gameTime * 1000) mod (240+137)) - 137
  #offset.y = 51
  logo.draw(offset)

unload:
  trace("Ok, bye.")
