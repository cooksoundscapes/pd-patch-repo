local config = {
    {path="volume", default=1, min=0, max=1, pow=3},
    {path="pan", default=0.5, min=0, max=1},
    {path="verb", default=0.5, min=0, max=1, pow=3},
    {path="drive/gain", default=40, min=0, max=100},
    {path="chorus/level", default=0.5, min=0, max=1},
    {path="chorus/depth", default=6, min=2, max=12},
    {path="chorus/rate", default=0.2, min=0, max=1, pow=2, mult=18},
    {path="chorus/waveform", default=0, min=0, max=1},
    {path="crusher/quant", default=0, min=0, max=1, pow=4},
    {path="crusher/downsamp", default=1, min=0, max=1, pow=3},
    {path="crusher/interp", default=0, min=0, max=1, int=1},
    {path="delay/dry", default=1, min=0, max=1, pow=3},
    {path="delay/level", default=0.5, min=0, max=1, pow=3},
    {path="delay/feedback", default=0.3, min=0, max=1, pow=3},
    {path="delay/time", default=0.4, min=0, max=1, pow=2, mult=2000},
    {path="delay/modInt", default=0.2, min=0, max=1, pow=2, mult=12},
    {path="delay/modRate", default=0.2, min=0, max=10},
    {path="delay/lp", default=1, min=0, max=1, pow=3, mult=21000},
    {path="delay/hp", default=0, min=0, max=1, pow=3, mult=21000},
    {path="delay/pitch", default=0, min=-24, max=24, int=1},
    {path="delay/magic", default=0, min=0, max=1, pow=3},
    {path="delay/time", default=0.5, min=0, max=1, pow=2, mult=2000},
    {path="filter/cutoff", default=1, min=0.001, max=1, pow=3, mult=21000},
    {path="filter/q", default=0.75, min=0.5, max=4},
    {path="lfo/rate", default=1, min=0, max=25},
    {path="lfo/target", default=0, min=0, max=4, int=1},
    {path="lfo/wave", default=0, min=0, max=5, int=1},
    {path="lfo/sr-seq", default=16, min=1, max=64, int=1},
    {path="lfo/depth", default=0, min=0, max=1},
    {path="drive_sw", default=0},
    {path="crusher_sw", default=0},
    {path="filter_sw", default=0},
    {path="delay_sw", default=0},
    {path="verb_sw", default=0},
    {path="chorus_sw", default=0}
}

return config