local SeqLights = {
    state = {0, 0, 0, 0, 0, 0, 0, 0},
    set = function(self, pos, val)
        if pos < 1 or pos > 8 then
            print("[SeqLights] POSITION MUST BE 1~8!")
            return
        end
        local l = val > 0 and 1 or 0
        self.state[pos] = l
        local byte = 0
        for i=1,8 do
            byte = byte << 1
            byte = byte | self.state[i]
        end
        print(byte)
        set_lights(app, byte >> 6)
    end
}

return SeqLights