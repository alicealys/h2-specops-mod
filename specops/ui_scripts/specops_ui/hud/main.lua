
local oncreate = function(menu)
    local createstate = CoD.CreateState
    CoD.CreateState = function(...)
        local args = {...}
        if (args[2] == 127.66 and args[3] == 12.670002) then
            CoD.CreateState = createstate
            return createstate(nil, 10, 235, nil, CoD.AnchorTypes.TopLeft)
        end

        return createstate(...)
    end

    local refresh = LUI.sp_hud.ObjectivesFrame.RefreshMinimapObjectives
    LUI.sp_hud.ObjectivesFrame.RefreshMinimapObjectives = function(a1, a2)
        local count = Engine.GetPlayerObjectivePositions(0, 0)
        if (count and menu.miniMapContainer and menu.miniMapContainer.miniMapIcons and #count < menu.miniMapContainer.miniMapIcons.objectiveCount) then
            menu.miniMapContainer.miniMapIcons.mapBlipPulse:clearAll()
            menu.miniMapContainer.miniMapIcons.objectiveCount = 0
        end

        refresh(a1, a2)
    end

    LUI.sp_hud.ObjectivesFrame.AddMiniMap(menu, true)
    local minimap = menu.miniMapContainer:getFirstChild()

    minimap:registerAnimationState("hud_off", {
        alpha = 0
    })

    minimap:registerAnimationState("hud_on", {
        alpha = 1
    })

    local hudoff = menu.m_eventHandlers["hud_off"]
    minimap.hud_off = false
    minimap.showing_message = false

    minimap:addElement(LUI.UITimer.new(100, "_update"))
    minimap:registerEventHandler("_update", function()
        minimap.showing_message = Game.IsShowingGameMessages(0)
        if (not minimap.showing_message and not minimap.hud_off) then
            minimap:animateToState("hud_on")
        else
            minimap:animateToState("hud_off")
        end
    end)

    minimap:registerEventHandler("game_message", function()
        if (Game.IsShowingGameMessages(0)) then
            minimap:animateToState("hud_off")
            minimap.showing_message = true
        end
    end)
end

local compassdef = LUI.MenuBuilder.m_definitions["CompassHudDef"]
LUI.MenuBuilder.m_definitions["CompassHudDef"] = function()
	local compass = compassdef()
    compass.states.default = {
        topAnchor = true,
        leftAnchor = true,
        rightAnchor = true,
        bottomAnchor = true,
        bottom = compass.states.default.bottom,
    }

    table.insert(compass.children, {
        type = "UIElement",
        states = {
            default = {
                topAnchor = true,
                leftAnchor = true,
                rightAnchor = true,
                bottomAnchor = true,
            },
            hud_off = {
                alpha = 0
            },
            hud_on = {
                alpha = 1
            }
        },
        handlers = {
            menu_create = oncreate
        }
    })
    return compass
end
