local HttpGet     = game.HttpGet
local GameId      = game.GameId
local Players     = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Fetch game list
local Games = loadstring(
    HttpGet(game, "https://raw.githubusercontent.com/fixingbugsat3am-dot/loadstringg/refs/heads/main/Scripts/GamesScripts/list.lua")
)()

-- Print supported games to console
print("=== KairoxHub Supported Games ===")
for id, data in pairs(Games) do
    print("✔ " .. data.Name .. " [" .. tostring(id) .. "]")
end
print("=================================")
print("Current Game ID: " .. tostring(GameId))

-- Check if current game is supported
local GameData = Games[GameId]

if not GameData then
    print("✘ Game not supported: " .. tostring(GameId))

    local ScreenGui       = Instance.new("ScreenGui")
    ScreenGui.Name        = "KairoxHubError"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent      = LocalPlayer:WaitForChild("PlayerGui")

    local Frame                     = Instance.new("Frame")
    Frame.Size                      = UDim2.fromScale(1, 1)
    Frame.BackgroundColor3          = Color3.fromRGB(0, 0, 0)
    Frame.BackgroundTransparency    = 0.4
    Frame.Parent                    = ScreenGui

    local Label               = Instance.new("TextLabel")
    Label.Size                = UDim2.fromScale(1, 1)
    Label.BackgroundTransparency = 1
    Label.TextColor3          = Color3.fromRGB(255, 255, 255)
    Label.TextScaled          = true
    Label.RichText            = true
    Label.Font                = Enum.Font.GothamBold
    Label.Text = table.concat({
        '<font size="40" color="rgb(255,80,80)">❌ Game Not Supported</font>',
        "",
        '<font size="24">Game ID: ' .. tostring(GameId) .. "</font>",
        "",
        '<font size="20" color="rgb(180,180,180)">KairoxHub does not support this game yet.</font>',
        '<font size="18" color="rgb(140,140,140)">Disconnecting in 3 seconds...</font>',
    }, "\n")
    Label.Parent = Frame

    task.wait(3)
    LocalPlayer:Kick("KairoxHub — Game not supported (ID: " .. tostring(GameId) .. ")")
    return
end

-- Game is supported, load the script
print("✔ Loading: " .. GameData.Name)
loadstring(HttpGet(game, GameData.URL))()
