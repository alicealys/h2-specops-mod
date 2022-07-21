local map = {}

map.premain = function()

end

function alarm()
    local alarmorg = game:getent("origin_alarm", "targetname")
    alarmorg:playloopsound("emt_oilrig_alarm_alert")
    game:ontimeout(function()
        alarmorg:stoploopsound("emt_oilrig_alarm_alert")
        alarmorg:delete()
    end, 20000)
end

function docktworappellers()
    local spawners = game:getentarray("hostiles_rappel_deck2", "targetname")
    level:onnotifyonce("rappel_dudes_failsafe", function()
        local hostiles = game:scriptcall("maps/oilrig", "_ID50606", spawners)
    end)
end

function helientersandattacks()
    local helispawner = game:getent("heli_deck2", "targetname")
    helispawner.origin = helispawner.origin + vector:new(0, 0, -250)
    local heli = game:scriptcall("_ID42411", "_ID35196", "heli_deck2")

    for i = 1, #heli._ID23512 do
        local turret = heli._ID23512[i]
        turret:scriptcall("_ID42413", "_ID39304", "manual")
        turret:setmode("manual")
    end

    heli._ID11585 = true
    game:scriptcall("maps/oilrig", "_ID48371", heli)
    game:ontimeout(function()
	    flagset("deck_2_heli_is_finished_intimidating")
    end, 5000)

    game:ontimeout(function()
        heli:scriptcall("_ID42508", "_ID18413", "tag_barrel", true)
    end, 3000)

    trackifplayerisshootingatintimidatingheli(heli)
    game:scriptcall("maps/oilrig", "_ID50725", heli)

    local waitfunc = function()
        game:scriptcall("_ID42508", "_ID4977", heli)
    end

    wait1 = level:onnotifyonce("player_shoots_or_aims_rocket_at_intimidating_heli", waitfunc)
    wait2 = level:onnotifyonce("deck_2_heli_is_finished_intimidating", waitfunc)

    wait1:endon(heli, "death")
    wait2:endon(heli, "death")
    wait1:endon(level, "deck_2_heli_is_finished_intimidating")
    wait2:endon(level, "player_shoots_or_aims_rocket_at_intimidating_heli")
end

function trackifplayerisshootingatintimidatingheli(heli)
    local interval = nil
    interval = heli:onnotify("damage", function(damage, attacker, vecdir, p, type_)
        if (game:isdefined(attacker) == 0 or game:isplayer(attacker) == 0) then
            return
        end

        flagset("player_shoots_or_aims_rocket_at_intimidating_heli")
        interval:clear()
    end)
end

function objmain()
    local objectivenumber = 1
    local objpositions = game:getentarray("obj_breach2", "targetname")
    game:objective_add(objectivenumber, "current", "&SO_ASSAULT_OILRIG_OBJ_MAIN")
    game:scriptcall("_ID42367", "_ID3438", objpositions)
    
    local breachindices = game:scriptcall("_ID42367", "_ID15588", objpositions)
    game:scriptcall("_ID42367", "_ID25325", objectivenumber, breachindices[1], breachindices[2], breachindices[3], breachindices[4])

    level:onnotifyonce("upper_room_breached", function()
        game:scriptcall("maps/_utility", "_ID25326", objectivenumber)
        game:objective_setpointertextoverride(objectivenumber)

        level:onnotifyonce("upper_room_cleared", function()
            local objposition = game:getent("obj_explosives_locate_01", "targetname")
            game:objective_position(objectivenumber, objposition.origin)

            level:onnotifyonce("player_at_stairs_to_deck_2", function()
                local objposition = game:getent("obj_explosives_locate_01a", "targetname")
                game:objective_position(objectivenumber, objposition.origin)
    
                level:onnotifyonce("player_at_corener_of_deck2", function()
                    local objposition = game:getent("obj_explosives_locate_02", "targetname")
                    game:objective_position(objectivenumber, objposition.origin)
        
                    level:onnotifyonce("player_at_stairs_to_top_deck", function()
                        local objpositions = game:getentarray("obj_breach3", "targetname")
                        game:scriptcall("_ID42367", "_ID3438", objpositions)

                        local breachindices = game:scriptcall("_ID42367", "_ID15588", objpositions)
                        game:scriptcall("_ID42367", "_ID25325", objectivenumber, breachindices[1], breachindices[2], breachindices[3], breachindices[4])

                        level:onnotifyonce("top_deck_room_breached", function()
                            game:scriptcall("maps/_utility", "_ID25326", objectivenumber)

                            level:onnotifyonce("barracks_cleared", function()
                                game:ontimeout(function()
                                    game:objective_state(objective_number, "done")
                                end, 1000)
                            end)
                        end)
                    end)
                end)
            end)
        end)
    end)
end

function firstbreachcleared()
    musicloop("mus_oilrig_fight_music_01")

    game:ontimeout(function()
        radiodialogue("oilrig_sbc_gettolz")
    end, 2000)

    level._ID52474 = game:getnodearray("node_hostage_scaffolding", "targetname")
	local volumeambushroom = game:getent("volume_ambush_room", "script_noteworthy")
    hostageevac(volumeambushroom)
    alarm()

    game:ontimeout(function()
        game:overridedvarint("specialops", 1)
        
        game:scriptcall("maps/oilrig", "_ID45005", nil, true) -- open gate
        game:scriptcall("maps/oilrig", "_ID47645", "dummy_spawner_ballsout_intro")
        game:scriptcall("maps/oilrig", "_ID47645", "dummy_spawner_ballsout")

        level:onnotifyonce("player_at_deck1_midpoint", function()
            docktworappellers()

            game:ontimeout(helientersandattacks, 10000)

            level:onnotifyonce("player_at_stairs_to_top_deck", function()
                game:overridedvarint("specialops", 1)
                game:scriptcall("maps/oilrig", "_ID53812")

                level:onnotifyonce("smoke_firefight", function()
                    game:ontimeout(function()
                        if (cointoss()) then
                            radiodialogue("oilrig_use_thermal_00")
                        else
                            radiodialogue("oilrig_use_thermal_00")
                        end
                    end, 2000)
                end)

                level:onnotifyonce("player_approaching_topdeck_building", function()
                    radiodialogue("oilrig_sbc_hostconfirmed")

                    level:onnotifyonce("top_deck_room_breached", function()
                        game:overridedvarint("specialops", 0)
                        game:musicstop()

                        level:onnotifyonce("barracks_cleared", function()
                            game:musicstop()

                            game:ontimeout(function()
                                musicloop("mus_oilrig_victory_music")
                            end, 500)

                            game:ontimeout(function()
                                missionover(true)
                            end, 2000)
                        end)
                    end)
                end)
            end)
        end)
    end, 10000)
end

function breachflags()
    level:onnotifyonce("breach_explosion", function()
        flagset("upper_room_breached")
        game:ontimeout(function()
            level:onnotifyonce("breach_explosion", function()
                flagset("top_deck_room_breached")
            end)
        end, 2000)
    end)
end

function hostageevac(volume)
    local hostages = volume:scriptcall("maps/_utility", "_ID15547", "neutral")
    if (flag("oilrig_mission_failed")) then
        return
    end

    if (flag("missionfailed")) then
        return
    end

    for i = 1, #hostages do
        game:scriptcall("maps/oilrig", "_ID47778", hostages[i])
    end

    aideletewhenoutofsight(hostages, 512)
end

function startmap()
    setplayerpos()
    game:scriptcall("maps/_compass", "setupminimap", "compass_map_oilrig_lvl_1")
    
    -- enable rendering groups
    flagset("portal_secondfloor_flag")
    game:enablepg("portal_secondfloor", 1)
    game:enablepg("portal_secondfloorbreach", 1)
    game:enablepg("portal_secondbreach", 1)

    player:takeweapon("scar_h_thermal_silencer")
    player:giveweapon("m1014")
    player:givemaxammo("m1014")

    -- random script_model
    game:getentbyref(2044, 0):hide()

    level._ID18992 = false

    enablechallengetimer("breaching_on", "eternity")
    breachflags()
    objmain()

    player._ID28001 = nil
    player:setmovespeedscale(1)

    battlechatteron("axis")

    game:ontimeout(function()
        radiodialogue("oilrig_sbc_civilhostages")
    end, 2000)

    level:onnotifyonce("upper_room_breached", function()
        game:musicstop()
    end)
    level:onnotifyonce("upper_room_cleared", firstbreachcleared)

    game:ontimeout(function()
        musicloop("mus_oilrig_sneak_music")
    end, 0)
    
    game:scriptcall("maps/oilrig", "_ID50414")
end

map.main = function()
    local removetriggers = game:getentarray("redshirt_trigger", "targetname")
    for i = 1, #removetriggers do
        removetriggers[i]:delete()
    end
    
    game:scriptcall("maps/_utility", "_ID1951", "start_map", startmap)
    mainhook.invoke(level)
    game:scriptcall("maps/_utility", "_ID10126", startmap)

    game:scriptcall("maps/oilrig", "_ID48391")
    game:scriptcall("common_scripts/utility", "_ID14402", "above_water_visuals")
end

return map
