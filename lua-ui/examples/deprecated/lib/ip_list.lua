local function ip_list(cmd_runner)
  cmd_runner:call("ip addr")
  local output = cmd_runner:read("*a")
  cmd_runner:close()

  if output == nil then return nil end

  local lines = {}

  for line in output:gmatch("[^\r\n]+") do
    table.insert(lines, line)
  end

  local devices = {}
  local awaiting_ip = false

  for _,line in ipairs(lines) do
    local n, dev = string.match(line, "(%d+):%s*(.-):%s<")
    if n and dev then
      if awaiting_ip == true then -- if awaiting ip info but reached next device, last device has no ip
        devices[#devices].ip = "N/A"
      end
      table.insert(devices, {device=dev})
      awaiting_ip = true
    end

    local ip = line:match("inet%s+(%d+%.%d+%.%d+%.%d+)/%d+")
    if ip then
      devices[#devices].ip = ip
      awaiting_ip = false
    end
  end

  return devices
end


return ip_list