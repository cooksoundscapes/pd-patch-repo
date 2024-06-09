local g = require("components.hexgrid")

create_surface("grid", screen_w, screen_h)
g(screen_w, screen_h, 40)

function Draw()
  draw_surface("grid", 0, 0)
end

function Cleanup()
  destroy_surface("grid")
end