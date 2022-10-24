local fx_control = pd.Class:new():register('fx_control')
local JSON = require("JSON")

-- TODO: method for setting preset names on slot

local preset_dir = '/home/me/pd/core-lib/presets'
local line_size = 8
local grid_size = 56
local max_fx = grid_size / line_size - 1

local function load_preset(self, fx, preset)
  local filename = string.format("%s_%s.json", fx, preset)
  local file = io.open(string.format("%s/%s", preset_dir, filename), "r")
  if file == nil then return end
  local json = file:read("*a")
  local content = assert(JSON:decode(json), string.format("%s: error reading JSON", filename))
  file:close()
  for param, value in pairs(content) do
    if type(value) == "table" then
      self:outlet(2, param, value)
    else
      self:outlet(2, param, { value })
    end
  end
end

-- every time that a parameter changes,
-- the FX will be added to self.changed and the
-- auto-save timeout will be called.
-- the timeout callback should iterate through
-- the self.changed table and save those files.

function fx_control:initialize(sel, atoms)
  if #atoms < 1 or #atoms > max_fx then
    self:error("[fx_control]: Wrong number of arguments;")
    return false
  end
  self.inlets = 2
  self.outlets = 2
  self.channel = 1
  self.channel_state = {}
  for i=1, line_size do
    self.channel_state[i] = {}
  end
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
  self.changed = {}
  self.should_load = ""
  self.auto_save_timeout = pd.Clock:new():register(self, "autosave")
  self.async_load = pd.Clock:new():register(self, "load")
  return true
end

-- param change
function fx_control:in_2(sel, atoms)
  if self.effects[sel] == nil then
    self:error("FX not in memory")
    return
  elseif #atoms < 2 then
    self:error("invalid parameter/value")
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
  self.auto_save_timeout:unset()
  self.auto_save_timeout:delay(600)
end

--channel / preset selection
function fx_control:in_1_list(atoms)
  if #atoms ~= 2 or -- not a midi note
    atoms[2] < 1 or -- not a note on
    atoms[1] < 0 or -- outside range
    atoms[1] > (grid_size - 1) or -- outside range
    type(atoms[2]) ~= "number" then return end -- not a midi node

  -- change audio channel
  if atoms[1] >= (grid_size - line_size) then
    local offset = grid_size - line_size - 1
    self:outlet(1, "list", {self.channel + offset, 0})
    self.channel = atoms[1] - offset
    self:outlet(1, "list", {self.channel + offset, 5})
    -- refresh grid
    for i=0, grid_size-line_size-1 do
      self:outlet(1, "list", {i, 0})
    end
    for ch, state in pairs(self.channel_state) do
      if self.channel == ch then
        for button in pairs(state) do
          local line = math.floor(button / line_size + 1)
          local slot = button % line_size
          for _,attr in pairs(self.effects) do
            if attr.line == line then
              attr.selected = slot
            end
          end
          self:outlet(1, "list", {button, 1})
        end
      end
    end
    return
  end
  -- change preset
  local line = math.floor(atoms[1] / line_size + 1)
  local slot = atoms[1] % line_size
  for fx_name, attributes in pairs(self.effects) do
    if line == attributes.line then
      if slot == attributes.selected then
        attributes.selected = nil
        self.channel_state[self.channel][atoms[1]] = nil
        self:outlet(2, "list", {self.channel, fx_name, "bypass"})
        self:outlet(1, "list", {atoms[1], 0})
        return
      end

      if not attributes.presets[slot] then
        -- if slot names not set, set the number
        attributes.presets[slot] = math.floor(slot)
      end
      if attributes.selected then
        -- turn off previous light
        local prev_button = (attributes.line - 1) * line_size + attributes.selected
        self.channel_state[self.channel][prev_button] = nil
        self:outlet(1, "list", {prev_button, 0})
      end
      attributes.selected = slot
      local button = (attributes.line - 1) * line_size + attributes.selected
      self.channel_state[self.channel][button] = true
      self:outlet(1, "list", {button, 1})
      self.should_load = fx_name
      self.async_load:unset()
      self.async_load:delay(100)
    end
  end
end

--manual load preset
function fx_control:in_2_load(atoms)
  if #atoms < 2 then return
  elseif self.effects[atoms[1]] == nil then
    self:error("FX not in memory")
    return
  end
  local preset_name = atoms[2]
  if type(atoms[2]) == "number" then
    preset_name = math.floor(atoms[2])
  end
  load_preset(self, atoms[1], preset_name)
end

--timer callback load
function fx_control:load()
  for fx_name, attributes in pairs(self.effects) do
    if self.should_load == fx_name then
      local preset_name = attributes.presets[attributes.selected]
      load_preset(self, fx_name, preset_name)
      self.should_load = ""
    end
  end
end

function fx_control:autosave()
  for fx in pairs(self.changed) do
    local effect = self.effects[fx]
    if not effect.selected then return end
    local path = string.format(
      "%s/%s_%s.json",
      preset_dir,
      fx,
      effect.selected
    )
    local json = JSON:encode(effect.params)
    local file = io.open(path, "w+")
    file:write(json)
    file:close()
    self.changed[fx] = nil
  end
end
