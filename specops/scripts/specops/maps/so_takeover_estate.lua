local map = {}

map.premain = function()
    game:getentarray("window_clip", "targetname"):foreach(entity.delete)
end

map.main = function()
    game:scriptcall("maps/_compass", "setupminimap", "compass_map_estate")
    setloadout("m4m203_eotech", "barrett", "fraggrenade", "flash_grenade", "viewhands_tf141", "american")

    deletenonspecialops({
        isspawner,
        isspawntrigger,
        istrigger
    })

    mainhook.invoke(level)

    setcompassdist("far")
    setplayerpos()
    enableallportalgroups()
    intro()
    musicloop("mus_so_takeover_estate")
end

return map
