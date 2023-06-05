var bird: array[3, Image] 
var logo:Image
var land:Image
var pipe_bottom:Image
var pipe_top:Image
var sky:Image

load:
  trace("Hello from flappybird")
  bird[0] = load_image("images/bird0.png")
  bird[1] = load_image("images/bird1.png")
  bird[2] = load_image("images/bird2.png")
  logo = load_image("images/logo.png")
  land = load_image("images/land.png")
  pipe_bottom = load_image("images/pipe-bottom.png")
  pipe_top = load_image("images/pipe-top.png")
  sky = load_image("images/sky.png")

update:
  sky.draw(vec2(0, 0))
  land.draw(vec2(0, 180))
  bird[0].draw(vec2(140, 60))
  logo.draw(vec2(65, 100))

unload:
  trace("Ok, bye.")
