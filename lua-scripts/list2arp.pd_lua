local list2arp = pd.Class:new():register("list2arp")

function list2arp:initialize(sel, atoms)
  self.inlets = 2
  self.outlets = 1
  self.current = {}
  self.rate = 125 --ms
  self.mode = "up"
  self._direction = "up"
  self.playpos = 1
  self.isplaying = false
  self.type = "float"
  self.clock = pd.Clock:new():register(self, "playnote")
  return true
end

function list2arp:finalize()
  self.clock:destruct()
end

function list2arp:in_1_list(notes)
  for i = 1, #self.current do
    self.current[i] = nil
  end
  
  for i = 1, #notes do
    self.current[i] = notes[i]
  end
  if self.isplaying and #self.current > 0 then
    self.clock:delay(0)
  end
end

function list2arp:in_2_play(state)
  if state[1] == 1 then
    self.clock:delay(0)
    self.isplaying = true
  else
    self.clock:unset()
    self.playpos = 1
    self.isplaying = false
  end
end

function list2arp:in_2_rate(rate)
  if type(rate[1]) == "number" then
    self.rate = rate[1]
  end
end

function list2arp:in_2_mode(mode)
  pd.post(mode[1])
  if type(mode[1]) == "string" then
    self.mode = mode[1]
  end
end

function list2arp:playnote()
  if #self.current > 0 then
    self:outlet(1, "float", {self.current[self.playpos]})
    if self.mode == "up" then
      self.playpos = self.playpos + 1
      if self.playpos > #self.current then
        self.playpos = 1
      end
    elseif self.mode == "down" then
      self.playpos = self.playpos - 1
      if self.playpos < 1 then
        self.playpos = #self.current
      end
    elseif self.mode == "updown" then
      if self._direction == "up" then
        self.playpos = self.playpos + 1
        if self.playpos > #self.current then
          self.playpos = #self.current - 1
          self._direction = "down"
        end
      else
        self.playpos = self.playpos - 1
        if self.playpos < 1 then
          self.playpos = 2
          self._direction = "up"
        end
      end
      
    end
    self.clock:delay(self.rate)
  end
end
