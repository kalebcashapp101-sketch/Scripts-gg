-- ╔══════════════════════════════════════════════════════════════╗
-- ║               AETHEL HUB — FULL COMBINED SCRIPT             ║
-- ║  Sources: Kali_Hub · Latest · QBSource · QBPerfectBeam       ║
-- ║           Trajectory · KickerAimbot · KickExtender           ║
-- ║           TackleAimbot · NoJumpCooldown · Anti-Lag            ║
-- ║  BUILD: v11 — physics lead prediction · lead sliders fixed       ║
-- ╚══════════════════════════════════════════════════════════════╝

repeat task.wait() until game:IsLoaded()

-- ================================================================
-- KEY SYSTEM
-- ================================================================
do
    local VALID_KEY  = "Aethelhubis#1"
    local Players_ks = game:GetService("Players")
    local UIS_ks     = game:GetService("UserInputService")
    local lp         = Players_ks.LocalPlayer
    local pg         = lp:WaitForChild("PlayerGui")

    -- Build key GUI
    local sg = Instance.new("ScreenGui")
    sg.Name            = "AethelKeyGui"
    sg.ResetOnSpawn    = false
    sg.IgnoreGuiInset  = true
    sg.DisplayOrder    = 999
    sg.Parent          = pg

    -- Blurred dark overlay
    local overlay = Instance.new("Frame", sg)
    overlay.Size              = UDim2.new(1,0,1,0)
    overlay.BackgroundColor3  = Color3.fromRGB(6,6,10)
    overlay.BackgroundTransparency = 0.25
    overlay.BorderSizePixel   = 0

    -- Card
    local card = Instance.new("Frame", sg)
    card.Size             = UDim2.new(0, 360, 0, 220)
    card.AnchorPoint      = Vector2.new(0.5, 0.5)
    card.Position         = UDim2.new(0.5, 0, 0.5, 0)
    card.BackgroundColor3 = Color3.fromRGB(10, 10, 16)
    card.BorderSizePixel  = 0
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 16)
    local cardStroke = Instance.new("UIStroke", card)
    cardStroke.Color = Color3.fromRGB(100, 105, 231); cardStroke.Thickness = 2

    -- Title
    local title = Instance.new("TextLabel", card)
    title.Size              = UDim2.new(1,-20,0,36)
    title.Position          = UDim2.new(0,10,0,14)
    title.BackgroundTransparency = 1
    title.Text              = "✦  Aethel Hub"
    title.TextColor3        = Color3.fromRGB(130,140,255)
    title.Font              = Enum.Font.GothamBold
    title.TextSize          = 22
    title.TextXAlignment    = Enum.TextXAlignment.Center

    -- Subtitle
    local sub = Instance.new("TextLabel", card)
    sub.Size             = UDim2.new(1,-20,0,20)
    sub.Position         = UDim2.new(0,10,0,50)
    sub.BackgroundTransparency = 1
    sub.Text             = "Enter your key to continue"
    sub.TextColor3       = Color3.fromRGB(160,160,180)
    sub.Font             = Enum.Font.Gotham
    sub.TextSize         = 13
    sub.TextXAlignment   = Enum.TextXAlignment.Center

    -- Input box
    local box = Instance.new("TextBox", card)
    box.Size              = UDim2.new(1,-40,0,42)
    box.Position          = UDim2.new(0,20,0,82)
    box.BackgroundColor3  = Color3.fromRGB(18,18,28)
    box.BorderSizePixel   = 0
    box.Text              = ""
    box.PlaceholderText   = "Paste key here..."
    box.PlaceholderColor3 = Color3.fromRGB(90,90,110)
    box.TextColor3        = Color3.fromRGB(220,220,240)
    box.Font              = Enum.Font.GothamBold
    box.TextSize          = 15
    box.ClearTextOnFocus  = false
    box.TextXAlignment    = Enum.TextXAlignment.Center
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 10)
    local boxStroke = Instance.new("UIStroke", box)
    boxStroke.Color = Color3.fromRGB(60,60,90); boxStroke.Thickness = 1.5

    -- Status label
    local status = Instance.new("TextLabel", card)
    status.Size             = UDim2.new(1,-20,0,18)
    status.Position         = UDim2.new(0,10,0,130)
    status.BackgroundTransparency = 1
    status.Text             = ""
    status.TextColor3       = Color3.fromRGB(220,80,80)
    status.Font             = Enum.Font.Gotham
    status.TextSize         = 12
    status.TextXAlignment   = Enum.TextXAlignment.Center

    -- Confirm button
    local btn = Instance.new("TextButton", card)
    btn.Size              = UDim2.new(1,-40,0,42)
    btn.Position          = UDim2.new(0,20,0,155)
    btn.BackgroundColor3  = Color3.fromRGB(80,85,210)
    btn.BorderSizePixel   = 0
    btn.Text              = "Confirm"
    btn.TextColor3        = Color3.fromRGB(255,255,255)
    btn.Font              = Enum.Font.GothamBold
    btn.TextSize          = 15
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)

    local validated = false

    local function tryKey()
        local input = box.Text:gsub("^%s+", ""):gsub("%s+$", "")
        if input == VALID_KEY then
            validated = true
            status.TextColor3 = Color3.fromRGB(80,220,120)
            status.Text = "✓  Key accepted — loading..."
            btn.BackgroundColor3 = Color3.fromRGB(50,180,90)
            task.wait(0.8)
            sg:Destroy()
        else
            status.TextColor3 = Color3.fromRGB(220,80,80)
            status.Text = "✗  Invalid key. Try again."
            -- Shake card
            local orig = card.Position
            for i = 1, 6 do
                card.Position = UDim2.new(orig.X.Scale, orig.X.Offset + (i%2==0 and 6 or -6),
                                          orig.Y.Scale, orig.Y.Offset)
                task.wait(0.04)
            end
            card.Position = orig
        end
    end

    btn.MouseButton1Click:Connect(tryKey)
    box.FocusLost:Connect(function(enter) if enter then tryKey() end end)

    -- Block everything until validated
    repeat task.wait(0.05) until validated
end

-- ================================================================
-- SECTION 1 — SERVICES & GLOBALS
-- ================================================================
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService      = game:GetService("TweenService")
local TestService       = game:GetService("TestService")
local VIM               = game:GetService("VirtualInputManager")
local CoreGui           = game:GetService("CoreGui")
local Workspace         = game:GetService("Workspace")
local Camera            = Workspace.CurrentCamera

local cloneref = cloneref or function(v) return v end

local Player = Players.LocalPlayer
while not Player do Player = Players.LocalPlayer task.wait() end

local Char = Player.Character or Player.CharacterAdded:Wait()
local Hum  = cloneref(Char:WaitForChild("Humanoid"))
local Hrp  = cloneref(Char:WaitForChild("HumanoidRootPart"))
local mouse = Player:GetMouse()

Player.CharacterAdded:Connect(function(c)
    Char = c
    Hrp  = c:WaitForChild("HumanoidRootPart")
    Hum  = c:WaitForChild("Humanoid")
end)

-- ================================================================
-- SECTION 2 — AC BYPASS (Delta-compatible rewrite)
-- ================================================================
do
    -- Safe helper: only call executor funcs if they exist
    local function safeHook(original, replacement)
        if typeof(hookfunction) ~= "function" then return end
        pcall(hookfunction, original, newcclosure and newcclosure(replacement) or replacement)
    end

    local function safeGetgc()
        if typeof(getgc) ~= "function" then return {} end
        local ok, r = pcall(getgc, true)
        return (ok and type(r) == "table") and r or {}
    end

    -- 1) Spoof debug.info so our script reports as a normal LocalScript
    pcall(function()
        if typeof(hookfunction) ~= "function" or typeof(debug) ~= "table" then return end
        local orig_debug_info = debug.info
        safeHook(debug.info, function(level, flags)
            if level == 2 and flags == "s" then return "LocalScript" end
            return orig_debug_info(level, flags)
        end)
    end)

    -- 2) Nullify the AC integrity checker (targets functions with known magic constant)
    pcall(function()
        local gc = safeGetgc()
        for _, v in pairs(gc) do
            if type(v) == "function"
            and typeof(islclosure) == "function" and islclosure(v)
            and typeof(isexecutorclosure) == "function" and not isexecutorclosure(v) then
                local ok, consts = pcall(function()
                    local p = getprotos and getprotos(v)
                    return p and #p == 1 and getconstants and getconstants(p[1])
                end)
                if ok and consts then
                    for _, c in pairs(consts) do
                        if type(c) == "number" and c > 1000000 and c < 10000000 then
                            pcall(hookfunction, v, newcclosure and newcclosure(function() end) or function() end)
                            break
                        end
                    end
                end
            end
        end
    end)

    -- 3) Block the AC's sound-based detection channel
    pcall(function()
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        local remote  = remotes and remotes:FindFirstChild("CharacterSoundEvent")
        if not remote or typeof(hookfunction) ~= "function" then return end
        local oldFire = remote.FireServer
        hookfunction(remote.FireServer, newcclosure(function(self, ...)
            local args = {...}
            if type(args[1]) == "string" and #args[1] > 20 then
                if args[2] == "b51b07a5c14d" or args[2] == "error" then return end
            end
            return oldFire(self, ...)
        end))
    end)

    _G.b51b07a5c14d = false

    task.wait(0.5)
    print("[Aethel Hub] AC bypass applied (Delta build)")
end

-- ================================================================
-- SECTION 3 — SHARED BEAM HELPER
-- ================================================================
local function beamProjectile(g, v0, x0, t1)
    local c  = 0.5 * 0.5 * 0.5
    local p3 = 0.5*g*t1*t1 + v0*t1 + x0
    local p2 = p3 - (g*t1*t1 + v0*t1)/3
    local p1 = (c*g*t1*t1 + 0.5*v0*t1 + x0 - c*(x0+p3))/(3*c) - p2
    local curve0 = (p1 - x0).Magnitude
    local curve1 = (p2 - p3).Magnitude
    local b  = (x0 - p3).Unit
    local r1 = (p1 - x0).Unit
    local u1 = r1:Cross(b).Unit
    local r2 = (p2 - p3).Unit
    local u2 = r2:Cross(b).Unit
    b = u1:Cross(r1).Unit
    local cf1 = CFrame.new(x0.X,x0.Y,x0.Z, r1.X,u1.X,b.X, r1.Y,u1.Y,b.Y, r1.Z,u1.Z,b.Z)
    local cf2 = CFrame.new(p3.X,p3.Y,p3.Z, r2.X,u2.X,b.X, r2.Y,u2.Y,b.Y, r2.Z,u2.Z,b.Z)
    return curve0, -curve1, cf1, cf2
end

-- ================================================================
-- SECTION 4 — QB AIMBOT (improved: better physics, mobile, controller)
-- ================================================================

-- ── Config ────────────────────────────────────────────────────────
local qbEnabled         = false
local qb_autoAngle      = false
local qb_antiOOB        = false
local qb_autoPower      = false
local qb_gMag           = 19.6  -- Football Fusion 2 uses default Roblox gravity
local qb_manualAngle    = 25   -- used when autoAngle is off
local qb_lockedTarget   = nil  -- current locked character
local qb_lockedPlayer   = nil  -- Player object for persistent lock across respawns

local qb_PassMode = {
    Dime   = {angleMin = 10, angleMax = 30, idealAngle = 18},  -- medium, accurate
    Mag    = {angleMin = 12, angleMax = 35, idealAngle = 20},  -- slightly higher arc
    Dive   = {angleMin = 8,  angleMax = 25, idealAngle = 14},  -- low flat dive route
    Jump   = {angleMin = 12, angleMax = 32, idealAngle = 20},  -- medium, accounts for height
    Slant  = {angleMin = 5,  angleMax = 15, idealAngle = 8},   -- very flat quick slant
    Bullet = {angleMin = 3,  angleMax = 10, idealAngle = 5},   -- flattest fastest
    Lob    = {angleMin = 35, angleMax = 55, idealAngle = 44},  -- high rainbow arc
    Screen = {angleMin = 3,  angleMax = 12, idealAngle = 6},   -- very short flat screen pass
}

-- Lead overrides — every mode listed so sliders always take effect
local qb_leadOverride = {
    Dime   = 5,
    Mag    = 6,
    Dive   = 6,
    Jump   = 5,
    Slant  = 4,
    Bullet = 3,
    Lob    = 7,
    Screen = 3,
}

local qb_data = {
    power = 0, angle = 25, airtime = 0, distance = 0,
    direction = Vector3.new(), target = nil,
    smoothVel = Vector3.new(),
    targetPos = Vector3.new()
}

local qb_Throwtypemode         = "Dime"
local qb_throwTypes            = {"Dime","Mag","Dive","Jump","Slant","Bullet","Lob","Screen"}
local qb_currentThrowTypeIndex = 1
local qb_throwCooldown         = false
local qb_isMobile              = UserInputService.TouchEnabled
local qb_isController          = false  -- detected on first gamepad input

-- Velocity smoothing (EMA, alpha=0.35)
local VEL_ALPHA = 0.35

-- ── Highlight ─────────────────────────────────────────────────────
local qb_HL = Instance.new("Highlight")
qb_HL.FillColor        = Color3.fromRGB(84, 118, 241)
qb_HL.OutlineColor     = Color3.fromRGB(255, 255, 255)
qb_HL.FillTransparency = 0.85
qb_HL.Enabled          = false
qb_HL.Parent           = CoreGui

-- ── Throw arc beam ────────────────────────────────────────────────
local qb_a0   = Instance.new("Attachment", Workspace.Terrain)
local qb_a1   = Instance.new("Attachment", Workspace.Terrain)
local qb_beam = Instance.new("Beam")
qb_beam.Attachment0  = qb_a0
qb_beam.Attachment1  = qb_a1
qb_beam.Segments     = 1750
qb_beam.Width0       = 0.55
qb_beam.Width1       = 0.55
qb_beam.Parent       = Workspace.Terrain
qb_beam.Color        = ColorSequence.new(Color3.fromRGB(100, 105, 231))
qb_beam.Transparency = NumberSequence.new(0)
qb_beam.FaceCamera   = true
qb_beam.Enabled      = false

-- ── HUD GUI ───────────────────────────────────────────────────────
local qb_gui = Instance.new("ScreenGui")
qb_gui.Name           = "QBACards"
qb_gui.Parent         = Player:WaitForChild("PlayerGui")
qb_gui.ResetOnSpawn   = false
qb_gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
qb_gui.Enabled        = false
qb_gui.DisplayOrder   = 10

-- Card size: bigger on mobile
local BTN_SIZE        = qb_isMobile and 70  or 56

local function qb_safeText(lbl, txt)
    if lbl and lbl.Parent then lbl.Text = tostring(txt) end
end

-- Draggable card: returns value label
-- ── HUD: single row matching screenshot layout ────────────────────
-- Cards: [Throw Type] [Power] [Airtime] [Angle] [Target]
-- Positioned top-center, can be dragged individually

local HUD_H       = qb_isMobile and 78 or 68
local HUD_W_SM    = qb_isMobile and 88 or 76   -- small cards
local HUD_W_LG    = qb_isMobile and 160 or 140  -- target card (wider)
local HUD_GAP     = 6
local HUD_Y_OFF   = qb_isMobile and 16 or 12   -- from top

-- Total row width = 4 small + 1 large + 4 gaps
local ROW_TOTAL   = HUD_W_SM * 4 + HUD_W_LG + HUD_GAP * 4
local HUD_START_X = -ROW_TOTAL / 2  -- center-anchored

local function makeDragCard(gui, name, anchorX, anchorY, offX, offY, defaultTxt, titleTxt, valColor, titleColor, w, h)
    valColor   = valColor   or Color3.fromRGB(255, 255, 255)
    titleColor = titleColor or Color3.fromRGB(130, 160, 255)
    w = w or HUD_W_SM; h = h or HUD_H

    local frame = Instance.new("Frame")
    frame.Name             = name
    frame.Parent           = gui
    frame.Size             = UDim2.new(0, w, 0, h)
    frame.AnchorPoint      = Vector2.new(anchorX, anchorY)
    frame.Position         = UDim2.new(anchorX, offX, anchorY, offY)
    frame.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
    frame.BorderSizePixel  = 0
    frame.BackgroundTransparency = 0.12
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

    -- subtle border glow
    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = titleColor; stroke.Thickness = 1.8; stroke.Transparency = 0.55

    -- Value label (big, top portion)
    local vLabel = Instance.new("TextLabel")
    vLabel.Parent             = frame
    vLabel.Size               = UDim2.new(1, -6, 0.58, 0)
    vLabel.Position           = UDim2.new(0, 3, 0, 6)
    vLabel.BackgroundTransparency = 1
    vLabel.Text               = defaultTxt
    vLabel.TextColor3         = valColor
    vLabel.TextScaled         = false
    vLabel.TextSize           = qb_isMobile and 22 or 20
    vLabel.Font               = Enum.Font.GothamBold
    vLabel.TextXAlignment     = Enum.TextXAlignment.Center
    vLabel.TextStrokeColor3   = Color3.new(0,0,0)
    vLabel.TextStrokeTransparency = 0.5

    -- Divider line
    local div = Instance.new("Frame", frame)
    div.Size               = UDim2.new(0.82, 0, 0, 1)
    div.Position           = UDim2.new(0.09, 0, 0.64, 0)
    div.BackgroundColor3   = titleColor
    div.BackgroundTransparency = 0.7
    div.BorderSizePixel    = 0

    -- Title label (small, bottom)
    local tLabel = Instance.new("TextLabel")
    tLabel.Parent             = frame
    tLabel.Size               = UDim2.new(1, -4, 0.3, 0)
    tLabel.Position           = UDim2.new(0, 2, 0.68, 0)
    tLabel.BackgroundTransparency = 1
    tLabel.Text               = titleTxt
    tLabel.TextColor3         = titleColor
    tLabel.TextScaled         = false
    tLabel.TextSize           = qb_isMobile and 12 or 11
    tLabel.Font               = Enum.Font.Gotham
    tLabel.TextXAlignment     = Enum.TextXAlignment.Center

    -- Drag support
    local dragging, dragStart, startPos = false, nil, nil
    frame.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
           or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = inp.Position; startPos = frame.Position
            inp.Changed:Connect(function()
                if inp.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if not dragging then return end
        if inp.UserInputType == Enum.UserInputType.MouseMovement
           or inp.UserInputType == Enum.UserInputType.Touch then
            local d = inp.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X,
                                       startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
           or inp.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    return vLabel
end

-- White = value text, colored = title text (matching screenshot style)
local WHITE     = Color3.fromRGB(255, 255, 255)
local COL_TYPE  = Color3.fromRGB(130, 140, 255)  -- blue-purple (Throw Type)
local COL_PWR   = Color3.fromRGB(100, 200, 255)  -- cyan        (Power)
local COL_AIR   = Color3.fromRGB(255, 200, 80)   -- amber       (Airtime)
local COL_ANG   = Color3.fromRGB(130, 140, 255)  -- blue-purple (Angle)
local COL_TGT   = Color3.fromRGB(130, 140, 255)  -- blue-purple (Target)

local X = HUD_START_X
local qb_modeLabel    = makeDragCard(qb_gui,"ModeCard",    0.5,0, X,                                   HUD_Y_OFF, "Dime",  "Throw Type", WHITE, COL_TYPE)
local qb_powerLabel   = makeDragCard(qb_gui,"PowerCard",   0.5,0, X + (HUD_W_SM + HUD_GAP),            HUD_Y_OFF, "95",    "Power",      WHITE, COL_PWR)
local qb_airtimeLabel = makeDragCard(qb_gui,"AirtimeCard", 0.5,0, X + (HUD_W_SM + HUD_GAP)*2,          HUD_Y_OFF, "0.30s", "Airtime",    WHITE, COL_AIR)
local qb_angleLabel   = makeDragCard(qb_gui,"AngleCard",   0.5,0, X + (HUD_W_SM + HUD_GAP)*3,          HUD_Y_OFF, "23.5°", "Angle",      WHITE, COL_ANG)
local qb_targetLabel  = makeDragCard(qb_gui,"TargetCard",  0.5,0, X + (HUD_W_SM + HUD_GAP)*4,          HUD_Y_OFF, "None",  "Target",     WHITE, COL_TGT, HUD_W_LG, HUD_H)

-- ── Mobile-only: Throw button + Cycle button + Lock button ─────────
local qb_throwBtn, qb_cycleBtn, qb_lockBtn

if qb_isMobile then
    local function makeTouchBtn(gui, name, anchorX, anchorY, offX, offY, label, color, size)
        local btn = Instance.new("TextButton")
        btn.Name             = name
        btn.Parent           = gui
        btn.Size             = UDim2.new(0, size, 0, size)
        btn.AnchorPoint      = Vector2.new(anchorX, anchorY)
        btn.Position         = UDim2.new(anchorX, offX, anchorY, offY)
        btn.BackgroundColor3 = color
        btn.TextColor3       = Color3.fromRGB(255, 255, 255)
        btn.Text             = label
        btn.TextScaled       = true
        btn.Font             = Enum.Font.GothamBold
        btn.BorderSizePixel  = 0
        btn.BackgroundTransparency = 0.25
        Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
        local stroke = Instance.new("UIStroke", btn)
        stroke.Color = Color3.fromRGB(255,255,255); stroke.Thickness = 1.5; stroke.Transparency = 0.6
        return btn
    end

    -- FF2 jump button sits at bottom-right (~70px from right, ~70px from bottom).
    -- Throw ⚡: same row as jump, just to its left (offset -16 - BTN_SIZE - 10 from right edge)
    local throwOff = -(BTN_SIZE + 10 + BTN_SIZE + 16)  -- left of jump button
    qb_throwBtn = makeTouchBtn(qb_gui, "ThrowBtn", 1, 1,
        throwOff, -16,
        "⚡", Color3.fromRGB(80, 80, 220), BTN_SIZE)

    -- Lock 🎯: above the FF2 power/kicker GUI — sits at ~38% from bottom right
    qb_lockBtn = makeTouchBtn(qb_gui, "LockBtn", 1, 1,
        -16, -(BTN_SIZE * 3 + 36),
        "🎯", Color3.fromRGB(200, 60, 60), BTN_SIZE)

    -- Switch ↻: directly above Lock
    qb_cycleBtn = makeTouchBtn(qb_gui, "CycleBtn", 1, 1,
        -16, -(BTN_SIZE * 4 + 46),
        "↻", Color3.fromRGB(50, 160, 80), BTN_SIZE)
end

-- ── Physics helpers ───────────────────────────────────────────────
local function qb_clampOOB(targetPos)
    if not qb_antiOOB then return targetPos end
    local bbounds = Workspace:FindFirstChild("bbounds")
    if not bbounds then return targetPos end
    local p, s = bbounds.Position, bbounds.Size
    return Vector3.new(
        math.clamp(targetPos.X, p.X - s.X/2 + 1, p.X + s.X/2 - 1),
        targetPos.Y,
        math.clamp(targetPos.Z, p.Z - s.Z/2 + 1, p.Z + s.Z/2 - 1)
    )
end

local function velForAngle(aRad, xz, dy, grav)
    local cosA  = math.cos(aRad)
    local cos2  = cosA * cosA
    local denom = 2 * (xz * math.tan(aRad) - dy) * cos2
    if denom <= 0 then return nil end
    local v2 = grav * xz * xz / denom
    if v2 <= 0 or v2 ~= v2 then return nil end
    return math.sqrt(v2)
end

-- Physics-based iterative lead prediction.
-- How it works:
--   1. Seed airtime from the last solved power (frame-coherent, not a fixed 55).
--   2. Project where the WR will BE at that airtime:
--        - flat XZ: actual WR velocity * airtime
--        - Y: full ballistic arc (v_y*t - 0.5*g*t^2) so jump routes land right
--        - lead: slider studs ALONG run direction, scaled by WR speed ratio
--          so a slow/cut WR doesn't get over-led.
--   3. Solve the exact throw angle/power to reach that spot.
--      Scoring biases toward idealAngle for the route type (no v*0.15 lob bias).
--   4. Refine twice with the solved airtime — 3 total passes to converge on
--      fast deep routes.
local MAX_WR_SPEED = 24  -- studs/s, typical top sprint speed in FF2

local function qb_calcThrow(fromPos, toPos, rawVel, smoothedVel, useAutoAngle, modeName)
    local cfg        = qb_PassMode[modeName] or qb_PassMode["Dime"]
    local angleMin   = cfg.angleMin
    local angleMax   = cfg.angleMax
    local idealAngle = cfg.idealAngle or ((angleMin + angleMax) / 2)
    local extraLead  = qb_leadOverride[modeName] or 5

    -- Use RAW velocity for XZ so lead is correct on frame 1 (smoothedVel lags).
    -- smoothedVel is kept only to damp Y jitter on jump routes.
    local rawVelFlat = Vector3.new(rawVel.X, 0, rawVel.Z)
    local rawSpeed   = rawVelFlat.Magnitude
    local rawDir     = rawSpeed > 0.1 and rawVelFlat.Unit or Vector3.new()

    -- Step 1: airtime seed — use last solved power if available, else assume 55.
    -- Dividing by cos(idealAngle) converts total speed → horizontal component.
    local d0        = (toPos - fromPos)
    local flat0     = Vector3.new(d0.X, 0, d0.Z).Magnitude
    local seedSpeed = (qb_data.power > 5) and qb_data.power or 55
    local seedHz    = seedSpeed * math.cos(math.rad(idealAngle))
    local roughT    = math.max(flat0 / math.max(seedHz, 8), 0.15)

    -- Helper: project WR position at time t.
    -- Y stays at ground height — WR is running, not in free fall.
    -- Applying -0.5*g*t^2 to the WR was predicting them underground which
    -- forced the solver to aim down and massively underpowered every throw.
    local function projectWR(t)
        local px = toPos.X + rawVelFlat.X * t + rawDir.X * extraLead
        local pz = toPos.Z + rawVelFlat.Z * t + rawDir.Z * extraLead
        local py = toPos.Y  -- WR catches at their current height
        return qb_clampOOB(Vector3.new(px, py, pz))
    end

    -- Step 2: first predicted position
    local predicted = projectWR(roughT)

    -- Step 3: solver — score by distance to idealAngle, no velocity penalty
    local function solveAngle(target)
        local disp    = target - fromPos
        local flatD   = Vector3.new(disp.X, 0, disp.Z).Magnitude
        local heightD = disp.Y
        local bV, bA, bT = 0, idealAngle, 0
        local bScore  = math.huge
        for aDeg = angleMin, angleMax, 1 do
            local aRad = math.rad(aDeg)
            local v    = velForAngle(aRad, flatD, heightD, qb_gMag)
            if v and v > 0 and v <= 95 then
                local at    = flatD / (v * math.cos(aRad))
                -- Score purely on angle proximity to ideal — no velocity bias
                local score = math.abs(aDeg - idealAngle)
                if score < bScore then
                    bScore = score; bA = aDeg; bV = v; bT = at
                end
            end
        end
        return bV, bA, bT
    end

    local bestVel, bestAngle, bestAirtime = solveAngle(predicted)

    -- Step 4a: first refinement pass
    if bestAirtime > 0.05 then
        predicted = projectWR(bestAirtime)
        local rv, ra, rt = solveAngle(predicted)
        if rv > 0 then bestVel, bestAngle, bestAirtime = rv, ra, rt end
    end

    -- Step 4b: second refinement pass (converges deep/fast routes)
    if bestAirtime > 0.05 then
        predicted = projectWR(bestAirtime)
        local rv, ra, rt = solveAngle(predicted)
        if rv > 0 then bestVel, bestAngle, bestAirtime = rv, ra, rt end
    end

    if not useAutoAngle then
        local aRad = math.rad(qb_manualAngle)
        local disp  = predicted - fromPos
        local flatD = Vector3.new(disp.X, 0, disp.Z).Magnitude
        local v     = velForAngle(aRad, flatD, disp.Y, qb_gMag)
        bestAngle   = qb_manualAngle
        bestVel     = v and math.clamp(v, 0, 95) or 0
        bestAirtime = bestVel > 0 and flatD / (bestVel * math.cos(aRad)) or 0
    end

    bestVel = math.clamp(bestVel, 0, 95)
    qb_data.power     = bestVel
    qb_data.angle     = bestAngle
    qb_data.airtime   = bestAirtime
    qb_data.targetPos = predicted
    qb_data.distance  = Vector3.new((predicted - fromPos).X, 0, (predicted - fromPos).Z).Magnitude
    return bestVel, bestAngle, bestAirtime, predicted
end

-- ── Target selection ──────────────────────────────────────────────
local function qb_screenDist(worldPos)
    local sp, onScreen = Camera:WorldToViewportPoint(worldPos)
    if not onScreen then return math.huge end
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    return (Vector2.new(sp.X, sp.Y) - center).Magnitude
end

-- Returns character model or nil
local function qb_findClosestOnScreen()
    local closest, closestDist = nil, math.huge
    local check = function(model)
        local hrp = model:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local d = qb_screenDist(hrp.Position)
        if d < closestDist then closest = model; closestDist = d end
    end
    for _, t in pairs(Players:GetPlayers()) do
        if t ~= Player and t.Team == Player.Team and t.Character then check(t.Character) end
    end
    local npcwr = Workspace:FindFirstChild("npcwr")
    if npcwr then
        for _, desc in pairs(npcwr:GetDescendants()) do
            if desc:IsA("Model") and (desc.Name == "bot 1" or desc.Name == "bot 3") then
                check(desc)
            end
        end
    end
    return closest
end

local function qb_getTarget()
    -- If manually locked, keep it unless they're gone
    if qb_lockedTarget then
        local hrp = qb_lockedTarget:FindFirstChild("HumanoidRootPart")
        if hrp and qb_lockedTarget.Parent then
            qb_data.target = qb_lockedTarget
            return
        else
            qb_lockedTarget = nil
        end
    end
    -- Auto: closest to screen center
    local closest = qb_findClosestOnScreen()
    if closest and closest ~= qb_data.target then
        qb_data.target    = closest
        qb_HL.Adornee     = closest
        qb_HL.Enabled     = true
        -- Seed with actual current velocity so lead is correct on frame 1
        local seedHrp = closest:FindFirstChild("HumanoidRootPart")
        qb_data.smoothVel = seedHrp and seedHrp.AssemblyLinearVelocity or Vector3.new()
    end
end

local function qb_lockCurrentTarget()
    if not qb_data.target then return end
    -- Store the Player object so lock survives character respawns
    local tPlr = Players:GetPlayerFromCharacter(qb_data.target)
    if tPlr then
        qb_lockedPlayer  = tPlr          -- persistent across respawns
        qb_lockedTarget  = qb_data.target
    else
        -- NPC — lock by model reference only
        qb_lockedPlayer  = nil
        qb_lockedTarget  = qb_data.target
    end
    local name = (tPlr and (tPlr.DisplayName ~= "" and tPlr.DisplayName or tPlr.Name))
                 or (qb_data.target.Name or "?")
    -- Visual indicator on the locked card: add 🔒 prefix to target label
    qb_safeText(qb_targetLabel, "🔒 " .. name)
    -- notify handled by custom UI
    print("[Aethel Hub] QB Lock: Locked: " .. name)
end

local function qb_unlockTarget()
    qb_lockedPlayer = nil
    qb_lockedTarget = nil
    qb_safeText(qb_targetLabel, "None")
end

-- ── Throw helpers (from KaliHub — confirmed working) ─────────────
local function qb_hasBall()
    if not Char then return false end
    return Char:FindFirstChildOfClass("Tool") ~= nil
end

local function qb_getGuiPower()
    local ballGui = Player.PlayerGui:FindFirstChild("BallGui")
    if not ballGui then return nil end
    local ok, d = pcall(function() return ballGui:FindFirstChild("Disp", true) end)
    if ok and d and d:IsA("TextLabel") then return tonumber(d.Text) end
    return nil
end

local function qb_doThrow(dirUnit, power)
    if not qbEnabled then return end
    local Football = Char and Char:FindFirstChildOfClass("Tool")
    if not Football then return end
    local handle = Football:FindFirstChild("Handle")
    local Remote = handle and handle:FindFirstChildOfClass("RemoteEvent")
    if not Remote then return end
    handle.CanCollide = false
    pcall(function()
        local anims     = ReplicatedStorage:FindFirstChild("Animations")
        local throwAnim = anims and anims:FindFirstChild("Throw")
        if throwAnim then Char.Humanoid:LoadAnimation(throwAnim):Play() end
    end)
    task.delay(0.14, function()
        local origin = handle.Position
        local tgt    = origin + dirUnit * 10000
        if game.PlaceId == 8206123457 then
            Remote:FireServer("Clicked", origin, tgt, power)
        else
            Remote:FireServer("Clicked", origin, tgt, 1, power)
        end
        task.delay(0.3, function()
            if handle and handle.Parent then handle.CanCollide = true end
        end)
    end)
end

local function qb_executeThrow()
    if not qbEnabled then return end
    if not qb_data.target then return end
    local head = Char and Char:FindFirstChild("Head")
    if not head or not Char:FindFirstChildOfClass("Tool") then return end

    -- Use the pre-solved values from RenderStepped (same ones shown in HUD)
    -- so the throw EXACTLY matches what the beam/HUD is displaying.
    local power   = qb_data.power
    local airtime = qb_data.airtime
    local predicted = qb_data.targetPos

    -- If no valid solution yet (target just acquired), solve now
    if not power or power <= 0 or airtime <= 0 then
        local hrp  = qb_data.target:FindFirstChild("HumanoidRootPart")
        local tPos = hrp and hrp.Position or qb_data.target:GetPivot().Position
        local tVelRaw = hrp and hrp.AssemblyLinearVelocity or Vector3.new()
        tPos = qb_clampOOB(tPos)
        power, _, airtime, predicted =
            qb_calcThrow(head.Position, tPos, tVelRaw, qb_data.smoothVel, qb_autoAngle, qb_Throwtypemode)
    end

    if not power or power <= 0 then return end

    -- Only override with the GUI power bar if it's actually been charged.
    -- On mobile a quick tap reads 0 from the bar → ball dies mid-air.
    if not qb_autoPower then
        local guiP = qb_getGuiPower()
        if guiP and guiP > 10 then power = guiP end
    end

    -- Origin must match what qb_calcThrow solved from (head.Position).
    -- The old +5-stud offset caused a direction mismatch with the arc.
    local gv  = Vector3.new(0, -qb_gMag, 0)
    local x0  = head.Position
    local dir = (predicted - x0) - 0.5 * gv * airtime * airtime
    if dir.Magnitude == 0 then return end
    qb_doThrow(dir.Unit, power)
end

-- ── Throw type cycle ──────────────────────────────────────────────
local function qb_cycleThrowType(reverse)
    if reverse then
        qb_currentThrowTypeIndex -= 1
        if qb_currentThrowTypeIndex < 1 then qb_currentThrowTypeIndex = #qb_throwTypes end
    else
        qb_currentThrowTypeIndex += 1
        if qb_currentThrowTypeIndex > #qb_throwTypes then qb_currentThrowTypeIndex = 1 end
    end
    qb_Throwtypemode = qb_throwTypes[qb_currentThrowTypeIndex]
    qb_safeText(qb_modeLabel, qb_Throwtypemode)
end

-- ── RenderStepped: update HUD + beam ──────────────────────────────
RunService.RenderStepped:Connect(function(dt)
    if not qbEnabled then
        qb_beam.Enabled = false; qb_HL.Enabled = false; qb_gui.Enabled = false; return
    end
    local hasBall = qb_hasBall()
    if not hasBall then
        qb_beam.Enabled = false; qb_HL.Enabled = false
        qb_gui.Enabled  = false
        -- Do NOT clear lockedPlayer here — preserve lock across plays
        qb_data.target = nil
        return
    end
    qb_gui.Enabled = true

    -- Persistent lock: reconnect to locked player's current character
    if qb_lockedPlayer then
        local newChar = qb_lockedPlayer.Character
        if newChar and newChar.Parent then
            if qb_lockedTarget ~= newChar then
                qb_lockedTarget  = newChar
                qb_data.target   = newChar
                qb_HL.Adornee    = newChar
                qb_HL.Enabled    = true
                local seedHrp = newChar:FindFirstChild("HumanoidRootPart")
                qb_data.smoothVel = seedHrp and seedHrp.AssemblyLinearVelocity or Vector3.new()
            else
                qb_data.target = qb_lockedTarget
            end
        else
            -- Player left or no character yet, keep lock pending
            qb_data.target = nil
            qb_beam.Enabled = false
            qb_safeText(qb_targetLabel, "🔒 (loading...)")
            return
        end
    else
        qb_getTarget()
    end

    if not qb_data.target or not qb_data.target.Parent then
        qb_HL.Enabled = false
        qb_safeText(qb_angleLabel,   "--")
        qb_safeText(qb_modeLabel,    qb_Throwtypemode)
        qb_safeText(qb_airtimeLabel, "--")
        qb_safeText(qb_powerLabel,   "--")
        qb_safeText(qb_targetLabel,  "None")
        qb_beam.Enabled = false
        return
    end

    qb_HL.Adornee = qb_data.target
    qb_HL.Enabled = true

    local head = Char:FindFirstChild("Head")
    if not head then return end

    local hrp  = qb_data.target:FindFirstChild("HumanoidRootPart")
    local tPos = hrp and hrp.Position or qb_data.target:GetPivot().Position
    local tVel = hrp and hrp.AssemblyLinearVelocity or Vector3.new()

    -- EMA alpha: dt*8 is frame-rate independent; cap at 0.3 so velocity builds
    -- up quickly enough to actually steer the lead on the first few frames.
    local alpha = math.clamp(dt * 8, 0.05, 0.3)
    qb_data.smoothVel = qb_data.smoothVel:Lerp(tVel, alpha)

    local calcV, angle, airtime, predicted =
        qb_calcThrow(head.Position, tPos, tVel, qb_data.smoothVel, qb_autoAngle, qb_Throwtypemode)

    qb_data.power   = calcV
    qb_data.angle   = angle
    qb_data.airtime = airtime

    local tName = "NPC"
    local tPlr  = Players:GetPlayerFromCharacter(qb_data.target)
    if tPlr then tName = tPlr.DisplayName ~= "" and tPlr.DisplayName or tPlr.Name end
    if qb_lockedPlayer then tName = "🔒 " .. tName end

    qb_safeText(qb_angleLabel,   string.format("%.1f°", angle))
    qb_safeText(qb_modeLabel,    qb_Throwtypemode)
    qb_safeText(qb_airtimeLabel, string.format("%.2fs", airtime))
    qb_safeText(qb_powerLabel,   string.format("%d", math.floor((calcV or 0) + 0.5)))
    qb_safeText(qb_targetLabel,  tName)

    if qb_data.airtime > 0 and qb_data.power > 0 then
        local gv = Vector3.new(0, -qb_gMag, 0)
        local x0 = head.Position  -- must match executeThrow origin exactly
        local dirU = (qb_data.targetPos - x0) - 0.5 * gv * qb_data.airtime * qb_data.airtime
        if dirU.Magnitude > 0.01 then
            dirU = dirU.Unit
            local c0, c1, cf1, cf2 = beamProjectile(gv, dirU * qb_data.power, x0, qb_data.airtime)
            qb_beam.Enabled    = true
            qb_beam.CurveSize0 = c0 or 0
            qb_beam.CurveSize1 = c1 or 0
            qb_a0.CFrame = qb_a0.Parent.CFrame:Inverse() * (cf1 or CFrame.new(x0))
            qb_a1.CFrame = qb_a1.Parent.CFrame:Inverse() * (cf2 or CFrame.new(qb_data.targetPos))
        end
    end
end)

-- ── Input: keyboard + touch + controller ──────────────────────────
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if not qbEnabled then return end
    local kc = input.KeyCode
    local ut = input.UserInputType

    -- Mobile: ANY tap on screen throws to locked/auto target.
    -- Touch is a separate UserInputType from MouseButton1 — the old code
    -- never caught it, so tapping the screen did nothing.
    if qb_isMobile and ut == Enum.UserInputType.Touch then
        if qb_hasBall() and (qb_lockedTarget or qb_data.target) then
            qb_executeThrow()
            return
        end
    end

    if ut == Enum.UserInputType.MouseButton1 or kc == Enum.KeyCode.Space or kc == Enum.KeyCode.E then
        -- Only throw on M1 if QB aimbot is active AND we actually have the ball
        if kc == Enum.KeyCode.Space or kc == Enum.KeyCode.E then
            qb_executeThrow()
        elseif ut == Enum.UserInputType.MouseButton1 and qb_hasBall() then
            qb_executeThrow()
        end
    end
    if kc == Enum.KeyCode.Q or kc == Enum.KeyCode.Z then qb_cycleThrowType(false) end
    if kc == Enum.KeyCode.Tab or kc == Enum.KeyCode.X then qb_cycleThrowType(true) end
    if kc == Enum.KeyCode.G then
        if qb_lockedPlayer or qb_lockedTarget then qb_unlockTarget()
        else qb_lockCurrentTarget() end
    end
    if ut == Enum.UserInputType.Gamepad1 then
        qb_isController = true
        if kc == Enum.KeyCode.ButtonR2 then qb_executeThrow() end
        if kc == Enum.KeyCode.ButtonR1 or kc == Enum.KeyCode.DPadRight then qb_cycleThrowType(false) end
        if kc == Enum.KeyCode.ButtonL1 or kc == Enum.KeyCode.DPadLeft  then qb_cycleThrowType(true) end
        if kc == Enum.KeyCode.ButtonB then
            if qb_lockedPlayer or qb_lockedTarget then qb_unlockTarget()
            else qb_lockCurrentTarget() end
        end
    end
end)

-- Mobile uses the dedicated ⚡ throw button — TouchTap intentionally not used
-- to avoid throwing on every accidental screen tap.

-- Mobile button connections
-- Activated fires on both tap (touch) and click, making it reliable on mobile.
-- MouseButton1Click is kept as a fallback for emulated/PC test scenarios.
if qb_isMobile then
    if qb_throwBtn then
        qb_throwBtn.Activated:Connect(function() qb_executeThrow() end)
    end
    if qb_cycleBtn then
        qb_cycleBtn.Activated:Connect(function() qb_cycleThrowType(false) end)
    end
    if qb_lockBtn then
        qb_lockBtn.Activated:Connect(function()
            if qb_lockedPlayer or qb_lockedTarget then qb_unlockTarget()
            else qb_lockCurrentTarget() end
        end)
    end
end

-- ================================================================
-- SECTION 5 — QB PERFECT BEAM (QBPerfectBeam.lua)
-- ================================================================
local perfBeamEnabled    = false
local perfBeamConnection = nil

local function perfBeam_start()
    if perfBeamConnection then return end
    perfBeamConnection = Workspace.ChildAdded:Connect(function(b)
        if b.Name ~= "Football" or not b:IsA("BasePart") then return end
        task.wait()
        local char = Player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        if (b.Position - root.Position).Magnitude > 9 then return end

        local vel = b.Velocity; local pos = b.Position
        local c0, c1, cf1, cf2 = beamProjectile(Vector3.new(0,-28,0), vel, pos, 10)

        local beam = Instance.new("Beam")
        local a0   = Instance.new("Attachment")
        local a1   = Instance.new("Attachment")
        beam.Color       = ColorSequence.new(Color3.fromRGB(255,255,255))
        beam.CurveSize0  = c0; beam.CurveSize1 = c1
        beam.Name        = "PerfHitbox"
        beam.Parent      = Workspace.Terrain
        beam.Segments    = 1750
        beam.FaceCamera  = true
        beam.Width0      = 1; beam.Width1 = 1
        beam.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0,    1),
            NumberSequenceKeypoint.new(0.01, 0),
            NumberSequenceKeypoint.new(0.99, 0),
            NumberSequenceKeypoint.new(1,    0.01),
        })
        a0.Parent = Workspace.Terrain; a0.CFrame = cf1
        a1.Parent = Workspace.Terrain; a1.CFrame = cf2
        beam.Attachment0 = a0; beam.Attachment1 = a1

        local landedConn
        landedConn = RunService.Heartbeat:Connect(function()
            if not b or b.Velocity.Magnitude < 1 then
                landedConn:Disconnect()
                task.delay(0.5, function()
                    pcall(function() beam:Destroy(); a0:Destroy(); a1:Destroy() end)
                end)
            end
        end)
        task.spawn(function()
            repeat task.wait() until not b.Parent or b.Parent ~= Workspace
            pcall(function() beam:Destroy(); a0:Destroy(); a1:Destroy() end)
        end)
    end)
end

local function perfBeam_stop()
    if perfBeamConnection then perfBeamConnection:Disconnect(); perfBeamConnection = nil end
    for _, v in pairs(Workspace:GetChildren()) do
        if v:IsA("Beam") and v.Name == "PerfHitbox" then v:Destroy() end
    end
end

if perfBeamEnabled then perfBeam_start() end

-- ================================================================
-- SECTION 6 — TRAJECTORY ARC — removed per user request
-- ================================================================
local trajEnabled = false  -- kept as variable so UI toggle reference doesn't error

-- ================================================================
-- SECTION 7 — CATCHING & PHYSICS (Kali_Hub source)
-- ================================================================
local autocatchon        = false
local catchdistance      = 10
local magson             = false
local magsrange          = 0
local magsdelayon        = false
local magsdelay          = 0
local showhitboxon       = false
local hitboxes           = {}
local catchresizeon      = false
local catchresizerange   = 10
local lmgg               = 0
local magmode            = "FTI"
local speedEnabled       = false
local speedValue         = 0.1
local movementLoop       = nil
local jumpoweron         = false
local jumpboost          = 50
local nojpcooldownon     = false
local njcconnections     = {}
local pullvector         = false
local pullvectorpower    = 1
local pullvectordistance = 5
local clicktackleon      = false
local clicktacklerange   = 5
local ballpathOn         = false
local ballpathColor      = Color3.fromRGB(128, 0, 128)
local ballpathConnection = nil
local deleteOOBEnabled   = false

local function findclosestball()
    if not Char or not Char:FindFirstChild("HumanoidRootPart") then return nil end
    local hrp = Char.HumanoidRootPart
    local closest, mindist = nil, math.huge
    for _, ball in pairs(Workspace:GetChildren()) do
        if ball.Name:lower():match("football") and ball:IsA("BasePart") and not ball.Anchored then
            local d = (hrp.Position - ball.Position).Magnitude
            if d < mindist then closest, mindist = ball, d end
        end
    end
    return closest, mindist
end

local function hitboxx(oid)
    if not oid or hitboxes[oid] or not magson or not showhitboxon then return end
    local holder = oid:FindFirstAncestorOfClass("Model")
    if holder and Players:GetPlayerFromCharacter(holder) then return end
    local hitbox = Instance.new("Part")
    hitbox.Name        = "Hitbox"
    hitbox.Size        = Vector3.new(magsrange, magsrange, magsrange)
    hitbox.Anchored    = true
    hitbox.CanCollide  = false
    hitbox.Transparency = 0.2
    hitbox.Material    = Enum.Material.ForceField
    hitbox.Color       = Color3.fromRGB(128, 0, 128)
    hitbox.CastShadow  = false
    hitbox.CFrame      = oid.CFrame
    hitbox.Shape       = Enum.PartType.Ball
    hitbox.Parent      = oid
    hitboxes[oid]      = {part = hitbox}
    local conn
    conn = RunService.Heartbeat:Connect(function()
        if not oid or not oid.Parent or not magson or not showhitboxon then
            if hitbox then hitbox:Destroy() end
            if conn then conn:Disconnect() end
            hitboxes[oid] = nil; return
        end
        hitbox.CFrame = oid.CFrame
        hitbox.Size   = Vector3.new(magsrange, magsrange, magsrange)
    end)
end

local function fitbalsize()
    for oid, data in pairs(hitboxes) do
        if data and data.part then
            data.part.Size  = Vector3.new(magsrange, magsrange, magsrange)
        else
            if data and data.part then data.part:Destroy() end
            hitboxes[oid] = nil
        end
    end
end

local function removeHitboxes()
    for _, data in pairs(hitboxes) do
        if data.part then data.part:Destroy() end
    end
    hitboxes = {}
end

local function footballhitbox()
    if not magson then return end
    for _, child in pairs(Workspace:GetChildren()) do
        if child.Name:lower():match("football") and child:IsA("BasePart") then hitboxx(child) end
    end
end

local function getfutbal()
    if not (Char and Char:FindFirstChild("HumanoidRootPart")) then return nil end
    local pp = Char.HumanoidRootPart.Position
    local closest, mindist = nil, math.huge
    for _, child in pairs(Workspace:GetChildren()) do
        if child.Name:lower():match("football") and child:IsA("BasePart") then
            local d = (child.Position - pp).Magnitude
            if d < mindist and d <= magsrange then closest, mindist = child, d end
        end
    end
    return closest
end

local function catchPart(ball)
    if not ball or not Char then return nil end
    local cl = Char:FindFirstChild("CatchLeft")
    local cr = Char:FindFirstChild("CatchRight")
    local closest, mindist = nil, math.huge
    local bp = ball.Position
    -- No magsrange filter here — range is for hitbox display only;
    -- the mag loop uses getfutbal() which already filters by magsrange.
    if cl and cl:IsA("BasePart") then
        local d = (cl.Position - bp).Magnitude
        if d < mindist then closest, mindist = cl, d end
    end
    if cr and cr:IsA("BasePart") then
        local d = (cr.Position - bp).Magnitude
        if d < mindist then closest, mindist = cr, d end
    end
    return closest
end

local function rrrrrrrsizenugget(character)
    if not character then return end
    local sizes = catchresizeon
        and Vector3.new(catchresizerange, catchresizerange, catchresizerange)
        or  Vector3.new(0.75, 5, 1.5)
    local cl = character:FindFirstChild("CatchLeft")
    local cr = character:FindFirstChild("CatchRight")
    if cl then cl.Size = sizes; cl.Transparency = 1 end
    if cr then cr.Size = sizes; cr.Transparency = 1 end
end

local function startMovementSystem()
    if not movementLoop then
        movementLoop = RunService.Heartbeat:Connect(function(dt)
            if not speedEnabled then return end
            local hum = Char and Char:FindFirstChild("Humanoid")
            if hum and hum.MoveDirection.Magnitude > 0 then
                Hrp.CFrame = Hrp.CFrame + (hum.MoveDirection * speedValue * 8 * dt)
            end
        end)
    end
end

local function stopMovementSystem()
    if movementLoop then movementLoop:Disconnect(); movementLoop = nil end
end

local function whenmoving(character)
    if not character then return end
    local hum = character:WaitForChild("Humanoid")
    local hrp = character:WaitForChild("HumanoidRootPart")
    hum.StateChanged:Connect(function(_, state)
        if state == Enum.HumanoidStateType.Jumping and jumpoweron then
            task.wait(0.05)
            hrp.AssemblyLinearVelocity = hrp.AssemblyLinearVelocity + Vector3.new(0, jumpboost - 50, 0)
        end
    end)
end

local function njc(char)
    if not char then return end
    local hum = char:WaitForChild("Humanoid")
    local conn = RunService.Stepped:Connect(function()
        if nojpcooldownon then hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true) end
    end)
    njcconnections[char] = conn
end

local function findclosesttackle(maxd)
    if not Char then return nil end
    local hrp = Char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local closest, closestd = nil, maxd
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == Player or plr.Team == Player.Team then continue end
        local tc = plr.Character
        if not tc then continue end
        local thrp = tc:FindFirstChild("HumanoidRootPart")
        if not thrp then continue end
        local hasBall = false
        for _, item in ipairs(tc:GetChildren()) do
            if item:IsA("Tool") and item.Name:match("Football") then hasBall = true; break end
        end
        if not hasBall then continue end
        local d = (hrp.Position - thrp.Position).Magnitude
        if d < closestd then closestd = d; closest = tc end
    end
    return closest
end

local function TriggerTouchEvent()
    local xPos = Camera.ViewportSize.X / 2
    local yPos = Camera.ViewportSize.Y / 2
    VIM:SendTouchEvent(1, Enum.UserInputState.Begin.Value,  xPos, yPos)
    task.wait(0.005)
    VIM:SendTouchEvent(1, Enum.UserInputState.End.Value,    xPos, yPos)
end

-- Main Heartbeat
RunService.Heartbeat:Connect(function(dt)
    if not Hrp then return end
    if magson then
        local ball = getfutbal()
        if ball then
            local cnp = tick()
            if magsdelayon and (cnp - lmgg) < magsdelay then
                -- wait
            else
                local cp = catchPart(ball)
                if cp then
                    if magmode == "CFrame" then
                        ball.CFrame = cp.CFrame
                    else
                        if typeof(firetouchinterest) == "function" then
                            -- ball must touch the catch part, so: firetouchinterest(catchPart, ball, ...)
                            pcall(firetouchinterest, ball, cp, 0)
                            task.wait()
                            pcall(firetouchinterest, ball, cp, 1)
                        else
                            ball.CFrame = cp.CFrame
                        end
                    end
                end
                if magsdelayon then lmgg = cnp end
            end
        end
    end
end)

Workspace.ChildAdded:Connect(function(child)
    if child.Name:lower():match("football") and magson and showhitboxon and child:IsA("BasePart") then
        hitboxx(child)
    end
end)

task.spawn(function()
    while task.wait(0.02) do
        if not autocatchon then continue end
        local ball, distance = findclosestball()
        if ball and distance <= catchdistance then TriggerTouchEvent() end
    end
end)

task.spawn(function()
    while task.wait(0.1) do
        if not pullvector or not Char or not Hrp then continue end
        for _, ball in pairs(Workspace:GetChildren()) do
            if ball.Name:lower():match("football") and ball:IsA("BasePart") then
                local d = (Hrp.Position - ball.Position).Magnitude
                if d <= pullvectordistance then
                    local dir = (ball.Position - Hrp.Position).Unit
                    Hrp.AssemblyLinearVelocity = dir * pullvectorpower * 25
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(1) do
        if not deleteOOBEnabled then continue end
        for _, obj in pairs(Workspace:GetChildren()) do
            if obj:IsA("BasePart") and obj.Position.Y < -100 then obj:Destroy() end
        end
    end
end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1
       or input.UserInputType == Enum.UserInputType.Touch then
        if clicktackleon then
            local tc = findclosesttackle(clicktacklerange)
            if tc and tc:FindFirstChild("HumanoidRootPart") and Hrp then
                Hrp.CFrame = tc.HumanoidRootPart.CFrame
            end
        end
    end
end)

if Player.Character then
    rrrrrrrsizenugget(Player.Character); whenmoving(Player.Character); njc(Player.Character)
end
Player.CharacterAdded:Connect(function(char)
    rrrrrrrsizenugget(char); whenmoving(char); njc(char)
    removeHitboxes()
end)

-- ================================================================
-- SECTION 8A — KICKER AIMBOT (KickerAimbot.lua)
-- ================================================================
local kickerAutoEnabled = false
local kickerPower       = 95    -- 1-100: higher = more power (cursor click earlier)
local kickerAcc         = 75    -- 1-100: higher = more accuracy (cursor click later)

local function handleKickerGui(child)
    if child.Name ~= "KickerGui" or not kickerAutoEnabled then return end
    task.spawn(function()
        -- wait for Cursor to exist
        local cursor
        local deadline = tick() + 5
        repeat cursor = child:FindFirstChild("Cursor", true); task.wait() until cursor or tick() > deadline
        if not cursor then return end

        -- Wait until cursor descends to power threshold (top of bar = low Y, so we wait until Y grows)
        local powerThreshold = 0.01 + ((100 - kickerPower) * 0.012)
        repeat task.wait() until not child.Parent
            or cursor.Position.Y.Scale >= powerThreshold
        if not child.Parent then return end
        -- Delta-compatible click (mouse1click not available in Delta)
        local _cx = Camera.ViewportSize.X / 2
        local _cy = Camera.ViewportSize.Y / 2
        VIM:SendMouseButtonEvent(_cx, _cy, 0, true,  game, 1)
        task.wait(0.05)
        VIM:SendMouseButtonEvent(_cx, _cy, 0, false, game, 1)

        -- Wait until cursor reaches accuracy threshold
        local accThreshold = 0.9 - ((100 - kickerAcc) * 0.001)
        repeat task.wait() until not child.Parent
            or cursor.Position.Y.Scale >= accThreshold
        if not child.Parent then return end
        -- Delta-compatible click
        local _cx2 = Camera.ViewportSize.X / 2
        local _cy2 = Camera.ViewportSize.Y / 2
        VIM:SendMouseButtonEvent(_cx2, _cy2, 0, true,  game, 1)
        task.wait(0.05)
        VIM:SendMouseButtonEvent(_cx2, _cy2, 0, false, game, 1)
    end)
end

Player:WaitForChild("PlayerGui").ChildAdded:Connect(function(child)
    if kickerAutoEnabled then handleKickerGui(child) end
end)

-- ================================================================
-- SECTION 8B — KICK EXTENDER (KickExtender.lua)
-- ================================================================
local kickExtendEnabled = false
local kickExtendSize    = 15

local function applyKickExtend(v)
    if not kickExtendEnabled then return end
    if v:IsA("BasePart") then
        local ks = v:FindFirstChild("KickingSound")
        if ks and ks:IsA("Sound") and v.Parent == Workspace then
            v.Size = Vector3.new(kickExtendSize, kickExtendSize, kickExtendSize)
        end
    end
end

local kickExtendConn = nil

local function startKickExtend()
    if kickExtendConn then return end
    for _, v in pairs(Workspace:GetChildren()) do applyKickExtend(v) end
    kickExtendConn = Workspace.DescendantAdded:Connect(function(v)
        task.wait()
        applyKickExtend(v)
    end)
end

local function stopKickExtend()
    if kickExtendConn then kickExtendConn:Disconnect(); kickExtendConn = nil end
end

-- ================================================================
-- SECTION 8C — TACKLE AIMBOT (TackleAimbot.lua)
-- ================================================================
local tackleAimbotEnabled = false
local tackleAimbotRange   = 15

local function runTackleAimbot(character)
    if not tackleAimbotEnabled then return end
    local playerRoot = character and character:FindFirstChild("HumanoidRootPart")
    if not playerRoot then return end

    for _, player in ipairs(Players:GetPlayers()) do
        if player == Player then continue end
        local tc = player.Character
        if not tc then continue end

        -- Only target players who have the football
        local hasBall = false
        for _, item in ipairs(tc:GetDescendants()) do
            if item:IsA("Tool") and item.Name:lower():find("football") then
                hasBall = true; break
            end
        end
        if not hasBall then continue end

        local catchRight = tc:FindFirstChild("CatchRight")
        if not catchRight then continue end

        local dist = (playerRoot.Position - catchRight.Position).Magnitude
        if dist >= tackleAimbotRange then continue end

        -- Teleport our CatchRight onto their CatchRight
        local myCR = character:FindFirstChild("CatchRight")
        if myCR then
            myCR.CFrame = CFrame.new(catchRight.Position)
            return  -- only tackle the nearest ball carrier
        end
    end
end

-- Hook into the existing M1 InputBegan (runs alongside click tackle)
-- We use a dedicated connection so it's independently toggleable
local tackleAimbotConn = nil

local function setupTackleAimbot(character)
    if tackleAimbotConn then tackleAimbotConn:Disconnect() end
    tackleAimbotConn = UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe or not tackleAimbotEnabled then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1
           or input.UserInputType == Enum.UserInputType.Touch
           or (input.UserInputType == Enum.UserInputType.Gamepad1
               and input.KeyCode == Enum.KeyCode.ButtonR2) then
            runTackleAimbot(character or Player.Character)
        end
    end)
end

if Player.Character then setupTackleAimbot(Player.Character) end
Player.CharacterAdded:Connect(function(c) setupTackleAimbot(c) end)

-- ================================================================
-- SECTION 8E — ANTI-LAG (Anti-Lag.lua)
-- ================================================================
local antiLagEnabled = false

local function applyAntiLag()
    for _, part in pairs(Workspace:GetDescendants()) do
        if part:IsA("BasePart") then
            pcall(function() part.Material = Enum.Material.SmoothPlastic end)
        end
    end
end

-- ================================================================
-- SECTION 8F — TACKLE REACH (TackleReach.lua)
-- ================================================================
local tackleReachEnabled = false
local tackleReachRange   = 15

local function runTackleReach()
    if not tackleReachEnabled then return end
    local character = Char
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    -- FF2: football is a BasePart named "Football" in workspace
    -- The carrier is whoever is closest to it
    local football = Workspace:FindFirstChild("Football")

    for _, target in pairs(Players:GetPlayers()) do
        if target == Player then continue end
        local tc = target.Character
        if not tc then continue end
        local targetHrp = tc:FindFirstChild("HumanoidRootPart")
        if not targetHrp then continue end

        -- Ball carrier check: player's HRP is within 6 studs of the football
        local hasBall = false
        if football and football:IsA("BasePart") then
            hasBall = (football.Position - targetHrp.Position).Magnitude < 6
        end
        -- Fallback: check for Tool in character
        if not hasBall then
            hasBall = tc:FindFirstChildOfClass("Tool") ~= nil
        end
        if not hasBall then continue end

        local dist = (hrp.Position - targetHrp.Position).Magnitude
        if dist > tackleReachRange then continue end

        for _, targetPart in pairs(tc:GetChildren()) do
            if targetPart:IsA("BasePart") then
                local myPart = character:FindFirstChild(targetPart.Name)
                if myPart then
                    pcall(function()
                        if typeof(firetouchinterest) == "function" then
                            firetouchinterest(myPart, targetPart, 0)
                        end
                    end)
                end
            end
        end
    end
end

RunService.Heartbeat:Connect(runTackleReach)

-- ================================================================
-- SECTION 8G — BLOCK REACH (BlockReach.lua)
-- ================================================================
local blockReachEnabled = false
local blockReachSize    = 20
local blockReachOpacity = 0.5

local function applyBlockReach(character)
    if not character then return end
    local blockP = character:FindFirstChild("BlockPart")
    if not blockP then return end
    if blockReachEnabled then
        blockP.Size        = Vector3.new(blockReachSize, blockReachSize, blockReachSize)
        blockP.Transparency = blockReachOpacity
    else
        -- Reset to default values
        blockP.Size        = Vector3.new(2, 2, 2)
        blockP.Transparency = 1
    end
end

local function refreshBlockReach()
    applyBlockReach(Char)
end

Player.CharacterAdded:Connect(function(c)
    task.wait(1) -- wait for BlockPart to load
    applyBlockReach(c)
end)

-- ================================================================
-- SECTION 8 — CUSTOM UI  (ExampleUI style)
-- ================================================================

-- ── Services already defined above ───────────────────────────────
-- TweenService, UserInputService, Players, Player already declared

-- ── Cleanup old UI ───────────────────────────────────────────────
local _pg = Player:WaitForChild("PlayerGui")
if _pg:FindFirstChild("AethelHubUI") then _pg.AethelHubUI:Destroy() end

-- ================================================================
-- UI CONSTANTS & COLORS
-- ================================================================
local C_BG        = Color3.fromRGB(10, 10, 20)
local C_TITLEBAR  = Color3.fromRGB(6, 6, 16)
local C_ROW       = Color3.fromRGB(13, 13, 26)
local C_ACCENT    = Color3.fromRGB(108, 99, 255)
local C_ACCENT2   = Color3.fromRGB(80, 72, 200)
local C_STROKE    = Color3.fromRGB(60, 50, 120)
local C_TEXT      = Color3.fromRGB(210, 210, 210)
local C_TABTEXT   = Color3.fromRGB(160, 155, 230)
local C_DIMTEXT   = Color3.fromRGB(120, 115, 160)
local C_OFF       = Color3.fromRGB(26, 26, 46)
local C_OFFSTROKE = Color3.fromRGB(50, 50, 80)
local C_GREEN     = Color3.fromRGB(80, 210, 120)

-- ================================================================
-- SCREEN GUI
-- ================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name           = "AethelHubUI"
ScreenGui.ResetOnSpawn   = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder   = 5
ScreenGui.Parent         = _pg

-- ── Main window ──────────────────────────────────────────────────
local WIN_W, WIN_H = 400, 380
local MainFrame = Instance.new("Frame")
MainFrame.Name             = "MainFrame"
MainFrame.Size             = UDim2.new(0, WIN_W, 0, WIN_H)
MainFrame.Position         = UDim2.new(0, 8, 0, 8)   -- top-left, out of the way
MainFrame.BackgroundColor3 = C_BG
MainFrame.BorderSizePixel  = 0
MainFrame.Parent           = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
local _ms = Instance.new("UIStroke", MainFrame)
_ms.Color = C_STROKE; _ms.Thickness = 1.5

-- ── Title bar ────────────────────────────────────────────────────
local TitleBar = Instance.new("Frame")
TitleBar.Size             = UDim2.new(1, 0, 0, 46)
TitleBar.BackgroundColor3 = C_TITLEBAR
TitleBar.BorderSizePixel  = 0
TitleBar.Parent           = MainFrame
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 12)
-- patch bottom corners
local _tbfix = Instance.new("Frame", TitleBar)
_tbfix.Size = UDim2.new(1,0,0.5,0); _tbfix.Position = UDim2.new(0,0,0.5,0)
_tbfix.BackgroundColor3 = C_TITLEBAR; _tbfix.BorderSizePixel = 0

local TitleLabel = Instance.new("TextLabel", TitleBar)
TitleLabel.Size = UDim2.new(1,-90,1,0); TitleLabel.Position = UDim2.new(0,14,0,0)
TitleLabel.BackgroundTransparency = 1; TitleLabel.Text = "✦  Aethel Hub"
TitleLabel.TextColor3 = Color3.fromRGB(130,140,255); TitleLabel.TextSize = 15
TitleLabel.Font = Enum.Font.GothamBold; TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Close button
local CloseBtn = Instance.new("TextButton", TitleBar)
CloseBtn.Size = UDim2.new(0,34,0,34); CloseBtn.Position = UDim2.new(1,-40,0.5,-17)
CloseBtn.BackgroundColor3 = Color3.fromRGB(180,40,40); CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255,255,255); CloseBtn.TextSize = 14
CloseBtn.Font = Enum.Font.GothamBold; CloseBtn.BorderSizePixel = 0
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0,8)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- Hide button
local HideBtn = Instance.new("TextButton", TitleBar)
HideBtn.Size = UDim2.new(0,34,0,34); HideBtn.Position = UDim2.new(1,-80,0.5,-17)
HideBtn.BackgroundColor3 = Color3.fromRGB(40,40,80); HideBtn.Text = "—"
HideBtn.TextColor3 = Color3.fromRGB(200,200,255); HideBtn.TextSize = 15
HideBtn.Font = Enum.Font.GothamBold; HideBtn.BorderSizePixel = 0
Instance.new("UICorner", HideBtn).CornerRadius = UDim.new(0,8)

-- Show button (bigger, easy to tap on mobile)
local ShowBtn = Instance.new("TextButton", ScreenGui)
ShowBtn.Size = UDim2.new(0,130,0,40); ShowBtn.Position = UDim2.new(0,8,0,8)
ShowBtn.BackgroundColor3 = C_BG; ShowBtn.Text = "▶  Aethel Hub"
ShowBtn.TextColor3 = Color3.fromRGB(200,200,255); ShowBtn.TextSize = 13
ShowBtn.Font = Enum.Font.GothamBold; ShowBtn.BorderSizePixel = 0; ShowBtn.Visible = false
Instance.new("UICorner", ShowBtn).CornerRadius = UDim.new(0,10)
local _showS = Instance.new("UIStroke", ShowBtn)
_showS.Color = C_STROKE; _showS.Thickness = 1.5

-- UI opens automatically after key is accepted; Hide button minimises it

HideBtn.MouseButton1Click:Connect(function()
    TweenService:Create(MainFrame, TweenInfo.new(0.18), {Size = UDim2.new(0,WIN_W,0,0)}):Play()
    task.delay(0.2, function() MainFrame.Visible = false; ShowBtn.Visible = true end)
end)
ShowBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = true; ShowBtn.Visible = false
    MainFrame.Size = UDim2.new(0,WIN_W,0,0)
    TweenService:Create(MainFrame, TweenInfo.new(0.18), {Size = UDim2.new(0,WIN_W,0,WIN_H)}):Play()
end)

-- Divider under title
local _div = Instance.new("Frame", MainFrame)
_div.Size = UDim2.new(1,-24,0,1); _div.Position = UDim2.new(0,12,0,46)
_div.BackgroundColor3 = Color3.fromRGB(40,35,80); _div.BorderSizePixel = 0

-- ── Drag ─────────────────────────────────────────────────────────
do
    local _df, _ds, _sp = false, nil, nil
    TitleBar.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            _df = true; _ds = inp.Position; _sp = MainFrame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if _df and (inp.UserInputType == Enum.UserInputType.MouseMovement
                 or inp.UserInputType == Enum.UserInputType.Touch) then
            local d = inp.Position - _ds
            MainFrame.Position = UDim2.new(_sp.X.Scale, _sp.X.Offset+d.X,
                                           _sp.Y.Scale, _sp.Y.Offset+d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then _df = false end
    end)
end

-- ================================================================
-- TAB BAR
-- ================================================================
local TAB_NAMES = {"Catching","Physics","QB / Throw","Kicker","Tackle","Movement","Misc"}
local activeTab = nil
local tabButtons = {}
local tabFrames  = {}

local TabBar = Instance.new("Frame", MainFrame)
TabBar.Size = UDim2.new(1,-2,0,32)
TabBar.Position = UDim2.new(0,1,0,47)
TabBar.BackgroundColor3 = Color3.fromRGB(8,8,18)
TabBar.BorderSizePixel = 0
local _tbLayout = Instance.new("UIListLayout", TabBar)
_tbLayout.FillDirection = Enum.FillDirection.Horizontal
_tbLayout.Padding = UDim.new(0,0)
_tbLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Tab divider
local _tabDiv = Instance.new("Frame", MainFrame)
_tabDiv.Size = UDim2.new(1,-2,0,1); _tabDiv.Position = UDim2.new(0,1,0,79)
_tabDiv.BackgroundColor3 = Color3.fromRGB(40,35,80); _tabDiv.BorderSizePixel = 0

-- Content area
local ContentArea = Instance.new("Frame", MainFrame)
ContentArea.Size = UDim2.new(1,-2,1,-82)
ContentArea.Position = UDim2.new(0,1,0,81)
ContentArea.BackgroundTransparency = 1
ContentArea.BorderSizePixel = 0
ContentArea.ClipsDescendants = true

local function makeTabFrame()
    local sf = Instance.new("ScrollingFrame", ContentArea)
    sf.Size = UDim2.new(1,0,1,0); sf.Position = UDim2.new(0,0,0,0)
    sf.BackgroundTransparency = 1; sf.BorderSizePixel = 0
    sf.ScrollBarThickness = 3
    sf.ScrollBarImageColor3 = C_ACCENT
    sf.CanvasSize = UDim2.new(0,0,0,0)
    sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
    sf.Visible = false
    local ll = Instance.new("UIListLayout", sf)
    ll.Padding = UDim.new(0,5)
    local pad = Instance.new("UIPadding", sf)
    pad.PaddingLeft = UDim.new(0,12); pad.PaddingRight = UDim.new(0,12)
    pad.PaddingTop = UDim.new(0,8);   pad.PaddingBottom = UDim.new(0,10)
    return sf
end

local function switchTab(name)
    for n, f in pairs(tabFrames) do
        f.Visible = (n == name)
    end
    for n, b in pairs(tabButtons) do
        b.BackgroundColor3 = (n == name) and C_ACCENT2 or Color3.fromRGB(8,8,18)
        b.TextColor3        = (n == name) and Color3.fromRGB(255,255,255) or C_TABTEXT
    end
    activeTab = name
end

local tabW = math.floor(WIN_W / #TAB_NAMES)
for i, name in ipairs(TAB_NAMES) do
    local btn = Instance.new("TextButton", TabBar)
    btn.Size = UDim2.new(0, tabW, 1, 0)
    btn.BackgroundColor3 = Color3.fromRGB(8,8,18)
    btn.BorderSizePixel = 0
    btn.Text = name
    btn.TextColor3 = C_TABTEXT
    btn.TextSize = 11
    btn.Font = Enum.Font.GothamBold
    btn.LayoutOrder = i
    btn.AutoButtonColor = false
    btn.TextScaled = false
    btn.ClipsDescendants = true
    Instance.new("UITextSizeConstraint", btn).MaxTextSize = 11
    tabButtons[name] = btn
    tabFrames[name]  = makeTabFrame()
    btn.MouseButton1Click:Connect(function() switchTab(name) end)
end

-- ================================================================
-- UI HELPER FUNCTIONS
-- ================================================================

local function AddSection(parent, title)
    local lbl = Instance.new("TextLabel", parent)
    lbl.Size = UDim2.new(1,0,0,20)
    lbl.BackgroundTransparency = 1
    lbl.Text = title:upper()
    lbl.TextColor3 = C_ACCENT
    lbl.TextSize = 10
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
end

local function AddLabel(parent, text)
    local lbl = Instance.new("TextLabel", parent)
    lbl.Size = UDim2.new(1,0,0,18)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = C_DIMTEXT
    lbl.TextSize = 11
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
end

local function AddToggle(parent, labelText, default, callback)
    local state = default or false
    local Row = Instance.new("Frame", parent)
    Row.Size = UDim2.new(1,0,0,38)
    Row.BackgroundColor3 = C_ROW
    Row.BorderSizePixel = 0
    Instance.new("UICorner", Row).CornerRadius = UDim.new(0,8)

    local lbl = Instance.new("TextLabel", Row)
    lbl.Size = UDim2.new(1,-52,1,0); lbl.Position = UDim2.new(0,12,0,0)
    lbl.BackgroundTransparency = 1; lbl.Text = labelText
    lbl.TextColor3 = C_TEXT; lbl.TextSize = 12; lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local tbtn = Instance.new("TextButton", Row)
    tbtn.Size = UDim2.new(0,26,0,26); tbtn.Position = UDim2.new(1,-38,0.5,-13)
    tbtn.BackgroundColor3 = state and C_ACCENT or C_OFF
    tbtn.Text = state and "✓" or ""; tbtn.TextColor3 = Color3.fromRGB(255,255,255)
    tbtn.TextSize = 13; tbtn.Font = Enum.Font.GothamBold; tbtn.BorderSizePixel = 0
    Instance.new("UICorner", tbtn).CornerRadius = UDim.new(0,6)
    local tks = Instance.new("UIStroke", tbtn)
    tks.Color = state and C_ACCENT or C_OFFSTROKE; tks.Thickness = 1.5

    tbtn.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(tbtn, TweenInfo.new(0.15), {BackgroundColor3 = state and C_ACCENT or C_OFF}):Play()
        tks.Color = state and C_ACCENT or C_OFFSTROKE
        tbtn.Text = state and "✓" or ""
        if callback then callback(state) end
    end)
    return Row
end

local function AddSlider(parent, labelText, minVal, maxVal, default, rounding, callback)
    rounding = rounding or 1
    local value = default or minVal
    local dragging = false

    local Con = Instance.new("Frame", parent)
    Con.Size = UDim2.new(1,0,0,52)
    Con.BackgroundColor3 = C_ROW
    Con.BorderSizePixel = 0
    Instance.new("UICorner", Con).CornerRadius = UDim.new(0,8)

    local lbl = Instance.new("TextLabel", Con)
    lbl.Size = UDim2.new(0.68,0,0,22); lbl.Position = UDim2.new(0,12,0,5)
    lbl.BackgroundTransparency = 1; lbl.Text = labelText
    lbl.TextColor3 = C_TEXT; lbl.TextSize = 12; lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local valLbl = Instance.new("TextLabel", Con)
    valLbl.Size = UDim2.new(0.3,-12,0,22); valLbl.Position = UDim2.new(0.7,0,0,5)
    valLbl.BackgroundTransparency = 1
    valLbl.Text = rounding == 0 and string.format("%d", value) or string.format("%.2f", value)
    valLbl.TextColor3 = C_ACCENT; valLbl.TextSize = 11; valLbl.Font = Enum.Font.GothamBold
    valLbl.TextXAlignment = Enum.TextXAlignment.Right

    local Track = Instance.new("Frame", Con)
    Track.Size = UDim2.new(1,-24,0,5); Track.Position = UDim2.new(0,12,0,34)
    Track.BackgroundColor3 = C_OFF; Track.BorderSizePixel = 0
    Instance.new("UICorner", Track).CornerRadius = UDim.new(1,0)

    local fillPct = (value - minVal) / math.max(maxVal - minVal, 0.001)
    local Fill = Instance.new("Frame", Track)
    Fill.Size = UDim2.new(fillPct,0,1,0); Fill.BackgroundColor3 = C_ACCENT; Fill.BorderSizePixel = 0
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(1,0)

    local Knob = Instance.new("Frame", Track)
    Knob.Size = UDim2.new(0,12,0,12); Knob.Position = UDim2.new(fillPct,-6,0.5,-6)
    Knob.BackgroundColor3 = Color3.fromRGB(255,255,255); Knob.BorderSizePixel = 0; Knob.ZIndex = 3
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1,0)
    local ks = Instance.new("UIStroke", Knob)
    ks.Color = C_ACCENT; ks.Thickness = 2

    local function update(ix)
        local ts = Track.AbsoluteSize.X
        if ts <= 1 then return end   -- frame not rendered yet, ignore
        local tp  = Track.AbsolutePosition.X
        local rel = math.clamp((ix - tp) / ts, 0, 1)
        local raw = minVal + rel * (maxVal - minVal)
        local rounded
        if rounding == 0 then
            rounded = math.floor(raw + 0.5)
        else
            local factor = 10 ^ rounding
            rounded = math.floor(raw * factor + 0.5) / factor
        end
        value = rounded
        Fill.Size = UDim2.new(rel,0,1,0)
        Knob.Position = UDim2.new(rel,-6,0.5,-6)
        valLbl.Text = rounding == 0 and string.format("%d", rounded) or string.format("%.2f", rounded)
        if callback then callback(rounded) end
    end

    Track.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = true; update(inp.Position.X)
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement
                      or inp.UserInputType == Enum.UserInputType.Touch) then
            update(inp.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    return Con
end

local function AddDropdown(parent, labelText, options, defaultIndex, callback)
    defaultIndex = defaultIndex or 1
    local selected = defaultIndex
    local open = false

    local Con = Instance.new("Frame", parent)
    Con.Size = UDim2.new(1,0,0,38)
    Con.BackgroundColor3 = C_ROW
    Con.BorderSizePixel = 0
    Instance.new("UICorner", Con).CornerRadius = UDim.new(0,8)
    Con.ZIndex = 5

    local lbl = Instance.new("TextLabel", Con)
    lbl.Size = UDim2.new(0.55,0,1,0); lbl.Position = UDim2.new(0,12,0,0)
    lbl.BackgroundTransparency = 1; lbl.Text = labelText
    lbl.TextColor3 = C_TEXT; lbl.TextSize = 12; lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 5

    local btn = Instance.new("TextButton", Con)
    btn.Size = UDim2.new(0.42,0,0,26); btn.Position = UDim2.new(0.57,0,0.5,-13)
    btn.BackgroundColor3 = C_ACCENT2; btn.BorderSizePixel = 0
    btn.Text = options[selected] .. " ▾"
    btn.TextColor3 = Color3.fromRGB(255,255,255); btn.TextSize = 11
    btn.Font = Enum.Font.GothamBold; btn.ZIndex = 5
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)

    -- Dropdown list (appears below)
    local list = Instance.new("Frame", Con)
    list.Size = UDim2.new(0.42,0,0, #options * 28)
    list.Position = UDim2.new(0.57,0,1,2)
    list.BackgroundColor3 = Color3.fromRGB(18,18,32)
    list.BorderSizePixel = 0; list.Visible = false; list.ZIndex = 10
    Instance.new("UICorner", list).CornerRadius = UDim.new(0,6)
    local ls = Instance.new("UIStroke", list); ls.Color = C_STROKE; ls.Thickness = 1; ls.ZIndex = 10
    local ll = Instance.new("UIListLayout", list); ll.Padding = UDim.new(0,0)

    for i, opt in ipairs(options) do
        local ob = Instance.new("TextButton", list)
        ob.Size = UDim2.new(1,0,0,28); ob.BackgroundTransparency = 1
        ob.Text = opt; ob.TextColor3 = C_TEXT; ob.TextSize = 11
        ob.Font = Enum.Font.Gotham; ob.ZIndex = 11
        ob.MouseEnter:Connect(function() ob.TextColor3 = Color3.fromRGB(255,255,255) end)
        ob.MouseLeave:Connect(function() ob.TextColor3 = C_TEXT end)
        ob.MouseButton1Click:Connect(function()
            selected = i
            btn.Text = options[selected] .. " ▾"
            list.Visible = false; open = false
            if callback then callback(options[selected], selected) end
        end)
    end

    btn.MouseButton1Click:Connect(function()
        open = not open; list.Visible = open
    end)
    -- Expand parent height when open
    list:GetPropertyChangedSignal("Visible"):Connect(function()
        Con.Size = list.Visible
            and UDim2.new(1,0,0, 38 + #options*28 + 4)
            or  UDim2.new(1,0,0, 38)
    end)

    if callback then callback(options[selected], selected) end
    return Con
end

-- ================================================================
-- CATCHING TAB
-- ================================================================
local tfCatch = tabFrames["Catching"]
AddSection(tfCatch, "Mags")
AddSlider(tfCatch, "Mag Range", 0, 20, 0, 1, function(v)
    magsrange = v; if magson and showhitboxon then fitbalsize() end
end)
AddToggle(tfCatch, "Mags", false, function(v)
    magson = v
    if not v then removeHitboxes() elseif showhitboxon then footballhitbox() end
end)
AddSlider(tfCatch, "Mag Delay", 0, 1, 0, 1, function(v)
    magsdelay = v; magsdelayon = v > 0
end)
AddDropdown(tfCatch, "Mag Mode", {"FTI", "CFrame"}, 1, function(v)
    magmode = v
end)
AddToggle(tfCatch, "Show Hitbox", false, function(v)
    showhitboxon = v
    if not v then removeHitboxes() elseif magson then footballhitbox() end
end)
AddToggle(tfCatch, "Auto Catch", false, function(v) autocatchon = v end)
AddSlider(tfCatch, "Auto Catch Radius", 1, 25, 10, 1, function(v) catchdistance = v end)

AddSection(tfCatch, "Football")
AddToggle(tfCatch, "Ball Path", false, function(v)
    ballpathOn = v
    if not v then
        if ballpathConnection then ballpathConnection:Disconnect(); ballpathConnection = nil end
        for _, obj in ipairs(Workspace.Terrain:GetChildren()) do
            if obj:IsA("Beam") and obj.Name == "BallPath" then obj:Destroy()
            elseif obj:IsA("Attachment") and obj.Name == "BallPathAtt" then obj:Destroy() end
        end
    else
        if ballpathConnection then ballpathConnection:Disconnect() end
        ballpathConnection = Workspace.ChildAdded:Connect(function(ball)
            if not (ball.Name:lower():find("football") and ball:IsA("BasePart")) then return end
            task.wait()
            local vel = ball.Velocity; local pos = ball.Position
            local c0, c1, cf1, cf2 = beamProjectile(Vector3.new(0,-28,0), vel, pos, 10)
            local bm = Instance.new("Beam")
            local ba0 = Instance.new("Attachment"); local ba1 = Instance.new("Attachment")
            bm.Color = ColorSequence.new{ColorSequenceKeypoint.new(0,ballpathColor),ColorSequenceKeypoint.new(1,ballpathColor)}
            bm.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(0.01,0),NumberSequenceKeypoint.new(0.99,0),NumberSequenceKeypoint.new(1,0.01)}
            bm.CurveSize0=c0; bm.CurveSize1=c1; bm.Segments=1750; bm.Width0=1; bm.Width1=1
            bm.Name="BallPath"; bm.Parent=Workspace.Terrain
            ba0.Parent=Workspace.Terrain; ba0.Name="BallPathAtt"; ba0.CFrame=ba0.Parent.CFrame:Inverse()*cf1
            ba1.Parent=Workspace.Terrain; ba1.Name="BallPathAtt"; ba1.CFrame=ba1.Parent.CFrame:Inverse()*cf2
            bm.Attachment0=ba0; bm.Attachment1=ba1
            local hbc
            hbc = RunService.Heartbeat:Connect(function()
                if ball.Velocity.Magnitude < 1 then
                    hbc:Disconnect()
                    pcall(function() bm:Destroy(); ba0:Destroy(); ba1:Destroy() end)
                end
            end)
            task.spawn(function()
                repeat task.wait() until not ball.Parent
                pcall(function() bm:Destroy(); ba0:Destroy(); ba1:Destroy() end)
            end)
        end)
    end
end)
AddToggle(tfCatch, "Perfect Beam (catches)", false, function(v)
    perfBeamEnabled = v
    if v then perfBeam_start() else perfBeam_stop() end
end)

AddSection(tfCatch, "Speed")
AddSlider(tfCatch, "Speed Value", 1, 12, 1, 1, function(v) speedValue = v/10 end)
AddToggle(tfCatch, "CFrame Speed", false, function(v)
    speedEnabled = v; if v then startMovementSystem() else stopMovementSystem() end
end)

AddSection(tfCatch, "Pull Vector")
AddToggle(tfCatch, "Pull Vector", false, function(v) pullvector = v end)
AddSlider(tfCatch, "Pull Speed", 1, 3, 1, 1, function(v) pullvectorpower = v end)
AddSlider(tfCatch, "Pull Radius", 1, 25, 5, 1, function(v) pullvectordistance = v end)

-- ================================================================
-- PHYSICS TAB
-- ================================================================
local tfPhys = tabFrames["Physics"]
AddSection(tfPhys, "Jump Power")
AddToggle(tfPhys, "Jump Power Boost", false, function(v) jumpoweron = v end)
AddSlider(tfPhys, "Jump Boost", 50, 65, 50, 1, function(v) jumpboost = v end)

AddSection(tfPhys, "Jump Cooldown")
AddToggle(tfPhys, "No Jump Cooldown", false, function(v)
    nojpcooldownon = v
    if not v and Player.Character then
        local conn = njcconnections[Player.Character]
        if conn then conn:Disconnect(); njcconnections[Player.Character] = nil end
    elseif v and Player.Character then njc(Player.Character) end
end)

AddSection(tfPhys, "World")
AddToggle(tfPhys, "Delete OOB Parts", false, function(v) deleteOOBEnabled = v end)

AddSection(tfPhys, "Click Tackle")
AddToggle(tfPhys, "Click Tackle", false, function(v) clicktackleon = v end)
AddSlider(tfPhys, "Tackle Range", 1, 15, 5, 1, function(v) clicktacklerange = v end)

-- ================================================================
-- QB / THROW TAB
-- ================================================================
local tfQB = tabFrames["QB / Throw"]
AddSection(tfQB, "QB Aimbot")
AddToggle(tfQB, "QB Aimbot Enabled", false, function(v)
    qbEnabled = v
    if not v then qb_beam.Enabled=false; qb_HL.Enabled=false; qb_gui.Enabled=false end
end)
AddLabel(tfQB, "E / Space = throw  ·  M1 = throw (when holding ball)")
AddLabel(tfQB, "Q = cycle fwd  ·  Tab = cycle back")
AddLabel(tfQB, "G = lock / unlock target")
AddLabel(tfQB, "Controller: R2=throw  R1/L1=cycle  B=lock")
AddLabel(tfQB, "Mobile: ⚡throw  ↻cycle  🎯lock")

AddSection(tfQB, "QB Options")
AddToggle(tfQB, "Auto Angle", false, function(v) qb_autoAngle = v end)
AddSlider(tfQB, "Manual Angle (when Auto off)", 1, 60, 25, 1, function(v) qb_manualAngle = v end)
AddToggle(tfQB, "Auto Power", false, function(v) qb_autoPower = v end)
AddToggle(tfQB, "Anti Out-Of-Bounds", false, function(v) qb_antiOOB = v end)

AddSection(tfQB, "Lead Distance (studs ahead of WR)")
AddLabel(tfQB, "0 = pure physics only. Increase if underthrown.")
AddSlider(tfQB, "Dime Lead",   0, 15, 5,  0, function(v) qb_leadOverride.Dime   = v end)
AddSlider(tfQB, "Mag Lead",    0, 15, 6,  0, function(v) qb_leadOverride.Mag    = v end)
AddSlider(tfQB, "Dive Lead",   0, 15, 6,  0, function(v) qb_leadOverride.Dive   = v end)
AddSlider(tfQB, "Jump Lead",   0, 15, 5,  0, function(v) qb_leadOverride.Jump   = v end)
AddSlider(tfQB, "Slant Lead",  0, 15, 4,  0, function(v) qb_leadOverride.Slant  = v end)
AddSlider(tfQB, "Bullet Lead", 0, 15, 3,  0, function(v) qb_leadOverride.Bullet = v end)
AddSlider(tfQB, "Lob Lead",    0, 15, 7,  0, function(v) qb_leadOverride.Lob    = v end)
AddSlider(tfQB, "Screen Lead", 0, 15, 3,  0, function(v) qb_leadOverride.Screen = v end)

-- ================================================================
-- KICKER TAB
-- ================================================================
local tfKick = tabFrames["Kicker"]
AddSection(tfKick, "Auto Kicker")
AddToggle(tfKick, "Auto Kicker", false, function(v) kickerAutoEnabled = v end)
AddSlider(tfKick, "Kicker Power %", 1, 100, 95, 1, function(v) kickerPower = v end)
AddSlider(tfKick, "Kicker Accuracy %", 1, 100, 75, 1, function(v) kickerAcc = v end)
AddLabel(tfKick, "Opens KickerGui automatically")
AddLabel(tfKick, "and clicks at set thresholds.")

AddSection(tfKick, "Kick Extender")
AddToggle(tfKick, "Kick Extender", false, function(v)
    kickExtendEnabled = v
    if v then startKickExtend() else stopKickExtend() end
end)
AddSlider(tfKick, "Hitbox Size", 5, 30, 15, 1, function(v) kickExtendSize = v end)
AddLabel(tfKick, "Enlarges kicking hitbox part when it spawns.")

-- ================================================================
-- TACKLE TAB
-- ================================================================
local tfTack = tabFrames["Tackle"]
AddSection(tfTack, "Tackle Aimbot")
AddToggle(tfTack, "Tackle Aimbot", false, function(v) tackleAimbotEnabled = v end)
AddSlider(tfTack, "Aimbot Range", 5, 40, 15, 1, function(v) tackleAimbotRange = v end)
AddLabel(tfTack, "M1 / Touch / R2 = teleport CatchRight onto carrier.")

AddSection(tfTack, "Click Tackle")
AddToggle(tfTack, "Click Tackle (TP body)", false, function(v) clicktackleon = v end)
AddSlider(tfTack, "Click Tackle Range", 1, 15, 5, 1, function(v) clicktacklerange = v end)
AddLabel(tfTack, "Teleports your HRP onto nearest ball carrier on click.")

AddSection(tfTack, "Tackle Reach")
AddToggle(tfTack, "Tackle Reach", false, function(v) tackleReachEnabled = v end)
AddSlider(tfTack, "Reach Range", 5, 50, 15, 1, function(v) tackleReachRange = v end)
AddLabel(tfTack, "FireTouchInterest on ball carrier parts within range.")

AddSection(tfTack, "Block Reach")
AddToggle(tfTack, "Block Reach", false, function(v)
    blockReachEnabled = v; refreshBlockReach()
end)
AddSlider(tfTack, "Block Reach Size", 5, 60, 20, 1, function(v)
    blockReachSize = v; if blockReachEnabled then refreshBlockReach() end
end)
AddSlider(tfTack, "Block Reach Opacity (0=solid)", 0, 10, 5, 1, function(v)
    blockReachOpacity = v/10; if blockReachEnabled then refreshBlockReach() end
end)

-- ================================================================
-- MOVEMENT TAB
-- ================================================================
local tfMove = tabFrames["Movement"]
AddSection(tfMove, "Jump")
AddToggle(tfMove, "Jump Power Boost", false, function(v) jumpoweron = v end)
AddSlider(tfMove, "Jump Boost", 50, 65, 50, 1, function(v) jumpboost = v end)

AddSection(tfMove, "Speed")
AddToggle(tfMove, "CFrame Speed", false, function(v)
    speedEnabled = v; if v then startMovementSystem() else stopMovementSystem() end
end)
AddSlider(tfMove, "Speed", 1, 12, 1, 1, function(v) speedValue = v/10 end)

AddSection(tfMove, "Jump Cooldown")
AddToggle(tfMove, "No Jump Cooldown", false, function(v)
    nojpcooldownon = v
    if not v and Player.Character then
        local conn = njcconnections[Player.Character]
        if conn then conn:Disconnect(); njcconnections[Player.Character] = nil end
    elseif v and Player.Character then njc(Player.Character) end
end)

-- ================================================================
-- MISC TAB
-- ================================================================
local tfMisc = tabFrames["Misc"]
AddSection(tfMisc, "Anti-Lag")
AddToggle(tfMisc, "Anti-Lag (apply once)", false, function(v)
    antiLagEnabled = v
    if v then applyAntiLag() end
end)
AddLabel(tfMisc, "Sets all BaseParts to SmoothPlastic to reduce lag.")

AddSection(tfMisc, "World")
AddToggle(tfMisc, "Delete OOB Parts", false, function(v) deleteOOBEnabled = v end)

AddSection(tfMisc, "Pull Vector")
AddToggle(tfMisc, "Pull Vector", false, function(v) pullvector = v end)
AddSlider(tfMisc, "Pull Speed", 1, 3, 1, 1, function(v) pullvectorpower = v end)
AddSlider(tfMisc, "Pull Radius", 1, 25, 5, 1, function(v) pullvectordistance = v end)

-- ================================================================
-- ACTIVATE FIRST TAB
-- ================================================================
switchTab("Catching")

print("Aethel Hub v10 Loaded! E/Space=throw · Q/Tab=cycle · G=lock")
