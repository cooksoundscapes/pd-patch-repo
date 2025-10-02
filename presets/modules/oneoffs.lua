local types = require "presets.modules.types"


return {
    omit_module=true,
    ['ps-synth-sw']=types:custom{
        min=0,max=2,default=0,res=2
    },
    ['od-gain']=types:custom{
        min=0,max=60,default=0,res=60,suffix='dB'
    },
    degrade=types:custom{
        min=0,max=1,default=0,res=256
    },
    bitcrush=types:custom{
        min=0,max=1,default=0,res=256,rve=4
    },
    lofi=types:toggle(),
    ["mod-01-mix"]=types:custom{
        min=-1,max=1,default=-1,res=256
    },
    master=types:volume(),
}