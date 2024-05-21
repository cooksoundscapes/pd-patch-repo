local waveforms = {"tri", "sqr", "saw", "ramp", "sine"}

local params = {
    ["strength"] = {value=0,
    display=function(self)
        return self.value
    end
    },
    ["rate"] = {value=0,
    display=function(self)
        return string.format("%.1f", self.value) .. "Hz"
    end
    },
    ["waveform"] = {value=0,
    display=function(self)
        return waveforms[math.floor(self.value)+1]
    end
    }
}

local sorted = {"strength", "rate", "waveform"}

function Draw()
SetColor(Color.white)
for i,name in ipairs(sorted) do
    move_to(4, i*FontSize)
    text(name .. ": " .. params[name]:display())
end

end

function SetParam(name, value)
if params[name] ~= nil then
    params[name].value = value
end
end

function Cleanup()
params = nil
sorted = nil
waveforms = nil
end
