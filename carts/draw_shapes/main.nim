load:
  trace("Hello from draw_shapes")
  # usually you would draw in update(), but you can do it once, here, too
  clear(SKYBLUE)
  set_color(YELLOW, BLACK)
  circle(vec2(160, 120), 100, 5)
  set_color(BLACK)
  circle(vec2(120, 80), 20)
  circle(vec2(200, 80), 20)
  set_color(PINK, RED)
  rectangle(vec2(130, 150), vec2(60, 10), 2)

unload:
  trace("Ok, bye.")