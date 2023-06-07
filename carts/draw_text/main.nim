var fontMurder: Font
var fontBigGreen: Font
var imageFps:Image

load:
  trace("Hello from draw_text")
  fontMurder = load_font("Youmurdererbb-pwoK.otf", 20, RED)
  fontBigGreen = load_font(50, GREEN)
  
  # drawing these things once is much faster
  clear(RAYWHITE)
  draw_text("Scary Text:\nHuman long-chain hydrocarbons vehicle augmented reality denim modem fluidity realism franchise.", vec2(0, 20), vec2(320, 240), fontMurder, 0, CenterAlign, TopAlign)
  draw_text("default text", vec2(0, 0), vec2(320, 240), fontDefault, 0, CenterAlign, MiddleAlign)
  draw_text("big green", vec2(0, 50), vec2(320, 240), fontBigGreen, 0, CenterAlign, MiddleAlign)
  imageFps = new_image(vec2(50, 20))
  

update:
  # any access of $(float) gives malformed Wasm binary
  imageFps.clear(RAYWHITE)
  imageFps.draw_text("0.0", vec2(0, 0), vec2(50, 20), fontDefault, 0, RightAlign, MiddleAlign, false)
  screen.draw_image(imageFps, vec2(265, 0))

unload:
  trace("Ok, bye.")
