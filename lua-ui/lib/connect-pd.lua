return function()
    local pd_connect_cmd = ""
    for i=1,16 do
        pd_connect_cmd = pd_connect_cmd .. "jack_connect pure_data:output_" .. i .. " craddle:input_" .. i
        if i < 16 then
            pd_connect_cmd = pd_connect_cmd .. " && "
        end
    end
    os.execute(pd_connect_cmd)
end
