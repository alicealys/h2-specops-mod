main()
{
    maps\contingency::_id_C21D();
    var_0 = getentarray("cargo1_group2", "targetname");
    var_1 = getentarray("cargo2_group2", "targetname");
    var_2 = getentarray("cargo3_group2", "targetname");
    common_scripts\utility::array_call(var_0, ::delete);
    common_scripts\utility::array_call(var_1, ::delete);
    common_scripts\utility::array_call(var_2, ::delete);
    _id_C9A4::main();
    _id_AC17::main();
    _id_CD80::main();
    _id_C10B::main();
    maps\_load::main();
    maps\contingency_anim::_id_A902();
    //maps\contingency_lighting::main();
    maps\contingency_aud::main();

    level.player thread dialog_unsilenced_weapons();
}

dialog_unsilenced_weapons()
{
	self endon("death");
	level endon("nonsilenced_weapon_pickup");

	old_weapon_list = self getweaponslistprimaries();

	while (true)
	{
		self waittill("weapon_change");

		current_weapon_list = self getweaponslistprimaries();
		state = false;
        
		foreach (weapon in current_weapon_list) 
		{
			if (!common_scripts\utility::array_contains( old_weapon_list, weapon))
            {
				state = true;
            }
		}

		if (state)
		{
			//Be careful about picking up enemy weapons, Soap. Any un-suppressed firearms will attract a lot of attention.	
			thread maps\_utility::radio_dialogue("so_for_cont_pri_attractattn");
			break;
		}
	}

	level notify("nonsilenced_weapon_pickup");
}
