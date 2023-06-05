var font: Font
var fontMurder: Font
var fontBigGreen: Font

load:
  trace("Hello from draw_text")
  fontMurder = loadFont("Youmurdererbb-pwoK.otf", 20, RED)
  fontBigGreen = load_font(50, GREEN)

update:
  clear(RAYWHITE)
  # align text center/top and offset by 20
  draw_text("Scary Text:\nHuman long-chain hydrocarbons vehicle augmented reality denim modem fluidity realism franchise.", vec2(0, 20), vec2(320, 240), fontMurder, 0, CenterAlign, TopAlign)
  
  # use fontDefault, put it in the middle/denter of screen
  draw_text("default text", vec2(0, 0), vec2(320, 240), fontDefault, 0, CenterAlign, MiddleAlign)
  
  # center/middle big green text, offset 50 on y (to drop down from center)
  draw_text("big green", vec2(0, 50), vec2(320, 240), fontBigGreen, 0, CenterAlign, MiddleAlign)

  # calling fps() here throws error: [trap] unreachable executed
  # draw_text($fps(), vec2(0, 10), vec2(310, 230), 0, 0, RightAlign, TopAlign)

  

unload:
  trace("Ok, bye.")
