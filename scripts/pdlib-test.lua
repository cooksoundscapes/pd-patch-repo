local pd = require("pdlib")

local e = pd.gettime()
for _=1,60 do
  local t = pd.gettime() - e
  print(t)
  pd.sleep(1000)
end
