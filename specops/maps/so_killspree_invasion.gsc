#include maps\_specialops;
#include maps\so_killspree_invasion_code;

main()
{
    _id_B7D3::main();
    _id_D59F::main("vehicle_mi-28_flying", "mi28", "script_vehicle_mi28");
    _id_D4C5::main();
    _id_C75F::main();
    maps\invasion_anim::_id_A902();
    maps\invasion_lighting::main();
    maps\invasion::_id_C21D();

	precacheitem("smoke_grenade_american");
	precacheitem("remote_missile_not_player_invasion");
	precachemodel("weapon_stinger_obj");
	precachemodel("weapon_uav_control_unit_obj");
	precacheitem("flash_grenade");
	
	precacheitem("zippy_rockets");
	precacheitem("stinger_speedy");

	precachestring(&"SO_KILLSPREE_INVASION_OBJ_REGULAR");
	precachestring(&"SO_KILLSPREE_INVASION_OBJ_HARDENED");
	precachestring(&"SO_KILLSPREE_INVASION_OBJ_VETERAN");
	precachestring(&"SO_KILLSPREE_INVASION_SCORE_ASSIST");
	precachestring(&"SO_KILLSPREE_INVASION_SCORE_KILL");
	precachestring(&"SO_KILLSPREE_INVASION_SCORE_BTR80");
	precachestring(&"SO_KILLSPREE_INVASION_SPLASH_COMBO");
	precachestring(&"SO_KILLSPREE_INVASION_SPLASH_BONUS");
	precachestring(&"SO_KILLSPREE_INVASION_HUD_REMAINING");
	precachestring(&"SO_KILLSPREE_INVASION_SCORE_BRUTAL");
	precachestring(&"SO_KILLSPREE_INVASION_SCORE_DOWNED");
	precachestring(&"SO_KILLSPREE_INVASION_SCORE_FINISHED");
	precachestring(&"SO_KILLSPREE_INVASION_DEADQUOTE_HINT1");
	precachestring(&"SO_KILLSPREE_INVASION_DEADQUOTE_HINT2");
	precachestring(&"SO_KILLSPREE_INVASION_DEADQUOTE_HINT3");
	precachestring(&"SO_KILLSPREE_INVASION_DEADQUOTE_HINT4");
	precachestring(&"SO_KILLSPREE_INVASION_DEADQUOTE_HINT5");
	precachestring(&"SO_KILLSPREE_INVASION_EOG_SOLID");
	precachestring(&"SO_KILLSPREE_INVASION_EOG_HEARTLESS");
	precachestring(&"SO_KILLSPREE_INVASION_EOG_COMBOS");
	precachestring(&"SO_KILLSPREE_INVASION_EOG_SCORE");
	precachestring(&"SO_KILLSPREE_INVASION_EOG_COMBOS_X");
	
	maps\_utility::add_start("so_killspree", ::start_so_killspree);
    maps\_load::main();
	maps\_compass::setupminimap("compass_map_invasion");
}

// ---------------------------------------------------------------------------------
//	challenge initializations
// ---------------------------------------------------------------------------------
start_so_killspree()
{
	so_killspree_init();
	
	//thread music_loop("so_killspree_invasion_music", 124);
	thread enable_nates_exploders();
	thread enable_challenge_timer("challenge_start", "challenge_success");
	thread enable_kill_counter_hud();
	common_scripts\utility::flag_wait("challenge_start");

	thread enable_hunter_enemy_group_gas_station(10);
	thread enable_btr80_circling_street();
	thread enable_btr80_circling_parking_lot();
	thread enable_hunter_truck_enemies_bank(); 
	thread enable_hunter_enemy_refill(10, 4, 8);
}

so_killspree_init()
{
	common_scripts\utility::flag_init("challenge_start");
	common_scripts\utility::flag_init("challenge_success");

	so_killspree_setup_radio_dialog();
	
	switch (level.gameskill)
	{
		case 0:	// easy
		case 1:	so_killspree_setup_regular();	break;	// regular
		case 2:	so_killspree_setup_hardened();	break;	// hardened
		case 3:	so_killspree_setup_veteran();	break;	// veteran
	}

	objective_add(1, "current", level.challenge_objective);

	// remove unwanted weapons
	sentries = getentarray("misc_turret", "classname");
	foreach (sentry in sentries)
		sentry delete();
	stingers = getentarray("weapon_stinger", "classname");
	foreach (stinger in stingers)
		stinger delete();
	
	// initialize scoring
	level.points_p1 = 0;
	level.points_p1_display = level.points_p1;
	level.points_p2 = 0;
	level.points_p2_display = level.points_p2;
	level.points_counter = scale_value(level.points_goal);
	level.points_counter_display = level.points_counter;
	level.points_base_flash = scale_value(10);
	level.points_combo_base = scale_value(0.25);
	foreach (player in level.players)
		player.points_combo_unused = 0;

	level.points_max = level.points_counter;

	// put a clamp on how often the player is alerted to hunter spawn points.
	level.hunter_dialog_throttle = 20000;

	// smoke chance when spawning bank or taco enemies.
	level.smoke_chance = 0.33;
	level.smoke_throttle = 60000;
	
	level.btr80_alert_throttle = 10000;
	
	// amount enemies give for score.
	level.btr_kill_value		= scale_value(40);
	level.hunter_kill_value		= scale_value(10);
	level.hunter_finish_value	= scale_value(5);
	level.hunter_brutal_value	= scale_value(20);
	level.combo_time_window		= 4;
	// prevent player from leaving the valid play space.
	//thread enable_escape_warning();
	//thread enable_escape_failure();

	// open doors around the map.
	door_diner_open();
	//door_nates_locker_open();
	//door_bt_locker_open();
	
	// remove ladder clips that are there to help the player in sp.
	ladder_clip = getent("nates_kitchen_ladder_clip", "targetname");
	ladder_clip delete();
	ladder_clip = getent("bt_ktichen_ladder_clip", "targetname");
	ladder_clip delete();

	// remove ladders entirely
	ladder_ents = getentarray("inv_ladders", "script_noteworthy");
	foreach (ent in ladder_ents)
		ent delete();
	ladder_ents = getentarray("inv_ladders_pathblocker", "script_noteworthy");
	foreach (ent in ladder_ents)
		ent disconnectpaths();
	
	// remove the predator control unit
	ent = getent("predator_drone_control", "targetname");
	ent delete();
	
	level.custom_eog_no_kills = true;
	level.custom_eog_no_partner = true;
	level.eog_summary_callback = ::custom_eog_summary;
	foreach (player in level.players)
	{
		player.solid_kills = 0;
		player.heartless_kills = 0;
		player.highest_combo = 0;
		player.total_score = 0;
	}

	level.player.total_score = scale_value(level.points_goal);
	
	deadquotes = [];
	deadquotes[deadquotes.size] = "@so_killspree_invasion_deadquote_hint1";
	deadquotes[deadquotes.size] = "@so_killspree_invasion_deadquote_hint2";
	deadquotes[deadquotes.size] = "@so_killspree_invasion_deadquote_hint3";
	deadquotes[deadquotes.size] = "@so_killspree_invasion_deadquote_hint4";
	deadquotes[deadquotes.size] = "@so_killspree_invasion_deadquote_hint5";

	//so_include_deadquote_array(deadquotes);
	
	// clear out some flags on enemies being used in the level.
	// enable when burger_town enemies are brought over, and spawn function updated
	// to send back how many were *actually* spawned so refill can work properly.
/*	convert_enemies = getentarray("gas_station_enemies", "targetname");
	convert_enemies = array_merge(convert_enemies, getentarray("bank_enemies", "targetname"));
	convert_enemies = array_merge(convert_enemies, getentarray("taco_enemies", "targetname"));
	convert_enemies = array_merge(convert_enemies, getentarray("burger_town_enemies", "targetname"));
	foreach (guy in convert_enemies)
	{
		if (isdefined(guy.script_goalvolume))
			guy.script_goalvolume = undefined;
		if (isdefined(guy.script_forcespawn))
			guy.script_forcespawn = undefined;
	}*/
}

scale_value(value)
{
	return int(value * 100);
}

so_killspree_setup_regular()
{
	level.points_goal = 300;
	level.challenge_objective = &"SO_KILLSPREE_INVASION_OBJ_REGULAR";
}

so_killspree_setup_hardened()
{
	level.points_goal = 300;
	level.challenge_objective = &"SO_KILLSPREE_INVASION_OBJ_HARDENED";
}

so_killspree_setup_veteran()
{
	level.points_goal = 300;
	level.challenge_objective = &"SO_KILLSPREE_INVASION_OBJ_VETERAN";
}

so_killspree_setup_radio_dialog()
{
	level.scr_radio["so_def_inv_thermaloptics"]	= "so_def_inv_thermaloptics";
	level.scr_radio["so_def_inv_bmpspottedyou"]	= "so_def_inv_bmpspottedyou";
}

// ---------------------------------------------------------------------------------
//	enable/disable events
// ---------------------------------------------------------------------------------

// ---------------------------------------------------------------------------------

custom_eog_summary()
{
	foreach (player in level.players)
	{
		//player add_custom_eog_summary_line("@so_killspree_invasion_eog_solid",		player.solid_kills);
		//player add_custom_eog_summary_line("@so_killspree_invasion_eog_heartless",	player.heartless_kills);
		//player add_custom_eog_summary_line("@so_killspree_invasion_eog_combos",	player.highest_combo);
		//player add_custom_eog_summary_line("@so_killspree_invasion_eog_score",		hud_convert_to_points(player.total_score));
	}
}

// ---------------------------------------------------------------------------------

enable_kill_counter_hud()
{
	level.pulse_requests = [];
	level.pulse_requests_p1 = [];
	level.pulse_requests_p2 = [];
	foreach (player in level.players)
		player thread hud_splash_destroy();

	common_scripts\utility::array_thread(level.players, ::hud_create_kill_counter);
}

// ---------------------------------------------------------------------------------

enable_nates_exploders()
{
	thread fire_off_exploder(getent("north_side_low", "targetname"));
	thread fire_off_exploder(getent("north_side_high", "targetname"));
	thread fire_off_exploder(getent("west_side", "targetname"));
}

// ---------------------------------------------------------------------------------

enable_smoke_wave_north(dialog_wait, flag_start)
{
	create_smoke_wave("magic_smoke_grenade_north", flag_start, dialog_wait);
}

enable_smoke_wave_south(dialog_wait, flag_start )
{
	create_smoke_wave("magic_smoke_grenade", flag_start, dialog_wait);
}

// ---------------------------------------------------------------------------------

enable_hunter_truck_enemies_bank(flag_start)
{
	create_hunter_truck_enemies("truck_north_right", flag_start);
}

enable_hunter_truck_enemies_road(flag_start)
{
	create_hunter_truck_enemies("truck_north_left", flag_start);
}

// ---------------------------------------------------------------------------------

enable_btr80_circling_street(flag_start)
{
	create_btr80("nate_attacker_left", flag_start);
}

enable_btr80_circling_parking_lot(flag_start)
{
	create_btr80("nate_attacker_mid", flag_start);
}

// ---------------------------------------------------------------------------------

enable_hunter_enemy_refill(refill_at, min_fill, max_fill)
{
	hunter_enemies_refill(refill_at, min_fill, max_fill);
}

enable_hunter_enemy_group_bank(enemy_count, flag_start)
{
	create_hunter_enemy_group("bank_enemies", flag_start, enemy_count);
}

enable_hunter_enemy_group_gas_station(enemy_count, flag_start)
{
	create_hunter_enemy_group("gas_station_enemies", flag_start, enemy_count);
}

enable_hunter_enemy_group_taco(enemy_count, flag_start)
{
	create_hunter_enemy_group("taco_enemies", flag_start, enemy_count);
}

// ---------------------------------------------------------------------------------