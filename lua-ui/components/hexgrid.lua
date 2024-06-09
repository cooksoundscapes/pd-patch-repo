return function(w, h, side)
  local max_hex_x = math.floor(w / (side * 1.5))
  local max_hex_y = math.floor(h / (side * 1.5))
  local angle = math.pi / 3

  Color("#ffffff")
  move_to(0, 0)

  local angle_dir = -1

  for vert=0,max_hex_y*2-1 do
    local draw_dir = 1 - 2 * (vert%2)
    for _=0,max_hex_x*2-1 do
      angle_dir = (angle_dir+1) % 4
      local delta_x, delta_y
      if angle_dir == 0 or angle_dir == 2 then
        -- straight line
        delta_x = side
        delta_y = 0
      elseif angle_dir == 1 then
        --downwards
        delta_x = math.cos(angle) * side
        delta_y = math.sin(angle) * side
      else
        --upwards
        delta_x = math.cos(-angle) * side
        delta_y = math.sin(-angle) * side
      end
      rel_line_to(delta_x * draw_dir, delta_y * draw_dir)
    end

    -- angle calculation for going downwards
    local delta_x
    local delta_y
    if angle_dir == 0 or angle_dir == 2 then
      -- ended in straight line

    elseif angle_dir == 1 then
      -- ended downwards
      if draw_dir == 1 then
        -- on the right
        delta_x = math.cos(angle) * side * -1
        delta_y = math.sin(angle) * side
        rel_line_to(delta_x, delta_y)
      else
        -- on the left
        delta_x = math.cos(angle) * side
        delta_y = math.sin(angle) * side
        rel_line_to(delta_x, delta_y)
      end

    elseif angle_dir == 3 then
      -- ended upwards
      if draw_dir == 1 then
        -- to the right
        rel_line_to(side, 0)
        delta_x = math.cos(angle) * side
        delta_y = math.sin(angle) * side
        rel_line_to(delta_x, delta_y)
        delta_x = math.cos(angle) * side * -1
        delta_y = math.sin(angle) * side
        rel_line_to(delta_x, delta_y)
      else
        -- to the left
        delta_x = -side
        delta_y = 0
        rel_line_to(delta_x, delta_y)
      end
    end
    angle_dir = -1
  end
  stroke()
end