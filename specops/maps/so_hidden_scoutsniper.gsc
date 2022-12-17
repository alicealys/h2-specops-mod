#include common_scripts\utility;
#include maps\_utility;
#include maps\_anim;
#include maps\_specialops;
#include maps\so_hidden_scoutsniper_code;

// ---------------------------------------------------------------------------------
//	Init
// ---------------------------------------------------------------------------------
main()
{
	level.so_compass_zoom = "far";
	
	default_start( ::start_so_hidden );
	add_start( "so_hidden",					::start_so_hidden,					"SO Hidden" );
	add_start( "so_hidden_ghillie_crates",	::start_so_hidden_ghillie_crates,	"Ghillie - Crates" );
	add_start( "so_hidden_ghillie_valley",	::start_so_hidden_ghillie_valley,	"Ghillie - Valley" );
	add_start( "so_hidden_patrol_church",	::start_so_hidden_patrol_church,	"Patrol - Church" );
	add_start( "so_hidden_patrol_houses",	::start_so_hidden_patrol_houses,	"Patrol - Houses" );
	add_start( "so_hidden_patrol_barn",		::start_so_hidden_patrol_barn,		"Patrol - Barn" );
	add_start( "so_hidden_ghillie_houses",	::start_so_hidden_ghillie_houses,	"Ghillie - Houses" );

	setsaveddvar( "sm_sunShadowScale", "0.7" ); // optimization
	setsaveddvar( "ui_hidemap", "1" );
	
	precachemodel("vehicle_small_wagon_blue_destructible");
	//maps\so_hidden_so_ghillies_anim::main();
	//maps\so_ghillies_precache::main();
	//maps\createart\so_ghillies_art::main();
	//maps\so_ghillies_fx::main();

	maps\scoutsniper::main();

	//thread maps\so_ghillies_amb::main();

	patch();
}

patch()
{
	// fix idle patrol anims
	replacefunc(maps\_patrol::patrol, ::patrol);
}

patrol( var_0, var_1, var_2 )
{
    if ( isdefined( self.enemy ) )
        return;

    self endon( "death" );
    self endon( "end_patrol" );
    self endon( "pain" );
    level endon( "_stealth_spotted" );
    level endon( "_stealth_found_corpse" );
    var_3 = 400;
    thread maps\_patrol::waittill_combat();
    thread maps\_patrol::waittill_death();
    self endon( "enemy" );
    self.goalradius = 32;
    self allowedstances( "stand" );
    self.disablearrivals = 1;
    self.disableexits = 1;
    self.allowdeath = 1;
    self.script_patroller = 1;
    maps\_patrol::linkpet();

    if ( maps\_patrol::_id_A849() )
    {
        maps\_patrol::_id_BBB2();
        maps\_patrol::_id_CE2A();
    }

    var_4 = "patrol_walk";

    if ( isdefined( self.patrol_walk_anim ) )
        var_4 = self.patrol_walk_anim;

    var_5 = isdefined( self._id_CA31 ) && self._id_CA31;
    maps\_utility::set_generic_run_anim( var_4, 1, !var_5 );
    var_6 = [];
    var_6["ent"][1] = maps\_patrol::get_target_ents;
    var_6["ent"][0] = common_scripts\utility::get_linked_ents;
    var_6["node"][1] = maps\_patrol::get_target_nodes;
    var_6["node"][0] = maps\_patrol::get_linked_nodes;
    var_6["struct"][1] = maps\_patrol::get_target_structs;
    var_6["struct"][0] = maps\_utility::get_linked_structs;
    var_7["ent"] = maps\_utility::set_goal_ent;
    var_7["node"] = maps\_utility::set_goal_node;
    var_7["struct"] = maps\_utility::set_goal_ent;

    if ( isdefined( var_0 ) )
        self.target = var_0;

    if ( isdefined( self.target ) )
    {
        var_8 = 1;
        var_9 = maps\_patrol::get_target_ents();
        var_10 = maps\_patrol::get_target_nodes();
        var_11 = maps\_patrol::get_target_structs();

        if ( var_9.size )
        {
            var_12 = common_scripts\utility::random( var_9 );
            var_13 = "ent";
        }
        else if ( var_10.size )
        {
            var_12 = common_scripts\utility::random( var_10 );
            var_13 = "node";
        }
        else
        {
            var_12 = common_scripts\utility::random( var_11 );
            var_13 = "struct";
        }
    }
    else
    {
        var_8 = 0;
        var_9 = common_scripts\utility::get_linked_ents();
        var_10 = maps\_patrol::get_linked_nodes();

        if ( var_9.size )
        {
            var_12 = common_scripts\utility::random( var_9 );
            var_13 = 1;
        }
        else
        {
            var_12 = common_scripts\utility::random( var_10 );
            var_13 = 0;
        }
    }

    var_14 = [];
    var_14["pause"] = "patrol_idle_";
    var_14["turn180"] = "patrol_turn180";
    var_14["smoke"] = "patrol_idle_smoke";
    var_14["stretch"] = "patrol_idle_stretch";
    var_14["checkphone"] = "patrol_idle_checkphone";
    var_14["phone"] = "patrol_idle_phone";

    if ( isdefined( var_12 ) )
    {
        var_15 = 0;
        var_16 = var_12;

        for (;;)
        {
            while ( isdefined( var_16.patrol_claimed ) )
                wait 0.05; 

            var_12.patrol_claimed = undefined;
            var_12 = var_16;
            self notify( "release_node" );
            var_12.patrol_claimed = 1;
            self.last_patrol_goal = var_12;
            [[ var_7[var_13] ]]( var_12 );

            if ( isdefined( var_12.radius ) && var_12.radius > 0 )
                self.goalradius = var_12.radius;
            else
                self.goalradius = 32;

            self waittill( "goal" );
            var_12 notify( "trigger", self );

            if ( isdefined( var_12.script_flag_set ) )
                common_scripts\utility::flag_set( var_12.script_flag_set );

            if ( isdefined( var_12.script_ent_flag_set ) )
                maps\_utility::ent_flag_set( var_12.script_ent_flag_set );

            if ( isdefined( var_12.script_flag_clear ) )
                common_scripts\utility::flag_clear( var_12.script_flag_clear );

            var_17 = var_12 [[ var_6[var_13][var_8] ]]();

            if ( !isdefined( var_17 ) || !var_17.size )
            {
                self notify( "reached_path_end" );
                self notify( "_patrol_reached_path_end" );

                if ( isalive( self.patrol_pet ) )
                    self.patrol_pet notify( "master_reached_patrol_end" );
            }

            var_16 = common_scripts\utility::random( var_17 );

            if ( level.script == "trainer" )
            {
                while ( distance2dsquared( var_16.origin, level.player.origin ) < 1024 )
                {
                    var_17 = var_16 [[ var_6[var_13][var_8] ]]();
                    var_16 = var_17[0];
                }
            }

            var_18 = distance2dsquared( var_12.origin, self.origin ) < var_3;

            if ( isdefined( var_16 ) )
                var_19 = distance2dsquared( var_12.origin, var_16.origin ) < var_3;
            else
                var_19 = 1;

            var_20 = isdefined( var_12.script_delay );
            var_21 = isdefined( var_12.script_flag_wait );
            var_22 = isdefined( var_12.script_animation );
            var_23 = var_17.size == 0;
            var_24 = var_20 || var_21 || var_22 || var_23;
            var_25 = common_scripts\utility::ter_op( var_23, "path_end_idle", "patrol_stop" );
            var_26 = "patrol_start";
            var_27 = animscripts\reactions::reactionscheckloop;

            if ( !var_15 && var_24 )
            {
                var_15 = 1;

                if ( !var_18 )
                    maps\_patrol::patrol_do_stop_transition_anim( var_25, var_27 );
            }

            if ( var_20 )
                wait(var_12.script_delay);

            if ( var_21 )
                common_scripts\utility::flag_wait( var_12.script_flag_wait );

            var_28 = var_12.script_animation;

            if ( var_22 )
            {
                self.patrol_script_animation = 1;
                var_29 = var_14[var_28];

                if ( isdefined( var_29 ) )
                {
                    if ( var_28 == "turn180" && isdefined( self.patrol_turn180 ) )
                        var_29 = self.patrol_turn180;

                    if ( var_28 == "pause" )
                    {
                        if ( isdefined( self.patrol_scriptedanim ) && isdefined( self.patrol_scriptedanim[var_28] ) )
                            var_29 = self.patrol_scriptedanim[var_28][randomint( self.patrol_scriptedanim[var_28].size )];
                        else
                            var_29 += randomintrange( 1, 6 );
                    }

                    maps\_anim::anim_generic_custom_animmode( self, "gravity", var_29, undefined, var_27 );
                }

                self.patrol_script_animation = undefined;
            }

            if ( var_23 && isdefined( self.patrol_end_idle ))
            {
                var_30 = undefined;

                if ( isdefined( self.patrol_end_idle ) && !isdefined( var_28 ) )
                    var_30 = self.patrol_end_idle[randomint( self.patrol_end_idle.size )];
                else if ( var_22 )
                    var_30 = var_14[var_28];

                if ( isdefined( var_30 ) )
                {
                    for (;;)
                    {
                        waitframe();
                        maps\_anim::anim_generic_custom_animmode( self, "gravity", var_30, undefined, var_27 );
                    }
                }

                break;
            }

            if ( var_15 )
            {
                if ( !var_19 )
                {
                    if ( !isdefined( self.cqbwalking ) || !self.cqbwalking )
                    {
                        var_15 = 0;

                        if ( !isdefined( var_28 ) || var_28 != "turn180" )
                            maps\_patrol::patrol_do_start_transition_anim( var_26, var_27 );
                    }
                }
            }
        }
    }
}

// ---------------------------------------------------------------------------------
//	Challenge Initializations
// ---------------------------------------------------------------------------------
start_so_hidden()
{
	start_so_hidden_basics();

	thread enable_patrol_enemies_crates();
	thread enable_ghillie_enemies_crates();
	thread enable_ghillie_enemies_valley();
	thread enable_patrol_enemies_church();
	thread enable_patrol_enemies_houses();
	thread enable_patrol_enemies_barn();
	thread enable_ghillie_enemies_houses();
}

start_so_hidden_ghillie_crates()
{
	start_so_hidden_basics();

	thread enable_ghillie_enemies_crates();
	thread enable_ghillie_enemies_valley();
	thread enable_patrol_enemies_church();
	thread enable_patrol_enemies_houses();
	thread enable_patrol_enemies_barn();
	thread enable_ghillie_enemies_houses();
	
	start_so_hidden_gogogo( "start_ghillie_crates" );
}

start_so_hidden_ghillie_valley()
{
	start_so_hidden_basics();

	thread enable_ghillie_enemies_valley();
	thread enable_patrol_enemies_church();
	thread enable_patrol_enemies_houses();
	thread enable_patrol_enemies_barn();
	thread enable_ghillie_enemies_houses();
	
	start_so_hidden_gogogo( "start_ghillie_valley" );
}

start_so_hidden_patrol_church()
{
	start_so_hidden_basics();

	thread enable_patrol_enemies_church();
	thread enable_patrol_enemies_houses();
	thread enable_patrol_enemies_barn();
	thread enable_ghillie_enemies_houses();

	start_so_hidden_gogogo( "start_patrol_church" );
}

start_so_hidden_patrol_houses()
{
	start_so_hidden_basics();

	thread enable_patrol_enemies_houses();
	thread enable_patrol_enemies_barn();
	thread enable_ghillie_enemies_houses();

	start_so_hidden_gogogo( "start_patrol_houses" );
}

start_so_hidden_patrol_barn()
{
	start_so_hidden_basics();

	thread enable_patrol_enemies_barn();
	thread enable_ghillie_enemies_houses();
	
	start_so_hidden_gogogo( "start_patrol_barn" );
}

start_so_hidden_ghillie_houses()
{
	start_so_hidden_basics();

	thread enable_ghillie_enemies_houses();
	
	start_so_hidden_gogogo( "start_ghillie_houses" );
}

start_so_hidden_basics()
{
	so_hidden_init();

	thread enable_stealth();
	thread enable_radiation();
	array_thread( level.players, ::dialog_unsilenced_weapons );
	
	thread fade_challenge_in();
	thread fade_challenge_out( "so_hidden_complete" );

	thread enable_challenge_timer( "so_hidden_start" , "so_hidden_complete" );
	thread enable_triggered_complete( "so_hidden_exit_trigger", "so_hidden_complete", "all" );

	// Hint to show current bonuses.
	array_thread( level.players, ::hud_bonuses_create );
}

so_hidden_init()
{
	flag_init( "so_hidden_complete" );
	flag_init( "so_hidden_exit_trigger" );
	flag_init( "force_disable_stealth" );
	
	flag_init( "church_windows_back" );
	flag_init( "church_windows_front" );
	flag_init( "school_windows" );
	flag_init( "house_windows" );

//	thread stealth_achievement();

	level.custom_eog_no_kills = true;
	level.custom_eog_no_partner = true;
	level.eog_summary_callback = ::custom_eog_summary;

	switch( level.gameSkill )
	{
		case 0:	// Easy
		case 1:	so_hidden_setup_regular();	break;	// Regular
		case 2:	so_hidden_setup_hardened();	break;	// Hardened
		case 3:	so_hidden_setup_veteran();	break;	// Veteran
	}
	
	// Objective marker updates.
	thread objective_set_chopper();
	
	// Give player a chance to not be seen through windows.	
	array_thread( getentarray( "clip_nosight", "targetname" ), ::clip_nosight_wait_for_activate );

	// Open up the church doorway.
	church_doors = getentarray( "church_door_front", "targetname" );
	foreach ( door in church_doors )
	{
		door ConnectPaths();
		door Delete();
	}

	// Keeps track of how many are active at a time.
	level.ghillie_count = 0;
	level.patrol_count = 0;
	level.enemies_spawned = 0;
	
	level.ghillie_go_aggro_distance = 450;
	
	patrol_enemy_reset_multi_kill();

	// Only allow kill announcements every few seconds.	
	level.death_dialog_throttle = 2500;
	level.death_dialog_time = gettime() + level.death_dialog_throttle;
	
	level.dialog_kill_stealth = [];
	level.dialog_kill_stealth[ level.dialog_kill_stealth.size ] = "so_hid_ghil_goodnight";
	level.dialog_kill_stealth[ level.dialog_kill_stealth.size ] = "so_hid_ghil_beautiful";
	level.dialog_kill_stealth[ level.dialog_kill_stealth.size ] = "so_hid_ghil_perfect";

	level.dialog_kill_quiet = [];
	level.dialog_kill_quiet[ level.dialog_kill_quiet.size ] = "so_hid_ghil_tango_down";
	level.dialog_kill_quiet[ level.dialog_kill_quiet.size ] = "so_hid_ghil_hesdown";
	level.dialog_kill_quiet[ level.dialog_kill_quiet.size ] = "so_hid_ghil_neutralized";
	
	level.dialog_kill_basic = [];
	level.dialog_kill_basic[ level.dialog_kill_basic.size ] = "so_hid_ghil_sloppy";
	level.dialog_kill_basic[ level.dialog_kill_basic.size ] = "so_hid_ghil_noisy";
	level.dialog_kill_basic[ level.dialog_kill_basic.size ] = "so_hid_ghil_do_better";

	// Global time bonuses
	level.bonus_stealth = 6;
	level.bonus_nofire = 3;
	level.bonus_basic = 1;
	level.bonus_time_given = 0;
	
	// Global number of kill counts
	level.deaths_stealth = 0;
	level.deaths_nofire = 0;
	level.deaths_basic = 0;

	// Individual player kill counts
	foreach ( player in level.players )
	{
		player.kills_stealth = 0;
		player.kills_nofire = 0;
		player.kills_basic = 0;
	}
	
	level._effect[ "extraction_smoke" ] = loadfx( "fx/smoke/green_flare_smoke_distant" );

	deadquotes = [];
	deadquotes[ deadquotes.size ] = "@DEADQUOTE_SO_STEALTH_LOOK_FOR_ENEMIES";
	deadquotes[ deadquotes.size ] = "@DEADQUOTE_SO_STEALTH_STAY_LOW";
	deadquotes[ deadquotes.size ] = "@DEADQUOTE_SO_STEALTH_USE_SILENCERS";
	//so_include_deadquote_array( deadquotes );
}

start_so_hidden_gogogo( start_id )
{
	start_point = getstruct( start_id, "script_noteworthy" );
	//maps\_specialops_code::place_player_at_start_point( level.player, start_point );
	if ( is_coop() )
		//maps\_specialops_code::place_player2_near_player1();

	wait 0.05;
	flag_set( "so_hidden_start" );
}

so_hidden_setup_regular()
{
	obj = getstruct( "so_hidden_obj_church", "script_noteworthy" );
	objective_add( 1, "current", &"SO_HIDDEN_SO_GHILLIES_OBJ_REGULAR", obj.origin );
	
	level.coop_difficulty_scalar = 0.75;

	level.ghillie_move_intro_min = 2.0;
	level.ghillie_move_intro_max = 3.0;
	level.ghillie_move_time_min = 4.0;
	level.ghillie_move_time_max = 8.0;

	level.ghillie_shoot_pause_min = 2.5;
	level.ghillie_shoot_pause_max = 3.5;
	level.ghillie_shoot_quit_min = 4.0;
	level.ghillie_shoot_quit_max = 8.0;
	level.ghillie_shoot_hold_min = 2.0;
	level.ghillie_shoot_hold_max = 3.0;
	level.ghillie_crouch_chance = 0.33;
	
	level.ghillie_flub_time_min = 5000;
	level.ghillie_flub_time_max = 10000;
}

so_hidden_setup_hardened()
{
	obj = getstruct( "so_hidden_obj_church", "script_noteworthy" );
	objective_add( 1, "current", &"SO_HIDDEN_SO_GHILLIES_OBJ_HARDENED", obj.origin );

	level.coop_difficulty_scalar = 0.33;

	level.ghillie_move_intro_min = 2.0;
	level.ghillie_move_intro_max = 3.0;
	level.ghillie_move_time_min = 4.0;
	level.ghillie_move_time_max = 8.0;

	level.ghillie_shoot_pause_min = 1.0;
	level.ghillie_shoot_pause_max = 1.75;
	level.ghillie_shoot_quit_min = 8.0;
	level.ghillie_shoot_quit_max = 12.0;
	level.ghillie_shoot_hold_min = 0.8;
	level.ghillie_shoot_hold_max = 1.6;
	level.ghillie_crouch_chance = 0.15;

	level.ghillie_flub_time_min = 10000;
	level.ghillie_flub_time_max = 20000;
}

so_hidden_setup_veteran()
{
	obj = getstruct( "so_hidden_obj_church", "script_noteworthy" );
	objective_add( 1, "current", &"SO_HIDDEN_SO_GHILLIES_OBJ_VETERAN", obj.origin );

	level.coop_difficulty_scalar = 0.25;

	level.ghillie_move_intro_min = 1.0;
	level.ghillie_move_intro_max = 2.0;
	level.ghillie_move_time_min = 4.0;
	level.ghillie_move_time_max = 8.0;

	level.ghillie_shoot_pause_min = 0.4;
	level.ghillie_shoot_pause_max = 0.8;
	level.ghillie_shoot_quit_min = 10.0;
	level.ghillie_shoot_quit_max = 20.0;
	level.ghillie_shoot_hold_min = 0.2;
	level.ghillie_shoot_hold_max = 0.4;
	level.ghillie_crouch_chance = 0.0;
}

// ---------------------------------------------------------------------------------
//	Enable/Disable events
// ---------------------------------------------------------------------------------

// ---------------------------------------------------------------------------------

enable_patrol_enemies_crates()
{
	thread create_patrol_enemies( "patrol_enemy_crates", "patrol_enemies_spawn_crates" );
}

enable_patrol_enemies_church()
{
	flag_set( "church_windows_back" );
	thread create_patrol_enemies( "patrol_enemy_church", "patrol_enemies_spawn_church", 0.5 );
}

enable_patrol_enemies_houses()
{
	flag_set( "church_windows_front" );
	flag_set( "school_windows" );
	thread create_patrol_enemies( "patrol_enemy_houses", "patrol_enemies_spawn_houses" );
}

enable_patrol_enemies_barn()
{
	flag_set( "house_windows" );
	thread create_patrol_enemies( "patrol_enemy_barn", "patrol_enemies_spawn_barn" );
}

// ---------------------------------------------------------------------------------

enable_ghillie_enemies_crates()
{
	thread create_ghillie_enemies( "ghillie_enemy_crates", "ghillie_enemies_spawn_crates" );
}

enable_ghillie_enemies_valley()
{
	thread create_ghillie_enemies( "ghillie_enemy_valley", "ghillie_enemies_spawn_crates", "ghillie_enemies_spawn_valley" );
}

enable_ghillie_enemies_houses()
{
	thread create_ghillie_enemies( "ghillie_enemy_houses", "ghillie_enemies_spawn_houses" );
}

// ---------------------------------------------------------------------------------

enable_stealth()
{
	thread turn_on_stealth();
}

enable_radiation()
{
	thread turn_on_radiation();
}

// ---------------------------------------------------------------------------------

custom_eog_summary()
{
	/*enemies_left = level.enemies_spawned;
	foreach( player in level.players )
	{
		enemies_left -= player.kills_stealth;
		enemies_left -= player.kills_nofire;
		enemies_left -= player.kills_basic;
	}

	foreach ( player in level.players )
	{
		player add_custom_eog_summary_line( "@SO_HIDDEN_SO_GHILLIES_STAT_STEALTH",	player.kills_stealth );
		player add_custom_eog_summary_line( "@SO_HIDDEN_SO_GHILLIES_STAT_NOFIRE",	player.kills_nofire );
		player add_custom_eog_summary_line( "@SO_HIDDEN_SO_GHILLIES_STAT_BASIC",	player.kills_basic );
		if ( flag( "so_hidden_complete" ) )
			player add_custom_eog_summary_line( "@SO_HIDDEN_SO_GHILLIES_STAT_SKIPPED",	enemies_left );
	}*/
}

// ---------------------------------------------------------------------------------

stealth_achievement()
{
	flag_wait( "so_hidden_complete" );
	
	if ( !stealth_achieved() )
		return;

	foreach ( player in level.players )
	{
		// No achievement for individual players unless they made at least one perfect kill.
		if ( player.kills_stealth > 0 )
			player maps\_utility::player_giveachievement_wrapper( "WRAITH" );
	}
}

stealth_achieved()
{
	// No achievement if any non-perfect kills happened during the mission.
	foreach( player in level.players )
	{
		if ( player.kills_nofire > 0 )
			return false;
		if ( player.kills_basic > 0 )
			return false;
	}

	return true;		
}

// ---------------------------------------------------------------------------------