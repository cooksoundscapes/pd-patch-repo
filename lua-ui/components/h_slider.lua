return function(x, y, w, h, min, max, level, border_color, bg_color, bar_color)
  set_line_width(2)
  rectangle(x, y, w, h)
  Color(bg_color)
  fill_preserve()
  Color(border_color)
  stroke()

  local bar_w = (w - 6) * (level / (max - min))
  rectangle(x + 3, y + 3, bar_w, h - 6)
  Color(bar_color)
  fill()
end