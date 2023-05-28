var logo:Image
var offset:Vector2

load:
  trace("Hello from draw_image")
  logo = load_image("icon.png")
  offset = (screen.dimensions() / 2) - (logo.dimensions() / 2)
  trace("screen: " & $screen.dimensions())
  trace("logo: " & $logo.dimensions())
  trace("offset: " & $offset)

update:
  logo.draw(offset)

unload:
  trace("Ok, bye.")