enable_challenge_timer(start, end, time_limit, silent)
{
    if (isdefined(level.lua["enable_challenge_timer"]))
    {
        func = level.lua["enable_challenge_timer"];
        [[ func ]](start, end, time_limit, silent);
    }
}

enable_escape_warning()
{
    if (isdefined(level.lua["enable_escape_warning"]))
    {
        func = level.lua["enable_escape_warning"];
        [[ func ]]();
    }
}

enable_escape_failure(start, end)
{
    if (isdefined(level.lua["enable_escape_failure"]))
    {
        func = level.lua["enable_escape_failure"];
        [[ func ]]();
    }
}

enable_triggered_start(challenge_id, challenge_id_complete)
{
    if (isdefined(level.lua["enable_triggered_start"]))
    {
        func = level.lua["enable_triggered_start"];
        [[ func ]](challenge_id, challenge_id_complete);
    }
}

enable_triggered_complete(challenge_id, challenge_id_complete)
{
    if (isdefined(level.lua["enable_triggered_complete"]))
    {
        func = level.lua["enable_triggered_complete"];
        [[ func ]](challenge_id, challenge_id_complete);
    }
}

add_challenge_timer(time_limit)
{
    if (isdefined(level.lua["add_challenge_timer"]))
    {
        func = level.lua["add_challenge_timer"];
        [[ func ]](time_limit);
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

enable_countdown_timer(timewait, setstarttime, message, timerdrawdelay)
{
    if (isdefined(level.lua["enable_countdown_timer"]))
    {
        func = level.lua["enable_countdown_timer"];
        [[ func ]](timewait, setstarttime, message, timerdrawdelay);
    }   
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

so_delete_breach_ents()
{
	breach_solids = getentarray("breach_solid", "targetname");
	foreach (ent in breach_solids)
	{
		ent connectpaths();
		ent delete();
	}
}

set_hud_yellow()
{
    if (isdefined(level.lua["set_hud_yellow"]))
    {
        func = level.lua["set_hud_yellow"];
        self [[ func ]]();
    }
}

set_hud_red()
{
    if (isdefined(level.lua["set_hud_red"]))
    {
        func = level.lua["set_hud_red"];
        self [[ func ]]();
    }  
}

set_hud_green()
{
    if (isdefined(level.lua["set_hud_green"]))
    {
        func = level.lua["set_hud_green"];
        self [[ func ]]();
    }
}

so_include_deadquote_array(arr)
{
    if (isdefined(level.lua["so_include_deadquote_array"]))
    {
        func = level.lua["so_include_deadquote_array"];
        self [[ func ]](arr);
    }
}

so_hud_pulse_default()
{
    fontscale = self.fontscale;
    self changefontscaleovertime(0.1);
    self.fontscale = 1.8;
    wait 0.1;
    self changefontscaleovertime(0.1);
    self.fontscale = fontscale;
}

issplitscreen()
{
    return false;
}

is_coop()
{
    return false;
}

so_standard_wait()
{
	return 4;
}

vector_multiply(vec, scale)
{
    return vec * scale;
}

setneargoalnotifydist(dist)
{
    self neargoalnotifydist(dist);
}
