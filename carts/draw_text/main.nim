var font: Font
var fontMurder: Font

load:
  trace("Hello from draw_text")
  fontMurder = loadFont("Youmurdererbb-pwoK.otf")

update:
  clear(BLACK)
  
  set_color(WHITE)
  draw_text("default text", vec2(0, 0))

  set_color(RED)
  fontMurder.draw_text("murder text", vec2(0, 20))
  

unload:
  trace("Ok, bye.")
