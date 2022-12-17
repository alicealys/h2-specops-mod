// H1 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool

main()
{
    setsaveddvar( "r_lodFOVScaleOverride", 1 );
    setsaveddvar( "r_lodFOVScaleOverrideAmount", 0.75 );
    setsaveddvar( "r_lodFOVScaleOverrideStopMaxAngle", 5 );
    setsaveddvar( "r_lodFOVScaleOverrideStopMinAngle", 0.0 );

    precachemodel("viewmodel_base_viewhands");
    precacheitem("mp5");

    maps\scoutsniper_precache::main();
    maps\createart\scoutsniper_fog_hdr::main();
    maps\scoutsniper_fx::main();

    maps\_load::main();

    maps\scoutsniper_anim::main();
    thread maps\scoutsniper_amb::main();
    common_scripts\utility::flag_init( "intro" );
    maps\scoutsniper_lighting::main();

    print("here");
}
