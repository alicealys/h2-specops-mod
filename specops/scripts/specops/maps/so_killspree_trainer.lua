local map = {}

map.premain = function()

end

map.calculatestars = function()
    return level.star_count
end

map.preover = function()
    local finished = level._id_CEFF >= 24
    local timeentry = {}
    if (not finished) then
        timeentry = {
            name = "@SO_KILLSPREE_TRAINER_SCOREBOARD_FINISH_TIME",
            value = "@SO_KILLSPREE_TRAINER_SCOREBOARD_NA",
            isvaluelocalized = true,
        }
    end

    game:sharedset("eog_extra_data", json.encode({
        hidekills = true,
        hidetime = not finished,
        timelabel = "@SO_KILLSPREE_TRAINER_SCOREBOARD_FINISH_TIME",
        stats = {
            timeentry,
            {
                name = "@SO_KILLSPREE_TRAINER_SCOREBOARD_ENEMIES_HIT",
                value = "@SO_KILLSPREE_TRAINER_ENEMIES_COUNT",
                values = {level._id_CEFF, 24},
                isvaluelocalized = true,
            },
            {
                name = "@SO_KILLSPREE_TRAINER_SCOREBOARD_CIVS_HIT",
                value = "@SO_KILLSPREE_TRAINER_CIVVIES_COUNT",
                values = {level._id_AEA9, 5},
                isvaluelocalized = true,
            }
        }
    }))
end

map.main = function()
    player:setviewmodel("viewmodel_base_viewhands")
    player:giveweapon("m4_grunt")
    player:giveweapon("usp")
    player:switchtoweapon("m4_grunt")

    mainhook.invoke(level)
    
    setcompassdist("close")
    setplayerpos()
    enableallportalgroups()
    intro()

    enableescapewarning()
    enableescapefailure()

    musicloop("mus_so_killspree_trainer_music")
end

return map
