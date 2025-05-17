local Games = loadstring(game:HttpGet("https://raw.githubusercontent.com/chmodddd/robloks/refs/heads/main/mem.lua"))()

for PlaceID, Execute in pairs(Games) do
    if PlaceID == game.PlaceId then
        loadstring(game:HttpGet(Execute))()
    end
end
