return {
  {path="rec", component="button", send="core"},
  {path="load", component="button", send="core"},
  {path="clear", component="button", send="core"},
  {path="set-bpm", component="button", send="core"},
  {path="loop", component="toggle", send="core"},
  {path="reverse", component="toggle", send="core"},
  {path="length", min=0, max=4000, component="slider", send="core"}
}
