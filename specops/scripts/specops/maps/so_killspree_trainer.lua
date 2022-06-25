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

local areas = {
    {
        index = 1, -- start
        sound = "train_cpd_movingforward",
        donotwarn = true,
        triggers = {
            game:getentbynum(415)
        }
    },
    {
        index = 2, -- first
        sound = "train_cpd_movingforward",
        warnon = game:getentbynum(693),
        triggers = {
            game:getentbynum(421)
        }
    },
    {
        index = 3, -- second
        sound = "train_cpd_areacleared",
        warnon = game:getentbyref(671, 0),
        triggers = {
            game:getentbynum(448),
            game:getentbynum(454),
        }
    },
    {
        index = 4, -- building
        sound = "train_cpd_upthestairs",
        triggers = {
            game:getentbynum(460),
        }
    },
    {
        index = 5, -- stairs melee
        triggers = {
            game:getentbynum(488),
        }
    },
    {
        index = 6, -- heaven
        sound = "train_cpd_jumpdown",
        triggers = {
            game:getentbynum(580),
        }
    },
    {
        index = 7, -- end1
        sound = "train_cpd_lastareamove",
        warnon = game:getentbynum(678),
        forcewarn = true,
        triggers = {
            game:getentbynum(581),
        }
    },
    {
        index = 8, -- end2
        sound = "train_cpd_sprint",
        warnon = game:getentbynum(685),
        forcewarn = true,
        triggers = {
            game:getentbynum(518),
        }
    }
}

for i = 1, #areas do
    local area = areas[i]

    area.totalenemies = 0
    area.hitenemies = 0

    function area:onnotify(notify, callback)
        local listeners = {}
        for o = 1, #area.triggers do
            table.insert(listeners, area.triggers[o]:onnotify(notify, callback))
        end
        return listeners
    end

    function area:notify(notify)
        for o = 1, #area.triggers do
            area.triggers[o]:notify(notify)
        end
    end

    function area:gettargets()
        local targets = {}
        for o = 1, #area.triggers do
            local rawtargets = area.triggers[o]:scriptcall("_ID42237", "_ID15808")
            for u = 1, #rawtargets do
                table.insert(targets, rawtargets[u])
            end
        end
        return targets
    end
end

cantalk = true
ondonesound = nil
function playsound(alias, wait)
    game:ontimeout(function()
        if (cantalk) then
            cantalk = false
            player:playsound(alias, "sound_done_")
            player:onnotifyonce("sound_done_", function()
                game:ontimeout(function()
                    cantalk = true
                    if (ondonesound) then
                        playsound(ondonesound)
                        ondonesound = nil
                    end
                end, 0)
            end)
        elseif (wait and not ondonesound) then
            ondonesound = alias
        end
    end, 0)
end

courseended = false
function endcourse()
    courseended = true
end

local totalhitenemies = 0
local totalhitcivvies = 0

function startcourse()
    starttime = game:gettime()

    playsound("train_cpd_clearfirstgogogo")
    
    startchallengetimer()
    startchallengestars({35, 45, -1})

    coursereloadnag()
    dialogueciviliankilled()

    game:scriptcall("maps/trainer", "cqb_timer_setup")
    game:scriptcall("maps/trainer", "cqb_timer_think")

    level:onnotify("civilian_killed", function()
        totalhitcivvies = totalhitcivvies + 1
        redsplash("Civilian Hit!")
        removechallengestar(3)
        civvieshitvalue:settext(totalhitcivvies .. "/5")
        if (totalhitcivvies >= 5) then
            missionover(false)
        end 
    end)

    game:ontimeout(function()
        game:scriptcall("maps/trainer", "_ID45967")
        local index = game:randomintrange(1, 3)
        local dialogues = {
            "train_ar3_getsome",
            "train_ar4_bringit",
            "train_ar5_comeon"
        }
        game:scriptcall("_ID42237", "_ID27077", dialogues[index], vector:new(-4136, 1921, -65))
    end, 3000)
end

cantalk = true
local currentarea = 1
function initarea(area)
    local targets = area:gettargets()

    local enemytargets = 0
    for i = 1, #targets do
        if (targets[i].script_noteworthy == "target_enemy") then
            enemytargets = enemytargets + 1
        end
    end

    area.totalenemies = enemytargets
    area.hitenemies = 0

    local function poptargets()
        area.started = true
        local hittargets = 0

        for i = 1, #targets do
            local enemy = targets[i].script_noteworthy == "target_enemy"
            targets[i]:notify("pop_up")
            targets[i]:onnotifyonce("hit", function()
                if (not enemy) then
                    return
                end

                totalhitenemies = totalhitenemies + 1
                hittargets = hittargets + 1
                area.hitenemies = hittargets

                enemieshitvalue:settext(totalhitenemies .. "/24")
                if (totalhitenemies >= 24) then
                    enemiestext:setgreen()
                    enemieshitvalue:setgreen()
                end

                if (hittargets == enemytargets) then
                    area.cleared = true
                    if (area.sound) then
                        playsound(area.sound)
                    end

                    hidetargetwarning()
                    splash("Area Cleared")
                    player:playlocalsound("scn_timer_buzzer")

                    currentarea = area.index + 1
                    local nextarea = areas[currentarea]

                    if (nextarea) then
                        if (nextarea.index == 6) then
                            -- open end gate
                            level._ID52018:scriptcall("maps/trainer", "_ID11599", nil, 1)
                            level._ID52018:scriptcall("maps/trainer", "_ID47495")
                            game:getentbyref(371, 0):delete()

                            game:ontimeout(function()
                                if (not jumpeddown) then
                                    playsound("train_cpd_timedcourse")
                                end
                            end, 5000)
                        end
                        
                        nextarea:poptargets()
                    else
                        endcourse()
                    end
                end
            end)
        end
    end

    area.poptargets = poptargets

    if (area.warnon) then
        area.warnon:onnotify("trigger", function()
            if (currentarea < area.index or (area.forcewarn and currentarea == area.index)) then
                showtargetwarning(false)
            end
        end)
    else
        local listeners = nil
        listeners = area:onnotify("trigger", function()
            if (area.index == 1) then
                for i = 1, #listeners do
                    listeners[i]:clear()
                end
    
                poptargets()
                startcourse()
            else
                if (area.started and area.index == 5 and not area.playedsound) then
                    area.playedsound = true
                    playsound("train_cpd_melee", true)
                end

                if (currentarea < area.index) then
                    showtargetwarning(false)
                end
            end
        end)
    end
end

map.preover = function()
    game:addlocalizedstring("SPECIAL_OPS_UI_TIME", "Finished Time")
    game:addlocalizedstring("SO_TRAINER_TOTAL_HIT_ENEMIES", "Enemy Targets Hit")
    game:addlocalizedstring("SO_TRAINER_TOTAL_HIT_CIVVIES", "Civilian Targets Hit")
    game:sharedset("eog_extra_data", json.encode({
        hidekills = true,
        timeoverride = totalhitenemies < 24 and "N/A" or nil,
        stats = {
            {
                name = "@SO_TRAINER_TOTAL_HIT_ENEMIES",
                value = tostring(totalhitenemies) .. "/24"
            },
            {
                name = "@SO_TRAINER_TOTAL_HIT_CIVVIES",
                value = tostring(totalhitcivvies) .. "/5"
            }
        }
    }))
end

function inittriggers()
    local triggers = game:getentarray("course_triggers_01", "script_noteworthy")
    local currentarea = 1

    level:onnotifyonce("player_course_jumped_down", function()
        jumpeddown = true
        if (not areas[6].cleared) then
            missionover(false)
        end
    end)

    for i = 1, #areas do
        initarea(areas[i])
    end

    local endtrigger = game:getentbyref(680, 0)
    endtrigger.origin = vector:new(-3655, 2901, -120)
    local listener = nil
    listener = endtrigger:onnotify("trigger", function()
        if (not jumpeddown or totalhitenemies < 24) then
            return
        end

        level:notify("kill_timer")
        listener:clear()

        missionover(totalhitenemies >= 24)
    end)
end

function hidetargetwarning()
    if (not showwarning) then
        return
    end

    showwarning = false
    targetwarning:fadeovertime(0.3)
    targetwarning.alpha = 0
end

function showtargetwarning(jump)
    if (showwarning) then
        return
    end

    showwarning = true
    local multiple = (areas[currentarea].totalenemies - areas[currentarea].hitenemies) > 1

    targetwarning:fadeovertime(1)
    targetwarning.alpha = 1

    if (multiple and jump) then
        targetwarning:settext("Missed Targets - Go Back Before Jumping")
    elseif (multiple) then
        targetwarning:settext("Missed Targets - Go Back")
    elseif (jump) then
        targetwarning:settext("Missed a Target - Go Back Before Jumping")
    else
        targetwarning:settext("Missed a Target - Go Back")
    end
end

function createmissingtargetwarning()
    targetwarning = game:newhudelem()
    targetwarning.horzalign = "center"
    targetwarning.alignx = "center"
    targetwarning.y = 170
    targetwarning.fontscale = 1.5
    targetwarning.alpha = 0
    targetwarning.font = "objective"
    targetwarning:settext("Missed a Target - Go Back")

    local show = false
    game:oninterval(function()
        targetwarning:fadeovertime(1)
        if (not showwarning) then
            targetwarning.alpha = 0
        else
            if (show) then
                targetwarning.alpha = 0.5
            else
                targetwarning.alpha = 1
            end
        end

        show = not show
    end, 1000)
end

function altweaponhasammo()
	local current = player:getcurrentweapon()
	local weapons = player:getweaponslistprimaries()
	for i = 1, #weapons do
		if (weapons[i] ~= current) then
            local altammo = player:getweaponammoclip(weapons[i])
            return altammo > 5
        end
	end
	return false
end

function coursereloadnag()
    local listener = nil
    listener = player:onnotify("reload_start", function()
        if (courseended or jumpeddown or not altweaponhasammo()) then
            return
        end

        listener:clear()
        playsound("train_cpd_justswitch")
    end)
end

function dialogueciviliankilled()
    local dialogue = {
        "train_cpd_watchout",
        "train_cpd_awwkilled",
        "train_cpd_acivilian"
    }

    local listener = nil
    local line = 0
    level:onnotify("civilian_killed", function()
        if (jumpeddown or courseended) then
            return
        end

        line = line + 1
        if (line > 3) then
            line = 1
        end

        local sound = dialogue[line]
        playsound(sound)
    end)
end

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
        door:playsound("door_gate_chainlink_slow_open")

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

    setchallengestaroffset(-36, 2.2)
    addchallengestars()
    addchallengetimer()
    createmissingtargetwarning()

    game:getentbyref(676, 0):onnotifyonce("trigger", function()
        if (currentarea == 6 and not areas[currentarea].cleared) then
            showtargetwarning(true)
        end
    end)

    enemiestext = createhuditem(3, -135, "Enemies: ")
    civilianstext = createhuditem(4, -135, "Civilians: ")

    enemieshitvalue = createhuditem(3, -135)
    enemieshitvalue:settext("0/24")
    enemieshitvalue.alignx = "left"

    civvieshitvalue = createhuditem(4, -135)
    civvieshitvalue:settext("0/5")
    civvieshitvalue.alignx = "left"

    -- remove default target trigger handlers
    game:detour("maps/trainer", "_ID54524", function() end)
    game:detour("maps/trainer", "_ID44800", function() end)
    game:detour("maps/trainer", "_ID46123", function() end)

    inittriggers()

    -- introscreen
    game:detour("_ID42318", "main", function() end)
end

map.main = function()
    game:setdvar("start", "course")
    mainhook.invoke(level)
end

return map
