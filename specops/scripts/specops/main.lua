local mapfile = io.open(scriptdir() .. "/maps/" .. game:getdvar("so_mapname") .. ".lua", "r")
if (not mapfile) then
    print("[SPEC OPS] Map not found")
    return
end

mapfile:close()

game:setdvar("ui_so_besttime", 0)
game:setdvar("ui_so_new_star", 0)

game:setdvar("scr_autoRespawn", 0)
game:setdvar("ui_deadquote", "")

local mapname = game:getdvar("so_mapname")
map = require("maps/" .. mapname)

if (map.localizedname) then
    game:setdiscorddetails(map.localizedname)
end

map.premain()
mainhook = game:detour(string.format("maps/%s", game:getdvar("mapname")), "main", function()
    map.main()
end)
