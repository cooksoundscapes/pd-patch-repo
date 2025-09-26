local types = require "presets.modules.types"

return {
    new = function()
        return {
            ['ps-sw']=types:toggle(),
            ['ps-tones']=types:compound{
                types:semitones(),
                types:semitones()
            }
        }
    end,
}