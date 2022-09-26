sostats = {}

local basepath = "players2/default/"
local statsfilename = basepath .. "/specops_stats.json"

local defaultstats = {
    maps = {

    }
}

local function getstatsinternal()
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

local function getstats()
    local stats = getstatsinternal() or {}
    if (type(stats.maps) ~= "table") then
        stats.maps = {}
    end
    return stats
end

local function writestats(stats)
    io.writefile(statsfilename, json.encode(stats), false)
end

sostats.getmapstats = function(mapname)
    local stats = getstats()
    local mapstats = stats.maps[mapname] or {}
    return mapstats
end

sostats.setmapstats = function(mapname, value)
    local stats = getstats()
    stats.maps[mapname] = value
    writestats(stats)
end

sostats.gettotalstars = function()
    local stats = getstats()
    local totalstars = 0
    for k, v in pairs(stats.maps) do
        if (v.stars) then
            totalstars = totalstars + v.stars
        end
    end
    return totalstars
end

return sostats
