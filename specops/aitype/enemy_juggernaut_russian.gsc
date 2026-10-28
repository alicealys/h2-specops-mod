// H2 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool

main()
{
    self.animtree = "";
    self.additionalassets = "juggernaut.csv";
    self.team = "axis";
    self.type = "human";
    self.subclass = "juggernaut";
    self.accuracy = 0.2;
    self.health = 3600;
    self.grenadeweapon = "fraggrenade";
    self.grenadeammo = 0;
    self.secondaryweapon = "beretta";
    self.sidearm = "beretta";

    if ( isai( self ) )
    {
        self setengagementmindist( 0.0, 0.0 );
        self setengagementmaxdist( 256.0, 1024.0 );
    }

    switch ( codescripts\character::get_random_weapon( 3 ) )
    {
        case 0:
            self.weapon = "m240";
            break;
        case 1:
            self.weapon = "m240_reflex";
            break;
        case 2:
            self.weapon = "m240_acog";
            break;
    }

    character\character_sp_juggernaut_h2::main();
}

spawner()
{
    self setspawnerteam( "axis" );
}

precache()
{
    character\character_sp_juggernaut_h2::precache();
    precacheitem( "m240" );
    precacheitem( "m240_reflex" );
    precacheitem( "m240_acog" );
    precacheitem( "beretta" );
    precacheitem( "beretta" );
    precacheitem( "fraggrenade" );
    maps\_juggernaut::main();
}
