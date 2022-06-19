local map = {}

map.localizedname = "Breach & Clear"

map.premain = function()
    local weapons = {
        {
            origin = vector:new(-1744.6, -1901.6, 596.5),
            angles = vector:new(320.895, 241.463, 0.910643),
            model = "weapon_ak47"
        },
        {
            origin = vector:new(-1695.9, -1765.4, 598),
            angles = vector:new(286.895, 35.7082, -179.18),
            model = "weapon_ak47"
        },
        {
            origin = vector:new(-1760.8, -1891.8, 593.8),
            angles = vector:new(313.4, 239.5, -80),
            model = "weapon_aa12"
        },
        {
            origin = vector:new(-1741.3, -1868.3, 579.125),
            angles = vector:new(0, 299.6, 90),
            model = "weapon_kriss"
        },
        {
            origin = vector:new(-1718.8, -1885.6, 577.125),
            angles = vector:new(0, 284.5, 90),
            model = "weapon_glock"
        },
        {
            origin = vector:new(-1685.1, -1770.2, 598.3),
            angles = vector:new(289.2, 72.5, -180),
            model = "weapon_aa12"
        },
        {
            origin = vector:new(-1761.4, -1763.9, 577.125),
            angles = vector:new(0, 356.931, 90),
            model = "weapon_m14_scoped_arctic"
        },
        {
            origin = vector:new(-1727.3, -1774.5, 577.125),
            angles = vector:new(0, 90, 90),
            model = "weapon_striker"
        },
    }

    for i = 1, #weapons do
        local weapon = game:spawn(weapons[i].model, weapons[i].origin)
        if (weapon) then
            local weaponnames = game:strtok(weapon.classname, "_")
            local weaponname = weaponnames[2]
            for i = 3, #weaponnames do
                weaponname = weaponname .. "_" .. weaponnames[i]
            end

            if (game:weaponaltweaponname(weaponname) ~= "none") then
                weapon:itemweaponsetammo(999, 999, 999, 1)
            end
    
            weapon:itemweaponsetammo(999, 999)

            game:oninterval(function()
                weapon.origin = weapons[i].origin
                weapon.angles = weapons[i].angles
            end, 0)
        end
    end

    local successtrig = game:spawn("trigger_radius", vector:new(0, 0, 0), 0, 400, 100)
    successtrig.origin = vector:new(-22, 265, 316)

    successtrig:onnotifyonce("trigger", function()
        missionover(true)
    end)

    local failtrig = game:spawn("trigger_radius", vector:new(0, 0, 0), 0, 200, 100)
    failtrig.origin = vector:new(-2598, -2393, 672)

    failtrig:onnotifyonce("trigger", function()
        missionover(false)
    end)

    -- change objective
    game:detour("maps/gulag", "_ID43460", function()
        local org = game:scriptcall("maps/gulag_code", "_ID49776")
        game:objective_add(4, "current", "Escape as quickly as possible.", org)
    end)

    level:onnotify("breaching", function()
        game:ontimeout(function()
            starttime = game:gettime()
        end, 3150)
    end)
end

map.main = function()
    game:setdvar("start", "bathroom")
    mainhook.invoke(level)

    game:ontimeout(function()
        player:takeweapon("m14_scoped_arctic")
        player:giveweapon("m1014")
        player:givemaxammo("m1014")

        local spawners = game:getspawnerteamarray("allies")
        for i = 1, #spawners do
            spawners[i]:delete()
        end

        local teammates = game:getaispeciesarray("allies")
        for i = 1, #teammates do
            teammates[i]:delete()
        end

        game:getentbyref(1318, 0):delete()
        game:getentbyref(1305, 0):delete()
        game:getentbyref(1319, 0):delete()

        player:setorigin(vector:new(-1462, -2014, 576))
        player:setplayerangles(vector:new(0, 120, 0))
    end, 0)
end

return map
