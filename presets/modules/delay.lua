local types = require "presets.modules.types"

return {
    new = function()
        return {
            bypass=types:toggle{default=1},
            fdbk=types:volume{default=-100, max=3},
            level=types:volume{default=-100},
            lop=types:freq_sweep{default=136},
            hip=types:freq_sweep(),
            ['mod.rate']=types:low_freq(),
            ['mod.depth']=types:custom{
                min=0,max=8,default=0,res=256,curve=3
            },
            bpm=types:bpm(),
            ['bpm.div']=types:bpm_div(),
        }
    end
}