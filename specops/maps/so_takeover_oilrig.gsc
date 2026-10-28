main()
{
	precachemodel("com_barrel_white_rust");
	precachemodel("com_barrel_blue_rust");
	
	// settings for this challenge
	level.pmc_gametype = "mode_elimination";
	level.pmc_enemies = 15;
	level.pmc_alljuggernauts = true;
	level.pmc_enemies_alive = 1;
	level.pmc_low_enemy_count = 3; // Used for pulsing the hud

    maps\_specialops::so_delete_breach_ents();

    _id_CA20::main();
    _id_D31E::main();
    _id_CE2B::main();
    maps\oilrig_anim::main();
    _id_AA61::main();
    maps\_pmc::preload();
    maps\_load::main();
    maps\_pmc::main();
    maps\oilrig_aud::main();
    maps\oilrig_lighting::main();
    box = getent("underwater_box", "targetname");
    box hide();

    thread scale_juggernaut_enemies();
	thread maps\oilrig::_id_BD07();
    
    door1 = getent("door_deck1", "targetname");
    door1 connectpaths();
    door1 delete();
    
    door3 = getent("door_deck1_animated", "targetname");
    door3 connectpaths();
    door3 delete();

    clip = getent("door_clip_deck1", "targetname");
    clip delete();

    door2 = getent("door_deck1_opposite", "targetname");
    door2 connectpaths();
    door2 delete();
    
    gate = getent("gate_01", "targetname");
	gate connectpaths();
	gate moveto((gate.origin - (0, -170, 0)), 1);
	
	fix_c4_barrels();

    maps\_compass::setupminimap("compass_map_oilrig_lvl_1");
	common_scripts\utility::array_thread(getentarray("compassTriggers", "targetname"), ::compass_triggers_think);
	common_scripts\utility::array_thread(getentarray("compassTriggers", "targetname"), maps\oilrig::_id_BD74);
	common_scripts\utility::array_call(getentarray("hide", "script_noteworthy"), ::hide);

	dds = getentarray("sub_dds_01", "targetname");
	door_dds = getentarray("dds_door_01", "targetname");
	common_scripts\utility::array_thread(dds, maps\_utility::hide_entity);
	common_scripts\utility::array_thread(door_dds, maps\_utility::hide_entity);

	dds = getentarray("sub_dds_02", "targetname");
	door_dds = getentarray("dds_door_02", "targetname");
	common_scripts\utility::array_thread(dds, maps\_utility::hide_entity);
	common_scripts\utility::array_thread(door_dds, maps\_utility::hide_entity);

	common_scripts\utility::flag_set("above_water_visuals");
}

fix_c4_barrels()
{
	common_scripts\utility::array_call(getentarray("c4barrelPacks", "script_noteworthy"), ::delete);
	
	barrels = getentarray("c4_barrel", "script_noteworthy");
	foreach (barrel in barrels)
	{
		if (common_scripts\utility::cointoss())
        {
			barrel setmodel("com_barrel_white_rust");
        }
		else
        {
			barrel setmodel("com_barrel_blue_rust");
        }
	}
}

save_triggers()
{
	common_scripts\utility::array_thread(getentarray("compassTriggers", "targetname"), ::make_special_op_ent);
	getent("killtrigger_ocean", "targetname") make_special_op_ent();
}

make_special_op_ent()
{
	assert(isdefined(self));
	self.script_specialops = 1;
}

compass_triggers_think()
{
	assertex(isdefined(self.script_noteworthy ), "compassTrigger at " + self.origin + " needs to have a script_noteworthy with the name of the minimap to use");
	while (true)
	{
		wait 1;
		self waittill("trigger");
		setsaveddvar("ui_hidemap", 0);
		maps\_compass::setupminimap(self.script_noteworthy);
	}
}

scale_juggernaut_enemies()
{
	while (true)
	{
		level waittill("update_enemies_remaining_count");
		
		if (level.pmc.enemies_remaining >= 12)
        {
			level.pmc.max_ai_alive = 1;
        }
		else if (level.pmc.enemies_remaining >= 8)
        {
			level.pmc.max_ai_alive = 2;
        }
		else
        {
			level.pmc.max_ai_alive = 3;
        }
	}
}
