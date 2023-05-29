var logo: Image

load:
  trace("Hello from draw_image")
  logo = load_image("icon.png")

update:
  clear(BLACK)
  logo.draw(vec2(96, 51))

unload:
  trace("Ok, bye.")
