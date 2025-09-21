local types = require("types")

return {
    chance=types:percent(),
    bpm=types:bpm(),
    length=types:percent(),
    degrade=types:toggle(),
    ["degrade.freq"]=types:low_freq(),
    ["degrade.amt"]=types:percent({max=95}),
}