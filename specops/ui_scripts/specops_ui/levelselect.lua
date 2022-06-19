game:addlocalizedstring("MENU_SO_ACT_ALPHA", "ALPHA")
game:addlocalizedstring("MENU_SO_ACT_BRAVO", "BRAVO")
game:addlocalizedstring("MENU_SO_ACT_CHARLIE", "CHARLIE")
game:addlocalizedstring("MENU_SO_ACT_DELTA", "DELTA")
game:addlocalizedstring("MENU_SO_ACT_ECHO", "ECHO")

local acts = {
    {
        id = "act1",
        index = 1,
        name = "@MENU_SO_ACT_ALPHA",
        missions = {
            {
                name = "The Pit",
                mapname = "trainer",
                locked = true
            },
            {
                name = "Sniper Fi",
                mapname = "contingency",
                locked = true
            },
            {
                name = "O Cristo Redentor",
                mapname = "favela",
                locked = true
            },
            {
                name = "Evasion",
                mapname = "contingency",
                locked = true
            },
            {
                name = "Suspension",
                mapname = "ending",
                locked = true
            }
        }
    },
    {
        id = "act2",
        index = 2,
        name = "@MENU_SO_ACT_BRAVO",
        missions = {
            {
                name = "Overwatch",
                mapname = "ending",
                locked = true
            },
            {
                name = "Body Count",
                mapname = "invasion",
                locked = true
            },
            {
                name = "Bomb Squad",
                mapname = "favela_escape",
                locked = true
            },
            {
                name = "Race",
                mapname = "cliffhanger",
                locked = true
            },
            {
                name = "Big Brother",
                mapname = "invasion",
                locked = true
            },
        }
    },
    {
        id = "act3",
        index = 3,
        name = "@MENU_SO_ACT_CHARLIE",
        missions = {
            {
                name = "Hidden",
                mapname = "ending",
                locked = true
            },
            {
                name = "Breach & Clear",
                mapname = "gulag",
            },
            {
                name = "Time Trial",
                mapname = "cliffhanger",
                locked = true
            },
            {
                name = "Homeland Security",
                mapname = "invasion",
                locked = true
            },
            {
                name = "Snatch & Grab",
                mapname = "boneyard",
                locked = true
            },
        }
    },
    {
        id = "act4",
        index = 4,
        name = "@MENU_SO_ACT_DELTA",
        missions = {
            {
                name = "Wardriving",
                mapname = "arcadia",
                locked = true
            },
            {
                name = "Wreckage",
                mapname = "ending",
                locked = true
            },
            {
                name = "Acceptable Losses",
                mapname = "cliffhanger",
                locked = true
            },
            {
                name = "Terminal",
                mapname = "airport",
                locked = true
            },
            {
                name = "Estate Takedown",
                mapname = "estate",
                locked = true
            },
        }
    },
    {
        id = "act5",
        index = 5,
        name = "@MENU_SO_ACT_ECHO",
        missions = {
            {
                name = "Wetwork",
                mapname = "oilrig",
                locked = true
            },
            {
                name = "High Explosive",
                mapname = "favela",
                locked = true
            },
            {
                name = "Armor Piercing",
                mapname = "oilrig",
                locked = true
            },
        }
    }
}

function levelselect(act)
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

        menu:addElement( LUI.H1MenuTab.new( {
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
            local name = act.missions[i].name
            game:addlocalizedstring(name, name)
            local button = menu:AddButton(name, function()
                LUI.FlowManager.RequestAddMenu(nil, "difficulty_selection_menu", true, menu.controller, false, {
                    acceptFunc = function()
                        Engine.Exec("map " .. act.missions[i].mapname)
                    end,
                    specialops = true
                })
            end, act.missions[i].locked, true, false, {
                style = GenericButtonSettings.Styles.FlatButton,
                textStyle = CoD.TextStyle.ForceUpperCase,
                disableSound = CoD.SFX.DenySelect
            })

            button:registerEventHandler("button_over", function()
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
