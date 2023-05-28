load:
  trace("Hello from draw_shapes")
  # usually you would draw in update(), but you can do it here, too
  clear(SKYBLUE)

  # face
  set_color(YELLOW, BLACK)
  circle(vec2(160, 120), 100, 5)
  
  # eyes & mouth
  set_color(BLACK)
  circle(vec2(120, 80), 20)
  circle(vec2(200, 80), 20)
  rectangle_round(vec2(130, 150), vec2(60, 10), 10)

  # nose
  set_color(RED)
  ellipse(vec2(160, 120), vec2(40, 20), 10)

unload:
  trace("Ok, bye.")