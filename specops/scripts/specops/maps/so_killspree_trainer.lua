local map = {}

map.localizedname = "The Pit"
map.calculatestars = function(time)
    if (time > 45000) then
        return 1
    end

    if (time < 45000 and time > 35000) then
        return 2
    end

    if (time < 35000) then
        if (level._ID44713 > 0) then
            return 2
        end

        return 3
    end
end

game:addlocalizedstring("SPECIAL_OPS_TRAINER", "The Pit")

map.premain = function()
    game:setdvar("ui_so_show_difficulty", 0)

    game:detour("maps/trainer", "_ID52784", function()
        game:scriptcall("maps/trainer", "_ID50489")
        game:scriptcall("maps/ssdd_lighting", "_ID43713", "course")
        game:scriptcall("_ID42407", "_ID40561", "trainer_pit", 0)

        local start = game:getent("course_start_pit", "targetname")
        player:setorigin(vector:new(-3491, 2563, -190))
        player:setplayerangles(start.angles)

        player:giveweapon("m4_grunt")
        player:givemaxammo("m4_grunt")
        player:giveweapon("usp")
        player:givemaxammo("usp")
        player:switchtoweapon("m4_grunt")

        -- open the gate
        local door = level.struct[53991]
        door:scriptcall("maps/trainer", "_ID11599")

        local cases = level.struct[49518]
        for i = 1, #cases do
            local animation = level.struct[30895]["training_case_01"]["open_case_soldier"]
            cases[i]:setanimknob(animation, 1, 0)
            cases[i]:setanimtime(animation, 1)
            cases[i].origin = cases[i].origin + vector:new(0, 2, 8)
            cases[i].angles = vector:new(0, 90, 0)
        end

        level.struct[47197]:delete() -- pitguy
        level.struct[53623]:delete() -- pitguygun

        local function showweapons(name)
            local weapons = game:getentarray(name, "script_noteworthy")
            for i = 1, #weapons do
                weapons[i]:scriptcall("maps/trainer", "_ID49617")
            end
        end

        showweapons("pit_weapons_case_01")
        showweapons("pit_weapons_case_02")
        showweapons("pit_weapons_table")

        local ai = game:getaiarray()
        for i = 1, #ai do
            ai[i]:delete()
        end

        local spawners = game:getspawnerarray()
        for i = 1, #spawners do
            spawners[i]:delete()
        end
    end)

    local dooropen = nil
    dooropen = game:detour("maps/trainer", "_ID11599", function(door)
        if (door.targetname ~= "gate_cqb_enter_main") then
            dooropen.invoke(door)
        end
    end)

    local timerhook = nil
    timerhook = game:detour("maps/trainer", "_ID47630", function(self_, a1)
        starttime = game:gettime()
        timerhook.invoke(self_, a1)
    end)

    local settimeformathook = nil
    local done = false
    settimeformathook = game:detour("_ID42407", "settimeformat", function(self_, time)
        local recommendeddifficulty = level.struct[46990]
        if (recommendeddifficulty ~= nil and not done) then
            done = true
            local time = math.floor(time * 1000)
            missionover(recommendeddifficulty ~= 1000, time)
        end
        return settimeformathook.invoke(self_, time)
    end)

    -- introscreen
    game:detour("_ID42318", "main", function() end)
end

map.main = function()
    game:setdvar("start", "course")
    mainhook.invoke(level)
end

return map
