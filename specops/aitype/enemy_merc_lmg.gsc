// H2 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool

main()
{
    self.animtree = "";
    self.additionalassets = "";
    self.team = "axis";
    self.type = "human";
    self.subclass = "regular";
    self.accuracy = 0.2;
    self.health = 150;
    self.grenadeweapon = "fraggrenade";
    self.grenadeammo = 0;
    self.secondaryweapon = "";
    self.sidearm = "pp2000";

    if ( isai( self ) )
    {
        self setengagementmindist( 512.0, 400.0 );
        self setengagementmaxdist( 1024.0, 1250.0 );
    }

    switch ( codescripts\character::get_random_weapon( 3 ) )
    {
        case 0:
            self.weapon = "rpd";
            break;
        case 1:
            self.weapon = "rpd_reflex";
            break;
        case 2:
            self.weapon = "rpd_acog";
            break;
    }

    switch ( codescripts\character::get_random_character( 2 ) )
    {
        case 0:
            _id_CBD5::main();
            break;
        case 1:
            _id_BC45::main();
            break;
    }
}

spawner()
{
    self setspawnerteam( "axis" );
}

precache()
{
    _id_CBD5::precache();
    _id_BC45::precache();
    precacheitem( "rpd" );
    precacheitem( "rpd_reflex" );
    precacheitem( "rpd_acog" );
    precacheitem( "pp2000" );
    precacheitem( "fraggrenade" );
}
