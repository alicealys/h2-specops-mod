local map = {}

map.localizedname = "Breach & Clear"
game:addlocalizedstring("SPECIAL_OPS_GULAG", "Breach & Clear")

function addlockers()
    local brushmodel = game:getentbyref(327, 0)

    local addcollision = function(origin)
        local collision = game:spawn("script_model", origin)
        collision:clonebrushmodeltoscriptmodel(brushmodel)
        collision:hide()
    end

    addcollision((vector:new(-721.342, -712.72, 575) + vector:new(-734.39, -728.037, 575)) / 2)
    addcollision(vector:new(-721.342, -712.72, 575))
    addcollision((vector:new(-664.202, -753.03, 575) + vector:new(-675.522, -769.197, 575)) / 2)
    addcollision(vector:new(-664.202, -753.03, 575))
    addcollision(vector:new(-734.39, -728.037, 575))
    addcollision(vector:new(-675.522, -769.197, 575))

    local lockers = {
		{model = "com_locker_double", angles = vector:new(0, 145, 0), origin = vector:new(-682.632, -751.013, 536)},
		{model = "com_locker_open", angles = vector:new(8, 145, 0), origin = vector:new(-662.973, -764.779, 538)},
		{model = "com_locker_double", angles = vector:new(0, 145, 8), origin = vector:new(-702.292, -737.247, 536)},
		{model = "com_locker_open", angles = vector:new(0, 145, 0), origin = vector:new(-721.952, -723.481, 536)},
		{model = "com_locker_double", angles = vector:new(0, 145, 0), origin = vector:new(-731.781, -716.598, 536)},
		{model = "com_locker_double", angles = vector:new(0, 145, 0), origin = vector:new(-643.313, -778.545, 536)},
		{model = "com_locker_double", angles = vector:new(0, 309, 0), origin = vector:new(-751.441, -702.833, 536)},
		{model = "com_locker_open", angles = vector:new(0, 325, 0), origin = vector:new(-731.781, -716.598, 536)},
		{model = "com_locker_double", angles = vector:new(0, 325, 0), origin = vector:new(-721.952, -723.481, 536)},
		{model = "com_locker_double", angles = vector:new(0, 325, 0), origin = vector:new(-702.292, -737.247, 536)},
		{model = "com_locker_open", angles = vector:new(0, 325, 0), origin = vector:new(-682.632, -751.013, 536)},
		{model = "com_locker_open", angles = vector:new(0, 325, 0), origin = vector:new(-672.802, -757.896, 536)},
		{model = "com_locker_double", angles = vector:new(0, 325, 0), origin = vector:new(-662.973, -764.779, 536)},
    }

    for i = 1, #lockers do
        local model = game:spawn("script_model", lockers[i].origin)
        model.angles = lockers[i].angles
        model:setmodel(lockers[i].model)
        model:makehard()
    end
end


level:onnotify("addlockers", function()
    addlockers()
end)

map.premain = function()
    game:setdvar("r_fog", 0)
    addlockers()

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

    local timelimit = nil
    if (game:getdvarint("g_gameskill") >= 3) then
        timelimit = 180
    end

    addchallengetimer(timelimit)
    level:onnotify("breaching", function()
        game:ontimeout(function()
            startchallengetimer()
            starttime = game:gettime()
        end, 2000)
    end)

    level:onnotify("player_exited_bathroom", function()
        missionover(true)
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
