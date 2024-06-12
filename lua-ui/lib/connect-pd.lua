return function(n_chan)
    local pd_connect_cmd = ""
    for i=1,n_chan do
        pd_connect_cmd = pd_connect_cmd .. "jack_connect pure_data:output_" .. i .. " craddle:input_" .. i
        if i < n_chan then
            pd_connect_cmd = pd_connect_cmd .. " && "
        end
    end
    os.execute(pd_connect_cmd)
end
