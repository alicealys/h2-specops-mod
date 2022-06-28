local map = {}

map.localizedname = "Evasion"
game:addlocalizedstring("SPECIAL_OPS_CONTINGENCY", "Evasion")

map.premain = function()
    -- dont delete stuff
    game:detour("_ID43797", "init", function() end)
    local start = game:getent("info_player_start_so", "classname")
    player:setorigin(start.origin)
    player:setplayerangles(start.angles)

    game:ontimeout(function()
        -- set fog
        player:scriptcall("_ID42407", "_ID40561", "contingency_forest", 0)
    end, 0)

    level:onnotifyonce("player_has_escaped", function()
        missionover(false)
    end)

    enableescapewarning()
    local escaped = game:getent("escaped_trigger", "script_noteworthy")
    escaped:onnotifyonce("trigger", function()
        missionover(true)
    end)

    game:musicplay("mus_contingency_stealth")
    game:detour("maps/contingency_beautiful_corner", "_ID45560", function() end)
    game:scriptcall("_ID42272", "_ID33575", "compass_map_contingency")
    -- delete some random brushmodel
    game:getentbyref(2083, 0):delete()

    local triggerhurts = game:getentarray("trigger_hurt", "classname")
    for i = 1, #triggerhurts do
        triggerhurts[i]:delete()
    end

    addchallengetimer()

    level:onnotifyonce("so_forest_contingency_start", function()
        starttime = game:gettime()
        startchallengetimer()
    end, 0)
end

function stealthmusic()
    game:musicplay("mus_contingency_stealth")

    level:onnotifyonce("_stealth_spotted", function()
        game:musicstop(0.2)
        game:ontimeout(function()
            game:musicplay("mus_contingency_stealth_busted")
        end, 500)

        local listener = nil
        listener = level:onnotify("_stealth_spotted", function()
            if (flag("_stealth_spotted")) then
                return
            end

            listener:clear()

            game:musicstop(3)
            game:ontimeout(function()
                stealthmusic()
            end, 3250)
        end)
    end)
end

function removedeadtrees()
    local deadtrees = game:getentarray("destroyable_tree_base", "script_noteworthy")
    for i = 1, #deadtrees do
        local deadparts = game:getentarray(deadtrees[i].target, "targetname")
        if (deadparts) then
            for o = 1, #deadparts do
                deadparts[i]:delete()
            end
        end 
    end
end

function threatbiascode()
    game:createthreatbiasgroup("bridge_guys")
	game:createthreatbiasgroup("truck_guys")
	game:createthreatbiasgroup("bridge_stealth_guys")
	game:createthreatbiasgroup("dogs")
	game:createthreatbiasgroup("price")
	game:createthreatbiasgroup("player")
	game:createthreatbiasgroup("end_patrol")
	player:setthreatbiasgroup("player")
	game:setignoremegroup("price", "dogs")
	game:setthreatbias("player", "bridge_stealth_guys", 1000)
	game:setthreatbias("player", "truck_guys", 1000)
end

function woodsfirstpatrolcqb()
    level:onnotifyonce("first_patrol_cqb", function()
        local firstpatrolcqb = game:getentarray("first_patrol_cqb", "targetname")
        for i = 1, #firstpatrolcqb do
            local guy = firstpatrolcqb[i]
            guy:scriptcall("maps/_utility", "_ID35014")
        end
    end)
end

function woodsseconddogpatrol()
    level:onnotifyonce("dialog_woods_second_dog_patrol", function()
        if (flag("someone_became_alert")) then
            return
        end

        local endpatrol = getentarray("end_patrol", "targetname")
        for i = 1, #endpatrol do
            local guy = endpatrol[i]
            guy:scriptcall("maps/_utility", "_ID35014")
        end
    end)
end

function enemynerf()
    local spawners = game:getspawnerteamarray("axis")
    for i = 1, #spawners do
        spawners[i]:onnotify("spawned", function(ai)
            ai.baseaccuracy = level.newenemyaccuracy
        end)
    end
end

function setupregular()
	level.newenemyaccuracy = 1

	local spawnerarray = game:getentarray("two_on_right", "script_noteworthy")
	local spawnerarray2 = game:getentarray("regular_remove", "script_noteworthy")
    for i = 1, #spawnerarray2 do
        spawnerarray:push(spawnerarray2[i])
    end

	local array1 = game:getentarray("cqb_patrol", "script_noteworthy")
    local addcount = 0
    for i = 1, #array1 do
        if (addcount < 2) then
            local spawner = array1[i]
            if (spawner.targetname == "first_patrol_cqb") then
                spawnerarray:push(spawner)
                addcount = addcount + 1
            end
        end
    end

    for i = 1, #spawnerarray do
        local spawner = spawnerarray[i]
        spawner.count = 0
    end
end

function soforestinit()
    enemynerf()

    local gameskill = game:getdvarint("g_gameskill")
    if (gameskill <= 1) then
        setupregular()
    elseif (gameskill == 2) then
        level.newenemyaccuracy = 1.75
    elseif (gameskill >= 3) then
        level.newenemyaccuracy = 1.75
    end

    game:objective_add(1, "current", "Evade the patrols and reach the safety of the village.", vector:new(-19720, -5152, 714))
end

function soforest()
    soforestinit()

    game:scriptcall("maps/contingency", "_ID43573")
    game:scriptcall("maps/contingency", "_ID53148")

    woodsfirstpatrolcqb()
    woodsseconddogpatrol()
end

map.main = function()
    game:setdvar("beautiful_corner", 1)
    mainhook.invoke(level)

    game:setsaveddvar("sm_sunShadowScale", 0.5)
	game:setsaveddvar("r_lightGridEnableTweaks", 1)
	game:setsaveddvar("r_lightGridIntensity", 1.5)
	game:setsaveddvar("r_lightGridContrast", 0)

    removedeadtrees()

	flaginit("forest_success")
	flaginit("forest_success_time_updated")
	flaginit("escaped_trigger")
	flaginit("stop_stealth_music")
	flaginit("someone_became_alert")
	flaginit("so_forest_contingency_start")
	flaginit("enemy_killed")

    -- init stuff
    game:scriptcall("_ID52608", "main")
    game:scriptcall("_ID49419", "main")

    game:scriptcall("_ID42323", "_ID32417", "viewhands_player_arctic_wind")

    -- idle_*
    game:scriptcall("_ID42314", "_ID19317")
    game:scriptcall("_ID48225", "main")
    game:scriptcall("_ID43509", "main")
    game:scriptcall("_ID42316", "main")
    game:scriptcall("_ID47233", "main")
    game:scriptcall("_ID42315", "main")
    game:scriptcall("_ID45778", "main")

    game:scriptcall("animscripts/dog/dog_init", "_ID19886")
    game:scriptcall("_ID42339", "main")

    game:scriptcall("_ID42323", "main") -- maps/_load::main
    game:scriptcall("_ID42373", "main") -- maps/_stealth::main
    game:scriptcall("maps/contingency", "_ID46260") -- stealth_settings

    threatbiascode()

    game:scriptcall("maps/contingency", "_ID44368") -- maps/contingency::dialog_we_are_spotted

    stealthmusic()
    game:scriptcall("maps/contingency", "_ID51808") -- dialog_stealth_recovery
    game:scriptcall("maps/contingency", "_ID46140") -- dialog_player_kill_master

    player:scriptcall("_ID42389", "_ID36343") -- maps/_stealth_utils::stealth_plugin_basic
    player:scriptcall("_ID42407", "_ID27997") -- maps/_utils::playerSnowFootsteps

    soforest()

    game:ontimeout(function()

        player:allowcrouch(true)
        player:allowprone(true)
        player:allowstand(true)

        game:setdvar("beautiful_corner", 0)
    end, 0)
end

return map
