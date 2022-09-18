main()
{
    print("balls");

    level.pmc_gametype = "mode_objective";
	level.pmc_enemies = 50;
	
    maps\_pmc::preLoad();
	maps\_load::main();
	maps\_pmc::main();

    maps\_compass::setupminimap("compass_map_boneyard");
}
