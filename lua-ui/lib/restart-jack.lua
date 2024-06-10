return function(config)
    jack_stop(app)
    local msg = string.format([[
    jack_control stop &&
    jack_control dps device hw:%s &&
    jack_control dps rate %d &&
    jack_control dps period %d &&
    jack_control dps nperiods %d &&
    jack_control start
    ]],
    config.hw,
    config.rate,
    config.period,
    config.nperiod
    )
    local h = io.popen(msg)
    if h ~= nil then
        local o = h:read("*a")
        print(o)
    end
    jack_start(app)
end