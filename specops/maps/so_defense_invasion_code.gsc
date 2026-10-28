#include maps\_specialops;

// ---------------------------------------------------------------------------------

fire_off_exploder(current)
{
	while (true)
	{
		common_scripts\_exploder::exploder(current.script_prefab_exploder);
		if(!isdefined(current.target))
			break;
		next = getent(current.target, "targetname");
		if(!isdefined(next))
			break;
		current = next;
	}
}

// ---------------------------------------------------------------------------------

create_smoke_wave(smoke_tag, dialog_wait)
{
	// prevent smoke from happening too frequently
	if (isdefined(level.smoke_throttle))
	{
		if (!isdefined(level.smoke_wave_time))
			level.smoke_wave_time = gettime() - level.smoke_throttle - 1;
	
		time_since = gettime() - level.smoke_wave_time;
		if (time_since <= level.smoke_throttle)
			return;
	
		level.smoke_wave_time = gettime();
	}
	
	magic_smoke_grenades = getentarray(smoke_tag, "targetname");
	common_scripts\utility::array_thread(magic_smoke_grenades, ::smoke_wave_play);

	// undefined dialog_wait assumes we don't want any. use 0 for no wait.
	if (isdefined(dialog_wait))
		thread dialog_smoke_wave_alert(dialog_wait);
}

smoke_wave_play()
{
	playfx(common_scripts\utility::getfx("smokescreen"), self.origin);
	self thread common_scripts\utility::play_sound_in_space("smokegrenade_explode_default");
}

dialog_smoke_wave_alert(dialog_wait)
{	
	level endon("special_op_terminated");

	wait dialog_wait;

	// record the time and go go go.
	level.smoke_wave_time = gettime();
		
	//hunter two-one, overlord. advise switching to thermal optics, over.
	maps\_utility::radio_dialogue("so_def_inv_thermaloptics");
}

// ---------------------------------------------------------------------------------

btr80_level_init()
{
	if (isdefined(level.btr80_init))
		return;
		
	level.btr80_init = true;
	level.btr80_count = 0;
	level.btr80_death_time = gettime();
	
	if (!isdefined(level.btr_kill_value))
		level.btr_kill_value = 400;

	if (!isdefined(level.btr_min_fighting_range))
		level.btr_min_fighting_range = 400;

	if (!isdefined(level.btr_max_fighting_range))
		level.btr_max_fighting_range = 2400;

	if (!isdefined(level.btr_target_fov))
		level.btr_target_fov = cos(50);
		
	level.btr80_building_checks = getentarray("trigger_multiple_flag_set_touching", "classname");
	
	for (i = level.btr80_building_checks.size - 1; i >= 0; i--)
	{
		building = level.btr80_building_checks[i];
		if (!isdefined(building.script_flag))
		{
			level.btr80_building_checks[i] = undefined;
			continue;
		}
			
		switch (building.script_flag)
		{
			case "player_inside_nates"	:
			case "player_in_burgertown"	:
			case "player_in_diner"		:
				// do nothing, keep in the list.
				break;
			default:
				level.btr80_building_checks[i] = undefined;
				break;
		}
	}
}

create_btr80(btr80_tag)
{
	btr80_level_init();		
	
	btr80 = maps\_vehicle::spawn_vehicle_from_targetname_and_drive(btr80_tag);
	common_scripts\utility::array_thread(getvehiclenodearray("new_target", "script_noteworthy"), ::btr80_new_target_think);
	
	btr80 thread btr80_watch_for_player();
	btr80 thread btr80_register_death();
	btr80 thread maps\_utility::ent_flag_init("spotted_player");
	btr80 thread btr80_turret_spotlight();
	btr80 thread maps\_vehicle_code::damage_hints();
	btr80 thread dialog_btr80_spotted_you();
}

btr80_watch_for_player()
{
	level endon("special_op_terminated");
	self endon("death");
	self.turret_busy = false;
	
	while (true)
	{
		wait .05;

		if (self maps\_utility::ent_flag("spotted_player"))
			continue;

		player = btr80_find_available_player();
		if (!isdefined(player))
			continue;

		tag_flash_angles = self gettagangles("tag_flash");
		if(!common_scripts\utility::within_fov(self.origin, tag_flash_angles, player.origin, level.btr_target_fov))
			continue;

		if(!btr80_can_see_player(player))
			continue;

		self notify("new_target");				// clears ambient target shooting
		self.turret_busy = true;
		self maps\_utility::ent_flag_set("spotted_player");
		player.btr80_attacker_id = self.unique_id;	// claim this player for myself.
		self vehicle_setspeed(0, 10);
		
		//saw player, now miss for 2 bursts
		btr80_miss_player(player);
		wait(randomfloatrange(0.8, 2.4));
		btr80_miss_player(player);
		wait(randomfloatrange(0.8, 2.4));
    	
		//if player is still exposed then hit him
		while (btr80_can_see_player(player))
		{
			btr80_fire_at_player(player);
			wait(randomfloatrange(0.5, 1.5));
		}
			
		self clearturrettargetent();
		self.turret_busy = false;
		self maps\_utility::ent_flag_clear("spotted_player");
		player.btr80_attacker_id = undefined;
		self vehicle_setspeed(10, 1);
	}
}

btr80_turret_spotlight()
{
	maps\_vehicle::vehicle_lights_on("spotlight spotlight_turret");
}

btr80_fire_at_player(player)
{
	self endon("death");
	
	burstsize = randomintrange(3, 5);
	firetime = .2;
	for (i = 0; i < burstsize; i++)
	{
		self setturrettargetent(player, common_scripts\utility::randomvector(20) + (0, 0, 32));//randomvec was 50
		self fireweapon();
		wait firetime;
	}
}

btr80_miss_player(player)
{
	self endon("death");

	//point in front of player
	forward = anglestoforward(player.angles);
	forwardfar = forward * 100;
	miss_vec = forwardfar + common_scripts\utility::randomvector(50);
	
	burstsize = randomintrange(4, 6);
	firetime = .2;
	for (i = 0; i < burstsize; i++)
	{
		offset = common_scripts\utility::randomvector(15) + miss_vec + (0,0,64);
		self setturrettargetent(player, offset);
		self fireweapon();
		wait firetime;
	}
}

btr80_find_available_player()
{
	p1_ok = btr80_check_player_available(level.player)  && btr80_check_player_in_range(level.player);
	p2_ok = btr80_check_player_available(level.player2) && btr80_check_player_in_range(level.player2);

	if (p1_ok && p2_ok)
		return common_scripts\utility::getclosest(self.origin, level.players);
	
	if (p1_ok)
		return level.player;

	if (p2_ok)
		return level.player2;
		
	return undefined;
}

btr80_check_player_available(player)
{
	if (!isdefined(player))
		return false;
	
	if (isdefined(player.btr80_attacker_id))
		return false;
		
	return true;
}

btr80_check_player_in_range(player)
{
	if (!isdefined(player))
		return false;
		
	if (distance(self.origin, player.origin) > level.btr_max_fighting_range)
		return false;

	if(distance(self.origin, player.origin) < level.btr_min_fighting_range)
		return false;
		
	return true;
}

btr80_check_player_in_building(player)
{
	if (!isdefined(player))
		return;
		
	foreach (building in level.btr80_building_checks)
	{
		if (player istouching(building))
			return true;
	}
	
	return false;
}

btr80_can_see_player(player)
{
	if (btr80_check_player_in_building(player))
		return false;
		
	if (!btr80_check_player_in_range(player))
		return false;
		
	tag_flash_loc = self gettagorigin("tag_flash");
	player_eye = player geteye();
	return sighttracepassed(tag_flash_loc, player_eye, false, self);
}

btr80_new_target_think()
{
	level endon("special_op_terminated");
	level endon("btr80s_all_down");

	targets = getentarray(self.script_linkto, "script_linkname");
	while (true)
	{
		self waittill("trigger", vehicle);
		
		if(!isalive(vehicle))
			return;
		if(vehicle.turret_busy)
			continue;
		
		vehicle notify("new_target");
		
		vehicle setturrettargetent(targets[0]);
		
		thread btr80_fire_at_targets(vehicle);
	}
}

btr80_fire_at_targets(vehicle)
{
	vehicle endon("new_target");
	vehicle endon("death");
	
	vehicle waittill("turret_on_target");
		
	while (true)
	{
		s = randomintrange(4, 6);
		for (j = 0; j < s; j++)
		{
				vehicle fireweapon();
				wait .2;
		}
		wait(randomfloatrange(1, 2));
	}
}

btr80_register_death()
{
	level endon("special_op_terminated");

	level.btr80_count++; 

	my_id = self.unique_id;
	
	self waittill("death", attacker);

	if(self maps\_utility::ent_flag("spotted_player"))
	{
		foreach (player in level.players)
		{
			if (isdefined(player.btr80_attacker_id) && (my_id == player.btr80_attacker_id))
				player.btr80_attacker_id = undefined;
		}
	}

	if (isplayer(attacker))
	{
		attacker.btr80_kills++;
		attacker update_sentry_attackeraccuracy(level.aamod_btr80_kill);
	}
		
	level.btr80_count--;
	assertex((level.btr80_count >= 0), "somehow the btr80 population counter dropped below 0. this should never happen.");

	level notify("btr80_death");
	if (level.btr80_count <= 0)
		level notify("btr80s_all_down");

}

dialog_btr80_spotted_you()
{
	level endon("special_op_terminated");
	self endon("death");

	while (true)
	{
		maps\_utility::ent_flag_wait("spotted_player");
		dialog_btr80_spotted_you_action();
		wait 20;
	}
}

dialog_btr80_spotted_you_action()
{
	spotted_player = undefined;
	foreach (player in level.players)
	{
		if (isdefined(player.btr80_attacker_id) && (player.btr80_attacker_id == self.unique_id))
		{
			spotted_player = player;
			break;
		}
	}
	
	if (!btr80_can_see_player(spotted_player))
		return;

	// prevent btr80 dialog from happening too frequently
	if (isdefined(level.btr80_alert_throttle))
	{
		if (!isdefined(level.btr80_alert_time))
			level.btr80_alert_time = gettime() - level.btr80_alert_throttle - 1;
	
		time_since = gettime() - level.btr80_alert_time;
		if (time_since <= level.btr80_alert_throttle)
			return;
	
		level.btr80_alert_time = gettime();
	}

	//enemy btr has a visual on you, hunter two-one, advise seeking cover, over.
	//hunter two-one, be advised enemy btr is targetting you, over.
	maps\_utility::radio_dialogue("so_def_inv_bmpspottedyou");
}

// ---------------------------------------------------------------------------------

hunter_enemies_level_init()
{
	// always re-init this as it can get overwritten at the end of a wave.
	maps\_utility::set_group_advance_to_enemy_parameters(30000, 2);

	if (isdefined(level.hunters_init))
		return;

	level.hunters_init = true;

	level.hunters_active = 0;
	if (!isdefined(level.hunters_all_in))
		level.hunters_all_in = 5;
	dialog_hunter_enemies_setup();

	level.difficultysettings["accuracydistscale"]["easy"] = 0.8;
	level.difficultysettings["accuracydistscale"]["normal"]  = 0.8;
	level.difficultysettings["accuracydistscale"]["hardened"] = 0.7;
	level.difficultysettings["accuracydistscale"]["veteran"]  = 0.6;
	maps\_gameskill::updatealldifficulty();
}

create_hunter_enemy_group(enemy_tag, enemy_count)
{
	hunter_enemies_level_init();
	
	if (!isdefined(level.hunter_group_initialized))
	{
		level.hunter_group_initialized = true;
		level.hunter_goals = getentarray("closest_goal_radius", "targetname");
	}
	
	current_enemies = getentarray(enemy_tag, "targetname");
	common_scripts\utility::array_thread(current_enemies, maps\_utility::add_spawn_function, ::create_hunter_enemy);

	if (!isdefined(enemy_count) || (enemy_count > current_enemies.size))
		enemy_count = current_enemies.size;

	current_enemies = common_scripts\utility::array_randomize(current_enemies);
	enemies_spawned = 0;
	for (i = 0; i < current_enemies.size; i++)
	{
		current_enemies[i].count = 1;
		guy = current_enemies[i] maps\_utility::spawn_ai();
		
		if (isdefined(guy))
			enemies_spawned++;

		if (enemies_spawned >= enemy_count)
			break;
	}
	
	// only say something if we spawned at least 10 guys.
	if (enemies_spawned >= 10)
		thread dialog_hunter_enemies(enemy_tag, 2.5);

	return enemies_spawned;
}

create_hunter_truck_enemies(truck_tag)
{
	hunter_enemies_level_init();

	if (!isdefined(level.truck_group_initialized))
	{
		level.truck_group_initialized = true;
		truck_group_enemies = getentarray("truck_group_enemies", "script_noteworthy");
		common_scripts\utility::array_thread(truck_group_enemies, maps\_utility::add_spawn_function, ::create_hunter_enemy, true);
	}

	truck = thread maps\_vehicle::spawn_vehicle_from_targetname_and_drive(truck_tag);
	truck.veh_pathtype = "constrained";
}

create_hunter_enemy(wait_for_unload)
{
	self endon("death");
	level endon("special_op_terminated");

	thread hunter_register_death();

	if (isdefined(wait_for_unload) && wait_for_unload)
		self waittill("jumpedout");

	thread hunter_enemy_maintain_closest_goal();
}

hunter_enemy_maintain_closest_goal()
{
	self endon("death");
	level endon("special_op_terminated");
	
	self.hunter_is_bored = false;
	self maps\_utility::enable_danger_react(5);
	self.goalradius = 2048;
	self.goalheight = 768;

	// figure out at what time we'll get bored.
	boredom_time_base = 30000;
	boredom_time_fuzz = 90000;
	boredom_time = gettime() + boredom_time_base + randomint(boredom_time_fuzz);
	
	while (true)
	{
		if (!hunter_check_become_bored(boredom_time))
		{
			self.hunter_is_bored = false;
			closest_player = common_scripts\utility::getclosest(self.origin, level.players);
			closest_goal = common_scripts\utility::getclosest(closest_player.origin, level.hunter_goals);
			if (!isdefined(self.current_goal) || (self.current_goal != closest_goal))
			{
				waittillframeend;
				//waittillframeend because you may be in the part of the frame that is before 
				//the script has received the "death" notify but after the ai has died.
	
				self.current_goal = closest_goal;
				self setgoalpos(self.current_goal.origin);
			}
		}
		else
		{
			// bored... so get more aggressive.
			self.hunter_is_bored = true;
			self.aggressivemode = true;
			self setgoalentity(common_scripts\utility::getclosest(self.origin, level.players));
			self setengagementmindist(384, 0);
			self setengagementmaxdist(640, 1024);

			while (true)
			{	
				// while still refilling the population, don't get ultra aggressive.
				if (isdefined(level.hunter_refill_active))
				{
					wait 1;
					continue;
				}
			
				if (level.hunters_active > level.hunters_all_in)
				{
					wait 1;
					continue;
				}
				
				// we are now *really* bored. shrink engagement distance a lot.
				self.goalradius = 512;
				self.goalheight = 256;
				self setengagementmindist(0, 0);
				self setengagementmaxdist(256, 384);
				self.combatmode = "no_cover";
				self maps\_utility::set_ignoresuppression(true);
				if (!isdefined(level.hunters_all_in_active))
				{
					// only need to set this once.
					level.hunters_all_in_active = true;
					maps\_utility::set_group_advance_to_enemy_parameters(2000, level.hunters_all_in);
				}
				// nothing left to do but die.
				return;
			}
		}

		wait 1.0;
	}
}

hunter_check_become_bored(bored_time)
{
	// no more than level.hunters_all_in count can be bored at a time.
	bored_guys = 0;
	enemies = getaiarray("axis");
	foreach (guy in enemies)
	{
		if (isdefined(guy.hunter_is_bored) && guy.hunter_is_bored)
			bored_guys++;
	}
	if (bored_guys >= level.hunters_all_in)
		return false;
	
	// if our timer expires, then go go go.
	if (gettime() >= bored_time)
		return true;

	// once the population gets small enough, make everyone bored and charge the player.
	if (!isdefined(level.hunter_refill_active) && (level.hunters_active <= level.hunters_all_in))
		return true;

	// if there is already a random hunter, then no.
	if (isdefined(level.bored_hunter))
		return false;

	// no bored hunter available, so it's us now!
	level.bored_hunter = self.unique_id;
	return true;
}

hunter_enemies_refill(refill_at, min_fill, max_fill, refill_max)
{
	level endon("special_op_terminated");

	if (isdefined(level.hunter_refill_active) && level.hunter_refill_active)
		return;
		
	level.hunter_refill_active = true;
	level.hunter_refill_used_smoke = false;

	if (!isdefined(refill_at) || (refill_at < 0))
		refill_at = 0;
	if (!isdefined(min_fill) || (min_fill < 1))
		min_fill = 1;
	if (!isdefined(max_fill) || (max_fill <= min_fill))
		max_fill = min_fill + 1;

	// this includes any currently active hunters in the level so we can maintain a level max which is the intent.
	// namely if a truck was spawned, this will be aware of them. 
	// if the truck is spawned after this thread is started then it will not be aware of them.
	if (isdefined(refill_max))
	{
		if (isdefined(level.hunters_active) && (level.hunters_active > 0))
			refill_max -= level.hunters_active;
	}
		
	refill_current = 0;

	spawn_option = undefined;
	while (isdefined(level.hunter_refill_active) && level.hunter_refill_active)
	{
		if (!isdefined(level.hunters_active) || (level.hunters_active <= refill_at))
		{
			respawn_amount = hunter_enemies_get_spawn_amount(min_fill, max_fill, refill_max, refill_current);
			spawn_option = hunter_enemies_get_spawn_option(spawn_option);
			switch (spawn_option)
			{
				case "bank":	respawn_amount = hunter_enemies_refill_group("bank_enemies", respawn_amount, "north"); break;
				case "gas":		respawn_amount = hunter_enemies_refill_group("gas_station_enemies", respawn_amount); break;
				case "taco":	respawn_amount = hunter_enemies_refill_group("taco_enemies", respawn_amount, "south"); break;
				case "burger":	respawn_amount = hunter_enemies_refill_group("burger_town_enemies", respawn_amount, "south"); break;
				default:		assertex(false, "hunter_enemies_refill() resulted in an invalid spawn option: " + spawn_option);
			}
		
			if (isdefined(refill_max))
			{
				refill_current += respawn_amount;
				if (refill_current >= refill_max)
					level.hunter_refill_active = undefined;
			}
		}
		
		// give it a moment before checking again.
		if (isdefined(level.hunter_refill_active) && level.hunter_refill_active)
			wait 1;
	}
	
	level notify("hunter_refill_complete");
}

hunter_enemies_get_spawn_amount(min_fill, max_fill, refill_max, refill_current)
{
	respawn_amount = randomintrange(min_fill, max_fill);
	if (isdefined(refill_max))
	{
		if ((refill_current + respawn_amount) > refill_max)
			respawn_amount = (refill_max - refill_current);
	}
	
	return respawn_amount;
}

hunter_enemies_get_spawn_option(last_spawn)
{
	if (!isdefined(last_spawn))
		last_spawn = "";
		
	spawn_options = [];
	
	if (!common_scripts\utility::flag("so_player_near_bank"))
		spawn_options[spawn_options.size] = "bank";
	if (!common_scripts\utility::flag("so_player_near_gas_station"))
		spawn_options[spawn_options.size] = "gas";
	if (!common_scripts\utility::flag("so_player_near_taco"))
		spawn_options[spawn_options.size] = "taco";
	if (!common_scripts\utility::flag("so_player_near_burgertown"))
		spawn_options[spawn_options.size] = "burger";

	// no "good" options, so just pick a random one.
	if (spawn_options.size <= 0)
	{
		spawn_options[spawn_options.size] = "bank";
		spawn_options[spawn_options.size] = "gas";
		spawn_options[spawn_options.size] = "taco";
		spawn_options[spawn_options.size] = "burger";
	}
	
	// only try for a new option if we have more than one.
	i = 0;
	if (spawn_options.size > 1)
	{
		i = randomint(spawn_options.size);
		if (spawn_options[i] == last_spawn)
		{
			i--;
			if (i < 0)
				i = spawn_options.size - 1;
		}
	}
		
	return spawn_options[i];
}

hunter_enemies_refill_group(enemy_group, respawn_amount, smoke_dir)
{
	if (isdefined(smoke_dir))
	{
		if ((randomfloat(1.0) < level.smoke_chance) || !level.hunter_refill_used_smoke)
		{
			level.hunter_refill_used_smoke = true;
			switch (smoke_dir)
			{
				case "north":	thread maps\so_defense_invasion::enable_smoke_wave_north(4); break;
				case "south":	thread maps\so_defense_invasion::enable_smoke_wave_south(4); break;
				default:		break;
			}
		}
	}

	return create_hunter_enemy_group(enemy_group, respawn_amount);
}

hunter_register_death()
{
	level endon("special_op_terminated");
	
	level.hunters_active++;
	my_id = self.unique_id;

	thread hunter_register_turret_death();
	
	self common_scripts\utility::waittill_any("death", "pain_death");

	if (isdefined(level.bored_hunter))
	{
		if (level.bored_hunter == my_id)
			level.bored_hunter = undefined;
	}
			
	level.hunters_active--;
	assertex((level.hunters_active >= 0), "somehow the hunter population counter dropped below 0. this should never happen.");

	level notify("hunter_death");
	if (hunter_check_wave_complete())
		level notify("hunters_all_down");
}

hunter_register_turret_death()
{
	level endon("special_op_terminated");

	self waittill("death", attacker);
	
	if (hunter_attacker_is_player_turret(attacker))
	{
		attacker.owner.turret_kills++;
		attacker.owner update_sentry_attackeraccuracy(level.aamod_sentry_kill);
	}
	else if (isplayer(attacker))
	{
		attacker update_sentry_attackeraccuracy(level.aamod_player_kill);
	}
}

hunter_attacker_is_player_turret(attacker)
{
	if (!isdefined(attacker))
		return false;
		
	if (!isdefined(attacker.targetname))
		return false;
		
	if (attacker.targetname != "sentry_minigun")
		return false;
		
	if (!isdefined(attacker.owner))
		return false;
		
	if (!isplayer(attacker.owner))
		return false;
		
	return true;
}

update_sentry_attackeraccuracy(adjust_amount)
{
	assert(isdefined(adjust_amount));
	
	sentry_turrets = getentarray("sentry_minigun", "targetname");
	foreach (sentry in sentry_turrets)
	{
		if (!isdefined(sentry.attackeraccuracy))
			continue;

		if (!isdefined(sentry.owner))
			continue;

		if (sentry.owner != self)
			continue;

		sentry.attackeraccuracy = max(1.0, sentry.attackeraccuracy + adjust_amount);
	}
}

hunter_check_wave_complete()
{
	if (level.hunters_active > 0)
		return false;
		
	if (isdefined(level.hunter_refill_active) && level.hunter_refill_active)
		return false;

	return true;		
}

dialog_hunter_enemies(enemy_tag, wait_time)
{
	// prevent hunter spawn dialogs from happening too frequently
	if (isdefined(level.hunter_dialog_throttle))
	{
		if (!isdefined(level.hunter_dialog_time))
			level.hunter_dialog_time = gettime() - level.hunter_dialog_throttle - 1;
	
		time_since = gettime() - level.hunter_dialog_time;
		if (time_since <= level.hunter_dialog_throttle)
			return;
	
		level.hunter_dialog_time = gettime();
	}

	if (isdefined(wait_time))
		wait wait_time;

	assertex(isdefined(level.dialog), "dialog_hunter_enemies requires level.dialog to be defined before it can play anything.");

	sound_selection = randomint(level.dialog[enemy_tag].size);
	thread maps\_utility::radio_dialogue(level.dialog[enemy_tag][sound_selection]);
}

dialog_hunter_enemies_setup(enemy_tag, wait_time)
{
	if (!isdefined(level.dialog))
		level.dialog = [];

	//hunter two-one this is overlord actual, we're seeing enemy reinforcements to your north, over.	
	level.dialog["bank_enemies"][0] = "inv_hqr_enemynorth";
	//be advised hunter two-one, you got enemy infantry by that bank to the north, over.	
	level.dialog["bank_enemies"][1] = "inv_hqr_banktonorth";
	//hunter two-one, be advised, enemy foot-mobiles approaching north of your location, over.	
	level.dialog["bank_enemies"][2] = "inv_hqr_footmobiles";

	//hunter two-one, hunter four has a visual on hostiles near the nova gas station, over.	
	level.dialog["gas_station_enemies"][0] = "inv_hqr_novagasstation";
	//hunter two-one, relay from goliath two, enemy reinforcements approaching from the west, over.	
	level.dialog["gas_station_enemies"][1] = "inv_hqr_enemywest";
	//hunter two-one, tangos approaching near the diner to the west, over.	
	level.dialog["gas_station_enemies"][2] = "inv_hqr_dinerwest";

	//hunter two-one, overlord. enemy foot-mobiles approaching you from the southeast, over.	
	level.dialog["taco_enemies"][0] = "inv_hqr_southeast";
	//hunter two-one, goliath one has a visual on hostiles coming from the southeast, over.	
	level.dialog["taco_enemies"][1] = "inv_hqr_visualse";
	//hunter two-one, be advised, enemy foot-mobiles have been sighted near the taco joint, over.	
	level.dialog["taco_enemies"][2] = "inv_hqr_tacojoint";

	//be advised hunter two-one, you have enemy foot mobiles by the burger town to the south, over.
	level.dialog["burger_town_enemies"][0] = "so_def_inv_mobilesouth";
	level.scr_radio["so_def_inv_mobilesouth"] = "so_def_inv_mobilesouth";
	//hunter two-one, overlord, be advised potential attackers from the south, over.
	level.dialog["burger_town_enemies"][1] = "so_def_inv_attacksouth";
	level.scr_radio["so_def_inv_attacksouth"] = "so_def_inv_attacksouth";
	//hunter two-one, hunter four has a identified a large hostile group near the burger town, over.
	level.dialog["burger_town_enemies"][2] = "so_def_inv_hostilesouth";
	level.scr_radio["so_def_inv_hostilesouth"] = "so_def_inv_hostilesouth";
	
	//hunter two-one, enemy predator drone has spotted you, advise taking cover, over.
	level.dialog["drone_spotted"][0] = "so_def_inv_dronespotted";
	level.scr_radio["so_def_inv_dronespotted"] = "so_def_inv_dronespotted";
	//hunter two-one, be advised enemy drone has noticed you, over.
	level.dialog["drone_spotted"][1] = "so_def_inv_dronenotice";
	level.scr_radio["so_def_inv_dronenotice"] = "so_def_inv_dronenotice";
	
	//hunter two-one, enemy drone is targetting you, seek cover, over.
	level.dialog["drone_shooting"][0] = "so_def_inv_dronetarget";
	level.scr_radio["so_def_inv_dronetarget"] = "so_def_inv_dronetarget";
	//enemy drone is firing directly on your position hunter two-one, over.
	level.dialog["drone_shooting"][1] = "so_def_inv_dronedirect";
	level.scr_radio["so_def_inv_dronedirect"] = "so_def_inv_dronedirect";
}

// ---------------------------------------------------------------------------------

attack_heli_init()
{
	if (isdefined(level.attack_heli_init))
		return;
		
	level.attackhelirange = 7000;
	level.attack_heli_count = 0;
	
	level.attack_heli_init = true;
	level.attack_heli_death_time = gettime();
	
	dialog_fill_nates_stinger();
	dialog_fill_diner_stinger();
}

create_attack_heli(heli_id, heli_points_id, wait_time)
{
	assertex(isdefined(heli_id), "create_attack_heli() requires a valid heli_id.");
	assertex(isdefined(heli_points_id), "create_attack_heli() requires a valid heli_points_id.");
			
	if (isdefined(wait_time))
		wait wait_time;
		
	attack_heli_init();
		
	eheli = maps\_vehicle::spawn_vehicle_from_targetname_and_drive(heli_id);
	eheli.circling = true;
	eheli.no_attractor = true;
	thread vehicle_scripts\_attack_heli::begin_attack_heli_behavior(eheli, heli_points_id);
	eheli thread attack_heli_register_death();

	thread dialog_attack_heli();
}

attack_heli_register_death()
{
	level.attack_heli_count++; 

	self waittill("death", attacker);
	
	thread dialog_shot_down_heli();

	level.attack_heli_count--;
	assertex((level.attack_heli_count >= 0), "somehow the heli population counter dropped below 0. this should never happen.");

	if (isplayer(attacker))
	{
		attacker.helicopter_kills++;
		attacker update_sentry_attackeraccuracy(level.aamod_heli_kill);
	}

	level notify("attack_heli_death");
	if (level.attack_heli_count == 0)
		level notify("attack_helis_all_down");
}

dialog_attack_heli()
{
	//hunter two-one, relay from goliath one: you got an enemy helicopter loaded for bear, approaching your area, over.	
	maps\_utility::radio_dialogue("inv_hqr_relaygol1");
}

dialog_shot_down_heli()
{
	wait 3;
	//nice one, over.
	maps\_utility::radio_dialogue("so_def_inv_niceone");
}

// ---------------------------------------------------------------------------------

// updated to be generic and not depend on specific exact stingers.
dialog_get_stinger()
{
	assertex(isdefined(level.stingers) && (level.stingers.size > 0), "dialog_get_stinger() requires at least one stinger to function correctly.");
	level endon("special_op_terminated");

	stringer_dialog_throttle_reset();
	
	nates_dialog_current = 0;
	diner_dialog_current = 0;
	
	while (true)
	{	
		// have to wait until we have a stinger available.
		if (!isdefined(level.stingers))
		{
			wait 1;
			continue;
		}

		// don't bother if there isn't anyone useful to shoot.
		if (!stinger_enemy_available())
		{
			wait 1;
			continue;	
		}
		
		p1_has_stinger = stinger_player_has(level.player);
		p2_has_stinger = stinger_player_has(level.player2);

		// if either player has a stinger, no need to play dialog.
		if (p1_has_stinger || p2_has_stinger)
		{
			wait 3;
			continue;
		}
		
		alert_stinger = common_scripts\utility::getclosest(level.player.origin, level.stingers);
		if (!isdefined(alert_stinger))
		{
			wait 1;
			continue;
		}

		// when in co-op, find the player closest to a stinger and alert them of that one.
		if (is_coop())
		{
			p1_distance = distance(level.player.origin, alert_stinger.origin);

			p2_stinger = common_scripts\utility::getclosest(level.player2.origin, level.stingers);
			p2_distance = distance(level.player2.origin, p2_stinger.origin);
			
			if (p2_distance < p1_distance)
				alert_stinger = p2_stinger;
		}

		if (isdefined(level.stingers["diner"]) && (alert_stinger == level.stingers["diner"]))
		{
			selected_line = level.diner_dialog[diner_dialog_current];
			maps\_utility::radio_dialogue(selected_line);
			
			diner_dialog_current++;
			if(diner_dialog_current >= level.diner_dialog.size)
				diner_dialog_current = 0;
		}
		else if (isdefined(level.stingers["nates_stinger"]))
		{
			selected_line = level.nates_dialog[nates_dialog_current];
			maps\_utility::radio_dialogue(selected_line);
			
			nates_dialog_current++;
			if(nates_dialog_current >= level.nates_dialog.size)
				nates_dialog_current = 0;
		}
		else
		{
			assertex(false, "dialog_get_stinger() tried to play an alert for a stinger, but no stingers are defined.");
			continue;
		}
		
		stringer_dialog_throttle_reset();
	}
}

stringer_dialog_throttle_reset()
{
	level.stinger_missile_throttle = gettime() + 60000;
}

stinger_player_has(player)
{
	// if no player, then they definitely don't have a stinger.
	if (!isdefined(player))
		return false;
		
	weapons = player getweaponslistall();
	foreach (weapon in weapons)
	{
		if (weapon == "at4")
			return true;
	}
	
	return false;
}

stinger_enemy_available()
{
	if (level.stinger_missile_throttle > gettime())
		return false;
		
	// if the player has killed one within the last 30 seconds don't remind.
	death_remind_delay = 30000;
	
	if (isdefined(level.attack_heli_count) && (level.attack_heli_count > 0))
	{
		if (level.attack_heli_death_time + death_remind_delay < gettime())
			return true;
	}
		
	if (isdefined(level.btr80_count) && (level.btr80_count > 0))
	{
		if (level.btr80_death_time + death_remind_delay < gettime())
			return true;
	}
	
	return false;
}

dialog_fill_diner_stinger()
{
	level.diner_dialog = [];
	
	//be advised hunter two one, at4 rockets located in the diner to the west, over.
	//hunter two-one, intel indicates a stockpile of at4 rockets to the west, over.
	level.diner_dialog[level.diner_dialog.size] = "so_def_inv_stingerdiner";
}

dialog_fill_nates_stinger()
{
	level.nates_dialog = [];
	
	//this is overlord actual, at4 rockets at the supply drop on the roof of nate's restaurant, over.
	//hunter two-one, check the roof of nate's restaurant for at4 rockets, over.
	level.nates_dialog[level.nates_dialog.size] = "so_def_inv_stingernates";
}

// ---------------------------------------------------------------------------------

stinger_maintain_spawn(stinger_id)
{
	level endon("special_op_terminated");

	level.stingers[stinger_id] = getent(stinger_id, "script_noteworthy");
	stinger = level.stingers[stinger_id];

	assertex(isdefined(stinger), "stinger_keep_available() was unable to find a stinger of script_noteworthy " + stinger_id); 

	stinger_origin = stinger.origin;
	stinger_angles = stinger.angles;

	garbage_dump = common_scripts\utility::getstruct("stinger_garbage_dump", "script_noteworthy");

	// remove the existing stinger and turn it into an at4.
	stinger delete();
	stinger = stinger_respawn(stinger_id, stinger_origin, stinger_angles);
	level.stingers[stinger_id] = stinger;

/*	while (true)
	{
		stinger waittill("trigger", player, old_weapon);
		
		// if players are grabbing them, never need to remind them.
		stringer_dialog_throttle_reset();
		
		stinger = undefined;
		level.stingers[stinger_id] = undefined;
		
		while (!isdefined(stinger))
		{
			wait 5;
			close_players = get_within_range(stinger_origin, level.players, 256);
			if (close_players.size > 0)
				continue;

			close_players = get_within_range(stinger_origin, level.players, 1024);
			if (close_players.size > 0)
			{
				if (stinger_player_can_see(stinger_origin))
					continue;
			}

			stinger = stinger_respawn(stinger_id, stinger_origin, stinger_angles);
			level.stingers[stinger_id] = stinger;
			if (isdefined(old_weapon))
				old_weapon.origin = garbage_dump.origin;
		}
	}*/
}

stinger_player_can_see(stinger_origin)
{
	foreach (player in level.players)
	{
		if (player maps\_utility::can_see_origin(stinger_origin))
			return true;
	}
	
	return false;
}

stinger_respawn(stinger_id, origin, angles)
{
	stinger = spawn("weapon_at4", origin, 1);
	stinger.angles = angles;
	stinger itemweaponsetammo(1, 0);
	stinger.script_noteworthy = stinger_id;
	
	return stinger;
}

// ---------------------------------------------------------------------------------

semtex_maintain_availability()
{
	semtex = getentarray("weapon_semtex_grenade", "classname");
	common_scripts\utility::array_thread(semtex, ::semtex_maintain_self);
}

semtex_maintain_self()
{
	level endon("special_op_terminated");

	semtex = self;
	semtex_origin = self.origin;
	semtex_angles = self.angles;
	
	while (true)
	{
		semtex waittill("trigger", player, old_weapon);

		// wait for players to leave proximity, then respawn.
		while (semtex_player_is_close(semtex_origin))
			wait 1;
			
		semtex = spawn("weapon_semtex_grenade", semtex_origin, 1);
		semtex.angles = semtex_angles;
		semtex itemweaponsetammo(4, 0);
	}
}

semtex_player_is_close(semtex_origin)
{
	close_players = maps\_utility::get_within_range(semtex_origin, level.players, 1024);
	return close_players.size > 0;
}

// ---------------------------------------------------------------------------------

hellfire_attack_start()
{
	if (isdefined(level.hellfire_active))
		return;
		
	level.hellfire_active = true; 
	level.hellfire_paused = false;

	if (!isdefined(level.hellfire_time_search))
		hellfire_set_time_search(20, 40);

	if (!isdefined(level.hellfire_time_breather))
		hellfire_set_time_breather(5, 8);

	thread hellfire_spawn_player1_uav();
	thread hellfire_spawn_player2_uav();
}

hellfire_spawn_player1_uav()
{
	level.hellfire_uav = hellfire_spawn_uav(level.player);		
}

hellfire_spawn_player2_uav()
{
	if (!is_coop())
		return;

	level.hellfire_uav_p2 = hellfire_spawn_uav(level.player2, 12);		
}

hellfire_spawn_uav(player, delay)
{
	level endon("special_op_terminated");
	level endon("hellfire_attack_stop");

	if (isdefined(delay))
		wait delay;
	
	hellfire_uav = getent("uav", "targetname");
	hellfire_uav.target = "so_uav_start";
	hellfire_uav = maps\_vehicle::spawn_vehicle_from_targetname_and_drive("uav");
	hellfire_uav playloopsound("uav_engine_loop");
	if (!level.hellfire_paused)
		hellfire_uav thread hellfire_monitor_player(player);
		
	return hellfire_uav;
}

hellfire_attack_pause()
{
	if (level.hellfire_paused)
		return;
		
	level.hellfire_paused = true;
	level notify("hellfire_attack_pause");
}

hellfire_attack_unpause()
{
	if (!level.hellfire_paused)
		return;
		
	level.hellfire_paused = false;
	level.hellfire_uav thread hellfire_monitor_player(level.player);
	if (is_coop() && isdefined(level.hellfire_uav_p2))
		level.hellfire_uav_p2 thread hellfire_monitor_player(level.player2);
}

hellfire_attack_stop()
{
	level notify("hellfire_attack_stop");

	level.hellfire_active = undefined;
	level.hellfire_paused = undefined;
	level.hellfire_uav delete();
	if (is_coop())
		level.hellfire_uav_p2 delete();
}

hellfire_monitor_player(player)
{
	if (isdefined(level.hellfire_paused) && level.hellfire_paused)
		return;
		
	player endon("death");
	level endon("special_op_terminated");
	level endon("hellfire_attack_stop");
	level endon("hellfire_attack_pause");

	while (true)
	{
		// wait for a while before going after the player.
		wait randomintrange(level.hellfire_time_search["min"], level.hellfire_time_search["max"]);
		while (!hellfire_check_player_available(player))
			wait 1;

		// spotted! give the player a moment to run...
		hud_warning = hud_display_uav_spotted(player, self.unique_id);
		dialog_hellfire_warn_player("drone_spotted");

		wait 2;
				
		// threaten our player...
		hellfire_threaten_player(player);
		wait randomintrange(level.hellfire_time_breather["min"], level.hellfire_time_breather["max"]);
			
		// threaten them again...
		hellfire_threaten_player(player);
		wait randomintrange(level.hellfire_time_breather["min"], level.hellfire_time_breather["max"]);
			
		// if player is still visible, attack them directly until no longer visible or dead
		if (hellfire_check_player_available(player))
		{
			hud_display_uav_targetting(hud_warning);
			dialog_hellfire_warn_player("drone_shooting");
			while (hellfire_check_player_available(player))
			{
				hellfire_attack_player(player);
				wait randomintrange(level.hellfire_time_breather["min"], level.hellfire_time_breather["max"]);
			}
		}
					
		// once player is hidden, give them one more scare and then move on.
		hellfire_attack_player(player);
		level notify("hellfire_attack_notarget_" + self.unique_id);
	}	
}

dialog_hellfire_warn_player(alias)
{
	// don't let these happen in too quick of succession
	if (isdefined(level.hellfire_warn_time))
	{
		if (level.hellfire_warn_time + 10000 > gettime())
			return;
	}
	
	level.hellfire_warn_time = gettime();
	
	index = randomint(level.dialog[alias].size);
	maps\_utility::radio_dialogue(level.dialog[alias][index]);
}

hellfire_check_player_available(player)
{
	if (!isdefined(player))
		return false;
		
	return sighttracepassed(self.origin, player geteye(), false, self);		
}

hellfire_attack_player(player, num_shots)
{
	player endon("death");
	level endon("special_op_terminated");
	level endon("hellfire_attack_stop");
	level endon("hellfire_attack_pause");

	if (!isdefined(num_shots))
		num_shots = 2;
	
	hellfire_shots = randomintrange(1, num_shots);
	for (i = 0; i < num_shots; i++)
	{
		attack_range_x = randomintrange(-600, 600);
		attack_range_y = randomintrange(-600, 600);
		attack_range_z = 0;
		attack_spot = player.origin;
		// on the first attack, always ensure it goes directly at the player.
		if (i > 0)
			attack_spot += (attack_range_x, attack_range_y, attack_range_z);
		hellfire_fire_missile(attack_spot);
		wait (randomfloatrange(0.33, 0.66));
	}
}

hellfire_threaten_player(player, max_shots)
{
	player endon("death");
	level endon("special_op_terminated");
	level endon("hellfire_attack_stop");
	level endon("hellfire_attack_pause");

	targets = common_scripts\utility::getstructarray("so_hellfire_target", "script_noteworthy");
	targets = maps\_utility::get_within_range(player.origin, targets, 1800);		// close enough to feel scary
	targets = maps\_utility::get_outside_range(player.origin, targets , 600);	// outside explosion radius
	
	if (!isdefined(max_shots))
		max_shots = 4;
		
	hellfire_shots = randomintrange(1, max_shots);
	for (i = 0; i < hellfire_shots; i++)
	{
		targets = self hellfire_attack_target(player, targets, true);	
		wait (randomfloatrange(0.25, 0.75));
	}
}

hellfire_attack_target(player, targets, remove_target)
{
	if (!isdefined(targets) || (targets.size <= 0))
		return;
		
	hellfire_index = maps\_utility::get_closest_index_to_player_view(targets, player, true);
	hellfire_target = targets[hellfire_index];
	hellfire_fire_missile(hellfire_target.origin);
	
	if (isdefined(remove_target) && remove_target)
		return maps\_utility::array_remove_index(targets, hellfire_index);
}

hellfire_fire_missile(target_origin)
{
	if (level.hellfire_paused)
		return;
		
	magicbullet("remote_missile_not_player_invasion", (self.origin + (0,0,-128)), target_origin);
}

hellfire_set_time_search(time_min, time_max)
{
	assertex(isdefined(time_min), "hellfire_set_time_search() requires a valid time_min");
	assertex(isdefined(time_max), "hellfire_set_time_search() requires a valid time_max");
	assertex((time_min < time_max), "hellfire_set_time_search() requires time_min to be less than time_max");

	if (!isdefined(level.hellfire_time_search))
		level.hellfire_time_search = [];
	
	level.hellfire_time_search["min"] = time_min;
	level.hellfire_time_search["max"] = time_max;
}

hellfire_set_time_breather(time_min, time_max)
{
	assertex(isdefined(time_min), "hellfire_set_time_breather() requires a valid time_min");
	assertex(isdefined(time_max), "hellfire_set_time_breather() requires a valid time_max");
	assertex((time_min < time_max), "hellfire_set_time_breather() requires time_min to be less than time_max");

	if (!isdefined(level.hellfire_time_breather))
		level.hellfire_time_breather = [];
	
	level.hellfire_time_breather["min"] = time_min;
	level.hellfire_time_breather["max"] = time_max;
}

// ---------------------------------------------------------------------------------

hud_display_wavecount(wave_num)
{
	// little delay so the "wave starting in..." can be removed
	wait(1);

	foreach (player in level.players)
	{
		// for now, it looks like there are waves on all difficulties.
		if (wave_num < 5)
		{
			player.hud_wave_title = so_create_hud_item(0, so_hud_ypos(), &"SPECIAL_OPS_WAVENUM", player);
			player.hud_wave_count = so_create_hud_item(0, so_hud_ypos(), undefined, player);
			player.hud_wave_count.alignx = "left";
			player.hud_wave_count setvalue(wave_num);
		}
		else
		{
			player.hud_wave_title = so_create_hud_item(0, so_hud_ypos(), &"SPECIAL_OPS_WAVEFINAL", player);
			player.hud_wave_title.alignx = "center";
		}
	}
}

hud_display_wavecount_remove()
{
	foreach (player in level.players)
	{
		player.hud_wave_title thread so_remove_hud_item(true);

		if (isdefined(player.hud_wave_count))
		{
			player.hud_wave_count thread so_remove_hud_item(true);
		}
	}
}

hud_display_uav_spotted(player, uav_id)
{
	hudelem = so_create_hud_item(-1, so_hud_ypos() + 100, &"SO_DEFENSE_INVASION_UAV_SPOTTED", player);
	hudelem set_hud_yellow();
	thread hud_display_uav_spotted_fade(hudelem, uav_id);
	return hudelem;
}

hud_display_uav_targetting(hudelem)
{
	if (!isdefined(hudelem))
		return;
		
	hudelem set_hud_red();
	hudelem.label = &"SO_DEFENSE_INVASION_UAV_TARGETTING";
}

hud_display_uav_spotted_fade(hudelem, uav_id)
{
	uav_notarget = "hellfire_attack_notarget_" + uav_id;
	level common_scripts\utility::waittill_any(uav_notarget, "hellfire_attack_stop", "hellfire_attack_pause", "special_op_terminated", "wave_complete");

	if (!isdefined(hudelem))
		return;

	hudelem so_remove_hud_item(false, true);
}

hud_display_wave(title_text, timer)
{
	hudelems = [];
	list = hud_get_wave_list(title_text);
	for (i = 0; i < list.size; i++)
	{
		if (list[i] != &"SO_DEFENSE_INVASION_ALERT_BLANK")
		{
			hudelems[i] = hud_create_wave_splash_default(i, list[i]);
			hudelems[i] setpulsefx(60, ((timer - 1) * 1000) - (i * 1000), 1000);
		}
		wait 1;
	}
	
	wait timer - (list.size * 1);

	foreach(hudelem in hudelems)
		hudelem destroy();	
}

hud_create_wave_splash_default(yline, message)
{
	hudelem = so_create_hud_item(yline, 0, message);
	hudelem.alignx = "center";
	hudelem.horzalign = "center";
	
	return hudelem;
}

hud_display_enemies_active(enemy_title, enemy_total, enemy_death)
{
	if (!isdefined(level.hud_display_enemies))
		level.hud_display_enemies = 0;
		
	level.hud_display_enemies++;
	
	foreach (player in level.players)
		player thread hud_display_enemies_active_player(enemy_title, enemy_total, enemy_death);
}

hud_display_enemies_active_player(enemy_title, enemy_total, enemy_death)
{
	level endon("special_op_terminated");
	
	hud_line = level.hud_display_enemies + 1;
	hudelem_title = so_create_hud_item(hud_line, so_hud_ypos(), enemy_title, self);
	hudelem_count = so_create_hud_item(hud_line, so_hud_ypos(), undefined, self);
	hudelem_count.alignx = "left";

	force_pulse = true;
	enemy_max = enemy_total;
	while (enemy_total > 0)
	{
		if (enemy_death == "hunter_death")
		{
			thread so_dialog_counter_update(enemy_total, enemy_max);
			thread hud_display_enemies_pulse_hunter(hudelem_title, hudelem_count, enemy_total, force_pulse);
		}
		else
		{
			thread hud_display_enemies_pulse_vehicle(hudelem_title, hudelem_count, enemy_total);
		}
	
		force_pulse = false;
		level waittill(enemy_death);
	
		enemy_total--;
	}

	hudelem_count so_remove_hud_item(true);
	hudelem_count = so_create_hud_item(hud_line, so_hud_ypos(), &"SPECIAL_OPS_DASHDASH", self);
	hudelem_count.alignx = "left";

	hudelem_title thread so_hud_pulse_success();
	hudelem_count thread so_hud_pulse_success();

	level waittill("wave_complete");

	hudelem_title	thread so_remove_hud_item();
	hudelem_count	thread so_remove_hud_item();
}

hud_display_enemies_pulse_hunter(hudelem_title, hudelem_count, enemy_total, force_pulse)
{
	hudelem_count setvalue(enemy_total);

	if (enemy_total > 5)
	{
		if (force_pulse)
		{
			hudelem_title thread so_hud_pulse_default();
			hudelem_count thread so_hud_pulse_default();
		}
		return;
	}

	hudelem_title thread so_hud_pulse_close();
	hudelem_count thread so_hud_pulse_close();
}

hud_display_enemies_pulse_vehicle(hudelem_title, hudelem_count, enemy_total)
{
	hudelem_count setvalue(enemy_total);
	
	hudelem_title thread so_hud_pulse_default();
	hudelem_count thread so_hud_pulse_default();
}

// ---------------------------------------------------------------------------------

door_diner_open()
{
	diner_back_door = getent("diner_back_door", "targetname");
	diner_back_door rotateyaw(85, .3);//counter clockwise
	diner_back_door playsound("diner_backdoor_slams_open");
	diner_back_door connectpaths();
}

door_nates_locker_open()
{
	nates_meat_locker_door = getent("nates_meat_locker_door", "targetname");
	nates_meat_locker_door_model = getent(nates_meat_locker_door.target, "targetname");
	nates_meat_locker_door_model linkto(nates_meat_locker_door);
	nates_meat_locker_door rotateyaw(-82, .1, 0, 0 );
	nates_meat_locker_door connectpaths();
}

door_bt_locker_open()
{
	bt_locker_door = getent("bt_locker_door", "targetname");
	bt_locker_door rotateyaw(-172, .1, 0, 0 );
	bt_locker_door connectpaths();
}

// ---------------------------------------------------------------------------------

so_defense_convert_enemies()
{
	// convert some additional enemies over to available gas station enemies
	convert_enemies = getentarray("diner_enemy_defenders", "targetname");
	convert_enemies = maps\_utility::array_merge(convert_enemies, getentarray("diner_enemy_counter_attack", "targetname"));
	for (i = 0; i < convert_enemies.size; i++)
		convert_enemies[i].targetname = "gas_station_enemies";
		
	// convert some additional enemies over to available burger town enemies
	convert_enemies = getentarray("burger_town_nates_attackers", "targetname");
	convert_enemies = maps\_utility::array_merge(convert_enemies, getentarray("burger_town_enemy_defenders", "targetname"));
	for (i = 0; i < convert_enemies.size; i++)
		convert_enemies[i].targetname = "burger_town_enemies";

	// make sure we only have the guys inside the burger joint.	
	convert_enemies = getentarray("burger_town_enemies", "targetname");
	burger_town_include = getent("so_burger_town_enemy_include", "script_noteworthy");
	for (i = convert_enemies.size - 1; i >= 0; i--)
	{
		if (!(convert_enemies[i] istouching(burger_town_include)))
			convert_enemies[i].targetname = "ignoreme";
	}	
}

so_defense_set_enemy_spawner_flags()
{
	// clear out some flags on enemies being used in the level.
	convert_enemies = getentarray("gas_station_enemies", "targetname");
	convert_enemies = maps\_utility::array_merge(convert_enemies, getentarray("bank_enemies", "targetname"));
	convert_enemies = maps\_utility::array_merge(convert_enemies, getentarray("taco_enemies", "targetname"));
	convert_enemies = maps\_utility::array_merge(convert_enemies, getentarray("burger_town_enemies", "targetname"));
	foreach (guy in convert_enemies)
	{
		if (isdefined(guy.script_goalvolume))
			guy.script_goalvolume = undefined;
		if (isdefined(guy.script_forcespawn))
			guy.script_forcespawn = undefined;
	}
}

hud_get_wave_list(title_text)
{
	list = [];
	if (!isdefined(title_text))
		return list;
			
	switch (title_text)
	{
		case "so_defense_invasion_wave_1":
			list[0] = &"SO_DEFENSE_INVASION_WAVE_1";
			list[1] = &"SO_DEFENSE_INVASION_ALERT_20";
			break;
	
		case "so_defense_invasion_wave_2":
			list[0] = &"SO_DEFENSE_INVASION_WAVE_2";
			list[1] = &"SO_DEFENSE_INVASION_ALERT_30";
			list[2] = &"SO_DEFENSE_INVASION_ALERT_HELLFIRE";
			break;
	
		case "so_defense_invasion_wave_3":
			list[0] = &"SO_DEFENSE_INVASION_WAVE_3";
			list[1] = &"SO_DEFENSE_INVASION_ALERT_40";
			list[2] = &"SO_DEFENSE_INVASION_ALERT_HELI";
			list[3] = &"SO_DEFENSE_INVASION_ALERT_HELLFIRE";
			break;
	
		case "so_defense_invasion_wave_4":
			list[0] = &"SO_DEFENSE_INVASION_WAVE_4";
			list[1] = &"SO_DEFENSE_INVASION_ALERT_30_SKILLED";
			list[2] = &"SO_DEFENSE_INVASION_ALERT_BTR80";
			list[3] = &"SO_DEFENSE_INVASION_ALERT_HELLFIRE";
			break;
	
		case "so_defense_invasion_wave_5":
			list[0] = &"SO_DEFENSE_INVASION_WAVE_5";
			list[1] = &"SO_DEFENSE_INVASION_ALERT_40_SKILLED";
			list[2] = &"SO_DEFENSE_INVASION_ALERT_BTR80";
			list[3] = &"SO_DEFENSE_INVASION_ALERT_HELIS";
			list[4] = &"SO_DEFENSE_INVASION_ALERT_HELLFIRE";
			break;
			
		default:
			assertex(false, "so_defense_build_enemy_list() received an invalid title_text (" + title_text + ")");
			break;
	}
	
	return list;
}

// ---------------------------------------------------------------------------------