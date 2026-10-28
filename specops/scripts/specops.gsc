#include animscripts\battlechatter;

main()
{
    replacefunc(maps\_utility::musiclength, ::music_length);
    replacefunc(maps\_gameskill::should_show_cover_warning, ::ret_false);
    replacefunc(animscripts\battlechatter::playbattlechatter, ::playbattlechatter);
    replacefunc(maps\_load::_id_B3AD, ::_id_B3AD);
    level.custom_gameskill_func = maps\_gameskill::solo_player_in_special_ops;
    common_scripts\utility::array_thread(getentarray("intelligence_item", "targetname"), ::delete_intel);
}

delete_intel()
{
    getent(self.target, "targetname") delete();
    self delete();
}

playbattlechatter()
{
    if ( !isalive( self ) )
        return;

    if ( !bcsenabled() )
        return;

    //if ( _func_1FB() )
        //return;

    if ( self._animactive > 0 )
        return;

    if ( isdefined( self.isspeaking ) && self.isspeaking )
        return;

    if ( self.team == "allies" && isdefined( anim.scripteddialoguestarttime ) )
    {
        if ( anim.scripteddialoguestarttime + anim.scripteddialoguebuffertime > gettime() )
            return;
    }

    if ( friendlyfire_warning() )
        return;

    if ( !isdefined( self.battlechatter ) || !self.battlechatter )
        return;

    if ( self.team == "allies" && getdvarint( "bcs_forceEnglish", 0 ) )
        return;

    if ( anim.isteamspeaking[self.team] )
        return;

    self endon( "death" );
    var_0 = gethighestpriorityevent();

    if ( !isdefined( var_0 ) )
        return;

    switch ( var_0 )
    {
        case "custom":
            thread playcustomevent();
            break;
        case "response":
            thread playresponseevent();
            break;
        case "order":
            thread playorderevent();
            break;
        case "threat":
            thread playthreatevent();
            break;
        case "reaction":
            thread playreactionevent();
            break;
        case "inform":
            thread playinformevent();
            break;
    }
}

_id_B3AD()
{
    ents = getentarray();

    if (!isdefined(ents))
    {
        return;
    }

    foreach (ent in ents)
    {
        if (ent maps\_load::_id_B92E(true))
        {
            ent delete();
        }
    }

    maps\_load::_id_B29C();
}

ret_false()
{
    return false;
}

music_length(name)
{
    value = tablelookup("mp/sound/soundlength.csv", 0, name, 1);

    if (!isdefined(value) || value == "")
    {
        value = getsoundlength(name);
        if (value == -1)
        {
            return -1;
        }
    }

    value = int(value);
    value *= 0.001;
    return value;
}
