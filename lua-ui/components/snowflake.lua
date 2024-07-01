return function(xc, yc, side_length, iterations, border_color)
  local function draw_koch_segment(x1, y1, x2, y2, depth)
    if depth == 0 then
      move_to(x1, y1)
      line_to(x2, y2)
    else
      local dx = (x2 - x1) / 3
      local dy = (y2 - y1) / 3

      local x3 = x1 + dx
      local y3 = y1 + dy

      local x4 = x2 - dx
      local y4 = y2 - dy

      local x5 = (x3 + x4) / 2 - (y4 - y3) * math.sqrt(3) / 2
      local y5 = (y3 + y4) / 2 + (x4 - x3) * math.sqrt(3) / 2

      draw_koch_segment(x1, y1, x3, y3, depth - 1)
      draw_koch_segment(x3, y3, x5, y5, depth - 1)
      draw_koch_segment(x5, y5, x4, y4, depth - 1)
      draw_koch_segment(x4, y4, x2, y2, depth - 1)
    end
  end

  local x1 = xc - side_length / 2
  local y1 = yc + side_length * math.sqrt(3) / 6

  local x2 = xc + side_length / 2
  local y2 = yc + side_length * math.sqrt(3) / 6

  local x3 = xc
  local y3 = yc - side_length * math.sqrt(3) / 3

  Color(border_color)
  draw_koch_segment(x1, y1, x2, y2, iterations)
  draw_koch_segment(x2, y2, x3, y3, iterations)
  draw_koch_segment(x3, y3, x1, y1, iterations)
  stroke()
end
