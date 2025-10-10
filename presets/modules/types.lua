return {
    _base_type = {
        map = function(self, value)
            local v = value / self.res
            if self.curve then
                v = v ^ self.curve
            end
            v = v * (self.max - self.min) + self.min
            return {v}
        end,
        inverse_map = function(self, value)
            local v = (value - self.min) / (self.max - self.min)
            if self.curve then
                v = v ^ (1 / self.curve)
            end
            return v * self.res
        end,
        set_default = function(self)
            self.current = self:inverse_map(self.default)
        end,
        get = function(self)
            return self:map(self.current)
        end,
        set = function(self, value)
            self.current = self:inverse_map(value)
        end,
        increment = function(self, inc)
            self.current = math.max(0, math.min(self.res, self.current + inc))
        end,
        pot = function(self, v)
            self.current = math.floor(v * self.res + 0.5)
        end,
    },

    _factory = function(self, p_type, overrides)
        overrides = overrides or {}

        -- set default methods on type table
        setmetatable(p_type, {__index=self._base_type})

        -- set type table as default for overrides
        setmetatable(overrides, {__index=p_type})

        -- expose base methods for extension
        overrides._base_type = self._base_type

        overrides:set_default()
        return overrides
    end,

    custom = function(self, t)
        -- directly set default methods for custom table
        setmetatable(t, {__index=self._base_type})

        -- expose base methods for extension
        t._base_type = self._base_type

        t:set_default()
        return t
    end,

    volume = function(self, t)
        return self:_factory({
            min=-100,max=0,
            default=0,
            res=100,
            curve=.5,
            suffix='dB'
        }, t)
    end,

    freq_sweep = function(self, t)
        return self:_factory({
            min=0,max=136,
            default=0,
            res=256,
        }, t)
    end,

    percent = function(self, t)
        return self:_factory({
            min=0,max=100,
            default=0,
            res=100,
            suffix='%'
        }, t)
    end,

    toggle = function(self, t)
        return self:_factory({
            min=0,max=1,
            default=0,
            res=1
        }, t)
    end,

    bpm = function(self, t)
        return self:_factory({
            min=60,max=200,
            default=110,
            res=256,
            suffix='BPM'
        }, t)
    end,

    bpm_div = function(self, t)
        return self:_factory({
            min=1,max=8,default=4,res=14
        }, t)
    end,

    low_freq = function(self, t)
        return self:_factory({
            min=0,max=20,
            default=0,
            res=256,
            suffix='Hz',
            curve=2,
        }, t)
    end,

    waveform = function(self, t)
        return self:_factory({
            min=0,
            max=4,
            default=0,
            res=4
        }, t)
    end,

    semitones = function(self, t)
        return self:_factory({
            min=-24,max=24,
            default=0,
            res=48,
        }, t)
    end,
}