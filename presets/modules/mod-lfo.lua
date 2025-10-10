local types = require "presets.modules.types"

return {
    new = function()
        return {
            rate=types:low_freq(),
            wave=types:waveform(),
            range=types:custom{
                min=3,max=12,default=3,res=256,
                map = function(self, value)
                    local v = self._base_type.map(self, value)
                    return {self.min, v[1]} -- returns range for [lfo~]
                end,
            }
        }
    end,
}