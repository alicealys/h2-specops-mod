// H1 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool

main()
{
    var_0 = getentarray( "leaking", "targetname" );

    if ( !var_0.size )
        return;

    var_0 thread precachefx();
    var_0 thread methodsinit();
    common_scripts\utility::array_thread( var_0, ::leak_setup );
}

leak_setup()
{
    switch ( self.script_noteworthy )
    {
        case "barrel_oil":
            leak_barrel_setup();
            break;
        case "barrel_acid":
            leak_barrel_setup();
            break;
        case "barrel_sludge":
            leak_barrel_setup();
            break;
        case "barrel_water":
            leak_barrel_setup();
            break;
    }

    thread leak_think();
}

leak_barrel_setup()
{
    self.a = self.origin;
    self.up = anglestoup( self.angles );
    var_0 = anglestoup( ( 0.0, 90.0, 0.0 ) );
    self.org = self.a + self.up * 22;
    self.a += self.up * 1.5;
    self.b = self.a + self.up * 41.4;
    self.volume = 25861.7;
    self.curvol = self.volume;
    var_1 = vectordot( self.up, var_0 );
    var_2 = self.b;

    if ( var_1 < 0 )
        var_2 = self.a;

    var_1 = abs( 1 - abs( var_1 ) );
    self.lowz = physicstrace( self.org, self.org + ( 0.0, 0.0, -80.0 ) )[2];
    self.highz = var_2[2] + var_1 * 14;
}

leak_think()
{
    self setcandamage( 1 );
    self.canspawnpool = isdefined( level._effect["leak_interactive_pool"] ) && isdefined( level._effect["leak_interactive_pool"][self.script_noteworthy] );
    self endon( "drained" );

    for (;;)
    {
        self waittill( "damage", var_0, var_1, var_2, var_3, var_4 );

        if ( var_4 == "MOD_MELEE" || var_4 == "MOD_IMPACT" )
            continue;

        var_3 = self [[ level._leak_methods[var_4] ]]( var_3, var_4 );

        if ( !isdefined( var_3 ) )
            continue;

        thread leak_drain( var_3 );
    }
}

leak_drain( var_0 )
{
    var_1 = pointonsegmentnearesttopoint( self.a, self.b, var_0 );
    var_2 = undefined;

    if ( var_1 == self.a )
        var_2 = self.up * -1;
    else if ( var_1 == self.b )
        var_2 = self.up;
    else
        var_2 = vectorfromlinetopoint( self.a, self.b, var_0 );

    var_3 = var_0[2] - self.lowz;

    if ( var_3 < 0.02 )
        var_3 = 0;

    var_4 = var_3 / ( self.highz - self.lowz ) * self.volume;

    if ( self.curvol > var_4 )
    {
        if ( self.canspawnpool )
            thread leak_pool( var_0, var_2 );

        thread common_scripts\utility::play_sound_in_space( level._sound["leak_interactive_leak"][self.script_noteworthy], var_0 );

        while ( self.curvol > var_4 )
        {
            playfx( level._effect["leak_interactive_leak"][self.script_noteworthy], var_0, var_2 );
            self.curvol -= 100;
            wait 0.1;
        }

        playfx( level._effect["leak_interactive_drain"][self.script_noteworthy], var_0, var_2 );
    }

    if ( self.curvol / self.volume <= 0.05 )
        self notify( "drained" );
}

leak_pool( var_0, var_1 )
{
    self.canspawnpool = 0;
    playfx( level._effect["leak_interactive_pool"][self.script_noteworthy], var_0, var_1 );
    wait 0.5;
    self.canspawnpool = 1;
}

methodsinit()
{
    level._leak_methods = [];
    level._leak_methods["MOD_UNKNOWN"] = ::leak_calc_splash;
    level._leak_methods["MOD_PISTOL_BULLET"] = ::leak_calc_ballistic;
    level._leak_methods["MOD_RIFLE_BULLET"] = ::leak_calc_ballistic;
    level._leak_methods["MOD_GRENADE"] = ::leak_calc_splash;
    level._leak_methods["MOD_GRENADE_SPLASH"] = ::leak_calc_splash;
    level._leak_methods["MOD_PROJECTILE"] = ::leak_calc_splash;
    level._leak_methods["MOD_PROJECTILE_SPLASH"] = ::leak_calc_splash;
    level._leak_methods["MOD_MELEE"] = ::leak_calc_nofx;
    level._leak_methods["MOD_HEAD_SHOT"] = ::leak_calc_nofx;
    level._leak_methods["MOD_CRUSH"] = ::leak_calc_nofx;
    level._leak_methods["MOD_TELEFRAG"] = ::leak_calc_nofx;
    level._leak_methods["MOD_FALLING"] = ::leak_calc_nofx;
    level._leak_methods["MOD_SUICIDE"] = ::leak_calc_nofx;
    level._leak_methods["MOD_TRIGGER_HURT"] = ::leak_calc_splash;
    level._leak_methods["MOD_EXPLOSIVE"] = ::leak_calc_splash;
    level._leak_methods["MOD_IMPACT"] = ::leak_calc_nofx;
    level._leak_methods["MOD_EXPLOSIVE_BULLET"] = ::leak_calc_ballistic;
}

leak_calc_ballistic( var_0, var_1 )
{
    return var_0;
}

leak_calc_splash( var_0, var_1 )
{
    var_2 = vectornormalize( vectorfromlinetopoint( self.a, self.b, var_0 ) );
    var_0 = pointonsegmentnearesttopoint( self.a, self.b, var_0 );
    return var_0 + var_2 * 4;
}

leak_calc_nofx( var_0, var_1 )
{
    return undefined;
}

leak_calc_assert( var_0, var_1 )
{

}

precachefx()
{
    for ( var_0 = 0; var_0 < self.size; var_0++ )
    {
        if ( self[var_0].script_noteworthy != "barrel_oil" )
            continue;

        level._effect["leak_interactive_leak"][self[var_0].script_noteworthy] = loadfx( "fx/impacts/barrel_leak" );
        level._effect["leak_interactive_pool"][self[var_0].script_noteworthy] = loadfx( "fx/misc/oilsplash_decal_spawner" );
        level._effect["leak_interactive_drain"][self[var_0].script_noteworthy] = loadfx( "fx/impacts/barrel_drain" );
        level._sound["leak_interactive_leak"][self[var_0].script_noteworthy] = "h1_oil_spill_start";
        break;
    }

    for ( var_0 = 0; var_0 < self.size; var_0++ )
    {
        if ( self[var_0].script_noteworthy != "barrel_acid" )
            continue;

        level._effect["leak_interactive_leak"][self[var_0].script_noteworthy] = loadfx( "fx/impacts/barrel_leak" );
        level._effect["leak_interactive_pool"][self[var_0].script_noteworthy] = loadfx( "fx/misc/oilsplash_decal_spawner" );
        level._effect["leak_interactive_drain"][self[var_0].script_noteworthy] = loadfx( "fx/impacts/barrel_drain" );
        level._sound["leak_interactive_leak"][self[var_0].script_noteworthy] = "h1_oil_spill_start";
        break;
    }

    for ( var_0 = 0; var_0 < self.size; var_0++ )
    {
        if ( self[var_0].script_noteworthy != "barrel_water" )
            continue;

        level._effect["leak_interactive_leak"][self[var_0].script_noteworthy] = loadfx( "fx/impacts/barrel_leak" );
        level._effect["leak_interactive_pool"][self[var_0].script_noteworthy] = loadfx( "fx/misc/oilsplash_decal_spawner" );
        level._effect["leak_interactive_drain"][self[var_0].script_noteworthy] = loadfx( "fx/impacts/barrel_drain" );
        level._sound["leak_interactive_leak"][self[var_0].script_noteworthy] = "h1_oil_spill_start";
        break;
    }

    for ( var_0 = 0; var_0 < self.size; var_0++ )
    {
        if ( self[var_0].script_noteworthy != "barrel_sludge" )
            continue;

        level._effect["leak_interactive_leak"][self[var_0].script_noteworthy] = loadfx( "fx/impacts/barrel_leak" );
        level._effect["leak_interactive_pool"][self[var_0].script_noteworthy] = loadfx( "fx/misc/oilsplash_decal_spawner" );
        level._effect["leak_interactive_drain"][self[var_0].script_noteworthy] = loadfx( "fx/impacts/barrel_drain" );
        level._sound["leak_interactive_leak"][self[var_0].script_noteworthy] = "h1_oil_spill_start";
        break;
    }
}
