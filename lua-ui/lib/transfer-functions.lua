return {
    audio_taper = function(n)
        local base = 10
        return math.log(1 + n * (base - 1),base) / math.log(base,base)
    end,
    pow = function(max, e)
        return function(n)
            return (n ^ e) * max
        end
    end,
    mtof = function(n)
        return 2 ^ (((n * 135) - 69) / 12) * 440
    end
}