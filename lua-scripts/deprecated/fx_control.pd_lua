local JSON = require("JSON")
local utils = dofile('./grid-utils.lua')
local error = dofile('./error.lua')

local preset_dir = '/home/me/pd/core-lib/presets'
local temporary_preset_bank = '/tmp/fx-ctrl-prst-bank'
local line_size = 8
local grid_size = 56
local max_fx = grid_size / line_size - 1

local function load_preset(fx, preset)
  local filename = string.format("%s_%s.json", fx, preset)
  local file = io.open(string.format("%s/%s", preset_dir, filename), "r")
  if file == nil then return end

  local json = file:read("*a")
  local params = assert(JSON:decode(json), string.format("%s: error reading JSON", filename))
  file:close()

  return params
end

local function save_preset(self, fx, new_name)
  local effect = self.effects[fx]
  if not effect.selected then return end

  local preset_name = new_name or effect.presets[effect.selected]
  local path = string.format(
    "%s/%s_%s.json",
    preset_dir,
    fx,
    preset_name
  )
  local json = JSON:encode(effect.params)
  local file = io.open(path, "w+")
  file:write(json)
  file:close()
  self.changed[fx] = nil
end

local function output_selected_preset(self, fx)
  for param, value in pairs(self.effects[fx].params) do
    local output = {self.channel, param}
    if type(value) == "table" then
      for _,v in ipairs(value) do
        table.insert(output, v)
      end
    else
      table.insert(output, value)
    end
    self:outlet(2, "list", output)
  end
end

local function change_preset_bank(prev_channel, next_channel, effects)
  local prev_ch = string.format('%d', prev_channel)
  local next_ch = string.format('%d', next_channel)

  local prev_data = nil
  local file = io.open(temporary_preset_bank, "r+")
  if file ~= nil then
    local content = file:read("*a")
    prev_data = JSON:decode(content)
  else
    file = io.open(temporary_preset_bank, "w+")
  end

  local new_data = {}
  for fx, attr in ipairs(effects) do
    if #attr.presets > 0 then
      new_data[fx] = attr.presets
    end
  end

  if #new_data > 0 then
    if prev_data == nil then
      prev_data = {}
    end
    prev_data[prev_ch] = new_data
    local changed = JSON:encode(prev_data)
    file:write(changed)
  end
  file:close()

  if prev_data[next_ch] ~= nil then
    for incoming_fx, preset_names in pairs(prev_data[next_ch]) do
      for fx, attr in pairs(effects) do
        if fx == incoming_fx then
          attr.presets = preset_names
        end
      end
    end
  end
end

local function fx_not_in_memory(self, fx)
  if self.effects[fx] == nil then
    self:error("FX not in memory")
    return true
  end
  return false
end

-- every time that a parameter changes,
-- the FX will be added to self.changed and the
-- auto-save timeout will be called.
-- the timeout callback should iterate through
-- the self.changed table and save those files.

local fx_control = pd.Class:new():register('fx_control')

function fx_control:initialize(sel, atoms)
  if #atoms < 1 or #atoms > max_fx then
    self:error("[fx_control]: Wrong number of arguments;")
    return false
  end
  self.inlets = 2
  self.outlets = 2
  self.channel = 1
  -- channel_state keeps light state data for each channel
  -- { channel1 = { 1=48, 2=36, 3=15 } }
  self.channel_state = {}
  for i=1, line_size do
    self.channel_state[i] = {}
  end
  -- effects keeps param data for each effect
  -- { fx1 = { line=1, selected=0, params={ param1=0, param2=0 }, presets={ name1, name2 } } }
  self.effects = {}
  local index = max_fx
  for _, fx_name in ipairs(atoms) do
    self.effects[fx_name] = {
      line = index,
      selected = nil,
      params = {},
      presets = {}
    }
    index = index - 1
  end
  self.auto_save = true
  self.changed = {}
  self.should_load = ""
  self.auto_save_timeout = pd.Clock:new():register(self, "autosave")
  self.async_load = pd.Clock:new():register(self, "load")
  return true
end

-- param change
function fx_control:in_2(sel, atoms)
  if fx_not_in_memory(self, sel) or
    error.wrong_count(self, atoms, 2) then
    return
  end

  local param = table.remove(atoms, 1)
  if #atoms > 1 then
    self.effects[sel].params[param] = atoms
  else
    self.effects[sel].params[param] = atoms[1]
  end
  self.changed[sel] = true
  -- debounced auto-save
  if self.auto_save == true then
    self.auto_save_timeout:unset()
    self.auto_save_timeout:delay(600)
  end
end

--channel / preset selection
function fx_control:in_1_list(atoms)
  if error.not_midi_note(self, atoms) or
    error.outside_range(self, atoms[1], 0, grid_size-1) or
    atoms[2] < 1 then --not note on
    return
  end

  -- change audio channel
  if atoms[1] >= (grid_size - line_size) then
    local offset = grid_size - line_size - 1
    local next_ch = atoms[1] - offset
    if self.channel == next_ch then return end

    -- save the preset names for each effect of previous channel
    -- retrieve preset names for each effect of next channel
    change_preset_bank(self.channel, next_ch, self.effects)

    -- update state
    self:outlet(1, "list", {self.channel + offset, 0})
    self.channel = next_ch
    self:outlet(1, "list", {self.channel + offset, 5})

    -- refresh grid
    utils.clear_grid(self, grid_size-line_size)

    -- for each button saved, load corresponding preset
    for ch, light_state in pairs(self.channel_state) do
      if self.channel == ch then
        for button in pairs(light_state) do
          local coord = utils.button_to_coord(button, line_size)
          for fx_name, attr in pairs(self.effects) do
            if attr.line == coord.line+1 then
              attr.selected = coord.col
              local preset_name = attr.presets[attr.selected]
              local params = load_preset(fx_name, preset_name)
              if params ~= nil then
                self.effects[fx_name].params = params
              end
            end
          end
          self:outlet(1, "list", {button, 1})
        end
      end
    end
    local json = JSON:encode(self.effects)
    local json2 = JSON:encode(self.channel_state)
    pd.post(json)
    pd.post(json2)
    return
  end
  -- change preset
  local coord = utils.button_to_coord(atoms[1], line_size)
  for fx_name, attr in pairs(self.effects) do
    if coord.line+1 == attr.line then
      if coord.col == attr.selected then
        attr.selected = nil
        self.channel_state[self.channel][atoms[1]] = nil
        self:outlet(2, "list", {self.channel, fx_name, "bypass"})
        self:outlet(1, "list", {atoms[1], 0})
        return
      end

      if not attr.presets[coord.col] then
        -- if slot name not set, set the number
        attr.presets[coord.col] = math.floor(coord.col)
      end

      if attr.selected then
        -- turn off previous light
        local prev_button = utils.coord_to_button(attr.line - 1, attr.selected, line_size)
        self.channel_state[self.channel][prev_button] = nil
        self:outlet(1, "list", {prev_button, 0})
      end

      attr.selected = coord.col
      self.channel_state[self.channel][atoms[1]] = true
      self:outlet(1, "list", {atoms[1], 1})
      self.should_load = fx_name
      self.async_load:unset()
      self.async_load:delay(100)
    end
  end
end

--load preset (fx, slot_number, name)
function fx_control:in_2_load(atoms)
  if error.wrong_count(self, atoms, 3) or
  fx_not_in_memory(self, atoms[1]) then return end
  local fx = atoms[1]
  local slot = atoms[2]
  local name = atoms[3]
  self.effects[fx].presets[slot] = name
  if self.effects[fx].selected == slot then
    local params = load_preset(fx, name)
    if params ~= nil then
      self.effects[fx].params = params
      output_selected_preset(self, fx)
    end
  end
end

-- manual save preset
function fx_control:in_2_save(atoms)
  if #atoms < 1 then
    self:error('no arguments for save message')
    return
  elseif fx_not_in_memory(self, atoms[1]) then return
  elseif self.effects[atoms[1]].selected == nil then
    self:error('no preset selected for save')
    return
  end

  save_preset(self, atoms[1], atoms[2])
  if atoms[2] ~= nil then
    local selected = self.effects[atoms[1]].selected
    self.effects[atoms[1]].presets[selected] = atoms[2]
  end
end

--toggle auto-save
function fx_control:in_2_autosave(atoms)
  if error.wrong_count(self, atoms, 1) then return end
  if atoms[1] >= 1 then
    self.auto_save = true
  else
    self.auto_save = false
  end
end

--timer load callback
function fx_control:load()
  for fx_name, attributes in pairs(self.effects) do
    if self.should_load == fx_name then
      local preset_name = attributes.presets[attributes.selected]
      local params = load_preset(fx_name, preset_name)
      if params == nil then return end

      self.effects[fx_name].params = params
      output_selected_preset(self, fx_name)
      self.should_load = ""
    end
  end
end

--timer save callback
function fx_control:autosave()
  for fx in pairs(self.changed) do
    save_preset(self, fx)
  end
end
