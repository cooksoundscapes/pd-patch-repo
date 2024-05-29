return function(self, state)
  return {
    [state.off] = function(chan)
      self.recording_pat = nil
      self:outlet(2, "list", {6*self.n_col + chan, state.off})
      self:outlet(1, "seq", {chan, "clear"})
    end,

    [state.stopped] = function(chan)
      self:outlet(2, "list", {6*self.n_col + chan, state.stopped})
      self:outlet(1, "seq", {chan, "stop"})
    end,

    [state.rec] = function(chan)
      if self.recording_pat == nil or self.recording_pat == chan then
        self.recording_pat = chan
        self:outlet(2, "list", {6*self.n_col + chan, state.rec})
        self:outlet(1, "seq", {"selected", chan})
        self:outlet(1, "seq", {chan, "rec"})
      end
    end,

    [state.playing] = function(chan)
      if self.recording_pat == chan then
        self.recording_pat = nil
      end
      self:outlet(2, "list", {6*self.n_col + chan, state.playing})
      self:outlet(1, "seq", {chan, "play"})
    end,

    [state.stop_cue] = function(chan)
      self:outlet(2, "list", {6*self.n_col + chan, state.stop_cue})
    end,

    [state.rec_cue] = function(chan)
      if self.recording_pat ~= nil then return end
      self.recording_pat = chan
      self:outlet(2, "list", {6*self.n_col + chan, state.rec_cue})
    end,

    [state.play_cue] = function(chan)
      self:outlet(2, "list", {6*self.n_col + chan, state.play_cue})
    end,

    [state.stop_rec_cue] = function(chan)
      self:outlet(2, "list", {6*self.n_col + chan, state.play_cue})
    end
  }
end