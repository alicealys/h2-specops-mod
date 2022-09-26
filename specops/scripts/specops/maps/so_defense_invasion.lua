local map = {}

map.premain = function()
    game:visionsetnaked("invasion", 0)
    game:getent("back_door_col", "targetname"):delete()
end

map.preover = function()
    game:sharedset("eog_extra_data", json.encode({
        hidekills = true,
        stats = {
            {
                name = "@SO_DEFENSE_INVASION_KILLS_TURRET",
                value = player.turret_kills
            },
            {
                name = "@SO_DEFENSE_INVASION_KILLS_BTR80",
                value = player.btr80_kills
            },
            {
                name = "@SO_DEFENSE_INVASION_KILLS_HELI",
                value = player.helicopter_kills
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
end

return map
