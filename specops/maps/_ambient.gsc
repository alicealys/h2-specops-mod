// H1 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool

init()
{
    level.ambient_zones = [];
    add_zone( "ac130" );
    add_zone( "alley" );
    add_zone( "bunker" );
    add_zone( "city" );
    add_zone( "container" );
    add_zone( "exterior" );
    add_zone( "exterior1" );
    add_zone( "exterior2" );
    add_zone( "exterior3" );
    add_zone( "exterior4" );
    add_zone( "exterior5" );
    add_zone( "forrest" );
    add_zone( "hangar" );
    add_zone( "interior" );
    add_zone( "interior_metal" );
    add_zone( "interior_stone" );
    add_zone( "interior_vehicle" );
    add_zone( "interior_wood" );
    add_zone( "mountains" );
    add_zone( "pipe" );
    add_zone( "shanty" );
    add_zone( "tunnel" );
    add_zone( "underpass" );

    if ( !isdefined( level.ambient_reverb ) )
        level.ambient_reverb = [];

    if ( !isdefined( level.ambient_eq ) )
        level.ambient_eq = [];

    if ( !isdefined( level.fxfireloopmod ) )
        level.fxfireloopmod = 1;

    level.eq_main_track = 0;
    level.eq_mix_track = 1;
    level.eq_track[level.eq_main_track] = "";
    level.eq_track[level.eq_mix_track] = "";
    level.ambient_modifier["interior"] = "";
    level.ambient_modifier["exterior"] = "";
    level.ambient_modifier["rain"] = "";
    maps\_equalizer::loadpresets();
}

activateambient( var_0 )
{
    level.ambient = var_0;

    if ( level.ambient == "exterior" )
        var_0 += level.ambient_modifier["exterior"];

    if ( level.ambient == "interior" )
        var_0 += level.ambient_modifier["interior"];

    ambientplay( level.ambient_track[var_0 + level.ambient_modifier["rain"]], 1 );
    thread ambienteventstart( var_0 + level.ambient_modifier["rain"] );
}

ambientvolume()
{
    for (;;)
    {
        self waittill( "trigger" );
        activateambient( "interior" );

        while ( level.player istouching( self ) )
            wait 0.1;

        activateambient( "exterior" );
    }
}

ambientdelay( var_0, var_1, var_2 )
{
    if ( !isdefined( level.ambienteventent ) )
        level.ambienteventent[var_0] = spawnstruct();
    else if ( !isdefined( level.ambienteventent[var_0] ) )
        level.ambienteventent[var_0] = spawnstruct();

    level.ambienteventent[var_0].min = var_1;
    level.ambienteventent[var_0].range = var_2 - var_1;
}

ambientevent( var_0, var_1, var_2 )
{
    if ( !isdefined( level.ambienteventent[var_0].event_alias ) )
        var_3 = 0;
    else
        var_3 = level.ambienteventent[var_0].event_alias.size;

    level.ambienteventent[var_0].event_alias[var_3] = var_1;
    level.ambienteventent[var_0].event_weight[var_3] = var_2;
}

ambientreverb( var_0 )
{
    level.player setreverb( level.ambient_reverb[var_0]["priority"], level.ambient_reverb[var_0]["roomtype"], level.ambient_reverb[var_0]["drylevel"], level.ambient_reverb[var_0]["wetlevel"], level.ambient_reverb[var_0]["fadetime"] );
    level waittill( "new ambient event track" );
    level.player deactivatereverb( level.ambient_reverb[var_0]["priority"], 2 );
}

setupeq( var_0, var_1, var_2 )
{
    if ( !isdefined( level.ambient_eq[var_0] ) )
        level.ambient_eq[var_0] = [];

    level.ambient_eq[var_0][var_1] = var_2;
}

setup_eq_channels( var_0, var_1 )
{
    level.eq_track[var_1] = "exterior";

    if ( !isdefined( level.ambient_eq ) || !isdefined( level.ambient_eq[var_0] ) )
    {
        deactivate_index( var_1 );
        return;
    }

    level.eq_track[var_1] = var_0;
    var_2 = getarraykeys( level.ambient_eq[var_0] );

    for ( var_3 = 0; var_3 < var_2.size; var_3++ )
    {
        var_4 = var_2[var_3];
        var_5 = maps\_equalizer::getfilter( level.ambient_eq[var_0][var_4] );

        if ( !isdefined( var_5 ) )
            continue;

        for ( var_6 = 0; var_6 < 3; var_6++ )
        {
            if ( isdefined( var_5["type"][var_6] ) )
            {
                level.player seteq( var_4, var_1, var_6, var_5["type"][var_6], var_5["gain"][var_6], var_5["freq"][var_6], var_5["q"][var_6] );
                continue;
            }

            level.player deactivateeq( var_1, var_4, var_6 );
        }
    }
}

deactivate_index( var_0 )
{
    level.player deactivateeq( var_0 );
}

ambienteventstart( var_0 )
{
    set_ambience_single( var_0 );
}

start_ambient_event( var_0 )
{
    level notify( "new ambient event track" );
    level endon( "new ambient event track" );

    if ( !isdefined( level.player.soundent ) )
    {
        level.player.soundent = spawn( "script_origin", ( 0.0, 0.0, 0.0 ) );
        level.player.soundent.playingsound = 0;
    }
    else if ( level.player.soundent.playingsound )
        level.player.soundent waittill( "sounddone" );

    var_1 = level.player.soundent;
    var_2 = level.ambienteventent[var_0].min;
    var_3 = level.ambienteventent[var_0].range;
    var_4 = 0;
    var_5 = 0;

    if ( isdefined( level.ambient_reverb[var_0] ) )
        thread ambientreverb( var_0 );

    for (;;)
    {
        wait(var_2 + randomfloat( var_3 ));

        while ( var_5 == var_4 )
            var_5 = ambientweight( var_0 );

        var_4 = var_5;
        var_1.origin = level.player.origin;
        var_1 linkto( level.player );
        var_1 playsound( level.ambienteventent[var_0].event_alias[var_5], "sounddone" );
        var_1.playingsound = 1;
        var_1 waittill( "sounddone" );
        var_1.playingsound = 0;
    }
}

ambientweight( var_0 )
{
    var_1 = level.ambienteventent[var_0].event_alias.size;
    var_2 = randomint( var_1 );

    if ( var_1 > 1 )
    {
        var_3 = 0;
        var_4 = 0;

        for ( var_5 = 0; var_5 < var_1; var_5++ )
        {
            var_3++;
            var_4 += level.ambienteventent[var_0].event_weight[var_5];
        }

        if ( var_3 == var_1 )
        {
            var_6 = randomfloat( var_4 );
            var_4 = 0;

            for ( var_5 = 0; var_5 < var_1; var_5++ )
            {
                var_4 += level.ambienteventent[var_0].event_weight[var_5];

                if ( var_6 < var_4 )
                {
                    var_2 = var_5;
                    break;
                }
            }
        }
    }

    return var_2;
}

add_zone( var_0 )
{
    level.ambient_zones[var_0] = 1;
}

check_ambience( var_0 )
{

}

ambient_trigger()
{
    var_0 = strtok( self.ambient, " " );

    if ( var_0.size == 1 )
    {
        var_1 = var_0[0];

        for (;;)
        {
            self waittill( "trigger", var_2 );
            set_ambience_single( var_1 );
        }
    }

    var_3 = getent( self.target, "targetname" );
    var_4 = var_3.origin;
    var_5 = undefined;

    if ( isdefined( var_3.target ) )
    {
        var_6 = getent( var_3.target, "targetname" );
        var_5 = var_6.origin;
    }
    else
        var_5 = var_4;

    var_7 = distance( var_4, var_5 );
    var_8 = var_0[0];
    var_9 = var_0[1];
    var_10 = 0.5;

    if ( isdefined( self.targetname ) && self.targetname == "ambient_exit" )
        var_10 = 0;

    for (;;)
    {
        self waittill( "trigger", var_2 );
        var_11 = undefined;

        while ( level.player istouching( self ) )
        {
            var_11 = maps\_utility::get_progress( var_4, var_5, level.player.origin, var_7 );

            if ( var_11 < 0 )
                var_11 = 0;

            if ( var_11 > 1 )
                var_11 = 1;

            set_ambience_blend( var_11, var_8, var_9 );
            wait 0.05;
        }

        if ( var_11 > var_10 )
            var_11 = 1;
        else
            var_11 = 0;

        set_ambience_blend( var_11, var_8, var_9 );
    }
}

ambient_end_trigger_think( var_0, var_1, var_2, var_3, var_4 )
{
    self endon( "death" );

    for (;;)
    {
        self waittill( "trigger", var_5 );
        ambient_trigger_sets_ambience_levels( var_0, var_1, var_2, var_3, var_4 );
    }
}

ambient_trigger_sets_ambience_levels( var_0, var_1, var_2, var_3, var_4 )
{
    level notify( "trigger_ambience_touched" );
    level endon( "trigger_ambience_touched" );

    for (;;)
    {
        var_5 = maps\_utility::get_progress( var_0, var_1, level.player.origin, var_2 );

        if ( var_5 < 0 )
        {
            var_5 = 0;
            set_ambience_single( var_3 );
            break;
        }

        if ( var_5 >= 1 )
        {
            set_ambience_single( var_4 );
            break;
        }

        set_ambience_blend( var_5, var_3, var_4 );
        wait 0.05;
    }
}

set_ambience_blend( var_0, var_1, var_2 )
{
    if ( level.eq_track[level.eq_main_track] != var_2 )
        setup_eq_channels( var_2, level.eq_main_track );

    if ( level.eq_track[level.eq_mix_track] != var_1 )
        setup_eq_channels( var_1, level.eq_mix_track );

    level.player seteqlerp( var_0, level.eq_main_track );

    if ( var_0 == 1 || var_0 == 0 )
        level.nextmsg = 0;

    if ( !isdefined( level.nextmsg ) )
        level.nextmsg = 0;

    if ( gettime() < level.nextmsg )
        return;

    level.nextmsg = gettime() + 200;
}

set_ambience_single( var_0 )
{
    if ( isdefined( level.ambienteventent[var_0] ) )
        thread start_ambient_event( var_0 );

    if ( level.eq_track[level.eq_main_track] != var_0 )
        setup_eq_channels( var_0, level.eq_main_track );

    level.player seteqlerp( 1, level.eq_main_track );
}

ambience_hud( var_0, var_1, var_2 )
{
    if ( getdvar( "loc_warnings" ) == "1" )
        return;

    if ( getdvar( "debug_hud" ) != "" )
        return;

    if ( !isdefined( level.amb_hud ) )
    {
        var_3 = -40;
        var_4 = 460;
        level.amb_hud = [];
        var_5 = newhudelem();
        var_5.alignx = "left";
        var_5.aligny = "bottom";
        var_5.x = var_3 + 22;
        var_5.y = var_4 + 10;
        var_5.color = ( 0.4, 0.9, 0.6 );
        level.amb_hud["inner"] = var_5;
        var_5 = newhudelem();
        var_5.alignx = "left";
        var_5.aligny = "bottom";
        var_5.x = var_3;
        var_5.y = var_4 + 10;
        var_5.color = ( 0.4, 0.9, 0.6 );
        level.amb_hud["frac_inner"] = var_5;
        var_5 = newhudelem();
        var_5.alignx = "left";
        var_5.aligny = "bottom";
        var_5.x = var_3 + 22;
        var_5.y = var_4;
        var_5.color = ( 0.4, 0.9, 0.6 );
        level.amb_hud["outer"] = var_5;
        var_5 = newhudelem();
        var_5.alignx = "left";
        var_5.aligny = "bottom";
        var_5.x = var_3;
        var_5.y = var_4;
        var_5.color = ( 0.4, 0.9, 0.6 );
        level.amb_hud["frac_outer"] = var_5;
    }

    if ( isdefined( var_2 ) )
    {
        level.amb_hud["frac_outer"].label = int( 100 * ( 1 - var_0 ) );
        level.amb_hud["frac_outer"].alpha = 1;
        level.amb_hud["outer"].label = var_2;
        level.amb_hud["outer"].alpha = 1;
    }
    else
    {
        level.amb_hud["outer"].alpha = 0;
        level.amb_hud["frac_outer"].alpha = 0;
    }

    level.amb_hud["outer"] fadeovertime( 0.5 );
    level.amb_hud["frac_outer"] fadeovertime( 0.5 );
    level.amb_hud["frac_inner"].label = int( 100 * var_0 );
    level.amb_hud["frac_inner"].alpha = 1;
    level.amb_hud["frac_inner"] fadeovertime( 0.5 );
    level.amb_hud["inner"] settext( var_1 );
    level.amb_hud["inner"].alpha = 1;
    level.amb_hud["inner"] fadeovertime( 0.5 );
}

set_ambience_blend_over_time( var_0, var_1, var_2 )
{
    if ( var_0 == 0 )
    {
        set_ambience_blend( 1, var_1, var_2 );
        return;
    }

    var_3 = 0;
    var_4 = 0.05;
    var_5 = 1 / ( var_0 / var_4 );

    for (;;)
    {
        var_3 += var_5;

        if ( var_3 >= 1 )
        {
            set_ambience_single( var_2 );
            break;
        }

        set_ambience_blend( var_3, var_1, var_2 );
        wait(var_4);
    }
}
