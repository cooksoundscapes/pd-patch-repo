local menu = require("components.menu")
local scrollbar = require("components.scrollbar")
local text_anim = require("components.text_anim")

local function find_param(line, param, search)
  if search == nil then search = ":%d+%)" end
  local value = string.match(line, param .. ":.+(" .. search .. ")")
  if value ~= nil then
    value = string.sub(value, 1, -2)
    value = string.sub(value, 2)
    return value
  end
end

--------------------------------------------------------

local page = {
  status = "inactive",
  cmd_runner = nil,
  device_menu = menu:new(),
  current_device = "",
  params = {
    selected = 1,
    order = { "rate", "period", "nperiods", "inchannels", "outchannels" },
    rate = {
      current = nil,
      values = { 44100, 48000, 88200, 96000, 176400, 192000 }
    },
    period = {
      current = nil,
      values = { 64, 128, 256, 512, 1024 }
    },
    nperiods = {
      current = nil,
      values = { 2, 3, 4, 5, 6, 7, 8 }
    },
    inchannels = {
      current = nil,
      values = { 1, 2, 3, 4, 5, 6, 7, 8 }
    },
    outchannels = {
      current = nil,
      values = { 1, 2, 3, 4, 5, 6, 7, 8 }
    },
  },

  loading = text_anim:new({"▙", "▛", "▜", "▟"}, 3),
  t1 = 0,
  t2 = 0,

  current_view = "params",

  init = function(self, cmd_runner)
    self.cmd_runner = cmd_runner
    self.current_view = "params"

    self.cmd_runner:call("jack_control status")
    self.cmd_runner:read("*l")
    self.status = "status: " .. self.cmd_runner:read("*l")
    self.cmd_runner:close()

    self.cmd_runner:call("cat /proc/asound/cards")
    self.device_menu.entries = {}
    for line in self.cmd_runner:lines() do
      local card = line:match("%[(.*)%]")
      if card ~= nil then
        table.insert(self.device_menu.entries, {
          name = card:gsub("%s", " ");
        })
      end
    end
    self.cmd_runner:close()

    self.cmd_runner:call("jack_control dp")
    for line in self.cmd_runner:lines() do
      for param,_ in pairs(self.params) do
        local curr_val = find_param(line, param)
        if curr_val ~= nil then
          self.params[param].current = curr_val
        else
        end
      end
      local device = line:match("hw:([^:]+)(%))")
      if device ~= nil then
        self.current_device = device
      end
    end
    self.cmd_runner:close()
  end,

  draw = function(self)
    if self.current_view == "params" then
      move_to(2, 0)
      text(self.status)
      move_to(2, FontSize)
      text("device: " .. self.current_device)
      move_to(2, FontSize*2)
      for i,param in ipairs(self.params.order) do
        if i == self.params.selected then
          text("["..param.."]" .. ": " .. self.params[param].current)
        else
          text(param .. ": " .. self.params[param].current)
        end
        move_to(2, FontSize * (i + 2))
      end

    elseif self.current_view == "devices" then
      self.device_menu:draw()
      scrollbar(#self.device_menu.entries, self.device_menu.selected, 0, 0, screen_w, screen_h)

    elseif self.current_view == "confirm" then
      text("Apply changes\nand restart audio?")
      move_to(2, screen_h-FontSize-2)
      text("no")
      move_to(screen_w - FontSize*2, screen_h-FontSize-2)
      text("yes")

    elseif self.current_view == "loading" then
      text("Restarting audio driver...\n" .. self.loading:get())
      if self.t1 < 30 then
        self.t1 = self.t1 + 1
      else
        if self.cmd_runner:is_running() == false then
          self.cmd_runner:call(
            "jack_control stop && jack_control dpr playback && jack_control dpr capture && " ..
            "jack_control dps device hw:" .. self.current_device .. "&&" ..
            "jack_control dps rate " .. self.params.rate.current .. "&&" ..
            "jack_control dps period " .. self.params.period.current .. "&&" ..
            "jack_control dps nperiods " .. self.params.nperiods.current .. "&&" ..
            "jack_control dps inchannels " .. self.params.inchannels.current .. "&&" ..
            "jack_control dps outchannels " .. self.params.outchannels.current .. "&&" ..
            "jack_control start"
          )
        else
          local read = self.cmd_runner:read("*l")
          if read ~= nil then
            print(read)
          end
          if read == nil then
            self.t2 = self.t2 + 1
            if self.t2 > 30 then
              self.t1 = 0
              self.t2 = 0
              self.cmd_runner:close()
              jack_start(app)
              self:init(self.cmd_runner)
            end
          end
        end
      end
    end

  end,

  action = function(self)
    if self.current_view == "params" then
      self.current_view = "devices"
    elseif self.current_view == "devices" then
      self.current_view = "confirm"
    elseif self.current_view == "confirm" then
      self.current_view = "loading"
      jack_stop(app)
    end
  end,

  encoder = function(self, pin, value)
    -- PARAMETER SCREEN
    if self.current_view == "params" then
      if pin == 1 then
        self.params.selected = math.max(1, math.min(#self.params.order, self.params.selected + value))
      elseif pin == 2 then
        local param = self.params.order[self.params.selected]
        local current = self.params[param].current
        local values = self.params[param].values
        if #values == 0 then return end
        local index = 1
        for i, v in ipairs(values) do
          if v == current then
            index = i
            break
          end
        end
        index = math.max(1, math.min(#values, index + value))
        self.params[param].current = values[index]
      end
    -- DEVICE MENU SCREEN
    elseif self.current_view == "devices" then
      if pin == 1 then
        self.device_menu:select(value)
        self.current_device = self.device_menu:get_selected().name
      end
    end
  end
}

return page
