if (Engine.InFrontend()) then
    return
end

local current = "0"

function eogsummary()
    local value = tonumber(Engine.GetDvarString("ui_so_mission_status"))
    Engine.SetDvarString("ui_so_mission_status", "0")
    local success = value == 1

    local popupwidth = 500
    local title = success and "@SPECIAL_OPS_UI_MISSION_SUCCESS" or "SPECIAL_OPS_UI_MISSION_FAILED"
	local popup = LUI.MenuBuilder.BuildRegisteredType("generic_yesno_popup", {
		popup_title = Engine.Localize(title),
		message_text = "",
        popup_width = popupwidth,
        padding_top = 10,
        cancel_means_no = false,
        popup_title_alignment = LUI.Alignment.Center,
		yes_action = function()
            Engine.Exec("lui_restart; fast_restart")
		end,
		no_action = function()
            Engine.Exec("disconnect")
		end
	})

    local deadquote = ""
    local content = popup:getFirstDescendentById("generic_selectionList_content_id")
    local body = LUI.UIElement.new({
        width = popupwidth - 22,
        height = deadquote ~= "" and 130 or 50
    })

    local deadquotetext = LUI.UIText.new({
        leftAnchor = true,
        topAnchor = true,
        rightAnchor = true,
        height = CoD.TextSettings.TitleFontSmaller.Height,
        font = CoD.TextSettings.TitleFontSmaller.Font,
        alignment = LUI.Alignment.Center
    })

    if (deadquote ~= "") then
        deadquotetext:setText(Engine.Localize(deadquote))
        body:addElement(deadquotetext)
    end

    local num = 0
    local addstat = function(name, value)
        local height = 30
        local offset = (height + 5) * num + (deadquote ~= "" and 80 or 0)

        local container = LUI.UIElement.new({
            leftAnchor = true,
            rightAnchor = true,
            topAnchor = true,
            height = height,
            top = offset,
        })

        local left = LUI.UIText.new({
            leftAnchor = true,
            topAnchor = true,
            height = CoD.TextSettings.TitleFontSmaller.Height,
            font = CoD.TextSettings.TitleFontSmaller.Font,
            width = 100,
            left = 5,
            top = (height - CoD.TextSettings.TitleFontSmaller.Height) / 2 + 2,
            alignment = LUI.Alignment.Left
        })

        left:setText(Engine.ToUpperCase(name))

        local right = LUI.UIText.new({
            rightAnchor = true,
            topAnchor = true,
            height = CoD.TextSettings.TitleFontSmaller.Height,
            font = CoD.TextSettings.TitleFontSmaller.Font,
            width = 100,
            right = -5,
            top = (height - CoD.TextSettings.TitleFontSmaller.Height) / 2 + 2,
            alignment = LUI.Alignment.Right
        })

        right:setText(value)

        local border = LUI.MenuBuilder.BuildRegisteredType("generic_border", {
            thickness = 0.1,
            border_red = Colors.generic_menu_frame_color.r - 0.2,
            border_green = Colors.generic_menu_frame_color.g - 0.2,
            border_blue = Colors.generic_menu_frame_color.b - 0.2
        })

        container:addElement(border)
        container:addElement(left)
        container:addElement(right)
        body:addElement(container)

        num = num + 1
    end

    local difficulties = {
        Engine.Localize("GAME_DIFFICULTY_EASY"),
        Engine.Localize("GAME_DIFFICULTY_MEDIUM"),
        Engine.Localize("GAME_DIFFICULTY_HARD"),
        Engine.Localize("GAME_DIFFICULTY_FU")
    }

    local function getdifficulty()
        local index = Engine.GetDvarInt("g_gameskill") + 1
        if (not difficulties[index]) then
            return Engine.Localize("GAME_DIFFICULTY_UNKNOWN")
        end

        local difficulty = difficulties[index]
        return difficulty:sub(13)
    end

    local msec = tonumber(Engine.GetDvarString("so_mission_time"))
    local formattedtime = string.format("%d:%02d.%02d", math.floor(msec / 1000 / 60), math.floor(msec / 1000) % 60, (msec % 1000) / 10)
    
    addstat("Time", formattedtime)
    addstat("Kills", Engine.GetDvarString("aa_player_kills"))
    addstat("Difficulty", getdifficulty())

    content:insertElement(body, 1)

    popup:registerEventHandler("menu_close", function()
        Engine.Exec("lui_restart; fast_restart")
    end)

    local yesbutton = popup:getFirstDescendentById("yes_button_id")
    local yestext = yesbutton:getFirstDescendentById("text_label")
    yestext:setText(Engine.Localize("SPECIAL_OPS_UI_PLAY_AGAIN"))

    local nobutton = yesbutton:getNextSibling()
    local notext = nobutton:getFirstDescendentById("text_label")
    notext:setText(Engine.Localize("SPECIAL_OPS_UI_RETURN_TO_SPECIALOPS"))

    return popup
end

LUI.MenuBuilder.registerType("so_eog_summary", eogsummary)

local getdvarbool = Engine.GetDvarBool
Engine.GetDvarBool = function(...)
    local args = {...}
    if (args[1] == "specialops") then
        return true
    end

    return getdvarbool(...)
end
