local map = require("maps/so_snowrace1_cliffhanger")

local timelimits = {
    15,
	15,
	10,
	8
}

local timelimit = timelimits[game:getdvarint("g_gameskill") + 1] or 15

map.localizedname = "Time Trial"
game:addlocalizedstring("SPECIAL_OPS_CLIFFHANGER", "Time Trial")

local premain = map.premain
map.premain = function()
    settimerlabel("Finish in: ")
    premain()

    game:precachemodel("h2_ch_square_flag_fast")

    local flagtime = 4
    if (game:getdvarint("g_gameskill") >= 3) then
        flagtime = 3
    end

	local stop = false
	level:onnotifyonce("special_op_terminated", function()
		stop = true
	end)

	local flagtriggers = game:getentarray("flag_trigger", "targetname")
	for i = 1, #flagtriggers do
		local flags = game:getentarray(flagtriggers[i].target, "targetname")
		for o = 1, #flags do
			local angles = flags[o].angles
			if (angles.x == 0) then
				angles = angles + vector:new(0, -90, 0)
			else
				angles = angles + vector:new(39, -90, 35)
			end

			flags[o].angles = angles
			flags[o].origin = flags[o].origin - vector:new(0, 0, 50)
		end

		local listner = nil
		listener = flagtriggers[i]:onnotify("trigger", function(ent)
			if (ent == nil or stop or (ent ~= player and ent ~= getplayervehicle())) then
				return
			end

			for o = 1, #flags do
				flags[o]:delete()
			end

			flagtriggers[i]:delete()
			listener:clear()

			splash("+" .. flagtime .. " Seconds")
			addchallengetimer(challengetimeleft + flagtime)
			startchallengetimer(6, 3)
			player:playlocalsound("snowrace_flag_capture")
		end)
	end
end

map.calculatestars = nil

map.addtimer = function()
    addchallengetimer(timelimit)
end

map.starttimer = function()
    startchallengetimer(6, 3)
end

return map
