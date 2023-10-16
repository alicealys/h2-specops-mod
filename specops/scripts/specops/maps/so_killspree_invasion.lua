local map = {}

map.premain = function()
    game:visionsetnaked("invasion", 0)

    local tarp = game:getentbyref(3096, 0)
    tarp.angles = tarp.angles + vector:new(0, -45, 0)
    tarp.origin = tarp.origin + vector:new(0, 20, 0)

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
