local mapfile = io.open(scriptdir() .. "/maps/" .. game:getdvar("mapname") .. ".lua", "r")
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

game:setdvar("specialops", 0)
game:setdvar("arcademode", 0)
game:setdvar("limited_mode", 0)

game:setdvar("ui_hideminimap", 0)

game:sharedset("eog_extra_data", "")

mapname = game:getdvar("mapname")

require("specops")
require("gsc")

map = require("maps/" .. mapname)

if (game:getdvar("so_debug") == "1") then
    print(map)
end

game:setdiscorddetails("@SPECIAL_OPS_" .. string.upper(mapname))

local black = game:newhudelem()
black:setshader("black", 1000, 1000)
black.x = -120
black.y = 0
black:fadeovertime(1)
black.alpha = 0

game:ontimeout(function()
    player:setactionslot(1, "")
end, 0)

player:notifyonplayercommand("toggle_challenge_timer", "+actionslot 1")
player:setweaponhudiconoverride("actionslot1", "h1_hud_dpad_blur")

gameskill = game:getdvarint("g_gameskill")

map.premain()
mainhook = game:detour(string.format("maps/%s", mapname), "main", function()
    map.main()
end)
