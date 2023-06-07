var fontMurder: Font
var fontBigGreen: Font
var imageFps:Image
var fps: float

var old_time: float
var current_time: float

load:
  trace("Hello from draw_text")
  fontMurder = load_font("Youmurdererbb-pwoK.otf", 20, RED)
  fontBigGreen = load_font(50, GREEN)
  
  # drawing these things once is much faster

  clear(RAYWHITE)
  
  # align text center/top and offset by 20
  draw_text("Scary Text:\nHuman long-chain hydrocarbons vehicle augmented reality denim modem fluidity realism franchise.", vec2(0, 20), vec2(320, 240), fontMurder, 0, CenterAlign, TopAlign)
  
  # use fontDefault, put it in the middle/center of screen
  draw_text("default text", vec2(0, 0), vec2(320, 240), fontDefault, 0, CenterAlign, MiddleAlign)
  
  # center/middle big green text, offset 50 on y (to drop down from center)
  draw_text("big green", vec2(0, 50), vec2(320, 240), fontBigGreen, 0, CenterAlign, MiddleAlign)

  # create an fps image that will update every frame
  imageFps = new_image(vec2(50, 20))
  

update:
  old_time = current_time
  current_time = get_time()
  fps = current_time - old_time
  # any access of $fps gives malformed Wasm binary
  # trace $fps

  imageFps.clear(RAYWHITE)
  imageFps.draw_text("0.0", vec2(0, 0), vec2(50, 20), fontDefault, 0, RightAlign, MiddleAlign, false)
  screen.draw_image(imageFps, vec2(265, 0))

unload:
  trace("Ok, bye.")
