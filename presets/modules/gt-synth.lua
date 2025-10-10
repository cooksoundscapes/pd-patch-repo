local types = require "presets.modules.types"

return {
    new = function()
        return {
            ['pitch-1']=types:semitones(),
            ['pitch-2']=types:semitones{},
            ['osc-2']=types:volume(),
            cutoff=types:freq_sweep{default=136},
            Q=types:custom{
                min=0.75,max=4,default=0.75,res=256
            },
            ['cutoff.key']=types:percent(),
            waveform=types:custom{
                min=0,max=2,default=0,res=2
            },
            ['filter.env.pow']=types:custom{
                min=1,max=4,default=2,res=256
            },
            ['filter.env.mult']=types:custom{
                min=1,max=80,default=5,res=256
            },
            ['filter.env.floor']=types:custom{
                min=-1,max=0,default=0,res=256
            },
            ['filter.lfo.depth']=types:custom{
                min=0,max=1,default=0,res=256
            },
            ['filter.lfo.rate']=types:low_freq(),
            ['filter.lfo.wave']=types:waveform(),
            ['pitch.lfo.cents']=types:custom{
                min=0,max=100,default=0,res=256
            },
            ['pitch.lfo.rate']=types:low_freq(),
            ['pitch.lfo.wave']=types:waveform(),
        }
    end
}