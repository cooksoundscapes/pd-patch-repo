return function(buffer, w, h, min_y, max_y, border_color, bg_color, line_color)
  min_y = min_y or -1
  max_y = max_y or 1

  local range = max_y - min_y
  local jump = (w-2) / #buffer

  rectangle(0, 0, w, h)
  Color(bg_color)
  fill_preserve()
  Color(border_color)
  stroke()

  Color(line_color)
  move_to(1, h * (1 - (buffer[1] - min_y) / range))
  set_line_width(1)
  for i,n in ipairs(buffer) do
    local y = (h-2) * (1 - (n - min_y) / range)
    line_to(i*jump, y)
  end
  line_to(w-1, h-1)
  line_to(1, h-1)
  fill()
end