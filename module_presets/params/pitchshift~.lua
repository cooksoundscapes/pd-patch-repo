
--[[
WIP!! faz os outros, faz o pd object e aí pensa aqui
]]

local types = require "types"
return {
    ['ps-sw']=types:toggle(),
    ['ps-tones']=types:custom({
        compound={
            types:semitones(),
            types:semitones()
        },
        send_val = function(self)
        end
    })
}