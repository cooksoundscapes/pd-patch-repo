return {
    _base_type = {
        map = function(self, value)
            local v = (value / self.res) * (self.max - self.min) + self.min
            return {v}
        end,
        inverse_map = function(self, value)
            return (value - self.min) / (self.max - self.min) * self.res
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
            self.current = math.max(self.min, math.min(self.max, self.current + inc))
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

    compound = function(_, types)
        return {
            values=types,
            set_default = function(self)
                for _,v in pairs(self.values) do
                    v:set_default()
                end
            end,
            get = function(self)
                local result = {}
                for _,v in pairs(self.values) do
                    table.insert(result, v:get()[1])
                end
                return result
            end,
            set = function(self, values)
                for i,v in pairs(values) do
                    self.values[i]:set(v)
                end
            end,
            increment = function(self, idx, inc)
                self.values[idx]:increment(inc)
            end,
        }
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
            res=256,
            suffix='Hz',
            map = function(_self, value)
                local norm = value / _self.res
                local v = _self.min + (_self.max - _self.min) * (norm^2)
                return {v}
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
            map = function(_self, value)
                local v = _self._base_type.map(_self, value)
                return {math.floor(v[1])}
            end,
        }, t)
    end,
}