local types = require "types"
return {
    rate=types:low_freq(),
    wave=types:custom{{
        min=0,max=4,default=0,res=4
    }},
    depth=types:custom({
        min=3,max=12,default=3,res=256,
        map = function(self)
            local v = self._base_type.map(self)
            return {self.min, v} -- returns range for [lfo~]
        end,
    })
}