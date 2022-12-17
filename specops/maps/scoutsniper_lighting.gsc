// H1 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool

main()
{
    init_level_lighting_flags();
    thread setup_dof_presets();
    thread set_level_lighting_values();
    thread handle_church_explosion();
    level.default_clut = "clut_scoutsniper";
    level.default_lightset = "scoutsniper";
    level.default_visionset = "scoutsniper";
    thread handle_intro_cinematics();
    thread handle_ghillie_wibble();
}

init_level_lighting_flags()
{

}

setup_dof_presets()
{

}

set_level_lighting_values()
{
    maps\_utility::vision_set_fog_changes( "scoutsniper", 0 );
    level.player lightset2( "scoutsniper" );
    level.player _meth_849F( "clut_scoutsniper", 0.0 );
    setsaveddvar( "sm_sunShadowScale", "0.7" );
}

handle_ghillie_wibble()
{
    var_0 = 0.5;
    var_1 = 1;
    _func_2f1( 0, "x", var_0 );
    _func_2f1( 0, "y", var_1 );
}

handle_intro_cinematics()
{

}

intro_blur_pre_h1()
{
    maps\_utility::delaythread( 1, maps\_utility::set_blur, 4.8, 0.25 );
    maps\_utility::delaythread( 4, maps\_utility::set_blur, 0, 3 );
}

handle_church_explosion()
{
    for (;;)
    {
        level waittill( "church_explosion_player_screen_fx" );
        level.player shellshock( "scoutsniper_church_explo", 3 );
    }
}
