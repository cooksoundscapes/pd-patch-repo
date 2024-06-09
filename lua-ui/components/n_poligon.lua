return function(n_side, length, xc, yc, border_color)
  if n_side < 1 then return end

  local side_length = length * 2 / n_side

  local central_angle = 2 * math.pi / n_side
  local radius = side_length / (2 * math.sin(math.pi / n_side))
  local vertices = {}

  for i=0,n_side - 1 do
    local x = xc + radius * math.cos(2 * math.pi * i / n_side + central_angle)
    local y = yc + radius * math.sin(2 * math.pi * i / n_side + central_angle)
    vertices[i+1] = {x, y}
  end
  local start_x, start_y = table.unpack(vertices[1])
  move_to(start_x, start_y)

  for i=2,n_side do
    line_to(table.unpack(vertices[i]))
  end
  close_path()
  Color(border_color)
  stroke()
end