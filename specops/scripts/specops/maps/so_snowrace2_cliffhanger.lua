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

    local flagtriggers = {
        vector:new(-14491, -35777, -513),
		vector:new(-18089, -37086, -1488),
		vector:new(-24761, -36037, -2655),
		vector:new(-20977, -36901, -2020),
		vector:new(-26421, -33245, -3541),
		vector:new(-27164, -29289, -4109),
		vector:new(-24066, -34131, -2655),
		vector:new(-28806, -29463, -3918),
		vector:new(-26184, -26151, -5060),
		vector:new(-25667, -21629, -5163),
		vector:new(-28029, -19577, -4695),
		vector:new(-31154, -16169, -4078),
		vector:new(-35772, -14191, -4263),
		vector:new(-38793, -13841, -4263),
		vector:new(-47914, -12608, -4263),
		vector:new(-53853, -14182, -4263),
		vector:new(-56971, -11872, -4147),
		vector:new(-58191, -7667, -2924),
		vector:new(-58477, -3580, -6064),
		vector:new(-58258, -93, -8620),
		vector:new(-58625, 3525, -11006),
		vector:new(-58454, 15811, -19968),
		vector:new(-58432, 21205, -23567),
		vector:new(-58603, 25948, -25757),
		vector:new(-43119, -12631, -4263),
		vector:new(-45495, -13489, -4263),
		vector:new(-51510, -12885, -4263),
		vector:new(-58251, 6943, -13684),
		vector:new(-58904, 11754, -17009),
    }

    local flags = {
		{origin = vector:new(-14593.6, -35629.9, -541.4), angles = vector:new(0, 35, 0)},
		{origin = vector:new(-14388.3, -35923.2, -526.4), angles = vector:new(0, 35, 0)},
		{origin = vector:new(-18094.1, -36907.1, -1521.9), angles = vector:new(0, 1.89965, 0)},
		{origin = vector:new(-18082.3, -37264.9, -1549.4), angles = vector:new(0, 1.89965, 0)},
		{origin = vector:new(-24679.3, -35878, -2717.6), angles = vector:new(0, 332.5, 0)},
		{origin = vector:new(-24844.7, -36195.5, -2717.1), angles = vector:new(0, 332.5, 0)},
		{origin = vector:new(-20959.3, -36722.6, -2064.2), angles = vector:new(0, 354.6, 0)},
		{origin = vector:new(-20993.1, -37078.9, -2062.1), angles = vector:new(0, 354.6, 0)},
		{origin = vector:new(-26251.7, -33187.9, -3590.8), angles = vector:new(0, 288.7, 0)},
		{origin = vector:new(-26590.7, -33302.5, -3616.2), angles = vector:new(0, 288.7, 0)},
		{origin = vector:new(-26986.5, -29316.4, -4153.3), angles = vector:new(0, 260.9, 0)},
		{origin = vector:new(-27339.9, -29259.7, -4165), angles = vector:new(0, 260.9, 0)},
		{origin = vector:new(-23984.3, -33972, -2721), angles = vector:new(0, 332.5, 0)},
		{origin = vector:new(-24149.7, -34289.5, -2706.4), angles = vector:new(0, 332.5, 0)},
		{origin = vector:new(-28627, -29472.5, -4005.4), angles = vector:new(0, 266.3, 0)},
		{origin = vector:new(-28984.2, -29449.3, -3993.3), angles = vector:new(0, 266.3, 0)},
		{origin = vector:new(-26011.3, -26199.2, -5140.1), angles = vector:new(0, 253.6, 0)},
		{origin = vector:new(-26354.7, -26098, -5114.1), angles = vector:new(0, 253.6, 0)},
		{origin = vector:new(-25501.7, -21564.1, -5161.9), angles = vector:new(0, 291.3, 0)},
		{origin = vector:new(-25835.3, -21694.1, -5233.2), angles = vector:new(0, 291.3, 0)},
		{origin = vector:new(-27993.9, -19402.1, -4771.1), angles = vector:new(0, 347.9, 0)},
		{origin = vector:new(-28069, -19752.2, -4711.2), angles = vector:new(0, 347.9, 0)},
		{origin = vector:new(-31070.2, -16012.1, -4161.9), angles = vector:new(0, 331.3, 0)},
		{origin = vector:new(-31242.2, -16326.2, -4150), angles = vector:new(0, 331.3, 0)},
		{origin = vector:new(-35688.2, -14034.1, -4352), angles = vector:new(0, 331.3, 0)},
		{origin = vector:new(-35860.2, -14348.2, -4352), angles = vector:new(0, 331.3, 0)},
		{origin = vector:new(-38799.9, -13662.7, -4352), angles = vector:new(0, 2.59999, 0)},
		{origin = vector:new(-38783.7, -14020.5, -4352), angles = vector:new(0, 2.59999, 0)},
		{origin = vector:new(-47893.8, -12429.8, -4352), angles = vector:new(0, 352.6, 0)},
		{origin = vector:new(-47939.9, -12785, -4352), angles = vector:new(0, 352.6, 0)},
		{origin = vector:new(-53894.1, -14008.5, -4352), angles = vector:new(0, 12.6, 0)},
		{origin = vector:new(-53815.9, -14358.1, -4352), angles = vector:new(0, 12.6, 0)},
		{origin = vector:new(-56796.3, -11832.3, -4250), angles = vector:new(0, 282.2, 0)},
		{origin = vector:new(-57146.5, -11908.1, -4265.4), angles = vector:new(0, 282.2, 0)},
		{origin = vector:new(-58010.8, -7666.5, -3006.4), angles = vector:new(0, 269.6, 0)},
		{origin = vector:new(-58369.1, -7664.1, -3004.4), angles = vector:new(0, 269.6, 0)},
		{origin = vector:new(-58296.8, -3679.5, -6055.9), angles = vector:new(321.752, 269.352, 0.400886)},
		{origin = vector:new(-58655.1, -3677.1, -6057.8), angles = vector:new(321.752, 269.352, 0.400886)},
		{origin = vector:new(-58077.8, -210.5, -8765.9), angles = vector:new(321.752, 269.352, 0.400886)},
		{origin = vector:new(-58436.1, -208.1, -8767.8), angles = vector:new(321.752, 269.352, 0.400886)},
		{origin = vector:new(-58444.8, 3389.5, -11117.9), angles = vector:new(321.752, 269.352, 0.400886)},
		{origin = vector:new(-58803.1, 3391.9, -11119.8), angles = vector:new(321.752, 269.352, 0.400886)},
		{origin = vector:new(-58273.8, 15656.5, -20107.9), angles = vector:new(321.752, 269.352, 0.400886)},
		{origin = vector:new(-58632.1, 15658.9, -20109.8), angles = vector:new(321.752, 269.352, 0.400886)},
		{origin = vector:new(-58249.8, 21045.5, -23971.9), angles = vector:new(321.752, 269.352, 0.400886)},
		{origin = vector:new(-58608.1, 21047.9, -23973.8), angles = vector:new(321.752, 269.352, 0.400886)},
		{origin = vector:new(-58422.8, 25889.5, -25804.4), angles = vector:new(0, 268.843, 0)},
		{origin = vector:new(-58781.1, 25891.9, -25791.4), angles = vector:new(0, 266.358, 0)},
		{origin = vector:new(-43121.9, -12452, -4352), angles = vector:new(0, 1.29999, 0)},
		{origin = vector:new(-43113.8, -12810, -4352), angles = vector:new(0, 1.29999, 0)},
		{origin = vector:new(-45503.9, -13310.7, -4352), angles = vector:new(0, 2.59999, 0)},
		{origin = vector:new(-45487.7, -13668.5, -4352), angles = vector:new(0, 2.59999, 0)},
		{origin = vector:new(-51555.9, -12713.2, -4352), angles = vector:new(0, 14.6, 0)},
		{origin = vector:new(-51465.7, -13059.9, -4352), angles = vector:new(0, 14.6, 0)},
		{origin = vector:new(-58070.8, 6847.5, -13711.9), angles = vector:new(321.752, 269.352, 0.400886)},
		{origin = vector:new(-58429.1, 6849.9, -13713.8), angles = vector:new(321.752, 269.352, 0.400886)},
		{origin = vector:new(-58723.8, 11610.5, -17168.9), angles = vector:new(321.752, 269.352, 0.400886)},
		{origin = vector:new(-59082.1, 11612.9, -17170.8), angles = vector:new(321.752, 269.352, 0.400886)},
    }

    game:precachemodel("h2_ch_square_flag_fast")

    local flagtime = 4
    if (game:getdvarint("g_gameskill") >= 3) then
        flagtime = 3
    end

    local flagtimetext = game:newhudelem()
    flagtimetext:setyellow()
    flagtimetext.horzalign = "center"
    flagtimetext.alignx = "center"
    flagtimetext.y = 180
    flagtimetext.fontscale = 2

    for i = 1, #flags do
        local model = game:spawn("script_model", flags[i].origin - vector:new(0, 0, 50))
        local angles = flags[i].angles
        if (angles.x == 0) then
            angles = angles + vector:new(0, -90, 0)
        else
            angles = angles + vector:new(39, -90, 25)
        end

        model.angles = angles
        model:setmodel("h2_ch_square_flag_fast")
        flags[i].model = model

        if ((i - 1) % 2 == 0) then
            local a = flags[i].origin
            local b = flags[i + 1].origin
            local slope = (a.y - b.y) / (a.x - b.x)
            
            local interval = nil
            local index = i
            interval = game:oninterval(function()
                if (ismissionover) then
                    interval:clear()
                    return
                end

                local pos = player.origin
                local zdiff = math.abs(pos.z - a.z)
                local distance = math.sqrt(((-slope * a.x + a.y) + slope * pos.x - pos.y) ^ 2 / (slope ^ 2 + 1))

                -- project player pos on line between 2 flags
                local slope2 = -1 / slope
                local px = ((-slope * a.x + a.y) - (-slope2 * pos.x + pos.y)) / (slope2 - slope)
                local py = slope * px + (-slope * a.x + a.y)
                local p = vector:new(px, py, a.z - 50)

                -- distancet = sum of distance of project from a and b
                local distancea = math.sqrt((p.x - a.x) ^ 2 + (p.y - a.y) ^ 2)
                local distanceb = math.sqrt((p.x - b.x) ^ 2 + (p.y - b.y) ^ 2)
                -- length = distance between flag a & b
                local length = math.sqrt(((b.x - a.x) ^ 2 + (b.y - a.y) ^ 2))
                local distancet = distancea + distanceb
                local isbetween = distancet - 20 <= length

                if (zdiff < 200 and distance < 50 and isbetween) then
                    interval:clear()

                    flagtimetext.fontscale = 2
                    flagtimetext.alpha = 1
                    flagtimetext.font = "bank"
                    flagtimetext:settext("+" .. flagtime .. " Seconds")
                    flagtimetext:fadeovertime(1)
                    flagtimetext.alpha = 0

                    addchallengetimer(challengetimeleft + flagtime)
                    startchallengetimer(6, 3)
                    player:playlocalsound("snowrace_flag_capture")

                    flags[index].model:delete()
                    flags[index + 1].model:delete()
                end
            end, 0)
        end
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
