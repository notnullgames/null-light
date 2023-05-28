var logo:Image
var offset:Vector2

load:
  trace("Hello from draw_images")
  logo = load_image("icon.png")
  offset = (screen.dimensions() / 2) - (logo.dimensions() / 2)
  trace("screen: " & $screen.dimensions())
  trace("logo: " & $logo.dimensions())
  trace("offset: " & $offset)

update:
  logo.draw(offset.x, offset.y)

unload:
  trace("Ok, bye.")