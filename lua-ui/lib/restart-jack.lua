return function(config)
    jack_stop(app)
    local msg = string.format([[
    jack_control stop &&
    jack_control dps device hw:%s &&
    jack_control dps rate %d &&
    jack_control dps period %d &&
    jack_control dps nperiods %d &&
    jack_control dps inchannels %d &&
    jack_control dps outchannels %d &&
    jack_control start
    ]],
    config.hw,
    config.rate,
    config.period,
    config.nperiod,
    config.io,
    config.io
    )
    local h = io.popen(msg)
    local output
    if h ~= nil then
        output = h:read("*a")
    end
    jack_start(app)
    local err = string.match(output, "^.-Failed to open server.-$")

    return err
end