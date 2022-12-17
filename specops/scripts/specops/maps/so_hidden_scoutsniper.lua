local map = {}

map.premain = function()
    
end

map.preover = function(success)
    local enemiesleft = level.enemies_spawned
    enemiesleft = enemiesleft - player.kills_stealth
    enemiesleft = enemiesleft - player.kills_nofire
    enemiesleft = enemiesleft - player.kills_basic

    game:sharedset("eog_extra_data", json.encode({
        hidekills = true,
        stats = {
            {
                name = "@SO_HIDDEN_SO_GHILLIES_STAT_STEALTH",
                value = player.kills_stealth
            },
            {
                name = "@SO_HIDDEN_SO_GHILLIES_STAT_NOFIRE",
                value = player.kills_nofire
            },
            {
                name = "@SO_HIDDEN_SO_GHILLIES_STAT_BASIC",
                value = player.kills_basic
            },
            {
                name = "@SO_HIDDEN_SO_GHILLIES_STAT_SKIPPED",
                value = success and enemiesleft or nil
            }
        }
    }))
end

map.main = function()
    game:scriptcall("maps/_compass", "setupminimap", "compass_map_scoutsniper")
    setloadout("cheytac_silencer", "usp_silencer", "fraggrenade", "flash_grenade", "viewhands_marine_sniper", "american")
    setloadoutequipment("c4", "claymore")

    game:getent("church_door_model", "targetname"):delete()

    mainhook.invoke(level)

    player:setweaponammostock("c4", 5)
    player:setweaponammostock("claymore", 5)

    setcompassdist("far")
    setplayerpos()
    enableallportalgroups()

    intro()
    enableescapewarning()
    enableescapefailure()
end

return map
