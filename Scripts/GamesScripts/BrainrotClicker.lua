--[[
╔══════════════════════════════════════════════════════════════════════════════╗
║             K A I R O X   H U B  —  C I N E M A T I C  L O A D            ║
║                  LocalScript  →  place in ReplicatedFirst                   ║
╚══════════════════════════════════════════════════════════════════════════════╝

  FEATURES:
  ▸ Fully transparent background — blurred game world shows through
  ▸ 55-particle floating field with individual pulse & drift
  ▸ Animated screen-wide scanline + internal card scanline
  ▸ Subtle world-space grid overlay
  ▸ Vignette edges (no solid backdrop, just dark corners)
  ▸ Large soft glow orb pulsing behind the card
  ▸ Glassmorphism card: bg asset + WindUI gradient + scrim
  ▸ Top-edge highlight line + UIStroke border
  ▸ Four animated corner bracket decorations
  ▸ KAIROX — letter-by-letter staggered reveal with gradient
  ▸ HUB pill  •  LIVE pill (pulsing)  •  version pill
  ▸ Animated separator with a sliding dot
  ▸ 10-segment progress bar + smooth gradient fill overlay
  ▸ Shimmer sweep on bar fill
  ▸ Glow dot tracks the right edge of the fill
  ▸ Live % counter via Heartbeat
  ▸ 6-step indicator dots with labels
  ▸ Status text crossfade between phases
  ▸ Tip bar cycling every 4 s
  ▸ Card entrance (slide up + CanvasGroup fade)
  ▸ Epic exit (card fires upward, particles scatter, blur dissolves)
--]]

-- ── Services ──────────────────────────────────────────────────────────────────
local Players         = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local TweenService    = game:GetService("TweenService")
local RunService      = game:GetService("RunService")
local Lighting        = game:GetService("Lighting")

ReplicatedFirst:RemoveDefaultLoadingScreen()

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ── Fonts ─────────────────────────────────────────────────────────────────────
local FAM    = "rbxasset://fonts/families/GothamSSm.json"
local F_REG  = Font.new(FAM, Enum.FontWeight.Regular, Enum.FontStyle.Normal)
local F_BOLD = Font.new(FAM, Enum.FontWeight.Bold,    Enum.FontStyle.Normal)
local F_HVY  = Font.new(FAM, Enum.FontWeight.Heavy,   Enum.FontStyle.Normal)

-- ── Constants ─────────────────────────────────────────────────────────────────
local CARD_W    = 560
local CARD_H    = 365
local SEG_COUNT = 10
local SEG_GAP   = 3
local BAR_H     = 6
local RNG       = Random.new()

local TIPS = {
    "Tip: Use /cmds to view all available commands",
    "Tip: Join our Discord server for early updates",
    "Tip: KAIROX HUB receives weekly content drops",
    "Tip: Report bugs so we can patch them fast",
    "Tip: Check the changelog for what's new today",
}

local STEPS_DATA = {
    { pct = 0.10, msg = "Booting KAIROX engine…",         step = 1, delay = 0.55 },
    { pct = 0.28, msg = "Fetching asset manifests…",      step = 2, delay = 0.80 },
    { pct = 0.47, msg = "Connecting to game servers…",    step = 3, delay = 0.70 },
    { pct = 0.65, msg = "Hydrating your player session…", step = 4, delay = 0.75 },
    { pct = 0.83, msg = "Rendering final layers…",        step = 5, delay = 0.60 },
    { pct = 1.00, msg = "Welcome to KAIROX HUB  ✦",       step = 6, delay = 0.00 },
}

local STEP_LABELS = { "INIT", "ASSETS", "NET", "DATA", "RENDER", "READY" }

-- ── Helpers ───────────────────────────────────────────────────────────────────
local function tw(obj, t, style, dir, props)
    local tween = TweenService:Create(obj,
        TweenInfo.new(t, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out),
        props)
    tween:Play()
    return tween
end

local function corner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 12)
    c.Parent = p
end

local function grad(parent, rot, colorKPs, transKPs)
    local g = Instance.new("UIGradient")
    g.Rotation = rot or 0
    g.Color    = ColorSequence.new(colorKPs)
    if transKPs then g.Transparency = NumberSequence.new(transKPs) end
    g.Parent = parent
end

local function stroke(p, color, thick, trans)
    local s = Instance.new("UIStroke")
    s.Color           = color or Color3.new(1,1,1)
    s.Thickness       = thick or 1
    s.Transparency    = trans or 0.7
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = p
end

local function newFrame(parent, props)
    local f = Instance.new("Frame")
    f.BorderSizePixel        = 0
    f.BackgroundTransparency = 1
    for k, v in pairs(props or {}) do f[k] = v end
    f.Parent = parent
    return f
end

local function newLabel(parent, props)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.BorderSizePixel        = 0
    for k, v in pairs(props or {}) do l[k] = v end
    l.Parent = parent
    return l
end

local function hlist(parent, padding)
    local ll = Instance.new("UIListLayout")
    ll.FillDirection     = Enum.FillDirection.Horizontal
    ll.Padding           = UDim.new(0, padding or 6)
    ll.VerticalAlignment = Enum.VerticalAlignment.Center
    ll.Parent = parent
end

-- ══════════════════════════════════════════════════════════════════════════════
-- BLUR  (game world visible through the UI)
-- ══════════════════════════════════════════════════════════════════════════════
local blur = Instance.new("BlurEffect")
blur.Size   = 0
blur.Parent = Lighting
tw(blur, 1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { Size = 44 })

-- ══════════════════════════════════════════════════════════════════════════════
-- SCREENGUI  (transparent — Roblox world shows through!)
-- ══════════════════════════════════════════════════════════════════════════════
local gui = Instance.new("ScreenGui")
gui.Name           = "KairoxHub_Loading"
gui.IgnoreGuiInset = true
gui.DisplayOrder   = 999
gui.ResetOnSpawn   = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent         = playerGui

local root = newFrame(gui, { Size = UDim2.fromScale(1,1), ZIndex = 1 })

-- ══════════════════════════════════════════════════════════════════════════════
-- VIGNETTE  (4 dark edge panels — no solid backdrop)
-- ══════════════════════════════════════════════════════════════════════════════
local function vignette(size, pos, rot)
    local f = newFrame(root, {
        Size = size, Position = pos,
        BackgroundColor3 = Color3.fromHex("#000000"),
        BackgroundTransparency = 0,
        ZIndex = 2,
    })
    grad(f, rot, {
        ColorSequenceKeypoint.new(0, Color3.fromHex("#000000")),
        ColorSequenceKeypoint.new(1, Color3.fromHex("#000000")),
    }, {
        NumberSequenceKeypoint.new(0, 0.0),
        NumberSequenceKeypoint.new(1, 1.0),
    })
end

vignette(UDim2.new(1,0,0.38,0), UDim2.fromScale(0,0),    90)
vignette(UDim2.new(1,0,0.38,0), UDim2.new(0,0,0.62,0),  270)
vignette(UDim2.new(0.28,0,1,0), UDim2.fromScale(0,0),     0)
vignette(UDim2.new(0.28,0,1,0), UDim2.new(0.72,0,0,0),  180)

-- ══════════════════════════════════════════════════════════════════════════════
-- GRID OVERLAY  (subtle world-space grid lines)
-- ══════════════════════════════════════════════════════════════════════════════
local gridCon = newFrame(root, { Size = UDim2.fromScale(1,1), ZIndex = 3 })

for col = 1, 13 do
    newFrame(gridCon, {
        Size = UDim2.new(0,1,1,0),
        Position = UDim2.fromScale(col/14, 0),
        BackgroundColor3 = Color3.fromHex("#ffffff"),
        BackgroundTransparency = 0.955, ZIndex = 3,
    })
end
for row = 1, 8 do
    newFrame(gridCon, {
        Size = UDim2.new(1,0,0,1),
        Position = UDim2.fromScale(0, row/9),
        BackgroundColor3 = Color3.fromHex("#ffffff"),
        BackgroundTransparency = 0.955, ZIndex = 3,
    })
end

-- ══════════════════════════════════════════════════════════════════════════════
-- GLOBAL SCAN LINE
-- ══════════════════════════════════════════════════════════════════════════════
local scanLine = newFrame(root, {
    Size = UDim2.new(1,0,0,2),
    Position = UDim2.fromScale(0,-0.02),
    BackgroundColor3 = Color3.fromHex("#ffffff"),
    BackgroundTransparency = 0,
    ZIndex = 5,
})
grad(scanLine, 0, {
    ColorSequenceKeypoint.new(0,    Color3.fromHex("#000000")),
    ColorSequenceKeypoint.new(0.25, Color3.fromHex("#ffffff")),
    ColorSequenceKeypoint.new(0.75, Color3.fromHex("#ffffff")),
    ColorSequenceKeypoint.new(1,    Color3.fromHex("#000000")),
}, {
    NumberSequenceKeypoint.new(0,    1),
    NumberSequenceKeypoint.new(0.25, 0.78),
    NumberSequenceKeypoint.new(0.75, 0.78),
    NumberSequenceKeypoint.new(1,    1),
})

-- ══════════════════════════════════════════════════════════════════════════════
-- SOFT GLOW ORB  (behind the card)
-- ══════════════════════════════════════════════════════════════════════════════
local glowOrb = Instance.new("ImageLabel")
glowOrb.Size                = UDim2.fromOffset(900, 900)
glowOrb.AnchorPoint         = Vector2.new(0.5, 0.5)
glowOrb.Position            = UDim2.fromScale(0.5, 0.5)
glowOrb.BackgroundTransparency = 1
glowOrb.Image               = "rbxasset://textures/particles/fire_main.dds"
glowOrb.ImageColor3         = Color3.fromHex("#b0b0c8")
glowOrb.ImageTransparency   = 0.91
glowOrb.ScaleType           = Enum.ScaleType.Stretch
glowOrb.ZIndex              = 4
glowOrb.Parent              = root

-- ══════════════════════════════════════════════════════════════════════════════
-- PARTICLE FIELD  (55 floating dots)
-- ══════════════════════════════════════════════════════════════════════════════
local partCon  = newFrame(root, { Size = UDim2.fromScale(1,1), ZIndex = 5 })
local particles = {}

for _ = 1, 55 do
    local sz    = RNG:NextNumber(2, 5)
    local angle = RNG:NextNumber(0, math.pi * 2)
    local speed = RNG:NextNumber(0.25, 1.1)
    local bx    = RNG:NextNumber(0, 1)
    local by    = RNG:NextNumber(0, 1)

    local p = newFrame(partCon, {
        Size = UDim2.fromOffset(sz, sz),
        Position = UDim2.fromScale(bx, by),
        BackgroundColor3 = Color3.fromHex("#ffffff"),
        BackgroundTransparency = RNG:NextNumber(0.55, 0.90),
        ZIndex = 5,
    })
    corner(p, 99)

    table.insert(particles, {
        f        = p,
        dx       = math.cos(angle) * speed,
        dy       = math.sin(angle) * speed,
        bx       = bx,
        by       = by,
        phase    = RNG:NextNumber(0, math.pi * 2),
        pspd     = RNG:NextNumber(0.5, 2.0),
        baseAlph = RNG:NextNumber(0.55, 0.88),
    })
end

-- ══════════════════════════════════════════════════════════════════════════════
-- CANVAS GROUP  (entire card — enables GroupTransparency fade)
-- ══════════════════════════════════════════════════════════════════════════════
local canvas = Instance.new("CanvasGroup")
canvas.Name               = "KairoxCard"
canvas.Size               = UDim2.fromOffset(CARD_W, CARD_H)
canvas.AnchorPoint        = Vector2.new(0.5, 0.5)
canvas.Position           = UDim2.new(0.5, 0, 0.58, 0)
canvas.BackgroundTransparency = 1
canvas.GroupTransparency  = 1
canvas.ZIndex             = 6
canvas.Parent             = root

-- ══════════════════════════════════════════════════════════════════════════════
-- CARD SHELL  (glassmorphism)
-- ══════════════════════════════════════════════════════════════════════════════
local card = newFrame(canvas, {
    Size = UDim2.fromScale(1,1),
    BackgroundColor3 = Color3.fromHex("#0c0c14"),
    BackgroundTransparency = 0.08,
    ZIndex = 1,
})
corner(card, 24)

-- Background asset image
local bgImg = Instance.new("ImageLabel")
bgImg.Size               = UDim2.fromScale(1,1)
bgImg.BackgroundTransparency = 1
bgImg.Image              = "rbxassetid://74044845995165"
bgImg.ImageTransparency  = 0.48
bgImg.ScaleType          = Enum.ScaleType.Crop
bgImg.ZIndex             = 2
bgImg.Parent             = card
corner(bgImg, 24)

-- WindUI-style gradient (exactly as requested)
grad(bgImg, 90, {
    ColorSequenceKeypoint.new(0,    Color3.fromHex("#ffffff")),
    ColorSequenceKeypoint.new(0.50, Color3.fromHex("#bdbdbd")),
    ColorSequenceKeypoint.new(1,    Color3.fromHex("#7a7a7a")),
}, {
    NumberSequenceKeypoint.new(0,    0.52),
    NumberSequenceKeypoint.new(0.50, 0.62),
    NumberSequenceKeypoint.new(1,    0.74),
})

-- Dark scrim for legibility
local scrim = newFrame(card, {
    Size = UDim2.fromScale(1,1),
    BackgroundColor3 = Color3.fromHex("#000000"),
    BackgroundTransparency = 0.32,
    ZIndex = 3,
})
corner(scrim, 24)

-- Top edge highlight line
local topLine = newFrame(card, {
    Size = UDim2.new(0.62,0,0,1),
    AnchorPoint = Vector2.new(0.5, 0),
    Position = UDim2.new(0.5,0,0,1),
    BackgroundColor3 = Color3.fromHex("#ffffff"),
    BackgroundTransparency = 0,
    ZIndex = 8,
})
corner(topLine, 1)
grad(topLine, 0, {
    ColorSequenceKeypoint.new(0,    Color3.fromHex("#000000")),
    ColorSequenceKeypoint.new(0.12, Color3.fromHex("#ffffff")),
    ColorSequenceKeypoint.new(0.88, Color3.fromHex("#ffffff")),
    ColorSequenceKeypoint.new(1,    Color3.fromHex("#000000")),
}, {
    NumberSequenceKeypoint.new(0,    1),
    NumberSequenceKeypoint.new(0.12, 0.05),
    NumberSequenceKeypoint.new(0.88, 0.05),
    NumberSequenceKeypoint.new(1,    1),
})

stroke(card, Color3.fromHex("#ffffff"), 1.2, 0.8)

-- Internal card scan line
local cardScan = newFrame(card, {
    Size = UDim2.new(1,0,0,70),
    Position = UDim2.fromScale(0,-0.25),
    BackgroundColor3 = Color3.fromHex("#ffffff"),
    BackgroundTransparency = 0,
    ZIndex = 7,
})
grad(cardScan, 90, {
    ColorSequenceKeypoint.new(0,   Color3.fromHex("#000000")),
    ColorSequenceKeypoint.new(0.5, Color3.fromHex("#ffffff")),
    ColorSequenceKeypoint.new(1,   Color3.fromHex("#000000")),
}, {
    NumberSequenceKeypoint.new(0,   1),
    NumberSequenceKeypoint.new(0.3, 0.90),
    NumberSequenceKeypoint.new(0.5, 0.86),
    NumberSequenceKeypoint.new(0.7, 0.90),
    NumberSequenceKeypoint.new(1,   1),
})

-- ══════════════════════════════════════════════════════════════════════════════
-- CORNER BRACKETS
-- ══════════════════════════════════════════════════════════════════════════════
local function bracket(ax, ay, px, py, ox, oy)
    local LEN, THICK = 22, 2
    local C, T = Color3.fromHex("#ffffff"), 0.48

    local con = newFrame(canvas, {
        Size = UDim2.fromOffset(LEN+THICK, LEN+THICK),
        AnchorPoint = Vector2.new(ax, ay),
        Position = UDim2.new(px, ox, py, oy),
        ZIndex = 9,
    })

    local h = newFrame(con, {
        Size = UDim2.fromOffset(LEN, THICK),
        AnchorPoint = Vector2.new(ax, ay),
        Position = UDim2.new(ax,0, ay,0),
        BackgroundColor3 = C, BackgroundTransparency = T, ZIndex = 9,
    })
    corner(h, 1)

    local v = newFrame(con, {
        Size = UDim2.fromOffset(THICK, LEN),
        AnchorPoint = Vector2.new(ax, ay),
        Position = UDim2.new(ax,0, ay,0),
        BackgroundColor3 = C, BackgroundTransparency = T, ZIndex = 9,
    })
    corner(v, 1)
end

bracket(0,0, 0,0,  10, 10)
bracket(1,0, 1,0, -10, 10)
bracket(0,1, 0,1,  10,-10)
bracket(1,1, 1,1, -10,-10)

-- ══════════════════════════════════════════════════════════════════════════════
-- CONTENT  (inner padding)
-- ══════════════════════════════════════════════════════════════════════════════
local content = newFrame(canvas, {
    Size = UDim2.new(1,-64,1,-50),
    Position = UDim2.fromOffset(32, 28),
    ZIndex = 10,
})

-- ══════════════════════════════════════════════════════════════════════════════
-- LOGO  — K A I R O X  (letter-by-letter stagger + WindUI gradient)
-- ══════════════════════════════════════════════════════════════════════════════
local LETTERS  = {"K","A","I","R","O","X"}
local LWIDTH   = 58
local logoWrap = newFrame(content, {
    Size = UDim2.fromOffset(#LETTERS * LWIDTH, 80),
    Position = UDim2.fromOffset(0, 0),
    ZIndex = 10,
})

local letterLabels = {}
for i, ch in ipairs(LETTERS) do
    local lbl = newLabel(logoWrap, {
        Size = UDim2.fromOffset(LWIDTH, 80),
        Position = UDim2.fromOffset((i-1)*LWIDTH, 12),
        Text = ch,
        TextColor3 = Color3.fromHex("#ffffff"),
        TextSize = 74,
        FontFace = F_HVY,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextTransparency = 1,
        ZIndex = 11,
    })
    grad(lbl, 90, {
        ColorSequenceKeypoint.new(0,    Color3.fromHex("#ffffff")),
        ColorSequenceKeypoint.new(0.50, Color3.fromHex("#bdbdbd")),
        ColorSequenceKeypoint.new(1,    Color3.fromHex("#7a7a7a")),
    })
    table.insert(letterLabels, lbl)
end

-- ══════════════════════════════════════════════════════════════════════════════
-- PILL ROW  (HUB · LIVE · version)
-- ══════════════════════════════════════════════════════════════════════════════
local pillRow = newFrame(content, {
    Size = UDim2.new(1,0,0,26),
    Position = UDim2.fromOffset(2, 84),
    ZIndex = 10,
})
hlist(pillRow, 8)

local function makePill(parent, text, bgHex, textHex, strokeHex, strokeT)
    local p = newFrame(parent, {
        Size = UDim2.fromOffset(0, 24),
        BackgroundColor3 = Color3.fromHex(bgHex),
        BackgroundTransparency = 0,
        AutomaticSize = Enum.AutomaticSize.X,
        ZIndex = 11,
    })
    corner(p, 6)

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft  = UDim.new(0, 10)
    pad.PaddingRight = UDim.new(0, 10)
    pad.Parent = p

    local lbl = newLabel(p, {
        Size = UDim2.fromScale(1,1),
        Text = text, TextColor3 = Color3.fromHex(textHex),
        TextSize = 11, FontFace = F_BOLD, ZIndex = 12,
    })
    if strokeHex then
        stroke(p, Color3.fromHex(strokeHex), 1, strokeT or 0.5)
    end
    return p, lbl
end

-- HUB pill with WindUI gradient
local hubPill = makePill(pillRow, "HUB", "#ffffff", "#111118")
grad(hubPill, 90, {
    ColorSequenceKeypoint.new(0,    Color3.fromHex("#ffffff")),
    ColorSequenceKeypoint.new(0.50, Color3.fromHex("#bdbdbd")),
    ColorSequenceKeypoint.new(1,    Color3.fromHex("#7a7a7a")),
})

-- LIVE pill
local _, liveText = makePill(pillRow, "● LIVE", "#0d1220", "#44dd66", "#44dd66", 0.45)

-- Version pill
makePill(pillRow, "v2.0  BETA", "#0d0d1a", "#7070aa", "#ffffff", 0.82)

-- ══════════════════════════════════════════════════════════════════════════════
-- SEPARATOR  + sliding dot
-- ══════════════════════════════════════════════════════════════════════════════
local sep = newFrame(content, {
    Size = UDim2.new(1,0,0,1),
    Position = UDim2.fromOffset(0, 123),
    BackgroundColor3 = Color3.fromHex("#ffffff"),
    BackgroundTransparency = 0,
    ZIndex = 10,
})
corner(sep, 1)
grad(sep, 0, {
    ColorSequenceKeypoint.new(0,    Color3.fromHex("#000000")),
    ColorSequenceKeypoint.new(0.08, Color3.fromHex("#ffffff")),
    ColorSequenceKeypoint.new(0.92, Color3.fromHex("#ffffff")),
    ColorSequenceKeypoint.new(1,    Color3.fromHex("#000000")),
}, {
    NumberSequenceKeypoint.new(0,    1),
    NumberSequenceKeypoint.new(0.08, 0.62),
    NumberSequenceKeypoint.new(0.92, 0.62),
    NumberSequenceKeypoint.new(1,    1),
})

local sepDot = newFrame(content, {
    Size = UDim2.fromOffset(6,6),
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0,0,0,123),
    BackgroundColor3 = Color3.fromHex("#ffffff"),
    BackgroundTransparency = 0.25,
    ZIndex = 11,
})
corner(sepDot, 99)

-- ══════════════════════════════════════════════════════════════════════════════
-- STATUS ROW
-- ══════════════════════════════════════════════════════════════════════════════
local statusLbl = newLabel(content, {
    Size = UDim2.new(0.72,0,0,20),
    Position = UDim2.fromOffset(0, 138),
    Text = "Booting KAIROX engine…",
    TextColor3 = Color3.fromHex("#8888a8"),
    TextSize = 13, FontFace = F_REG,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 11,
})

local pctLbl = newLabel(content, {
    Size = UDim2.new(0.28,0,0,20),
    Position = UDim2.new(0.72,0,0,138),
    Text = "0%",
    TextColor3 = Color3.fromHex("#ffffff"),
    TextSize = 13, FontFace = F_BOLD,
    TextXAlignment = Enum.TextXAlignment.Right,
    ZIndex = 11,
})

-- ══════════════════════════════════════════════════════════════════════════════
-- SEGMENTED PROGRESS BAR  +  smooth fill overlay
-- ══════════════════════════════════════════════════════════════════════════════
local barTrack = newFrame(content, {
    Size = UDim2.new(1,0,0,BAR_H),
    Position = UDim2.fromOffset(0, 164),
    BackgroundColor3 = Color3.fromHex("#ffffff"),
    BackgroundTransparency = 0.91,
    ZIndex = 10,
})
corner(barTrack, 99)

local segLayout = Instance.new("UIListLayout")
segLayout.FillDirection     = Enum.FillDirection.Horizontal
segLayout.Padding           = UDim.new(0, SEG_GAP)
segLayout.VerticalAlignment = Enum.VerticalAlignment.Center
segLayout.Parent            = barTrack

local segFrames = {}
for _ = 1, SEG_COUNT do
    local seg = newFrame(barTrack, {
        Size = UDim2.new(
            1/SEG_COUNT, -math.ceil(SEG_GAP*(SEG_COUNT-1)/SEG_COUNT),
            1, 0),
        BackgroundColor3 = Color3.fromHex("#ffffff"),
        BackgroundTransparency = 0.88,
        ZIndex = 11,
    })
    corner(seg, 99)
    table.insert(segFrames, seg)
end

-- Smooth gradient fill (sits on top of segments)
local barFill = newFrame(content, {
    Size = UDim2.new(0,0,0,BAR_H),
    Position = UDim2.fromOffset(0, 164),
    BackgroundColor3 = Color3.fromHex("#ffffff"),
    BackgroundTransparency = 0,
    ZIndex = 12,
    ClipsDescendants = true,
})
corner(barFill, 99)
grad(barFill, 0, {
    ColorSequenceKeypoint.new(0,    Color3.fromHex("#ffffff")),
    ColorSequenceKeypoint.new(0.50, Color3.fromHex("#bdbdbd")),
    ColorSequenceKeypoint.new(1,    Color3.fromHex("#7a7a7a")),
})

-- Shimmer sweep inside fill
local shimmer = newFrame(barFill, {
    Size = UDim2.fromScale(0.42, 1),
    Position = UDim2.fromScale(-0.55, 0),
    BackgroundColor3 = Color3.fromHex("#ffffff"),
    BackgroundTransparency = 0.45,
    ZIndex = 13,
})
corner(shimmer, 99)
grad(shimmer, 0, {
    ColorSequenceKeypoint.new(0,   Color3.fromHex("#000000")),
    ColorSequenceKeypoint.new(0.5, Color3.fromHex("#ffffff")),
    ColorSequenceKeypoint.new(1,   Color3.fromHex("#000000")),
}, {
    NumberSequenceKeypoint.new(0,   1),
    NumberSequenceKeypoint.new(0.5, 0.28),
    NumberSequenceKeypoint.new(1,   1),
})

-- Leading glow dot at fill right edge
local fillDot = newFrame(content, {
    Size = UDim2.fromOffset(8,8),
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0,0,0,167),
    BackgroundColor3 = Color3.fromHex("#ffffff"),
    BackgroundTransparency = 0.18,
    ZIndex = 13,
})
corner(fillDot, 99)

-- ══════════════════════════════════════════════════════════════════════════════
-- STEP INDICATORS
-- ══════════════════════════════════════════════════════════════════════════════
local stepsRow = newFrame(content, {
    Size = UDim2.new(1,0,0,22),
    Position = UDim2.fromOffset(0, 178),
    ZIndex = 10,
})
hlist(stepsRow, 8)

local stepItems = {}
for _, name in ipairs(STEP_LABELS) do
    local con = newFrame(stepsRow, {
        Size = UDim2.fromOffset(0, 20),
        AutomaticSize = Enum.AutomaticSize.X,
        ZIndex = 11,
    })
    hlist(con, 4)

    local dot = newFrame(con, {
        Size = UDim2.fromOffset(5,5),
        BackgroundColor3 = Color3.fromHex("#ffffff"),
        BackgroundTransparency = 0.88,
        ZIndex = 12,
    })
    corner(dot, 99)

    local lbl = newLabel(con, {
        Size = UDim2.fromOffset(0, 20),
        AutomaticSize = Enum.AutomaticSize.X,
        Text = name,
        TextColor3 = Color3.fromHex("#393950"),
        TextSize = 10, FontFace = F_BOLD,
        ZIndex = 12,
    })

    table.insert(stepItems, { dot = dot, lbl = lbl })
end

-- ══════════════════════════════════════════════════════════════════════════════
-- TIP BAR  (bottom of card)
-- ══════════════════════════════════════════════════════════════════════════════
local tipSep = newFrame(content, {
    Size = UDim2.new(1,0,0,1),
    Position = UDim2.new(0,0,1,-32),
    BackgroundColor3 = Color3.fromHex("#ffffff"),
    BackgroundTransparency = 0.88,
    ZIndex = 10,
})
grad(tipSep, 0, {
    ColorSequenceKeypoint.new(0,    Color3.fromHex("#000000")),
    ColorSequenceKeypoint.new(0.08, Color3.fromHex("#ffffff")),
    ColorSequenceKeypoint.new(0.92, Color3.fromHex("#ffffff")),
    ColorSequenceKeypoint.new(1,    Color3.fromHex("#000000")),
}, {
    NumberSequenceKeypoint.new(0,    1),
    NumberSequenceKeypoint.new(0.08, 0.88),
    NumberSequenceKeypoint.new(0.92, 0.88),
    NumberSequenceKeypoint.new(1,    1),
})

local tipLbl = newLabel(content, {
    Size = UDim2.new(0.72,0,0,20),
    Position = UDim2.new(0,0,1,-24),
    Text = TIPS[1],
    TextColor3 = Color3.fromHex("#4a4a62"),
    TextSize = 11, FontFace = F_REG,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 11,
})

newLabel(content, {
    Size = UDim2.new(0.28,0,0,20),
    Position = UDim2.new(0.72,0,1,-24),
    Text = "© 2025  KAIROX HUB",
    TextColor3 = Color3.fromHex("#2e2e44"),
    TextSize = 11, FontFace = F_REG,
    TextXAlignment = Enum.TextXAlignment.Right,
    ZIndex = 11,
})

-- ══════════════════════════════════════════════════════════════════════════════
-- RUNTIME LOOP  (particles / scanlines / dot glow / live blink)
-- ══════════════════════════════════════════════════════════════════════════════
local alive = true
local clock = 0

RunService.Heartbeat:Connect(function(dt)
    if not alive then return end
    clock += dt

    -- Particle drift + pulse
    for _, p in ipairs(particles) do
        local x = (p.bx + p.dx * clock * 0.016) % 1
        local y = (p.by + p.dy * clock * 0.011) % 1
        p.f.Position = UDim2.fromScale(x, y)
        local a = p.baseAlph + math.sin(clock * p.pspd + p.phase) * 0.07
        p.f.BackgroundTransparency = math.clamp(a, 0.40, 0.96)
    end

    -- Global scan line
    scanLine.Position = UDim2.fromScale(0, (clock * 0.17) % 1.12 - 0.04)

    -- Card internal scan
    cardScan.Position = UDim2.fromScale(0, (clock * 0.10) % 1.35 - 0.22)

    -- Separator travelling dot
    sepDot.Position = UDim2.new((clock * 0.22) % 1, 0, 0, 123)

    -- Fill dot tracks bar right edge
    fillDot.Position = UDim2.new(barFill.Size.X.Scale, -4, 0, 167)

    -- Glow orb breathing
    glowOrb.ImageTransparency = 0.90 + math.sin(clock * 0.65) * 0.03

    -- LIVE blink
    liveText.TextTransparency = math.abs(math.sin(clock * 1.4)) * 0.55
end)

-- Perpetual shimmer sweep
task.spawn(function()
    while alive do
        shimmer.Position = UDim2.fromScale(-0.55, 0)
        local t = TweenService:Create(shimmer,
            TweenInfo.new(1.7, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
            { Position = UDim2.fromScale(1.35, 0) })
        t:Play(); t.Completed:Wait()
        task.wait(0.15)
    end
end)

-- ══════════════════════════════════════════════════════════════════════════════
-- ENTRANCE
-- ══════════════════════════════════════════════════════════════════════════════
task.wait(0.05)
tw(canvas, 0.88, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, {
    GroupTransparency = 0,
    Position          = UDim2.new(0.5, 0, 0.5, 0),
})

-- Letter stagger reveal
task.spawn(function()
    task.wait(0.25)
    for i, lbl in ipairs(letterLabels) do
        task.wait(0.07)
        tw(lbl, 0.48, Enum.EasingStyle.Back, Enum.EasingDirection.Out, {
            TextTransparency = 0,
            Position         = UDim2.fromOffset((i-1)*LWIDTH, 0),
        })
    end
end)

-- Tip cycling
task.spawn(function()
    local ti = 1
    while alive do
        task.wait(4.2)
        tw(tipLbl, 0.18, Enum.EasingStyle.Quad, nil, { TextTransparency = 1 })
        task.wait(0.22)
        ti = (ti % #TIPS) + 1
        tipLbl.Text = TIPS[ti]
        tw(tipLbl, 0.22, Enum.EasingStyle.Quad, nil, { TextTransparency = 0 })
    end
end)

-- ══════════════════════════════════════════════════════════════════════════════
-- PROGRESS ENGINE
-- ══════════════════════════════════════════════════════════════════════════════
local currentPct = 0

local function activateSegments(pct)
    local lit = math.floor(pct * SEG_COUNT + 0.5)
    for i, seg in ipairs(segFrames) do
        if i <= lit then
            tw(seg, 0.28 + i*0.025, Enum.EasingStyle.Quint, nil, {
                BackgroundTransparency = 0.28,
                BackgroundColor3       = Color3.fromHex("#ffffff"),
            })
        end
    end
end

local function activateStep(idx)
    local s = stepItems[idx]
    if not s then return end
    tw(s.dot, 0.38, Enum.EasingStyle.Back, Enum.EasingDirection.Out, {
        BackgroundTransparency = 0,
        Size = UDim2.fromOffset(7,7),
    })
    tw(s.lbl, 0.35, nil, nil, { TextColor3 = Color3.fromHex("#9999cc") })
end

local function setProgress(targetPct, msg, stepIdx)
    tw(barFill, 0.62, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, {
        Size = UDim2.new(targetPct, 0, 0, BAR_H)
    })
    activateSegments(targetPct)

    -- Animated % counter
    local startP  = currentPct
    local elapsed = 0
    local dur     = 0.62
    local con; con = RunService.Heartbeat:Connect(function(dt)
        elapsed += dt
        local a = math.min(elapsed / dur, 1)
        pctLbl.Text = math.floor((startP + (targetPct - startP) * a) * 100) .. "%"
        if a >= 1 then con:Disconnect() end
    end)
    currentPct = targetPct

    tw(statusLbl, 0.15, Enum.EasingStyle.Quad, nil, { TextTransparency = 1 })
    task.wait(0.18)
    statusLbl.Text = msg
    tw(statusLbl, 0.22, Enum.EasingStyle.Quad, nil, { TextTransparency = 0 })

    activateStep(stepIdx)
end

-- ══════════════════════════════════════════════════════════════════════════════
-- MAIN SEQUENCE
-- ══════════════════════════════════════════════════════════════════════════════
task.spawn(function()
    for _, step in ipairs(STEPS_DATA) do
        local wait_time = game:IsLoaded() and (step.delay * 0.28) or step.delay
        task.wait(wait_time)
        setProgress(step.pct, step.msg, step.step)
    end

    if not game:IsLoaded() then game.Loaded:Wait() end
    task.wait(1.15)

    -- ── EXIT ─────────────────────────────────────────────────────────────────
    alive = false

    -- Card fires upward + fades
    tw(canvas, 0.52, Enum.EasingStyle.Quint, Enum.EasingDirection.In, {
        GroupTransparency = 1,
        Position          = UDim2.new(0.5, 0, 0.40, 0),
    })

    tw(scanLine, 0.4, Enum.EasingStyle.Quad, nil, { BackgroundTransparency = 1 })

    -- Particles scatter and vanish
    for _, p in ipairs(particles) do
        tw(p.f, RNG:NextNumber(0.25, 0.65), Enum.EasingStyle.Quad, nil, {
            BackgroundTransparency = 1,
            Size = UDim2.fromOffset(0,0),
        })
    end

    tw(glowOrb, 0.5, Enum.EasingStyle.Quad, nil, { ImageTransparency = 1 })
    tw(blur, 0.85, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { Size = 0 })

    task.wait(0.9)
    gui:Destroy()
    blur:Destroy()
end)

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
