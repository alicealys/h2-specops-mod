require("menus/data/acts")

local function formattime(msec)
    return string.format("%d:%02d.%02d", math.floor(msec / 1000 / 60), math.floor(msec / 1000) % 60, (msec % 1000) / 10)
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

local function levelselect(act)
    return function(root)
        local width = GenericMenuDims.menu_right_standard + 150 - GenericMenuDims.menu_left
        
        local menu = LUI.MenuTemplate.new(root, {
            menu_title = Engine.Localize( "@MENU_MISSION_SELECT_CAPS" ),
            uppercase_title = true,
            menu_top_indent = LUI.MenuTemplate.spMenuOffset + LUI.H1MenuTab.tabChangeHoldingElementHeight + H1MenuDims.spacing,
            menu_list_divider_top_offset = -(LUI.H1MenuTab.tabChangeHoldingElementHeight + H1MenuDims.spacing),
            menu_width = width,
        })

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

        menu:addElement(LUI.H1MenuTab.new({
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
            isTabLockedfunc = function ()
                return false
            end,
            previousDisabled = false,
            nextDisabled = false,
            enableRightLeftNavigation = true,
            skipChangeTab = true,
            exclusiveController = menu.exclusiveController
        }))

        for i = 1, #act.missions do
            local name = "@SPECIAL_OPS_" .. Engine.ToUpperCase(act.missions[i].somapname)
            local islocked = not (io.fileexists(game:getloadedmod() .. "/scripts/specops/maps/" .. act.missions[i].somapname .. ".lua"))
            local button = menu:AddButton(name, function()
                if (act.missions[i].nodifficulty) then
                    Engine.SetDvarFromString("so_mapname", act.missions[i].somapname)
                    Engine.SetDvarFromString("addon_mapname", act.missions[i].somapname)
                    Engine.Exec("map " .. act.missions[i].mapname)
                    return
                end

                Engine.SetDvarInt("recommended_gameskill", -1)
                LUI.FlowManager.RequestAddMenu(nil, "difficulty_selection_menu", true, menu.controller, false, {
                    acceptFunc = function()
                        Engine.SetDvarFromString("so_mapname", act.missions[i].somapname)
                        Engine.SetDvarFromString("addon_mapname", act.missions[i].somapname)
                        Engine.Exec("map " .. act.missions[i].mapname)
                    end,
                    specialops = true,
                    tryAgainAvailable = false
                })
            end, islocked, true, false, {
                style = GenericButtonSettings.Styles.FlatButton,
                textStyle = CoD.TextStyle.ForceUpperCase,
                disableSound = CoD.SFX.DenySelect
            })

            local gainfocus = button.m_eventHandlers["gain_focus"]
            button:registerEventHandler("gain_focus", function(element, event)
                gainfocus(element, event)
                if (not menu.infoBox) then
                    LUI.LevelSelect.AddLocationInfoWindow(menu, {
                        skipAnim = true
                    })
                    addstars(menu.infoBox)
                end

                menu.infoBox.title:setText(Engine.Localize(name))
                local description = "@SPECIAL_OPS_" .. Engine.ToUpperCase(act.missions[i].somapname) .. "_DESC"
                menu.infoBox.description:setText(Engine.Localize(description))

                local stats = sostats.getmapstats(act.missions[i].somapname)
                local time = stats.besttime and Engine.Localize("@MENU_SO_BEST_TIME", formattime(stats.besttime)) or Engine.Localize("@LUA_MENU_NOT_COMPLETED")
                menu.infoBox:setstars((stats.stars or 0) + 1)

                menu:processEvent({
                    name = "update_levelInfo",
                    blipPosX = act.missions[i].blip and act.missions[i].blip.x or 60,
                    blipPosY = act.missions[i].blip and act.missions[i].blip.y or 60,
                    map_name = "invasion",
                    location_image = "h2_minimap_worldmap_mission_select",
                    level_number = 1,
                    title_text = Engine.Localize(name),
                    location_text = "",
                    intel_text = time,
                    level_controller = nil,
                    narative_level = 1,
                })

                menu.infoBox.bottomLeftElements.difficultyText:setText("")

                PersistentBackground.ChangeBackground(nil, "mission_select_bg_" .. act.missions[i].mapname)
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
