local map = {}

map.premain = function()
    game:visionsetnaked("favela_escape", 0)

    setloadout("m1014", "glock", "fraggrenade", "flash_grenade", "viewhands_tf141_favela", "american")
    -- introscreen
    game:detour("_ID42318", "main", function() end)
end

function airlinerdelete()
    local ents = game:getentarray( "sbmodel_airliner_flyby", "targetname")
    ents:foreach(function(ent)
        ent:delete()
    end)
end

function defusesetup()
    player:takeweapon("ump45_acog")
    player:giveweapon("m1014")
    player:givemaxammo("m1014")
    player:switchtoweapon("m1014")

    setplayerpos()

    enableallportalgroups()

    -- 

    airlinerdelete()
    cleanupsetup()

    flaginit("defuse_update_score")

    arrayspawnfunctargetname("civilian", civilian)

    local cooponly = game:getentarray("coop_only", "script_noteworthy")
    cooponly:foreach(function(ent)
        ent:delete()
    end)

    intro()
    enableescapewarning()
    enableescapefailure()

    game:ontimeout(function()
        opendoor("sbmodel_market_door_1", game:getentbynum(1785))
	    opendoor("sbmodel_vista1_door1", game:getentbynum(1901))
    end, 0)

    changecombatmodesetup()
    
    musicloop("mus_favelaescape_finalrun")

    enablechallengetimer("defuse_start", "defuse_complete", 300)

    defuseobjectives()
end

local defusecount = 0
local bombfx = game:loadfx("vfx/lights/light_c4_blink")
function defuseobjectives()
    local objectives = {
        "&SO_DEFUSE_FAVELA_ESCAPE_OBJ_BOMB_MARKET",
        "&SO_DEFUSE_FAVELA_ESCAPE_OBJ_BOMB_APARTMENT",
        "&SO_DEFUSE_FAVELA_ESCAPE_OBJ_BOMB_STORE",
    }

    local defuselocations = game:getentarray("defuse_briefcase", "targetname")
    defuselocations:foreach(defuselocationhandler)

    for i = 1, #defuselocations do
        local location = defuselocations[i]
        local objid = location.script_index
        game:objective_add(location.script_index, "current", objectives[objid + 1], location.origin + vector:new(0, 0, 24))
        objswitchtext(location, 400, objid)
    end

    local listener = nil
    listener = level:onnotify("defuse_update_score", function(objid)
        if (objid) then
            game:objective_state(objid, "done")
        end

        if (defusecount <= 0) then
            listener:clear()
            flagset("defuse_complete")
        end
    end)
end

function objswitchtext(briefcase, dist, objid)
    local interval = nil
    interval = game:oninterval(function()
        local close = false
        if (game:squared(dist) > game:distancesquared(briefcase.origin, player.origin)) then
            close = true
        end

        if (close) then
            game:objective_setpointertextoverride(objid, "&SO_DEFUSE_FAVELA_ESCAPE_OBJ_TEXT")
            dist = 800
        else
            game:objective_setpointertextoverride(objid, "")
        end
    end, 0)

    interval:endon(briefcase, "briefcase_bomb_defused")
end

function defuselocationhandler(briefcase)
    briefcase:entflaginit("briefcase_bomb_defused")
    defusecount = defusecount + 1

    local bombarray = game:getentarray(briefcase.target, "targetname")
    bombarray:foreach(function(bomb)
        -- no c4 model :(
        if (bomb.model ~= "h2_weapon_c4") then
            return
        end

        game:ontimeout(function()
            local fxent = game:playloopedfx(bombfx, 1, bomb:gettagorigin("tag_fx"))
            briefcase:onnotifyonce("briefcase_bomb_defused", function()
                fxent:delete()
            end)
        end, math.floor(game:randomfloat(0.5) * 1000))
    end)

    local f1 = function()
        briefcase:makeusable()
        briefcase:sethintstring("&SO_DEFUSE_FAVELA_ESCAPE_DEFUSE_HINT")
    end

    f1()

    local listener = nil
    local done = true
    listener = briefcase:onnotify("trigger", function()
        if (not done) then
            return
        end

        if (briefcase:entflag("briefcase_bomb_defused")) then
            listener:clear()
            return
        end

        done = false
        briefcase:makeunusable()
        briefcasedefuse(briefcase, function(result)
            if (result) then
                listener:clear()
            else
                done = true
                f1()
            end
        end)
    end)
end

function briefcasedefuse(briefcase, callback)
    player:playerlinkto(briefcase)
    player:playerlinkedoffsetenable(briefcase)

    player:disableweapons()
    briefcase:hide()

    game:ontimeout(function()
        defuseusebar(4.5, briefcase, function(result)
            if (result) then
                briefcase:entflagset("briefcase_bomb_defused")
                defusecount = defusecount - 1
                level:notify("defuse_update_score", briefcase.script_index)
            end
            
            game:ontimeout(function()
                briefcase:show()
                player:unlink()
        
                game:ontimeout(function()
                    player:enableweapons()
    
                    game:ontimeout(function()
                        callback(result)
                    end, 500)
                end, 800)
            end, 500)
        end)
    end, 1200)
end

function defuseusebar(filltime, briefcase, callback)
    briefcase.defusetime = 0
    local buttontime = briefcase.defusetime
    local totaltime = filltime

    local bar = createprogressbar(player, 57)
    bar:updatebar(0)
    local text = createfontstring("objective", 1.2)
    text.objectivefont = true
    text:setpoint("CENTER", nil, 0, 45)
    text:settext("&SO_DEFUSE_FAVELA_ESCAPE_DEFUSING")
    text.fontscale = 0.6
    text:setwhite()

    local interval = nil
    interval = game:oninterval(function()
        if (not useactive()) then
            briefcase.defusetime = buttontime

            text:destroyelem()
            bar:destroyelem()

            interval:clear()
            callback(false)
            return
        end

        bar:updatebar(buttontime / totaltime)

        buttontime = buttontime + 0.05
        if (buttontime > totaltime) then
            text:destroyelem()
            bar:destroyelem()

            interval:clear()
            callback(true)
        end
    end, 0)
end

function useactive()
    if (player:usebuttonpressed() == 0) then
        return false
    end

    if (flag("special_op_failed")) then
        return false
    end

    if (ismissionover) then
        return false
    end

    return true
end

function opendoor(name, brushmodel)
    local door = game:getent(name, "targetname")
    local linker = game:getent(door.target, "targetname")
    door:linkto(linker)
    brushmodel:linkto(linker)
    door:connectpaths()
    linker:rotateto(linker._ID31037, 0.5)
    linker:onnotifyonce("rotatedone", function()
        door:unlink()
    end)
end

function cleanupsetup()
    addspawnfunc("axis", cleanupspawnfunc)

    local arr = game:getentarray("clean_up_volume", "targetname")
    arr:foreach(cleanupvolume)

    local arr = game:getentarray("clean_up_respawn_trigger", "script_noteworthy")
    arr:foreach(cleanuprespawntrigger)
end

function cleanupvolume(volume)
    game:oninterval(function()
        if (player:istouching(volume) == 0) then
            level:notify("clenup", volume.script_group)
        end
    end, 1000)
end

function cleanupspawnfunc(ai)
    if (game:isdefined(ai.script_group) == 0) then
        return
    end

    local waittillcleanup = nil
    waittillcleanup = function()
        ai:onnotifyonce("clean_up", function(scriptgroup)
            if (ai.script_group ~= scriptgroup) then
                waittillcleanup()
                return
            end

            game:ontimeout(function()
                if (game:sightconetrace(player:geteye(), player) == 0) then
                    ai.spawner.count = ai.spawner.count + 1
                    ai:delete()
                end
            end, 300):endon(ai, "death")
        end):endon(ai, "death")
    end

    waittillcleanup()
end

function cleanuprespawntrigger(trigger)
    local waittilltrigger = nil
    waittilltrigger = function()
        trigger:onnotifyonce("trigger", function()
            local listener = nil
            listener = level:onnotify("clean_up", function(scriptgroup)
                if (trigger.script_group ~= scriptgroup) then
                    return
                end

                trigger:scriptcall("maps/_spawner", "_ID38908", trigger)
                listener:clear()
                waittilltrigger()
            end)
        end)
    end
end

function changecombatmodesetup()
    local arr = game:getentarray("change_combatmode_node", "script_noteworthy")
    arr:foreach(changecombatmodenode)

    local arr = game:getentarray("change_combatmode_trigger", "script_noteworthy")
    arr:foreach(changecombatmodetrigger)
end

function changecombatmodenode(node)
    node:onnotify("trigger", function(ai)
        ai.combatmode = node.script_combatmode
    end)
end

function changecombatmodetrigger(trigger)
    local originent = game:getent(trigger.target, "targetname")
    local distsqrd = originent.radius * originent.radius

    local waittrigger = nil
    waittrigger = function()
        trigger:onnotifyonce("trigger", function()
            local aiarray = game:getaiarray("axis")

            aiarray:foreach(function(ai)
                if (game:distancesquared(ai.origin, originent.origin) > distsqrd) then
                    return
                end

                ai:notify("stop_going_to_node")
                ai.combatmode = "cover"
                ai.goalradius = 640
                ai:setgoalentity(player)
            end)

            game:ontimeout(waittrigger, 10000)
        end)
    end

    waittrigger()
end

function civilian(ai)
	--civiliandeath(ai)

    ai:onnotifyonce("reached_path_end", function()
        local timer = 0
        local dist = 2000 * 2000

        local interval = nil
        interval = game:oninterval(function()
            if (timer >= 10) then
                ai:delete()
                interval:clear()
                return
            end

            local issafe = false
            if (game:distancesquared(ai.origin, player.origin) < dist) then
                issafe = false
            end

            if (withinfov(player.origin, player.angles, ai.origin, game:cos(60))) then
                issafe = false
            end

            if (issafe) then
                timer = timer + 1
            else
                timer = 0
            end
        end, 0)

        interval:endon(ai, "death")
    end):endon(ai, "death")
end

function civiliandeath(ai)
    local listener = ai:onnotifyonce("death", killer, type_, function()
        if (game:isplayer(killer) == 0) then
            return
        end

        --soforcedeadquote("@SO_DEFUSE_FAVELA_ESCAPE_MISSION_FAILED_CIVILIAN")
        --missionfailedwrapper()
    end)

    listener:endon(level, "defuse_complete")
    listener:endon(level, "missionfailed")
    listener:endon(level, "special_op_terminated")
end

map.main = function()
    deletenonspecialops({
        isspawntrigger,
        isspawner
    })

    game:scriptcall("maps/favela_escape", "_ID19719")
    game:scriptcall("_ID51196", "main")
    game:scriptcall("_ID54620", "main")
    game:scriptcall("_ID53782", "main")
    game:scriptcall("_ID51773", "main")
    game:scriptcall("maps/favela_escape_anim", "main")
    game:scriptcall("maps/favela_escape_lighting", "main")

    game:precachemodel("h2_weapon_c4")

    game:scriptcall("maps/_load", "main")
    game:scriptcall("maps/_compass", "setupminimap", "compass_map_favela_escape")

    defusesetup()
end

return map
