return {
    _base_type = {
        map = function(self)
            return (self.current / self.res) * (self.max - self.min) + self.min
        end,
        inverse_map = function(self, value)
            return (value - self.min) / (self.max - self.min) * self.res
        end
    },

    _factory = function(self, p_type, overrides)
        setmetatable(p_type, {__index=self._base_type})
        setmetatable(overrides or {}, {__index=p_type})

        overrides.current = overrides:inverse_map(overrides.default)
        return overrides
    end,

    custom = function(self, t)
        setmetatable(t, {__index=self._base_type})
        t.current = t:inverse_map(t.default)
        return t
    end,

    volume = function(self, t)
        return self:_factory({
            min=-100,max=0,
            default=0,
            res=100,
            suffix='dB'
        }, t)
    end,

    freq_sweep = function(self, t)
        return self:_factory({
            min=0,max=136,
            default=0,
            res=256,
            suffix='Hz',
            --vis_value=function(v) return 440 * 2 * ((v - 69) / 12) end,
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

    low_freq = function(self, t)
        return self:_factory({
            min=0,max=20,
            default=0,
            rest=256,
            suffix='Hz',
            map = function(_self)
                local norm = _self.current / _self.res
                return _self.min + (_self.max - _self.min) * (norm^2)
            end,
            inverse_map = function(_self, value)
                local norm = (value - _self.min) / (_self.max - _self.min)
                return math.sqrt(norm) * _self.res
            end
        }, t)
    end,

    semitones = function(self, t)
        return self:_factory({
            min=-24,max=24,
            default=0,
            res=96,
            map = function(_self)
                local v = self._base_type.map(_self)
                return math.floor(v)
            end,
        }, t)
    end,
}