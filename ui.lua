-- ============================================================
--   MXME_Premium UI  |  LocalScript  (StarterPlayerScripts)
--   Bind : RightShift  |  Draggable  |  6 tabs  |  8 slots each
-- ============================================================

local Players        = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService   = game:GetService("TweenService")
local RunService     = game:GetService("RunService")

local LocalPlayer  = Players.LocalPlayer
local PlayerGui    = LocalPlayer:WaitForChild("PlayerGui")

-- ────────────────────────────────────────────────────────────
--  CONSTANTS
-- ────────────────────────────────────────────────────────────
local MENU_SIZE     = UDim2.new(0, 540, 0, 380)
local MENU_POS_OPEN = UDim2.new(0.5, -270, 0.5, -190)
local TWEEN_IN      = TweenInfo.new(0.35, Enum.EasingStyle.Back,   Enum.EasingDirection.Out)
local TWEEN_OUT     = TweenInfo.new(0.25, Enum.EasingStyle.Quart,  Enum.EasingDirection.In)
local ACCENT        = Color3.fromRGB(255, 255, 255)
local BG            = Color3.fromRGB(8,   8,   8)
local TAB_BG        = Color3.fromRGB(13,  13,  13)
local CONTENT_BG    = Color3.fromRGB(11,  11,  11)
local BORDER        = Color3.fromRGB(50,  50,  50)
local TEXT_DIM      = Color3.fromRGB(140, 140, 140)
local SNOWFLAKE_COUNT = 18

-- ────────────────────────────────────────────────────────────
--  TABS  ( name , icon drawn with ImageLabel unicode trick )
--  We use TextLabels with custom "icon" characters rendered
--  via a DrawingLib-style approach – pure GUI, no assets.
-- ────────────────────────────────────────────────────────────
local TABS = {
    { id = "aim",    label = "Aim",    icon = "⊕" },   -- crosshair-like
    { id = "visual", label = "Visual", icon = "◉" },   -- eye-like
    { id = "world",  label = "World",  icon = "◍" },   -- globe-like
    { id = "player", label = "Player", icon = "♟" },   -- human-like
    { id = "config", label = "Config", icon = "⚙" },   -- gear
    { id = "other",  label = "Other",  icon = "…" },   -- dots
}

-- ────────────────────────────────────────────────────────────
--  HELPERS
-- ────────────────────────────────────────────────────────────
local function makeFrame(parent, size, pos, bg, border, zindex)
    local f = Instance.new("Frame")
    f.Size            = size  or UDim2.new(1,0,1,0)
    f.Position        = pos   or UDim2.new(0,0,0,0)
    f.BackgroundColor3 = bg   or BG
    f.BorderSizePixel  = 0
    f.ZIndex           = zindex or 1
    f.Parent           = parent
    if border then
        local stroke = Instance.new("UIStroke")
        stroke.Color     = border
        stroke.Thickness = 0.8
        stroke.Parent    = f
    end
    return f
end

local function makeText(parent, text, size, color, font, pos, textSize, zindex)
    local l = Instance.new("TextLabel")
    l.Size               = size   or UDim2.new(1,0,1,0)
    l.Position           = pos    or UDim2.new(0,0,0,0)
    l.BackgroundTransparency = 1
    l.Text               = text   or ""
    l.TextColor3         = color  or ACCENT
    l.Font               = font   or Enum.Font.GothamBold
    l.TextSize           = textSize or 13
    l.ZIndex             = zindex or 2
    l.Parent             = parent
    return l
end

local function makeCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 4)
    c.Parent = parent
    return c
end

local function makePadding(parent, t,b,l,r)
    local p = Instance.new("UIPadding")
    p.PaddingTop    = UDim.new(0, t or 0)
    p.PaddingBottom = UDim.new(0, b or 0)
    p.PaddingLeft   = UDim.new(0, l or 0)
    p.PaddingRight  = UDim.new(0, r or 0)
    p.Parent = parent
    return p
end

-- ────────────────────────────────────────────────────────────
--  SCREEN GUI
-- ────────────────────────────────────────────────────────────
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name              = "MXME_Premium"
ScreenGui.ResetOnSpawn      = false
ScreenGui.ZIndexBehavior    = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset    = true
ScreenGui.Parent            = PlayerGui

-- ────────────────────────────────────────────────────────────
--  BLUR  (background blur effect behind the whole menu)
-- ────────────────────────────────────────────────────────────
local BlurEffect = Instance.new("BlurEffect")
BlurEffect.Size   = 0
BlurEffect.Parent = game:GetService("Lighting")

-- ────────────────────────────────────────────────────────────
--  BACKDROP  (dark tinted overlay)
-- ────────────────────────────────────────────────────────────
local Backdrop = makeFrame(ScreenGui,
    UDim2.new(1,0,1,0),
    UDim2.new(0,0,0,0),
    Color3.fromRGB(0,0,0), nil, 1)
Backdrop.BackgroundTransparency = 1   -- starts invisible

-- ────────────────────────────────────────────────────────────
--  MAIN MENU FRAME
-- ────────────────────────────────────────────────────────────
local MenuFrame = makeFrame(ScreenGui,
    MENU_SIZE,
    UDim2.new(0.5,-270, 0.5,-190),
    BG, BORDER, 5)
MenuFrame.ClipsDescendants = true
makeCorner(MenuFrame, 6)

-- Subtle inner glow border (white, low opacity)
local InnerGlow = Instance.new("UIStroke")
InnerGlow.Color     = Color3.fromRGB(255,255,255)
InnerGlow.Thickness = 0.5
InnerGlow.Transparency = 0.75
InnerGlow.Parent    = MenuFrame

-- ── Grid noise texture overlay (pure CSS-like dots) ──────────
local NoiseOverlay = makeFrame(MenuFrame,
    UDim2.new(1,0,1,0),
    UDim2.new(0,0,0,0),
    Color3.fromRGB(255,255,255), nil, 6)
NoiseOverlay.BackgroundTransparency = 0.97
NoiseOverlay.ZIndex = 6

-- Radial white glow at center (vignette inverse)
local CenterGlow = makeFrame(MenuFrame,
    UDim2.new(0, 320, 0, 320),
    UDim2.new(0.5, -160, 0.5, -160),
    Color3.fromRGB(255,255,255), nil, 6)
CenterGlow.BackgroundTransparency = 0.97
makeCorner(CenterGlow, 160)

-- ────────────────────────────────────────────────────────────
--  TOP BAR
-- ────────────────────────────────────────────────────────────
local TopBar = makeFrame(MenuFrame,
    UDim2.new(1,0,0,34),
    UDim2.new(0,0,0,0),
    Color3.fromRGB(6,6,6), nil, 7)

-- Title
local TitleLabel = makeText(TopBar,
    "MXME", UDim2.new(0,120,1,0), ACCENT,
    Enum.Font.GothamBold, UDim2.new(0,14,0,0), 14, 8)
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.TextYAlignment = Enum.TextYAlignment.Center

local SubLabel = makeText(TopBar,
    "premium", UDim2.new(0,80,1,0), Color3.fromRGB(180,180,180),
    Enum.Font.Gotham, UDim2.new(0,70,0,0), 10, 8)
SubLabel.TextXAlignment = Enum.TextXAlignment.Left
SubLabel.TextYAlignment = Enum.TextYAlignment.Center

-- Close hint
local HintLabel = makeText(TopBar,
    "[RightShift]", UDim2.new(0,100,1,0),
    Color3.fromRGB(60,60,60), Enum.Font.Gotham,
    UDim2.new(1,-108,0,0), 9, 8)
HintLabel.TextXAlignment = Enum.TextXAlignment.Right

-- Thin separator line under TopBar
local TopSep = makeFrame(MenuFrame,
    UDim2.new(1,0,0,1),
    UDim2.new(0,0,0,34),
    BORDER, nil, 7)

-- ────────────────────────────────────────────────────────────
--  LEFT TAB BAR  (80px wide)
-- ────────────────────────────────────────────────────────────
local TabBar = makeFrame(MenuFrame,
    UDim2.new(0,80,1,-35),
    UDim2.new(0,0,0,35),
    TAB_BG, nil, 7)

-- Right border of tab bar
local TabSep = makeFrame(MenuFrame,
    UDim2.new(0,1,1,-35),
    UDim2.new(0,80,0,35),
    BORDER, nil, 8)

-- ────────────────────────────────────────────────────────────
--  CONTENT AREA  (right of tabs)
-- ────────────────────────────────────────────────────────────
local ContentArea = makeFrame(MenuFrame,
    UDim2.new(1,-81,1,-35),
    UDim2.new(0,81,0,35),
    CONTENT_BG, nil, 7)
ContentArea.ClipsDescendants = true

-- ────────────────────────────────────────────────────────────
--  SNOWFLAKE PARTICLE SYSTEM  (left side of menu)
-- ────────────────────────────────────────────────────────────
local SnowContainer = makeFrame(TabBar,
    UDim2.new(1,0,1,0),
    UDim2.new(0,0,0,0),
    Color3.fromRGB(0,0,0), nil, 9)
SnowContainer.BackgroundTransparency = 1
SnowContainer.ClipsDescendants       = true

local snowflakes = {}
local SNOW_CHARS = {"✦","❄","❅","❆","·","*","·"}

for i = 1, SNOWFLAKE_COUNT do
    local sf = Instance.new("TextLabel")
    sf.BackgroundTransparency = 1
    sf.Size      = UDim2.new(0,14,0,14)
    sf.Position  = UDim2.new(math.random(0,100)/100, 0,
                             -(math.random(10,100)/100), 0)
    sf.Text      = SNOW_CHARS[math.random(#SNOW_CHARS)]
    sf.TextColor3 = Color3.fromRGB(
        math.random(180,255),
        math.random(180,255),
        math.random(180,255))
    sf.TextTransparency = math.random(30,70)/100
    sf.Font      = Enum.Font.Code
    sf.TextSize  = math.random(6,11)
    sf.ZIndex    = 10
    sf.Parent    = SnowContainer

    snowflakes[i] = {
        label  = sf,
        speed  = math.random(18, 45) / 1000,   -- UDim per second
        drift  = math.random(-8, 8)  / 10000,
        wobble = math.random(0, 628) / 100,     -- phase
        amp    = math.random(2, 6)   / 10000,
    }
end

-- ────────────────────────────────────────────────────────────
--  TAB BUTTONS  + CONTENT PAGES
-- ────────────────────────────────────────────────────────────
local tabButtons  = {}
local tabPages    = {}
local activeTab   = nil

local tabListLayout = Instance.new("UIListLayout")
tabListLayout.SortOrder  = Enum.SortOrder.LayoutOrder
tabListLayout.Padding    = UDim.new(0, 2)
tabListLayout.Parent     = TabBar
makePadding(TabBar, 8,8,4,4)

for idx, tabData in ipairs(TABS) do

    -- ── Tab button ──────────────────────────────────────────
    local btn = makeFrame(TabBar,
        UDim2.new(1,-8,0,48),
        UDim2.new(0,4,0,0),
        Color3.fromRGB(0,0,0), nil, 10)
    btn.BackgroundTransparency = 1
    btn.LayoutOrder = idx
    makeCorner(btn, 4)

    -- Active indicator bar (left)
    local activeBar = makeFrame(btn,
        UDim2.new(0,2,0,22),
        UDim2.new(0,0,0.5,-11),
        ACCENT, nil, 12)
    activeBar.Visible = false
    makeCorner(activeBar, 2)

    -- Icon
    local iconLbl = makeText(btn,
        tabData.icon,
        UDim2.new(1,0,0,26),
        TEXT_DIM,
        Enum.Font.Code,
        UDim2.new(0,0,0,6),
        18, 11)
    iconLbl.TextXAlignment = Enum.TextXAlignment.Center

    -- Label
    local nameLbl = makeText(btn,
        tabData.label,
        UDim2.new(1,0,0,14),
        TEXT_DIM,
        Enum.Font.Gotham,
        UDim2.new(0,0,0,28),
        9, 11)
    nameLbl.TextXAlignment = Enum.TextXAlignment.Center

    -- Hover / click regions
    local clickBtn = Instance.new("TextButton")
    clickBtn.Size                = UDim2.new(1,0,1,0)
    clickBtn.BackgroundTransparency = 1
    clickBtn.Text                = ""
    clickBtn.ZIndex              = 13
    clickBtn.Parent              = btn

    tabButtons[tabData.id] = {
        frame     = btn,
        activeBar = activeBar,
        iconLbl   = iconLbl,
        nameLbl   = nameLbl,
        clickBtn  = clickBtn,
    }

    -- ── Content page ────────────────────────────────────────
    local page = makeFrame(ContentArea,
        UDim2.new(1,0,1,0),
        UDim2.new(0,0,0,0),
        Color3.fromRGB(0,0,0), nil, 8)
    page.BackgroundTransparency = 1
    page.Visible = false
    makePadding(page, 12, 12, 14, 14)

    -- Category header
    local catHeader = makeText(page,
        string.upper(tabData.label),
        UDim2.new(1,0,0,20),
        Color3.fromRGB(70,70,70),
        Enum.Font.GothamBold,
        UDim2.new(0,0,0,0),
        9, 9)
    catHeader.TextXAlignment = Enum.TextXAlignment.Left

    -- Thin divider under header
    local divider = makeFrame(page,
        UDim2.new(1,0,0,1),
        UDim2.new(0,0,0,22),
        Color3.fromRGB(28,28,28), nil, 9)

    -- Option list
    local listFrame = makeFrame(page,
        UDim2.new(1,0,1,-30),
        UDim2.new(0,0,0,30),
        Color3.fromRGB(0,0,0), nil, 9)
    listFrame.BackgroundTransparency = 1

    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding   = UDim.new(0, 4)
    listLayout.Parent    = listFrame

    -- 8 "Soon" options per tab
    for opt = 1, 8 do
        local optRow = makeFrame(listFrame,
            UDim2.new(1,0,0,36),
            UDim2.new(0,0,0,0),
            Color3.fromRGB(16,16,16), BORDER, 10)
        optRow.LayoutOrder = opt
        makeCorner(optRow, 3)

        -- Option name
        local optName = makeText(optRow,
            "soon",
            UDim2.new(0.6,0,1,0),
            Color3.fromRGB(80,80,80),
            Enum.Font.GothamBold,
            UDim2.new(0,12,0,0),
            11, 11)
        optName.TextXAlignment = Enum.TextXAlignment.Left

        -- Soon badge
        local badge = makeFrame(optRow,
            UDim2.new(0,44,0,18),
            UDim2.new(1,-56,0.5,-9),
            Color3.fromRGB(22,22,22), BORDER, 11)
        makeCorner(badge, 9)

        local badgeText = makeText(badge,
            "SOON",
            UDim2.new(1,0,1,0),
            Color3.fromRGB(55,55,55),
            Enum.Font.GothamBold,
            UDim2.new(0,0,0,0),
            8, 12)
        badgeText.TextXAlignment = Enum.TextXAlignment.Center
        badgeText.TextYAlignment = Enum.TextYAlignment.Center
    end

    tabPages[tabData.id] = page
end

-- ────────────────────────────────────────────────────────────
--  TAB SWITCHING LOGIC
-- ────────────────────────────────────────────────────────────
local function switchTab(id)
    if activeTab == id then return end

    -- Deactivate old
    if activeTab then
        local old = tabButtons[activeTab]
        old.activeBar.Visible = false
        TweenService:Create(old.iconLbl,
            TweenInfo.new(0.15), {TextColor3 = TEXT_DIM}):Play()
        TweenService:Create(old.nameLbl,
            TweenInfo.new(0.15), {TextColor3 = TEXT_DIM}):Play()
        TweenService:Create(old.frame,
            TweenInfo.new(0.15),
            {BackgroundTransparency = 1}):Play()
        tabPages[activeTab].Visible = false
    end

    -- Activate new
    activeTab = id
    local cur = tabButtons[id]
    cur.activeBar.Visible = true
    TweenService:Create(cur.iconLbl,
        TweenInfo.new(0.15), {TextColor3 = ACCENT}):Play()
    TweenService:Create(cur.nameLbl,
        TweenInfo.new(0.15), {TextColor3 = ACCENT}):Play()
    TweenService:Create(cur.frame,
        TweenInfo.new(0.15),
        {BackgroundTransparency = 0.85}):Play()
    cur.frame.BackgroundColor3 = Color3.fromRGB(255,255,255)
    tabPages[id].Visible = true
end

-- Wire click events
for _, tabData in ipairs(TABS) do
    tabButtons[tabData.id].clickBtn.MouseButton1Click:Connect(function()
        switchTab(tabData.id)
    end)

    -- Hover effect
    tabButtons[tabData.id].clickBtn.MouseEnter:Connect(function()
        if activeTab ~= tabData.id then
            TweenService:Create(tabButtons[tabData.id].iconLbl,
                TweenInfo.new(0.12),
                {TextColor3 = Color3.fromRGB(200,200,200)}):Play()
        end
    end)
    tabButtons[tabData.id].clickBtn.MouseLeave:Connect(function()
        if activeTab ~= tabData.id then
            TweenService:Create(tabButtons[tabData.id].iconLbl,
                TweenInfo.new(0.12),
                {TextColor3 = TEXT_DIM}):Play()
        end
    end)
end

-- Default tab
switchTab("aim")

-- ────────────────────────────────────────────────────────────
--  DRAG  (TopBar as handle)
-- ────────────────────────────────────────────────────────────
do
    local dragging   = false
    local dragStart  = Vector2.new()
    local startPos   = UDim2.new()

    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            dragStart = input.Position
            startPos  = MenuFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (
            input.UserInputType == Enum.UserInputType.MouseMovement or
            input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            MenuFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ────────────────────────────────────────────────────────────
--  OPEN / CLOSE ANIMATION
-- ────────────────────────────────────────────────────────────
local menuOpen = false

-- Start closed
MenuFrame.Size      = UDim2.new(0,0,0,0)
MenuFrame.Position  = UDim2.new(0.5,0,0.5,0)
MenuFrame.Visible   = false

local function openMenu()
    menuOpen = true
    MenuFrame.Visible = true
    MenuFrame.Position = UDim2.new(0.5,0,0.5,0)
    MenuFrame.Size     = UDim2.new(0,0,0,0)

    TweenService:Create(BlurEffect,
        TweenInfo.new(0.3),{Size = 12}):Play()
    TweenService:Create(Backdrop,
        TweenInfo.new(0.25),
        {BackgroundTransparency = 0.55}):Play()
    TweenService:Create(MenuFrame, TWEEN_IN, {
        Size     = MENU_SIZE,
        Position = MENU_POS_OPEN,
    }):Play()
end

local function closeMenu()
    menuOpen = false
    TweenService:Create(BlurEffect,
        TweenInfo.new(0.25),{Size = 0}):Play()
    TweenService:Create(Backdrop,
        TweenInfo.new(0.25),
        {BackgroundTransparency = 1}):Play()
    local tw = TweenService:Create(MenuFrame, TWEEN_OUT, {
        Size     = UDim2.new(0,0,0,0),
        Position = UDim2.new(0.5,0,0.5,0),
    })
    tw:Play()
    tw.Completed:Connect(function()
        if not menuOpen then
            MenuFrame.Visible = false
        end
    end)
end

-- ────────────────────────────────────────────────────────────
--  BIND : RightShift
-- ────────────────────────────────────────────────────────────
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        if menuOpen then closeMenu() else openMenu() end
    end
end)

-- ────────────────────────────────────────────────────────────
--  RUNSERVICE  –  Snow animation
-- ────────────────────────────────────────────────────────────
RunService.Heartbeat:Connect(function(dt)
    if not MenuFrame.Visible then return end

    for _, sf in ipairs(snowflakes) do
        local lbl     = sf.label
        local px      = lbl.Position.X.Scale
        local py      = lbl.Position.Y.Scale

        py = py + sf.speed * dt
        sf.wobble = sf.wobble + dt * 0.8
        px = px + sf.drift + math.sin(sf.wobble) * sf.amp

        -- Clamp X
        if px < 0   then px = 0   end
        if px > 0.9 then px = 0.9 end

        -- Reset when off-bottom
        if py > 1.05 then
            py = -(math.random(2,20)/100)
            px = math.random(0,90)/100
            sf.speed  = math.random(18,45)/1000
            sf.wobble = math.random(0,628)/100
        end

        lbl.Position = UDim2.new(px, 0, py, 0)
    end
end)

-- ────────────────────────────────────────────────────────────
--  FOOTER  (version tag)
-- ────────────────────────────────────────────────────────────
local Footer = makeFrame(MenuFrame,
    UDim2.new(1,-84,0,12),
    UDim2.new(0,82,1,-14),
    Color3.fromRGB(0,0,0), nil, 8)
Footer.BackgroundTransparency = 1

makeText(Footer,
    "v1.0 • MXME_premium",
    UDim2.new(1,0,1,0),
    Color3.fromRGB(35,35,35),
    Enum.Font.Gotham,
    UDim2.new(0,0,0,0),
    8, 9)

-- ────────────────────────────────────────────────────────────
--  DONE  –  press RightShift in-game to toggle
-- ────────────────────────────────────────────────────────────
print("[MXME_Premium] Loaded — press RightShift to toggle menu")
