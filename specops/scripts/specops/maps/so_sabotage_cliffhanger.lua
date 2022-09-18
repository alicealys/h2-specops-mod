local map = {}

map.premain = function()
    setloadout("masada_silencer_mt_camo_on_h2", "usp_silencer", "fraggrenade", "flash_grenade", "viewhands_arctic", "american")
end

function startmap()
    setplayerpos()

    intro()
    enableescapewarning()
    enableescapefailure()

    enablechallengetimer("challenge_start", "sabotage_success")
    oncomplete()

    enableallportalgroups()

    setflags()
    setupexplosives()
    explosivesplantedmonitor()
    blizzardcontrol()
    starttruckpatrol()

    dialogue()
end

function starttruckpatrol()
    local truckguys = game:getentarray("truck_guys", "script_noteworthy")
    arrayspawnfunc(truckguys, function(ai)
        ai:scriptcall("maps/cliffhanger_stealth", "_ID52114")
    end)

    level:onnotifyonce("start_truck_patrol", function()
        local truckpatrol = game:scriptcall("_ID42411", "_ID35196", "truck_patrol")
        truckpatrol:scriptcall("_ID42237", "_ID27000", "cliffhanger_truck_music")
        basetruckthink(truckpatrol)
        truckheadlights(truckpatrol)

        truckpatrol:onnotifyonce("death", function()
            flagset("jeep_blown_up")
            truckpatrol:notify("stop soundcliffhanger_truck_music")
        end)
    end)
end

function basetruckthink(truckpatrol)
    dialogtruckcoming(truckpatrol)
    dialogjeepstopped(truckpatrol)

    unloadandattackifstealthbrokenandclose(truckpatrol)

    level:onnotifyonce("truck_guys_alerted", function()
        local guys = getlivingaiarray("truck_guys", "script_noteworthy")
        if (#guys == 0) then
            truckpatrol:vehicle_setspeed(0, 15)
            return
        end

        local screamer = randomof(guys)
        screamer:scriptcall("_ID42386", "_ID12800")

        truckpatrol:onnotifyonce("safe_to_unload", function()
            truckpatrol:vehicle_setspeed(0, 15)
            game:ontimeout(function()
                truckpatrol:scriptcall("_ID42413", "_ID1680")
                flagset("jeep_stopped")
            end, 1000):endon(truckpatrol, "death")
        end):endon(truckpatrol, "death")
    end):endon(truckpatrol, "death")
end

function unloadandattackifstealthbrokenandclose(truckpatrol)
    local done = true
    local listener = nil
    listener = level:onnotify("_stealth_spotted", function()
        if (not done or not flag("_stealth_spotted")) then
            return
        end

        local interval = nil
        interval = game:oninterval(function()
            if (game:distance(player.origin, truckpatrol.origin) > 800) then
                return
            end

            interval:clear()
            if (not flag("_stealth_spotted")) then
                done = true
            else
                listener:clear()
                flagset("truck_guys_alerted")
            end
        end, 0)
    end)
end

level.expfx = game:loadfx("fx/explosions/mig29_core_explosion")
level.expfx1 = game:loadfx("fx/explosions/mig29_core_explosion_flames_02")
level.expfx2 = game:loadfx("fx/explosions/mig29_core_explosion_flames_03")

function truckheadlights(truckpatrol)
	game:playfxontag(level._ID1426["lighthaze_snow_headlights"], truckpatrol, "TAG_LIGHT_RIGHT_FRONT")
	game:playfxontag(level._ID1426["lighthaze_snow_headlights"], truckpatrol, "TAG_LIGHT_LEFT_FRONT")
	game:playfxontag(level._ID1426["car_taillight_uaz_l"], truckpatrol, "TAG_LIGHT_LEFT_TAIL")
	game:playfxontag(level._ID1426["car_taillight_uaz_l"], truckpatrol, "TAG_LIGHT_RIGHT_TAIL")
 	
    truckpatrol:onnotifyonce("death", function()
        if (game:isdefined(truckpatrol) == 1) then
            deletetruckheadlights(truckpatrol)
        end
    end)
end	
 
function deletetruckheadlights(truckpatrol)
	game:stopfxontag(level._ID1426["lighthaze_snow_headlights"], truckpatrol, "TAG_LIGHT_RIGHT_FRONT")
    game:stopfxontag(level._ID1426["lighthaze_snow_headlights"], truckpatrol, "TAG_LIGHT_LEFT_FRONT")
	game:stopfxontag(level._ID1426["car_taillight_uaz_l"], truckpatrol, "TAG_LIGHT_LEFT_TAIL")
	game:stopfxontag(level._ID1426["car_taillight_uaz_l"], truckpatrol, "TAG_LIGHT_RIGHT_TAIL")
end

function watchfortruck(truckpatrol)
    local interval = game:oninterval(function()
        if (game:distance(player.origin, truckpatrol.origin) <= 1200) then
            level:notify("player_in_truck_range")
        end
    end, 0)
end

function dialogtruckcoming(truckpatrol)
    watchfortruck(truckpatrol)

    local firsttime = false

    local lastnotify = 0
    local waittime = 1000
    local listener = level:onnotify("player_in_truck_range", function()
        local now = game:gettime()
        if (now - lastnotify < waittime) then
            return
        end

        lastnotify = now
        local truckcoming = withinfov(truckpatrol.origin, truckpatrol.angles, player.origin, game:cos(45))
        if (truckcoming) then
            if (not firsttime and cointoss()) then
                radiodialogue("cliff_pri_truckcomingback")
            else
                radiodialogue("cliff_pri_truckiscoming")
            end

            firsttime = false
            waittime = 11000
        else
            waittime = 1000
        end
    end)

    listener:endon(level, "special_op_terminated")
    listener:endon(level, "jeep_stopped")
    listener:endon(level, "jeep_blown_up")
end

function dialogjeepstopped(truckpatrol)
    local listener = truckpatrol:onnotifyonce("unloading", function()
        if (not flag("_stealth_spotted")) then
            return
        end

        radiodialogue("cliff_pri_headsup")

        if (flag("_stealth_spotted")) then
            return
        end

        radiodialogue("cliff_pri_lookingaround")
    end)

    listener:endon(level, "special_op_terminated")
end

local extracting = false
function oncomplete()
    local trigger = game:getent("player_outside_compound", "script_noteworthy")
    local listener = nil
    listener = trigger:onnotify("trigger", function()
        if (not extracting) then
            return
        end

        game:objective_state(2, "done")
        listener:clear()
        missionover(true)
    end)
end

function isspecialspawner(ent)
	return ent.script_noteworthy ~= "high_threat_spawner" and isspawner(ent)
end

function isspecialvehicle(ent)
	if (ent.code_classname == "script_vehicle_collmap") then
        return false
    end

	local specialcase = ent.script_noteworthy ~= "tarmac_snowmobile"
	local specialcase2 = ent.targetname ~= "truck_patrol"
		
	return specialcase and specialcase2 and isvehicle(ent)
end

function stealthsettings()
    game:scriptcall("_ID42389", "_ID36356", "cliffhanger", function(self_)
        self_:scriptcall("maps/cliffhanger_stealth", "_ID46153")
    end)

    local aievent = array:new()
    
    aievent["ai_eventDistNewEnemy"] = array:new()
    aievent["ai_eventDistNewEnemy"]["spotted"] = 320
    aievent["ai_eventDistNewEnemy"]["hidden"] = 192

    aievent["ai_eventDistExplosion"] = array:new()
    aievent["ai_eventDistExplosion"]["hidden"] = 1500
    aievent["ai_eventDistExplosion"]["hidden"] = 1500

    aievent["ai_eventDistDeath"] = array:new()
    aievent["ai_eventDistDeath"]["spotted"] = 320
    aievent["ai_eventDistDeath"]["hidden"] = 192

    aievent["ai_eventDistPain"] = array:new()
    aievent["ai_eventDistPain"]["spotted"] = 192
    aievent["ai_eventDistPain"]["hidden"] = 96

    aievent["ai_eventDistBullet"] = array:new()
    aievent["ai_eventDistBullet"]["spotted"] = 96
    aievent["ai_eventDistBullet"]["hidden"] = 96

    aievent["ai_eventDistFootstep"] = array:new()
    aievent["ai_eventDistFootstep"]["spotted"] = 120
    aievent["ai_eventDistFootstep"]["hidden"] = 120
    
    aievent["ai_eventDistFootstepWalk"] = array:new()
    aievent["ai_eventDistFootstepWalk"]["spotted"] = 60
    aievent["ai_eventDistFootstepWalk"]["hidden"] = 60
    
    aievent["ai_eventDistFootstepSprint"] = array:new()
    aievent["ai_eventDistFootstepSprint"]["spotted"] = 700
    aievent["ai_eventDistFootstepSprint"]["hidden"] = 500

    game:scriptcall("_ID42389", "_ID36234", aievent)

    local rangeshidden = array:new()
    rangeshidden["prone"] = 200
    rangeshidden["crouch"] = 350
    rangeshidden["stand"] = 600

    local rangesspotted = array:new()

    rangesspotted["prone"] = 600
    rangesspotted["crouch"] = 800
    rangesspotted["stand"] = 1000

    game:scriptcall("_ID42389", "_ID36284", rangeshidden, rangesspotted)

    local alertduration = array:new()
    alertduration[0] = 1
    alertduration[1] = 1
    alertduration[2] = 1
    alertduration[3] = 0.75

    game:scriptcall("_ID42389", "_ID36243", alertduration[level._ID15361])

    game:scriptcall("_ID42389", "_ID36234", aievent)


    local a = array:new()
    a["sight_dist"] = 400
    a["detect_dist"] = 200
    game:scriptcall("_ID42389", "_ID36268", a)

    stealthmusic()

    player:scriptcall("_ID42389", "_ID36343") -- maps/_stealth_utils::stealth_plugin_basic
    player:scriptcall("_ID42407", "_ID27997") -- maps/_utils::playerSnowFootsteps
end

function dialogue()
    stealthdialoguespotted()
    stealthdialoguefailure()

    dialogunsilencedweapons()

    game:ontimeout(function()
    	radiodialogue("cliff_pri_likeaghost")

        game:ontimeout(function()
        	radiodialogue("cliff_pri_keepeyeonheart")
        end, 350)
    end, 4000)
end

function stealthdialoguespotted()
    if (ismissionover) then
        return
    end

    local dialogues = {
        "cliff_pri_takecover",
        "cliff_pri_beenspotted",
        "cliff_pri_foundyou",
    }

    dialogues = shuffle(dialogues)
    local index = 1
    
    level:onnotifyonce("_stealth_spotted", function()
        game:ontimeout(function()
            if (ismissionover) then
                return
            end

            if (flag("_stealth_spotted")) then
                radiodialogue(dialogues[index])
                index = index + 1
                if (index > #dialogues) then
                    index = 1
                end
            end

            local listener = nil
            listener = level:onnotify("_stealth_spotted", function()
                if (flag("_stealth_spotted")) then
                    return
                end
    
                listener:clear()
                stealthdialoguespotted()
            end)
        end, 1000)
    end)
end

function stealthdialoguefailure()
    if (ismissionover) then
        return
    end

    local dialogues = {
        "cliff_pri_dontalertthem",
        "cliff_pri_sloppy",
        "cliff_pri_silencers",
    }

    dialogues = shuffle(dialogues)
    local index = 1

    level:onnotifyonce("_stealth_spotted", function()
        game:ontimeout(function()
            local listener = nil
            listener = level:onnotify("_stealth_spotted", function()
                if (flag("_stealth_spotted")) then
                    return
                end
    
                listener:clear()

                game:ontimeout(function()
                    if (not flag("_stealth_spotted")) then
                        if (ismissionover) then
                            return
                        end

                        radiodialogue(dialogues[index])
                        index = index + 1
                        if (index > #dialogues) then
                            index = 1
                        end
                    end

                    stealthdialoguefailure()
                end, 1000)
            end)
        end, 1000)
    end)
end

function dialogunsilencedweapons()
    local listener = nil
    listener = player:onnotify("weapon_change", function()
        local weap = player:getcurrentprimaryweapon()
        if (weap == nil or weap == "none" or game:issubstr(weap, "silence") == 1 or game:issubstr(weap, "soap") == 1) then
            return
        end

        listener:clear()
        radiodialogue("cliff_pri_attractattn")
    end)
end

function stealthmusic()
    if (ismissionover) then
        return
    end

    musicloop("mus_cliffhanger_stealth")

    level:onnotifyonce("_stealth_spotted", function()
        game:musicstop(0.2)
        game:ontimeout(function()
            if (ismissionover) then
                return
            end

            musicloop("mus_cliffhanger_stealth_busted")
        end, 500)

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

local planttargets = {}
function setupexplosives()
    local models = game:getentarray("explosive_obj_model", "script_noteworthy")
    for i = 1, #models do
        local model = models[i]
        model:hide()
        local plantedmodel = game:getent(model.target, "targetname")
        plantedmodel:hide()
    end

    local truncatedplanttargets = {}
    for i = 1, #models do
        truncatedplanttargets[i] = models[i]
        truncatedplanttargets[i]:show()
    end


    for i = 1, #truncatedplanttargets do
        local target = truncatedplanttargets[i]
        local id = #planttargets

        local plantedmodel = game:getent(target.target, "targetname")
        plantedmodel:hide()

        local struct = {}
        struct.objmodel = target
        struct.objectiveid = tonumber(game:strtok(target.targetname, "_")[2])
        struct.plantedmodel = plantedmodel
        struct.origin = target.origin
        struct.plantflag = "explosive_" .. tostring(id)
        struct.id = id
        struct.planted = false
        struct.plantedmodel.health = 100
        struct.plantedmodel:scriptcall("_ID42407", "_ID13024", struct.plantflag)
        
        table.insert(planttargets, struct)
    end

    game:ontimeout(function()
        flagset("explosives_ready")
        for i = 1, #planttargets do
            local target = planttargets[i]
            target.objmodel:makeusable()
            target.objmodel:setcursorhint("HINT_ACTIVATE")

            local wasusinggamepad = nil
            local interval = game:oninterval(function()
                local isusinggamepad = player:scriptcall("common_scripts/utility", "_ID20583")
                if (wasusinggamepad ~= isusinggamepad) then
                    if (isusinggamepad == 1) then
                        target.objmodel:sethintstring("&SCRIPT_PLATFORM_HINTSTR_PLANTEXPLOSIVES")
                    else
                        target.objmodel:sethintstring("&SCRIPT_PLATFORM_HINTSTR_PLANTEXPLOSIVES_KBM")
                    end
                end
            end, 0)


            target.objmodel:onnotifyonce("trigger", function()
                target.objmodel:makeunusable()
                target.objmodel:hide()
                target.plantedmodel:show()

                target.plantedmodel:scriptcall("_ID43691", "_ID27192")
                target.plantedmodel:scriptcall("_ID42407", "_ID27079", "detpack_plant")

                target.planted = true
                target.plantedmodel:scriptcall("_ID42407", "_ID13025", target.plantflag)
                game:objective_additionalposition(1, target.id, vector:new(0, 0, 0))

                game:ontimeout(function()
                    level:notify("an_explosive_planted")
                end, 0)
            end)
        end

        game:ontimeout(function()
            game:objective_add(1, "current", "&SO_SABOTAGE_CLIFFHANGER_OBJ_REGULAR")
            for i = 1, #planttargets do
                local target = planttargets[i]
                game:objective_additionalposition(1, target.id, target.origin)
            end
        end, 0)
    end, 0)
end

function explosivesplantedmonitor()
    game:scriptcall("_ID42237", "_ID38863", "player_outside_compound", "script_noteworthy")
    level:onnotifyonce("explosives_ready", function()
        local listener = nil
        listener = level:onnotify("an_explosive_planted", function()
            local allplanted = true
            for i = 1, #planttargets do
                if (planttargets[i].planted == false) then
                    allplanted = false
                end
            end

            if (not allplanted) then
                return
            end

            listener:clear()
            game:objective_state(1, "done")

            local outsideobj = getstruct("obj_outside_compound", "script_noteworthy")
            game:objective_add(2, "current", "Get clear of the compound for extraction.", outsideobj.origin)

            extracting = true
            game:scriptcall("_ID42237", "_ID38865", "player_outside_compound", "script_noteworthy")
        end)
    end)
end
    
function blizzardcontrol()
    game:scriptcall("maps/_utility", "_ID32515", "cliffhanger_blizzard_med", 0)
    game:scriptcall("maps/_utility", "_ID14689", "cliffhanger_blizzard_med", 0)
    game:scriptcall("maps/cliffhanger_code", "_ID49362", 0)
end

function flagsinit()
	flaginit("challenge_start")
	flaginit("sabotage_success")
	flaginit("explosives_planted")
	flaginit("stop_stealth_music")
	flaginit("someone_became_alert")	
	
	flaginit("explosives_ready")
	
	flaginit("destroyed_fallen_tree_cliffhanger01")
	flaginit("script_attack_override")
	
	flaginit("truck_guys_alerted")
	
	flaginit("jeep_blown_up")
	flaginit("jeep_stopped")
	flaginit("first_two_guys_in_sight")
	
	flaginit("done_with_stealth_camp")
	
	flaginit("player_outside_compound")
end


function setflags()
	flagset("first_two_guys_in_sight")
end

map.main = function()
    game:precacheshader("overlay_frozen")
    game:precacheitem("c4")

    game:scriptcall("_ID43695", "main")

    deletenonspecialops({
        isspawntrigger,
        isspecialspawner,
        isspecialvehicle
    })

    local voltronarray = game:getentarray("script_vehicle_snowmobile_coop_alt", "classname")
    local voltronarray2 = game:getentarray("script_vehicle_snowmobile_coop", "classname")

    arraydelete(voltronarray)
    arraydelete(voltronarray2)
    
	local truckpatrol = game:getent("truck_patrol", "targetname")
	truckpatrol.target = "truck_patrol_target"

    addstart("start_map", startmap)
    defaultstart(startmap)

    flagsinit()

    game:scriptcall("_ID53530", "main")
    game:scriptcall("_ID49383", "main")
    --game:scriptcall("_ID49359", "_ID50425")

    game:scriptcall("maps/cliffhanger_anim", "_ID15518")
    game:scriptcall("maps/cliffhanger_anim", "_ID31296")
    game:scriptcall("maps/cliffhanger_anim", "_ID27230")
    game:scriptcall("maps/cliffhanger_lighting", "main")

    game:scriptcall("maps/_load", "main")

    -- idle_*
    game:scriptcall("_ID42314", "_ID19317")
    game:scriptcall("_ID48225", "main")
    game:scriptcall("_ID43509", "main")
    game:scriptcall("_ID42316", "main")
    game:scriptcall("_ID47233", "main")
    game:scriptcall("_ID42315", "main")
    game:scriptcall("_ID45778", "main")

    game:scriptcall("_ID42339", "main")

    game:scriptcall("_ID42373", "main") -- maps/_stealth::main
    stealthsettings()

    game:scriptcall("maps/_compass", "setupminimap", "compass_map_cliffhanger")

    local weapons = game:assetlist("weapon")
    for i = 1, #weapons do
        pcall(function()
            game:precacheitem(weapons[i])
        end)
    end

    local weapons = game:assetlist("xmodel")
    for i = 1, #weapons do
        pcall(function()
            if (weapons[i]:match("tarp")) then
                game:precachemodel(weapons[i])
            end
        end)
    end
end

return map
