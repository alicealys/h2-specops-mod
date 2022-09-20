local map = {}

map.premain = function()
    game:visionsetnaked("invasion", 0)
end

map.preover = function()
    game:sharedset("eog_extra_data", json.encode({
        hidekills = true,
        stats = {
            {
                name = "@SO_KILLSPREE_INVASION_EOG_SOLID",
                value = player.solid_kills
            },
            {
                name = "@SO_KILLSPREE_INVASION_EOG_HEARTLESS",
                value = player.heartless_kills
            },
            {
                name = "@SO_KILLSPREE_INVASION_EOG_COMBOS",
                value = player.highest_combo
            },
            {
                name = "@SO_KILLSPREE_INVASION_EOG_SCORE",
                value = player.total_score
            }
        }
    }))
end

map.main = function()
    game:scriptcall("maps/_compass", "setupminimap", "compass_map_invasion")
    setloadout("scar_h_reflex", "beretta", "fraggrenade", "flash_grenade", "viewmodel_base_viewhands", "american")

    mainhook.invoke(level)

    setcompassdist("far")
    setplayerpos()
    enableallportalgroups()
    intro()
    musicloop("mus_so_killspree_invasion")
end

return map
