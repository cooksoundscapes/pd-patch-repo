X = 10
Y = 10

function Draw()
  X = (X + 0.1) % 1000

  set_source_rgb(1, 1, 1)
  move_to((math.sin(X)*3) + 10, (math.cos(X)*3)+15)
  text("BUGIBUGI", 16)
end
