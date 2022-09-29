main()
{
    replacefunc(maps\_utility::musiclength, ::music_length);
    replacefunc(maps\_gameskill::should_show_cover_warning, ::ret_false);
    replacefunc(maps\_load::_id_B3AD, ::_id_B3AD);
    level.custom_gameskill_func = maps\_gameskill::solo_player_in_special_ops;
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
