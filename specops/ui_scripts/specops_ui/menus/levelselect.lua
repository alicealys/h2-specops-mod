require("menus/data/acts")

local function formattime(msec)
    return string.format("%d:%02d.%02d", math.floor(msec / 1000 / 60), math.floor(msec / 1000) % 60, (msec % 1000) / 10)
end

local function cleanstr(str)
    return str:sub(2, #str - 1)
end

local function gettotalstars()
    local totalstars = 0
    for i = 1, #acts do
        for o = 1, #acts[i].missions do
            if (acts[i].missions[o].playable) then
                totalstars = totalstars + 3
            end
        end
    end
    return totalstars
end

local function getnextunlock()
    local stars = sostats.gettotalstars()
    for i = 1, #acts do
        if (stars < acts[i].requiredstars) then
            return acts[i].requiredstars - stars
        end
    end
    return -1
end

LUI.MenuBuilder.registerPopupType("specops_stars_missing", function(element, data)
    local messagetext = nil
    if (data.stars > 1) then
        messagetext = Engine.Localize("@SPECIAL_OPS_SO_UNLOCK_MORE_DESC", data.stars)
    else
        messagetext = Engine.Localize("@SPECIAL_OPS_SO_UNLOCK_SINGLE_DESC")
    end

	return LUI.MenuBuilder.BuildRegisteredType( "generic_confirmation_popup", {
		cancel_will_close = true,
		popup_title = Engine.Localize("@MENU_NOTICE"),
		message_text = messagetext,
		button_text = Engine.Localize("@MENU_OK"),
	})
end)

local function addlocationinfowindow(menu)
	local infoBox = LUI.MenuBuilder.BuildRegisteredType("InfoBox", {
		skipAnim = true,
        noRightPane = true
	})

    LUI.sp_menus.LevelSelectMenu.SetupInfoBoxRightForMissionSelect(infoBox)
    
	infoBox:drawCornerLines()
	menu:addElement(infoBox)
	menu.infoBox = infoBox
end

local function startmap(somapname, mapname)
    Engine.SetDvarFromString("so_mapname", somapname)
    Engine.SetDvarFromString("addon_mapname", somapname)
    Engine.SetDvarBool("cl_disableMapMovies", true)
    Engine.SetDvarBool("cl_enableCustomLoadscreen", true)
    Engine.SetDvarString("cl_loadscreenImage", "loadscreen_" .. somapname)

    local objmaps = {
        ["so_ac130_co_hunted"] = true,
        ["so_snowrace1_cliffhanger"] = true,
        ["so_killspree_trainer"] = true,
        ["so_killspree_favela"] = true,
        ["so_rooftop_contingency"] = true,
    }

    Engine.SetDvarString("cl_loadscreenTitle", Engine.LocalizeLong("@SPECIAL_OPS_" .. Engine.ToUpperCase(somapname)))
    Engine.SetDvarString("cl_loadscreenDesc", Engine.LocalizeLong("@SPECIAL_OPS_" .. Engine.ToUpperCase(somapname) .. "_DESC"))
    Engine.SetDvarString("cl_loadscreenObjIcon", "star")

    if (objmaps[somapname] ~= nil) then
        Engine.SetDvarString("cl_loadscreenObj", Engine.LocalizeLong("@SPECIAL_OPS_" .. Engine.ToUpperCase(somapname) .. "_OBJ_DESC"))
    else
        Engine.SetDvarString("cl_loadscreenObj", "")
    end

    Engine.Exec("map " .. mapname)
end

local function addbuttonstars(button, earned)
    local num = 0
    local createstar = function()
        local star = LUI.UIImage.new({
            topAnchor = true,
            rightAnchor = true,
            top = 4,
            height = 22,
            width = 22,
            right = (22 * num + 5 * num) * -1 - 10,
            material = RegisterMaterial("star"),
            alpha = 0.7
        })

        star:registerAnimationState("unlocked", {
            color = Colors.h2.yellow,
        })

        star:registerAnimationState("locked", {
            color = Colors.h2.grey,
        })

        star:registerAnimationState("focus", {
            alpha = 1,
        })

        
        star:registerAnimationState("unfocus", {
            alpha = 0.7,
        })

        num = num + 1

        return star
    end

    local stars = {}
    for i = 3, 1, -1 do
        local star = createstar()
        star:animateToState("locked")
        star:registerEventHandler("gain_focus", MBh.AnimateToState("focus"))
        star:registerEventHandler("lose_focus", MBh.AnimateToState("unfocus"))

        stars[i] = star
        button:addElement(star)
    end

    local timer = LUI.UITimer.new(150, "update_stars")
    button:addElement(timer)
    local starindex = 0
    button:registerEventHandler("update_stars", function()
        starindex = starindex + 1

        if (starindex <= earned) then
            stars[starindex]:animateToState("unlocked")
        end

        if (starindex >= 3) then
            timer:close()
        end
    end)
end

local function addstars(infobox)
    local num = 0
    local createstar = function()
        local star = LUI.UIImage.new({
            topAnchor = true,
            leftAnchor = true,
            top = -10,
            height = 22,
            width = 22,
            left = 22 * num + 5 * num,
            material = RegisterMaterial("star"),
            alpha = 1
        })

        star:registerAnimationState("unlocked", {
            color = Colors.h2.yellow,
        })

        star:registerAnimationState("locked", {
            color = Colors.h2.grey,
        })

        num = num + 1

        return star
    end

    infobox.stars = {
        createstar(),
        createstar(),
        createstar(),
    }

    function infobox:setstars(count)
        for i = 1, #infobox.stars do
            if (i < count) then
                infobox.stars[i]:animateToState("unlocked")
            else
                infobox.stars[i]:animateToState("locked")
            end
        end
    end

    for i = 1, #infobox.stars do
        infobox.bottomLeftElements:addElement(infobox.stars[i])
    end
end


local h1menutab = package.loaded["LUI.H1MenuTab"]
local createbarelement = h1menutab.CreateBarElement
h1menutab.CreateBarElement = function(a1, index, ...)
    local button = createbarelement(a1, index, ...)
    if (not button) then
        return button
    end

    button.properties = {
        allowDisabledAction = true
    }

    button:registerEventHandler("button_action_disable", function()
        LUI.FlowManager.RequestAddMenu(nil, "specops_stars_missing", nil, nil, nil, {
            stars = acts[index].requiredstars - sostats.gettotalstars()
        })
    end)

    return button
end

local function levelselect(act)
    return function(root)
        local width = GenericMenuDims.menu_right_standard + 150 - GenericMenuDims.menu_left
        local menu = LUI.MenuTemplate.new(root, {
            menu_title = Engine.Localize("@MENU_MISSION_SELECT_CAPS"),
            uppercase_title = true,
            menu_top_indent = LUI.MenuTemplate.spMenuOffset + LUI.H1MenuTab.tabChangeHoldingElementHeight + H1MenuDims.spacing,
            menu_list_divider_top_offset = -(LUI.H1MenuTab.tabChangeHoldingElementHeight + H1MenuDims.spacing),
            menu_width = width
        })

        local createtoprighttext = function()
            local toprightstate = CoD.CreateState(-500, 45, -25, nil, CoD.AnchorTypes.TopRight)
            toprightstate.alignment = LUI.Alignment.Right
            toprightstate.font = CoD.TextSettings.TitleFontTiny.Font
            toprightstate.height = CoD.TextSettings.TitleFontTiny.Height
            toprightstate.color = GenericMenuColors.text_highlight
            local toprighttext = LUI.UIText.new(toprightstate)

            toprighttext:registerAnimationState("show", {
                alpha = 1
            })

            toprighttext:registerAnimationState("hide", {
                alpha = 0
            })

            local star = LUI.UIImage.new({
                topAnchor = true,
                rightAnchor = true,
                top = -6,
                height = 22,
                width = 22,
                right = 25,
                material = RegisterMaterial("star"),
                alpha = 1,
                color = Colors.h2.yellow,
            })

            toprighttext:addElement(star)

            menu:addElement(toprighttext)
            return toprighttext
        end

        local smallbarstate = CoD.CreateState(nil, 66, 0, nil, CoD.AnchorTypes.TopRight)
		smallbarstate.width = 200
		smallbarstate.height = 1
		smallbarstate.material = RegisterMaterial("gradient_fadein")
		smallbarstate.color = GenericMenuColors.title_divider
		menu.headerContainer:addElement(LUI.UIImage.new(smallbarstate))

        local totalstars = createtoprighttext()
        totalstars:setText(Engine.Localize("@MENU_SP_TOTAL_STARS", sostats.gettotalstars(), gettotalstars()))

        local nextunlock = nil
        local nextunlockvalue = getnextunlock()
        if (nextunlockvalue ~= -1) then
            nextunlock = createtoprighttext()
            nextunlock:animateToState("hide")
            nextunlock.visible = false
            nextunlock:setText(Engine.ToUpperCase(Engine.Localize("@MENU_SP_NEXT_UNLOCK_VALUE", nextunlockvalue)))

            menu:addElement(LUI.UITimer.new(3000, "switch_text"))
            menu:registerEventHandler("switch_text", function()
                if (nextunlock.visible) then
                    nextunlock.visible = false
                    nextunlock:animateInSequence({
                        {
                            "show",
                            0
                        },
                        {
                            "hide",
                            200
                        }
                    })

                    totalstars:animateInSequence({
                        {
                            "hide",
                            200
                        },
                        {
                            "show",
                            400
                        }
                    })
                else
                    nextunlock.visible = true
                    totalstars:animateInSequence({
                        {
                            "show",
                            0
                        },
                        {
                            "hide",
                            200
                        }
                    })

                    nextunlock:animateInSequence({
                        {
                            "hide",
                            200
                        },
                        {
                            "show",
                            400
                        }
                    })
                end
            end)
        end
        
        local black_state = CoD.CreateState(nil, nil, nil, nil, CoD.AnchorTypes.All)
        black_state.red = 0
        black_state.blue = 0
        black_state.green = 0
        black_state.alpha = 0
        black_state.left = -100
        black_state.right = 100
        black_state.top = -100
        black_state.bottom = 100
    
        local black = LUI.UIImage.new(black_state)
        black:setPriority(-1000)
    
        black:registerAnimationState("BlackScreen", {
            alpha = 1
        })
    
        black:registerAnimationState("Faded", {
            alpha = 0
        })

        menu:addElement(black)

        local menutab = LUI.H1MenuTab.new({
            title = function (index)
                return Engine.Localize(acts[index].name)
            end,
            top = LUI.MenuTemplate.spMenuOffset + LUI.MenuTemplate.ListTop,
            width = width,
            tabCount = #acts,
            clickTabBtnAction = function(a1, a2, index)
                LUI.FlowManager.RequestAddMenu(nil, "so_levelselect_" .. acts[index].id, true, nil, true)
                CoD.PlayEventSound(CoD.SFX.H1TabChange, 10)
            end,
            activeIndex = act.index,
            underTabTextFunc = function (index)
                return Engine.Localize(acts[index].name)
            end,
            isTabLockedfunc = function(index)
                return (not Engine.GetDvarBool("mis_cheat")) and sostats.gettotalstars() < acts[index].requiredstars
            end,
            previousDisabled = false,
            nextDisabled = false,
            enableRightLeftNavigation = true,
            skipChangeTab = true,
            exclusiveController = menu.exclusiveController
        })

        menu:addElement(menutab)

        for i = 1, #act.missions do
            local name = "@SPECIAL_OPS_" .. Engine.ToUpperCase(act.missions[i].somapname)
            local islocked = not (io.fileexists(game:getloadedmod() .. "/scripts/specops/maps/" .. act.missions[i].somapname .. ".lua"))
            local button = menu:AddButton(name, function()
                if (act.missions[i].nodifficulty) then
                    Engine.SetDvarString("ui_loadMenuName", "so_levelselect_act" .. act.index)
                    startmap(act.missions[i].somapname, act.missions[i].mapname)
                    return
                end

                Engine.SetDvarInt("recommended_gameskill", -1)
                LUI.FlowManager.RequestAddMenu(nil, "difficulty_selection_menu", true, menu.controller, false, {
                    acceptFunc = function()
                        Engine.SetDvarString("ui_loadMenuName", "so_levelselect_act" .. act.index)
                        startmap(act.missions[i].somapname, act.missions[i].mapname)
                    end,
                    specialops = true,
                    tryAgainAvailable = false
                })
            end, islocked, true, false, {
                style = GenericButtonSettings.Styles.FlatButton,
                textStyle = CoD.TextStyle.ForceUpperCase,
                disableSound = CoD.SFX.DenySelect
            })

            local stats = sostats.getmapstats(act.missions[i].somapname)
            if (not islocked) then
                addbuttonstars(button, (stats.stars or 0))
            end

            local gainfocus = button.m_eventHandlers["gain_focus"]
            button:registerEventHandler("gain_focus", function(element, event)
                gainfocus(element, event)
                if (not menu.infoBox) then
                    addlocationinfowindow(menu, {
                        skipAnim = true,
                        noRightPane = true
                    })
                end

                menu.infoBox.title:setText(Engine.Localize(name))
                local description = "@SPECIAL_OPS_" .. Engine.ToUpperCase(act.missions[i].somapname) .. "_DESC"
                menu.infoBox.description:setText(Engine.Localize(description))

                local stats = sostats.getmapstats(act.missions[i].somapname)
                local time = stats.besttime and Engine.Localize("@MENU_SO_BEST_TIME", formattime(stats.besttime)) or Engine.Localize("@LUA_MENU_NOT_COMPLETED")

                menu:processEvent({
                    name = "update_levelInfo",
                    level_number = 1,
                    title_text = Engine.Localize(name),
                    location_text = "",
                    intel_text = time,
                    level_controller = nil,
                    narative_level = 1,
                })

                PersistentBackground.ChangeBackground(nil, act.missions[i].video)
                black:animateInSequence( {
                    {
                        "BlackScreen",
                        0
                    },
                    {
                        "Faded",
                        2000
                    }
                })
            end)
        end

        menu:AddBackButton()

        return menu
    end
end

for i = 1, #acts do
    LUI.MenuBuilder.registerType("so_levelselect_" .. acts[i].id, levelselect(acts[i]))
end

firstmenu = "so_levelselect_" .. acts[1].id
