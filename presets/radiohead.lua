local ps_is_on = false
local ps_config = 0
local ps_configs = {
    {0, 12},
    {-12, -12}
}
local trem_is_on = false
local synth_is_on = false

local function ps_toggle(state, config)
    state.pitchshift['ps-tones']:set(ps_configs[config])
    if ps_config ~= config or not ps_is_on then
        state.pitchshift['ps-sw']:set(1)
        state.wavetable_synth['synth-sw']:set(0)
        ps_is_on = true
        synth_is_on = false
    else
        state.pitchshift['ps-sw']:set(0)
        ps_is_on = false
    end
    ps_config = config
    return {
        params={
            {'pitchshift', 'ps-tones'},
            {'pitchshift', 'ps-sw'},
            {'synth', 'synth-sw'}
        },
        leds={
            [4]=ps_is_on,
            [6]=synth_is_on
        }
    }
end

local function synth_toggle(state)
    if not synth_is_on then
        state.wavetable_synth['synth-sw']:set(1)
        state.pitchshift['ps-sw']:set(0)
        synth_is_on = true
        ps_is_on = false
    else
        state.wavetable_synth['synth-sw']:set(0)
        synth_is_on = false
    end
    return {
        params={
            {'pitchshift', 'ps-sw'},
            {'synth', 'synth-sw'}
        },
        leds={
            [4]=ps_is_on,
            [6]=synth_is_on
        }
    }
end

local pedal_actions = {
    function(press, state)
        if press == 127 then
            return ps_toggle(state, 1)
        end
    end,
    function(press, state)
        if press == 127 then
            if not trem_is_on then
                state['amp-lfo'].bypass:set(0)
                trem_is_on = true
            else
                state['amp-lfo'].bypass:set(1)
                trem_is_on = false
            end
            return {
                params = {{'amp-lfo', 'bypass'}},
                leds = {[5]=trem_is_on}
            }
        end
    end,
    function(press, state)
        if press == 127 then
            synth_toggle(state)
        end
    end,
    function(press, state)
        if press == 127 then
            return ps_toggle(state, 2)
        end
    end,
}

local encoder_actions = {
    function(direction, state)
        if trem_is_on then
            state['amp-lfo'].rate:increment(direction)
            return {params={{'amp-lfo', 'rate'}}}
        end
    end,
    function(direction, state)
        if trem_is_on then
            state['amp-lfo'].depth:increment(direction)
            return {params={{'amp-lfo', 'depth'}}}
        end
    end,
    function(direction, state) end,
    function(direction, state) end,
}

return {
    defaults = {},
    pedal = function(ftsw, press, state)
        if pedal_actions[ftsw] ~= nil then
            return pedal_actions[ftsw](press, state)
        end
    end,
    encoders = function(enc, direction, state)
        if encoder_actions[enc] ~= nil then
            return encoder_actions[enc](direction, state)
        end
    end,
    seq_buttons = function(seq_btn, press, state)
    end,
    exp_pedal = function(_, position, state)
    end
}