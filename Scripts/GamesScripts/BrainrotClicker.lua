local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Player = game:GetService("Players").LocalPlayer
local Leaderstats = Player:WaitForChild("leaderstats")
local Cash = Leaderstats:WaitForChild("Cash")
local Rebirths = Leaderstats:WaitForChild("Rebirths")
local GetLuckyBlockShopState = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("GetLuckyBlockShopState")
local BuyLuckyBlockShopCash = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("BuyLuckyBlockShopCash")
local LuckyBlockShopState = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("LuckyBlockShopState")
local LuckyDropEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("LuckyDrop")




-- Remotes (renamed to avoid conflicts)
local RemoteRebirth = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Rebirth")
local RemoteClick = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ClickBrainrot")
local BuyUpgrade      = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("BuyUpgrade")
local GetUpgradeState = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("GetUpgradeState")

-- State
local Spamming = false
local AutoRebirth = false
local AntiAFKThread = nil
local AntiAFKActive = false
local LuckyShopDropdown = nil
local AutoLuckyActive = false
local ShopNextRefreshAt = 0
local SelectDropdown    = nil
local AutoUpgradeActive = false
local SelectedUpgrades  = {}
local UpgradeNames      = {}
local UpgradeDropdown   = nil

-- Executor safety
local setclipboard = setclipboard or clipboard and clipboard.set or function() end
local getgenv = getgenv or function() return _G end
local loadstring = loadstring or function() return function() end end

WindUI:AddTheme({
    Name = "m",

    Accent = WindUI:Gradient({
        ["0"] = { Color = Color3.fromHex("#ffffff"), Transparency = 0 },
        ["20"] = { Color = Color3.fromHex("#d9d9d9"), Transparency = 0 },
        ["40"] = { Color = Color3.fromHex("#a6a6a6"), Transparency = 0 },
        ["60"] = { Color = Color3.fromHex("#6e6e6e"), Transparency = 0 },
        ["80"] = { Color = Color3.fromHex("#3a3a3a"), Transparency = 0 },
        ["100"] = { Color = Color3.fromHex("#1a1a1a"), Transparency = 0 },
    }, { Rotation = 90 }),

    Background = WindUI:Gradient({
        ["0"] = { Color = Color3.fromHex("#0f0f10"), Transparency = 0 },
        ["20"] = { Color = Color3.fromHex("#0b0b0c"), Transparency = 0 },
        ["40"] = { Color = Color3.fromHex("#080809"), Transparency = 0 },
        ["60"] = { Color = Color3.fromHex("#060607"), Transparency = 0 },
        ["80"] = { Color = Color3.fromHex("#050506"), Transparency = 0 },
        ["100"] = { Color = Color3.fromHex("#040405"), Transparency = 0 },
    }, { Rotation = 90 }),

    BackgroundTransparency = 0,

    Outline = WindUI:Gradient({
        ["0"] = { Color = Color3.fromHex("#3a3a3a"), Transparency = 0 },
        ["100"] = { Color = Color3.fromHex("#1c1c1c"), Transparency = 0 },
    }, { Rotation = 90 }),

    Text = WindUI:Gradient({
        ["0"] = { Color = Color3.fromHex("#ffffff"), Transparency = 0 },
        ["50"] = { Color = Color3.fromHex("#bdbdbd"), Transparency = 0 },
        ["100"] = { Color = Color3.fromHex("#7a7a7a"), Transparency = 0 },
    }, { Rotation = 90 }),

    Placeholder = Color3.fromHex("#8a8a8a"),

    Button = WindUI:Gradient({
        ["0"] = { Color = Color3.fromHex("#2b2b2b"), Transparency = 0 },
        ["20"] = { Color = Color3.fromHex("#242424"), Transparency = 0 },
        ["40"] = { Color = Color3.fromHex("#1f1f1f"), Transparency = 0 },
        ["60"] = { Color = Color3.fromHex("#1a1a1a"), Transparency = 0 },
        ["80"] = { Color = Color3.fromHex("#151515"), Transparency = 0 },
        ["100"] = { Color = Color3.fromHex("#101010"), Transparency = 0 },
    }, { Rotation = 90 }),

    Icon = WindUI:Gradient({
        ["0"] = { Color = Color3.fromHex("#ffffff"), Transparency = 0 },
        ["50"] = { Color = Color3.fromHex("#bdbdbd"), Transparency = 0 },
        ["100"] = { Color = Color3.fromHex("#7a7a7a"), Transparency = 0 },
    }, { Rotation = 90 }),

    Hover = Color3.fromHex("#3a3a3a"),

    WindowBackground = WindUI:Gradient({
        ["0"] = { Color = Color3.fromHex("#1a1a1a"), Transparency = 0 },
        ["25"] = { Color = Color3.fromHex("#141414"), Transparency = 0 },
        ["50"] = { Color = Color3.fromHex("#101010"), Transparency = 0 },
        ["75"] = { Color = Color3.fromHex("#0c0c0c"), Transparency = 0 },
        ["100"] = { Color = Color3.fromHex("#090909"), Transparency = 0 },
    }, { Rotation = 90 }),

    WindowShadow = Color3.fromHex("#000000"),

    DialogBackground = WindUI:Gradient({
        ["0"] = { Color = Color3.fromHex("#202020"), Transparency = 0 },
        ["50"] = { Color = Color3.fromHex("#161616"), Transparency = 0 },
        ["100"] = { Color = Color3.fromHex("#101010"), Transparency = 0 },
    }, { Rotation = 90 }),

    DialogBackgroundTransparency = 0,

    DialogTitle = WindUI:Gradient({
        ["0"] = { Color = Color3.fromHex("#ffffff"), Transparency = 0 },
        ["100"] = { Color = Color3.fromHex("#d0d0d0"), Transparency = 0 },
    }, { Rotation = 90 }),

    DialogContent = Color3.fromHex("#b5b5b5"),
    DialogIcon = Color3.fromHex("#8a8a8a"),

    WindowTopbarTitle = WindUI:Gradient({
        ["0"] = { Color = Color3.fromHex("#ffffff"), Transparency = 0 },
        ["100"] = { Color = Color3.fromHex("#cfcfcf"), Transparency = 0 },
    }, { Rotation = 90 }),

    WindowTopbarAuthor = Color3.fromHex("#8a8a8a"),
    WindowTopbarIcon = Color3.fromHex("#cfcfcf"),

    TabBackground = WindUI:Gradient({
        ["0"] = { Color = Color3.fromHex("#2a2a2a"), Transparency = 0 },
        ["50"] = { Color = Color3.fromHex("#1f1f1f"), Transparency = 0 },
        ["100"] = { Color = Color3.fromHex("#141414"), Transparency = 0 },
    }, { Rotation = 90 }),

    TabTitle = WindUI:Gradient({
        ["0"] = { Color = Color3.fromHex("#ffffff"), Transparency = 0 },
        ["100"] = { Color = Color3.fromHex("#cfcfcf"), Transparency = 0 },
    }, { Rotation = 90 }),

    TabIcon = Color3.fromHex("#a8a8a8"),

    ElementBackground = WindUI:Gradient({
        ["0"] = { Color = Color3.fromHex("#2e2e2e"), Transparency = 0 },
        ["25"] = { Color = Color3.fromHex("#242424"), Transparency = 0 },
        ["50"] = { Color = Color3.fromHex("#1c1c1c"), Transparency = 0 },
        ["75"] = { Color = Color3.fromHex("#151515"), Transparency = 0 },
        ["100"] = { Color = Color3.fromHex("#101010"), Transparency = 0 },
    }, { Rotation = 90 }),

    ElementTitle = WindUI:Gradient({
        ["0"] = { Color = Color3.fromHex("#ffffff"), Transparency = 0 },
        ["100"] = { Color = Color3.fromHex("#cfcfcf"), Transparency = 0 },
    }, { Rotation = 90 }),

    ElementDesc = Color3.fromHex("#9a9a9a"),
    ElementIcon = Color3.fromHex("#b5b5b5"),

    PopupBackground = WindUI:Gradient({
        ["0"] = { Color = Color3.fromHex("#222222"), Transparency = 0 },
        ["50"] = { Color = Color3.fromHex("#181818"), Transparency = 0 },
        ["100"] = { Color = Color3.fromHex("#121212"), Transparency = 0 },
    }, { Rotation = 90 }),

    PopupTitle = WindUI:Gradient({
        ["0"] = { Color = Color3.fromHex("#ffffff"), Transparency = 0 },
        ["100"] = { Color = Color3.fromHex("#cfcfcf"), Transparency = 0 },
    }, { Rotation = 90 }),

    PopupContent = Color3.fromHex("#b5b5b5"),
    PopupIcon = Color3.fromHex("#8a8a8a"),

    Toggle = WindUI:Gradient({
        ["0"] = { Color = Color3.fromHex("#3a3a3a"), Transparency = 0 },
        ["100"] = { Color = Color3.fromHex("#1f1f1f"), Transparency = 0 },
    }, { Rotation = 90 }),

    ToggleBar = Color3.fromHex("#ffffff"),

    Checkbox = WindUI:Gradient({
        ["0"] = { Color = Color3.fromHex("#3a3a3a"), Transparency = 0 },
        ["100"] = { Color = Color3.fromHex("#1f1f1f"), Transparency = 0 },
    }, { Rotation = 90 }),

    CheckboxIcon = Color3.fromHex("#ffffff"),

    Slider = WindUI:Gradient({
        ["0"] = { Color = Color3.fromHex("#3a3a3a"), Transparency = 0 },
        ["100"] = { Color = Color3.fromHex("#1f1f1f"), Transparency = 0 },
    }, { Rotation = 90 }),

    SliderThumb = Color3.fromHex("#ffffff"),
})

WindUI:SetTheme("m")

local Window = WindUI:CreateWindow({
    Title = "KairoxHub",
    Icon = "file-terminal", -- lucide icon
    Author = "by Kairox5858",
    Folder = "KairoxHub",
    
    -- ↓ This all is Optional. You can remove it.
    Size = UDim2.fromOffset(580, 460),
    MinSize = Vector2.new(560, 350),
    MaxSize = Vector2.new(850, 560),
    ToggleKey = Enum.KeyCode.K,
    Transparent = true,
    Theme = "m",
    Resizable = true,
    SideBarWidth = 150,
    BackgroundImageTransparency = 0.3,
    HideSearchBar = true,
    ScrollBarEnabled = false,
    Background = "rbxassetid://74044845995165",


       User = {
        Enabled = true,
        Anonymous = false,

        Callback = function()
            local Players = game:GetService("Players")
            local Player = Players.LocalPlayer

            local Leaderstats = Player:FindFirstChild("leaderstats")

            if not Leaderstats then
                warn("leaderstats not found")
                return
            end

            local Cash = Leaderstats:FindFirstChild("Cash")
            local Rebirths = Leaderstats:FindFirstChild("Rebirths")

            print("Player:", Player.Name)
            print("Cash:", Cash and Cash.Value or 0)
            print("Rebirths:", Rebirths and Rebirths.Value or 0)
        end,
    },

})

Window:EditOpenButton({
    Title = "KairoxHub",
    Icon = "terminal",

    CornerRadius = UDim.new(0, 18),
    StrokeThickness = 3,

    Color = ColorSequence.new(
        Color3.fromHex("#1c1c1f"),
        Color3.fromHex("#2a2a2e")
    ),

    OnlyMobile = false,
    Enabled = true,
    Draggable = true,
})

--FONT
WindUI:SetFont("rbxasset://fonts/families/GothamSSm.json")

Window:Tag({
    Title = "v1.0.0",
    Icon = "info",
    Color = Color3.fromHex("#000000"),
    Radius = 8,
})

Window:Tag({
    Title = "Freemium",
    Icon = "lock",
    Color = Color3.fromHex("#000000"),
    Radius = 8,
})


local Home = Window:Tab({
    Title = "Home",
    Icon = "house", -- optional
    Locked = false,
})

local Welcome = Home:Section({
    Title = "Welcome to KairoxHub",
    Icon = "info",
    Desc = "This is Kairox with freemium features, enjoy!",
})

Home:Space()




local Contact = Home:Section({
    Title = "Contact Us",
    Icon = "mail",
    Desc = "Have questions? Reach out to us!",
})




local function Notify(title, content)
    WindUI:Notify({
        Title = title,
        Content = content,
        Duration = 3,
        Icon = "check",
    })
end

local function OpenLink(url, name)
    if setclipboard then
        setclipboard(url)
    end

    Notify(name, "Link copied to clipboard!")
end

-- DISCORD
Home:Button({
    Title = "Discord Server",
    Color = Color3.fromHex("#5865F2"),
    Justify = "Center",
    IconAlign = "Left",
    Icon = "message-circle",
    Callback = function()
        OpenLink("https://discord.gg/mZqcDZRdwE", "Discord")
    end
})

-- ROBLOX
Home:Button({
    Title = "Roblox Profile",
    Color = Color3.fromHex("#302f2f"),
    Justify = "Center",
    IconAlign = "Left",
    Icon = "gamepad-2",
    Callback = function()
        OpenLink("https://www.roblox.com/users/10813829823/profile", "Roblox")
    end
})

-- YOUTUBE
Home:Button({
    Title = "YouTube Channel",
    Color = Color3.fromHex("#FF0000"),
    Justify = "Center",
    IconAlign = "Left",
    Icon = "youtube",
    Callback = function()
        OpenLink("https://www.youtube.com/@KairoxHubb", "YouTube")
    end
})

-- TIKTOK
Home:Button({
    Title = "TikTok Profile",
    Color = Color3.fromHex("#111111"),
    Justify = "Center",
    IconAlign = "Left",
    Icon = "music",
    Callback = function()
        OpenLink("https://www.tiktok.com/@kairoxhub", "TikTok")
    end
})

local Update = Home:Section({ 
    Title = "UPDATES",
})

local UpdateParra = Home:Paragraph({
    Title = "info",
    Desc = "so we just released v1.0.0 with freemium features, we will be adding more features in the future, stay tuned!",
    Color = Color3.fromHex("#000000"),
    Icon = "info",
    Thumbnail = "rbxassetid://74044845995165",
    ThumbnailSize = 80,
    Locked = false,
})

Home:Select()

local Status = Window:Tab({
    Title = "Status",
    Icon = "activity",
    Locked = false,
})


-- Player Stats
local StatusStats = Status:Paragraph({ Title = "Player Stats", Desc = "Loading...", Icon = "user", Color = Color3.fromHex("#000000") })
 
local function UpdateStatusStats()
    StatusStats:SetDesc("💰 Cash: " .. tostring(Cash.Value) .. "\n🔄 Rebirths: " .. tostring(Rebirths.Value))
end
UpdateStatusStats()
Cash:GetPropertyChangedSignal("Value"):Connect(UpdateStatusStats)
Rebirths:GetPropertyChangedSignal("Value"):Connect(UpdateStatusStats)
 
Status:Space()
 
-- Lucky Shop Restock Countdown
local RestockParagraph = Status:Paragraph({ Title = "Lucky Shop Restock", Desc = "Waiting for shop data...", Icon = "timer", Color = Color3.fromHex("#000000") })
 
task.spawn(function()
    while task.wait(1) do
        if ShopNextRefreshAt > 0 then
            local remaining = math.max(0, ShopNextRefreshAt - os.time())
            if remaining == 0 then
                RestockParagraph:SetDesc("🔃 Restocking now!")
            else
                local mins = math.floor(remaining / 60)
                local secs = remaining % 60
                RestockParagraph:SetDesc(string.format("⏳ Restocks in: %dm %ds", mins, secs))
            end
        else
            RestockParagraph:SetDesc("⏳ Waiting for shop data...")
        end
    end
end)
 
Status:Space()
 



Status:Select() -- Select Tab

local Main = Window:Tab({
    Title = "Main",
    Icon = "box", -- optional
    Locked = false,
})


local MFeatures = Main:Section({ 
    Title = "MAIN FEATURES",
})


local AutoClicker = Main:Toggle({
    Title = "Auto Click OP",
    Desc = "Auto Clicks the Brainrot",
    Icon = "mouse-pointer-click",
    Type = "Toggle",
    Value = false,

    Callback = function(state)
        Spamming = state

        if state then
            task.spawn(function()
                while Spamming do
                    pcall(function()
                        RemoteClick:FireServer()
                    end)

                    task.wait(0.1)
                end
            end)
        end
    end
})

Main:Space()

local Rebirth = Main:Toggle({
    Title = "Auto Rebirth",
    Desc = "Automatically rebirths",
    Icon = "refresh-cw",
    Type = "Toggle",
    Value = false,

    Callback = function(state)
        AutoRebirth = state

        if state then
            task.spawn(function()
                while AutoRebirth do
                    pcall(function()
                        RemoteRebirth:InvokeServer()
                    end)

                    task.wait(0.1)
                end
            end)
        end
    end
})
Main:Space()

local function BuildUpgradeDropdown(levels)
    UpgradeNames = {}
    for upgradeName, _ in pairs(levels) do
        table.insert(UpgradeNames, upgradeName)
        SelectedUpgrades[upgradeName] = true
    end
    table.sort(UpgradeNames)

    if UpgradeDropdown then
        UpgradeDropdown:SetValues(UpgradeNames)
    else
        UpgradeDropdown = Main:Dropdown({
            Title     = "Select Upgrades to Auto Buy",
            Desc      = "Click to toggle each upgrade",
            Icon      = "arrow-up-circle",
            Values    = UpgradeNames,
            Value     = UpgradeNames,
            Multi     = true,
            AllowNone = true,
            Callback  = function(selected)
                SelectedUpgrades = {}
                if type(selected) == "table" then
                    for _, name in ipairs(selected) do
                        SelectedUpgrades[name] = true
                    end
                end
            end
        })
    end
end

-- Fetch upgrade names (separate from shop state fetch)
task.spawn(function()
    local ok, state = pcall(function()
        return GetUpgradeState:InvokeServer()
    end)
    if ok and state and state.levels then
        BuildUpgradeDropdown(state.levels)
    else
        warn("GetUpgradeState failed:", state)
    end
end)

-- Auto Upgrade Toggle
Main:Toggle({
    Title = "Auto Upgrade",
    Desc  = "Continuously buys selected upgrades ATENTION IT WILL BUY IT BUT YOU WHEN YOU STOP YOU NEED TO BUY ONE MANNUALLY SO THE THINGS COUNTS",
    Icon  = "trending-up",
    Type  = "Toggle",
    Value = false,
    Callback = function(state)
        AutoUpgradeActive = state

        if state then
            local count = 0
            for _ in pairs(SelectedUpgrades) do count = count + 1 end

            if count == 0 then
                Notify("Auto Upgrade", "No upgrades selected in dropdown!")
                AutoUpgradeActive = false
                return
            end

            Notify("Auto Upgrade", "Buying " .. count .. " upgrades on loop")

            task.spawn(function()
                while AutoUpgradeActive do
                    for upgradeName, _ in pairs(SelectedUpgrades) do
                        if not AutoUpgradeActive then break end
                        pcall(function()
                            BuyUpgrade:InvokeServer(upgradeName, 1)
                        end)
                        task.wait(0.15)
                    end
                    task.wait(0.1)
                end
            end)
        end
    end
})

Main:Space()

local Shop = Main:Section({ 
    Title = "SHOP",
})



-- ─────────────────────────────────────────────
-- LUCKY BLOCK AUTO BUYER
-- ─────────────────────────────────────────────

local SelectedBlocks = {} -- keyed by star: { [star] = { name, cashPrice } }
local AutoBuyActive = false
local ShopNextRefreshAt = 0



-- Selection dropdown (rebuilt whenever shop updates)
local function BuildSelectionDropdown(offers)
    local values = {}

    for _, offer in ipairs(offers) do
        local name = tostring(offer.name or "Unknown")
        local star = offer.star
        local price = tostring(offer.cashPrice or "?")
        local stock = tonumber(offer.stock) or 0
        local isSelected = SelectedBlocks[star] ~= nil

        table.insert(values, {
            Title = name .. " (" .. star .. "⭐)",
            Desc = "Cost: " .. price .. " | Stock: " .. stock,
            Icon = stock > 0 and "shopping-bag" or "x",
            Callback = function()
                if stock <= 0 then
                    Notify("Lucky Shop", name .. " is out of stock!")
                    return
                end

                local ok, result = pcall(function()
                    return BuyLuckyBlockShopCash:InvokeServer(star)
                end)

                if ok and result and result.success == true then
                    Notify("Lucky Shop", "Bought " .. name .. "!")
                else
                    local msg = (ok and result and result.message) or "Purchase failed!"
                    Notify("Lucky Shop", msg)
                end
            end
        })
    end

    if #values == 0 then
        table.insert(values, {
            Title = "No items available",
            Icon  = "x",
            Callback = function() end
        })
    end

    if SelectDropdown then
        SelectDropdown:SetValues(values)
    else
        SelectDropdown = Main:Dropdown({
            Title  = "Select Blocks to Auto Buy",
            Desc   = "Click to toggle selection",
            Icon   = "shopping-cart",
            Values = values,
        })
    end
end

-- Auto Buy toggle
Main:Toggle({
    Title = "Auto Buy Lucky Blocks",
    Desc  = "Buys your selected lucky blocks on loop",
    Icon  = "zap",
    Type  = "Toggle",
    Value = false,
    Callback = function(state)
        AutoBuyActive = state

        if state then
            task.spawn(function()
                while AutoBuyActive do
                    local hasSomething = false
                    for star, data in pairs(SelectedBlocks) do
                        hasSomething = true
                        local ok, result = pcall(function()
                            return BuyLuckyBlockShopCash:InvokeServer(star)
                        end)
                        if ok and result and result.success == true then
                            Notify("Auto Buy", "Bought: " .. data.name)
                        end
                        task.wait(0.3)
                    end
                    if not hasSomething then
                        task.wait(1)
                    end
                    task.wait(0.5)
                end
            end)
        end
    end
})

-- Hook into shop state fetches to populate the selection dropdown and timer
local function OnShopState(state)
    if not (state and state.unlocked == true and state.offers) then return end

    -- Update restock timer
    ShopNextRefreshAt = tonumber(state.nextRefreshAt) or 0

    -- Build/update selection dropdown
    BuildSelectionDropdown(state.offers)

end

-- Initial fetch
task.spawn(function()
    local ok, state = pcall(function() return GetLuckyBlockShopState:InvokeServer() end)
    if ok and state then
        OnShopState(state)
    else
        Notify("Lucky Shop", "Shop is locked or unavailable")
    end
end)

-- Live updates from server
LuckyBlockShopState.OnClientEvent:Connect(function(state)
    OnShopState(state)
    Notify("Lucky Shop", "Shop refreshed!")
end)


Main:Select()

local Misc = Window:Tab({
    Title = "Misc",
    Icon = "settings", -- optional
    Locked = false,
})



local AntiAFK = Misc:Toggle({
    Title = "Anti-AFK",
    Desc = "Prevents getting kicked for inactivity",
    Icon = "shield-check",
    Type = "Toggle",
    Value = false,
    Callback = function(state)
        if state then
            if not getgenv().AntiAFKLoaded then
                getgenv().AntiAFKLoaded = true
                loadstring(game:HttpGet("https://raw.githubusercontent.com/NoTwistedHere/Roblox/main/AntiAFK.lua"))()
            end
        end
        -- turning off does nothing, script already running
    end
})


-- Define all themes first
local Themes = {
    {
        Name = "Midnight",
        Icon = "moon",
        Desc = "Deep black monochrome",
        Accent = {
            ["0"] = "#ffffff", ["20"] = "#d9d9d9", ["40"] = "#a6a6a6",
            ["60"] = "#6e6e6e", ["80"] = "#3a3a3a", ["100"] = "#1a1a1a"
        },
        Background = { ["0"] = "#0f0f10", ["100"] = "#040405" },
        Window = { ["0"] = "#1a1a1a", ["100"] = "#090909" },
        Element = { ["0"] = "#2e2e2e", ["100"] = "#101010" },
        Button = { ["0"] = "#2b2b2b", ["100"] = "#101010" },
        Toggle = { ["0"] = "#3a3a3a", ["100"] = "#1f1f1f" },
    },
    {
        Name = "Ocean",
        Icon = "waves",
        Desc = "Cool deep blue",
        Accent = {
            ["0"] = "#7dd3fc", ["20"] = "#38bdf8", ["40"] = "#0ea5e9",
            ["60"] = "#0284c7", ["80"] = "#0369a1", ["100"] = "#075985"
        },
        Background = { ["0"] = "#0c1929", ["100"] = "#060e18" },
        Window = { ["0"] = "#0f2133", ["100"] = "#080f1a" },
        Element = { ["0"] = "#163045", ["100"] = "#0a1a28" },
        Button = { ["0"] = "#1e3a52", ["100"] = "#0d2035" },
        Toggle = { ["0"] = "#1e4060", ["100"] = "#0d2035" },
    },
    {
        Name = "Violet",
        Icon = "sparkles",
        Desc = "Rich purple vibes",
        Accent = {
            ["0"] = "#e9d5ff", ["20"] = "#c084fc", ["40"] = "#a855f7",
            ["60"] = "#9333ea", ["80"] = "#7e22ce", ["100"] = "#581c87"
        },
        Background = { ["0"] = "#120a1e", ["100"] = "#080510" },
        Window = { ["0"] = "#1a0f2e", ["100"] = "#0d0718" },
        Element = { ["0"] = "#27153f", ["100"] = "#120a22" },
        Button = { ["0"] = "#321a52", ["100"] = "#1a0d30" },
        Toggle = { ["0"] = "#3b1f5e", ["100"] = "#1e0f35" },
    },
    {
        Name = "Ember",
        Icon = "flame",
        Desc = "Warm red & orange",
        Accent = {
            ["0"] = "#fca5a5", ["20"] = "#f87171", ["40"] = "#ef4444",
            ["60"] = "#dc2626", ["80"] = "#b91c1c", ["100"] = "#7f1d1d"
        },
        Background = { ["0"] = "#1c0a0a", ["100"] = "#0d0404" },
        Window = { ["0"] = "#2a0d0d", ["100"] = "#120606" },
        Element = { ["0"] = "#3a1111", ["100"] = "#1a0808" },
        Button = { ["0"] = "#4a1515", ["100"] = "#220a0a" },
        Toggle = { ["0"] = "#5a1a1a", ["100"] = "#2a0d0d" },
    },
    {
        Name = "Forest",
        Icon = "tree-pine",
        Desc = "Natural dark green",
        Accent = {
            ["0"] = "#86efac", ["20"] = "#4ade80", ["40"] = "#22c55e",
            ["60"] = "#16a34a", ["80"] = "#15803d", ["100"] = "#14532d"
        },
        Background = { ["0"] = "#0a1a0e", ["100"] = "#050d07" },
        Window = { ["0"] = "#0d2211", ["100"] = "#071208" },
        Element = { ["0"] = "#123018", ["100"] = "#08180c" },
        Button = { ["0"] = "#173d1e", ["100"] = "#0a2011" },
        Toggle = { ["0"] = "#1a4a23", ["100"] = "#0d2814" },
    },
    {
        Name = "Gold",
        Icon = "crown",
        Desc = "Luxe amber & gold",
        Accent = {
            ["0"] = "#fde68a", ["20"] = "#fbbf24", ["40"] = "#f59e0b",
            ["60"] = "#d97706", ["80"] = "#b45309", ["100"] = "#78350f"
        },
        Background = { ["0"] = "#1a1206", ["100"] = "#0d0903" },
        Window = { ["0"] = "#251a08", ["100"] = "#120d04" },
        Element = { ["0"] = "#33230a", ["100"] = "#1a1206" },
        Button = { ["0"] = "#42300e", ["100"] = "#221808" },
        Toggle = { ["0"] = "#503c12", ["100"] = "#28200a" },
    },
    {
        Name = "Arctic",
        Icon = "snowflake",
        Desc = "Icy cyan & white",
        Accent = {
            ["0"] = "#ffffff", ["20"] = "#e0f7fa", ["40"] = "#80deea",
            ["60"] = "#26c6da", ["80"] = "#0097a7", ["100"] = "#006064"
        },
        Background = { ["0"] = "#08141a", ["100"] = "#040a0d" },
        Window = { ["0"] = "#0d1f29", ["100"] = "#060f14" },
        Element = { ["0"] = "#122d3d", ["100"] = "#081822" },
        Button = { ["0"] = "#183a4f", ["100"] = "#0a2030" },
        Toggle = { ["0"] = "#1e4860", ["100"] = "#0d2838" },
    },
}

-- Helper to build and apply a theme
local function ApplyTheme(t)
    local function G(colors, rot)
        local tbl = {}
        for k, hex in pairs(colors) do
            tbl[k] = { Color = Color3.fromHex(hex), Transparency = 0 }
        end
        return WindUI:Gradient(tbl, { Rotation = rot or 90 })
    end

    WindUI:AddTheme({
        Name = t.Name,
        Accent          = G(t.Accent, 135),
        Background      = G(t.Background),
        BackgroundTransparency = 0,
        Outline         = G({ ["0"] = "#3a3a3a", ["100"] = "#1c1c1c" }),
        Text            = G({ ["0"] = "#ffffff", ["50"] = "#cccccc", ["100"] = "#888888" }),
        Placeholder     = Color3.fromHex("#8a8a8a"),
        Button          = G(t.Button),
        Icon            = G({ ["0"] = "#ffffff", ["50"] = "#bbbbbb", ["100"] = "#888888" }),
        Hover           = Color3.fromHex("#3a3a3a"),
        WindowBackground = G(t.Window),
        WindowShadow    = Color3.fromHex("#000000"),
        DialogBackground = G(t.Element),
        DialogBackgroundTransparency = 0,
        DialogTitle     = G({ ["0"] = "#ffffff", ["100"] = "#d0d0d0" }),
        DialogContent   = Color3.fromHex("#b5b5b5"),
        DialogIcon      = Color3.fromHex("#8a8a8a"),
        WindowTopbarTitle  = G({ ["0"] = "#ffffff", ["100"] = "#cfcfcf" }),
        WindowTopbarAuthor = Color3.fromHex("#8a8a8a"),
        WindowTopbarIcon   = Color3.fromHex("#cfcfcf"),
        TabBackground   = G(t.Element),
        TabTitle        = G({ ["0"] = "#ffffff", ["100"] = "#cfcfcf" }),
        TabIcon         = Color3.fromHex("#a8a8a8"),
        ElementBackground = G(t.Element),
        ElementTitle    = G({ ["0"] = "#ffffff", ["100"] = "#cfcfcf" }),
        ElementDesc     = Color3.fromHex("#9a9a9a"),
        ElementIcon     = Color3.fromHex("#b5b5b5"),
        PopupBackground = G(t.Window),
        PopupTitle      = G({ ["0"] = "#ffffff", ["100"] = "#cfcfcf" }),
        PopupContent    = Color3.fromHex("#b5b5b5"),
        PopupIcon       = Color3.fromHex("#8a8a8a"),
        Toggle          = G(t.Toggle),
        ToggleBar       = Color3.fromHex("#ffffff"),
        Checkbox        = G(t.Toggle),
        CheckboxIcon    = Color3.fromHex("#ffffff"),
        Slider          = G(t.Toggle),
        SliderThumb     = Color3.fromHex("#ffffff"),
    })

    WindUI:SetTheme(t.Name)

    WindUI:Notify({
        Title = "Theme Applied",
        Content = t.Name .. " — " .. t.Desc,
        Duration = 3,
        Icon = t.Icon,
    })
end

-- Build dropdown values from themes
local DropdownValues = {}
for _, t in ipairs(Themes) do
    table.insert(DropdownValues, {
        Title = t.Name,
        Desc = t.Desc,
        Icon = t.Icon,
        Callback = function()
            ApplyTheme(t)
        end
    })
end

-- Dropdown
local ThemeDropdown = Misc:Dropdown({
    Title = "Color Theme",
    Desc = "Pick a UI color theme",
    Icon = "palette",
    Values = DropdownValues,
})

-- Apply default theme on load
ApplyTheme(Themes[1])


local isDesktop = UserInputService.KeyboardEnabled
local debounce = false

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode ~= Enum.KeyCode.K then return end
    if debounce then return end

    debounce = true

    -- wait a frame so WindUI toggles first
    task.wait(0.1)

    -- 🔥 assume it's CLOSED after pressing K
    if isDesktop then
        WindUI:Notify({
            Title = "KairoxHub",
            Content = "Press [K] to open the UI again",
            Duration = 4,
            Icon = "keyboard",
        })
    end

    task.wait(0.3)
    debounce = false
end)


local FirstTime = not getgenv().KairoxHubJoinedBefore

if FirstTime then
    getgenv().KairoxHubJoinedBefore = true

    WindUI:Notify({
        Title = "Welcome to KairoxHub!",
        Content = "Enjoy your experience!",
        Duration = 5,
        Icon = "sparkles",
    })
else
    WindUI:Notify({
        Title = "Welcome back to KairoxHub!",
        Content = "Glad to see you again!",
        Duration = 5,
        Icon = "refresh-cw",
    })
end
