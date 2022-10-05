local map = {}

function getplayervehicle()
    local linked = player:getlinkedparent()
    if (linked and linked.classname and linked.classname:match("vehicle")) then
        return linked
    end

    return nil
end

map.calculatestars = function(time)
    if (time <= 70000) then
        return 3
    elseif (time > 70000 and time <= 90000) then
        return 2
    elseif (time <= 120000) then
        return 1
    end

    return 0
end

map.preover = function(success)
    if (success) then
        return
    end

    game:sharedset("eog_extra_data", json.encode({
		timestringoverride = "@SO_SNOWRACE1_CLIFFHANGER_DNF",
    }))
end

function entity:startraceboost()
    game:ontimeout(function()
        local boostwindow = 0.2
        local vehicle = getplayervehicle()
        if (not vehicle) then
            return
        end

	    if (vehicle.veh_throttle > 0) then
		    return
        end

        local giveboost = function()
            vehicle:givevehicleboost(50)
	
            text = game:newhudelem()
            text.hidewheninmenu = true
            text.alignx = "center"
            text.horzalign = "center"
            text.fontscale = 1
            text.y = 180
            text.alpha = 0
            text:fadeovertime(0.1)
            text.alpha = 1
            text.objectivefont = true
            text:setwhite(true)
            text:settext("&SO_SNOWRACE1_CLIFFHANGER_PERFECT_TIMING")
    
            game:ontimeout(function()
                text:fadeovertime(0.5)
                text.alpha = 0
                game:ontimeout(function()
                    text:destroy()
                end, 500)
            end, 2000)
        end
	
        local listener = nil
        listener = game:oninterval(function()
            if (vehicle.veh_throttle ~= 0) then
                listener:clear()
                giveboost()
                return
            end

            boostwindow = boostwindow - 0.05
            if (boostwindow <= 0) then
                listener:clear()
                return
            end
        end, 50)
    end, 200)
end

function entity:givevehicleboost(boostspeed)
	speed = math.floor(self:vehicle_getspeed())
	if (speed >= boostspeed) then
		return
    end
	
    local end_ = function()
        if (game:isdefined(self) == 1) then
            self:vehphys_setspeed(boostspeed)
        end
    end

    local listener = nil
    local callback = function()
        if (game:isdefined(self) == 0) then
            listener:clear()
            end_()
            return
        end
        
        speed = speed + 5
        if (speed > boostspeed) then
            listener:clear()
            end_()
            return
        end

        self:vehphys_setspeed(speed)
    end

    callback()
    listener = game:oninterval(callback, 0)
end

map.addtimer = function()
    addchallengetimer(nil, true)
    addchallengestars()
end

map.starttimer = function()
    startchallengestars({70, 90, 120})
    startchallengetimer()
end

map.objective = "&SO_SNOWRACE1_CLIFFHANGER_OBJ_FINISHLINE"

function objective()
    local finishline = game:getent("finish_line_origin", "targetname")
    game:objective_add(1, "current", map.objective, finishline.origin)
    game:objective_setpointertextoverride(1, "&SO_SNOWRACE1_CLIFFHANGER_FINISHLINE")

    local movers = game:getentarray("move_objective", "targetname")
    for i = 1, #movers do
        local originent = game:getent(movers[i].target, "targetname")
        movers[i]:onnotifyonce("trigger", function()
            finishline:moveto(originent.origin, 10, 1.0, 1.0)
        end)
    end

    game:oninterval(function()
        game:objective_position(1, finishline.origin)
    end, 0)
end

map.premain = function()
    game:executecommand("0x4E5D8AE8 3")

    settimetrial(true)

    game:setdvar("ui_so_show_difficulty", 0)
    game:setdvar("ui_so_show_minimap", 0)

    game:precacheshader("star")

    -- remove radio chatter
    game:detour("_ID42407", "_ID28864", function() end)

    local finishtrig = game:getent("finishline", "targetname")
    local done = false
    finishtrig:onnotify("trigger", function(ent)
        if (not done and ent == player) then
            missionover(true)
            done = true
        end
    end)

    -- change objective
    game:detour("maps/cliffhanger_code", "_ID43733", objective)

    -- remove end triggers
    game:getentbyref(69, 0):delete()
    local triggers = game:getentarray("player_top_speed_limit_trigger", "targetname")
    for i = 1, #triggers do
        triggers[i]:delete()
    end

    -- tree explosion triggers
    game:getentbyref(1942, 0):delete()
    game:getentbyref(2397, 0):delete()

    local black = game:newhudelem()
    black:setshader("black", 1000, 1000)
    black.x = -120
    black.y = 0

    local starttimer = game:newhudelem()
    starttimer.horzalign = "center"
    starttimer.alignx = "center"
    starttimer.y = 210
    starttimer.font = "objective"
    starttimer.fontscale = 2
    starttimer.hidewhendead = true
    starttimer.hidewheninmenu = true

    player:freezecontrols(true)

    map.addtimer()

    local startrace = function()
        local vehicle = getplayervehicle()
        if (vehicle) then
            vehicle.veh_topspeed = 100
        end

        starttimer:settext("&SO_SNOWRACE1_CLIFFHANGER_RACE_READY")
        starttimer.objectivefont = true
        starttimer.fontscale = 1
        starttimer:setwhite()
        player:freezecontrols(true)

        game:ontimeout(function()
            local timer = nil
            local beeps = 0

            timer = game:oninterval(function()
                starttimer:settext("&SO_SNOWRACE1_CLIFFHANGER_RACE_" .. tostring(3 - beeps))
                if (beeps <= 1) then
                    starttimer:setred()
                else
                    starttimer:setyellow()
                end
    
                if (beeps == 3) then
                    starttimer:setgreen()
                    starttimer:settext("&SO_SNOWRACE1_CLIFFHANGER_RACE_GO")
    
                    game:ontimeout(function()
                        starttimer:fadeovertime(0.5)
                        starttimer.alpha = 0
                        game:ontimeout(function()
                            starttimer:destroy()
                        end, 500)
                    end, 1000)
                    
                    player:playsound("so_starttimer_go")
                    game:musicplay("mus_cliffhanger_snowmobile")
    
                    player:freezecontrols(false)
                    player:startraceboost()
                    starttime = game:gettime()
                    timer:clear()

                    map.starttimer()
                    return
                end
    
                player:playsound("so_starttimer_beep")
                beeps = beeps + 1
            end, 1000)
        end, 1000)
    end

    game:detour("maps/cliffhanger_aud", "main", function() end)

    game:ontimeout(function()
        level._ID48727:vehicle_teleport(vector:new(-11804, -35416.3, 117.931), vector:new(9.00746, 185.371, -4.1671))
        game:ontimeout(function()
            black:fadeovertime(1)
            black.alpha = 0
            startrace()
        end, 500)
    end, 0)

    local spawners = game:vehicle_getspawnerarray()
    for i = 1, #spawners do
        if (spawners[i].targetname:match("fly")) then
            spawners[i]:delete()
        end
    end

    local spawners = game:getspawnerteamarray("allies")
    for i = 1, #spawners do
        spawners[i]:delete()
    end

    local ai = game:getaispeciesarray("allies")
    for i = 1, #ai do
        ai[i]:delete()
    end

    local destructibles = game:getentarray("destructible_toy", "targetname")
    for i = 1, #destructibles do
        destructibles[i]:delete()
    end

    local toremove = {
        "script_vehicle_hind_chernobyl",
        "script_vehicle_ch46e_opened_door_interior_a",
        "actor_ally_hero_soap_arctic",
        "script_vehicle_snowmobile_friendly",
    }

    game:oninterval(function()
        for i = 1, #toremove do
            local ent = game:getent(toremove[i], "classname")
            if (ent) then
                ent:delete()
            end
        end
    end, 0)

    if (game:getdvar("so_mapname") == "so_snowrace1_cliffhanger") then
        player.ignorerandombulletdamage = true

        game:scriptcall("maps/cliffhanger_code", "_ID12882")
        game:scriptcall("_ID42237", "_ID14402", "reached_top")
    
        game:ontimeout(function()
            game:scriptcall("_ID50343", "_ID46156")
            game:oninterval(function()
                game:scriptcall("_ID50343", "_ID46156")
            end, 500)
        end, 4000)
    end
end

map.main = function()
    game:setdvar("start", "snowmobile")
    mainhook.invoke(level)
    game:ontimeout(function()
        -- trigger that makes a part of the map render
        game:getentbynum(1973):notify("trigger")
        game:musicstop()
        intro()
    end, 0)
end

return map
