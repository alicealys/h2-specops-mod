local map = {}

game:precacheitem("p90_reflex")

map.premain = function()
    setloadout("m21_scoped_arctic_silenced", "usp_silencer", "fraggrenade", "flash_grenade", "viewhands_arctic", "american")

    game:ontimeout(function()
        -- set fog
        player:scriptcall("maps/_utility", "_ID40561", "contingency_forest", 0)
    end, 0)

    setplayerpos()
    intro()
    enableescapefailure()
    enableescapewarning()

    local escaped = game:getent("escaped_trigger", "script_noteworthy")
    escaped:onnotifyonce("trigger", function()
        flagset("forest_success")
    end)
    
    enablechallengetimer("so_forest_contingency_start", "forest_success")

    game:musicplay("mus_contingency_stealth")
    game:detour("maps/contingency_beautiful_corner", "_ID45560", function() end)
    game:scriptcall("maps/_compass", "setupminimap", "compass_map_contingency")

    local endbrush = game:getentbyref(2083, 0)
    endbrush.origin = vector:new(-19547.058594, -5072.545898, 758.208191)
    endbrush.angles = vector:new(0, 65, 0)

    local triggerhurts = game:getentarray("trigger_hurt", "classname")
    for i = 1, #triggerhurts do
        triggerhurts[i]:delete()
    end
end

function stealthmusic()
    musicloop("mus_contingency_stealth")

    level:onnotifyonce("_stealth_spotted", function()
        game:musicstop(0.2)
        game:ontimeout(function()
            musicloop("mus_contingency_stealth_busted")
        end, 500):endon(level, "special_op_terminated")

        local listener = nil
        listener = level:onnotify("_stealth_spotted", function()
            if (flag("_stealth_spotted")) then
                return
            end

            listener:clear()

            game:musicstop(3)
            game:ontimeout(function()
                stealthmusic()
            end, 3250):endon(level, "special_op_terminated")
        end)

        listener:endon(level, "special_op_terminated")
    end):endon(level, "special_op_terminated")
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

    local escapetrig = game:getent("escaped_trigger", "script_noteworthy")
    local escapeobjorigin = game:getent(escapetrig.target, "targetname").origin
    game:objective_add(1, "current", "&SO_FOREST_CONTINGENCY_OBJ_REGULAR", escapeobjorigin)
    game:playfx(extractionsmoke, escapeobjorigin)
end

function soforest()
    soforestinit()

    game:scriptcall("maps/contingency", "_ID43573")
    game:scriptcall("maps/contingency", "_ID53148")

    woodsfirstpatrolcqb()
    woodsseconddogpatrol()
end

map.main = function()
    mainhook.invoke(level)

    extractionsmoke = game:loadfx("fx/smoke/green_flare_smoke_distant")

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
    enableallportalgroups()

    game:ontimeout(function()
        player:allowcrouch(true)
        player:allowprone(true)
        player:allowstand(true)
    end, 0)
end

return map
