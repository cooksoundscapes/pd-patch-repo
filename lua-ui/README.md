## OSC endpoints:

* `/navigate`: args = `s`
* `/param`: 1st arg = `s`, 2nd arg = `s` or `f`
* `/buffer`: 1st arg = `s` followed by any n of `f`
* `/panel`: args = `sff`: device, pin, value

Install fonts at `~/.local/share/fonts` OR use `/fonts` subdir  

### Reference
`text(text, size, font, width, alignment, centered)`  
`arc(xc, yc, radius, angle1, angle2)`  
  
`/buffer` must be used together with `SetTable` function.  
`SetTable` receives 2 args: `name` and `data`, which is a numeric array of N fields;  
When the endpoint `/buffer` is called, hte engine will push the 1st arg as a string (`name`),  
transform the rest of the data into a lua table and push to stack.  
You can define the behavior of `SetTable` and treat it in anyway.


