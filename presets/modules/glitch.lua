local types = require "presets.modules.types"

return {
    new = function()
        return {
            chance=types:percent(),
            dry=types:percent(),
            bpm=types:bpm(),
            ['bpm.div']=types:bpm_div(),
            length=types:percent(),
            degrade=types:toggle(),
            ["degrade.freq"]=types:low_freq(),
            ["degrade.amt"]=types:percent{max=95},
        }
    end,
}