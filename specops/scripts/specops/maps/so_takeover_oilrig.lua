local map = {}

map.premain = function()
    game:visionsetnaked("oilrig", 0)
end

function savetriggers()
    game:scriptcall("maps/_compass", "setupminimap", "compass_map_oilrig_lvl_1")

    local triggers = game:getentarray("compassTriggers", "targetname")
    for i = 1, #triggers do
        triggers[i].script_specialops = 1
    end
    
    game:getent("killtrigger_ocean", "targetname").script_specialops = 1
end

map.main = function()
    game:scriptcall("maps/_compass", "setupminimap", "compass_map_oilrig_lvl_1")
    setloadout("m240", "m79", "fraggrenade", "flash_grenade", "viewhands_udt", "american")
    setloadoutequipment("claymore")

    savetriggers()
    deletenonspecialops({
        isspawner,
        --isspawntrigger,
        istrigger
    })

    mainhook.invoke(level)

    player:givemaxammo("claymore")

    setcompassdist("far")
    setplayerpos()
    enableallportalgroups()
    intro()
    musicloop("mus_so_takeover_oilrig")
end

return map
