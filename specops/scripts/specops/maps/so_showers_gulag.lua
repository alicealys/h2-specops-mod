local map = {}

map.premain = function()
    game:visionsetnaked("gulag", 0)
    setloadout("m4m203_reflex_arctic", "m1014", "fraggrenade", "flash_grenade", "viewhands_udt", "american")
end

map.main = function()
    mainhook.invoke(level)
    setcompassdist("close")
    setplayerpos()
    intro()
end

return map
