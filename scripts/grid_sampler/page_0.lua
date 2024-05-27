return function(self, state, side, note, velocity)
    -- find column and row values
    local col = note % self.n_col
    local row = math.floor(note / self.n_row)

    local channel = self.channels[row]
    -- update / clear row's press_state acording to the velocity
    if velocity > 0 then
        channel.pressed = col
    else
        channel.pressed = nil
    end

    -- if this input is not a note-on, return now
    if velocity < 1 then return end

    local curr_state = channel.state
    local new_state = 0

    -- if stop button is being held, check if it can work
    if self.aux_press_state[side.stop] == true and
        curr_state == state.playing
    then
        if channel.sync == true then
            new_state = state.stop_cue
        else
            new_state = state.stopped
        end
    else
        if channel.sync > 0 then
            new_state = self.mappings.hard_sync.note_in[curr_state]
        else
            new_state = self.mappings.free.note_in[curr_state]
        end
    end

    -- if rec_arm is being held and state is off, it will auto stop rec at X bars,
    -- depending on which col was pressed to record
    if self.aux_press_state[side.rec_arm] == true and
        curr_state == state.off
    then
        channel.auto_stop_bars = col + 1
        channel.recorded_bar_count = 0
    else
        channel.auto_stop_bars = 0
    end

    -- if new_state is valid, update and call the action for the new state
    if new_state ~= nil then
        channel.state = new_state
        if self.action_map[new_state] ~= nil then
            self.action_map[new_state](row, col)
        end
    end
end