local map = {}

map.premain = function()
    game:visionsetnaked("invasion", 0)
    game:getent("back_door_col", "targetname"):delete()
end

map.preover = function()

end

function iscustomflagtrigger(ent)
	if (defined(ent.script_specialops) or not defined(ent.classname)) then
        return false
    end
		
	local classnames = {
        ["trigger_multiple_flag_set"] = true,
        ["trigger_multiple_flag_set_touching"] = true,
        ["trigger_multiple_flag_clear"] = true,
        ["trigger_multiple_flag_looking"] = true,
        ["trigger_multiple_flag_lookat"] = true,
    }
	
	return classnames[ent.classname] == true
end

map.main = function()
    setloadout("ump45_digital_eotech", "deserteagle", "fraggrenade", "flash_grenade", "viewmodel_base_viewhands", "american")
    setloadoutequipment("c4", "claymore")

    deletenonspecialops({
        isspawntrigger,
        isspawner,
        iskillspawnertrigger,
        isgoalvolume,
        iscustomflagtrigger
    })

    player:notifyonplayercommand("enter_chopper", "+actionslot 2")
    player:onnotify("enter_chopper", function()
        print(level.chopper)
        player:cameralinkto(level.chopper, "tag_turret")
        player:controlsunlink(level.chopper)
        --player:playerlinkto(level.chopper, "tag_turret")
        --_id_D3D6::_id_C24F( true, player, false )
        --level.chopper:scriptcall("_id_D3D6", "_id_C24F")
    end)


    mainhook.invoke(level)

    setcompassdist("far")
    setplayerpos()
    enableallportalgroups()
    intro()
end

return map
