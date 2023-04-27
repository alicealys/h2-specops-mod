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
    self.sidearm = "glock";

    if ( isai( self ) )
    {
        self setengagementmindist( 128.0, 0.0 );
        self setengagementmaxdist( 512.0, 768.0 );
    }

    switch ( codescripts\character::get_random_weapon( 7 ) )
    {
        case 0:
            self.weapon = "p90";
            break;
        case 1:
            self.weapon = "p90_acog";
            break;
        case 2:
            self.weapon = "p90_reflex";
            break;
        case 3:
            self.weapon = "ump45_reflex";
            break;
        case 4:
            self.weapon = "tmp";
            break;
        case 5:
            self.weapon = "ump45_acog";
            break;
        case 6:
            self.weapon = "ump45_eotech";
            break;
    }

    switch ( codescripts\character::get_random_character( 3 ) )
    {
        case 0:
            _id_C36C::main();
            break;
        case 1:
            _id_B2D3::main();
            break;
        case 2:
            _id_BCF1::main();
            break;
    }
}

spawner()
{
    self setspawnerteam( "axis" );
}

precache()
{
    _id_C36C::precache();
    _id_B2D3::precache();
    _id_BCF1::precache();
    precacheitem( "p90" );
    precacheitem( "p90_acog" );
    precacheitem( "p90_reflex" );
    precacheitem( "ump45_reflex" );
    precacheitem( "tmp" );
    precacheitem( "ump45_acog" );
    precacheitem( "ump45_eotech" );
    precacheitem( "glock" );
    precacheitem( "fraggrenade" );
}
