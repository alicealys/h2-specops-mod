local map = {}

map.premain = function()
    game:visionsetnaked("invasion", 0)
    local backdoor = game:getent("diner_back_door", "targetname")
    local doorcol = game:getent("back_door_col", "targetname")
    doorcol:linkto(backdoor)
    doorcol:connectpaths()
    local doorcoldup = game:spawn("script_model", vector:new(-454.452, -1018.58, 2358.8))
    doorcoldup.angles = vector:new(0, -2, 0)
    doorcoldup:clonebrushmodeltoscriptmodel(doorcol)
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
