sostats = {}

local basepath = "players2/default/"
local statsfilename = basepath .. "/specops_stats.json"

local defaultstats = {
    maps = {

    }
}

local mapkeys = {"stars", "besttime"}

local function parseoldstats()
    if (not io.fileexists(statsfilename)) then
        return
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

    for k, v in pairs(stats.maps) do
        game:statsset("maps", k, "stars", v.stars)
        game:statsset("maps", k, "besttime", v.besttime)
    end

    io.removefile(statsfilename)
end

parseoldstats()

local function getstats()
    local stats = game:statsget()
    if (stats.maps == nil) then
        stats.maps = {}
    end
    return stats
end

sostats.getmapstats = function(mapname)
    local stats = {}

    local has = game:statshas("maps", mapname)
    if (not game:statshas("maps", mapname) or has == 0) then
        return {}
    end

    for k, v in pairs(mapkeys) do
        local value = game:statsget("maps", mapname, v)
        stats[v] = value
    end

    return stats
end

sostats.setmapstats = function(mapname, value)
    for k, v in pairs(value) do
        game:statsset("maps", mapname, k, v)
    end
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
