local map = {}

map.premain = function()

end

map.main = function()
    deletenonspecialops({
        isspawner,
        isspawntrigger,
        istrigger
    })

    game:scriptcall("maps/_compass", "setupminimap", "compass_map_favela")
    setloadout("m79", "rpg_player", "fraggrenade", "flash_grenade", "viewhands_tf141_favela", "american")
    setloadoutequipment("c4", "claymore")

    mainhook.invoke(level)

    setcompassdist("close")
    setplayerpos()
    enableallportalgroups()
    intro()

    enableescapewarning()
    enableescapefailure()

    musicloop("mus_so_juggernauts_favela")

    player:givemaxammo("c4")
    player:givemaxammo("claymore")
    player:givemaxammo("m79")
    player:givemaxammo("rpg")

    addspawnfunc("axis", function(enemy)
        enemy:onnotifyonce("weapon_dropped", function(weapon)
            weapon:delete()
        end)
    end)
end

return map
