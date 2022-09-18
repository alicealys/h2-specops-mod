local map = {}

map.premain = function()
    setloadout("barrett", "deserteagle", "fraggrenade", "flash_grenade", "viewhands_arctic", "american")
end

function transformvehiclebytargetname(veh, vehiclename, targetnamestring, targetstring)
    local result = veh.targetname == vehiclename
    if (result) then
        veh.targetname = targetnamestring
        veh.target = targetstring
    end

    return result
end

function isvehiclespecial(ent)
    if (ent.code_classname == "script_vehicle_collmap") then
        return false
    end

    local specialcase1 = not transformvehiclebytargetname(ent, "base_troop_transport2", "truck_1", "truck_1_guys")
    local specialcase2 = not transformvehiclebytargetname(ent, "base_troop_transport1", "truck_2", "truck_2_guys")
    local specialcase3 = not transformvehiclebytargetname(ent, "base_truck1", "jeep_1", "jeep_1_guys")
    local specialcase4 = not transformvehiclebytargetname(ent, "second_uav", "second_uav", "uav_path")

    local originalcase = isvehicle(ent)
    local specialresult = specialcase1 and specialcase2 and specialcase3 and specialcase4
    local result = specialresult and originalcase

    return result
end

function initwave(wavenum, count)
    local struct = {}
    struct.hostilecount = count
    struct.vehicles = {}

    wavespawnstructs[wavenum] = struct
end

function addwavevehicle(wavenum, targetname, type_, altnode, delay)
    if (wavespawnstructs[wavenum] == nil) then
        initwave(wavenum, nil)
    end

    local struct = {}
    struct.targetname = targetname
    struct.ent = game:getent(targetname, "targetname")
    struct.type = type_
    struct.delay = delay
    struct.altnode = altnode

    table.insert(wavespawnstructs[wavenum].vehicles, struct)
end

function setupregular()
    initwave(1, 15)
    
    initwave(2, 17)
    addwavevehicle(2, "jeep_1", "uaz")

    initwave(3, 19)
    addwavevehicle(3, "truck_1", "bm21")

    challengeobjective = "&SO_ROOFTOP_CONTINGENCY_OBJ_REGULAR"
    hostileaccuracy = 1
    wipedoutrequirement = 2
    wavedelay = 10
    alloweduavammo = 5
    uavspawndelay = 15
    uavpickuprespawn = false
end

function setuphardened()
    initwave(1, 15)
    
    initwave(2, 16)
    addwavevehicle(2, "jeep_1", "uaz")

    initwave(3, 17)
    addwavevehicle(3, "truck_1", "bm21")

    initwave(4, 18)
    addwavevehicle(4, "jeep_1", "uaz", game:getvehiclenode("jeep_1_guys_alt", "targetname"))

    challengeobjective = "&SO_ROOFTOP_CONTINGENCY_OBJ_HARDENED"
    hostileaccuracy = 1
    wipedoutrequirement = 3
    wavedelay = 10
    alloweduavammo = 4
    uavspawndelay = 15
    uavpickuprespawn = false
end

function setupveteran()
    initwave(1, 15)

    initwave(2, 16)
    addwavevehicle(2, "jeep_1", "uaz")

    initwave(3, 17)
    addwavevehicle(3, "truck_1", "bm21")

    initwave(4, 20)
    addwavevehicle(4, "jeep_1", "uaz", game:getvehiclenode("jeep_1_guys_alt", "targetname"), 0)

    initwave(5, 20)
    addwavevehicle(5, "truck_2", "bm21", nil, 1)
    addwavevehicle(4, "jeep_1", "uaz", game:getvehiclenode("jeep_1_guys_alt2", "targetname"), 0)

    challengeobjective = "&SO_ROOFTOP_CONTINGENCY_OBJ_VETERAN"
    hostileaccuracy = 1
    wipedoutrequirement = 3
    wavedelay = 10
    alloweduavammo = 3
    uavspawndelay = 20
    uavpickuprespawn = false
end

function spawnersetup()
    for i = 1, #wavespawnstructs do
        local newarray = array:new()
        local waveguys = game:getentarray("wave_guys", "script_noteworthy")

        for o = 1, #waveguys do
            newarray:push(waveguys[o])
            if (#newarray >= wavespawnstructs[i].hostilecount) then
                break
            end
        end

        wavespawnstructs[i].spawners = newarray:randomize()
    end

    local failsafespawners = game:getentarray("failsafe_spawners", "targetname")
    failsafespawners:foreach(function(spawner)
        spawner.script_noteworthy = "wave_guys"
    end)
end

function waveclosingin(ai, startwith)
    if (game:isalive(ai) == 0) then
        return
    end

    ai:notify("wave_closing_in_called")
    game:ontimeout(function()
        waveclosingininternal(ai, startwith)
    end, 0)
end

function waveclosingininternal(ai, startwith)
    local stop = false
    ai:onnotifyonce("wave_closing_in_called", function()
        stop = true
    end)

    ai:onnotifyonce("death", function()
        stop = true
    end)

    local f1 = function()
        if (stop) then
            return
        end

        local fardelay = 0
        local meddelay = game:randomfloatrange(15, 20)
        local closedelay = game:randomfloatrange(30, 35)
        local playerdelay = game:randomfloatrange(15, 25)
        local factor = (100 - ((currentwave - 1) * 10)) / 100 * rooffactor

        if (ai.classname ~= "actor_enemy_arctic_SNIPER") then
            factor = factor * 0.75
        end

        if (ai.classname == "actor_enemy_arctic_SHOTGUN") then
            factor = factor * 0.25
        end

        local end1 = function()
            if (stop) then
                return
            end

            wavegotoplayer(ai, factor * playerdelay)
        end

        if (startwith ~= nil and startwith ~= "attack_line_far") then
            if (startwith == "attack_line_med") then
                waveclosinginatline(ai, factor * meddelay, "attack_line_med", end1)
            else
                waveclosinginatline(ai, factor * closedelay, "attack_line_close", end1)
            end
        else
            waveclosinginatline(ai, factor * fardelay, "attack_line_far", function()
                if (stop) then
                    return
                end

                waveclosinginatline(ai, factor * meddelay, "attack_line_med", function()
                    if (stop) then
                        return
                    end

                    waveclosinginatline(ai, factor * closedelay, "attack_line_close", end1)
                end)
            end)
        end
    end

    if (ai.script_noteworthy == "vehicle_guys") then
        ai:onnotifyonce("jumpedout", f1)
    else
        f1()
    end
end

function wavegotoplayer(ai, delay)
    local timeout = nil
    timeout = game:ontimeout(function()
        seekplayer(ai)
    end, ms(delay))
    
    timeout:endon(ai, "death")
    timeout:endon(ai, "wave_closing_in_called")
end

function seekplayer(ai)
    local stop = false

    ai:onnotifyonce("death", function()
        stop = true
    end)

    ai:onnotifyonce("wave_closing_in_called", function()
        stop = true
    end)

    level:onnotifyonce("special_op_terminated", function()
        stop = true
    end)

    ai.goalradius = 2000
    local loop = nil
    loop = function()
        if (stop) then
            return
        end
        
        local goalradius = ai.goalradius
        if (goalradius > 300) then
            goalradius = goalradius - game:randomintrange(200, 600)
        end

        if (goalradius < 300) then
            goalradius = game:randomintrange(250, 500)
        end

        ai.goalradius = goalradius
        ai:setgoalentity(player)
        ai:onnotifyonce("goal", function()
            if (stop) then
                return
            end

            game:ontimeout(loop, ms(game:randomfloatrange(5, 9)))
        end)
    end

    loop()
end

function gethigherpriorityplayer(ai, minweight)
    local combinedweight = 1
    if (minweight < 0) then
        combinedweight = 0
    end

    local playerarray = array:new()
    local players = game:getentarray("player", "classname")

    players:foreach(function(player1)
        if (player1.sopriority > minweight) then
            playerarray:push(player1)
            local priority = player1.sopriority

            local dist2d = game:distance2d(ai.origin, player1.origin)
            priority = priority + 1 - (dist2d / 800)
            if (priority < 0) then
                priority = 0
            end

            combinedweight = combinedweight + priority 
        end
    end)

    local targetent = nil
    if (#playerarray) then
        local randomweight = game:randomfloat(combinedweight)
        local currweight = 0
        playerarray:foreach(function(player1)
            currweight = currweight + player1.sopriority
            if (randomweight < currweight) then
                targetent = player1
            end
        end)
    end

    return targetent
end

function setattackline(ai, lineposition)
    local attackline = game:getentarray(lineposition, "script_noteworthy")
    local toent = attackline[game:randomint(#attackline) + 1]
    attackline:foreach(function(ent)
        if (ent.timesused < toent.timesused) then
            toent = ent
        end
    end)

    ai.goalradius = toent.radius
    ai:scriptcall("maps/_utility", "_ID32336", toent.origin)
    toent.timesused = toent.timesused + 1
end

function waveclosinginatline(ai, delay, attackline, callback)
    local f1 = function()
        local minweight = 0
        if (attackline == "attack_line_far") then
            minweight = 0.75
        elseif (attackline == "attack_line_med") then
            minweight = 0.5
        else
            minweight = 0.25
        end

        local targetent = gethigherpriorityplayer(ai, minweight)
        if (defined(targetent)) then
            seekplayer(ai)
            callback()
        else
            setattackline(ai, attackline)
            ai:onnotifyonce("goal", callback)
        end
    end

    local timeout = game:ontimeout(f1, ms(delay))
    timeout:endon(ai, "death")
    timeout:endon(ai, "wave_closing_in_called")
end

function deaththink(ai)
    ai:onnotifyonceany(function()
        hostilecount = hostilecount - 1
        if (game:isdefined(ai) == 0) then
            return
        end

        local damageweapon = nil
        local attacker = nil

        if (game:isdefined(ai.damageweapon) == 1) then
            damageweapon = ai.damageweapon
        end

        if (game:isdefined(ai.lastattacker) == 1) then
            attacker = ai.lastattacker
        end

        local destructiblekilled = false
        if (game:isdefined(attacker._ID9644) == 1) then
            if (attacker.hellfired == 1) then
                damageweapon = "remote_missile"
            elseif (attacker.claymored == 1) then
                damageweapon = "claymore"
            end

            attacker = attacker._ID9644
            destructiblekilled = true
        end

        if (game:isdefined(attacker) == 0 or game:isplayer(attacker) == 0 or game:isdefined(damageweapon) == 0) then
            return
        end

        if (destructiblekilled) then
            attacker._ID36218["kills"] = attacker._ID36218["kills"] + 1
        end

        if (damageweapon == "claymore") then
            attacker.claymorekills = attacker.claymorekills + 1
        end

        if (damageweapon == "remote_missile") then
            attacker.hellfirekills = attacker.hellfirekills + 1
        end
    end, "death", "pain_death")
end

function spawnfunctions()
    currentwave = 1

    addspawnfunc("axis", function(ai)
        hostilecount = hostilecount + 1
        ai.baseaccuracy = hostileaccuracy

        if (wavespawnstructs[currentwave].wavemembers == nil) then
            wavespawnstructs[currentwave].wavemembers = {}
        end

        table.insert(wavespawnstructs[currentwave].wavemembers, ai)
        
        ai:scriptcall("maps/contingency", "_ID53967")
        deaththink(ai)
    end)

    arrayspawnfuncnoteworthy("wave_guys", waveclosingin)
    arrayspawnfunctargetname("truck_1_guys", waveclosingin, "attack_line_med")
    arrayspawnfunctargetname("truck_2_guys", waveclosingin, "attack_line_med")
    arrayspawnfunctargetname("jeep_1_guys", waveclosingin, "attack_line_close")
    arrayspawnfunctargetname("jeep_1_guys_alt", waveclosingin, "attack_line_close")
    arrayspawnfunctargetname("jeep_1_guys_alt2", waveclosingin, "attack_line_med")

    addsinglespawnfunc(game:getent("truck_1", "targetname"), setupbasevehicles)
    addsinglespawnfunc(game:getent("truck_2", "targetname"), setupbasevehicles)
    addsinglespawnfunc(game:getent("jeep_1", "targetname"), setupbasevehicles)
end

function setupbasevehicles(vehicle)
    if (not vehicle) then
        return
    end

    if (vehicle.setup == 1) then
        return
    end

    vehicle.setup = true
    vehicle:scriptcall("_ID48289", "_ID53152")
    unloadwhenstuck(vehicle)
    vehicle:scriptcall("maps/contingency", "_ID46839")

    vehicle:onnotifyonce("unloaded", function()
        vehicle:vehicle_setspeed(0, 15)
        if (game:isdefined(vehicle._ID49554) == 1) then
            vehicle._ID49554 = nil
            game:target_remove(vehicle)
        end

        level._ID48408 = game:scriptcall("_ID42237", "_ID3321", level._ID48408, vehicle)
    end):endon(vehicle, "death")
end

function unloadwhenstuck(vehicle)
    local interval = nil
    interval = game:oninterval(function()
        if (vehicle:vehicle_getspeed() < 2) then
            vehicle:vehicle_setspeed(0, 15)
            vehicle:scriptcall("_ID42411", "_ID40298")
            vehicle:notify("kill_badplace_forever")
            interval:clear()
        end
    end, 2000)

    interval:endon(vehicle, "unloaded")
    interval:endon(vehicle, "unloading")
    interval:endon(vehicle, "death")
end

function sorooftopinit()
    uavpickedup = false
    hostilecount = 0
    wavespawnstructs = {}

    switch(gameskill, {
        [0] = setupregular,
        [1] = setupregular,
        [2] = setuphardened,
        [3] = setupveteran
    })

    rooffactor = 1
    local allattacklines = game:getentarray("attack_line", "targetname")
    allattacklines:foreach(function(attackline)
        attackline.timesused = 0
    end)

    player.hellfirekills = 0
    player.claymorekills = 0

    spawnersetup()
    spawnfunctions()

    enableescapewarning()
    enableescapefailure()

    game:ontimeout(function()
        wavespawnthink()
    end, 4000)

    playeronroofthink()
    wavewipedout()
    uavpickupsetup()
    uav()

    threatpriority()

    game:objective_add(1, "current", challengeobjective)
end

function playeronroofthink()
    local waittillroof = nil
    waittillroof = function()
        level:onnotifyonce("player_on_roof", function()
            local guys = game:getaiarray("axis")

            if (flag("player_on_roof")) then
                guys:foreach(function(guy)
                    rooffactor = 1
                    guy.baseaccuracy = hostileaccuracy
                end)

                setgrenadefrequency(1)
            else
                guys:foreach(function(guy)
                    rooffactor = 0.7
                    guy.baseaccuracy = 2
                end)

                setgrenadefrequency(0.5)
            end
        end)

        game:ontimeout(waittillroof, 2000)
    end

    waittillroof()
end

function setgrenadefrequency(fraction)
    fraction = fraction or 1

    game:scriptcall("_ID42298", "_ID1889", "playerGrenadeBaseTime", 0.25, 40000 * fraction)
    game:scriptcall("_ID42298", "_ID1889", "playerGrenadeBaseTime", 0.75, 35000 * fraction)
    level._ID10851["playerGrenadeBaseTime"]["hardened"] = 25000 * fraction
	level._ID10851["playerGrenadeBaseTime"]["veteran"] = 25000 * fraction

    game:scriptcall("_ID42298", "_ID39716")
    game:scriptcall("_ID42298", "_ID39669")
end

function threatpriority()
    local roofpoint = getstruct("so_roof_point", "targetname")
    local interval = game:oninterval(function()
        local weight = 0
        local dist = game:distance(roofpoint, player.origin)
        if (dist > 400) then
            weight = dist / 2000
        end

        player.sopriority = weight
    end, 1000)

    interval:endon(player, "death")
end

function hudhostilecount()
    local hudelemtitle = createhuditem(2, hudxpos(), "&SO_ROOFTOP_CONTINGENCY_HOSTILES")
    local hudelemcount = createhuditem(2, hudxpos(), "&SPECIAL_OPS_DASHDASH")
    hudelemcount.alignx = "left"

    flagwait("waves_start", function()
        local maxcount = hostilecount

        local loop1 = nil
        loop1 = function()
            if (flag("challenge_success")) then
                hudelemcount:destroy_()
                hudelemtitle:destroy_()
                return
            end

            dialoguecounterupdate(hostilecount, maxcount)
            local currcount = hostilecount
            hudelemcount.label = ""
            hudelemcount:setvalue(hostilecount)

            if (currcount <= 0) then
                hudelemcount:settext("&SPECIAL_OPS_DASHDASH")
            elseif (currcount <= 5) then
                hudelemcount:setgreen()
                hudelemtitle:setgreen()
            elseif (currcount > 5) then
                hudelemcount:setwhite()
                hudelemtitle:setwhite()
            end

            local loop2 = nil
            loop2 = function()
                if (flag("challenge_success") or currcount ~= hostilecount) then
                    loop1()
                    return
                end

                game:ontimeout(function()
                    if (hostilecount > currcount) then
                        maxcount = hostilecount
                        progressgoalstatus = "none"
                    end

                    loop2()
                end, 0)
            end

            loop2()
        end

        loop1()
    end)
end

function hudwavenum()
    local listener = nil
    listener = level:onnotify("new_wave_started", function()
        game:ontimeout(function()
            local hud = nil
            local hudcount = nil
            if (currentwave < #wavespawnstructs) then
                hud = createhuditem(0, hudxpos(), "&SPECIAL_OPS_WAVENUM")
                hudcount = createhuditem(0, hudxpos())
                hudcount.alignx = "left"
                hudcount:setvalue(currentwave)
            else
                hud = createhuditem(0, hudxpos(), "&SPECIAL_OPS_WAVEFINAL")
                hud.alignx = "center"
            end

            musicloop("mus_contingency_base_arrival", 291)
            flagwait("wave_wiped_out", function()
                game:musicstop(1)
                hud:destroy_()

                if (defined(hudcount)) then
                    hudcount:destroy_()
                end
            end)
        end, 1000)
    end)
end

function spawnvehicleandgo(struct)
    local spawner = struct.ent

    local f1 = function()
        if (struct.altnode) then
            local targetname = struct.altnode.targetname
            spawner.target = targetname
        end

        local vehicle = spawner:scriptcall("maps/_utility", "_ID35192")

        if (not vehicle) then
            return
        end
        
        vehicle:startpath()
    end

    if (struct.delay) then
        game:ontimeout(f1, ms(struct.delay))
    else
        f1()
    end
end

function hudnewwave(callback)
    currentwave = currentwave + 1
    if (currentwave > #wavespawnstructs) then
        return
    end

    local wavemsg = "&SO_ROOFTOP_CONTINGENCY_WAVE_STARTS"
    local wavedelaylocal = 0.75

    if (currentwave == #wavespawnstructs) then
        wavemsg = "&SO_ROOFTOP_CONTINGENCY_WAVE_FINAL_STARTS"
    else
        if (currentwave == 2) then
            wavemsg = "&SO_ROOFTOP_CONTINGENCY_WAVE_SECOND_STARTS"
        end

        if (currentwave == 3) then
            wavemsg = "&SO_ROOFTOP_CONTINGENCY_WAVE_THIRD_STARTS"
        end

        if (currentwave == 4) then
            wavemsg = "&SO_ROOFTOP_CONTINGENCY_WAVE_FOURTH_STARTS"
        end
    end

    enablecountdowntimer(wavedelay, false, wavemsg, wavedelaylocal)
    game:ontimeout(function()
        hudwavesplash(currentwave, wavedelay - 2, callback)
    end, 2000)
end

function wavespawnthink()
    hudhostilecount()
    hudwavenum()

    flagwait("waves_start", function()
        local iter = nil
        local waveindex = 0
        iter = function()
            waveindex = waveindex + 1
            if (waveindex > #wavespawnstructs) then
                return
            end

            flagclear("wave_wiped_out")
            currentwave = waveindex

            local spawnfailedcount = 0

            local o = 0
            local iter2 = nil

            local f1 = function()
                local vehicles = wavespawnstructs[waveindex].vehicles
                for j = 1, #vehicles do
                    spawnvehicleandgo(vehicles[j])
                end

                flagset("wave_" .. currentwave .. "_started")
                level:notify("new_wave_started")

                if (game:isdefined(uavplayer) == 1) then
                    level:notify("stop_uav_reload")
                    flagclear("uav_reloading")
    
                    player:scriptcall("_ID50736", "_ID54399", uavpickedup, remotedetonatorweapon)
                    player:scriptcall("_ID50736", "_ID44898")
                end

                game:ontimeout(function()
                    flagset("wave_spawned")
                    flagwait("wave_wiped_out", function()
                        if (flag("special_op_terminated")) then
                            return
                        end

                        if (waveindex == #wavespawnstructs) then
                            flagset("challenge_success")
                            return
                        end

                        if (game:isdefined(uavplayer) == 1) then
                            uavplayer:scriptcall("_ID50736", "_ID50531", uavpickedup, true)
                        end

                        player:notify("force_out_of_uav")
                        hudnewwave(iter)
                    end)
                end, 1000)
            end

            local iter3 = nil
            local q = 0
            local failsafespawners = game:getentarray("failsafe_spawners", "targetname")
            iter3 = function()
                q = q + 1
                if (q > spawnfailedcount) then
                    f1()
                    return
                end

                local spawner = failsafespawners[game:randomint(#failsafespawners) + 1]
                spawner.count = 1
                spawner:spawnai2(nil, function(guy)
                    if (not defined(guy)) then
                        q = q - 1
                    end

                    iter3()
                end)
            end

            iter2 = function()
                o = o + 1
                if (o > #wavespawnstructs[waveindex].spawners) then
                    iter3()
                    return
                end

                local spawner = wavespawnstructs[waveindex].spawners[o]
                spawner.count = 1

                spawner:spawnai2(nil, function(guy)
                    if (not defined(guy)) then
                        spawnfailedcount = spawnfailedcount + 1
                    end

                    iter2()
                end)
            end

            iter2()
        end

        iter()
    end)
end

function wavewipedout()
    flagwait("waves_start", function()
        local loop = nil
        loop = function()
            flagwait("wave_spawned", function()
                local population = 0
                local aiwave = game:getaiarray("axis")
                aiwave:foreach(function(guy)
                    if (game:isalive(aiwave) == 1) then
                        population = population + 1
                    end
                end)
    
                if (population <= wipedoutrequirement) then
                    aiwave:foreach(function(ai)
                        waveclosingin(ai, "attack_line_med")
                    end)
    
                    local f1 = function()
                        flagclear("wave_spawned")
                        flagset("wave_wiped_out")
                        player:playsound("arcademode_kill_streak_won")
                        game:ontimeout(loop, 1000):endon(level, "special_op_terminated")
                    end
    
                    local interval = nil
                    interval = game:oninterval(function()
                        if (hostilecount <= 0) then
                            if (flag("special_op_terminated")) then
                                return
                            end

                            f1()
                            interval:clear()
                        end
                    end, 500)

                    interval:endon(level, "special_op_terminated")
                else
                    game:ontimeout(loop, 1000):endon(level, "special_op_terminated")
                end
            end)
        end

        loop()
    end):endon(level, "special_op_terminated")
end

function getvehicletypecount(wavenum, type_)
    local count = 0

    local vehicles = wavespawnstructs[wavenum].vehicles
    for i = 1, #vehicles do
        if (vehicles[i].type == type_) then
            count = count + 1
        end
    end

    return count
end

function hudgetwavelist(wavenum)
    local list = {}
    list[1] = {}

    if (wavenum < #wavespawnstructs) then
        list[1].text = "&SPECIAL_OPS_INTERMISSION_WAVENUM"
        list[1].count = wavenum
    else
        list[1].text = "&SPECIAL_OPS_INTERMISSION_WAVEFINAL"
    end

    list[2] = {}
    list[2].text = "&SO_ROOFTOP_CONTINGENCY_HOSTILES_COUNT"
    list[2].count = wavespawnstructs[wavenum].hostilecount

    local index = 3
    local uazcount = getvehicletypecount(wavenum, "uaz")
    list[2].count = list[2].count + (uazcount * 4)

    if (uazcount > 0) then
        list[index] = {}
        if (uazcount == 1) then
            list[index].text = "&SO_ROOFTOP_CONTINGENCY_UAZ_COUNT_SINGLE"
        else
            list[index].text = "&SO_ROOFTOP_CONTINGENCY_UAZ_COUNT"
        end

        list[index].count = uazcount
        index = index + 1
    end

    local bm21count = getvehicletypecount(wavenum, "bm21")
    list[2].count = list[2].count + (bm21count * 6)

    if (bm21count > 0) then
        list[index] = {}
        if (bm21count == 1) then
            list[index].text = "&SO_ROOFTOP_CONTINGENCY_BM21_COUNT_SINGLE"
        else
            list[index].text = "&SO_ROOFTOP_CONTINGENCY_BM21_COUNT"
        end

        list[index].count = bm21count
    end

    return list
end

function hudcreatewavesplash(yline, message)
    local hudelem = createhuditem(yline, 0, message)
    hudelem.alignx = "center"
    hudelem.horzalign = "center"

    return hudelem
end
    
function hudwavesplash(wavenum, timer, callback)
    local hudelems = {}
    local list = hudgetwavelist(wavenum)

    local iter = nil
    local i = 0
    iter = function()
        i = i + 1
        if (i > #list) then
            game:ontimeout(function()
                for o = 1, #hudelems do
                    hudelems[o]:destroy()
                end

                callback()
            end, ms(timer - (#list * 1)))
            return
        end

        hudelems[i] = hudcreatewavesplash(i - 1, list[i].text)
        if (list[i].count ~= nil) then
            hudelems[i]:setvalue(list[i].count)
        end

        hudelems[i]:setpulsefx(60, ((timer - 1) * 1000) - ((i - 1) * 1000), 1000)
        game:ontimeout(iter, 1000)
    end

    iter()
end

function startsorooftop()
    sorooftopinit()

    game:ontimeout(function()
        radiodialogue("so_roof_cont_def_pos")
    end, 1000)

    game:visionsetnaked("contingency", 0)

    setplayerpos()

    game:ontimeout(function()
        enablecountdowntimer(10)
        enablechallengetimer("waves_start", "challenge_success", nil, true)
        flagset("start_countdown")

        game:ontimeout(function()
            hudwavesplash(1, wavedelay - 2, function()
                flagset("waves_start")
            end)
        end, 2000)
    end, 4000)
end

function waittopickupuav(callback)
    if (gameskill < 2) then
        level:onnotifyonce("start_countdown", callback)
    else
        level:onnotifyonce("wave_wiped_out", callback)
    end
end

function uavpickupsetup()
    local uavpickup = game:getent("uav_controller", "targetname")
    uavpickup:hide()

    waittopickupuav(function()
        pickupuavreminder()

        game:ontimeout(function()
            local wait = nil
            wait = function()
                uavpickup:show()
                uavpickup:makeusable()
                uavpickup:sethintstring("&SO_ROOFTOP_CONTINGENCY_DRONE_PICKUP")
        
                uavpickup:onnotifyonce("trigger", function()
                    uavpickup:playsound("detpack_pickup")
                    uavpickedup = true
                    uavplayer = player
        
                    flagset("uav_in_use")
        
                    player:scriptcall("_ID50736", "_ID44738", remotedetonatorweapon)
        
                    if ((gameskill > 1 and not flag("wave_2_started") or not flag("wave_1_started"))) then
                        uavplayer:scriptcall("_ID50736", "_ID50531", false, true)
                    end

                    uavpickup:makeunusable()
                    uavpickup:hide()

                    displayedhints = displayedhints or false
                    if (not displayedhints) then
                        local f1 = function()
                            displayedhints = true
                            local slot = player:scriptcall("_ID50736", "_ID48383")
                            if (defined(slot)) then
                                player:displayhint("hint_predator_drone_" .. slot)
                            else
                                player:displayhint("hint_predator_drone_4")
                            end
                        end

                        if (gameskill > 1 and not flag("wave_2_started")) then
                            flagwait("wave_2_started", f1)
                        elseif (not flag("wave_1_started")) then
                            flagwait("wave_1_started", f1)
                        else
                            f1()
                        end
                    end
                end)

                flagwaitopen("uav_in_use", function()
                    game:ontimeout(wait, 2000 + ms(uavspawndelay))
                end)
            end
        
            game:ontimeout(wait, 2000)
        end, 1000)
    end)
end

function pickupuavreminder()
    local stop = false
    level:onnotifyonce("uav_in_use", function()
        stop = true
    end)

    local loop = nil
    loop = function()
        if (flag("special_op_terminated") or stop) then
            return
        end

        radiodialogue("cont_pri_controluav")
        game:ontimeout(loop, ms(game:randomfloatrange(15, 20)))
    end

    game:ontimeout(loop, ms(game:randomfloatrange(15, 20)))
end

function uav()
    waittopickupuav(function()
        radiodialogue("cont_cmt_almostinpos")
        level._ID49526 = game:scriptcall("_ID42411", "_ID35196", "second_uav")
        level._ID49526:playloopsound("uav_engine_loop")
        level._ID39406 = game:spawn("script_model", level._ID49526.origin)
        level._ID39406:setmodel("tag_origin")
        uavrigaiming()
    end)
end

function uavrigaiming()
    if (game:isalive(level._ID49526) == 0) then
        return
    end

    if (defined(level._ID45535)) then
        return
    end

    local focuspoints = game:getentarray("uav_focus_point", "targetname")
    local interval = game:oninterval(function()
        local closestfocus = getclosest(player.origin, focuspoints)
        local targetpos = closestfocus.origin
        local angles = game:vectortoangles(targetpos - level._ID39406.origin)
        level._ID39406:moveto(level._ID49526.origin, 0.10, 0, 0)
        level._ID39406:rotateto(angles, 0.10, 0, 0)
    end, 0)

    interval:endon(level, "uav_destroyed")
    interval:endon(level._ID49526, "death")
end

function destructibledamagemonitor(ent)
    ent:onnotify("damage", function(dmg, attacker, dir, point, mod, model, tagname, partname, dflags, weapon)
        if (game:isplayer(attacker) == 0 or weapon == nil) then
            return
        end

        if (weapon == "remote_missile") then
            ent.hellfired = true
        elseif (weapon == "claymore") then
            ent.claymored = true
        end
    end):endon(ent, "exploded")
end

function uavvision()
    player:onnotify("exiting_uav_control", function()
        game:visionsetnaked("contingency")
        game:enablepg("base_middle", 1)
        game:enablepg("base_entrance", 1)
        game:enablepg("base_end", 1)
        game:enablepg("portal_group_base_building_33", 1)
        level:notify("draw_target_end")
    end)
end

map.preover = function()
    local standardkills = player._ID36218["kills"]
    standardkills = standardkills - player.hellfirekills
    standardkills = standardkills - player.claymorekills

    game:sharedset("eog_extra_data", json.encode({
        hidekills = true,
        stats = {
            {
                name = "@SO_ROOFTOP_CONTINGENCY_STANDARD_KILLS",
                value = standardkills
            },
            {
                name = "@SO_ROOFTOP_CONTINGENCY_HELLFIRE_KILLS",
                value = player.hellfirekills
            },
            {
                name = "@SO_ROOFTOP_CONTINGENCY_CLAYMORE_KILLS",
                value = player.claymorekills
            }
        }
    }))
end

map.main = function()
    setcompassdist("far")

    game:setsaveddvar("sm_sunShadowScale", 0.5)
	game:setsaveddvar("r_lightGridEnableTweaks", 1)
	game:setsaveddvar("r_lightGridIntensity", 1.5)
	game:setsaveddvar("r_lightGridContrast", 0)

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

    game:scriptcall("_ID42411", "_ID52468", "script_vehicle_uaz_winter_physics", functionptr:new("_ID51074", "_ID32550"), functionptr:new("maps/contingency", "_ID44501"))

    game:scriptcall("maps/_load", "main")

    game:scriptcall("_ID42323", "_ID32417", "viewhands_player_arctic_wind")
    game:scriptcall("_ID42272", "_ID33575", "compass_map_contingency")

    enableallportalgroups(0)
    game:enablepg("base_middle", 1)
    game:enablepg("base_entrance", 1)
    game:enablepg("base_end", 1)
    game:enablepg("portal_group_base_building_33", 1)
    uavvision()

    deletenonspecialops({
        isvehiclespecial,
        isspawner,
        isspawntrigger
    })

    defaultstart(startsorooftop)
    addstart("start_so_rooftop", startsorooftop)

    remotedetonatorweapon = "remote_missile_detonator"

    game:precacheitem(remotedetonatorweapon)
    game:scriptcall("_ID50736", "init")
    game:scriptcall("_ID50736", "_ID51835")

    local vehicles = game:getentarray("destructible_vehicle", "targetname")
    vehicles:foreach(function(vehicle)
        destructibledamagemonitor(vehicle)
    end)
end

return map
