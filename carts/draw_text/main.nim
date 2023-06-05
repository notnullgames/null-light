var font: Font
var fontMurder: Font

load:
  trace("Hello from draw_text")
  fontMurder = loadFont("Youmurdererbb-pwoK.otf", 20, RED)

update:
  clear(RAYWHITE)
  draw_text("default text", vec2(115, 80))
  draw_text("murder text", vec2(0, 0), vec2(320, 240), fontMurder, 0, CenterAlign, MiddleAlign)
  
  # calling fps() here throws error: [trap] unreachable executed
  # draw_text($fps(), vec2(0, 10), vec2(310, 230), 0, 0, RightAlign, TopAlign)

  

unload:
  trace("Ok, bye.")
