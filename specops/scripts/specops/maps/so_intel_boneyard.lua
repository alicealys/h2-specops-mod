local map = {}

map.premain = function()
    setloadout("m4m203_reflex", "cheytac", "fraggrenade", "flash_grenade", "viewhands_tf141", "american")
    game:getentarray("trigger_multiple_slide", "classname"):foreach(entity.delete)
end

map.main = function()
    deletenonspecialops({
        isspawner,
        isspawntrigger,
        istrigger
    })

    game:scriptcall("maps/_compass", "setupminimap", "compass_map_boneyard")

    mainhook.invoke(level)

    setcompassdist("far")
    setplayerpos()
    enableallportalgroups()
    intro()

    enableescapewarning()
    enableescapefailure()

    musicloop("mus_so_intel_boneyard")
end

return map
