local current = "0"

function formattime(msec)
    return string.format("%d:%02d.%02d", math.floor(msec / 1000 / 60), math.floor(msec / 1000) % 60, (msec % 1000) / 10)
end

function eogsummary()
    Engine.PlaySound("so_ingame_summary")

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
            width = (popupwidth - 22) / 2,
            left = 5,
            top = (height - CoD.TextSettings.TitleFontSmaller.Height) / 2 + 3,
            alignment = LUI.Alignment.Left
        })

        left:setText(Engine.ToUpperCase(name))

        local right = LUI.UIText.new({
            rightAnchor = true,
            topAnchor = true,
            height = CoD.TextSettings.TitleFontSmaller.Height,
            font = CoD.TextSettings.TitleFontSmaller.Font,
            width = (popupwidth - 22) / 2,
            right = -5,
            top = (height - CoD.TextSettings.TitleFontSmaller.Height) / 2 + 3,
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
    local formattedtime = ""
    if (msec < 0) then
        formattedtime = Engine.Localize("@MENU_SO_DID_NOT_FINISH")
    else
        formattedtime = formattime(msec)
    end
    
    local extradata = game:sharedget("eog_extra_data")
    if (extradata ~= "") then
        extradata = json.decode(extradata)
    end

    if (type(extradata) ~= "table") then
        extradata = {}
    end

    content:getFirstDescendentById("spacer"):close()

    local showdifficulty = tonumber(Engine.GetDvarString("ui_so_show_difficulty")) == 1
    local extraheight = 0

    extraheight = extraheight - 30
    if (not extradata.hidetime) then
        local label = "@SPECIAL_OPS_UI_TIME"
        if (extradata.timelabel) then
            label = extradata.timelabel
        end

        if (not extradata.timeoverride) then
            addstat(Engine.Localize(label), formattedtime)
            extraheight = extraheight + 30
        else
            addstat(Engine.Localize(label), extradata.timeoverride)
            extraheight = extraheight + 30
        end
    end

    if (not extradata.hidekills) then
        addstat(Engine.Localize("@SPECIAL_OPS_UI_KILLS"), Engine.GetDvarString("aa_player_kills"))
        extraheight = extraheight + 35
    end

    if (showdifficulty) then
        addstat(Engine.Localize("@SPECIAL_OPS_UI_DIFFICULTY"), getdifficulty())
        extraheight = extraheight + 35
    end

    if (type(extradata.stats) == "table") then
        for i = 1, #extradata.stats do
            local stat = extradata.stats[i]
            if (type(stat) == "table" and stat.name and stat.value) then
                local value = stat.value
                if (stat.istimestamp and type(value) == "number") then
                    value = formattime(value)
                end
    
                if (stat.isvaluelocalized) then
                    local values = type(stat.values) == "table" and stat.values or {}
                    addstat(Engine.Localize(stat.name), Engine.Localize(value, table.unpack(values)))
                else
                    addstat(Engine.Localize(stat.name), value)
                end
    
                extraheight = extraheight + 35
            end
        end
    end

    body:registerAnimationState("default", {
        width = popupwidth - 22,
        height = (deadquote ~= "" and 80 or 0) + extraheight + 5
    })
    body:animateToState("default")

    content:insertElement(body, 1)

    popup:registerEventHandler("menu_close", function()
        Engine.Exec("lui_restart; fast_restart")
    end)

    local timer = LUI.UITimer.new(400, "show_new_stars")
    popup:addElement(timer)
    popup:registerEventHandler("show_new_stars", function()
        local newstars = tonumber(Engine.GetDvarString("ui_so_new_stars"))
        local newbest = tonumber(Engine.GetDvarString("ui_so_new_besttime")) == 1
        if (newstars > 0) then
            LUI.FlowManager.RequestAddMenu(nil, "so_new_stars")
        elseif (newbest) then
            LUI.FlowManager.RequestAddMenu(nil, "so_new_record")
        end
        timer:close()
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
