local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()



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
    },
    

})

--FONT
WindUI:SetFont("rbxasset://fonts/families/GothamSSm.json")

Window:Tag({
    Title = "v1.0.0",
    Icon = "info",
    Color = Color3.fromHex("#ffffff"),
    Radius = 8,
})

Window:Tag({
    Title = "Freemium",
    Icon = "lock",
    Color = Color3.fromHex("ffffff"),
    Radius = 8,
})

local RunService = game:GetService("RunService")

local fps = 0

RunService.RenderStepped:Connect(function(dt)
    fps = math.floor(1 / dt)
end)

local tag = Window:Tag({
    Title = "FPS: 0",
    Icon = "activity",
    Color = Color3.fromHex("#ffffff"),
    Radius = 8,
})

task.spawn(function()
    while task.wait(0.5) do
        if tag and tag.SetTitle then
            tag:SetTitle("FPS: " .. fps)
        end

        if tag and tag.SetColor then
            if fps >= 60 then
                tag:SetColor(Color3.fromHex("#ffffff"))
            elseif fps >= 30 then
                tag:SetColor(Color3.fromHex("#ffffff"))
            else
                tag:SetColor(Color3.fromHex("#ffffff"))
            end
        end
    end
end)

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

