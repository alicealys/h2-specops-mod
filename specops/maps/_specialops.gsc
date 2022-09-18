enable_challenge_timer(start, end)
{
    if (isdefined(level.lua["enable_challenge_timer"]))
    {
        func = level.lua["enable_challenge_timer"];
        [[ func ]](start, end);
    }
}

so_dialog_counter_update(current, goal, divide)
{
    if (isdefined(level.lua["so_dialog_counter_update"]))
    {
        func = level.lua["so_dialog_counter_update"];
        [[ func ]](current, goal, divide);
    }
}

so_create_hud_item(line, xoffset, message, alwaysdraw)
{
    if (isdefined(level.lua["so_create_hud_item"]))
    {
        func = level.lua["so_create_hud_item"];
        [[ func ]](line, xoffset, message, alwaysdraw);
        return level.luaret;
    }

    return newhudelem();
}

so_hud_ypos()
{
    return -135;
}

so_hud_pulse_success()
{
    if (isdefined(level.lua["so_hud_pulse_success"]))
    {
        func = level.lua["so_hud_pulse_success"];
        self [[ func ]]();
    }
}

so_hud_pulse_close()
{
    if (isdefined(level.lua["so_hud_pulse_close"]))
    {
        func = level.lua["so_hud_pulse_close"];
        self [[ func ]]();
    }
}

so_remove_hud_item()
{
    self destroy();
}

fade_challenge_in()
{

}

fade_challenge_out(name)
{

}
