main()
{
    replacefunc(maps\_utility::musiclength, ::music_length);
    replacefunc(maps\_gameskill::should_show_cover_warning, ::ret_false);
    level.custom_gameskill_func = maps\_gameskill::solo_player_in_special_ops;
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
