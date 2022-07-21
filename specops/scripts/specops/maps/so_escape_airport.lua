local map = {}

map.premain = function()
    -- introscreen
    game:detour("_ID42318", "main", function() end)

    local weapontarp = game:getentbyref(2349, 0)
    local newweapontarp = game:spawn("script_model", weapontarp.origin)
    newweapontarp:clonebrushmodeltoscriptmodel(weapontarp)

    local weapontarp2 = game:getentbyref(2353, 0)
    local newweapontarp2 = game:spawn("script_model", weapontarp2.origin)
    newweapontarp2:clonebrushmodeltoscriptmodel(weapontarp2)
end

function spawnsmoke(smoketag, smoketrigger, smokepause)
    smokepause = smokepause or 1.0
    local trigger = game:getent(smoketrigger, "targetname")
    trigger:onnotifyonce("trigger", function()
        local smokespots = game:scriptcall("_ID42237", "_ID16640", smoketag, "targetname")
        for i = 1, #smokespots do
            game:magicgrenademanual("smoke_grenade_american", smokespots[i].origin, vector:new(0, 0, -1), game:randomfloat(smokepause))
        end
    end)
end

function crashelevator()
    local elevator = game:scriptcall("maps/airport_code", "_ID54197")
    level._ID43262 = elevator

    elevator._ID12279["housing"]["mainframe"][1]:playsound("elevator_shake_groan")
    elevator._ID12279["housing"]["mainframe"][1]:scriptcall("_ID42407", "_ID27079", "scn_airport_elevator_fall")

    game:ontimeout(function()
        game:scriptcall("_ID42234", "_ID13611", 1)
        local struct = game:scriptcall("common_scripts/utility", "_ID16638", "elevator_pick", "targetname")
        local array_ = game:getentarray("elevator_casing_glass", "targetname")
        if (#array_) then
            local var5 = game:scriptcall("common_scripts/utility", "_ID16182", struct.origin, array_)
            if (var5) then
                var5:delete()
            end
        end

        array_ = game:getentarray("elevator_housing_glass", "script_noteworthy")
        if (#array_) then
            local var5 = game:scriptcall("common_scripts/utility", "_ID16182", struct.origin, array_)
            if (var5) then
                var5:delete()
            end
        end

        game:magicgrenademanual("fraggrenade", struct.origin, vector:new(0, 0, 0), 0.05)	

        game:ontimeout(function()
            local mainframe = game:getent("airport_glass_elevator", "script_noteworthy")

            local vec1 = vector:new(0, 0, 1000)
            local vec2 = vector:new(0, 0, -1000)

            game:ontimeout(function()
                game:scriptcall("maps/airport_code", "_ID46962", elevator._ID53945, elevator._ID12279["housing"]["mainframe"][1], 1.05, vec1, vec2)
            end, 950)

            game:ontimeout(function()
                local var1 = elevator:scriptcall("_ID42233", "_ID15889", 0)
                local var2 = elevator:scriptcall("_ID42233", "_ID15891", 0)
                level._ID12382 = game:scriptcall("common_scripts/utility", "_ID3321", level._ID12382, elevator)

                game:ontimeout(function()
                    game:scriptcall("maps/airport_code", "_ID51551", 80)
                end, 100)

                game:ontimeout(function()
                    game:scriptcall("maps/airport_code", "_ID51551", 70)
                end, 600)

                game:ontimeout(function()
                    game:scriptcall("maps/airport_code", "_ID51551", 60)
                end, 750)

                elevator._ID12279["housing"]["inside_trigger"]:delete()
                elevator._ID12279["housing"]["mainframe"][1]:movegravity(vector:new(0, 0, 0), 1)

                game:ontimeout(function()
                    elevator._ID12279["housing"]["mainframe"][1]:playsound("elevator_crash")
                    game:scriptcall("_ID42234", "_ID13611", 2)
                    game:scriptcall("maps/airport_code", "elevator_crash_earthquake")

                    var1:delete()
                    var2:delete()

                    game:ontimeout(function()
                        elevator:notify("elevator_moved")
                        game:scriptcall("common_scripts/utility", "_ID14402", "elevator_destroyed")

                        level._ID51784 = 94
                    end, 500)
                end, 1000)
            end, 1000)
        end, 500)
    end, 0)
end

function disableelevators()
    local elevator = level._ID12382[1]
    local leftdoor = elevator:scriptcall("_ID42233", "_ID15889", 1)
    local rightdoor = elevator:scriptcall("_ID42233", "_ID15891", 1)

    leftdoor:connectpaths()
    rightdoor:connectpaths()

    local housing = game:getentarray("elevator_housing", "targetname")
    for i = 1, #housing do
        disableelevatorinternal(housing[i])
    end

    local buttons = game:getentarray("elevator_call", "targetname")
    for i = 1, #buttons do
        buttons[i].origin = vector:new(0, 0, -50000)
    end
end

function disableelevatorinternal(e)
    local num = 0
    local ent = e
    while (true) do
        if (game:isdefined(ent.target) == 0) then
            return
        end

        ent = game:getent(ent.target, "targetname")
        
        if (num == 2 or num == 3) then
            ent.origin = vector:new(0, 0, -50000)
        end
        
        num = num + 1
    end
end

function shootoutglass()
    local trigger = game:getent("shoot_out_glass", "targetname")
    trigger:onnotifyonce("trigger", function()
        game:scriptcall("maps/_utility", "_ID1801", "enemy_dining_area_riot_movein_trig", "targetname")
        local start = getstruct("shoot_out_glass_start", "script_noteworthy")
        local ends = getstructarray("shoot_out_glass_end", "script_noteworthy")

        local foreach = nil
        foreach = function(i)
            local end_ = ends[i]
            if (i > #ends) then
                return
            end

            local shots = game:randomintrange(5, 8)
            local foreach2 = nil
            foreach2 = function(o)
                if (o > shots) then
                    game:ontimeout(function()
                        foreach(i + 1)
                    end, 1000)
                    return
                end

                game:bullettracer(start.origin, end_.origin, true)
                game:magicbullet("m240", start.origin, end_.origin)
                game:ontimeout(function()
                    foreach2(o + 1)
                end, math.floor(game:randomfloatrange(0.05, 0.1) * 1000))
            end

            foreach2(1)
        end

        foreach(1)
    end)
end

function signdeparturestatuseratic()
    local stop = false
    level:onnotifyonce("special_op_terminated", function()
        stop = true
    end)
	
	local statuses = {
        "arriving",
        "ontime",
        "boarding",
        "delayed"
    }

    game:ontimeout(function()
        local f = nil
        f = function()
            if (flag("stop_board_flipping") or stop) then
                return
            end

            local snds = game:getentarray("snd_departure_board", "targetname")
            for i = 1, #snds do
                local member = snds[i]
                member:playsound(member._ID31438)
            end

            local arr = game:scriptcall("common_scripts/utility", "_ID3320", level._ID46762)
            local spintime = 0

            for i = 1, #arr do
                local value = arr[i]
                spintime = i * 0.1
                game:ontimeout(function()
                    value:scriptcall("maps/airport_code", "_ID43595", statuses[game:randomint(#statuses) + 1])
                end, math.floor(spintime * 1000))
            end

            game:ontimeout(function()
                if (cointoss()) then
                    game:ontimeout(f, game:randomintrange(500, 6000))
                else
                    f()
                end
            end, math.floor(spintime * 1000))

        end

        f()
    end, 1000)
end

function objectivebreadcrumb()
    flaginit("obj_shopping")
    flaginit("obj_escalators_end")
    flaginit("obj_finish")

    local objorigin = getstruct("obj_escalator_top", "script_noteworthy").origin

    local setobj = function(origin)
        game:objective_add(1, "current", "&SO_ESCAPE_AIRPORT_OBJ_REGULAR", origin)
    end

    local updateobjectiveon = function(name, callback)
        level:onnotifyonce(name, function()
            local objorigin = getstruct(name, "script_noteworthy").origin
            game:objective_position(1, objorigin)
            if (callback) then
                callback()
            end
        end)
    end

    setobj(objorigin)

    updateobjectiveon("obj_shopping", function()
        updateobjectiveon("obj_escalators_end", function()
            updateobjectiveon("obj_finish")
        end)
    end)
end

function isscriptmodelcivilian(ent)
    if (ent.code_classname == "script_model" and ent.model == "body_city_civ_male_a_drone") then
        return true
    end

    return false
end

function airport()
    deletenonspecialops({
        isspawner,
        isspawntrigger,
        isvehicle,
        isscriptmodelcivilian
    })

    setplayerpos()

    player:freezecontrols(false)
    player:takeweapon("m4_grenadier_airport")
    player:giveweapon("striker")

    musicloop("mus_airport_escape")

    local trigger = game:getent("start_terminal", "script_noteworthy")
    trigger:onnotify("trigger", function()
        level:notify("start_terminal")
    end)

    local escaped = game:getent("escaped_trigger", "script_noteworthy")
    escaped:onnotifyonce("trigger", function()
        level:notify("escaped_terminal")
    end)

    enablechallengetimer("start_terminal", "escaped_terminal")

    objectivebreadcrumb()

    game:scriptcall("maps/airport_code", "_ID48861")
    signdeparturestatuseratic()
    
    game:scriptcall("maps/airport_code", "_ID51732")

    spawnsmoke("smoke_escalators_first", "enemy_waiting_area_above_movein_trig")
	spawnsmoke("smoke_escalators_ending", "enemy_security_area_final_movein_trig", 0.0)

    shootoutglass()
    disableelevators()
    
    local trigger = game:getent("enemy_waiting_area_above_movein_trig", "targetname")
    trigger:onnotifyonce("trigger", crashelevator)

    local alliesspawners = game:getspawnerteamarray("allies")
    for i = 1, #alliesspawners do
        alliesspawners[i]:delete()
    end

    local neutralsspawners = game:getspawnerteamarray("neutral")
    for i = 1, #neutralsspawners do
        neutralsspawners[i]:delete()
    end

    local securityspawners = game:getspawnerteamarray("axis")
    for i = 1, #securityspawners do
        if (securityspawners[i].classname:match("security")) then
            securityspawners[i]:delete()
        end
    end

    local allies = game:getaispeciesarray("allies")
    for i = 1, #allies do
        allies[i]:delete()
    end

    local neutrals = game:getaispeciesarray("neutral")
    for i = 1, #neutrals do
        neutrals[i]:delete()
    end

    local enemyremovetrigs = {}

    enemyremovetrigs["enemy_waiting_area_intro"] = 0
    arrayspawnfuncnoteworthy("enemy_waiting_area_intro", function(ai)
        enemymovetostruct(ai, "enemy_waiting_area_intro", 384)
    end)

    enemyremovetrigs["enemy_waiting_area_above"] = 0
    arrayspawnfuncnoteworthy("enemy_waiting_area_above", function(ai)
        enemymovetostruct(ai, "enemy_waiting_area_above", 384, true, game:randomintrange(20, 30))
    end)
    arrayspawnfuncnoteworthy("enemy_waiting_area_above", function(ai)
        enemyignorecover(ai)
    end)

    enemyremovetrigs["enemy_dining_area_prone"] = 0
    arrayspawnfuncnoteworthy("enemy_dining_area_prone", function(ai)
        enemypronetostand(ai, "enemy_dining_area_riot", 512)
    end)
    arrayspawnfuncnoteworthy("enemy_dining_area_riot", function(ai)
        enemypronetostand(ai, "enemy_dining_area_riot", 512)
    end)
    
    enemyremovetrigs["enemy_store_area_start"] = 0
    arrayspawnfuncnoteworthy("enemy_dining_area_prone", function(ai)
        enemypronetostand(ai, "enemy_store_area_start", 512)
    end)
    arrayspawnfuncnoteworthy("enemy_store_area_start", function(ai)
        enemypronetostand(ai, "enemy_store_area_start", 512)
    end)

    enemyremovetrigs["enemy_security_area_final"] = 0
    arrayspawnfuncnoteworthy("enemy_security_area_top", function(ai)
        enemymovetostruct(ai, "enemy_security_area_final", 1024)
    end)
    arrayspawnfuncnoteworthy("enemy_security_area_bottom", function(ai)
        enemymovetostruct(ai, "enemy_security_area_final", 1024)
    end)
    arrayspawnfuncnoteworthy("enemy_security_area_final", function(ai)
        enemymovetostruct(ai, "enemy_security_area_final", 1024)
    end) 

    for k, v in pairs(enemyremovetrigs) do
        pastenemyremove(k, v)
    end
end

map.main = function()
    game:precacheitem("m203_m4")
    game:precacheitem("usp_airport")
    game:precacheitem("m4_grunt_airport")
    game:precacheitem("saw_airport")
    game:precacheitem("rpg_straight")
    game:precacherumble("tank_rumble")
    game:precacherumble("damage_heavy")
    game:precacherumble("light_2s")
    game:precacheshader("overlay_airport_death")
    game:precacheshader("white")
    game:precacheshellshock("airport")

    game:scriptcall("maps/airport_anim", "main")
    game:scriptcall("maps/airport_lighting", "main")
    game:scriptcall("maps/airport_aud", "main")
    game:scriptcall("maps/_compass", "setupminimap", "compass_map_airport")
    game:scriptcall("maps/_load", "main")

    airport()
end

function enemyignorecover(ent)
	ent.combatmode = "no_cover"
end

function enemyseekplayer(ent, goalradius, delay)
    local stop = false
    level:onnotifyonce("special_op_terminated", function()
        stop = true
    end)

    ent:onnotifyonce("death", function()
        stop = true
    end)

    local f = function()
        if (stop) then
            return
        end

        local f1 = function()
            if (stop) then
                return
            end

            enemyupdatetarget(ent, player)
            ent.goalradius = goalradius
            ent.goalheight = 256
        end

        if (ent.target ~= nil) then
            ent:onnotifyonce("goal", f1)
        else
            f1()
        end
    end

    if (delay) then
        game:ontimeout(f, math.floor(delay * 1000))
    else
        f()
    end
end

function enemyupdatetarget(ent, newtarget)
	ent.currentgoalplayer = newtarget
	ent:setgoalentity(newtarget)
end

function enemymovetostruct(ent, trig, seekgoalradius, stay, duration)
    if (game:isalive(ent) == 0) then
        return
    end

    local stop = false
    ent:onnotifyonce("woken_up", function()
        stop = true
    end)

    ent:onnotifyonce("death", function()
        stop = true
    end)

    level:onnotifyonce("special_op_terminated", function()
        stop = true
    end)

	ent.baseaccuracy = 1.0
	ent:setgoalpos(ent.origin)
	ent.goalradius = 16
	ent:scriptcall("maps/_utility", "_ID10912")
	ent.ignoreall = true

    local triggername = nil
    if (trig ~= nil) then
        triggername = trig .. "_movein_trig"
    end
			
	enemymovetostructdetectdamage(ent, seekgoalradius, stay, duration, triggername)
	
    if (triggername ~= nil) then
        local trigger = game:getent(triggername, "targetname")
        trigger:onnotifyonce("trigger", function(ent2)
            if (stop) then
                return
            end

            game:ontimeout(function()
                if (stop) then
                    return
                end

                level:notify(triggername, ent2)
            end, 0)

            enemymovetostructwakeup(ent, seekgoalradius, stay, duration)
        end)
    else
        enemymovetostructwakeup(ent, seekgoalradius, stay, duration)
    end
end

function enemymovetostructdetectdamage(ent, seekgoalradius, stay, duration, triggername)
    local done = false
    level:onnotifyonce("special_op_terminated", function()
        done = true
    end)
    ent:onnotifyonce("woken_up", function()
        done = true
    end)

    local l1 = nil
    local l2 = nil
    local f = function()
        l1:clear()
        l2:clear()

        if (done) then
            return
        end

        done = true

        if (triggername ~= nil) then
            game:scriptcall("maps/_utility", "_ID1801", triggername, "targetname")
        end

        if (game:isalive(ent) == 1) then
            enemymovetostructwakeup(ent, seekgoalradius, stay, duration)
        end
    end

    l1 = ent:onnotifyonce("damage", f)
    l2 = ent:onnotifyonce("death", f)
end

function enemymovetostructwakeup(ent, seekgoalradius, stay, duration)
    ent:notify("woken_up")

	ent.ignoreall = false
	local node = game:getnode(ent.target, "targetname")
	if (game:isdefined(node) == 0) then
        node = getstruct(ent.target, "targetname")
    end

    local goaltype = nil
	if (node.classname == nil) then
		if (node.type == nil) then
			goaltype = "struct"
        else
			goaltype = "node"
        end
	else
		goal_type = "origin"
    end

	local requireplayerdist = 300
    ent:scriptcall("_ID42372", "_ID16964", node, goaltype, nil, requireplayerdist)

    local entnum = ent:getentitynumber()
    game:ontimeout(function()
        if (game:isalive(ent) == 0) then
            return
        end

        ent:scriptcall("maps/_utility", "_ID12480")
        if (stay == true) then
            enemyseekplayer(ent, seekgoalradius, duration)
        else
            enemyseekplayer(ent, seekgoalradius)
        end
    end, 1000)
end

function enemypronetostand(ent, trig, seekgoalradius, stay, duration)
    local stop = false
    level:onnotifyonce("special_op_terminated", function()
        stop = true
    end)

    ent:onnotifyonce("death", function()
        stop = true
    end)

    ent:onnotifyonce("woken_up", function()
        stop = true
    end)
	
	ent.ignoreall = true
	ent:setgoalpos(ent.origin)
	ent.goalradius = 16
	ent:scriptcall("maps/_utility", "_ID10912")

    game:ontimeout(function()
        if (stop) then
            return
        end

        local triggername = nil
        if (trig ~= nil) then
            triggername = trig .. "_movein_trig"
        end

        enemypronetostanddetectdamage(ent, seekgoalradius, stay, duration, triggername)

        if (triggername ~= nil) then
            local trigger = game:getent(triggername, "targetname")
            trigger:onnotifyonce("trigger", function(ent2)
                if (stop) then
                    return
                end
    
                game:ontimeout(function()
                    if (stop) then
                        return
                    end
    
                    level:notify(triggername, ent2)
                end, 0)
    
                enemypronetostandwakeup(ent, seekgoalradius, stay, duration)
            end)
        end
    end, 0)
end

function enemypronetostanddetectdamage(ent, seekgoalradius, stay, duration, triggername)
    local stop = false
    level:onnotifyonce("special_op_terminated", function()
        stop = true
    end)

    ent:onnotifyonce("woken_up", function()
        stop = true
    end)

    local l1 = nil
    local l2 = nil

    local done = false
    local f = function()
        l1:clear()
        l2:clear()

        if (done) then
            return
        end

        done = true

        if (stop) then
            return
        end

        if (triggername ~= nil) then
            game:scriptcall("maps/_utility", "_ID1801", triggername, "targetname")
        end

        if (game:isalive(ent) == 1) then
            enemypronetostandwakeup(ent, seekgoalradius, stay, duration)
        end
    end

    l1 = ent:onnotifyonce("damage", f)
    l2 = ent:onnotifyonce("death", f)
end

function enemypronetostandwakeup(ent, seekgoalradius, stay, duration)
    ent:notify("woken_up")
	
	ent.ignoreall = false
    ent:scriptcall("maps/_utility", "_ID12480")
    if (stay == true) then
        enemyseekplayer(ent, seekgoalradius, duration)
    else
        enemyseekplayer(ent, seekgoalradius)
    end
end

function pastenemyremove(enemygroup, num)
    level:onnotifyonce(enemygroup .. "_kill", function()
        local enemyarray = game:getaiarray("axis")
        local guystodelete = array:new()

        for i = 1, #enemyarray do
            local guy = enemyarray[i]
            if (guy.script_noteworthy == enemygroup) then
                guystodelete:push(guy)
            end
        end

        if (num ~= nil and num > 0 and num < #guystodelete) then
            local randomguys = game:scriptcall("common_scripts/utility", "_ID3320", guystodelete)
            guystodelete = array:new()

            for i = 1, num do
                guystodelete:push(randomguys[i])
            end
        end

        game:scriptcall("maps/_utility", "_ID2265", guystodelete, 512)
    end)
end

return map
