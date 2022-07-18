local map = {}

map.localizedname = "O Cristo Redentor"
game:addlocalizedstring("SPECIAL_OPS_FAVELA", "O Cristo Redentor")

map.premain = function()
    -- introscreen
    game:detour("_ID42318", "main", function() end)

    -- dont delete stuff
    game:detour("_ID43797", "init", function() end)

    game:getent("favela_soccerball_1", "targetname"):delete()
    game:getent("favela_soccerball_2", "targetname"):delete()

    setfailonmissionover(false)
end

function setupregular()
    objective = "Kill 30 Enemies."
	pointscounter = 30
	
	minenemypopulation = 14
	maxenemypopulation = 22
	maxdogsatonce	= 0
	enemyambushwavesize	= 6
	enemyseekwavesize = 4
	civiliankillfail = 6
	
	ambushtoseekerdelay = 45
end

function setuphardened()
    objective = "Kill 40 Enemies."
	pointscounter = 40
	
	minenemypopulation = 14
	maxenemypopulation = 22
	maxdogsatonce = 2
	enemyambushwavesize = 6
	enemyseekwavesize = 4
	civiliankillfail = 4
	
	ambushtoseekerdelay = 40
end

function deleteonveteran()
    local deleteents = game:getentarray("delete_on_veteran", "script_noteworthy")
    for i = 1, #deleteents do
        deleteents[i]:delete()
    end
end

function setupveteran()
    deleteonveteran()

    objective = "Kill 50 Enemies."
	pointscounter = 50
	
	minenemypopulation = 12
	maxenemypopulation = 20
	maxdogsatonce = 2
	enemyambushwavesize = 6
	enemyseekwavesize = 4
	civiliankillfail = 3
	
	ambushtoseekerdelay = 40
end

function favelainit()
    pointtarget = pointscounter

    game:scriptcall("maps/_utility", "_ID1801", "vision_shanty", "script_noteworthy")

    local sentries = game:getentarray("misc_turret", "classname")
    for i = 1, #sentries do
        sentries[i]:delete()
    end

    local stingers = game:getentarray("weapon_stinger", "classname")
    for i = 1, #stingers do
        stingers[i]:delete()
    end

    local gameskill = game:getdvarint("g_gameskill")

    if (gameskill <= 1) then
        setupregular()
    elseif (gameskill == 2) then
        setuphardened()
    else
        setupveteran()
    end

    game:objective_add(1, "current", objective)

    addspawnfunc("axis", function(ai)
        level:notify("enemy_number_changed")
        level:notify("enemy_population_info_available")
    end)

	arrayspawnfuncnoteworthy("ignore_and_delete_on_goal", function(ai)
        ai:scriptcall("maps/favela_code", "_ID49718")
    end)
	arrayspawnfuncnoteworthy("delete_at_path_end", function(ai)
        ai:scriptcall("maps/favela_code", "_ID43843")
    end)
	arrayspawnfuncnoteworthy("delete_at_path_end_no_choke", function(ai)
        ai:scriptcall("maps/favela_code", "_ID51696")
    end)
	arrayspawnfuncnoteworthy("seek_player", function(ai)
        ai:scriptcall("maps/favela_code", "_ID44232")
    end)
	arrayspawnfuncnoteworthy("dog_seek_player", function(ai)
        ai:scriptcall("maps/favela_code", "_ID45233", 512)
    end)
	arrayspawnfuncnoteworthy("delete_at_goal", function(ai)
        ai:scriptcall("maps/favela_code", "_ID53331")
    end)
	arrayspawnfuncnoteworthy("window_smasher", function(ai)
        ai:scriptcall("maps/favela_code", "_ID49949")
    end)
	arrayspawnfuncnoteworthy("ignored_until_goal", function(ai)
        ai:scriptcall("maps/favela_code", "_ID51706")
    end)
	arrayspawnfuncnoteworthy("desert_eagle_guy", function(ai)
        ai:scriptcall("maps/favela_code", "_ID50867")
    end)
	arrayspawnfuncnoteworthy("faust", function(ai)
        ai:scriptcall("maps/favela_code", "_ID51386")
    end)
end

function spawnwavebytrigger(triggers)
    for i = 1, #triggers do
        triggers[i]:notify("trigger")
    end
end

function spawnfailed(spawn, callback)
    if (not spawn) then
        callback(true)
        return
    end

    if (game:isalive(spawn) == 0) then
        callback(true)
        return
    end

    local f1 = function()
        callback(game:isalive(spawn) == 0)
    end

    if (not spawn._ID14234) then
        spawn:onnotifyonce("finished spawning", f1)
        return
    end

    f1()
end

function enemyrefill(delay, seektrigger, ambushtrigger)
    local listeners = {}

    table.insert(listeners, level:onnotifyonce("enemy_population_info_available", function()
        table.insert(listeners, game:ontimeout(function()
            local lastspawn = 0
            table.insert(listeners, game:oninterval(function()
                local time = game:gettime()
                if (time - lastspawn < 5000) then
                    return
                end

                lastspawn = game:gettime()

                local populationmindelta = minenemypopulation -  #game:getaiarray("axis")
                if (populationmindelta > 0) then
                    spawnenemysecondarywave(ambushtrigger, populationmindelta)
                end
            end, 0))
        end, delay * 1000))
    end))

    level:onnotifyonce("special_op_terminated", function()
        for i = 1, #listeners do
            listeners[i]:clear()
        end
    end)
end

function enemyremovewhenmax(delay)
    local listeners = {}
    table.insert(listeners, level:onnotifyonce("enemy_population_info_available", function()
        local done = true
        local f = function()
            done = false
            local populationmaxdelta = maxenemypopulation - #game:getaiarray("axis")
            
            local f1 = function()
                if (populationmaxdelta < 0) then
                    local enemies = game:getaiarray("axis"):totable()
                    local guys = {}
                    for i = 1, math.abs(populationmaxdelta) do
                        local idx = (game:randomint(#enemies) or 0) + 1
                        guys[i] = enemies[idx]
                        table.remove(enemies, idx)
                    end

                    local arr = array:new()
                    for i = 1, #guys do
                        arr:push(guys[i])
                    end

                    game:scriptcall("maps/_utility", "_ID2265", arr, 512)
                end

                done = true
            end

            if (populationmaxdelta < 0) then
                game:ontimeout(function()
                    populationmaxdelta = maxenemypopulation - #game:getaiarray("axis")
                    f1()
                end, delay * 1000)
                return
            end

            f1()
        end

        table.insert(listeners, level:onnotify("enemy_number_changed", function()
            if (done) then
                f()
            end
        end))
    end))

    table.insert(listeners, level:onnotifyonce("special_op_terminated", function()
        for i = 1, #listeners do
            listeners[i]:clear()
        end
    end))
end

function releasedoggy()
    local dogspawner = game:getentarray("fence_dog_spawner", "targetname"):totable()

    arrayspawnfunc(dogspawner, function(dog)
        dog:onnotifyonce("death", function()
            dogdeaths = dogdeaths + 1
        end)

        dog.goalheight = 80
        dog.goalradius = 300

        local listeners = {}
        table.insert(listeners, game:oninterval(function()
            dog:setgoalpos(player.origin)
        end, 2000))

        table.insert(listeners, level:onnotifyonce("special_op_terminated", function()
            for i = 1, #listeners do
                listeners[i]:clear()
            end
        end))

        table.insert(listeners, dog:onnotifyonce("death", function()
            for i = 1, #listeners do
                listeners[i]:clear()
            end
        end))
    end)

    local gameskill = game:getdvarint("g_gameskill")
    local numdogs = math.max(gameskill, 1)
    local lastdog = 0
    local waittime = 0

    level:onnotify("who_let_the_dogs_out", function()
        local time = game:gettime()
        if (time - lastdog < waittime) then
            return
        end

        for i = 1, numdogs do
            local dog = shuffle(dogspawner)[1]
            local dogcount = game:getaispeciesarray("axis", "dog")

            if (#dogcount < maxdogsatonce) then
                dog.count = 1
                dog:stalingradspawn()
            end
        end

        lastdog = game:gettime()
        waittime = 1 + game:randomint(5)
    end)
end

function shouldreleasedog()
    return ((pointscounter % 10) == 0 )
end

function doggyattack()
	if (maxdogsatonce <= 0) then
        return
    end
	
    level:onnotifyonce("enemy_population_info_available", function()
        level:onnotify("enemy_downed", function()
            if (shouldreleasedog()) then
                level:notify("who_let_the_dogs_out")
            end
        end)
    end)
end

function spawnenemysecondarywave(trigger, maxspawned)
    local spawntrig = {}
    if (type(trigger) ~= "table") then
        table.insert(spawntrig, trigger)
    else
        spawntrig = trigger
    end

    if (maxspawned == nil or maxspawned < 0) then
        spawnwavebytrigger(spawntrig)
        return
    end
    
    alreadyspawned = 0
    spawntrig = shuffle(spawntrig)

    for i = 1, #spawntrig do
        local trig = spawntrig[i]
        local enemyspawners = shuffle(game:getentarray(trig.target, "targetname"):totable())

        local foreachspawner = nil
        foreachspawner = function(index)
            local spawner = enemyspawners[index]
            if (not spawner) then
                return
            end

            if (alreadyspawned <= maxspawned) then
                spawner.count = 1
                local guy = spawner:spawnai()
                spawnfailed(guy, function(result)
                    if (not result) then
                        alreadyspawned = alreadyspawned + 1
                    end

                    foreachspawner(index + 1)
                end)
            end
        end

        foreachspawner(1)
    end
end

function array:totable()
    local t = {}
    for i = 1, #self do
        table.insert(t, self[i])
    end
    return t
end

civviedeaths = 0
enemydeaths = 0
dogdeaths = 0

function killspree()
    favelainit()

    setplayerpos()

    player:takeweapon("m1014")
    player:takeweapon("masada_grenadier_acog")

    player:giveweapon("ranger")
    player:giveweapon("ak47_acog")

    player:switchtoweapon("ak47_acog")

    player:givemaxammo("ranger")
    player:givemaxammo("ak47_acog")

    enableescapewarning()
    enablefailonescape()

    enablechallengetimer("start_so_killspree_favela", "challenge_success")

    enemiestext = createhuditem(3, -135, "Hostiles: ")
    civilianstext = createhuditem(4, -135, "Civilian Deaths: ")

    enemieshitvalue = createhuditem(3, -135)
    enemieshitvalue.alignx = "left"
    enemieshitvalue:setvalue(pointscounter)

    civvieshitvalue = createhuditem(4, -135)
    civvieshitvalue:settext("0 (" .. civiliankillfail .. ")")
    civvieshitvalue.alignx = "left"

    player:onnotify("enemy_killed", function(attacker)
        enemydeaths = enemydeaths + 1

        pointscounter = pointscounter - 1
        if (pointscounter <= 0) then
            enemieshitvalue:setvalue(0)
            missionover(true)
            return
        end

        if (pointscounter <= 5) then
            enemiestext:setgreen()
            enemieshitvalue:setgreen()
        else
            enemiestext:setwhite()
            enemieshitvalue:setwhite()
        end

        enemieshitvalue:setvalue(pointscounter)

        level:notify("enemy_number_changed")
        level:notify("enemy_downed")
        level:notify("enemy_killed_by_player")
    end)

    player:onnotify("civilian_killed", function()
        civviedeaths = civviedeaths + 1
        civvieshitvalue:settext(civviedeaths .. " (" .. civiliankillfail .. ")")

        local remaining = civiliankillfail - civviedeaths
        if (remaining <= 1) then
            civvieshitvalue:setred()
            civilianstext:setred()
        elseif (remaining == 2) then
            civilianstext:setyellow()
            civvieshitvalue:setyellow()
        elseif (remaining > 2) then
            civilianstext:setwhite()
            civvieshitvalue:setwhite()
        end

        if (remaining == 0) then
            missionover(false)
        end
    end)

    level:onnotifyonce("start_so_killspree_favela", function()
        game:ontimeout(function()
            flagset("favela_enemies_spawned")

            local roofspawntrig = game:getent("favela_spawn_trigger", "script_noteworthy")
            local seekerspawntrig = game:getent("so_favela_spawn_trigger", "script_noteworthy")

            local firstwavetrigs = {seekerspawntrig}
            if (game:randomint(100) > 66) then
                table.insert(firstwavetrigs, roofspawntrig)
            end

            local ambushspawntrigger = game:getent("so_favela_ambush_spawn_trigger", "script_noteworthy")

            spawnenemysecondarywave(ambushspawntrigger, enemyambushwavesize)
            spawnenemysecondarywave(firstwavetrigs, enemyseekwavesize)

            game:ontimeout(function()
                releasedoggy()
                doggyattack()
                enemyrefill(10, seekerspawntrig, ambushspawntrigger)
                enemyremovewhenmax(10)
            end, 2000)
        end, 1000)
    end)
end

map.main = function()
    game:scriptcall("_ID46622", "main")
    game:scriptcall("_ID45443", "main")

    game:scriptcall("_ID52157", "main")
    game:scriptcall("maps/favela_anim", "main")
    game:scriptcall("_ID51411", "main")
    game:scriptcall("_ID51362", "main")

    -- hiding_door anims
    game:scriptcall("_ID52657", "main")
    game:scriptcall("_ID45285", "_ID49852")

    game:scriptcall("maps/favela_aud", "main")
    game:scriptcall("maps/favela_lighting", "main")
    game:scriptcall("maps/favela_code", "_ID48221", "playerstart_favela")
    game:scriptcall("maps/favela", "_ID54185")

    game:scriptcall("_ID42323", "_ID32417", "viewhands_player_tf141_favela")
    game:scriptcall("_ID42272", "_ID33575", "compass_map_favela")

    game:scriptcall("_ID42323", "main") -- maps/_load::main
    game:scriptcall("animscripts/dog/dog_init", "_ID19886")

	flaginit("challenge_success")
	flaginit("favela_enemies_spawned")
	flaginit("enemy_population_info_available")
	flaginit("detailed_enemy_population_info_available")
	flaginit("start_so_killspree_favela")

    musicloop("mus_favela_tension")

    killspree()
end

map.preover = function()
    game:addlocalizedstring("SO_KILLSPREE_FAVELA_KILLS_CIVILIANS", "Civilians Killed")
    game:addlocalizedstring("SO_KILLSPREE_FAVELA_KILLS_DOGS", "Dogs Killed")

    local data = {
        hidekills = true,
        stats = {
            {
                name = "@SPECIAL_OPS_UI_KILLS",
                value = enemydeaths - dogdeaths
            },
            {
                name = "@SO_KILLSPREE_FAVELA_KILLS_CIVILIANS",
                value = civviedeaths
            }
        }
    }

    if (maxdogsatonce > 0) then
        table.insert(data.stats, {
            name = "@SO_KILLSPREE_FAVELA_KILLS_DOGS",
            value = dogdeaths
        })
    end

    game:sharedset("eog_extra_data", json.encode(data))
end

return map
