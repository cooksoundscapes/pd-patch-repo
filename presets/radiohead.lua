local pedal_actions = {
    function(press, state)
        if press == 127 then
            local is_on = state.oneoffs['ps-synth-sw']:get() == 1 and
                          state.pitchshift.t1:get() == 0 and
                          state.pitchshift.t2:get() == 12
            if not is_on then
                state.oneoffs['ps-synth-sw']:set(1)
                state.pitchshift.t1:set(0)
                state.pitchshift.t2:set(12)
            else
                state.oneoffs['ps-synth-sw']:set(0)
            end
            return {
                params={
                    {'oneoffs', 'ps-synth-sw'},
                    {'pitchshift', 't1'},
                    {'pitchshift', 't2'}
                }
            }
        end
    end,
    function(press, state)
        if press == 127 then
            local is_on = state['amp-lfo'].bypass:get() == 0
            if not is_on then
                state['amp-lfo'].bypass:set(0)
            else
                state['amp-lfo'].bypass:set(1)
            end
            return {
                params={
                    {'amp-lfo', 'bypass'}
                }
            }
        end
    end,
    function(press, state)
    end,
    function(press, state)
    end,
}

return {
    defaults = {
        {'amp-lfo', 'depth', 90}
    },
    footsw = function(state, ftsw, press)
        if pedal_actions[ftsw] ~= nil then
            return pedal_actions[ftsw](press, state)
        end
    end,
    encoders = function(state, enc, direction)
    end,
    seq_buttons = function(state, seq_btn, press)
    end,
    ['exp-pedal'] = function(state, position)
    end
}
