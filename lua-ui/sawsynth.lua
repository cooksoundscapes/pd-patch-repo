local vsl = require("components.controlled_v_slider")
local hsl = require("components.controlled_h_slider")
local nbx = require("components.controlled_numbox")
local knob = require("components.controlled_knob")
local fn = require("lib.transfer-functions")
local mouse = require("lib.mouse")
local fps = require("lib.fps")

local base_x = 20
local base_y = 36
local ksize = 50
local spacing = ksize + 8

local synth_params = {
    style = function(self)
        local s1 = spacing
        local s2 = 14
        for i,c in pairs(self.controls) do
            if i < 4 then
                c.x = base_x + (i-1) * s1
            else
                c.x = base_x + s1*3 + (i-4) * s2
            end
            c.y = base_y
        end
    end,
    controls = {
        knob:new(0, 0, ksize, fn.audio_taper, "synth osc2", "osc 2", 10),
        knob:new(0, 0, ksize, {0, 100}, "synth detune", "pitch", 10),
        knob:new(0, 0, ksize, {0, 1000}, "synth glide", "glide", 10),
        --[[vsl:new(0, 0, 10, 60, fn.pow(000, 2), "synth env a", "a"),
        vsl:new(0, 0, 10, 60, fn.pow(000, 2), "synth env d", "d"),
        vsl:new(0, 0, 10, 60, fn.audio_taper, "synth env s", "s"),
        vsl:new(0, 0, 10, 60, fn.pow(2000, 2), "synth env r", "r")]]
    }
}
synth_params:style()

local filter_params = {
    style = function(self)
        local s1 = spacing
        local s2 = 14
        for i,c in pairs(self.controls) do
            if i < 5 then
                c.x = base_x + (i-1) * s1
            else
                c.x = base_x + s1*4 + (i-5) * s2
            end
            c.y = base_y + spacing*1.5
        end
    end,
    controls = {
        knob:new(0, 0, ksize, fn.mtof, "filter cutoff", "Freq", 10),
        knob:new(0, 0, ksize, {0.5, 4}, "filter q", "Q", 10),
        knob:new(0, 0, ksize, {0, 1}, "filter key", "Keytrack", 10),
        knob:new(0, 0, ksize, {0, 1}, "filter env_lvl", "Envelope", 10),
        --[[vsl:new(0, 0, 10, 60, fn.pow(2000, 2), "filter env a", "a"),
        vsl:new(0, 0, 10, 60, fn.pow(2000, 2), "filter env d", "d"),
        vsl:new(0, 0, 10, 60, fn.audio_taper, "filter env s", "s"),
        vsl:new(0, 0, 10, 60, fn.pow(2000, 2), "filter env r", "r")]]
    }
}
filter_params:style()

local delay_params = {
    style = function(self)
        local sx = spacing
        local sy = spacing*1.2
        local y = base_y + spacing*3
        for i,c in pairs(self.controls) do
            c.x = ((i-1) % 5) * sx + base_x
            c.y = math.floor((i-1) / 5) * sy + y
        end
    end,
    controls = {
        knob:new(0, 0, ksize, fn.audio_taper, "delay level", "volume", 10),
        knob:new(0, 0, ksize, fn.audio_taper, "delay feedback", "feedback", 10),
        knob:new(0, 0, ksize, fn.pow(2000, 2), "delay time", "time", 10),
        knob:new(0, 0, ksize, fn.pow(8, 2), "delay modRate", "rate", 10),
        knob:new(0, 0, ksize, fn.pow(8, 2), "delay modInt", "depth", 10),
        knob:new(0, 0, ksize, fn.mtof, "delay lp", "LP", 10),
        knob:new(0, 0, ksize, fn.mtof, "delay hp", "HP", 10),
        nbx:new(0, 0, ksize, 20, -24, 24, "delay pitch", "tune", 10),
        knob:new(0, 0, ksize, fn.audio_taper, "delay magic", "magic", 10)
    }
}
delay_params:style()

local seq_params = {
    style = function(self)
        for i,c in pairs(self.controls) do
            c.x = base_x + (i-1) * spacing
            c.y = base_y + spacing*5.5
        end
    end,
    controls = {
        knob:new(0, 0, ksize, {50, 1000}, "seq rate", "rate", 10),
        nbx:new(0, 0, ksize, 20, 1, 128, "seq steps", "steps", 10),
        nbx:new(0, 0, ksize, 20, 0, 99999, "seq seed", "seed", 10),
        nbx:new(0, 0, ksize, 20, 1, 4, "seq amount", "harm.", 10),
        nbx:new(0, 0, ksize, 20, 0, 100, "seq missBy", "rests", 10),
        nbx:new(0, 0, ksize, 20, 0, 127, "seq min", "min", 10),
        nbx:new(0, 0, ksize, 20, 0, 127, "seq max", "max", 10),
    }
    --scale
}
seq_params:style()

for _,p in pairs({synth_params, filter_params, delay_params, seq_params}) do
    for _,ctl in pairs(p.controls) do
        mouse:add_area(ctl)
    end
end

function Draw()
    Color("#ffffff")
    text(string.format("fps %.2f", fps:get()), 10)
    mouse:check()
    for _,c in pairs(synth_params.controls) do
        c:draw()
    end
    for _,c in pairs(filter_params.controls) do
        c:draw()
    end
    for _,c in pairs(delay_params.controls) do
        c:draw()
    end
    for _,c in pairs(seq_params.controls) do
        c:draw()
    end
end