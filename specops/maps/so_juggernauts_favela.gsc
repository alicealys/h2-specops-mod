main()
{
    level.pmc_gametype = "mode_elimination";
	level.pmc_enemies = 10;
	level.pmc_alljuggernauts = true;
	level.pmc_enemies_alive = 1;
	level.pmc_low_enemy_count = 3;

	common_scripts\utility::array_call(getentarray("placed_weapon", "script_noteworthy"), ::delete);

    visionsetnaked("favela", 0);
    visionsetnaked("favela_shanty", 0);

    _id_B61E::main();
    _id_C8A2::main();
    _id_B183::main();
    _id_CBBD::main();
    maps\favela_anim::main();
    _id_C8D3::main();
    maps\_load::set_player_viewhand_model("viewhands_player_tf141_favela");
	maps\_pmc::preLoad();
    maps\_load::main();
    maps\favela_aud::main();
    maps\favela_lighting::main();

    maps\_utility::activate_trigger("vision_shanty", "script_noteworthy");

    getent("favela_soccerball_1", "targetname") hide();
    getent("favela_soccerball_2", "targetname") hide();

	maps\_pmc::main();

	thread scale_juggernaut_enemies();
}

delete_hiding_door_disconnect()
{
	self connectPaths();
	self delete();
}

scale_juggernaut_enemies()
{
	while (true)
	{
		level waittill("update_enemies_remaining_count");
		
		if (level.pmc.enemies_remaining >= 9)
        {
			level.pmc.max_ai_alive = 1;
        }
		else if (level.pmc.enemies_remaining >= 7)
        {
			level.pmc.max_ai_alive = 2;
        }
		else
        {
			level.pmc.max_ai_alive = 3;
        }
	}
}
