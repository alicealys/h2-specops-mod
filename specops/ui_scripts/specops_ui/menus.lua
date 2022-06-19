if (not Engine.InFrontend()) then
    return
end

require("levelselect")

LUI.LevelSelect.IsAllLevelCompleted = function()
	return false
end

Engine.CanResumeGame = function()
	return false
end

local localize = Engine.Localize
Engine.Localize = function(...)
	local args = {...}
	if (args[1] == "@MENU_SP_FOR_THE_RECORD") then
		return "SPECIAL OPS"
	end

    if (args[1] == "@MENU_SP_CAMPAIGN") then
        return "SPECIAL OPS"
    end

	return localize(unpack(args))
end

LUI.onmenuopen("main_campaign", function(menu)
	local buttonlist = menu:getChildById(menu.type .. "_list")
	buttonlist:removeElement(buttonlist:getFirstChild())
	buttonlist:removeElement(buttonlist:getFirstChild())
	buttonlist:removeElement(buttonlist:getFirstChild())
end)

game:addlocalizedstring("LUA_SP_SPECIAL_OPS_DESC", "Play Special Ops.")

LUI.addmenubutton("main_campaign", {
	index = 1,
	text = "@MENU_MISSION_SELECT_CAPS",
	description = Engine.Localize("@LUA_SP_SPECIAL_OPS_DESC"),
	callback = function()
		LUI.FlowManager.RequestAddMenu(nil, firstmenu)
	end
})
