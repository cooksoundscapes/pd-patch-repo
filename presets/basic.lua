return {
    banks = {
        [1] = {
            normal = {
                {'oneoffs', 'master'},
                {'oneoffs', 'od-gain'},
                {'mod-01', 'mix'},
                {'pitchshift', 't1'}
            },
            shift = {
                nil,
                nil,
                {'mod-lfo', 'rate'},
                {'pitchshift', 't2'}
            }
        },

        [2] = {
            normal = {
                {'amp-lfo', 'bpm'},
                {'amp-lfo', 'depth'},
                {'amp-lfo', 'wave'},
                {'oneoffs', 'degrade'}
            },
            shift = {
                {'amp-lfo', 'bpm-div'},
                nil,
                nil,
                {'oneoffs', 'bitcrush'}
            }
        },

        [3] = {
            normal = {
                {'delay', 'level'},
                {'delay', 'fdbk'},
                {'delay', 'bpm'},
                {'delay', 'lop'}
            },
            shift = {
                nil,
                {'delay', 'mod.depth'},
                {'delay', 'bpm-div'},
                {'delay', 'hip'}
            }
        },

        [4] = {
            normal = {
                {'glitch', 'chance'},
                {'glitch', 'length'},
                {'glitch', 'bpm'},
                {'glitch', 'dry'}
            },
            shift = {
                nil,
                nil,
                {'glitch', 'bpm-div'},
                nil
            }
        },

        [5] = {
            normal = {
                {'gt-synth', 'cutoff'},
                {'gt-synth', 'waveform'},
                {'gt-synth', 'pitch-1'},
                {'gt-synth', 'pitch.lfo.cents'}
            },
            shift = {
                {'gt-synth', 'Q'},
                {'gt-synth', 'osc-2'},
                {'gt-synth', 'pitch-2'},
                {'gt-synth', 'pitch.lfo.rate'}
            }
        },

        [6] = {
            normal = {
                {'gt-synth', 'cutoff-key'},
                {'gt-synth', 'filter.lfo.depth'},
                {'gt-synth', 'filter.lfo.rate'},
                {'gt-synth', 'filter.lfo.wave'}
            },
            shift = {
                nil,
                nil,
                nil,
                {'gt-synth', 'pitch.lfo.wave'}
            }
        }
    }
}
