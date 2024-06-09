return function(x, y, w, h, radius)
  local deegrees = math.pi / 180
  new_path()
  arc(x + w - radius, y + radius, radius, -90 * deegrees, 0 * deegrees)
  arc(x + w - radius, y + h - radius, radius, 0 * deegrees, 90 * deegrees)
  arc(x + radius, y + h - radius, radius, 90 * deegrees, 180 * deegrees)
  arc(x + radius, y + radius, radius, 180 * deegrees, 270 * deegrees)
end