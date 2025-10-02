local simple_toggle = require 'presets.common'.simple_toggle

local ftsw_actions = {
    simple_toggle{
        on_activate={
            {'oneoffs', 'ps-synth-sw', 1},
            {'pitchshift', 't1', 0},
            {'pitchshift', 't2', 12}
        },
        on_deactivate={
            {'oneoffs', 'ps-synth-sw', 0}
        },
    },
    simple_toggle{
        on_activate={
            {'amp-lfo', 'bypass', 0}
        },
        on_deactivate={
            {'amp-lfo', 'bypass', 1}
        }
    }
}

return {
    defaults = {
        {'amp-lfo', 'depth', 90},
        {'amp-lfo', 'bypass', 1},
        {'oneoffs', 'ps-synth-sw', 0},
    },
    footsw = function(state, ftsw, press)
        if ftsw_actions[ftsw] ~= nil then
            return ftsw_actions[ftsw](press, state)
        end
    end,
    encoders = function(state, enc, direction)
    end,
    seq_buttons = function(state, seq_btn, press)
    end,
    ['exp-pedal'] = function(state, position)

    end
}
