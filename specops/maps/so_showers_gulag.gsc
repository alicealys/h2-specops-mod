#include maps\_specialops;

main()
{
    precacheitem("smoke_grenade_american");
    precacheitem("m4m203_reflex_arctic");
    precacheitem("f15_sam");
    precacheitem("sam");
    precacheitem("slamraam_missile");
    precacheitem("slamraam_missile_guided");
    precacheitem("cobra_seeker");
    precacheitem("rpg_straight");
    precacheitem("cobra_sidewinder");
    precacheitem("m14_scoped_arctic");
    precacheitem("claymore");
    precacheitem("mp5_silencer_reflex");
    precacheturret("player_view_controller");
    precacheitem("fraggrenade");
    precacheitem("flash_grenade");
    precacheitem("claymore");
    precachemodel("viewhands_udt");
    precachemodel("h1_cs_light_alarm_on");
    precachemodel("h1_cs_light_alarm_blue_on");
    precachemodel("h1_cs_light_alarm_blue");
    precachemodel("gulag_price_ak47");
    precachemodel("vehicle_slamraam_launcher_no_spike");
    precachemodel("vehicle_slamraam_missiles");
    precachemodel("projectile_slamraam_missile");
    precachemodel("tag_turret");
    precachemodel("me_lightfluohang_double_destroyed");
    precachemodel("me_lightfluohang_single_destroyed");
    precachemodel("ma_flatscreen_tv_wallmount_broken_01");
    precachemodel("ma_flatscreen_tv_wallmount_broken_02");
    precachemodel("com_tv2_d");
    precachemodel("com_tv1");
    precachemodel("com_tv2");
    precachemodel("com_locker_double_destroyed");
    precachemodel("dt_mirror_dam");
    precachemodel("dt_mirror_des");
    precachemodel("tag_laser");
    precachemodel("viewbody_udt");
    precachemodel("h2_gulag_cellblock2_intact_wall_01");
    precachemodel("trq_tree_pine_snow_045_02_static");
    precachemodel("trq_tree_pine_snow_060_02_static");
    precachemodel("trq_tree_pine_snow_070_02_static");
    precachemodel("trq_tree_pine_snow_080_02_static");
    precachemodel("trq_tree_pine_snow_090_02_static");
    precachemodel("trq_tree_pine_snow_105_02_static");
    precachemodel("com_blackhawk_spotlight_on_mg_setup_3x_cold");
    precachemodel("com_blackhawk_spotlight_on_mg_setup_3x_cold_off");
    precachemodel("h2_com_laptop_rugged_open_gulag");
    precachemodel("h2_gulag_rappel_rope_player_60ft");
    precachemodel("h2_gulag_rappel_rope_player_60ft_standard");
    precachemodel("body_seal_udt_smg_gulag_intro");
    precachemodel("body_seal_udt_assault_a_gulag_intro");
    precachemodel("head_seal_udt_d_lifesaver_gulag_intro");
    precachemodel("head_seal_udt_a_gulag_intro");
    precachemodel("head_seal_udt_c_gulag_intro");
    precachemodel("head_seal_udt_d_gulag_intro");
    precachemodel("head_seal_udt_e_gulag_intro");
    precachemodel("h2_head_seal_udt_b_c_gulag_intro");
    precachemodel("h2_vehicle_sa15_gauntlet_destroy_snow");
    precachemodel("com_tv1_pho_zombie");
    precachemodel("hat_opforce_merc_b");
    precacheshader("h1_hud_tutorial_border");
    precacheshader("h1_hud_tutorial_blur");
    loadfx("fx/explosions/tv_flatscreen_explosion");
    loadfx("fx/misc/light_fluorescent_single_blowout_runner");
    loadfx("fx/misc/light_fluorescent_blowout_runner");
    loadfx("fx/props/locker_double_des_01_left");
    loadfx("fx/props/locker_double_des_02_right");
    loadfx("fx/props/locker_double_des_03_both");
    loadfx("fx/misc/no_effect");
    loadfx("fx/misc/light_blowout_swinging_runner");
    loadfx("fx/props/mirror_dt_panel_broken");
    loadfx("fx/props/mirror_shatter");
    loadfx("fx/misc/tower_light_blue_steady");
    precacheshellshock("gulag_attack");
    precacheshellshock("nosound");
    precachemodel("rat");

    var_3 = getentarray("gulag_destructible_volume", "targetname");
    maps\_utility::mask_destructibles_in_volumes(var_3);
    maps\_utility::mask_interactives_in_volumes(var_3);

    level.default_goalheight = 128;
    common_scripts\utility::create_dvar("f15", 1);
    setsaveddvar("g_friendlynamedist", 0);

	maps\_utility::set_default_start("so_showers");
	maps\_utility::add_start("so_showers", ::start_so_showers_timed, "special op: showers");

    var_0 = getentarray("falling_rib_chunk", "targetname");
    common_scripts\utility::array_thread(var_0, maps\_utility::self_delete);
    var_1 = getentarray("top_hall_exploder", "targetname");
    common_scripts\utility::array_thread(var_1, maps\_utility::self_delete);
    var_2 = getentarray("top_hall_chunk", "targetname");
    common_scripts\utility::array_thread(var_2, maps\_utility::self_delete);
    var_2 = getentarray("top_hall_chunk", "targetname");
    common_scripts\utility::array_thread(var_2, maps\_utility::self_delete);

    level.disable_interactive_tv_use_triggers = true;

    maps\_compass::setupminimap("compass_map_gulag_2");

    _id_B708::main();
    _id_BEE0::main();
    _id_C71F::main();
    _id_C789::main();
    _id_C1F5::main();
    maps\gulag_anim::main();
    maps\_load::main();
    maps\gulag::_id_C21D();
    maps\gulag_aud::main();
    maps\gulag_lighting::main();
    maps\gulag_code::_id_C868("shower_hanging_lamp", "shower_hanging_light");
    soundscripts\_snd::snd_message("start_bathroom_checkpoint");
    maps\gulag_lighting::_id_B3E6("gulag_showers");
    maps\_art::sunflare_changes("shower", 0);

    thread maps\gulag_code::_id_A8C5();
    setdvar("use_improved_breaches", 1);
    level._id_CA75 = "mil_frame_charge";
    maps\_slowmo_breach::slowmo_breach_init();
    level._effect["breach_door"] = loadfx("fx/explosions/breach_wall_concrete");

    level._id_D498 = 1000;
    level._pipe_fx_time = 2.5;

    thread maps\gulag_code::_id_D405();
    enablepg("hide_interior_portal_group", 0);
    thread maps\gulag_code::_id_BFF5();
    setignoremegroup("team3", "axis");
    setignoremegroup("axis", "team3");

    maps\_utility::array_spawn_function_noteworthy("overlook_spawner", maps\gulag_code::_id_ACEA);
    maps\_utility::array_spawn_function_targetname("bhd_spawner", maps\gulag_code::_id_BA8C);
    maps\_utility::array_spawn_function_noteworthy("breach_death_spawner", maps\gulag_code::_id_AD2D);
    maps\_utility::array_spawn_function_noteworthy("riot_shield_spawner", maps\gulag_code::_id_BEEC);
    maps\_utility::array_spawn_function_noteworthy("flee_armory_spawner", maps\gulag_code::_id_A941);
    maps\_utility::array_spawn_function_noteworthy("tarp_spawner", maps\gulag_code::_id_B033);
    maps\_utility::array_spawn_function_noteworthy("close_fighter_spawner", maps\gulag_code::_id_B871);
    maps\_utility::array_spawn_function_noteworthy("bathroom_balcony_spawner", maps\gulag_code::_id_CC7B);
    maps\_utility::array_spawn_function_noteworthy("riot_escort_spawner", maps\gulag_code::_id_A820);
    maps\_utility::array_spawn_function_noteworthy("catwalk_spawner", maps\gulag_code::_id_D582);
    maps\_utility::array_spawn_function_noteworthy("dies_fast_to_explosive", maps\gulag_code::_id_C794);
    maps\_utility::array_spawn_function_noteworthy("ignore_then_dies_fast_to_explosive", maps\gulag_code::_id_B512);
    common_scripts\utility::run_thread_on_noteworthy("low_health_destructible", maps\gulag_code::_id_ADC4);
    common_scripts\utility::run_thread_on_targetname("challenge_only", ::challenge_only_think);
}

challenge_only_think()
{
	if (level.start_point == "so_showers")
	{
		if (self.classname == "script_model")
		{
			self setcandamage(true);
		}

		return;
	}
	
	if (self.classname == "script_brushmodel")
    {
		self connectpaths();
    }
	
	self delete();
}

so_showers_timed_setup_regular()
{
	level.challenge_objective = &"SO_SHOWERS_GULAG_OBJ_REGULAR";
}

so_showers_timed_setup_hardened()
{
	level.challenge_objective = &"SO_SHOWERS_GULAG_OBJ_HARDENED";
}

so_showers_timed_setup_veteran()
{
	level.challenge_time_limit = 180; 
	level.challenge_objective = &"SO_SHOWERS_GULAG_OBJ_VETERAN";
}

gulag_shower_challenge_music()
{
	level waittill("slowmo_breach_ending");
    wait 2;
	maps\_utility::music_loop("mus_so_showers_gulag_music", 150);
}

so_showers_update_objective()
{
	level waittill("player_enters_bathroom");

	objective_marker = getent("player_rappels_from_bathroom", "script_noteworthy");
	objective_position(1, objective_marker.origin);
	objective_setpointertextoverride(1, "");
}

player_enters_bathroom()
{
    level waittill("breaching");
    wait 2;
    level notify("player_enters_bathroom_");
}

fill_weapon_pickups()
{
	weapons = getentarray("so_weapons", "targetname");

	foreach (weapon in weapons)
	{
		weapon_names = strtok(weapon.classname, "_");

		weapon_name = weapon_names[1];
		for (i = 2; i < weapon_names.size; i++)
		{
			weapon_name = weapon_name + "_" + weapon_names[i];
		}

		if (weaponaltweaponname(weapon_name) != "none")
		{
			weapon itemweaponsetammo(999, 999, 999, 1);
		}

		weapon itemweaponsetammo(999, 999);
	}
}

start_so_showers_timed()
{
    fill_weapon_pickups();
    getent("breach_hint_model", "targetname") delete();
    getent("car_blows_up", "script_noteworthy") delete();
    
	common_scripts\utility::flag_set("enable_interior_fx");
	thread maps\_utility::set_ambient("gulag_hall_int0");

	switch (level.gameskill)
	{
		case 0:
		case 1:
            so_showers_timed_setup_regular();
        break;
		case 2:
            so_showers_timed_setup_hardened();
        break;
		case 3:
            so_showers_timed_setup_veteran();
        break;
	}
	
	enable_escape_warning();
	enable_escape_failure();
	
	breach_marker = getent("pipe_breach_org", "targetname");
	objective_add(1, "current", level.challenge_objective, breach_marker.origin);
	maps\_slowmo_breach::objective_breach(1, 2);
	thread so_showers_update_objective();
	
	volume = getent("gulag_shower_destructibles", "script_noteworthy");
	volume maps\_utility::activate_destructibles_in_volume();
	volume maps\_utility::activate_interactives_in_volume();

	thread fade_challenge_in();
	thread fade_challenge_out("player_exited_bathroom");
    thread player_enters_bathroom();
	thread enable_challenge_timer("player_enters_bathroom_", "player_exited_bathroom", level.challenge_time_limit);
	thread enable_triggered_complete("player_rappels_from_bathroom", "player_exited_bathroom");
	thread gulag_shower_challenge_music();

	foreach (player in level.players)
	{
		player setactionslot(1, "");
	}

	common_scripts\utility::flag_wait("player_enters_bathroom");

    thread _id_B417::ambienteventstart("gulag_shower_int0");

	level.player.attackeraccuracy = 0;
	level.player maps\_utility::delaythread(6, maps\_gameskill::update_player_attacker_accuracy);

	maps\_utility::activate_trigger_with_targetname("bathroom_initial_enemies");
	
	maps\_utility::delaythread(10, maps\_utility::activate_trigger_with_targetname, "bathroom_balcony_room1_trigger");

	common_scripts\utility::flag_wait("bathroom_start_second_wave");

	maps\_utility::delaythread(1, maps\_utility::activate_trigger_with_targetname, "bathroom_balcony_room2_trigger");
	maps\_utility::activate_trigger_with_targetname("bathroom_second_wave_trigger");
}
