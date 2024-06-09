function Draw()
  Color("#ffffff")
  local mx, my, mb = mouse()
  -- THAT'S CAUSING CORE DUMP! IDK WHY YET
  -- text(mx .. my)
  -- mas só dá segfault se eu concatenar, olha que bizarro.
  text(mx)
  move_to(0, 30)
  text(my)
end