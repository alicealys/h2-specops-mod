// H1 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool

dyndof( var_0 )
{
    if ( !isdefined( level.player_dynamic_dof_settings ) )
    {
        level.player_dynamic_dof_settings = spawnstruct();
        level.player_dynamic_dof_settings.settings_list = [];
        level.player_dynamic_dof_settings.base_priority_tracker = 0;
    }

    if ( !isdefined( level.player_dynamic_dof_settings.settings_list[var_0] ) )
    {
        var_1 = __create_dynamic_dof_struct( var_0 );
        var_1.base_priority = level.player_dynamic_dof_settings.base_priority_tracker;
        level.player_dynamic_dof_settings.base_priority_tracker += 1;
        var_1.override_priority = -1;
        level.player_dynamic_dof_settings.settings_list[var_0] = var_1;
    }

    return level.player_dynamic_dof_settings.settings_list[var_0];
}

__create_dynamic_dof_struct( var_0 )
{
    var_1 = spawnstruct();
    var_1.fstop = 22;
    var_1.focus_distance = 10000;
    var_1.focus_distance_offset = 0;
    var_1.focus_speed = 1;
    var_1.aperture_speed = 1;
    var_1.angle_min = -180;
    var_1.angle_max = 180;
    var_1.reference_entity = undefined;
    var_1.tag_name = undefined;
    var_1.offset = undefined;
    var_1.should_autofocus = 0;
    var_1.name = var_0;
    var_1.require_visible = 0;
    var_1.min_range = 0;
    var_1.max_range = 100000;
    var_1.view_model_fstop_scale = 5;
    return var_1;
}

dyndof_remove( var_0 )
{
    if ( isdefined( level.player_dynamic_dof_settings.settings_list[var_0] ) )
    {
        level.player_dynamic_dof_settings.settings_list[var_0] = undefined;
        level.player_dynamic_dof_settings.settings_dirty = 1;
    }
    else
    {

    }
}

dyndof_values( var_0, var_1, var_2, var_3 )
{
    if ( isdefined( var_0 ) )
        self.fstop = var_0;

    if ( isdefined( var_1 ) )
        self.focus_distance = var_1;

    if ( isdefined( var_2 ) )
        self.focus_speed = var_2;

    if ( isdefined( var_3 ) )
        self.aperture_speed = var_3;

    level.player_dynamic_dof_settings.settings_dirty = 1;
    return self;
}

dyndof_fstop( var_0 )
{
    if ( !isdefined( var_0 ) )
        return self;

    self.fstop = var_0;
    level.player_dynamic_dof_settings.settings_dirty = 1;
    return self;
}

dyndof_focus_distance( var_0 )
{
    if ( !isdefined( var_0 ) )
        return self;

    self.focus_distance = var_0;
    level.player_dynamic_dof_settings.settings_dirty = 1;
    return self;
}

dyndof_focus_distance_offset( var_0 )
{
    if ( !isdefined( var_0 ) )
        return self;

    self.focus_distance_offset = var_0;
    level.player_dynamic_dof_settings.settings_dirty = 1;
    return self;
}

dyndof_focus_speed( var_0 )
{
    if ( !isdefined( var_0 ) )
        return self;

    self.focus_speed = var_0;
    level.player_dynamic_dof_settings.settings_dirty = 1;
    return self;
}

dyndof_aperture_speed( var_0 )
{
    if ( !isdefined( var_0 ) )
        return self;

    self.aperture_speed = var_0;
    level.player_dynamic_dof_settings.settings_dirty = 1;
    return self;
}

dyndof_view_model_fstop_scale( var_0 )
{
    if ( !isdefined( var_0 ) )
        return self;

    self.view_model_fstop_scale = var_0;
    level.player_dynamic_dof_settings.settings_dirty = 1;
    return self;
}

dyndof_angles( var_0, var_1 )
{
    if ( !isdefined( var_0 ) || !isdefined( var_1 ) )
        return self;

    while ( var_0 < -180 )
        var_0 += 360;

    while ( var_0 > 180 )
        var_0 -= 360;

    for ( self.angle_min = var_0; var_1 < -180; var_1 += 360 )
    {

    }

    while ( var_1 > 180 )
        var_1 -= 360;

    self.angle_max = var_1;
    level.player_dynamic_dof_settings.settings_dirty = 1;
    return self;
}

dyndof_valid_range( var_0, var_1 )
{
    if ( !isdefined( var_0 ) || !isdefined( var_1 ) )
        return self;

    self.min_range = var_0;
    self.max_range = var_1;
    return self;
}

dyndof_reference_entity( var_0 )
{
    self.reference_entity = var_0;
    level.player_dynamic_dof_settings.settings_dirty = 1;
    return self;
}

dyndof_tag_name( var_0 )
{
    self.tag_name = var_0;
    level.player_dynamic_dof_settings.settings_dirty = 1;
    return self;
}

dyndof_offset( var_0 )
{
    self.offset = var_0;
    level.player_dynamic_dof_settings.settings_dirty = 1;
    return self;
}

dyndof_view_pos( var_0 )
{
    level.player_dynamic_dof_settings.view_pos = var_0;
    level.player_dynamic_dof_settings.settings_dirty = 1;
    return self;
}

dyndof_require_visible( var_0 )
{
    if ( isdefined( var_0 ) )
        self.require_visible = var_0;

    return self;
}

dyndof_priority( var_0 )
{
    self.override_priority = var_0;
    level.player_dynamic_dof_settings.settings_dirty = 1;
    return self;
}

dyndof_autofocus( var_0 )
{
    self.should_autofocus = var_0;
    level.player_dynamic_dof_settings.settings_dirty = 1;
    return self;
}

dyndof_autofocus_add_ignore_entity( var_0 )
{
    if ( !isdefined( self.autofocus_ignore_list ) )
        self.autofocus_ignore_list = [];

    self.autofocus_ignore_list = common_scripts\utility::array_add( self.autofocus_ignore_list, var_0 );
    level.player_dynamic_dof_settings.settings_dirty = 1;
    return self;
}

dyndof_autofocus_remove_ignore_entity( var_0 )
{
    if ( isdefined( self.autofocus_ignore_list ) )
        self.autofocus_ignore_list = common_scripts\utility::array_remove( self.autofocus_ignore_list, var_0 );

    level.player_dynamic_dof_settings.settings_dirty = 1;
    return self;
}

dyndof_system_clear_all()
{
    level.player_dynamic_dof_settings.settings_list = [];
    level.player_dynamic_dof_settings.settings_dirty = 1;
}

dyndof_system_start( var_0 )
{
    level endon( "end_dynamic_dof" );

    if ( isdefined( level.player_dynamic_dof_settings.active ) )
        return;

    level.player_dynamic_dof_settings.active = 1;

    if ( var_0 )
        setsaveddvar( "r_dof_physical_bokehEnable", 1 );

    if ( !isdefined( level.player_dynamic_dof_settings ) && level.player_dynamic_dof_settings.settings_list.size <= 0 )
        return;

    level.player enablephysicaldepthoffieldscripting();
    var_1 = "";

    while ( level.player_dynamic_dof_settings.active )
    {
        var_2 = level.player getplayerangles();
        var_3 = var_2[1];

        if ( isdefined( level.player.owner ) )
            var_2 = combineangles( level.player.owner.angles, level.player.angles );

        var_4 = anglestoforward( var_2 );
        var_5 = level.player.origin + ( 0, 0, level.player getplayerviewheight() );

        if ( isdefined( level.player_dynamic_dof_settings.view_pos ) )
            var_5 = level.player_dynamic_dof_settings.view_pos;

        if ( isdefined( level.player_dynamic_dof_settings.settings_dirty ) )
        {
            var_1 = "";
            level.player_dynamic_dof_settings.settings_dirty = undefined;
        }

        var_6 = undefined;

        foreach ( var_8 in level.player_dynamic_dof_settings.settings_list )
        {
            if ( !isdefined( var_8 ) )
                continue;

            var_9 = var_3;
            var_10 = 1;

            if ( isdefined( var_8.reference_entity ) )
            {
                var_8.reference_point = var_8.reference_entity.origin;

                if ( isdefined( var_8.tag_name ) )
                {
                    if ( !maps\_utility::hastag( var_8.reference_entity.model, var_8.tag_name ) )
                    {
                        if ( !isdefined( var_8.reference_entity.headmodel ) )
                        {

                        }
                        else
                        {

                        }
                    }

                    var_8.reference_point = var_8.reference_entity gettagorigin( var_8.tag_name );
                }

                if ( isdefined( var_8.offset ) )
                {
                    var_11 = rotatevector( var_8.offset, var_8.reference_entity.angles );
                    var_8.reference_point += var_11;
                }

                var_12 = vectornormalize( var_8.reference_point - var_5 );
                var_13 = vectordot( var_4, var_12 );
                var_9 = acos( var_13 );
                var_14 = var_8.min_range * var_8.min_range;
                var_15 = var_8.max_range * var_8.max_range;
                var_16 = distancesquared( var_5, var_8.reference_point );

                if ( var_16 < var_14 || var_16 > var_15 )
                    var_10 = 0;
            }

            if ( isdefined( var_8.reference_point ) && var_8.require_visible )
            {
                var_17 = __dyndof_bullet_trace_ignore_glass( var_5, var_8.reference_point );

                if ( !isdefined( var_17["entity"] ) )
                    var_10 = 0;
                else if ( var_17["entity"] != var_8.reference_entity )
                {
                    var_18 = distancesquared( var_5, var_8.reference_point );
                    var_19 = distancesquared( var_5, var_17["position"] );

                    if ( var_18 != var_19 )
                        var_10 = 0;
                }
            }

            if ( var_10 )
            {
                if ( var_8.should_autofocus || var_9 >= var_8.angle_min && var_9 <= var_8.angle_max )
                {
                    if ( !isdefined( var_6 ) )
                    {
                        var_6 = var_8;
                        continue;
                    }

                    var_6 = var_6 __dyndof_get_higher_priority_setting( var_8 );
                }
            }
        }

        if ( isdefined( var_6 ) )
        {
            var_21 = var_6.focus_distance;

            if ( var_6.should_autofocus )
            {
                var_22 = var_6.focus_distance;

                if ( var_6.focus_distance < 0 )
                    var_22 = 1024;

                var_23 = var_5 + var_4 * var_22;
                var_17 = __dyndof_bullet_trace_ignore_glass( var_5, var_23, var_6.autofocus_ignore_list );
                var_21 = distance( var_5, var_17["position"] );
            }
            else if ( isdefined( var_6.reference_entity ) )
            {
                var_21 = distance( var_6.reference_point, var_5 );

                if ( var_6.focus_distance >= 0 && var_21 > var_6.focus_distance )
                    var_21 = var_6.focus_distance;
            }

            var_24 = var_21 + var_6.focus_distance_offset;

            if ( var_24 < 1 )
                var_24 = 1;

            level.player setphysicaldepthoffield( var_6.fstop, var_24, var_6.focus_speed, var_6.aperture_speed );
            var_25 = var_6.fstop * var_6.view_model_fstop_scale;

            if ( var_25 > 512 )
                var_25 = 512;

            level.player setphysicalviewmodeldepthoffield( var_25, var_24 );
            var_1 = var_6.name;
        }

        wait 0.05;
    }
}

__dyndof_bullet_trace_ignore_glass( var_0, var_1, var_2 )
{
    var_3 = 1;
    var_4 = var_0;
    var_5 = undefined;
    var_6 = level.player;

    for ( var_7 = 0; var_3 && var_7 < 10; var_7++ )
    {
        var_5 = bullettrace( var_4, var_1, 1, var_6, 0, 1, 0 );
        var_8 = distancesquared( var_4, var_1 );
        var_9 = var_5["entity"];
        var_10 = vectornormalize( var_1 - var_4 );

        if ( var_8 > 800 && var_5["surfacetype"] == "glass" )
        {
            var_4 = var_5["position"] + var_10 * 2;
            continue;
        }

        if ( isdefined( var_2 ) && isdefined( var_9 ) )
        {
            if ( common_scripts\utility::array_contains( var_2, var_9 ) )
                var_4 = var_5["position"] + var_10 * 2;
            else
                var_3 = 0;

            continue;
        }

        var_3 = 0;
    }

    return var_5;
}

__dyndof_get_higher_priority_setting( var_0 )
{
    if ( var_0.override_priority > self.override_priority )
        return var_0;

    if ( var_0.base_priority < self.base_priority )
        return var_0;

    return self;
}

dyndof_system_end()
{
    level notify( "end_dynamic_dof" );
    setsaveddvar( "r_dof_physical_bokehEnable", 0 );
    level.player_dynamic_dof_settings = undefined;
    level.player disablephysicaldepthoffieldscripting();
}

cinematic_sequence( var_0 )
{
    if ( !isdefined( level.__cinematic_sequences_container ) )
        level.__cinematic_sequences_container = [];

    if ( isdefined( var_0 ) )
    {
        if ( !isdefined( level.__cinematic_sequences_container[var_0] ) )
            level.__cinematic_sequences_container[var_0] = __cinematic_sequence_create_sequence( var_0 );

        return level.__cinematic_sequences_container[var_0];
    }

    return undefined;
}

__cinematic_sequence_create_sequence( var_0 )
{
    var_1 = spawnstruct();
    var_1.sequence_name = var_0;
    var_1.default_fov = getdvarint( "cg_fov", 65 );
    var_1.activated = 0;
    var_1.keys = [];
    return var_1;
}

cinseq_key( var_0 )
{
    if ( !isdefined( self.keys[var_0] ) )
    {
        self.keys[var_0] = __cinematic_sequence_create_key( var_0 );
        self.keys[var_0].parent_sequence = self;
    }

    return self.keys[var_0];
}

cinseq_active()
{
    return self.activated;
}

cinseq_start_sequence()
{
    if ( !self.activated )
    {
        foreach ( var_1 in self.keys )
            var_1.activated = undefined;

        self.activated = 1;
        __cinematic_sequence_run_sequence_internal();
    }
    else
    {

    }

    return self;
}

__cinematic_sequence_run_sequence_internal()
{
    var_0 = gettime();
    var_1 = gettime();
    var_2 = 0.05;

    for ( var_3 = 1; var_3; var_1 = gettime() )
    {
        var_4 = var_1 - var_0;
        var_3 = 0;

        foreach ( var_6 in self.keys )
        {
            if ( !isdefined( var_6.activated ) )
            {
                var_3 = 1;

                if ( isdefined( var_6.key_time ) && var_4 > var_6.key_time * 1000 )
                {
                    __cinseq_activate_key( var_6 );
                    var_6.activated = 1;
                }
            }
        }

        wait(var_2);
    }

    self.activated = 0;
}

__cinseq_activate_key( var_0 )
{
    if ( isdefined( var_0.function_list ) )
    {
        foreach ( var_2 in var_0.function_list )
            __cinseq_call_custom_func( var_2 );
    }

    if ( isdefined( var_0.gauss_blur_amount ) && isdefined( var_0.gauss_blur_duration ) )
        setblur( var_0.gauss_blur_amount, var_0.gauss_blur_duration );

    if ( isdefined( var_0.screen_shake_struct ) )
        __cinseq_start_screen_shake( var_0.screen_shake_struct );

    if ( isdefined( var_0.fov_value ) && isdefined( var_0.fov_lerp_duration ) )
        level.player lerpfov( var_0.fov_value, var_0.fov_lerp_duration );

    var_0 __cinseq_handle_dyndofs();

    if ( isdefined( var_0.slowmo_slow_scale ) )
        setslowmotion( gettimescale(), var_0.slowmo_slow_scale, var_0.slowmo_in_duration );
    else if ( isdefined( var_0.slowmo_out_duration ) )
        setslowmotion( gettimescale(), level.slowmo.speed_norm, var_0.slowmo_out_duration );

    if ( isdefined( self.rumble_name ) )
        self.rumble_entity playrumbleonentity( self.rumble_name );
}

__cinseq_start_screen_shake( var_0 )
{
    level.player screenshakeonentity( var_0.pitch_scale, var_0.yaw_scale, var_0.roll_scale, var_0.duration, var_0.duration_fade_up, var_0.duration_fade_down, var_0.radius, var_0.frequency_pitch, var_0.frequency_roll, var_0.frequency_yaw, var_0.exponent );
}

__cinseq_call_custom_func( var_0 )
{
    var_1 = var_0.scope_entity;

    if ( !isdefined( var_1 ) )
        var_1 = level;

    switch ( var_0.params.size )
    {
        case 0:
            var_1 thread [[ var_0.cin_function ]]();
            break;
        case 1:
            var_1 thread [[ var_0.cin_function ]]( var_0.params[0] );
            break;
        case 2:
            var_1 thread [[ var_0.cin_function ]]( var_0.params[0], var_0.params[1] );
            break;
        case 3:
            var_1 thread [[ var_0.cin_function ]]( var_0.params[0], var_0.params[1], var_0.params[3] );
            break;
        case 4:
            var_1 thread [[ var_0.cin_function ]]( var_0.params[0], var_0.params[1], var_0.params[2], var_0.params[3] );
            break;
        default:
            var_1 thread [[ var_0.cin_function ]]( var_0.params[0], var_0.params[1], var_0.params[2], var_0.params[3], var_0.params[4] );
    }
}

__cinematic_sequence_create_key( var_0 )
{
    var_1 = spawnstruct();
    var_1.name = var_0;
    var_1.start_dynamic_dof = 0;
    var_1.dyndof_use_bokeh = 0;
    var_1.end_dynamic_dof = 0;
    var_1.clear_all_dynamic_dof_settings = 0;
    return var_1;
}

cinseq_key_time( var_0 )
{
    self.key_time = var_0;
    return self;
}

cinseq_key_add_custom_func( var_0, var_1, var_2, var_3, var_4, var_5, var_6, var_7 )
{
    if ( !isdefined( self.function_list ) )
        self.function_list = [];

    var_8 = spawnstruct();
    var_8.cin_function = var_1;
    var_8.scope_entity = var_2;
    var_8.params = [];

    if ( isdefined( var_3 ) )
    {
        var_8.params[0] = var_3;

        if ( isdefined( var_4 ) )
        {
            var_8.params[1] = var_4;

            if ( isdefined( var_5 ) )
            {
                var_8.params[2] = var_5;

                if ( isdefined( var_6 ) )
                {
                    var_8.params[3] = var_6;

                    if ( isdefined( var_7 ) )
                        var_8.params[4] = var_7;
                }
            }
        }
    }

    self.function_list[var_0] = var_8;
    return self;
}

cinseq_key_gauss_blur( var_0, var_1 )
{
    self.gauss_blur_amount = var_0;
    self.gauss_blur_duration = var_1;
    return self;
}

cinseq_key_screen_shake( var_0 )
{
    self.screen_shake_struct = var_0;
    return self;
}

cinseq_create_screen_shake_struct()
{
    var_0 = spawnstruct();
    var_0.pitch_scale = 0;
    var_0.yaw_scale = 0;
    var_0.roll_scale = 0;
    var_0.duration = 0;
    var_0.duration_fade_up = 0;
    var_0.duration_fade_down = 0;
    var_0.radius = 0;
    var_0.frequency_pitch = 1;
    var_0.frequency_yaw = 1;
    var_0.frequency_roll = 1;
    var_0.exponent = 1;
    return var_0;
}

cinseq_key_lerp_fov( var_0, var_1 )
{
    if ( !isdefined( var_0 ) || !isdefined( var_1 ) )
        return self;

    self.fov_value = var_0;
    self.fov_lerp_duration = var_1;
    return self;
}

cinseq_key_lerp_fov_default( var_0 )
{
    if ( !isdefined( var_0 ) )
        return self;

    self.fov_value = self.parent_sequence.default_fov;
    self.fov_lerp_duration = var_0;
    return self;
}

cinseq_key_set_slowmo( var_0, var_1 )
{
    if ( !isdefined( var_1 ) )
        var_1 = 1;

    self.slowmo_slow_scale = var_0;
    self.slowmo_in_duration = var_1;
    return self;
}

cinseq_key_remove_slowmo( var_0 )
{
    if ( !isdefined( var_0 ) )
        var_0 = 1;

    self.slowmo_out_duration = var_0;
    return self;
}

__cinseq_handle_dyndofs()
{
    if ( self.clear_all_dynamic_dof_settings )
        dyndof_system_clear_all();

    if ( isdefined( self.remove_dyn_dof_list ) )
    {
        foreach ( var_1 in self.remove_dyn_dof_list )
            dyndof_remove( var_1 );
    }

    if ( isdefined( self.dyndof_list ) )
    {
        foreach ( var_4 in self.dyndof_list )
            __cinseq_set_dyn_dof_from_struct( var_4 );
    }

    if ( self.start_dynamic_dof )
        thread dyndof_system_start( self.dyndof_use_bokeh );

    if ( self.end_dynamic_dof )
        thread dyndof_system_end();
}

__cinseq_set_dyn_dof_from_struct( var_0 )
{
    var_1 = dyndof( var_0.name );

    if ( isdefined( var_1 ) )
    {
        if ( isdefined( var_0.fstop ) )
            var_1 dyndof_fstop( var_0.fstop );

        if ( isdefined( var_0.focus_distance ) )
            var_1 dyndof_focus_distance( var_0.focus_distance );

        if ( isdefined( var_0.focus_speed ) )
            var_1 dyndof_focus_speed( var_0.focus_speed );

        if ( isdefined( var_0.aperture_speed ) )
            var_1 dyndof_aperture_speed( var_0.aperture_speed );

        if ( isdefined( var_0.reference_entity ) )
            var_1 dyndof_reference_entity( var_0.reference_entity );

        if ( isdefined( var_0.remove_ref_ent ) && var_0.remove_ref_ent )
            var_1 dyndof_reference_entity( undefined );

        if ( isdefined( var_0.tag_name ) )
            var_1 dyndof_tag_name( var_0.tag_name );

        if ( isdefined( var_0.priority ) )
            var_1 dyndof_priority( var_0.priority );

        if ( isdefined( var_0.offset ) )
            var_1 dyndof_focus_distance_offset( var_0.offset );

        if ( isdefined( var_0.view_model_fstop_scale ) )
            var_1 dyndof_view_model_fstop_scale( var_0.view_model_fstop_scale );
    }
}

cinseq_key_create_dyndof( var_0 )
{
    __cinseq_dyndof_verify_create_setting( var_0 );
    return self;
}

cinseq_key_dyndof_values( var_0, var_1, var_2, var_3, var_4 )
{
    var_5 = __cinseq_dyndof_verify_create_setting( var_0 );
    var_5.fstop = var_1;
    var_5.focus_distance = var_2;
    var_5.focus_speed = var_3;
    var_5.aperture_speed = var_4;
    return self;
}

cinseq_key_dyndof_ref_ent( var_0, var_1, var_2 )
{
    var_3 = __cinseq_dyndof_verify_create_setting( var_0 );
    var_3.reference_entity = var_1;

    if ( !isdefined( var_2 ) )
        var_3.remove_ref_ent = 0;
    else
        var_3.remove_ref_ent = 1;

    return self;
}

cinseq_key_dyndof_tag_name( var_0, var_1 )
{
    var_2 = __cinseq_dyndof_verify_create_setting( var_0 );
    var_2.tag_name = var_1;
    return self;
}

cinseq_key_remove_dyndof( var_0 )
{
    if ( !isdefined( self.remove_dyn_dof_list ) )
        self.remove_dyn_dof_list = [];

    self.remove_dyn_dof_list = common_scripts\utility::array_add( self.remove_dyn_dof_list, var_0 );
    return self;
}

cinseq_key_start_dynamic_dof( var_0 )
{
    self.start_dynamic_dof = 1;

    if ( isdefined( var_0 ) )
        self.dyndof_use_bokeh = var_0;

    return self;
}

cinseq_key_dyndof_view_model_fstop_scale( var_0, var_1 )
{
    var_2 = __cinseq_dyndof_verify_create_setting( var_0 );
    var_2.view_model_fstop_scale = var_1;
    return self;
}

cinseq_key_end_dynamic_dof()
{
    self.end_dynamic_dof = 1;
    return self;
}

cinseq_key_clear_all_dyndofs()
{
    self.clear_all_dynamic_dof_settings = 1;
    return self;
}

cinseq_key_dyndof_priority( var_0, var_1 )
{
    var_2 = __cinseq_dyndof_verify_create_setting( var_0 );
    var_2.priority = var_1;
    return self;
}

cinseq_key_dyndof_offset( var_0, var_1 )
{
    var_2 = __cinseq_dyndof_verify_create_setting( var_0 );
    var_2.offset = var_1;
    return self;
}

cinseq_key_rumble( var_0, var_1 )
{
    if ( isdefined( var_0 ) )
    {
        if ( !isdefined( var_1 ) )
            var_1 = level.player;

        self.rumble_name = var_0;
        self.rumble_entity = var_1;
    }

    return self;
}

__cinseq_dyndof_verify_create_setting( var_0 )
{
    if ( !isdefined( self.dyndof_list ) )
        self.dyndof_list = [];

    if ( !isdefined( self.dyndof_list[var_0] ) )
    {
        self.dyndof_list[var_0] = spawnstruct();
        self.dyndof_list[var_0].name = var_0;
    }

    return self.dyndof_list[var_0];
}
