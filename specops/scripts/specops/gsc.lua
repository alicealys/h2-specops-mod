level.lua = array:new()
level.luaret = nil


local function createfunction(func)
    return function(ent, ...)
        print(...)
        level.luaret = func(...)
    end
end

level.lua["so_create_hud_item"] = createfunction(createhuditem)
level.lua["so_dialog_counter_update"] = createfunction(dialoguecounterupdate)
level.lua["enable_challenge_timer"] = createfunction(enablechallengetimer)
level.lua["so_hud_pulse_success"] = entity.setgreen
level.lua["so_hud_pulse_close"] = entity.setgreen
