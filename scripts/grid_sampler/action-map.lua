return function(self, state)
  return {
    [state.off] = function(chan)
        self:set_row(chan, 0)
        self:outlet(1, "list", {chan, "clear"})
    end,
    [state.stopped] = function(chan)
        self:set_row(chan, 0)
        self:outlet(2, "list", {chan * self.n_row, 1})
        self:outlet(1, "list", {chan, "float", 0})
    end,
    [state.rec] = function(chan)
        local channel = self.channels[chan]
        if channel.auto_stop_bars > 0 then
            self:set_row(chan, 0)
            self:set_row(chan, state.rec, channel.auto_stop_bars)
        else
            self:set_row(chan, state.rec)
        end
        channel.is_recording = true
        self:outlet(1, "list", {chan, "rec", 1})
        self:outlet(1, "list", {chan, "float", 0})
    end,
    [state.playing] = function(chan, col)
        self:set_row(chan, 0)
        local channel = self.channels[chan]

        -- stop rec in case it's on
        if channel.is_recording == true then
            channel.is_recording = false
            self:outlet(1, "list", {chan, "rec", 0})
        end
        local curr_slice = col / self.n_col

        -- if channel is playing backwards, slice actually starts in the end of the slice
        if channel.reverse > 0 then
            curr_slice = curr_slice + 1/self.n_col
        end
        self:outlet(2, "list", {chan * self.n_row + col, state.playing})
        self:outlet(1, "list", {chan, 1, curr_slice})
    end,
    [state.stop_cue] = function(chan)
        self:set_row(chan, state.stop_cue)
    end,
    [state.rec_cue] = function(chan)
        local channel = self.channels[chan]
        if channel.auto_stop_bars > 0 then
            self:set_row(chan, state.rec_cue, channel.auto_stop_bars)
        else
            self:set_row(chan, state.rec_cue)
        end
    end,
    [state.play_cue] = function(chan)
        self:set_row(chan, state.play_cue)
    end,
    [state.stop_rec_cue] = function(chan)
        self:set_row(chan, state.play_cue)
    end
  }
end
