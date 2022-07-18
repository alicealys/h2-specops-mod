colors = {
    h2 = {
        yellow = vector:new(0.86, 0.81, 0.34),
        grey = vector:new(0.6, 0.6, 0.6)
    },
    red = {
        color = vector:new(1, 0.4, 0.4),
        glowcolor = vector:new(0.7, 0.2, 0.2)
    },
    yellow = {
        color = vector:new(1, 1, 0.5),
        glowcolor = vector:new(0.7, 0.7, 0.2)
    },
    green = {
        color = vector:new(0.8, 1, 0.8),
        glowcolor = vector:new(0.301961, 0.6, 0.301961)
    },
    blue = {
        color = vector:new(0.8, 0.8, 1),
        glowcolor = vector:new(0.301961, 0.301961, 0.6)
    },
    white = {
        color = vector:new(1, 1, 1),
        glowcolor = vector:new(0, 0, 0)
    }
}

function entity:setblue()
    self.color = colors.blue.color
    self.glowcolor = colors.blue.glowcolor
    self.glowalpha = 0.1
end

function entity:setred()
    self.color = colors.red.color
    self.glowcolor = colors.red.glowcolor
    self.glowalpha = 0.1
end

function entity:setyellow()
    self.color = colors.yellow.color
    self.glowcolor = colors.yellow.glowcolor
    self.glowalpha = 0.1
end

function entity:setgreen()
    self.color = colors.green.color
    self.glowcolor = colors.green.glowcolor
    self.glowalpha = 0.1
end

function entity:setwhite()
    self.color = colors.white.color
    self.glowcolor = colors.white.glowcolor
    self.glowalpha = 0.1
end

local huditems = {}
function createhuditem(line, xoffset, message, always_draw)
	line = line + 2

	local hudelem = game:newhudelem()
	hudelem.alignx = "right"
	hudelem.aligny = "middle"
	hudelem.horzalign = "right"
	hudelem.vertalign = "middle"
	hudelem.x = xoffset
    hudelem.font = "bank"
	hudelem.y = -92 + (15 * line)
	hudelem.foreground = 1
	hudelem.fontscale = 1.3
	hudelem.hidewheninmenu = true
	hudelem.hidewhendead = true
	hudelem.sort = 2
	hudelem:setwhite()

	if (message) then
		hudelem.label = message
    end

    table.insert(huditems, hudelem)

	return hudelem
end

local istimetrial = false
local timerlabel = "Time: "
local timerlabelempty = "Time: -:--.-"

function addchallengetimer(timelimit)
    if (challengetimer) then
        challengetimer:destroy_()
    end

    if (timelimit) then
        challengetimer = createhuditem(1, -178, timerlabel)
        challengetimer.timelimit = timelimit
        challengetimer:settenthstimerstatic(timelimit)
    else
        challengetimer = createhuditem(1, -178, timerlabelempty)
    end

    challengetimer.alignx = "left"
end

local challengetimerlistener = nil
challengetimeleft = 0
function startchallengetimer(nudgetime, hurrytime)
    nudgetime = nudgetime or 30
    hurrytime = hurrytime or 10

    if (not challengetimer) then
        addchallengetimer()
    end

    if (challengetimerlistener) then
        challengetimerlistener:clear()
    end

    challengetimeleft = 0
    challengetimer.label = timerlabel
    challengetimer:setwhite()

    player:playsoundasmaster("arcademode_zerodeaths")

    if (challengetimer.timelimit) then
        challengetimer:settenthstimer(challengetimer.timelimit)
        challengetimeleft = challengetimer.timelimit
        local changecolor = function()
            if (ismissionover) then
                challengetimerlistener:clear()
                return
            end

            if (challengetimeleft <= 0) then
                missionover(false)
                challengetimerlistener:clear()
                return
            end

            challengetimeleft = challengetimeleft - 1

            if (challengetimeleft <= nudgetime and challengetimeleft > hurrytime) then
                challengetimer:setyellow()
            end

            if (challengetimeleft <= hurrytime) then
                challengetimer:setred()
            end
        end

        changecolor()
        challengetimerlistener = game:oninterval(changecolor, 1000)
    else
        challengetimer:settenthstimerup(0)
    end
end

function enablechallengetimer(notifystart, notifyend)
    addchallengetimer()
    level:onnotifyonce(notifystart, function()
        starttime = game:gettime()
        startchallengetimer()
    end)

    level:onnotifyonce(notifyend, function()
        missionover(true)
    end)
end

local challengestarsoffset = {x = 0, y = 0}

function setchallengestaroffset(x, y)
    challengestarsoffset = {x = x, y = y}
end

function addchallengestars()
    if (challengestars) then
        for i = 1, #challengestars do
            challengestars[i]:destroy_()
        end
    end

    challengestars = {}

    local function createstar()
        local star = createhuditem(3 + challengestarsoffset.y, challengestarsoffset.x + -116 + 22 * #challengestars)
        star.color = colors.yellow.color
        star:setshader("star", 22, 20)
        return star
    end

    table.insert(challengestars, createstar())
    table.insert(challengestars, createstar())
    table.insert(challengestars, createstar())
end

function removechallengestar(index)
    challengestars[#challengestars - index + 1].removed = true
    challengestars[#challengestars - index + 1].alpha = 0
end

local startimer = nil
function startchallengestars(times)
    if (not challengestars) then
        addchallengestars()
    end

    if (starttimer) then
        starttimer:clear()
    end

    local interval = 500

    for i = 1, #times do
        times[i] = times[i] * 2
    end

    local step = 1
    local secs = 0
    starttimer = game:oninterval(function()
        if (ismissionover) then
            starttimer:clear()
            return
        end

        if (times[step] < 0) then
            starttimer:clear()
            return
        end

        local diff = times[step] - secs
        if (diff <= 10 and diff > 1 and step <= #times) then
            local show = diff % 2 ~= 0
            if (not challengestars[step].removed) then
                if (show) then
                    challengestars[step].alpha = 1
                else
                    challengestars[step].alpha = 0.5
                end
            end
        elseif (diff <= 1 and step <= #times) then
            challengestars[step].alpha = 0
            step = step + 1

            if (step > #times) then
                missionover(false)
                starttimer:clear()
            end
        end

        secs = secs + 1
    end, interval)
end

function setchallengetimes(star1, star2, star3)
    challengetimes = {star1, star2, star3}
end

function settimetrial(value)
    istimetrial = value
end

function settimerlabel(label)
    timerlabel = label
end

local failonmissionover = true
function setfailonmissionover(value)
    failonmissionover = value
end

game:detour("_ID42407", "_ID23778", function()
    if (failonmissionover) then
        missionover(false)
    else
        game:setsaveddvar("hud_missionFailed", 0)
        game:setsaveddvar("hud_showstance", 1)
        game:setsaveddvar("actionSlotsHide", 0)
        game:setsaveddvar("ui_hideCompassTicker", 0)
        game:setsaveddvar("ammoCounterHide", 0)
    end
end)

local doingsplash = false
local splashqueue = {}
local splashnum = 0
local function splashinternal(text, color)
    if (doingsplash) then
        return
    end

    doingsplash = true

    if (not splashtext) then
        splashtext = game:newhudelem()
        splashtext.horzalign = "center"
        splashtext.alignx = "center"
        splashtext.y = 180
        splashtext.font = "bank"
        splashtext.fontscale = 2
        splashtext.hidewhendead = true
        splashtext.hidewheninmenu = true
    end

    splashtext:fadeovertime(0)
    splashtext:settext(text)
    splashtext.alpha = 1

    if (not color or color == "yellow") then
        splashtext:setyellow()
    elseif (color == "red") then
        splashtext:setred()
    elseif (color == "green") then
        splashtext:setgreen()
    elseif (color == "white") then
        splashtext:setwhite()
    end

    game:ontimeout(function()
        splashtext:fadeovertime(1)
        splashtext.alpha = 0
        game:ontimeout(function()
            doingsplash = false
        end, 1000)
    end, 100)
end

function entity:destroy_()
    if (not self.destroyed) then
        local value = pcall(function()
            self:destroy()
        end)
 
        if (not value) then
            print("Failed to destroy hudelem")
        end

        self.destroyed = true
    end
end

local splashinterval = nil
function addsplash(text, color)
    table.insert(splashqueue, {
        text = text,
        color = color
    })

    if (splashinterval) then
        return
    end

    splashinterval = game:oninterval(function()
        if (doingsplash or #splashqueue == 0) then
            return
        end

        local splash = splashqueue[1]
        table.remove(splashqueue, 1)

        splashinternal(splash.text, splash.color)
    end, 0)
end

function splash(text)
    addsplash(text, "yellow")
end

function redsplash(text)
    addsplash(text, "red")
end

function pingescapewarning()
    if (not escapewarningsplash) then
        escapewarningsplash = game:newhudelem()
        escapewarningsplash.alignx = "center"
        escapewarningsplash.horzalign = "center"
        escapewarningsplash.y = 220
        escapewarningsplash.font = "bank"
        escapewarningsplash.fontscale = 1.5
        escapewarningsplash.faded = 1
        escapewarningsplash:settext("Turn back and continue the mission!")
        escapewarningsplash:setwhite()
    end

    if (escapewarningsplash.faded == 0) then
        return
    end

    escapewarningsplash.faded = 0
    escapewarningsplash.alpha = 1
    escapewarningsplash:fadeovertime(1)
    escapewarningsplash.alpha = 0.5
    game:ontimeout(function()
        if (escapewarningsplash) then
            escapewarningsplash.faded = 1
        end
    end, 1000)
end

function enableescapewarning()
	local escapewarningtriggers = game:getentarray( "player_trying_to_escape", "script_noteworthy" )
    local escapeinterval = game:oninterval(function()
        local istouching = false
        for i = 1, #escapewarningtriggers do
            local trigger = escapewarningtriggers[i]
            istouching = istouching or (player:istouching(trigger) == 1)
        end

        if (istouching) then
            pingescapewarning()
        elseif (escapewarningsplash ~= nil) then
            escapewarningsplash.alpha = 0
            escapewarningsplash:fadeovertime(0.25)
        end
    end, 0)

    level:onnotifyonce("special_op_terminated", function()
        if (escapewarningsplash) then
            escapewarningsplash:destroy_()
            escapewarningsplash = nil
            escapeinterval:clear()
        end
    end)
end

function enablefailonescape()
    level:onnotifyonce("player_has_escaped", function()
        missionover(false)
    end)
end

function enableescapefailure()
    enablefailonescape()
end

function setplayerpos()
    local start = game:getent("info_player_start_so", "classname")
    if (start) then
        player:setorigin(start.origin)
        player:setplayerangles(start.angles)
    end
end

player:onnotify("death", function()
    missionover(false)
end)

game:scriptcall("_ID42237", "_ID14402", "disable_autosaves") -- _utility::flag_set
level:onnotify("can_save", function()
    game:scriptcall("_ID42237", "_ID14402", "disable_autosaves") -- _utility::flag_set
    game:scriptcall("_ID42237", "_ID14388", "can_save") -- _utility::flag_clear
end)

ismissionover = false
local playerkills = 0
function missionover(success, timeoverride)
    if (ismissionover) then
        return
    end

    level:notify("special_op_terminated")

    if (map.preover) then
        map.preover()
    end

    if (challengetimer) then
        challengetimer.alpha = 0
        challengetimer:destroy_()
        challengetimer = nil
    end

    for i = 1, #huditems do
        huditems[i]:destroy_()
    end

    huditems = {}
    if (splashinterval) then
        splashinterval:clear()
    end

    ismissionover = true

    game:ontimeout(function()
        game:setblur(6, 1)
    end, 100)

    game:ambientstop(2)
    game:musicstop(true)

    player:allowjump(false)
    player:disableweapons()
    player:disableusability()
    player:enableinvulnerability()

    game:ontimeout(function()
        local text = game:newhudelem()
        text.font = "bank"
        text.glowalpha = 0.3

        if (success) then
            text.color = vector:new(0.8, 0.8, 1)
            text.glowcolor = vector:new(0.301961, 0.301961, 0.6)
            text:settext("Mission Success!")
            player:playlocalsound("h1_arcademode_mission_success")
        else
            text.hidwhendead = false
            text.color = vector:new(1, 0.4, 0.4)
            text.glowcolor = vector:new(0.7, 0.2, 0.2)
            text:settext("Mission Failed!")
        end

        text.horzalign = "center"
        text.alignx = "center"
        text.fontscale = 1.2
        text.y = 220
        text:setpulsefx(60, 2500, 500)
    end, 0)

    local finaltime = 0
    if (not success and istimetrial) then
        finaltime = -1
        game:setdvar("so_mission_time", -1)
    else
        if (timeoverride) then
            finaltime = timeoverride
            game:setdvar("so_mission_time", timeoverride)
        else
            local time = game:gettime()
            if (starttime) then
                local total = time - starttime
                finaltime = total
                game:setdvar("so_mission_time", total)
            else
                game:setdvar("so_mission_time", 0)
            end
        end
    end

    game:setdvar("ui_so_new_besttime", 0)
    game:setdvar("ui_so_new_stars", 0)
    game:setdvar("aa_player_kills", playerkills)

    if (success and finaltime >= 0) then
        local mapname = game:getdvar("so_mapname")
        local stats = sostats.getmapstats(mapname)
        local nobest = stats.besttime == nil or type(stats.besttime) ~= "number"
        if (nobest or stats.besttime > finaltime) then
            if (not nobest) then
                game:setdvar("ui_so_new_besttime", 1)
            end
            stats.besttime = finaltime
        end
    
        local stars = type(map.calculatestars) == "function" and map.calculatestars(finaltime) or game:getdvarint("g_gameskill")
        local nostars = stats.stars == nil or type(stats.stars) ~= "number"
        if (nostars or stats.stars < stars) then
            game:setdvar("ui_so_prev_stars", nostars and 0 or stats.stars)
            game:setdvar("ui_so_new_stars", stars)
            stats.stars = stars
        end

        sostats.setmapstats(mapname, stats)
    end

    player.ignoreme = true

    game:ontimeout(function()
        local dogs = game:getentarray("actor_enemy_dog", "classname")
        for i = 1, #dogs do
            dogs[i]:delete()
        end
    
        local ai = game:getaiarray()
        for i = 1, #ai do
            ai[i]:delete()
        end
    
        local spawners = game:getspawnerarray()
        for i = 1, #spawners do
            spawners[i]:delete()
        end    

        player:freezecontrols(true)
        game:executecommand("lui_open so_eog_summary")
        game:setdvar("ui_so_mission_status", success and 1 or 2)

        game:setsaveddvar("hud_showstance", 0)
        game:setsaveddvar("actionSlotsHide", 1)
        game:setsaveddvar("ui_hideCompassTicker", 1)
        game:setsaveddvar("ammoCounterHide", 1)
    end, 3000)
end

function flaginit(flag)
    game:scriptcall("_ID42237", "_ID14400", flag)
end

function flag(flag)
    return game:scriptcall("_ID42237", "_ID14385", flag) == 1
end

function flagset(flag)
    game:scriptcall("_ID42237", "_ID14402", flag)
end

function flagclear(flag)
    game:scriptcall("_ID42237", "_ID14388", flag)
end

local spawnfuncs = {axis = {}, allies = {}, neutral = {}, team3 = {}}
function addspawnfunc(team, callback)
    table.insert(spawnfuncs[team], callback)
end

function arrayspawnfunc(array_, func)
    for i = 1, #array_ do
        array_[i]:onnotify("spawned", func)
    end
end

function arrayspawnfuncnoteworthy(name, func)
    local arr = game:getentarray(name, "script_noteworthy")
    arrayspawnfunc(arr, func)
end

game:ontimeout(function()
    local spawners = game:getspawnerarray()
    for i = 1, #spawners do
        spawners[i]:onnotify("spawned", function(ai)
            local funcs = spawnfuncs[ai.team]
            if (type(funcs) == "table") then
                for o = 1, #funcs do
                    funcs[o](ai)
                end
            end

            ai:onnotifyonce("death", function(attacker)
                if (attacker == player) then
                    if (ai.team == "axis") then
                        playerkills = playerkills + 1
                        player:notify("enemy_killed")
                    end

                    if (ai.team == "neutral") then
                        player:notify("civilian_killed")
                    end
                end
            end)
        end)
    end
end, 0)

function musicloop(music)
    game:scriptcall("maps/_utility", "_ID24577", music)
end

function entity:spawnai()
    if (self._ID31214) then
        return self:stalingradspawn()
    else
        return self:dospawn()
    end
end

function cointoss()
    return game:scriptcall("common_scripts/utility", "_ID8201") == 1
end

function getstruct(value, field)
    return game:scriptcall("common_scripts/utility", "_ID16638", value, field)
end

function getstructarray(value, field)
    return game:scriptcall("common_scripts/utility", "_ID16640", value, field)
end

function isspawner(ent)
    if (ent.code_classname == nil) then
        return false
    end
		
    return game:issubstr(ent.code_classname, "actor_") == 1
end

function isvehicle(ent)
    if (ent.code_classname == nil) then
        return false
    end

    return game:issubstr(ent.code_classname, "script_vehicle") == 1
end

function isspawntrigger(ent)
	if (ent.classname == "trigger_multiple_spawn") then
        return true
    end

	if (ent.classname == "trigger_multiple_spawn_reinforcement") then
        return true
    end

    if (ent.classname == "trigger_multiple_friendly_respawn") then
        return true
    end

    if (ent.targetname == "flood_spawner") then
        return true
    end

    if (ent.targetname == "friendly_respawn_trigger") then
        return true
    end

    if (ent.spawnflags & 32 ~= 0) then
        return true
    end

	return false
end

function radiodialogue(sound)
    game:scriptcall("_ID42407", "_ID28864", sound)
end

function aideletewhenoutofsight(arr, dist)
    game:scriptcall("maps/_utility", "_ID2265", arr, dist)
end

function battlechatteron(team)
    game:scriptcall("_ID42407", "_ID4918", team)
end

function addstart(name, func)
    game:scriptcall("maps/_utility", "_ID1951", name, func)
end

function defaultstart(func)
    game:scriptcall("maps/_utility", "_ID10126", func)
end

function arraydelete(arr)
    for i = 1, #arr do
        arr[i]:delete()
    end
end

function deletenonspecialops(types)
    local ents = game:getentarray()

    local candelete = function(ent)
        return ent.code_classname and ent.script_specialops ~= 1 and ent.targetname ~= "intelligence_item"
    end

    local trydelete = function(ent)
        if (not candelete(ent)) then
            return
        end

        for i = 1, #types do
            if (types[i](ent)) then
                ent:delete()
                return
            end
        end
    end

    for i = 1, #ents do
        local ent = ents[i]
        trydelete(ent)
    end
end

function foreach(arr, func)
    for i = 1, #arr do
        func(arr[i])
    end
end

function array:foreach(func)
    for i = 1, #self do
        func(self[i], i)
    end
end

function enableallportalgroups()
    local portals = game:getentarray("portal_group", "classname")
    portals:foreach(function(portal)
        game:enablepg(portal.targetname, 1)
    end)
end

function shuffle(array)
    local out = {}

    for i = 1, #array do
        local offset = i - 1
        local value = array[i]
        local randomindex = offset * math.random()
        local flooredindex = randomindex - randomindex % 1

        if (flooredindex == offset) then
            out[#out + 1] = value
        else
            out[#out + 1] = out[flooredindex + 1]
            out[flooredindex + 1] = value
        end
    end

    return out
end

math.randomseed(os.time())
