return {
    action = function(self, state, side, note, velocity)
        -- find column and row values
        local col = note % self.n_col
        local row = math.floor(note / self.n_row)

        --check if it's the pattern row
        if row == 6 and velocity > 0 then
            local pattern = self.patterns[col]
            if pattern == nil then return end

            local new_pat_state = self:find_next_state(pattern.state, pattern.sync)
            if new_pat_state ~= nil then
                pattern.state = new_pat_state
                local action = self.pattern_action_map[new_pat_state]
                if action ~= nil then
                    action(col)
                end
            end
            return
        end

        local channel = self.channels[row]
        if channel == nil then return end

        -- update / clear row's press_state acording to the velocity
        if velocity > 0 then
            channel.pressed = col
        else
            channel.pressed = nil
        end

        -- if this input is not a note-on, return now
        if velocity < 1 then return end

        local curr_state = channel.state
        local new_state = self:find_next_state(curr_state, channel.sync)

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
    end,
    init = function(_) end
}