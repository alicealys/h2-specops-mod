switch(mapname, {
    ["so_crossing_so_bridge"] = function()
        campaign = "ranger"
    end,
    ["so_hidden_so_ghillies"] = function()
        campaign = "ghillie"
    end,
    ["so_killspree_invasion"] = function()
        campaign = "ranger"
    end,
    ["so_forest_contingency"] = function()
        campaign = "arctic"
    end,
    ["so_rooftop_contingency"] = function()
        campaign = "arctic"
    end,
    ["so_sabotage_cliffhanger"] = function()
        campaign = "arctic"
    end,
    ["so_escape_airport"] = function()
        campaign = "ranger"
    end,
    ["so_killspree_favela"] = function()
        campaign = "desert"
    end,
    ["so_defense_invasion"] = function()
        campaign = "ranger"
    end,
    ["so_demo_so_bridge"] = function()
        campaign = "ranger"
    end,
    ["so_ac130_co_hunted"] = function()
        campaign = "woodland"
    end,
    ["so_showers_gulag"] = function()
        campaign = "seal"
    end,
    ["so_assault_oilrig"] = function()
        campaign = "seal"
    end,
    ["so_killspree_trainer"] = function()
        campaign = "ranger"
    end,
    ["so_defuse_favela_escape"] = function()
        campaign = "desert"
    end,
    ["so_takeover_oilrig"] = function()
        campaign = "seal"
    end,
    ["so_takeover_estate"] = function()
        campaign = "woodland"
    end, 
    ["so_intel_boneyard"] = function()
        campaign = "desert"
    end,
    ["so_juggernauts_favela"] = function()
        campaign = "desert"
    end,
    ["so_download_arcadia"] = function()
        campaign = "ranger"
    end,
    ["so_chopper_invasion"] = function()
        campaign = "ranger"
    end,
    ["so_snowrace1_cliffhanger"] = function()
        campaign = "arctic"
    end,
    ["so_snowrace2_cliffhanger"] = function()
        campaign = "arctic"
    end,
})

function mapfunction(name, file, id)
    _G[name] = function(...)
        return game:scriptcall(file, id, ...)
    end
end

function mapmethod(name, file, id)
    entity[name] = function(ent, ...)
        return ent:scriptcall(file, id, ...)
    end
end

mapfunction("getclosest", "common_scripts/utility", "_ID16182")
mapmethod("displayhint", "maps/_utility", "_ID11085")

game:detour("_ID42476", "_ID27337", function() end)

game:setdvar("scr_disableSaveGame", 1)

loadout = nil
loadoutequipment = nil

function setloadout(...)
    loadout = {...}
end

function setloadoutequipment(...)
    loadoutequipment = {...}
end

game:detour("maps/_loadout_code", "_id_C9FB", function()
    local mapname = game:getdvar("mapname")

    if (loadout) then
        level.has_loadout = true
        game:scriptcall("maps/_loadout_code", "loadout", mapname, table.unpack(loadout))
    end

    if (loadoutequipment) then
        game:scriptcall("maps/_loadout_code", "loadoutequipment", mapname, table.unpack(loadoutequipment))
    end
end)

level:onnotify("juggernaut_attacking", function()
    player:playlocalsound("_juggernaut_attack")
end)
