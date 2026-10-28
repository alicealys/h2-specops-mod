#include maps\_specialops;

DEFEND_ENEMY_BUILDUP_COUNT_FRACTION  = 0.9;
MIN_SPAWN_DISTANCE 					 = 1024;
DEFAULT_ENEMY_GOAL_RADIUS_MIN 		 = 512;
DEFAULT_ENEMY_GOAL_RADIUS_MAX 		 = 2500;
DEFAULT_ENEMY_GOAL_HEIGHT			 = 128;
DEFAULT_ENEMY_GOAL_HEIGHT_JUGGERNAUT = 81;
DEFAULT_ENEMY_GOAL_HEIGHT_SNIPER	 = 640;
ENEMY_GOAL_RADIUS_SEEK_PLAYER_MIN 	 = 1200;
ENEMY_GOAL_RADIUS_SEEK_PLAYER_MAX 	 = 1600;
SEEK_PLAYERS_ENEMY_COUNT 			 = 6;
TIME_REMAINING_FLASH_WAYPOINT 		 = 2 * 60;
AI_INSIDE_TRANSPORT_CHOPPER			 = 6;	// this shouldn't be changed, it's only for info, it doesn't actually change the number that go into the chopper
MAX_ENEMIES_ALIVE_ELIMINATION		 = 25;
DEFEND_SETUP_TIME					 = 180;
DEFEND_TIME							 = 5 * 60;
JUGGERNAUT_ENEMY_VISIBLE_TIMEOUT	 = 20;

preload()
{
	level.pmc_match = true;
	level.teambased = false;	
	maps\_juggernaut::main();
	level._effect["extraction_smoke"] = loadfx("smoke/green_flare_smoke_distant");
}

main()
{
	assert(isdefined(level.pmc_gametype));
	assert(isdefined(level.pmc_enemies));
	assert(level.pmc_enemies > 0);
	if (isdefined(level.pmc_enemies_alive))
		assert(level.pmc_enemies_alive > 0);
	
	if (isdefendmatch())
	{
		assert(isdefined(level.pmc_defend_enemy_count));
		assert(level.pmc_defend_enemy_count > 0);
	}
	
	if (!isdefined(level.pmc_alljuggernauts))
		level.pmc_alljuggernauts = false;
	
	//-------------------------------------------------------------

	_id_D2A4::main();

	initialize_gametype();

	start_pmc_gametype();
}

initialize_gametype()
{
	juggernaut_setup();
	//--------------------------------
	// precache
	//--------------------------------

	// enemies alive: &&1
	precachestring(&"PMC_DEBUG_ENEMY_COUNT");
	// vehicles alive: &&1
	precachestring(&"PMC_DEBUG_VEHICLE_COUNT");
	// enemy spawners: &&1
	precachestring(&"PMC_DEBUG_SPAWNER_COUNT");
	// enemies remaining: &&1
	precachestring(&"PMC_ENEMIES_REMAINING");
	// time remaining: &&1
	precachestring(&"PMC_TIME_REMAINING");
	// kill all enemies in the level.
	precachestring(&"PMC_OBJECTIVE_KILL_ENEMIES");
	// kill all enemies in the level [&&1 remaining].
	precachestring(&"PMC_OBJECTIVE_KILL_ENEMIES_REMAINING");
	// enter the abort codes into the laptop before time runs out.
	precachestring(&"PMC_OBJECTIVE_ABORT_CODES");
	// mission failed. the objective was not completed in time.
	precachestring(&"PMC_OBJECTIVE_FAILED");
	// spectating
	precachestring(&"PMC_SPECTATING");
	// reach the extraction zone before time runs out.
	precachestring(&"PMC_OBJECTIVE_EXTRACT");
	// press and hold &&1 to use the laptop.
	precachestring(&"PMC_HINT_USELAPTOP");
	// set up a defensive position before enemy attack.
	precachestring(&"PMC_OBJECTIVE_SETUP_DEFENSES");
	// time until attack: &&1
	precachestring(&"PMC_TIME_UNTIL_ATTACK");
	// survive until time runs out.
	precachestring(&"PMC_OBJECTIVE_DEFEND");
	// press and hold &&1 on the laptop to skip set up time.
	precachestring(&"PMC_START_ATTACK_USE_HINT");
	// approach the laptop to skip set up time.
	precachestring(&"PMC_START_ATTACK_HINT");
	// hq damage
	precachestring(&"PMC_HQ_DAMAGE");
	// retrieving intel...
	precachestring(&"PMC_HQ_RECOVERING_INTEL");
	
	precachemodel("com_laptop_open");
	
	precacheshader("waypoint_ammo");
	precacheshader("waypoint_target");
	precacheshader("waypoint_extraction");
	precacheshader("waypoint_defend");
	
	//--------------------------------
	// set up some tweak values
	//--------------------------------
	
	setdvarifuninitialized("pmc_debug", "0");
	setdvarifuninitialized("pmc_debug_forcechopper", "0");
	
	level.pmc = spawnstruct();
	level.pmc.hud = spawnstruct();
	level.pmc.sound = [];
//	level.pmc.music = [];

	level.pmc.defendsetuptime = DEFEND_SETUP_TIME;
	level.pmc.defendtime = DEFEND_TIME;
	
	if (isdefined(level.pmc_enemies_alive))
		level.pmc.max_ai_alive = level.pmc_enemies_alive;
	else
		level.pmc.max_ai_alive = MAX_ENEMIES_ALIVE_ELIMINATION;
	
	level.pmc.enemy_goal_radius_min = DEFAULT_ENEMY_GOAL_RADIUS_MIN;
	level.pmc.enemy_goal_radius_max = DEFAULT_ENEMY_GOAL_RADIUS_MAX;
//	level.pmc.music["exfiltrate"] 		 = "pmc_music_extract";
//	level.pmc.music["mission_complete"] 	 = "pmc_victory_music";
	level.pmc.sound["exfiltrate"] 		 = "pmc_exfiltrate_area";
	level.pmc.sound["obj_win"] 			 = "pmc_outta_here";
	level.pmc.sound["obj_fail"] 			 = "pmc_mission_failed";
	level.pmc.sound["minutes_6"] 			 = "pmc_6_minutes";
	level.pmc.sound["minutes_4"] 			 = "pmc_4_minutes";
	level.pmc.sound["minutes_3"] 			 = "pmc_3_minutes";
	level.pmc.sound["minutes_2"] 			 = "pmc_2_minutes";
	level.pmc.sound["minutes_1"] 			 = "pmc_1_minute";
	level.pmc.sound["minutes_30sec"][0]	 = "pmc_time_almost_up";
	level.pmc.sound["minutes_30sec"][1]  = "pmc_running_out_of_time";
	level.pmc.sound["timer_tick"] 		 = "pmc_timer_tick";
//	level.pmc.sound["juggernaut_attack"] 	 = "pmc_juggernaut";

	//--------------------------------
	// variables and init
	//--------------------------------

	common_scripts\utility::flag_init("enemies_seek_players");
	common_scripts\utility::flag_init("objective_complete");
	common_scripts\utility::flag_init("extraction_complete");
	common_scripts\utility::flag_init("defend_started");
	common_scripts\utility::flag_init("pmc_DEFEND_SETUP_TIME_finished");
	common_scripts\utility::flag_init("defend_failed");
	common_scripts\utility::flag_init("remove_caches");
	common_scripts\utility::flag_init("exfiltrate_music_playing");
	common_scripts\utility::flag_init("mission_complete");
	common_scripts\utility::flag_init("mission_start");
	
	common_scripts\utility::flag_init("staged_pacing_used");
	common_scripts\utility::flag_init("pacing_stage_2");
	common_scripts\utility::flag_init("pacing_stage_3");

	// delete the stuff that is only for hostage mode for now.
	common_scripts\utility::run_thread_on_noteworthy("hostage_only", maps\_utility::self_delete);

	// make slowmo breach spawners run the pmc logic
	common_scripts\utility::run_thread_on_noteworthy("pmc_spawner", maps\_utility::add_spawn_function, ::room_breach_spawned);

	level.pmc.helicopter_exists = false;
	level.pmc.helicopter_queuing = false;
	level.pmc.helicopter_transport_last = undefined;
	level.pmc.helicopter_transport_min_time = 90 * 1000;// seconds * 1000
	level.pmc.helicopter_attack_last = undefined;
	level.pmc.helicopter_attack_min_time = 90 * 1000;// seconds * 1000

	level.pmc.enemy_vehicles_alive = 0;

	level.sentry_pickups = getentarray("script_model_pickup_sentry_gun", "classname");
	level.sentry_pickups = common_scripts\utility::array_combine(level.sentry_pickups, getentarray("script_model_pickup_sentry_minigun", "classname"));
	
	level.pmc.send_in_juggernaut = false;
	level.pmc.juggernauts_spawned = 0;
	level.pmc.juggernauts_killed = 0;
	level.pmc.spawned_juggernaut_at_game_start = false;
	level.pmc.spawned_juggernaut_at_game_start_counter = 5;
}

start_pmc_gametype()
{
	set_gametype_vars();
	
	thread maps\_specialops::fade_challenge_in();
	thread maps\_specialops::fade_challenge_out("mission_complete");
		
	//if (!isdefendmatch())
	//	array_thread(level.sentry_pickups, ::delete_sentry_pickup);
	
	//get an array of pre-placed enemy sentry guns
	level.sentry_enemies = getentarray("sentry_gun", "targetname");
	level.sentry_enemies = common_scripts\utility::array_combine(level.sentry_enemies, getentarray("sentry_minigun", "targetname"));
	
	if (isdefendmatch())
		common_scripts\utility::array_thread(level.sentry_enemies, _id_D2A4::_id_AE99);
	
	//----------------------------------------
	// set gametype specific function pointers
	//----------------------------------------

	level.pmc.enemy_spawn_position_func = ::pick_enemy_spawn_positions;
	level.pmc.populate_enemies_func = ::populate_enemies;
	level.pmc.get_spawnlist_func = ::get_spawnlist;
	level.pmc.set_goal_func = ::enemy_set_goal_when_player_spotted;
	level.pmc.limitrespawns = true;
	if (isdefendmatch())
	{
		level.pmc.enemy_spawn_position_func = ::pick_enemy_spawn_positions_defend;
		level.pmc.populate_enemies_func = ::populate_enemies;
		level.pmc.get_spawnlist_func = ::get_spawnlist_defend;
		level.pmc.set_goal_func = ::enemy_seek_objective_in_stages;
		level.pmc.limitrespawns = false;
	}
	else
	{
		thread staged_pacing_system();// obj and elimination, not defend
	}

	assert(isdefined(level.pmc.enemy_spawn_position_func));
	assert(isdefined(level.pmc.populate_enemies_func));
	assert(isdefined(level.pmc.get_spawnlist_func));
	assert(isdefined(level.pmc.set_goal_func));

	//----------------------------------------
	// get all enemy spawners in level
	//----------------------------------------

	// get all enemy spawners in the level for possible spawning
	level.pmc.enemy_spawners_full_list = getentarray("pmc_spawner", "targetname");
	assertex(level.pmc.enemy_spawners_full_list.size >= level.pmc_enemies, "there aren't enough enemy spawners in the level.");
	
	[[level.pmc.enemy_spawn_position_func]]();

	assert(isdefined(level.pmc.enemy_spawners));
	assert(level.pmc.enemy_spawners.size > 0);
	assert(isdefined(level.pmc.enemy_spawners_full_list));
	assert(level.pmc.enemy_spawners_full_list.size > 0);

	debug_print("found " + level.pmc.enemy_spawners.size + " enemy spawners");
	assertex(level.pmc.enemy_spawners.size >= level.pmc.enemies_kills_to_win, "there aren't enough enemy spawners in the level to hunt down " + level.pmc.enemies_kills_to_win + " enemies.");
	level.pmc.enemies_remaining = level.pmc.enemies_kills_to_win;

	//----------------------------------------
	// get us started!
	//----------------------------------------

	level.pmc._populating_enemies = false;
	level.pmc._re_populating_enemies = false;
	gametype_setup();
	setup_objective_entities();
	add_player_objectives();

	thread [[level.pmc.populate_enemies_func]]();

	//----------------------------------------
	// debug threads for testing
	//----------------------------------------

	if (getdvar("pmc_debug") == "1")
	{
		thread debug_show_enemy_spawners_count();
		thread debug_show_enemies_alive_count();
		thread debug_show_vehicles_alive_count();
	}
}

set_gametype_vars()
{
	/#
	// make sure the gametype is valid
	switch(level.pmc_gametype)
	{
		case "mode_elimination":
			debug_print("gametype: elimination");
			break;
		case "mode_objective":
			debug_print("gametype: objective");
			break;
		case "mode_defend":
			debug_print("gametype: defend");
			break;
		default:
			assertmsg("error selecting gametype");
	}
	#/
	
	level.pmc.enemies_kills_to_win = level.pmc_enemies;
	assert(level.pmc.enemies_kills_to_win > 0);
	
	if (isdefendmatch())
		level.pmc.max_ai_alive = level.pmc_defend_enemy_count;
}

pick_enemy_spawn_positions_defend()
{
	level.pmc.enemy_spawners = level.pmc.enemy_spawners_full_list;
}

pick_enemy_spawn_positions()
{
	color_gray = (0.3, 0.3, 0.3);
	color_red = (1, 0, 0);
	color_white = (1, 1, 1);
	color_blue = (0, 0, 1);
	color_green = (0, 1, 0);

	// get min and max x and y values for all possible spawners
	x_min = level.pmc.enemy_spawners_full_list[0].origin[0];
	x_max = level.pmc.enemy_spawners_full_list[0].origin[0];
	y_min = level.pmc.enemy_spawners_full_list[0].origin[1];
	y_max = level.pmc.enemy_spawners_full_list[0].origin[1];

	foreach (spawner in level.pmc.enemy_spawners_full_list)
	{
		if (spawner.origin[0] < x_min)
			x_min = spawner.origin[0];
		if (spawner.origin[0] > x_max)
			x_max = spawner.origin[0];
		if (spawner.origin[1] < y_min)
			y_min = spawner.origin[1];
		if (spawner.origin[1] > y_max)
			y_max = spawner.origin[1];
	}

	x_min -= 250;
	x_max += 250;
	y_min -= 250;
	y_max += 250;

	// occassional wait to prevent false infinite loop since this can't always be done on the first frame
	// it is however, always done while the player has a black screen overlay and isn't in gameplay
	wait 0.05;

	// draw the bounds of the area

	// set the number of divisions we will make to the area
	number_of_divisions = 5;

	// find how tall and wide each grid space will be with the given number of divisions
	width_x = abs(x_max - x_min);
	width_y = abs(y_max - y_min);
	division_spacing_x = width_x / number_of_divisions;
	division_spacing_y = width_y / number_of_divisions;

	averagequadradius = (division_spacing_x + division_spacing_y) / 4;
	level.pmc.enemy_goal_radius_min = int(averagequadradius * 0.8);
	level.pmc.enemy_goal_radius_max = int(averagequadradius * 1.2);

	// create a struct for each grid square so we can store info on each one
	numquads = number_of_divisions * number_of_divisions;
	level.quads = [];
	curent_division_x = 0;
	curent_division_y = 0;
	for (i = 0 ; i < numquads ; i++)
	{
		level.quads[i] = spawnstruct();
		level.quads[i].number = i;
		level.quads[i].containsspawners = false;
		level.quads[i].enemiesinquad = 0;

		level.quads[i].min_x = x_min + (division_spacing_x * curent_division_x);
		level.quads[i].max_x = level.quads[i].min_x + division_spacing_x;

		level.quads[i].min_y = y_max - (division_spacing_y * curent_division_y);
		level.quads[i].max_y = level.quads[i].min_y - division_spacing_y;

		curent_division_x++ ;
		if (curent_division_x >= number_of_divisions)
		{
			curent_division_x = 0;
			curent_division_y++ ;
		}
	}

	// see which quads don't have any spawners in them at all
	// so they aren't used in spawn logic
	foreach (spawner in level.pmc.enemy_spawners_full_list)
	{
		if (distance(maps\_utility::getaverageplayerorigin(), spawner.origin) <= MIN_SPAWN_DISTANCE)
			continue;
		quadindex = spawner get_quad_index();
		level.quads[quadindex].containsspawners = true;
	}

	// occassional wait to prevent false infinite loop since this can't always be done on the first frame
	// it is however, always done while the player has a black screen overlay and isn't in gameplay
	wait 0.05;

	// print the quad bounds and number on each quad

	randomized = undefined;

	// if most of the spawners in the map will be used then just throw all of them into the pool
	if (level.pmc.enemies_kills_to_win >= (level.pmc.enemy_spawners_full_list.size / 1.2))
	{
		spawnstouse = level.pmc.enemy_spawners_full_list;
		debug_print("using all spawners placed in the map as possible enemy locations because we're using almost all of the spawners!");
	}
	else
	{
		// we now know which quads contain possible spawners so lets put one spawner in each quad to start, then two once all quads are used, then three, etc
		randomized = common_scripts\utility::array_randomize(level.pmc.enemy_spawners_full_list);
		spawnstouse = [];
		allowedspawnersperquad = 1;
		loopcount = 0;
		for (;;)
		{
			loopcount = 0;
			foreach (spawner in randomized)
			{
				if (distance(maps\_utility::getaverageplayerorigin(), spawner.origin) <= MIN_SPAWN_DISTANCE)
					continue;

				quadindex = spawner get_quad_index();
				assert(level.quads[quadindex].containsspawners);
				assert(isdefined(level.quads[quadindex].enemiesinquad));

				// if this quad has already been used once we don't use it again
				if (level.quads[quadindex].enemiesinquad >= allowedspawnersperquad)
					continue;

				// this spawner is in a quad that hasn't been used yet so we can use it
				level.quads[quadindex].enemiesinquad++ ;

				// add this spawner to the spawnstouse array, and take it out of the future potential spawner list
				spawnstouse[spawnstouse.size] = spawner;
				randomized = common_scripts\utility::array_remove(randomized, spawner);

				// if we've reached the number of enemies to kill then move on
				if (spawnstouse.size >= level.pmc.enemies_kills_to_win)
					break;

				loopcount++ ;
				if (loopcount > 50)
				{
					loopcount = 0;
					// occassional wait to prevent false infinite loop since this can't always be done on the first frame
					// it is however, always done while the player has a black screen overlay and isn't in gameplay

					wait 0.05;
				}
			}
			allowedspawnersperquad++ ;
			if (spawnstouse.size >= level.pmc.enemies_kills_to_win)
				break;
			debug_print("still need more spawners");
		}
		assert(spawnstouse.size > 0);
		assert(spawnstouse.size <= level.pmc.enemies_kills_to_win);
		assert((spawnstouse.size + randomized.size) == level.pmc.enemy_spawners_full_list.size);
		randomized = undefined;
	}
	debug_print("all spawners are ready");

	level.pmc.enemy_spawners = spawnstouse;
}

get_quad_index()
{
	org_x = self.origin[0];
	org_y = self.origin[1];

	quadindex = undefined;
	foreach (quad in level.quads)
	{
		assert(isdefined(quad.number));
		if ((org_x >= quad.min_x) && (org_x <= quad.max_x) && (org_y >= quad.max_y) && (org_y <= quad.min_y))
		{
			assert(quad.number >= 0);
			assert(quad.number < level.quads.size);
			return quad.number;
		}
	}
	assertmsg("quad wasn't found in get_quad_index()");
}

populate_enemies()
{
	common_scripts\utility::flag_wait("mission_start");

	//---------------------------------------------------------------------
	// spawns all of the best located ai until the max alive ai count is reached
	//---------------------------------------------------------------------

	if (level.pmc._populating_enemies)
		return;
	level.pmc._populating_enemies = true;

	if (isdefendmatch())
		common_scripts\utility::flag_wait("pmc_DEFEND_SETUP_TIME_finished");

	prof_begin("populate_enemies");

	debug_print("populating enemies");

	aliveenemies = getaiarray("axis");
	assert(isdefined(aliveenemies));
	assert(aliveenemies.size + level.pmc.enemy_vehicles_alive <= level.pmc.max_ai_alive);
	if (level.pmc.limitrespawns)
		assert(aliveenemies.size + level.pmc.enemy_vehicles_alive <= level.pmc.enemies_remaining);

	// make sure we don't already have enough ai alive to beat the level
	if (level.pmc.limitrespawns)
	{
		if (aliveenemies.size + level.pmc.enemy_vehicles_alive >= level.pmc.enemies_remaining)
		{
			level.pmc._populating_enemies = false;
			return;
		}
	}

	// make sure we don't already have the most ai alive that we can have
	if (aliveenemies.size + level.pmc.enemy_vehicles_alive >= level.pmc.max_ai_alive)
	{
		level.pmc._populating_enemies = false;
		return;
	}

	// see how many ai we have room to spawn
	numbertospawn = level.pmc.max_ai_alive - (aliveenemies.size + level.pmc.enemy_vehicles_alive);
	freeaislots = getfreeaicount();
	if (numbertospawn > freeaislots)
		numbertospawn = freeaislots;

	assert(numbertospawn > 0);

	if (isdefendmatch())
	{
		if ((numbertospawn + AI_INSIDE_TRANSPORT_CHOPPER) < (level.pmc.max_ai_alive * DEFEND_ENEMY_BUILDUP_COUNT_FRACTION))
		{
			level.pmc._populating_enemies = false;
			return;
		}
	}

	// again, make sure that the new amount of ai we're about to spawn, plus the alive ai, doesn't
	// exceed the number of ai remaining to win. cap numbertospawn if required.
	if (level.pmc.limitrespawns)
	{
		if (aliveenemies.size + level.pmc.enemy_vehicles_alive + numbertospawn > level.pmc.enemies_remaining)
			numbertospawn = level.pmc.enemies_remaining - (aliveenemies.size + level.pmc.enemy_vehicles_alive);
		assert(numbertospawn > 0);
	}

	// make sure that we don't spawn ai on the ground if a chopper is in queue, because it's waiting to fill up
	if (level.pmc.helicopter_queuing)
	{
		if (numbertospawn >= AI_INSIDE_TRANSPORT_CHOPPER)
			level notify("spawn_chopper");
		level.pmc._populating_enemies = false;
		debug_print(numbertospawn + " ai are in chopper queue");
		return;
	}

	spawnlist = [[level.pmc.get_spawnlist_func]]();

	// spawn the spawnlist
	spawn_more_enemies(spawnlist, numbertospawn);

	prof_end("populate_enemies");

	level.pmc._populating_enemies = false;
}

get_spawnlist()
{
	// get array of enemy spawners in order of closest to farthest
	return common_scripts\utility::get_array_of_closest(maps\_utility::getaverageplayerorigin(), level.pmc.enemy_spawners, undefined, undefined, undefined, MIN_SPAWN_DISTANCE);
}

get_spawnlist_defend()
{
	// get array of enemy spawners in order of farthest to closest
	all_spawners = common_scripts\utility::get_array_of_closest(maps\_utility::getaverageplayerorigin(), level.pmc.enemy_spawners_full_list, undefined, undefined, undefined, MIN_SPAWN_DISTANCE);
	all_spawners = common_scripts\utility::array_reverse(all_spawners);

	//use the farthest second half
	spawners = [];
	for (i = 0 ; i < int(all_spawners.size / 2);i++)
	{
		spawners[spawners.size] = all_spawners[i];
	}

	return common_scripts\utility::array_randomize(spawners);
}

re_populate_enemies()
{
	if (level.pmc._re_populating_enemies)
		return;
	level.pmc._re_populating_enemies = true;

	wait 3.0;

	[[level.pmc.populate_enemies_func]]();

	level.pmc._re_populating_enemies = false;
}

juggernaut_setup()
{
	level.jug_spawners = undefined;
	level.juggernaut_mode = false;
	level.juggernaut_next_spawner = 0;

	jugs = getentarray("juggernaut_spawner", "targetname");

	if (isdefined(jugs) && jugs.size > 0)
	{
		level.juggernaut_mode = true;
		level.jug_spawners = jugs;
	}
}


spawn_juggernaut(reg_spawner)
{
	jug_spawner = level.jug_spawners[level.juggernaut_next_spawner];

	level.juggernaut_next_spawner++ ;
	if (level.juggernaut_next_spawner >= level.jug_spawners.size)
	{
		// wait a frame so we don't try to use the same spawner twice in one frame
		wait 0.05;
		level.juggernaut_next_spawner = 0;
	}

	jug_spawner.origin = reg_spawner.origin;
	jug_spawner.angles = reg_spawner.angles;
	jug_spawner.count = 1;
	guy = jug_spawner maps\_utility::spawn_ai();
	return guy;
}


init_enemy_combat_mode(spawnerindex)
{
	if (isdefendmatch())
		return;

	 /#
	if (getdvar("scr_force_ai_combat_mode") != "0")
		return;
	#/

	if (self animscripts\combat_utility::islongrangeai())
		return;
	
	if (self animscripts\combat_utility::isshotgunai())
		return;
	
	if (spawnerindex % 3)
		self.combatmode = "ambush";
}

spawn_more_enemies(spawnlist, numbertospawn)
{
	debug_print("trying to spawn " + numbertospawn + " enemies");

	// try spawning from spawners that haven't been used yet if possible.
	numberspawnedcorrectly = 0;
	numberspawnedcorrectly = spawn_more_enemies_from_array(spawnlist, numbertospawn);

	// try spawning remaining (if any) from any spawners, instead of just ones that haven't been used yet.
	numberspawnedincorrectly = 0;
	if (numberspawnedcorrectly < numbertospawn)
		numberspawnedincorrectly = spawn_more_enemies_from_array(level.pmc.enemy_spawners_full_list, numbertospawn - numberspawnedcorrectly, false);

	assertex(numberspawnedcorrectly + numberspawnedincorrectly == numbertospawn, "there are enough spawn locations in the level, but none of them could be used for spawning");

	debug_print("successfully spawned " + (numberspawnedcorrectly + numberspawnedincorrectly) + " enemies, after retrying " + numberspawnedincorrectly + " failed attempts.");
	debug_print("possible spawners remaining: " + level.pmc.enemy_spawners.size);
}

spawn_more_enemies_from_array(spawnlist, numbertospawn, removespawnedfromarray)
{
	if (!isdefined(removespawnedfromarray))
		removespawnedfromarray = true;
	if (isdefendmatch())
		removespawnedfromarray = false;

	spawnersused = [];
	numberfailedattempts = 0;
	numbertospawnremaining = numbertospawn;
	for (i = 0; i < spawnlist.size; i++)
	{
		isjuggernaut = false;
		spawnlist[i].count = 1;
		if (should_spawn_juggernaut())
		{
			guy = spawn_juggernaut(spawnlist[i]);
			isjuggernaut = true;
		}
		else
		{
			guy = spawnlist[i] maps\_utility::spawn_ai();
		}

		if ((maps\_utility::spawn_failed(guy)) || (!isalive(guy)) || (!isdefined(guy)))
		{
			numberfailedattempts++ ;
			continue;
		}
		spawnersused[spawnersused.size] = spawnlist[i];
		if (isjuggernaut)
		{
			level.pmc.juggernauts_spawned++ ;
			if (level.pmc.send_in_juggernaut)
			{
				guy thread juggernaut_hunt_immediately_behavior();
				level.pmc.send_in_juggernaut = false;
			}
			else
				guy thread [[level.pmc.set_goal_func]]();
		}
		else
		{
			guy init_enemy_combat_mode(i);
			guy thread [[level.pmc.set_goal_func]]();
		}

		guy thread enemy_death_wait();
		guy thread enemy_seek_player_wait();

		numbertospawnremaining -- ;
		assert(numbertospawnremaining >= 0);
		if (numbertospawnremaining == 0)
			break;
	}

	if (removespawnedfromarray)
	{
		// remove the guys that spawned from the spawner list so they don't get spawned twice
		enemy_spawner_count_before = level.pmc.enemy_spawners.size;
		level.pmc.enemy_spawners = maps\_utility::array_exclude(level.pmc.enemy_spawners, spawnersused);
		assert(level.pmc.enemy_spawners.size == enemy_spawner_count_before - spawnersused.size);
	}

	return spawnersused.size;
}

enemy_update_goal_on_jumpout()
{
	self endon("death");
	self waittill("jumpedout");
	waittillframeend;
	self [[level.pmc.set_goal_func]]();
}

enemy_set_goal_when_player_spotted()
{
	self endon("death");

	if (!isai(self))
		return;
	if (!isalive(self))
		return;
	
	//small goal, but aware of player moves them to spots where they could see him, but keeps them spread out
	self.goalradius = 450;
	self set_goal_height();
	
	if (isdefined(self.juggernaut))
	{
		self maps\_utility::wait_for_notify_or_timeout("enemy_visible", JUGGERNAUT_ENEMY_VISIBLE_TIMEOUT);
		juggernaut_set_goal_when_player_spotted_loop();
		return;
	}
	
	self waittill("enemy_visible");
	
	if (self animscripts\combat_utility::isshotgunai() || (randomint(3) == 0))
		enemy_set_goal_when_player_spotted_loop();
}

set_goal_height()
{
	if (isdefined(self.juggernaut))
		self.goalheight = DEFAULT_ENEMY_GOAL_HEIGHT_JUGGERNAUT;
	else if (self animscripts\combat_utility::issniper())
		self.goalheight = DEFAULT_ENEMY_GOAL_HEIGHT_SNIPER;
	else
		self.goalheight = DEFAULT_ENEMY_GOAL_HEIGHT;
}

juggernaut_set_goal_when_player_spotted_loop()
{
	self endon("death");

	self.usechokepoints = false;

	//small goal at the player so they can close in aggressively
	while (1)
	{
		self.goalradius = 32;
		self set_goal_height();
		if (isdefined(self.enemy))
			self setgoalpos(self.enemy.origin);
		else
			self setgoalpos(level.player.origin);
		wait 4;
	}
}

enemy_set_goal_when_player_spotted_loop()
{
	self endon("death");
	//large goal at the player so they can close in intelligently
	while (1)
	{
		if (self.doingambush)
			self.goalradius = 2048;
		else if (self animscripts\combat_utility::issniper())
			self.goalradius = 5000;
		else
			self.goalradius = randomintrange(1200, 1600);

		if (isdefined(self.enemy))
			self setgoalpos(self.enemy.origin);
		else
			self setgoalpos(level.player.origin);

		wait 45;
	}
}

enemy_set_goalradius()
{
	if (!isai(self))
		return;
	if (!isalive(self))
		return;
	self.goalradius = randomintrange(level.pmc.enemy_goal_radius_min, level.pmc.enemy_goal_radius_max);
	self set_goal_height();
}

enemy_seek_player_wait()
{
	self endon("death");
	common_scripts\utility::flag_wait("enemies_seek_players");

	debug_print("ai is seeking out player!");

	self enemy_seek_player();
}

enemy_seek_player(modscale)
{
	self endon("death");
	self.accuracy = 50;// final enemies are more deadly
	self.combatmode = "cover";
	while (1)
	{
		self.goalradius = randomintrange(1200, 1600);
		self set_goal_height();
		if (isdefined(self.enemy) && self.enemy.classname == "player")
			self setgoalpos(self.enemy.origin);
		else
			self setgoalpos(level.players[randomint(level.players.size)].origin);
		wait 45;
	}
}

enemy_seek_objective_in_stages()
{
	self endon("death");
	self.goalradius = 1600;
	self setgoalpos(level.pmc.defend_obj_origin);
	wait 45;
	self.goalradius = 1100;
	wait 45;
	self.goalradius = 600;
}

enemy_seek_player_in_stages()
{
	self endon("death");
	modscale = 3;
	for (;;)
	{
		self.goalradius = randomintrange(ENEMY_GOAL_RADIUS_SEEK_PLAYER_MIN, ENEMY_GOAL_RADIUS_SEEK_PLAYER_MAX) * modscale;
		self set_goal_height();
		self setgoalentity(common_scripts\utility::random(level.players));
		modscale -- ;
		if (modscale <= 0)
			break;
		wait 45;
	}
}

enemy_death_wait()
{
	self thread enemy_wait_death();
	self thread enemy_wait_damagenotdone();
}

enemy_wait_death()
{
	self endon("cancel_enemy_death_wait");

	self waittill("death", attacker);
	thread enemy_died(attacker);

	self notify("cancel_enemy_death_wait");
}

enemy_wait_damagenotdone()
{
	self endon("cancel_enemy_death_wait");

	self waittill("damage_notdone", damage, attacker);
	thread enemy_died(attacker);

	self notify("cancel_enemy_death_wait");
}

enemy_died(attacker)
{
	if (common_scripts\utility::flag_exist("special_op_terminated") && common_scripts\utility::flag("special_op_terminated"))
	{
		return;
	}
		
	if (level.pmc.limitrespawns)
	{
		level.pmc.enemies_remaining -- ;
	}

	assert(level.pmc.enemies_remaining >= 0);

	level notify("enemy_died");// needed for pacing
	level notify("update_enemies_remaining_count");
	thread re_populate_enemies();

	// check if we should send the remaining few enemies out towards the ai
	if (level.pmc.enemies_remaining <= SEEK_PLAYERS_ENEMY_COUNT)
		common_scripts\utility::flag_set("enemies_seek_players");

	// check to see if the mission has been completed
	if ((level.pmc.limitrespawns) && (level.pmc.enemies_remaining == 0))
	{
		if (isobjectivematch())
			common_scripts\utility::flag_wait("objective_complete");

//		wait 3.0;
		if (isdefined(level.pmc.objective_enemies_index))
			objective_state(level.pmc.objective_enemies_index, "done");

		if (!isobjectivematch())
			thread mission_complete();
	}
}

iseliminationmatch()
{
	return(level.pmc_gametype == "mode_elimination");
}

isobjectivematch()
{
	return(level.pmc_gametype == "mode_objective");
}

isdefendmatch()
{
	return(level.pmc_gametype == "mode_defend");
}

setup_objective_entities()
{
	objectivelocations = [];
	
	objectiveent = getentarray("pmc_objective", "targetname");
	objectiveent = common_scripts\utility::get_array_of_closest(maps\_utility::getaverageplayerorigin(), objectiveent);
	
	foreach(i, ent in objectiveent)
	{
		objectivelocations[i] = spawnstruct();
		objectivelocations[i].laptop = ent;
		assert(isdefined(ent.target));
		objectivelocations[i].trigger = getent(ent.target, "targetname");
		assert(isdefined(objectivelocations[i].trigger));
		assert(objectivelocations[i].trigger.classname == "trigger_use");
		objectivelocations[i].laptop hide();
		objectivelocations[i].trigger common_scripts\utility::trigger_off();
	}
	
	if (isdefendmatch())
	{
		//find closest volume
		defend_volumes = getentarray("info_volume_pmcdefend", "classname");
		defend_volume = common_scripts\utility::getclosest(maps\_utility::getaverageplayerorigin(), defend_volumes);

		//find the obj closest to that volume
		obj_index = maps\_utility::get_closest_index(defend_volume.origin, objectiveent);
		defend_obj = objectivelocations[obj_index];
		
		objectivelocations = common_scripts\utility::array_remove(objectivelocations, defend_obj);
		level.pmc.defend_obj_origin = defend_obj.laptop.origin;
		assertex(isdefined(level.pmc.defend_obj_origin), "undefined defend location origin.");
		thread set_up_defend_location(defend_obj, defend_volume);
	}
	
	// if we're in an objective match, set the objective variable to a random location
	if (isobjectivematch())
	{
		randomlocation = randomint(objectivelocations.size);
		level.pmc.objective = objectivelocations[randomlocation];
		
		level.pmc.objective.laptop_obj = spawn("script_model", level.pmc.objective.laptop.origin);
		level.pmc.objective.laptop_obj.angles = level.pmc.objective.laptop.angles;
		level.pmc.objective.laptop_obj setmodel("com_laptop_open");

		objectivelocations = common_scripts\utility::array_remove(objectivelocations, objectivelocations[randomlocation]);
	}
	
	// delete unused objective location entities
	foreach(location in objectivelocations)
		location.trigger delete();
}

delete_sentry_pickup()
{
	waittillframeend;
	self thread _id_D2A4::_id_AE99();
}

set_up_defend_location(defend_obj, defend_volume)
{
	defend_volume thread defend_think(80);
	thread DEFEND_SETUP_TIME_think(defend_obj);

	foreach (gun in level.sentry_pickups)
	{
		d = distance(gun.origin, defend_obj.trigger.origin);
		if (d <= 300)
			continue;
		gun thread delete_sentry_pickup();
	}
}

DEFEND_SETUP_TIME_think(defend_obj)
{
	defend_obj.trigger thread DEFEND_SETUP_TIME_trigger();
	thread DEFEND_SETUP_TIME_hint();

	wait level.pmc.defendsetuptime;
	common_scripts\utility::flag_set("pmc_DEFEND_SETUP_TIME_finished");

	defend_obj.trigger common_scripts\utility::trigger_off();
}

DEFEND_SETUP_TIME_hint()
{
	level endon("pmc_DEFEND_SETUP_TIME_finished");
	wait 15;

	hint_defend_setup = spawnstruct();
	// approach the laptop to skip set up time.
	hint_defend_setup.string = &"PMC_START_ATTACK_HINT";
	hint_defend_setup.timeout = 5;
	foreach (player in level.players)
		player maps\_utility::show_hint(hint_defend_setup);

	common_scripts\utility::flag_wait("pmc_DEFEND_SETUP_TIME_finished");

	maps\_utility::hide_hint(hint_defend_setup);
}

DEFEND_SETUP_TIME_trigger()
{
	// press and hold &&1 on the laptop to skip set up time.
	self sethintstring(&"PMC_START_ATTACK_USE_HINT");
	self waittill("trigger");
	common_scripts\utility::flag_set("pmc_DEFEND_SETUP_TIME_finished");
	self common_scripts\utility::trigger_off();
}


defend_think(fill_time)
{
	totaltime = fill_time;
	enemy_time = 0;
	bar_doesnt_exist = true;
	bar = undefined;

	while (1)
	{
		//reset and check enemies in volume each frame
		//also pull nearby enemies into volume
		self.enemy_count = 0;
		enemies = getaiarray("axis");
		foreach (enemy in enemies)
		{
			if ((distance(enemy.origin, self.origin)) < 600)
			{
				enemy setgoalpos(level.pmc.defend_obj_origin);
				if (enemy istouching(self))
					self.enemy_count++ ;
			}
		}

		//enemies are in volume, add and update bar
		if (self.enemy_count > 0)
		{
			enemy_time = enemy_time + (self.enemy_count * .05);
			if (enemy_time > 0)
			{
				if (bar_doesnt_exist)
				{
					bar = maps\_hud_util::createbar();
					bar maps\_hud_util::setpoint("center", undefined, 0, 75);
					bar.text = maps\_hud_util::createfontstring("objective", 1.4);
					bar.text maps\_hud_util::setpoint("center", undefined, 0, 63);
					// hq damage
					bar.text settext(&"PMC_HQ_DAMAGE");
					bar.text.sort = -1;

					bar_doesnt_exist = false;
					bar maps\_hud_util::updatebar(enemy_time / totaltime);
				}
				else
				{
					bar maps\_hud_util::updatebar(enemy_time / totaltime);
				}
			}
		}
		else// no enemies in volume, if players are, empty the bar
		{
			foreach (player in level.players)
				if (player istouching(self))
					enemy_time = enemy_time - .1;
			if (enemy_time < 0)
				enemy_time = 0;
			if (bar_doesnt_exist == false)
				bar maps\_hud_util::updatebar(enemy_time / totaltime);
		}

		if ((enemy_time == 0) && (bar_doesnt_exist == false))
		{
			bar.text notify("destroying");
			bar.text maps\_hud_util::destroyelem();
			bar notify("destroying");
			bar maps\_hud_util::destroyelem();
			bar_doesnt_exist = true;
		}
		if (enemy_time >= fill_time)
		{
			// keep enemies away from the objective!
			setdvar("ui_deadquote", &"PMC_DEFEND_FAILED");
			maps\_utility::missionfailedwrapper();
		}
		wait .05;
	}
}

show_remaining_enemy_count()
{
	/*
	"default"
    "bigfixed"
    "smallfixed"
    "objective"
    "big"
    "small"
    "hudbig"
    "hudsmall"
    */
    
/*	level.pmc.hud.remainingenemycounthudelem = newhudelem();
	level.pmc.hud.remainingenemycounthudelem.x = -10;
	level.pmc.hud.remainingenemycounthudelem.y = -100;
	level.pmc.hud.remainingenemycounthudelem.font = "hudsmall";
	level.pmc.hud.remainingenemycounthudelem.fontscale = 1.0;
	level.pmc.hud.remainingenemycounthudelem.alignx = "right";
	level.pmc.hud.remainingenemycounthudelem.aligny = "bottom";
	level.pmc.hud.remainingenemycounthudelem.horzalign = "right";
	level.pmc.hud.remainingenemycounthudelem.vertalign = "bottom";
	// enemies remaining: &&1
	level.pmc.hud.remainingenemycounthudelem.label = &"PMC_ENEMIES_REMAINING";
	level.pmc.hud.remainingenemycounthudelem.alpha = 1;*/
	
	self.remainingenemycounthudelem = so_create_hud_item(2, so_hud_ypos(), &"SPECIAL_OPS_HOSTILES", self);
	self.remainingenemycounthudelemnum = so_create_hud_item(2, so_hud_ypos(), "", self);
	self.remainingenemycounthudelemnum.alignx = "left";

	//self thread info_hud_handle_fade(self.remainingenemycounthudelem, "mission_complete");
	//self thread info_hud_handle_fade(self.remainingenemycounthudelemnum, "mission_complete");

	for (;;)
	{
		//thread enemy_remaining_count_blimp();
		
		// update the number of enemies remaining on the hud
		self.remainingenemycounthudelemnum setvalue(level.pmc.enemies_remaining);
		if (isdefined(level.pmc.enemies_kills_to_win) && (level.pmc.enemies_kills_to_win > 0))
			thread so_dialog_counter_update(level.pmc.enemies_remaining, level.pmc_enemies);

		// kill all enemies in the level [&&1 remaining].
		if (isdefined(level.pmc.objective_enemies_index))
			// kill all enemies in the level [&&1 remaining].
			objective_string_nomessage(level.pmc.objective_enemies_index, &"PMC_OBJECTIVE_KILL_ENEMIES_REMAINING", level.pmc.enemies_remaining);

		if (level.pmc.enemies_remaining <= 0)
		{
			self.remainingenemycounthudelem thread so_hud_pulse_success();
			self.remainingenemycounthudelemnum thread so_hud_pulse_success();

			break;
		}

		if (isdefined(level.pmc_low_enemy_count) && level.pmc.enemies_remaining <= level.pmc_low_enemy_count)
		{
			self.remainingenemycounthudelem thread so_hud_pulse_close();
			self.remainingenemycounthudelemnum thread so_hud_pulse_close();
		}
			
		level waittill("update_enemies_remaining_count");
	}
	
	common_scripts\utility::flag_wait("mission_complete");
	self.remainingenemycounthudelem thread so_remove_hud_item();
	self.remainingenemycounthudelemnum thread so_remove_hud_item();
}

enemy_remaining_count_blimp()
{
	level notify("enemy_remaining_count_blimp");
	level endon("enemy_remaining_count_blimp");
	
	scaletimeout = 0.1;
	scaletimein = 0.4;
	scalesize = 1.3;
	
	wait 0.1;
	
	level.pmc.hud.remainingenemycounthudelem changefontscaleovertime(scaletimeout);
	level.pmc.hud.remainingenemycounthudelem.fontscale = scalesize;
	
	wait scaletimeout + 0.2;
	
	level.pmc.hud.remainingenemycounthudelem changefontscaleovertime(scaletimein);
	level.pmc.hud.remainingenemycounthudelem.fontscale = 1.0;
}

gametype_setup()
{
	if (isobjectivematch())
	{
		common_scripts\utility::array_thread(level.players, ::player_use_objective_think);
		thread wait_objective_complete();
	}
	thread maps\_specialops::enable_challenge_timer("mission_start", "mission_complete");
}

player_use_objective_think()
{
	level endon("kill_objective_use_thread");

	while (!isdefined(level.pmc.objective))
		wait 0.05;

	// press and hold &&1 to use the laptop.
	level.pmc.objective.trigger common_scripts\utility::trigger_on();
	level.pmc.objective.laptop show();
	level.pmc.objective.trigger.active = true;
	level.pmc.objective.trigger sethintstring(&"PMC_HINT_USELAPTOP");

	for (;;)
	{
		wait 0.05;

		level.pmc.objective.trigger waittill("trigger", player);
		if (player != self)
			continue;

		buttontime = 0;
		totaltime = 3.0;
		qdone = false;
		
		player thread freeze_controls_while_using_laptop();
		
		self.objective_bar = self maps\_hud_util::createclientprogressbar(self, 60);
		self.objective_bar_text = self maps\_hud_util::createclientfontstring("timer", 0.6);
		self.objective_bar_text maps\_hud_util::setpoint("center", undefined, 0, 45);
		self.objective_bar_text settext(&"PMC_HQ_RECOVERING_INTEL");	// retrieving intel...


		while ((self usebuttonpressed()) && (!common_scripts\utility::flag("objective_complete")))
		{
			self.objective_bar maps\_hud_util::updatebar(buttontime / totaltime);

			wait 0.05;
			buttontime += 0.05;
			if (buttontime > totaltime)
			{
				qdone = true;
				break;
			}
		}

		if (isdefined(self.objective_bar))
			self.objective_bar maps\_hud_util::destroyelem();
		if (isdefined(self.objective_bar_text))
			self.objective_bar_text maps\_hud_util::destroyelem();
		
		player notify("remove_laptop_pickup_hud");
		
		if (qdone)
		{
			player playsound("intelligence_pickup");
			break;
		}
	}
	
	// remove progress bars from all players that might have been using the objective at the same time
	foreach (player in level.players)
	{
		player notify("remove_laptop_pickup_hud");
		if (isdefined(player.objective_bar))
		{
			player.objective_bar maps\_hud_util::destroyelem();
			player.objective_bar = undefined;
		}
		if (isdefined(player.objective_bar_text))
		{
			player.objective_bar_text maps\_hud_util::destroyelem();
			player.objective_bar_text = undefined;
		}
	}

	level.pmc.objective.trigger delete();
	level.pmc.objective.laptop_obj delete();
	level.pmc.objective.laptop delete();

	common_scripts\utility::flag_set("objective_complete");
}

freeze_controls_while_using_laptop()
{
	self endon("death");
	
	self disableweapons();
	self freezecontrols(true);
	
	self waittill("remove_laptop_pickup_hud");
	
	self enableweapons();
	self freezecontrols(false);
}

wait_objective_complete()
{
	common_scripts\utility::flag_wait("objective_complete");
	wait 0.05;
	level notify("kill_objective_use_thread");
	
	extraction_info = get_extraction_location();
	
	// objective was completed, now get to the extraction zone
	objective_state(1, "done");
	
	// reach the extraction zone before time runs out.
	objective_add(2, "current", &"PMC_OBJECTIVE_EXTRACT", extraction_info.script_origin.origin);
	if (!common_scripts\utility::flag("exfiltrate_music_playing"))
	{
		common_scripts\utility::flag_set("exfiltrate_music_playing");
//		thread musicplaywrapper(level.pmc.music["exfiltrate"]);
	}
	thread play_local_sound("exfiltrate");
	playfx(common_scripts\utility::getfx("extraction_smoke"), extraction_info.script_origin.origin);
	
	// wait until all alive players are in the extraction zone
	// wait for all players to be inside extraction zone
	maps\_specialops_code::wait_all_players_are_touching(extraction_info.trigger);
	
	// complete the objective
	objective_state(2, "done");
	
	common_scripts\utility::flag_set("extraction_complete");
	common_scripts\utility::flag_set("mission_complete");
	thread mission_complete();
}

get_extraction_location()
{
	extraction_info = spawnstruct();
	
	// get all available extraction locations in the map
	extraction_origins = getentarray("extraction", "targetname");
	averageorigin = maps\_utility::getaverageplayerorigin();
	extraction_origins = common_scripts\utility::get_array_of_closest(averageorigin, extraction_origins);
	
	// choose the far extraction point from where the players are
	extraction_info.script_origin = extraction_origins[extraction_origins.size - 1];
	assert(isdefined(extraction_info.script_origin));
	
	extraction_info.trigger = getent(extraction_info.script_origin.target, "targetname");
	assert(isdefined(extraction_info.trigger));
	
	return extraction_info;
}

add_player_objectives()
{
	if (isobjectivematch())
	{
		objective_add_laptop(1);
	}
	else if (isdefendmatch())
	{
		thread objective_add_defend();
	}
	else
	{
		objective_add_enemies(1);
		foreach (player in level.players)
			player thread show_remaining_enemy_count();
	}

}

objective_add_enemies(objnum)
{
	if (!isdefined(objnum))
		objnum = 1;
	level.pmc.objective_enemies_index = objnum;
	// kill all enemies in the level.
	objective_add(objnum, "current", &"PMC_OBJECTIVE_KILL_ENEMIES", (0, 0, 0));
	// kill all enemies in the level [&&1 remaining].
	objective_string_nomessage(objnum, &"PMC_OBJECTIVE_KILL_ENEMIES_REMAINING", level.pmc.enemies_remaining);
}

objective_add_laptop(objnum)
{
	if (!isdefined(objnum))
		objnum = 1;
	assert(isdefined(level.pmc.objective.trigger.origin));
	
	//wait for trigger to get turned on since it effects it's origin
	while(!isdefined(level.pmc.objective.trigger.active))
		wait 0.05;
	
	// retrieve enemy intel.
	objective_add(objnum, "current", &"PMC_OBJECTIVE_ABORT_CODES", level.pmc.objective.trigger.origin);
}

objective_add_defend()
{
	assert(isdefined(level.pmc.defendsetuptime));
	assert(isdefined(level.pmc.defendtime));

	// set up a defensive position before enemy attack.
	objective_add(1, "current", &"PMC_OBJECTIVE_SETUP_DEFENSES", (0, 0, 0));
	thread show_DEFEND_TIMEr();

	common_scripts\utility::flag_wait("pmc_DEFEND_SETUP_TIME_finished");
	//wait level.pmc.defendsetuptime;

	common_scripts\utility::flag_set("defend_started");

	objective_state(1, "done");
	// survive until time runs out.
	objective_add(2, "current", &"PMC_OBJECTIVE_DEFEND", (0, 0, 0));

	wait level.pmc.defendtime;

	objective_state(2, "done");
	thread mission_complete();
}

show_DEFEND_TIMEr()
{
	level.pmc.hud.defendtimer = newhudelem();
	level.pmc.hud.defendtimer.x = 0;
	level.pmc.hud.defendtimer.y = 30;
	level.pmc.hud.defendtimer.fontscale = 2.5;
	level.pmc.hud.defendtimer.alignx = "left";
	level.pmc.hud.defendtimer.aligny = "middle";
	level.pmc.hud.defendtimer.horzalign = "left";
	level.pmc.hud.defendtimer.vertalign = "middle";
	level.pmc.hud.defendtimer.alpha = 1;
	// time until attack: &&1
	level.pmc.hud.defendtimer.label = &"PMC_TIME_UNTIL_ATTACK";
	level.pmc.hud.defendtimer settimer(level.pmc.defendsetuptime);

	common_scripts\utility::flag_wait("pmc_DEFEND_SETUP_TIME_finished");

	// time remaining: &&1
	level.pmc.hud.defendtimer.label = &"PMC_TIME_REMAINING";
	level.pmc.hud.defendtimer settimer(level.pmc.defendtime);
}

play_local_sound(alias, looptime, stop_loop_notify)
{
	assert(isdefined(level.pmc.sound));
	assert(isdefined(level.pmc.sound[alias]));

	if (isarray(level.pmc.sound[alias]))
	{
		rand = randomint(level.pmc.sound[alias].size);
		aliastoplay = level.pmc.sound[alias][rand];
	}
	else
	{
		aliastoplay = level.pmc.sound[alias];
	}

	if (!isdefined(looptime))
	{
		common_scripts\utility::array_thread(level.players, maps\_utility::playlocalsoundwrapper, aliastoplay);
		return;
	}

	level endon("special_op_terminated");
	level endon(stop_loop_notify);
	for (;;)
	{
		common_scripts\utility::array_thread(level.players, maps\_utility::playlocalsoundwrapper, aliastoplay);
		wait looptime;
	}
}

mission_complete()
{
//	thread musicplaywrapper(level.pmc.music["mission_complete"]);
//	wait 1.5;
	common_scripts\utility::flag_set("mission_complete");
}

debug_print(string)
{
	if (getdvar("pmc_debug") == "1")
	{
		print(string);
		assert(isdefined(string));
		iprintln(string);
	}
}

debug_show_enemy_spawners_count()
{
	if (isdefendmatch())
		return;

	level.pmc.hud.enemyspawnercounthudelem = newhudelem();
	level.pmc.hud.enemyspawnercounthudelem.x = 0;
	level.pmc.hud.enemyspawnercounthudelem.y = -30;
	level.pmc.hud.enemyspawnercounthudelem.fontscale = 1.5;
	level.pmc.hud.enemyspawnercounthudelem.alignx = "left";
	level.pmc.hud.enemyspawnercounthudelem.aligny = "bottom";
	level.pmc.hud.enemyspawnercounthudelem.horzalign = "left";
	level.pmc.hud.enemyspawnercounthudelem.vertalign = "bottom";
	// enemy spawners: &&1
	level.pmc.hud.enemyspawnercounthudelem.label = &"PMC_DEBUG_SPAWNER_COUNT";
	level.pmc.hud.enemyspawnercounthudelem.alpha = 1;

	for (;;)
	{
		assert(isdefined(level.pmc.enemy_spawners));
		assert(isdefined(level.pmc.enemy_spawners.size));
		level.pmc.hud.enemyspawnercounthudelem setvalue(level.pmc.enemy_spawners.size);
		wait 0.05;
	}
}

debug_show_enemies_alive_count()
{
	level.pmc.hud.enemycounthudelem = newhudelem();
	level.pmc.hud.enemycounthudelem.x = 0;
	level.pmc.hud.enemycounthudelem.y = -15;
	level.pmc.hud.enemycounthudelem.fontscale = 1.5;
	level.pmc.hud.enemycounthudelem.alignx = "left";
	level.pmc.hud.enemycounthudelem.aligny = "bottom";
	level.pmc.hud.enemycounthudelem.horzalign = "left";
	level.pmc.hud.enemycounthudelem.vertalign = "bottom";
	// enemies alive: &&1
	level.pmc.hud.enemycounthudelem.label = &"PMC_DEBUG_ENEMY_COUNT";
	level.pmc.hud.enemycounthudelem.alpha = 1;

	for (;;)
	{
		enemyaialive = getaiarray("axis");
		assert(isdefined(enemyaialive));
		assert(isdefined(enemyaialive.size));
		level.pmc.hud.enemycounthudelem setvalue(enemyaialive.size + level.pmc.enemy_vehicles_alive);
		wait 0.05;
	}
}

debug_show_vehicles_alive_count()
{
	level.pmc.hud.enemyvehiclecounthudelem = newhudelem();
	level.pmc.hud.enemyvehiclecounthudelem.x = 0;
	level.pmc.hud.enemyvehiclecounthudelem.y = 0;
	level.pmc.hud.enemyvehiclecounthudelem.fontscale = 1.5;
	level.pmc.hud.enemyvehiclecounthudelem.alignx = "left";
	level.pmc.hud.enemyvehiclecounthudelem.aligny = "bottom";
	level.pmc.hud.enemyvehiclecounthudelem.horzalign = "left";
	level.pmc.hud.enemyvehiclecounthudelem.vertalign = "bottom";
	// vehicles alive: &&1
	level.pmc.hud.enemyvehiclecounthudelem.label = &"PMC_DEBUG_VEHICLE_COUNT";
	level.pmc.hud.enemyvehiclecounthudelem.alpha = 1;

	for (;;)
	{
		level.pmc.hud.enemyvehiclecounthudelem setvalue(level.pmc.enemy_vehicles_alive);
		wait 0.05;
	}
}
/*
set_up_preplaced_enemy_sentry_turrets(turrets)
{
	if (turrets.size == 0)
		return;

	//sort from closest to furtherest
	turrets = get_array_of_closest(maps\_utility::getaverageplayerorigin(), turrets);

	//remove the closest 2
	turrets[0] thread common_scripts\_sentry::delete_sentry_turret();
	turrets = array_remove(turrets, turrets[0]);

	if (turrets.size == 0)
		return;

	turrets[0] thread common_scripts\_sentry::delete_sentry_turret();
	turrets = array_remove(turrets, turrets[0]);

	num_to_keep = 3;

	if (turrets.size <= num_to_keep)
		return;

	turrets = common_scripts\utility::array_randomize(turrets);

	for (i = 0 ; i < turrets.size ; i++)
	{
		if (i >= num_to_keep)
		{
			turrets[i] thread common_scripts\_sentry::delete_sentry_turret();
		}
	}
}
*/
room_breach_spawned()
{
	// this thread gets ran when a room breach enemy gets spawned via the room breaching global script
	delete_unseen_enemy();
	self thread enemy_death_wait();
}

delete_unseen_enemy()
{
	// deletes 1 far away not-visible enemy in the map

	// get array of enemy spawners in order of farthest to closest
	ai = common_scripts\utility::get_array_of_closest(maps\_utility::getaverageplayerorigin(), getaiarray("axis"));
	ai = common_scripts\utility::array_reverse(ai);

	foreach (enemy in ai)
	{
		if (!enemy enemy_can_see_any_player())
		{
			println("^3an ai was deleted to make room for a door breach spawner");
			enemy notify("cancel_enemy_death_wait");
			enemy delete();
			return;
		}
	}
}

enemy_can_see_any_player()
{
	foreach (player in level.players)
	{
		if (self cansee(player))
			return true;
	}
	return false;
}

staged_pacing_system()
{
	one_third = int(level.pmc.enemies_kills_to_win / 3);
	two_thirds = int((level.pmc.enemies_kills_to_win * 2) / 3);
	level.pmc.max_juggernauts = int(level.pmc.enemies_kills_to_win / 7);


	thread count_dead_juggernauts();

	common_scripts\utility::flag_set("staged_pacing_used");
	while (1)
	{
		level waittill("enemy_died");

		//stage 1   one enemy killed, less than 1/3 of enemies killed
		//attack heli chance
		if (level.pmc.enemies_remaining >= two_thirds)
		{
			//50% chance through this entire period
			println("pacing                  stage 1");
			force_odds = one_third * 2;
		}

		//stage 2   1/3 to 2/3rds of enemies killed
		//transport heli or attack heli
		//transport isnt forced, just allowed
		//one juggernaut at a time
		else if (level.pmc.enemies_remaining >= one_third)
		{
			common_scripts\utility::flag_set("pacing_stage_2");
			println("pacing                  stage 2");
			thread send_in_one_juggernaut(one_third);
			//create_one_heli(if_none_already);
		}

		//stage 3   more than 2/3rds of enemies killed
		//two juggernauts at a time
		//second heli
		else
		{
			common_scripts\utility::flag_set("pacing_stage_3");
			println("pacing                  stage 3");
			//create_one_heli();
			thread send_in_multiple_juggernauts();
		}
	}

	//stage 4   less than 7 enemies left
	//beef up remaining and send in
	//done elsewhere
}


count_dead_juggernauts()
{
	while (1)
	{
		level waittill("juggernaut_died");
		level.pmc.juggernauts_killed++ ;
	}
}


juggernaut_hunt_immediately_behavior()
{
	self endon("death");

	self.usechokepoints = false;

	//small goal at the player so they can close in aggressively
	while (1)
	{
		self.goalradius = 32;
		self set_goal_height();
		if (isdefined(self.enemy))
			self setgoalpos(self.enemy.origin);
		else
		{
			enemyplayer = level.players[randomint(level.players.size)];
			self setgoalpos(enemyplayer.origin);
		}
			
		wait 4;
	}
}

send_in_one_juggernaut(one_third)
{
	//this doesnt actually spawn or force the juggernaut
	//it just alters the checks in should_spawn_juggernaut()
	//and removes a guy to make room
	living = level.pmc.juggernauts_spawned - level.pmc.juggernauts_killed;
	allowed_for_this_stage = (level.pmc.max_juggernauts / 2);

	if (living > 0)
		return;

	if (level.pmc.juggernauts_spawned >= allowed_for_this_stage)
		return;

	println("pacing                  trying for 1 juggernaut");
	odds = int((one_third / allowed_for_this_stage) / 2);

	if (randomint(odds) > 0)
		return;

	println("pacing                  spawning 1 juggernaut");
	delete_unseen_enemy();
	level.pmc.send_in_juggernaut = true;
}


send_in_multiple_juggernauts()
{
	jugs_remaining = level.pmc.max_juggernauts - level.pmc.juggernauts_spawned;

	if (jugs_remaining < 1)
		return;

	println("pacing                  trying for x juggernauts");
	odds = int(level.pmc.enemies_remaining / jugs_remaining);

	if (odds <= 0)
		odds = 1;
	if (randomint(odds) > 0)
		return;

	println("pacing                  spawning 1 juggernaut");
	delete_unseen_enemy();
	level.pmc.send_in_juggernaut = true;
}


should_spawn_juggernaut()
{
	if (level.pmc_alljuggernauts)
		return true;
	if (!level.juggernaut_mode)
		return false;
	
	// spawn a juggernaut at the start of the game instead of waiting until the end if this is set.
	if (!level.pmc.spawned_juggernaut_at_game_start)
	{
		assert(level.pmc.spawned_juggernaut_at_game_start_counter > 0);
		chance = randomint(level.pmc.spawned_juggernaut_at_game_start_counter);
		level.pmc.spawned_juggernaut_at_game_start_counter--;
		if (chance == 0)
		{
			level.pmc.spawned_juggernaut_at_game_start = true;
			return true;
		}
	}
	
	if (common_scripts\utility::flag("staged_pacing_used"))
	{
		if (level.pmc.send_in_juggernaut)
			return true;
		else
			return false;
	}
	if (randomint(10) > 0)
		return false;
	else
		return true;
}