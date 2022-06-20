sostats = {}

local basepath = game:getloadedmod()
local statsfilename = basepath .. "/stats.json"

local defaultstats = {
    maps = {

    }
}

local function getstats()
    if (not io.fileexists(statsfilename)) then
        io.writefile(statsfilename, json.encode(defaultstats), false)
        return defaultstats
    end

    local stats = nil
    pcall(function()
        stats = json.decode(io.readfile(statsfilename))
    end, 0)

    if (type(stats) ~= "table") then
        stats = {}
    end

    if (type(stats.maps) ~= "table") then
        stats.maps = {}
    end

    return stats
end

local function writestats(stats)
    io.writefile(statsfilename, json.encode(stats), false)
end

sostats.getmapstats = function(mapname)
    local stats = getstats() or {}
    if (type(stats.maps) ~= "table") then
        stats.maps = {}
    end
    local mapstats = stats.maps[mapname] or {}
    return mapstats
end

sostats.setmapstats = function(mapname, value)
    local stats = getstats() or {}
    if (type(stats.maps) ~= "table") then
        stats.maps = {}
    end
    stats.maps[mapname] = value
    writestats(stats)
end

return sostats
