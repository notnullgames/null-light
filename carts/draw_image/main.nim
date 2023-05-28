var logo:Image
var offset:Vector2
var logoSize:Vector2
var screenSize:Vector2

load:
  trace("Hello from draw_image")
  logo = load_image("icon.png")
  logoSize = logo.dimensions()
  screenSize = screen.dimensions()
  offset.x = int32(screenSize.x / 2) - int32(logoSize.x / 2)

update:
  # gameTime is the current seconds the engine has been running, as a float32
  var frameTime = int (gameTime * 100)
  offset.y = int32(frameTime mod (screenSize.y + logoSize.y)) - logoSize.y
  clear()
  logo.draw(offset)

unload:
  trace("Ok, bye.")