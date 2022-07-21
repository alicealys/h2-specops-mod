local map = {}

function addlockercollision()
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
end

function challengeonly()
    local ents = game:getentarray("challenge_only_", "targetname")
    for i = 1, #ents do
        if (ents[i].classname == "script_model") then
            ents[i]:setcandamage(true)
        end

        if (ents[i].classname == "script_brushmodel") then
            ents[i]:connectpaths()
        end
    end
end

map.premain = function()
    game:setdvar("r_fog", 0)
    addlockercollision()
    challengeonly()

    local weapons = game:getentarray("so_weapons", "targetname")
    for i = 1, #weapons do
        local weapon = weapons[i]
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
        end
    end

    setplayerpos()
    enablefailonescape()
    enableescapewarning()

    -- change objective
    game:detour("maps/gulag", "_ID43460", function()
        local org = game:scriptcall("maps/gulag_code", "_ID49776")
        local gameskill = game:getdvarint("g_gameskill")

        if (gameskill <= 2) then
            game:objective_add(1, "current", "&SO_SHOWERS_GULAG_OBJ_REGULAR", org)
        else
            game:objective_add(1, "current", "&SO_SHOWERS_GULAG_OBJ_VETERAN", org)
        end
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
