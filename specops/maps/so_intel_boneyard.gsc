main()
{
    _id_D4E2::main();
    _id_AA09::main();
    _id_CC16::main();
    maps\boneyard_anim::main();
    maps\boneyard_lighting::main();

    level.pmc_gametype = "mode_objective";
	level.pmc_enemies = 50;
	
    maps\_pmc::preLoad();
	maps\_load::main();
	maps\_pmc::main();

    maps\_compass::setupminimap("compass_map_boneyard");
}
