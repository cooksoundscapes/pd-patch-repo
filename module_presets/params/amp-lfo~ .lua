local types = require "types"
return {
    rate=types:low_freq(),
    wave=types:custom({
        min=0,max=4,default=0,res=4
    }),
    depth=types:volume()
}