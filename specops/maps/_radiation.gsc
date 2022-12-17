// H1 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool

main()
{
    precachestring( &"SCOUTSNIPER_MRHR" );
    precachestring( &"SCRIPT_RADIATION_DEATH" );
    precacheshellshock( "radiation_low" );
    precacheshellshock( "radiation_med" );
    precacheshellshock( "radiation_high" );

    foreach ( var_2, var_1 in level.players )
    {
        var_1.radiation = spawnstruct();
        var_1.radiation.super_dose = 0;
        var_1.radiation.inside = 0;
        var_1 maps\_utility::ent_flag_init( "_radiation_poisoning" );
    }

    common_scripts\utility::run_thread_on_targetname( "radiation", ::updateradiationtriggers );
    common_scripts\utility::run_thread_on_targetname( "super_radiation", ::super_radiation_trigger );
    common_scripts\utility::array_thread( level.players, ::updateradiationdosage );
    common_scripts\utility::array_thread( level.players, ::updateradiationdosimeter );
    common_scripts\utility::array_thread( level.players, ::updateradiationshock );
    common_scripts\utility::array_thread( level.players, ::updateradiationblackout );
    common_scripts\utility::array_thread( level.players, ::updateradiationsound );
    common_scripts\utility::array_thread( level.players, ::updateradiationflag );
    common_scripts\utility::array_thread( level.players, ::first_radiation_dialogue );
}

updateradiationtriggers()
{
    self.members = 0;

    for (;;)
    {
        self waittill( "trigger", var_0 );
        thread updateradiationtrigger_perplayer( var_0 );
    }
}

updateradiationtrigger_perplayer( var_0 )
{
    if ( var_0.radiation.inside )
        return;

    var_0.radiation.inside = 1;
    var_0.radiation.triggers[var_0.radiation.triggers.size] = self;

    while ( var_0 istouching( self ) )
        wait 0.05;

    var_0.radiation.inside = 0;
    var_0.radiation.triggers = common_scripts\utility::array_remove( var_0.radiation.triggers, self );
}

super_radiation_trigger()
{
    self waittill( "trigger", var_0 );
    var_0.radiation.super_dose = 1;
}

updateradiationdosage()
{
    self.radiation.triggers = [];
    self.radiation.rate = 0;
    self.radiation.ratepercent = 0;
    self.radiation.total = 0;
    self.radiation.totalpercent = 0;
    var_0 = 1;
    var_1 = 0;
    var_2 = 1100000 / 60 * var_0;
    var_3 = 200000;
    var_4 = var_2 - var_1;

    for (;;)
    {
        var_5 = [];

        for ( var_6 = 0; var_6 < self.radiation.triggers.size; var_6++ )
        {
            var_7 = self.radiation.triggers[var_6];
            var_8 = distance( self.origin, var_7.origin ) - 15;
            var_5[var_6] = var_2 - var_2 / var_7.radius * var_8;
        }

        var_9 = 0;

        for ( var_6 = 0; var_6 < var_5.size; var_6++ )
            var_9 += var_5[var_6];

        if ( var_9 < var_1 )
            var_9 = var_1;

        if ( var_9 > var_2 )
            var_9 = var_2;

        self.radiation.rate = var_9;
        self.radiation.ratepercent = ( var_9 - var_1 ) / var_4 * 100;

        if ( self.radiation.super_dose )
        {
            var_9 = var_2;
            self.radiation.ratepercent = 100;
        }

        if ( self.radiation.ratepercent > 25 )
        {
            self.radiation.total += var_9;
            self.radiation.totalpercent = self.radiation.total / var_3 * 100;
        }
        else if ( self.radiation.ratepercent < 1 && self.radiation.total > 0 )
        {
            self.radiation.total -= 1500;

            if ( self.radiation.total < 0 )
                self.radiation.total = 0;

            self.radiation.totalpercent = self.radiation.total / var_3 * 100;
        }

        wait(var_0);
    }
}

updateradiationshock()
{
    var_0 = 1;

    for (;;)
    {
        if ( self.radiation.ratepercent >= 75 )
        {
            self shellshock( "radiation_high", 5 );
            soundscripts\_snd::snd_message( "aud_radiation_shellshock", "radiation_high" );
        }
        else if ( self.radiation.ratepercent >= 50 )
        {
            self shellshock( "radiation_med", 5 );
            soundscripts\_snd::snd_message( "aud_radiation_shellshock", "radiation_med" );
        }
        else if ( self.radiation.ratepercent > 25 )
        {
            self shellshock( "radiation_low", 5 );
            soundscripts\_snd::snd_message( "aud_radiation_shellshock", "radiation_low" );
        }
        else if ( self.radiation.ratepercent <= 25 && self.radiation.ratepercent > 0 )
            soundscripts\_snd::snd_message( "aud_radiation_shellshock", "radiation_none" );

        wait(var_0);
    }
}

updateradiationsound()
{
    thread playradiationsound();

    for (;;)
    {
        if ( self.radiation.ratepercent >= 75 )
            self.radiation.sound = "item_geigercouner_level4";
        else if ( self.radiation.ratepercent >= 50 )
            self.radiation.sound = "item_geigercouner_level3";
        else if ( self.radiation.ratepercent >= 25 )
            self.radiation.sound = "item_geigercouner_level2";
        else if ( self.radiation.ratepercent > 0 )
            self.radiation.sound = "item_geigercouner_level1";
        else
            self.radiation.sound = "none";

        wait 0.05;
    }
}

updateradiationflag()
{
    for (;;)
    {
        if ( self.radiation.ratepercent > 25 )
            maps\_utility::ent_flag_set( "_radiation_poisoning" );
        else
            maps\_utility::ent_flag_clear( "_radiation_poisoning" );

        wait 0.05;
    }
}

playradiationsound()
{
    wait 0.05;
    var_0 = spawn( "script_origin", ( 0.0, 0.0, 0.0 ) );
    var_0.origin = self.origin;
    var_0.angles = self.angles;
    var_0 linkto( self );
    var_1 = self.radiation.sound;

    for (;;)
    {
        if ( var_1 != self.radiation.sound )
        {
            var_0 stopsounds();

            if ( isdefined( self.radiation.sound ) && self.radiation.sound != "none" )
                var_0 playloopsound( self.radiation.sound );
        }

        var_1 = self.radiation.sound;
        wait 0.05;
    }
}

updateradiationratepercent()
{
    var_0 = 0.05;
    var_1 = newclienthudelem( self );
    var_1.fontscale = 1.2;
    var_1.x = 670;
    var_1.y = 350;
    var_1.alignx = "right";
    var_1.label = "";
    var_1.alpha = 0;

    for (;;)
    {
        var_1.label = self.radiation.ratepercent;
        wait(var_0);
    }
}

updateradiationdosimeter()
{
    var_0 = 0.028;
    var_1 = 100;
    var_2 = 1;
    var_3 = var_1 - var_0;
    var_4 = self.origin;
    var_5 = newclienthudelem( self );
    var_5.fontscale = 1.2;
    var_5.x = 676;
    var_5.y = 360;
    var_5.alpha = 0;
    var_5.alignx = "right";
    var_5.label = &"SCOUTSNIPER_MRHR";
    var_5 thread updateradiationdosimetercolor( self );

    for (;;)
    {
        if ( self.radiation.rate <= var_0 )
        {
            var_6 = randomfloatrange( -0.001, 0.001 );
            var_5 setvalue( var_0 + var_6 );
        }
        else if ( self.radiation.rate > var_1 )
            var_5 setvalue( var_1 );
        else
            var_5 setvalue( self.radiation.rate );

        wait(var_2);
    }
}

updateradiationdosimetercolor( var_0 )
{
    var_1 = 0.05;

    for (;;)
    {
        var_2 = 1;
        var_3 = 0.13;

        while ( var_0.radiation.rate >= 100 )
        {
            if ( var_2 <= 0 || var_2 >= 1 )
                var_3 *= -1;

            var_2 += var_3;

            if ( var_2 <= 0 )
                var_2 = 0;

            if ( var_2 >= 1 )
                var_2 = 1;

            self.color = ( 1, var_2, var_2 );
            wait(var_1);
        }

        self.color = ( 1.0, 1.0, 1.0 );
        wait(var_1);
    }
}

updateradiationblackout()
{
    level endon( "special_op_terminated" );
    self endon( "death" );
    var_0 = newclienthudelem( self );
    var_0.x = 0;
    var_0.y = 0;
    var_0 setshader( "black", 640, 480 );
    var_0.alignx = "left";
    var_0.aligny = "top";
    var_0.horzalign = "fullscreen";
    var_0.vertalign = "fullscreen";
    var_0.alpha = 0;
    var_1 = 1;
    var_2 = 4;
    var_3 = 0.25;
    var_4 = 1;
    var_5 = 25;
    var_6 = 100;
    var_7 = 0;

    for (;;)
    {
        while ( self.radiation.totalpercent > 25 && self.radiation.ratepercent > 25 )
        {
            var_8 = var_6 - var_5;
            var_7 = ( self.radiation.totalpercent - var_5 ) / var_8;

            if ( var_7 < 0 )
                var_7 = 0;
            else if ( var_7 > 1 )
                var_7 = 1;

            var_9 = var_2 - var_1;
            var_10 = var_1 + var_9 * ( 1 - var_7 );
            var_11 = var_4 - var_3;
            var_12 = var_3 + var_11 * var_7;
            var_13 = 7.2 * var_12;
            var_14 = var_7 * 0.5;
            var_15 = 7.2 * var_14;

            if ( var_7 == 1 )
                break;

            var_16 = var_10 / 2;
            var_0 fadeinblackout( var_16, var_12, var_13, self );
            var_0 fadeoutblackout( var_16, var_14, var_15, self );
            wait(var_7 * 0.5);
        }

        if ( var_7 == 1 )
            break;

        if ( var_0.alpha != 0 )
            var_0 fadeoutblackout( 1, 0, 0, self );

        wait 0.05;
    }

    var_0 fadeinblackout( 2, 1, 6, self );
    thread radiation_kill();
}

radiation_kill()
{
    self.specialdamage = 1;
    self.specialdeath = 1;
    self.radiationdeath = 1;

    if ( !maps\_utility::kill_wrapper() )
        return;

    waittillframeend;
    var_0 = &"SCRIPT_RADIATION_DEATH";
    setdvar( "ui_deadquote", var_0 );
}

fadeinblackout( var_0, var_1, var_2, var_3 )
{
    self fadeovertime( var_0 );
    self.alpha = var_1;
    var_3 setblurforplayer( var_2, var_0 );
    wait(var_0);
}

fadeoutblackout( var_0, var_1, var_2, var_3 )
{
    self fadeovertime( var_0 );
    self.alpha = var_1;
    var_3 setblurforplayer( var_2, var_0 );
    wait(var_0);
}

first_radiation_dialogue()
{
    self endon( "death" );

    for (;;)
    {
        maps\_utility::ent_flag_wait( "_radiation_poisoning" );

        if ( level.script == "scoutsniper" || level.script == "co_scoutsniper" )
            level thread maps\_utility::function_stack( maps\_utility::radio_dialogue, "scoutsniper_mcm_youdaft" );

        level notify( "radiation_warning" );
        maps\_utility::ent_flag_waitopen( "_radiation_poisoning" );
        wait 10;
    }
}
