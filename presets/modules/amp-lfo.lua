local types = require "presets.modules.types"

return {
    new = function()
        return {
            wave=types:custom{
                min=0,max=4,default=0,res=4
            },
            depth=types:custom({
                min=60, max=100, default=60,res=40
            }),
            bypass=types:toggle{default=1},
            bpm=types:bpm(),
            ['bpm.div']=types:custom{
                min=1,max=8,default=4,res=16
            }
        }
    end
}