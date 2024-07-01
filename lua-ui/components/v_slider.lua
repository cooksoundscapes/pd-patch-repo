return function(x, y, w, h, min, max, level, border_color, bg_color, bar_color)
  set_line_width(2)
  rectangle(x, y, w, h)
  Color(bg_color)
  fill_preserve()
  Color(border_color)
  stroke()

  local mod = level / (max - min)
  local bar_h = (h - 6) * mod
  local bar_y = (y + 3) + ((1 - mod) * (h - 6))
  rectangle(x + 3, bar_y, w - 6, bar_h)
  Color(bar_color)
  fill()
end