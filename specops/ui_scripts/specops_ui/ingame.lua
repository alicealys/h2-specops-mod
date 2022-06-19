if (Engine.InFrontend()) then
    return
end

local current = "0"

game:addlocalizedstring("SPECIAL_OPS_GULAG", "Breach & Clear")

function missionend()
    local container = LUI.UIElement.new({
        topAnchor = true,
        leftAnchor = true,
        width = 1280,
        height = 720,
        top = 1000
    })

    container:registerAnimationState("show", {
        topAnchor = true,
        leftAnchor = true,
        width = 1280,
        height = 720,
    })

    container:animateToState("show", 200)

    local value = tonumber(Engine.GetDvarString("ui_so_mission_over"))
    Engine.SetDvarString("ui_so_mission_over", "0")
    local success = value == 1

    local popup = LUI.UIElement.new({
        leftAnchor = true,
        topAnchor = true,
        width = 1280,
        top = 150,
        height = 720 - 150 * 2
    })

    local background = LUI.UIImage.new({
        leftAnchor = true,
        topAnchor = true,
        width = 1280,
        height = 720 - 150 * 2,
        material = RegisterMaterial("white"),
        color = {
            r = 0,
            g = 0,
            b = 0,
        },
        alpha = 0.6
    })

    local textstate = {
        leftAnchor = true,
        topAnchor = true,
        width = 1280,
        height = 35,
        font = RegisterFont("fonts/bank.ttf", 35),
        alignment = LUI.Alignment.Center
    }

    if (success) then
        textstate.color = {
            r = 0.8, 
            g = 0.8, 
            b = 1
        }
    else
        textstate.color = {
            r = 1, 
            g = 0.4, 
            b = 0.4
        }
    end

    local text = LUI.UIText.new(textstate)

    if (success) then
        text:setText("Mission Success!")
    else
        text:setText("Mission Failed!")
    end

    local numstats = 0
    local function addstat(name, value)
        local width = 500
        local padleft = 10
        local padright = 6
        local height = 24

        local offset = 120 + numstats * (height + 36)
        numstats = numstats + 1

        local background = LUI.UIImage.new({
            leftAnchor = true,
            topAnchor = true,
            left = 1280 / 2 - width / 2 - padleft,
            width = width + padleft * 2,
            height = height + padright,
            top = offset - padright / 2,
            material = RegisterMaterial("white"),
            color = {
                r = 0,
                g = 0,
                b = 0,
            },
            alpha = 0.6
        }) 

        local labeltext = LUI.UIText.new({
            leftAnchor = true,
            topAnchor = true,
            left = 1280 / 2 - width / 2,
            width = width,
            height = height,
            top = offset,
            font = RegisterFont("fonts/bank.ttf", 35),
        })

        labeltext:setText(name)

        local valuetext = LUI.UIText.new({
            leftAnchor = true,
            topAnchor = true,
            left = 1280 / 2 - width / 2,
            width = width,
            height = height,
            top = offset,
            font = RegisterFont("fonts/bank.ttf", 35),
            alignment = LUI.Alignment.Right
        })

        valuetext:setText(value)

        popup:addElement(background)
        popup:addElement(labeltext)
        popup:addElement(valuetext)
    end

    popup:addElement(background)
    popup:addElement(text)

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
    local formattedtime = string.format("%d:%02d.%d", math.floor(msec / 1000 / 60), math.floor(msec / 1000) % 60, (msec % 1000) / 10)
    
    addstat("Time", formattedtime)
    addstat("Kills", Engine.GetDvarString("aa_player_kills"))
    addstat("Difficulty", getdifficulty())

    local bind = LUI.UIBindButton.new()
    bind:registerEventHandler("button_secondary", function(element, event)
        bind:close()
        LUI.FlowManager.RequestLeaveMenu(nil, "so_mission_over")
        LUI.roots.UIRoot0:addElement(LUI.UITimer.new(500, "update_restart"))
        LUI.roots.UIRoot0:registerEventHandler("update_restart", function()
            Engine.Exec("lui_restart; fast_restart")
        end)
    end)

    container:addElement(popup)
    container:addElement(bind)

    return container
end

Engine.SetDvarFromString("ui_so_mission_over", "0")
LUI.roots.UIRoot0:addElement(LUI.UITimer.new(10, "update_watch_dvar"))
LUI.roots.UIRoot0:registerEventHandler("update_watch_dvar", function(element, event)
    local value = Engine.GetDvarString("ui_so_mission_over")
    if (value ~= "0") then
        LUI.FlowManager.RequestAddMenu(nil, "so_mission_over")
    end
end)

local getdvarbool = Engine.GetDvarBool
Engine.GetDvarBool = function(...)
    local args = {...}
    if (args[1] == "specialops") then
        return true
    end

    return getdvarbool(...)
end

LUI.MenuBuilder.registerType("so_mission_over", missionend)
