local mapfile = io.open(scriptdir() .. "/maps/" .. game:getdvar("mapname") .. ".lua", "r")
if (not mapfile) then
    return
end

mapfile:close()

local mapname = game:getdvar("mapname")
local map = require("maps/" .. mapname)

if (map.localizedname) then
    game:setdiscorddetails(map.localizedname)
end

map.premain()
mainhook = game:detour(string.format("maps/%s", mapname), "main", function()
    map.main()
end)
