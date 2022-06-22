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

	return hudelem
end

function formattime(msec)

end

function addchallengetimer(timelimit)
    if (challengetimer) then
        challengetimer:destroy()
    end

    if (timelimit) then
        challengetimer = createhuditem(1, -178, "Time: ")
        challengetimer.timelimit = timelimit
        challengetimer:settenthstimerstatic(timelimit)
    else
        challengetimer = createhuditem(1, -178, "Time: -:--.-")
    end

    challengetimer.alignx = "left"
end

local challengetimerlistener = nil
function startchallengetimer(timelimit, nudgetime, hurrytime)
    nudgetime = nudgetime or 30
    hurrytime = hurrytime or 10

    if (not challengetimer) then
        addchallengetimer()
    end

    if (challengetimerlistener) then
        challengetimerlistener:clear()
    end

    challengetimer.label = "Time: "

    if (challengetimer.timelimit) then
        challengetimer:settenthstimer(challengetimer.timelimit)
        local timeleft = challengetimer.timelimit
        challengetimerlistener = game:oninterval(function()
            if (ismissionover) then
                challengetimerlistener:clear()
                return
            end

            timeleft = timeleft - 1
            if (timeleft <= 0) then
                missionover(false)
                challengetimerlistener:clear()
                return
            end

            if (timeleft <= nudgetime and timeleft > hurrytime) then
                challengetimer:setyellow()
            end

            if (timeleft <= hurrytime) then
                challengetimer:setred()
            end
        end, 1000)
    else
        challengetimer:settenthstimerup(0)
    end
end

function addchallengestars()
    if (challengestars) then
        for i = 1, #challengestars do
            challengestars[i]:destroy()
        end
    end

    challengestars = {}

    local function createstar()
        local star = createhuditem(3, -116 + 22 * #challengestars)
        star.color = colors.yellow.color
        star:setshader("star", 22, 20)
        return star
    end

    table.insert(challengestars, createstar())
    table.insert(challengestars, createstar())
    table.insert(challengestars, createstar())
end

local startimer = nil
function starchallengestars(times)
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

        local diff = times[step] - secs
        if (diff <= 10 and diff > 1 and step <= #times) then
            local show = diff % 2 ~= 0
            if (show) then
                challengestars[step].alpha = 1
            else
                challengestars[step].alpha = 0.5
            end
        elseif (diff <= 1 and step <= #times) then
            challengestars[step].alpha = 0
            step = step + 1

            if (step > #times) then
                missionover(false, -1)
                starttimer:clear()
            end
        end

        secs = secs + 1
    end, interval)
end

function setchallengetimes(star1, star2, star3)
    challengetimes = {star1, star2, star3}
end

game:detour("_ID42407", "_ID23778", function()
    missionover(false)
end)

player:onnotify("death", function()
    missionover(false, challengestars and -1 or nil)
end)

game:scriptcall("_ID42237", "_ID14402", "disable_autosaves") -- _utility::flag_set
level:onnotify("can_save", function()
    game:scriptcall("_ID42237", "_ID14402", "disable_autosaves") -- _utility::flag_set
    game:scriptcall("_ID42237", "_ID14388", "can_save") -- _utility::flag_clear
end)

ismissionover = false
function missionover(success, timeoverride)
    if (challengetimer) then
        challengetimer:destroy()
        challengetimer = nil
    end

    if (challengestars) then
        for i = 1, #challengestars do
            challengestars[i]:destroy()
        end
        challengestars = nil
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

    local finaltime = 0
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

    game:setdvar("ui_so_besttime", 0)
    game:setdvar("ui_so_new_star", 0)

    if (finaltime >= 0) then
        local mapname = game:getdvar("so_mapname")
        local stats = sostats.getmapstats(mapname)
        if (stats.besttime == nil or type(stats.besttime) ~= "number" or stats.besttime > finaltime) then
            stats.besttime = finaltime
            game:setdvar("ui_so_besttime", 1)
        end
    
        local stars = type(map.calculatestars) == "function" and map.calculatestars(finaltime) or game:getdvarint("g_gameskill")
        if (stats.stars == nil or type(stats.stars) ~= "number" or stats.stars < stars) then
            stats.stars = stars
            game:setdvar("ui_so_new_star", 1)
        end

        sostats.setmapstats(mapname, stats)
    end

    local ai = game:getaiarray()
    for i = 1, #ai do
        ai[i]:delete()
    end

    local spawners = game:getspawnerarray()
    for i = 1, #spawners do
        spawners[i]:delete()
    end

    game:ontimeout(function()
        player:freezecontrols(true)
        game:executecommand("lui_open so_eog_summary")
        game:setdvar("ui_so_mission_status", success and 1 or 2)

        game:setsaveddvar("hud_showstance", 0)
        game:setsaveddvar("actionSlotsHide", 1)
        game:setsaveddvar("ui_hideCompassTicker", 1)
        game:setsaveddvar("ammoCounterHide", 1)
    end, 3000)
end
