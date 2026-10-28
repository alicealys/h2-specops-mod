main()
{
	no_prone_water = getentarray("no_prone_water", "targetname");
	foreach(trigger in no_prone_water)
    {
		trigger.script_specialops = 1;
    }

	level.pmc_gametype = "mode_elimination";
	level.pmc_enemies = 40;
	level.pmc_low_enemy_count = 5; // Used for pulsing the hud

    _id_B22E::main();
    _id_C989::main();
    _id_C908::main();
    maps\estate_anim::main();
    _id_BA9C::main();
    maps\estate_aud::main();
    maps\estate_lighting::main();
    maps\estate_beautiful_corner::_id_C85F();

    maps\_pmc::preload();
    maps\_load::main();
    maps\_pmc::main();

    thread remove_sp_elements();

    maps\_compass::setupMiniMap("compass_map_estate");
}

remove_sp_elements()
{
	getent( "fake_backwards_door", "targetname" ) delete();
	getent( "fake_backwards_door_clip", "targetname" ) delete();
	getent( "recroom_closed_doors", "targetname" ) delete();
	getent( "dsm", "targetname" ) delete();
	getent( "dsm_obj", "targetname" ) delete();
	
	common_scripts\utility::array_call( getentarray( "window_newspaper", "targetname" ), ::delete );
	common_scripts\utility::array_call( getentarray( "window_pane", "targetname" ), ::delete );
	common_scripts\utility::array_call( getentarray( "window_brokenglass", "targetname" ), ::delete );
	common_scripts\utility::array_call( getentarray( "window_blinds", "targetname" ), ::delete );
	common_scripts\utility::array_call( getentarray( "paper_window_sightblocker", "targetname" ), ::delete );
	common_scripts\utility::array_call( getentarray( "sp_claymore_pickups", "targetname" ), ::delete );
}
