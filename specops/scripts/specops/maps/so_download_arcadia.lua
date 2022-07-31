local map = {}

map.premain = function()
    -- introscreen
    game:detour("_ID42318", "main", function() end)
end

function arcadiaprecache()
    game:setsaveddvar("r_outdoorfeather", 64)
    game:precachestring("&ARCADIA_OBJECTIVE_AA_GUNS")
    game:precachestring("&ARCADIA_OBJECTIVE_BROOKMERE")
    game:precachestring("&ARCADIA_OBJECTIVE_INTEL")
    game:precachestring("&ARCADIA_LASER_HINT")
    game:precachestring("&ARCADIA_LASER_HINT_GOLFCOURSE")
    game:precachestring("&ARCADIA_PICK_UP_BRIEFCASE_HINT")
    game:precachestring("&ARCADIA_PICK_UP_BRIEFCASE_HINT_PC")
    game:precachestring("&ARCADIA_OBJECTIVE_LOCATE_AA_GUNS")
    game:precachestring("&ARCADIA_OBJECTIVE_NEUTRALIZE_AA_GUNS")
    game:precachestring("&ARCADIA_OBJECTIVE_EXTRACT_VIP")
    game:_func_260("arcadia")
    game:_func_260("arcadia_nvg_laser")
    game:precacheshader("dpad_laser_designator")
    game:precacheshader("black")
    game:precachemodel("vehicle_zpu4_burn")
    game:precachemodel("cs_vodkabottle01")
    game:precachemodel("electronics_camera_pointandshoot_animated")
    game:precachemodel("com_metal_briefcase_opened_obj")
    game:precacherumble("arcadia_artillery_rumble")
    game:precacherumble("grenade_rumble")
    game:setdynamicdvar("arcadia_debug_stryker", "0")
    game:precacheitem("rpg_straight")
    game:precacheitem("usp_laserdesignator")
end

function startsodownloadarcadia()
	DOWNLOAD_TIME = 60				-- how long it takes to download the files at each spot
	DOWNLOAD_INTERRUPT_RADIUS = 256	-- how close to the download an enemy has to be to "interrupt" it
	NEARBY_CHARGE_RADIUS = 1000		-- radius around the download from which we'll pull existing enemies to charge the download spot
	NUM_ENEMIES_LEFT_TOLERANCE = 0	-- how many guys we will tolerate still being alive in a wave before it's done
	NUM_FILES_MIN = 900
	NUM_FILES_MAX = 2400
    HUD_TEXT_SCALE = 0.6

    setplayerpos()

    enablechallengetimer("start_challenge", "stryker_extraction_done")

    sodownloadobjectiveinit(0, "&SO_DOWNLOAD_ARCADIA_OBJ_REGULAR")
    strykerthink()
    sodownloadarcadiaintrodialogue()
end

function strykerthink()
    local stryker = game:scriptcall("maps/_vehicle", "_ID35195", "stryker")
    level._ID51107 = stryker

    local org = game:spawn("script_origin", stryker.origin)
    org:linkto(stryker)
    org.animname = "foley"
    
    game:createthreatbiasgroup("stryker")
    game:createthreatbiasgroup("stryker_ignoreme")
    stryker.threatbiasgroup = "stryker"
    game:setignoremegroup("stryker_ignoreme", "stryker")

    stryker.target = "stryker_pathstart"
    local pathstart = game:getvehiclenode(stryker.target, "targetname")
    stryker:attachpath(pathstart)

    stryker.veh_pathtype = "follow"
    stryker:vehphys_disablecrashing()
    stryker:scriptcall("maps/_vehicle", "_ID16988")
    stryker:setvehiclelookattext("Honey Badger", "&")

    player._ID29480 = 4
    lasertargetingdevice()

    stryker._ID53781 = stryker
    stryker:scriptcall("maps/arcadia_stryker", "_ID51150")
    stryker:scriptcall("maps/arcadia_stryker", "_ID48063")
    strykerlaserreminderdialogue(stryker)

    strykergreenlightenemiesinsuppressionzone(stryker)
    strykerdisablelaserreminderthread(stryker)

    local trig = game:getent("trig_bridge_end", "targetname")
    local listener = nil
    listener = trig:onnotify("trigger", function(ent)
        if (game:isplayer(ent) == 0) then
            return
        end

        listener:clear()
        stryker:startpath()
        local firstmovenode = game:getvehiclenode("vnode_bridge", "script_noteworthy")
        strykermovetonode(stryker, firstmovenode, false)

        strykermovewithplayers(stryker)
        strykerextraction(stryker)
    end)
end

function strykerextraction(stryker)
    level:onnotifyonce("all_downloads_finished", function()
        game:ontimeout(function()
            local node = game:getvehiclenode("vnode_house1", "script_noteworthy")
            strykermovetonode(stryker, node)
    
            local strykerobjidx = downloadobjectiveidx + 1
            game:objective_add(strykerobjidx, "current", "&SO_DOWNLOAD_ARCADIA_OBJ_EXTRACT", stryker.origin)
            game:objective_onentity(strykerobjidx, stryker)
    
            strykerextractionenemies()
    
            local interval = nil
            interval = game:oninterval(function()
                if (game:distance(player.origin, stryker.origin) > 280) then
                    return
                end
    
                interval:clear()
                flagset("stryker_extraction_done")
                level:notify("golf_course_mansion")
            end, 0)
        end, 0)
    end)
end

function strykerextractionenemies()
    local org = player.origin
    local spawners = game:getspawnerteamarray("axis")
    spawners = game:scriptcall("_ID42237", "_ID15566", org, spawners)

    local arr = array:new()
    for i = 1, #spawners do
        local spawner = spawners[i]
        if (i > 15) then
            break
        end

        spawner.count = 3
        arr:push(spawner)
    end

    arr:foreach(strykerextractionspawnenemy)
end

function strykerextractionspawnenemy(spawner)
    game:ontimeout(function()
        local guy = spawner:spawnai()
        spawnfailed(guy, function(result)
            if (result == true) then
                return 
            end

            guy:setthreatbiasgroup("axis")
            guy:setgoalpos(level._ID51107.origin)
        end)
    end, math.floor(game:randomfloat(10) * 1000))
end

function strykerdisablelaserreminderthread()
    game:oninterval(function()
        local count = #game:getaiarray("axis")
        if (count == 0) then
            flagset("no_living_enemies")
        else
            flagclear("no_living_enemies")
        end
    end, 500)
end

STRYKER_SUPPRESSION_RADIUS = 1500 * 1500

function strykergreenlightenemiesinsuppressionzone(stryker)
    local f1 = nil
    f1 = function()
        if (self._ID53756 == nil) then
            game:ontimeout(f1, 100)
            return
        end

        local axis = game:getaiarray("axis")
        for i = 1, #axis do
            local guy = axis[i]
            if (game:isalive(guy) == 1 and game:distancesquared(guy.origin, stryker._ID53756) <= STRYKER_SUPPRESSION_RADIUS) then
                if (guy:getthreatbiasgroup() == "stryker_ignoreme") then
                    stryker:setthreatbiasgroup("axis")
                    strykerenemyresettoignore(stryker, guy)
                end
            end
        end

        game:ontimeout(f1, 250)
    end
end

function strykerenemyresettoignore(stryker, guy)
    local interval = game:oninterval(function()
        if (self._ID53756 ~= nil) then
            return
        end

        interval:clear()
        if (game:isalive(guy) == 1) then
            guy:setthreatbiasgroup("stryker_ignoreme")
        end
    end, 100)

    interval:endon(guy, "death")
end

function strykermovewithplayers(stryker)
	local trig1 = game:getent("trig_stryker_house1", "targetname")
	local node1 = game:getvehiclenode("vnode_house1", "script_noteworthy")
	local trig2 = game:getent("trig_stryker_house2", "targetname")
	local node2 = game:getvehiclenode( "vnode_house2", "script_noteworthy")
	local trig3 = game:getent("trig_stryker_house3", "targetname")
	local node3 = game:getvehiclenode("vnode_house3", "script_noteworthy")

    local trigs = {trig1, trig2, trig3}
    local nodes = {node1, node2, node3}

    local timeintrig = 5
    local currnode = nil

    local done = false
    level:onnotifyonce("all_downloads_finished", function()
        done = true
    end)

    local f1 = nil
    f1 = function()
        if (done) then
            return
        end

        local activetrigindex = nil

        local f3 = nil
        f3 = function()
            if (done) then
                return
            end

            game:ontimeout(f1, 500)

            if (activetrigindex == nil) then
                return
            end

            local thenode = nodes[activetrigindex]
            if (currnode == nil or currnode ~= thenode) then
                currnode = thenode
                strykermovetonode(stryker, thenode)
            end
        end

        local i = 0
        local iter = nil
        iter = function()
            if (done) then
                return
            end

            i = i + 1

            if (i > #trigs) then
                f3()
                return
            end

            local trig = trigs[i]
            if (player:istouching(trig) == 0) then
                iter()
                return
            end

            local endtime = game:gettime() + math.floor(timeintrig * 1000)

            local f2 = nil
            f2 = function()
                if (done) then
                    return
                end

                if (game:gettime() >= endtime) then
                    activetrigindex = i
                    f3()
                else
                    iter()
                end
            end
            
            local interval = nil
            interval = game:oninterval(function()
                if (done) then
                    interval:clear()
                    return
                end

                if (game:gettime() >= endtime or player:istouching(trig) == 0) then
                    f2()
                    interval:clear()
                end
            end, 100)
        end

        iter()
    end

    f1()
end

function strykermovetonode(stryker, node, dodialogue)
    local goalradius = 130

    if (node.origin.x < stryker.origin.x) then
        stryker.veh_pathdir = "reverse"
        stryker.veh_transmission = "reverse"
        stryker._ID41729 = 0
    else
        stryker.veh_pathdir = "forward"
        stryker.veh_transmission = "forward"
        stryker._ID41729 = 1
    end
    
    if (dodialogue == nil or dodialogue == true) then
        stryker:notify("resuming_speed")
    end

    stryker:vehiclesetspeedwrapper(10, 5)

    local interval = nil
    interval = game:oninterval(function()
        if (game:distance(stryker.origin, node.origin) > goalradius) then
            return
        end

        interval:clear()
        stryker:vehiclesetspeedwrapper(0, 5)

        if (dodialogue == nil or dodialogue == true) then
            stryker:notify("wait for gate")
        end
    end, 0)
end

function entity:vehiclesetspeedwrapper(speed, rate, msg)
    if (self:vehicle_getspeed() == 0 and speed == 0) then
        return
    end
    
    self:vehicle_setspeed(speed, rate)
end
    
function lasertargetingdevice()
    player._ID22029 = nil
    player._ID21752 = false

    player:setweaponhudiconoverride("actionslot4", "dpad_laser_designator")
    player:notifyonplayercommand("use_laser", "+actionslot 4")

    if (player:scriptcall("_ID42407", "_ID13023", "disable_stryker_laser") == 0) then
        player:scriptcall("_ID42407", "_ID13024", "disable_stryker_laser")
    end

    player:onnotify("use_laser", function()
        if (player._ID21752 == 1) then
            player:notify("cancel_laser")
            player:laseroff()
            player._ID21752 = false
            game:ontimeout(function()
                player:allowfire(true)
            end, 200)
        else
            player:laseron("arcadia")
            player:allowfire(false)
            player._ID21752 = true
            laserdesignatetarget()
        end
    end):endon(player, "remove_laser_targeting_device")
end

function laserdesignatetarget()
    if (game:scriptcall("_ID42237", "_ID14385", "used_laser")) then
        game:scriptcall("_ID42237", "_ID14402", "used_laser")
        game:scriptcall("_ID42407", "_ID11085", "use_laser_attack")
    end

    player:onnotifyonce("fired_laser", function()
        local trace = player:scriptcall("maps/arcadia_code", "_ID15795")
        local pos = trace["position"]
        local ent = trace["entity"]

        level:notify("laser_coordinates_received")
        if (not flag("disable_stryker_laser") and not player:entflag("disable_stryker_laser") and game:isalive(level._ID51107) == 1) then
            local d = game:distance(level._ID51107.origin, pos)
            local inrange = d >= 200 and d <= 3500

            game:scriptcall("maps/arcadia_code", "_ID45433", inrange, pos, entity)
            if (inrange) then
                level._ID51107:scriptcall("maps/arcadia_stryker", "_ID49367", pos)
            end
        end

        game:ontimeout(function()
            player:notify("use_laser")
        end, 500)
    end):endon(player, "cancel_laser")
end

function entity:laserinput()
    self:notifyonplayercommand("use_laser", "+actionslot 4")
    self:notifyonplayercommand("fired_laser", "+attack")

    if (flag("used_laser")) then
        self:entflagset("used_laser1")
        self:entflagset("used_laser2")
    end

    self:onnotifyonceany(function()
        self:entflagset("used_laser1")

        if (flag("used_laser")) then
            self:entflagset("used_laser1")
            self:entflagset("used_laser2")
        end

        self:onnotifyonceany(function()
            self:entflagset("used_laser2")
        end, "fired_laser", "used_laser")
    end, "use_laser", "used_laser")
end

function strykerlaserreminderdialogprethink(stryker)
    stryker:onnotifyonce("laser_coordinates_received", function()
        game:ontimeout(function()
            stryker:scriptcall("maps/arcadia_stryker", "_ID45939")
        end, 30000)
    end)
end

function laserhintprint()
    if (game:isalive(player) == 0) then
        return
    end

    player:scriptcall("maps/_utility", "_ID11085", "use_laser1", nil, nil, nil, nil, 3)
    player:onnotifyonce("used_laser1", function()
        game:ontimeout(function()
            player:scriptcall("maps/_utility", "_ID11085", "use_laser2", nil, nil, nil, nil, 3)
        end, 100)
    end)
end

function strykerlaserreminderdialogue(stryker)
    player:laserinput()

    level:onnotifyonce("intro_dialogue_done", function()
        print("here")
        strykerlaserreminderdialogprethink(stryker)

        radiodialogue("so_dwnld_stk_explicitauth")
        laserhintprint()
        stryker:scriptcall("maps/arcadia_code", "_ID49697")

        if (flag("used_laser")) then
            return
        end

        local timeout = game:ontimeout(function()
            local f1 = function()
                -- radiodialogue("so_dwnld_stk_designated")
                local f2 = function()
                    --radiodialogue("so_dwnld_stk_cantfire")
                end

                local timeout = game:ontimeout(function()
                    local interval = nil
                    interval = game:oninterval(function()
                        if (not flag("no_living_enemies")) then
                            f2()
                            interval:clear()
                        end
                    end, 5000)
                end, 45000)

                timeout:endon(level, "used_laser")
                timeout:endon(stryker, "laser_coordinates_received")
            end

            local interval = nil
            interval = game:oninterval(function()
                if (not flag("no_living_enemies")) then
                    f1()
                    interval:clear()
                end
            end, 5000)

            interval:endon(level, "used_laser")
            interval:endon(stryker, "laser_coordinates_received")
        end, 45000)

        timeout:endon(level, "used_laser")
        timeout:endon(stryker, "laser_coordinates_received")
    end)
end

function sodownloadarcadiaintrodialogue()
    game:ontimeout(function()
        radiodialogue("so_dwnld_hqr_laptops")
        radiodialogue("so_dwnld_hqr_downloaddata")

        game:ontimeout(function()
            flagset("intro_dialogue_done")
            musicloop("mus_so_download_arcadia_music", 328)
        end, 9500)
    end, 1000)
end

function sodownloadobjectiveinit(objidx, objstr)
    downloadobjectivestr = objstr
	downloadobjectiveidx = objidx
	downloadscomplete = 0

    downloads = getstructarray("download", "targetname")
	
    for i = 1, #downloads do
        downloads[i].objpos = (i - 1)
    end

    game:objective_add(downloadobjectiveidx, "current", objstr, downloads[1].origin)

    for i = 2, #downloads do
        local download = downloads[i]
        game:objective_additionalposition(downloadobjectiveidx, download.objpos, download.origin)
    end

    player:entflaginit("download_hint_on")
    downloads:foreach(downloadobjsetup)
end

function downloadobjsetup(download)
	local computer = game:spawn("script_model", download.origin)
	computer:setmodel("com_laptop_open")
	computer.angles = download.angles
	
	local dsmspot = getstruct(download.target, "targetname")
	local dsm = game:spawn("script_model", dsmspot.origin)
	dsm:setmodel("com_metal_briefcase_opened")
	dsm.angles = dsmspot.angles
	
	local dsmobj = game:spawn("script_model", dsm.origin)
	dsmobj:setmodel("com_metal_briefcase_opened_obj")
	dsmobj.angles = dsm.angles
	
	dsm:hide()

	download.computer = computer
	download.dsm = dsm
	download.dsmobj = dsmobj
	
	download.trig = game:getent(download.target, "targetname")
    download.trig:sethintstring("&SO_DOWNLOAD_ARCADIA_DSM_USE_HINT")
	
	downloadobjthink(download)
end

function downloadfilesnemeiesattack(download, downloadtime)
    download.spawned = array:new()
    download.totaldefenders = 0

    download.totaldefenders = downloadfilesnearbydefenderscharge(download)
    download.totaldefenders = download.totaldefenders + downloadfilesspawnchargers(download)

    downloadenemiesattackdialogue(download)

    local f1 = nil

    local interval = nil
    interval = game:oninterval(function()
        if (#download.spawned < download.totaldefenders) then
            return
        end

        f1()
        interval:clear()
    end, 0)

    f1 = function()
        waittilldeadordying(download.spawned, (#download.spawned - NUM_ENEMIES_LEFT_TOLERANCE), downloadtime, function()
            download.wavedead = true
        end)
    end
end

function downloadenemiesattackdialogue(download)
    local alias = nil
	local waittime = nil
	local alias2 = nil

    switch(download.script_parameters, {
        ["download_1_charger"] = function()
            alias = "so_dwnld_stk_tenfootmobiles"
        end,
        ["download_2_charger"] = function()
            alias = "so_dwnld_stk_brownmansion"
        end,
        ["download_3_charger"] = function()
            alias = "so_dwnld_stk_acrossstreet"
            waittime = 10
            alias2 = "so_dwnld_stk_gotmovement"
        end
    })

    if (alias ~= nil) then
       -- radiodialogue(alias)
    end

    local playalias2 = function()
        --radiodialogue(alias2)
    end

    if (waittime ~= nil and alias2 ~= nil) then
        game:ontimeout(playalias2, ms(waittime))
    elseif (alias2 ~= nil) then
        playalias2()
    end
end

function downloadfilesnearbydefenderscharge(download)
    local axis = game:getaiarray("axis")
    local close = array:new()

    for i = 1, #axis do
        local guy = axis[i]
        if (game:distance(guy.origin, download.origin) <= NEARBY_CHARGE_RADIUS) then
            close:push(guy)
            download.spawned:push(guy)
        end
    end

    close:foreach(function(guy)
        defenderchargedsm(guy, download)
    end)

    return #close
end

function defenderchargedsm(guy, download)
    local goalent = game:getent(download.script_linkto, "script_linkname")
    guy.goalradius = 1800
    guy:setgoalentity(goalent)
    aidelayedseekthink(guy, download, goalent)
end

function downloadfilesspawnchargers(download)
    local chargers = game:getentarray(download.script_parameters, "targetname")
    chargers = chargers:randomize()
    chargers:foreach(function(charger)
        downloadfilesspawncharger(charger, download)
    end)
    return #chargers
end

function downloadfilesspawncharger(charger, download)
    local f2 = function()
        local guy = charger:spawnai2(nil, function(guy)
            spawnfailed(guy, function(result)
                if (result) then
                    download.totaldefenders = download.totaldefenders - 1
                    return
                end
    
                download.spawned:push(guy)
                defenderchargedsm(guy, download)
            end)
        end)
    end

    local f1 = function()
        game:ontimeout(f2, ms(game:randomfloat(8)))
    end

    if (charger.script_delay ~= nil) then
        game:ontimeout(f1, ms(charger.script_delay))
    else
        f1()
    end
end

function aidelayedseekthink(guy, download, goalent)
    local maxseekers = 3

    local callback = nil
    callback = function()
        if (game:isalive(guy) == 0) then
            interval:clear()
            return
        end

        if (guy.goalradius > 200) then
            guy.goalradius = guy.goalradius - 200
        end

        if (guy.goalradius < 200) then
            guy.goalradius = 200
        end

        local count = 0
        local seekcount = 0
        local ais = game:getaiarray("axis")

        ais:foreach(function(ai)
            if (ai.seekingplayer == player) then
                seekcount = seekcount + 1
            end

            if (ai == guy) then
                return
            end

            if (game:distancesquared(ai.origin, goalent.origin) < 250 * 250) then
                count = count + 1
            end
        end)

        if (count > 2 or download.downloadcomplete == 1) then
            if (guy.seekingplayer == nil) then
                local goalplayer = nil
                if (seekcount < maxseekers) then
                    goalplayer = player
                end

                if (goalplayer ~= nil) then
                    guy.seekingplayer = player
                    guy:setgoalentity(goalplayer)
                    guy.goalradius = 1000
                end
            end

            if (guy.seekplayer == nil) then
                guy.goalradius = 1000
            end
        end

        game:ontimeout(callback, ms(game:randomfloatrange(6, 9))):endon(guy, "death")
    end

    callback()
end

function downloadfileswavedeath(download)
    local interval = nil
    interval = game:oninterval(function()
        if (download.wavedead ~= 0) then
            interval:clear()
            download:notify("download_interrupted")
        end
    end, 0)

    interval:endon(download, "downloading_stopped")
end

function downloadfiles(download, callback)
    local downloadtime = DOWNLOAD_TIME - download.downloadtimeelapsed

    if (not flag("first_download_started")) then
        flagset("first_download_started")

        -- radiodialogue("so_dwnld_hqr_wirelesslydisrupt")
    end

    download.downloading = true
    download:notify("downloading")

    local success = false

    local starttime = game:gettime()
    local endtime = starttime + math.floor(downloadtime * 1000)

    if (download.defendersspawned == nil) then
        download.defendersspawned = true
        download.wavedead = false
        downloadfilesnemeiesattack(download, downloadtime)
    end

    game:ontimeout(function()
        downloadfileswavedeath(download)
    end, 100)
    
    downloadfilescatchinterrupt(download)

    download:entflagclear("download_stopped")

    downloadfileshudcountdown(download, downloadtime, function(newdownloadtime)
        local f1 = function()
            download:notify("downloading_stopped")
            download.downloading = false
            download.downloadtimeelapsed = download.downloadtimeelapsed + ((game:gettime() - starttime) / 1000)

            if (download.wavedead == 1 or game:gettime() >= endtime) then
                success = true
            end

            download:entflagset("download_stopped")
            game:ontimeout(function()
                if (not success) then
                    downloadfileshudcountdownabort(download)
                    downloadinterruptdialogue()
                else
                    downloadfileshudfinish(download)
                end
            end, 0)

            callback(success)
        end

        if (download.wavedead == 1) then
            game:ontimeout(f1, math.floor(newdownloadtime * 1000))
        else
            local listener = download:onnotifyonce("download_interrupted", f1)
            game:ontimeout(function()
                listener:clear(); f1()
            end, math.floor(newdownloadtime * 1000)):endon(download, "download_interrupted")
        end
    end)
end

function downloadfilescatchinterrupt(download)
    local interval = nil
    interval = game:oninterval(function()
        local axis = game:getaiarray("axis")
        for i = 1, #axis do
            local guy = axis[i]
            if (aineardownload(download, guy)) then
                download:notify("download_interrupted")
                break
            end
        end
    end, 2000)

    interval:endon(download, "downloading_stopped")
end

function aineardownload(download, guy)
    local verticaldist = game:abs(guy:gettagorigin("j_spinelower").z - download.origin.z)
    local dist = game:distance(guy.origin, download.origin)

    if (verticaldist > 50) then
        return false
    end

    if (game:distance(guy.origin, download.origin) < DOWNLOAD_INTERRUPT_RADIUS) then
        return true
    end

	return false
end

function downloadinterruptdialogue()

end

function downloadfileshudcountdownabort(download)
	local x = -200
	local hudelem = getcountdownhud(x, download.hudelemy, nil, nil, HUD_TEXT_SCALE)
	hudelem.alignx = "right"
	hudelem.label = "&SO_DOWNLOAD_ARCADIA_DSM_FRAME"
	hudelem:setred()

	local hudelemstatus = getcountdownhud(x, download.hudelemy, nil, nil, HUD_TEXT_SCALE)
	hudelemstatus.label = "&SO_DOWNLOAD_ARCADIA_DOWNLOAD_INTERRUPTED"
	hudelemstatus:setred()

	hudelem:hudblink()
	hudelemstatus:hudblink()

    local destroy = function()
        hudelem:destroy()
        hudelemstatus:destroy()
    end

    local listener = download:onnotifyonce("downloading", destroy)
    game:ontimeout(function()
        listener:clear()
        destroy()
    end, 25000):endon(download, "downloading")
end

function entity:hudblink()
    local fadetime = 0.1
    local statetime = 500

    game:oninterval(function()
        self:fadeovertime(fadetime)
        self.alpha = 1

        game:ontimeout(function()
            self:fadeovertime(fadetime)
            self.alpha = 0
        end, statetime):endon(self, "death")
    end, statetime * 2):endon(self, "death")
end

function downloadfileshudfinish(download)
	local x = -200
	local hudelem = getcountdownhud(x, download.hudelemy, nil, nil, HUD_TEXT_SCALE)
	hudelem.alignx = "right"
	hudelem.label = "&SO_DOWNLOAD_ARCADIA_DSM_FRAME"
	hudelem:setblue()

	local hudelemstatus = getcountdownhud(x, download.hudelemy, nil, nil, HUD_TEXT_SCALE)
	hudelemstatus.label = "&SO_DOWNLOAD_ARCADIA_DOWNLOAD_COMPLETE"
	hudelemstatus:setblue()

	hudelem:hudblink()
	hudelemstatus:hudblink()

    local destroy = function()
        hudelem:destroy()
        hudelemstatus:destroy()
    end

    game:ontimeout(destroy, 10000)
end

function dsmwait(hudelem, time, callback)
    hudelem:setvalue(0)
    game:ontimeout(function()
        local delay = 0.1
        local steps = time / delay

        local i = -1
        local iter = nil
        iter = function()
            i = i + 1
            if (i >= steps) then
                hudelem:setvalue(100)
                game:ontimeout(callback, 500)
                return
            end

            local num = game:clamp(game:int((i / steps) * 100), 0, 100)
            hudelem:setvalue(num)
            game:ontimeout(iter, math.floor(delay * 1000))
        end

        iter()
    end, 1000)
end

function downloadfilesupdate(download, hudelem, hudelemstatus, hudelemstatustotal, timeleft)
    local endtime = game:gettime() + math.floor(timeleft * 1000)
    local filesleft = download.totalfiles - download.filesdone
    local incrementtime = 0.05
    local fileinc = incrementtime / (timeleft / filesleft)

    local interval = nil
    interval = game:oninterval(function()
        if (game:gettime() >= endtime or download:entflag("download_stopped")) then
            if (not download:entflag("download_stopped")) then
                hudelemstatus:setvalue(download.totalfiles)
            end

            hudelem:destroy()
            hudelemstatus:destroy()
            hudelemstatustotal:destroy()
            
            interval:clear()
        else
            download.filesdone = download.filesdone + fileinc
            hudelemstatus:setvalue(game:int(download.filesdone))
        end
    end, 0)
end

function downloadfileshudcountdown(download, timeleft, callback)
    local functionstarttime = game:gettime()
    local x = -200
    local yoffset = 50

    local startdownload = function()
        local x = -250
        local xoffset = x + 170

        local hudelem = getcountdownhud(x, download.hudelemy, nil, nil, HUD_TEXT_SCALE)
        hudelem.label = "&SO_DOWNLOAD_ARCADIA_DSM_PROGRESS"
        hudelem:setpulsefx(30, 900000, 700)

        local hudelemstatus = getcountdownhud(xoffset, download.hudelemy, nil, nil, HUD_TEXT_SCALE, nil, nil, 0)
        hudelemstatus.alignx = "right"
        hudelemstatus:setpulsefx(30, 900000, 700)

        local hudelemstatustotal = getcountdownhud(xoffset, download.hudelemy, nil, nil, HUD_TEXT_SCALE, nil, nil, 0)
        hudelemstatustotal.label = "&SO_DOWNLOAD_ARCADIA_DSM_TOTALFILES"
        hudelemstatustotal:setpulsefx(30, 900000, 700)

        if (download.totalfiles == nil) then
            download.totalfiles = game:randomintrange(NUM_FILES_MIN, NUM_FILES_MAX)
        end

        hudelemstatustotal:setvalue(download.totalfiles)

        timeleft = timeleft - ((game:gettime() - functionstarttime) / 1000)

        if (download.wavedead == 1 and timeleft > 3) then
            timeleft = 3
        end

        downloadfilesupdate(download, hudelem, hudelemstatus, hudelemstatustotal, timeleft)
        callback(timeleft)
    end

    if (huddownloadcount == nil) then
        huddownloadcount = 0
    end

    if (download.firstdownload == 1) then
        local y = yoffset + (huddownloadcount * 20)
        huddownloadcount = huddownloadcount + 1
        download.hudelemy = y

        local hudelem = getcountdownhud(x, download.hudelemy, nil, nil, HUD_TEXT_SCALE)
        hudelem.label = "&SO_DOWNLOAD_ARCADIA_DSM_FRAME"
        hudelem.alignx = "right"
        hudelem:setpulsefx(30, 900000, 700)

        game:ontimeout(function()
            local hudelemstatus = getcountdownhud(x, download.hudelemy, nil, nil, HUD_TEXT_SCALE)
            hudelemstatus:setpulsefx(30, 900000, 700)
            hudelemstatus.label = "&SO_DOWNLOAD_ARCADIA_DSM_INIT"

            dsmwait(hudelemstatus, 2.5, function()
                hudelemstatus:destroy()

                local hudelemstatus = getcountdownhud(x, download.hudelemy, nil, nil, HUD_TEXT_SCALE)
                hudelemstatus.label = "&SO_DOWNLOAD_ARCADIA_DSM_CONNECTING"
                hudelemstatus:setpulsefx(30, 900000, 700)

                dsmwait(hudelemstatus, 0.9, function()
                    hudelemstatus:destroy()

                    local hudelemstatus = getcountdownhud(x, download.hudelemy, nil, nil, HUD_TEXT_SCALE)
                    hudelemstatus.label = "&SO_DOWNLOAD_ARCADIA_DSM_LOGIN"
                    hudelemstatus:setpulsefx(30, 900000, 700)
    
                    dsmwait(hudelemstatus, 3.75, function()
                        hudelemstatus:destroy()

                        local hudelemstatus = getcountdownhud(x, download.hudelemy, nil, nil, HUD_TEXT_SCALE)
                        hudelemstatus.label = "&SO_DOWNLOAD_ARCADIA_DSM_LOCATE"
                        hudelemstatus:setpulsefx(30, 900000, 700)
        
                        dsmwait(hudelemstatus, 1.5, function()
                            hudelem:destroy()
                            hudelemstatus:destroy()

                            download.firstdownload = false
                            startdownload()
                        end)
                    end)
                end)
            end)
        end, 650)
    else
        startdownload()
    end
end

function downloadobjdialogue()

end

function downloadobjthink(download)
    download:entflaginit("download_stopped")
    download.downloading = false
    download.firstdownload = true
    download.downloadtimeelapsed = 0
    download.filesdone = 0
    download.downloadcomplete = false

    local finish = function()
        download.downloadcomplete = true
        downloadscomplete = downloadscomplete + 1

        downloadobjdialogue()

        if (downloadscomplete >= #downloads) then
            objectivecomplete(downloadobjectiveidx)
            flagset("all_downloads_finished")
        else
            game:objective_additionalposition(downloadobjectiveidx, download.objpos, vector:new(0, 0, 0))
            game:objective_string(downloadobjectiveidx, downloadobjectivestr)
            game:objective_ring(downloadobjectiveidx)
        end
    end

    local waittilltrigger = nil
    waittilltrigger = function()
        download.trig:onnotifyonce("trigger", function()
            download.dsmobj:hide()
            download.dsm:show()
    
            download.trig:makeunusable()
    
            downloadfiles(download, function(success)
                if (success) then
                    download.dsm:hide()
                    finish()
                else
                    download.trig:makeusable()
                    download.dsm:hide()
                    download.dsmobj:show()
                    waittilltrigger()
                end
            end)
        end)
    end

    waittilltrigger()
end

function fakechoppers()
    local choppers = game:getentarray("fake_creek_chopper", "targetname")
    choppers:foreach(entity.delete)

    local choppers = game:getentarray("fake_golf_course_chopper", "targetname")
    choppers:foreach(entity.delete)

    local choppers = game:getentarray("checkpoint_fake_chopper", "targetname")
    choppers:foreach(entity.delete)
end

function mansionpool()
    player.inwater = false

    local trigger = game:getent("pool", "targetname")
    local waittilltrigger = nil
    waittilltrigger = function()
        trigger:onnotifyonce("trigger", function()
            if (player:istouching(trigger) == 1 and player.inwater == 0) then
                mansionpoolinternal(trigger)
            end

            game:ontimeout(waittilltrigger, 500)
        end)
    end

    waittilltrigger()
end

function mansionpoolinternal(trigger)
    player.inwater = true

    local restore = function()
        player.inwater = false
        player:setmovespeedscale(1)
        player:allowstand(true)
        player:allowcrouch(true)
        player:allowprone(true)
    end

    local interval = nil
    interval = game:oninterval(function()
        if (player:istouching(trigger) == 0) then
            restore()
            interval:clear()
            return
        end

        player:setmovespeedscale(0.3)
        player:allowstand(true)
        player:allowcrouch(false)
        player:allowprone(false)
    end, 100)
end

function initflags()
    flaginit("intro_dialogue_done")
	flaginit("first_download_started")
	flaginit("player_has_escaped")
	flaginit("all_downloads_finished")
	flaginit("stryker_extraction_done")
	
	--flaginit("used_laser")
	--flaginit("laser_hint_print")
	--flagset("laser_hint_print")
	
	flaginit("golf_course_vehicles")
	flaginit("golf_course_mansion")
	
	flaginit("start_challenge")

	flaginit("no_living_enemies")

	--flaginit("disable_stryker_dialog")
	--flaginit("disable_stryker_laser")
	flaginit("golf_course_vehicles")
	flaginit("golf_course_vehicles_stop")
end

function arcadiaenemysetup()
    enemies = array:new()

    local allspawners = game:getspawnerteamarray("axis")
    arrayspawnfunc(allspawners, arcadiaenemyspawnfunc)

    local insideguys = array:new()
    local outsideguys = array:new()

    for i = 1, #allspawners do
        local spawner = allspawners[i]
        if (spawner.targetname ~= nil) then
            if (game:issubstr(spawner.targetname, "inside") == 1) then
                insideguys:push(spawner)
            elseif (game:issubstr(spawner.targetname, "outside") == 1) then
                outsideguys:push(spawner)
            end
        end
    end

    arrayspawnfunc(outsideguys, arcadiaoutsideenemyspawnfunc)
    enemyspawners = allspawners
end

function arcadiaenemyspawnfunc(ai)
    if (game:randomint(100) > 10) then
        ai:setthreatbiasgroup("stryker_ignoreme")
    end

    ai:scriptcall("maps/_utility", "_ID26354", 800)
end

function arcadiaoutsideenemyspawnfunc(ai)
    if (game:isdefined(ai.script_linkto) == 0 or game:isdefined(ai.script_parameters) == 0 or ai.script_parameters == nil) then
        return
    end

    local retreattrig = game:getent(ai.script_linkto, "script_linkname")
    local retreatvol = game:getent(ai.script_parameters, "targetname")

    retreattrig:onnotifyonce("trigger", function()
        ai.combatmode = "ambush"

        pcall(function()
            ai:setgoalvolumeauto(retreatvol)
        end)
    end):endon(ai, "death")
end

map.main = function()
    initflags()
    arcadiaprecache()

    deletenonspecialops({
        isspawntrigger,
        isflagtrigger,
        isspawner,
        iskillspawnertrigger,
        isgoalvolume,
    })

    game:scriptcall("_ID49178", "main", "vehicle_stryker_config2")

    enableescapewarning()
    enableescapefailure()

    game:scriptcall("_ID49242", "main")
    game:scriptcall("_ID51176", "main")
    game:scriptcall("_ID44499", "main")
    game:scriptcall("maps/arcadia_lighting", "main")
    game:scriptcall("maps/arcadia", "_ID44594")

    defaultstart(startsodownloadarcadia)
    addstart("so_escape", startsodownloadarcadia)

    game:scriptcall("maps/_load", "set_player_viewhand_model", "viewhands_player_us_army")
    game:scriptcall("maps/_load", "main")

    game:scriptcall("_ID42407", "_ID1895", "use_laser", "&SO_DOWNLOAD_ARCADIA_LASER_HINT1")
    game:scriptcall("_ID42407", "_ID1895", "use_laser_attack", "&SO_DOWNLOAD_ARCADIA_LASER_HINT2")
    game:scriptcall("_ID42407", "_ID1895", "use_laser1", "&SO_DOWNLOAD_ARCADIA_LASER_HINT1")
    game:scriptcall("_ID42407", "_ID1895", "use_laser2", "&SO_DOWNLOAD_ARCADIA_LASER_HINT2")

    game:scriptcall("_ID53924", "main")

    game:scriptcall("maps/arcadia_anim", "main")
    game:scriptcall("maps/arcadia_aud", "main")

    game:scriptcall("maps/_compass", "setupminimap", "compass_map_arcadia")

    enableallportalgroups(0)
    game:enablepg("portal_stryker_road", 1)
    game:enablepg("portal_golf_road", 1)

    arcadiaenemysetup()

    game:scriptcall("common_scripts/utility", "_ID30396", "plane_sounds", function(ent, ...)
        ent:scriptcall("_ID42550", "_ID26746", ...)
    end)

    fakechoppers()
    mansionpool()
end

return map
