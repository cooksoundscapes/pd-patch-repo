local types = require "types"

return {
    time=types:custom{{
        min=20, max=2000,
        default=360,
        res=256,
        suffix='ms',
        map = function(_self, current)
            local norm = current / _self.res
            return _self.min + (_self.max - _self.min) * (norm^3)
        end,
        inverse_map = function(self, value)
            local norm = (value - self.min) / (self.max - self.min)
            return self.res * (norm ^ (1/3))
        end
    }},
    fdbk=types:volume({default=-100, max=3}),
    level=types:volume({default=-100}),
    lop=types:freq_sweep({default=136}),
    hip=types:freq_sweep(),
    ['mod.rate']=types:low_freq(),
    ['mod.depth']=types:custom{{min=0,max=8,default=0,res=256}}
}