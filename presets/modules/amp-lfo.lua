local types = require "presets.modules.types"

return {
    new = function()
        return {
            wave=types:waveform(),
            depth=types:volume{default=-100},
            bypass=types:toggle{default=1},
            bpm=types:bpm(),
            ['bpm.div']=types:bpm_div(),
        }
    end
}