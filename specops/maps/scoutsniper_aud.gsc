// H1 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool

main()
{
    config_system();
    init_snd_flags();
    init_globals();
    launch_threads();
    launch_loops();
    thread launch_line_emitters();
    create_level_envelop_arrays();
    precache_presets();
    register_snd_messages();
    thread intro_start();
    common_scripts\utility::run_thread_on_targetname( "trigger_bird_flyaway01", ::bird_flyaway_sound01 );
    common_scripts\utility::run_thread_on_targetname( "trigger_bird_flyaway02", ::bird_flyaway_sound02 );
    common_scripts\utility::run_thread_on_targetname( "trigger_bird_flyaway03", ::bird_flyaway_sound03 );
}

config_system()
{
    soundscripts\_audio::set_stringtable_mapname( "shg" );
    soundscripts\_snd_filters::snd_set_occlusion( "med_occlusion" );
    soundscripts\_audio_mix_manager::mm_add_submix( "mix_scoutsniper_global" );
}

init_snd_flags()
{
    common_scripts\utility::flag_init( "musicSubmixDelay" );
}

init_globals()
{
    level._interior_vo_zone = getentarray( "interior_vo_zone", "targetname" );
}

launch_threads()
{

}

launch_loops()
{

}

launch_line_emitters()
{
    wait 0.1;
}

create_level_envelop_arrays()
{

}

precache_presets()
{

}

register_snd_messages()
{
    soundscripts\_snd::snd_register_message( "snd_zone_handler", ::zone_handler );
    soundscripts\_snd::snd_register_message( "snd_music_handler", ::music_handler );
    soundscripts\_snd::snd_register_message( "aud_start_intro_checkpoint", ::aud_start_intro_checkpoint );
    soundscripts\_snd::snd_register_message( "aud_start_church_checkpoint", ::aud_start_intro_checkpoint );
    soundscripts\_snd::snd_register_message( "aud_start_graveyard_checkpoint", ::aud_start_intro_checkpoint );
    soundscripts\_snd::snd_register_message( "aud_start_pond_checkpoint", ::aud_start_intro_checkpoint );
    soundscripts\_snd::snd_register_message( "aud_start_cargo_checkpoint", ::aud_start_intro_checkpoint );
    soundscripts\_snd::snd_register_message( "aud_start_dash_checkpoint", ::aud_start_intro_checkpoint );
    soundscripts\_snd::snd_register_message( "aud_start_town_checkpoint", ::aud_start_intro_checkpoint );
    soundscripts\_snd::snd_register_message( "aud_start_dogs_checkpoint", ::aud_start_intro_checkpoint );
    soundscripts\_snd::snd_register_message( "aud_start_center_checkpoint", ::aud_start_intro_checkpoint );
    soundscripts\_snd::snd_register_message( "aud_start_end_checkpoint", ::aud_start_intro_checkpoint );
    soundscripts\_snd::snd_register_message( "start_field_mix", ::start_field_mix );
    soundscripts\_snd::snd_register_message( "start_pond_mix", ::start_pond_mix );
    soundscripts\_snd::snd_register_message( "start_cargo_mix", ::start_cargo_mix );
    soundscripts\_snd::snd_register_message( "start_taking_guard_mix", ::start_taking_guard_mix );
    soundscripts\_snd::snd_register_message( "stop_taking_guard_mix", ::stop_taking_guard_mix );
    soundscripts\_snd::snd_register_message( "start_dash_mix", ::start_dash_mix );
    soundscripts\_snd::snd_register_message( "aud_start_dash_heli_flyby_sequence", ::aud_start_dash_heli_flyby_sequence );
    soundscripts\_snd::snd_register_message( "aud_start_dash_convoy_sequence", ::aud_start_dash_convoy_sequence );
    soundscripts\_snd::snd_register_message( "start_mix_moving_to_town", ::start_mix_moving_to_town );
    soundscripts\_snd::snd_register_message( "start_town_mix", ::start_town_mix );
    soundscripts\_snd::snd_register_message( "start_dogs_mix", ::start_dogs_mix );
    soundscripts\_snd::snd_register_message( "start_school_heli_mix", ::start_school_heli_mix );
    soundscripts\_snd::snd_register_message( "start_center_mix", ::start_center_mix );
    soundscripts\_snd::snd_register_message( "start_end_mix", ::start_end_mix );
    soundscripts\_snd::snd_register_message( "play_additionnal_fs_sfx", ::play_additionnal_fs_sfx );
}

zone_handler( var_0, var_1 )
{

}

music_handler( var_0, var_1 )
{

}

aud_start_intro_checkpoint( var_0 )
{
    soundscripts\_audio_zone_manager::azm_start_zone( "exterior" );
}

aud_start_church_checkpoint( var_0 )
{
    soundscripts\_audio_zone_manager::azm_start_zone( "exterior" );
}

aud_start_graveyard_checkpoint( var_0 )
{
    soundscripts\_audio_zone_manager::azm_start_zone( "church" );
}

aud_start_field_checkpoint( var_0 )
{
    soundscripts\_audio_zone_manager::azm_start_zone( "exterior" );
}

aud_start_pond_checkpoint( var_0 )
{
    soundscripts\_audio_zone_manager::azm_start_zone( "exterior" );
}

aud_start_cargo_checkpoint( var_0 )
{
    soundscripts\_audio_zone_manager::azm_start_zone( "exterior" );
}

aud_start_dash_checkpoint( var_0 )
{
    soundscripts\_audio_zone_manager::azm_start_zone( "containor" );
}

aud_start_town_checkpoint( var_0 )
{
    soundscripts\_audio_zone_manager::azm_start_zone( "exterior" );
}

aud_start_dogs_checkpoint( var_0 )
{
    soundscripts\_audio_zone_manager::azm_start_zone( "exterior" );
}

aud_start_center_checkpoint( var_0 )
{
    soundscripts\_audio_zone_manager::azm_start_zone( "exterior" );
}

aud_start_end_checkpoint( var_0 )
{
    soundscripts\_audio_zone_manager::azm_start_zone( "hall" );
}

intro_start()
{
    common_scripts\utility::flag_wait( "introscreen_activate" );
    soundscripts\_audio_mix_manager::mm_add_submix( "scoutsniper_intro_mute" );
    intro_check_end();
}

intro_check_end()
{
    common_scripts\utility::flag_wait( "introscreen_remove_submix" );
    soundscripts\_audio_mix_manager::mm_clear_submix( "scoutsniper_intro_mute" );
    soundscripts\_audio_zone_manager::azm_start_zone( "exterior" );
}

start_field_mix()
{
    soundscripts\_audio_mix_manager::mm_clear_submix( "graveyard_hind_mix" );
    soundscripts\_audio_mix_manager::mm_add_submix( "field_mix" );
}

start_pond_mix()
{
    soundscripts\_audio_mix_manager::mm_clear_submix( "field_mix" );
    soundscripts\_audio_mix_manager::mm_add_submix( "pond_mix" );
}

start_cargo_mix()
{
    soundscripts\_audio_mix_manager::mm_clear_submix( "pond_mix" );
    soundscripts\_audio_mix_manager::mm_add_submix( "cargo_mix" );
}

start_taking_guard_mix()
{
    soundscripts\_audio_mix_manager::mm_add_submix( "taking_guard_mix" );
}

stop_taking_guard_mix()
{
    wait 1;
    soundscripts\_audio_mix_manager::mm_clear_submix( "taking_guard_mix" );
}

start_dash_mix()
{
    soundscripts\_audio_mix_manager::mm_clear_submix( "cargo_mix" );
    soundscripts\_audio_mix_manager::mm_add_submix( "dash_mix" );
}

start_mix_moving_to_town()
{
    self waittill( "trigger", var_0 );

    if ( !common_scripts\utility::flag( "musicSubmixDelay" ) )
    {
        soundscripts\_audio_mix_manager::mm_add_submix( "moving_to_town" );
        level.movingtotownsubmix = 1;
    }

    level common_scripts\utility::flag_wait( "musicSubmixDelay" );

    if ( isdefined( level.movingtotownsubmix ) && level.movingtotownsubmix )
        soundscripts\_audio_mix_manager::mm_clear_submix( "moving_to_town" );
}

moving_to_town_submix_handler()
{
    level maps\_utility::delaythread( 24, common_scripts\utility::flag_set, "musicSubmixDelay" );
    common_scripts\utility::run_thread_on_targetname( "dash_safezone_trigger", ::start_mix_moving_to_town );
}

start_town_mix()
{
    soundscripts\_audio_mix_manager::mm_clear_submix( "dash_mix" );
    soundscripts\_audio_mix_manager::mm_add_submix( "town_mix" );
}

start_dogs_mix()
{
    soundscripts\_audio_mix_manager::mm_clear_submix( "town_mix" );
}

start_center_mix()
{
    soundscripts\_audio_mix_manager::mm_clear_submix( "dogs_mix" );
    soundscripts\_audio_mix_manager::mm_add_submix( "center_mix" );
}

start_school_heli_mix()
{
    soundscripts\_audio_mix_manager::mm_add_submix( "school_heli_mix" );
}

start_end_mix()
{
    soundscripts\_audio_mix_manager::mm_clear_submix( "center_mix" );
    soundscripts\_audio_mix_manager::mm_add_submix( "end_mix" );
}

bird_flywaway( var_0, var_1 )
{
    self waittill( "trigger", var_2 );
    var_3 = spawn( "script_origin", var_0 );
    var_4 = spawn( "script_origin", var_1 );
    var_3 thread maps\_utility::play_sound_on_entity( "anml_bird_startle_flyaway" );
    var_3 moveto( var_4.origin, 2, 0.5 );
    wait 2;
    var_3 delete();
    var_4 delete();
}

bird_flyaway_sound01()
{
    thread bird_flywaway( ( -8751.3, -11507.7, -160.006 ), ( -10563.6, -11225.8, 416.322 ) );
    thread bird_flywaway( ( -9133.09, -10977.3, -33.0787 ), ( -10541.5, -10762.5, 384.938 ) );
}

bird_flyaway_sound02()
{
    bird_flywaway( ( -9819.0, -7393.55, -58.442 ), ( -11173.2, -7153.06, 352.737 ) );
}

bird_flyaway_sound03()
{
    bird_flywaway( ( -187.072, 690.678, -111.24 ), ( -422.097, 1246.75, 314.014 ) );
}

aud_start_graveyard_heli_scripted_sequence( var_0 )
{
    soundscripts\_audio_mix_manager::mm_add_submix( "graveyard_hind_mix" );
    var_1 = spawn( "script_origin", self.origin );
    var_1 linkto( self );
    var_1 playsound( "scn_scoutsniper_graveyard_hind_passby" );
    var_2 = spawn( "script_origin", self.origin );
    var_3 = ( 0.0, 0.0, -400.0 );
    var_2 linkto( self, "tag_origin", var_3, ( 0.0, 0.0, 0.0 ) );
    var_2 playrumblelooponentity( "heli_loop" );
    var_0 thread monitor_end_node_reached();
    common_scripts\utility::waittill_any( "end_node_reached", "enemy", "restart_avm" );
    soundscripts\_audio_mix_manager::mm_clear_submix( "graveyard_hind_mix" );
    var_1 scalevolume( 0, 2 );
    wait 2;
    var_1 stopsound( "scn_scoutsniper_graveyard_hind_passby" );
    var_2 stoprumble( "heli_loop" );
}

aud_start_school_heli_scripted_sequence( var_0 )
{
    maps\_utility::play_sound_on_entity( "scn_scoutsniper_school_int_heli_flyby" );
    var_0 thread monitor_end_node_reached();
    common_scripts\utility::waittill_any( "end_node_reached" );
    wait 2;
    soundscripts\_audio_mix_manager::mm_clear_submix( "school_heli_mix" );
    wait 2;
    self stopsound( "scn_scoutsniper_school_int_heli_flyby" );
}

monitor_end_node_reached()
{
    self waittill( "trigger", var_0 );
    var_0 endon( "death" );
    var_0 notify( "end_node_reached" );
}

aud_start_dash_heli_flyby_sequence()
{
    var_0 = getent( "start_heli", "script_noteworthy" );
    var_0 waittill( "trigger" );
    wait 0.1;
    soundscripts\_audio_mix_manager::mm_add_submix( "dash_heli_flyby_mix" );
    var_1 = maps\_utility::get_vehicle( "dash_hind", "targetname" );
    var_1 playsound( "scn_scoutsniper_dash_heli_flyby" );
    thread aud_start_dash_heli_idle( var_1 );
    common_scripts\utility::flag_wait( "_stealth_spotted" );

    if ( isdefined( level.dash_section ) && level.dash_section )
    {
        soundscripts\_audio_mix_manager::mm_clear_submix( "dash_heli_flyby_mix" );
        var_1 scalevolume( 0, 1 );
        wait 1;
        var_1 stopsounds();
    }
}

aud_start_dash_heli_idle( var_0 )
{
    var_1 = getent( "land_heli_start_node", "script_noteworthy" );
    var_1 waittill( "trigger" );
    soundscripts\_audio_mix_manager::mm_clear_submix( "dash_heli_flyby_mix" );
    var_0 scalevolume( 0.5, 0.5 );
    wait 0.5;
    var_0 playloopsound( "scn_scoutsniper_dash_heli_idle" );
    var_0 scalevolume( 1, 1.5 );
    common_scripts\utility::flag_wait( "_stealth_spotted" );

    if ( isdefined( level.dash_section ) && level.dash_section )
    {
        var_0 scalevolume( 0, 1 );
        wait 1;
        var_0 stoploopsound( "scn_scoutsniper_dash_heli_idle" );
    }
}

aud_field_handle_bmps_engine()
{
    var_0 = getvehiclenode( "first_bmp_end", "script_noteworthy" );
    var_1 = getvehiclenode( "second_bmp_end", "script_noteworthy" );
    var_2 = getvehiclenode( "third_bmp_end", "script_noteworthy" );
    var_3 = getvehiclenode( "fourth_bmp_end", "script_noteworthy" );
    var_0 thread aud_field_bmp_end_node_reached();
    var_1 thread aud_field_bmp_end_node_reached();
    var_2 thread aud_field_bmp_end_node_reached();
    var_3 thread aud_field_bmp_end_node_reached();
}

aud_field_bmp_end_node_reached()
{
    self waittill( "trigger", var_0 );
    var_0 aud_field_bmp_to_idle();
}

aud_field_bmp_engine_handle()
{
    waittillframeend;
    self.script_disablevehicleaudio = 1;
    self vehicle_turnengineoff();
    thread maps\_utility::play_loop_sound_on_tag( "bmp_engine_front", "tag_flash" );
    thread maps\_utility::play_loop_sound_on_tag( "bmp_engine_rear", "tag_c4" );
    thread maps\_utility::play_loop_sound_on_tag( "bmp_thread_loop_side", "tag_wheel_middle_left" );
    thread maps\_utility::play_loop_sound_on_tag( "bmp_thread_loop_side", "tag_wheel_middle_right" );
}

aud_field_bmp_to_idle()
{
    self scalevolume( 0, 1 );
    wait 1.2;
    common_scripts\utility::stop_loop_sound_on_entity( "bmp_engine_front" );
    common_scripts\utility::stop_loop_sound_on_entity( "bmp_engine_rear" );
    common_scripts\utility::stop_loop_sound_on_entity( "bmp_thread_loop_side" );
    self scalevolume( 1, 1 );
    thread maps\_utility::play_loop_sound_on_tag( "bmp_engine_idle", "tag_flash" );
}

aud_start_dash_convoy_sequence()
{
    var_0 = getvehiclenode( "firsttruck", "script_noteworthy" );
    var_1 = getvehiclenode( "secondtruck", "script_noteworthy" );
    var_2 = getvehiclenode( "jeep", "script_noteworthy" );
    var_0 thread convoy_node_reached();
    var_1 thread convoy_node_reached();
    var_2 thread convoy_node_reached();
}

convoy_node_reached()
{
    self waittill( "trigger", var_0 );
    var_1 = "scn_scoutsniper_dash_" + self.script_noteworthy;
    var_0 thread maps\_utility::play_sound_on_entity( var_1 );
    var_2 = getvehiclenode( self.script_noteworthy + "_close", "script_noteworthy" );
    var_2 waittill( "trigger", var_0 );
    var_1 = "scn_scoutsniper_dash_" + self.script_noteworthy + "_close";
    var_0 thread maps\_utility::play_sound_on_entity( var_1 );
}

play_additionnal_fs_sfx()
{
    if ( self != level.price )
        thread maps\_utility::play_sound_on_entity( "scn_scout_convoy_npc_step" );
}

aud_school_heli_rumble()
{
    thread common_scripts\utility::play_sound_in_space( "emt_helicopter_ground_rumble", ( 11330.9, 6009.59, 150.375 ) );
    thread common_scripts\utility::play_sound_in_space( "scn_scoutsniper_school_int_debris_1", ( 11366.0, 5986.93, 191.435 ) );
    thread common_scripts\utility::play_sound_in_space( "scn_scoutsniper_school_int_debris_2", ( 11346.6, 5770.42, 190.031 ) );
}

cargo_guard_getting_hit( var_0 )
{
    var_0 thread maps\_utility::play_sound_on_entity( "scn_scoutsniper_taking_guard" );
}
