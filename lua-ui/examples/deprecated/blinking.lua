local leds = require("lib.led-array")

function Draw()
    SetColor(Color.white)
    text("hdasufhis")
end

SetOscTarget("192.168.1.22")

function SetParam(_,v)
    set_lights(app, v)
end
    
function Cleanup()
    SetOscTarget("localhost")
end