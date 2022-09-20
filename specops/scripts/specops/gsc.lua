level.lua = array:new()
level.luaret = nil


local function createfunction(func)
    return function(ent, ...)
        level.luaret = func(...)
    end
end

level.lua["so_create_hud_item"] = createfunction(createhuditem)
level.lua["so_dialog_counter_update"] = createfunction(dialoguecounterupdate)
level.lua["enable_challenge_timer"] = createfunction(enablechallengetimer)
level.lua["enable_escape_warning"] = createfunction(enableescapewarning)
level.lua["enable_escape_failure"] = createfunction(enableescapefailure)
level.lua["enable_countdown_timer"] = createfunction(enablecountdowntimer)
level.lua["set_hud_yellow"] = entity.setyellow
level.lua["set_hud_red"] = entity.setred
level.lua["so_hud_pulse_success"] = entity.setgreen
level.lua["so_hud_pulse_close"] = entity.setgreen
