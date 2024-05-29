return {
  action = function(self, state, _, note, velocity)
    --[[ sampler functions:
    1 - sync on/off
    2 - reverse on/off
    3 - loop on/off
    4 - load file (pensar melhor)
    5 - set master bpm
    valores pre-setados de length? (usando 3 botoes)
    valores pre-setados de speed? (usando 3 botoes)
    play/stop ?
    ]]
    local col = note % self.n_col
    local player_param = self.player_param_map[col+1]

    if velocity > 0 then
      if player_param.type == "button" then
        self:outlet(2, "list", {note, 5}) -- yellow
      end

      local ch = math.floor(note / self.n_col)
      local channel = self.channels[ch]
      if channel == nil then return end
      if player_param == nil then return end

      if player_param.type == "toggle" then
        local numeric_value
        local values = player_param.values
        -- if the scripts needs other values than 0-1
        if values ~= nil then
          if channel[player_param.name] == values[1] then
            channel[player_param.name] = values[2]
            numeric_value = 1
          else
            channel[player_param.name] = values[1]
            numeric_value = 0
          end
        else
          numeric_value = channel[player_param.name] ~ 1
          channel[player_param.name] = numeric_value
        end
        self:outlet(2, "list", {note, numeric_value * 4 + 1}) -- turns 0-1 into 1-5
        self:outlet(1, "list", {ch, player_param.name, numeric_value})

      elseif player_param.type == "button" then
        self:outlet(1, "list", {ch, player_param.name})
      end

    elseif player_param.type == "button" then
      self:outlet(2, "list", {note, 1}) --green
    end
  end,

  init = function(self)
    -- for each channel, iterate over player param map and set lights acording to channel state
    for c,chan in pairs(self.channels) do
      for i,p in pairs(self.player_param_map) do
        local curr_state = chan[p.name]
        if p.type == "toggle" and p.values ~= nil then
          if curr_state == p.values[1] then
            curr_state = 0
          else
            curr_state = 1
          end
        end

        local b = c * self.n_row + i-1
        if curr_state ~= nil then
          local s = curr_state*4 + 1
          self:outlet(2, "list", {b, s})
        elseif p.type == "button" then
          self:outlet(2, "list", {b, 1}) -- green
        end
      end
    end
  end
}