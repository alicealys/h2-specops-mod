local mapfile = io.open(scriptdir() .. "/maps/" .. game:getdvar("so_mapname") .. ".lua", "r")
if (not mapfile) then
    print("[SPEC OPS] Map not found")
    return
end

mapfile:close()

game:setdvar("ui_so_besttime", 0)
game:setdvar("ui_so_new_star", 0)
game:setdvar("ui_so_show_difficulty", 1)
game:setdvar("ui_so_show_minimap", 1)

game:setdvar("r_fog", 1)

game:setdvar("scr_autoRespawn", 0)
game:setdvar("ui_deadquote", "")
game:setdvar("beautiful_corner", 0)

game:sharedset("eog_extra_data", "")

local mapname = game:getdvar("so_mapname")
map = require("maps/" .. mapname)

if (map.localizedname) then
    game:setdiscorddetails(map.localizedname)
end

local black = game:newhudelem()
black:setshader("black", 1000, 1000)
black.x = -120
black.y = 0
black:fadeovertime(1)
black.alpha = 0

-- set_custom_gameskill_func
level._ID9544 = function()
    game:scriptcall("_ID42298", "_ID34935")
end
game:ontimeout(function()
    game:scriptcall("_ID42298", "_ID32787", true)
end, 0)

map.premain()
mainhook = game:detour(string.format("maps/%s", game:getdvar("mapname")), "main", function()
    map.main()
end)
