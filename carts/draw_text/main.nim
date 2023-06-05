var font: Font
var fontMurder: Font

load:
  trace("Hello from draw_text")
  fontMurder = loadFont("Youmurdererbb-pwoK.otf", 20, RED)

update:
  clear(RAYWHITE)
  draw_text("default text", vec2(115, 80))
  draw_text("murder text", vec2(0, 0), vec2(320, 240), fontMurder, 0, CenterAlign, MiddleAlign)
  

unload:
  trace("Ok, bye.")
