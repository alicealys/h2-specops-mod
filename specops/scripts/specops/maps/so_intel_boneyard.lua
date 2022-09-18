local map = {}

map.premain = function()

end

map.main = function()
    deletenonspecialops({
        isspawner,
        isspawntrigger,
        istrigger
    })

    game:scriptcall("maps/_compass", "setupminimap", "compass_map_boneyard")
    setloadout("m4m203_reflex", "cheytac", "fraggrenade", "flash_grenade", "viewhands_tf141", "american")

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
