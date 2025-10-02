local types = require "presets.modules.types"

return {
    new = function()
        return {
            t1=types:semitones(),
            t2=types:semitones()
        }
    end,
}