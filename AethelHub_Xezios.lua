-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")

local cloneref = cloneref or function(v) return v end
local player = Players.LocalPlayer
local Char = player.Character or player.CharacterAdded:Wait()
local Hum = cloneref(Char:WaitForChild("Humanoid")) or cloneref(Char:FindFirstChild("Humanoid"))
local Hrp = cloneref(Char:WaitForChild("HumanoidRootPart")) or cloneref(Char:FindFirstChild("HumanoidRootPart"))

-- Load XEZIOS UI Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/notfinobe/xezios/main/source.lua"))()

-- ================================================================
-- Window & Tabs
-- ================================================================
local Window = Library:Window({
    Name = "Aethel Hub",
    Size = Vector2.new(550, 400),
})

local MainTab   = Window:Tab({ Name = "Main" })
local PlayerTab = Window:Tab({ Name = "Player" })
local MiscTab   = Window:Tab({ Name = "Misc" })
local SettingsTab = Window:Tab({ Name = "Settings" })

-- Sections
local ShootingSection       = MainTab:Section({ Name = "Auto Shooting",          Side = "Left" })
local GuardSection          = MainTab:Section({ Name = "Auto Guard",             Side = "Right" })
local ReboundSection        = MainTab:Section({ Name = "Auto Rebound & Steal",   Side = "Left" })
local PostSection           = MainTab:Section({ Name = "Post Aimbot",            Side = "Right" })
local FollowSection         = MainTab:Section({ Name = "Follow Ball Carrier",    Side = "Left" })
local ReachSection          = MainTab:Section({ Name = "Reach",                  Side = "Right" })
local MagnetSection         = MainTab:Section({ Name = "Ball Magnet",            Side = "Left" })

local SpeedSection          = PlayerTab:Section({ Name = "Speed Boost",          Side = "Left" })

local VisualsSection        = MiscTab:Section({ Name = "Visuals",                Side = "Left" })
local AnimSection           = MiscTab:Section({ Name = "Animation Changer",      Side = "Right" })
local TeleportSection       = MiscTab:Section({ Name = "Teleporter",             Side = "Left" })

-- ================================================================
-- State variables
-- ================================================================
local autoShootEnabled      = false
local autoGuardEnabled      = false
local autoGuardToggleEnabled= false
local speedBoostEnabled     = false
local postAimbotEnabled     = false
local teleportEnabled       = false
local followEnabled         = false
local magnetEnabled         = false
local stealReachEnabled     = false

local desiredSpeed          = 30
local predictionTime        = 0.3
local guardDistance         = 10
local shootPower            = 0.8
local postActivationDistance= 10
local offsetDistance        = 3
local followOffset          = 3
local MagsDist              = 30
local stealReachMultiplier  = 1.5

local visibleConn           = nil
local autoGuardConnection   = nil
local speedBoostConnection  = nil
local postAimbotConnection  = nil
local followConnection      = nil
local magnetConnection      = nil
local lastPositions         = {}

local postHoldActive        = false
local lastPostUpdate        = 0
local POST_UPDATE_INTERVAL  = 0.033

local originalRightArmSize, originalLeftArmSize

-- Shooting elements
local visualGui       = player.PlayerGui:WaitForChild("Visual")
local shootingElement = visualGui:WaitForChild("Shooting")
local Shoot           = ReplicatedStorage.Packages.Knit.Services.ControlService.RE.Shoot

-- Park detection
local function IsPark()
    return workspace:WaitForChild("Game"):FindFirstChild("Courts") ~= nil
end
local isPark = IsPark()

-- ================================================================
-- Helper functions
-- ================================================================
local function getPlayerFromModel(model)
    for _, plr in pairs(Players:GetPlayers()) do
        if plr.Character == model then return plr end
    end
    return nil
end

local function isOnDifferentTeam(otherModel)
    local otherPlayer = getPlayerFromModel(otherModel)
    if not otherPlayer then return false end
    if not player.Team or not otherPlayer.Team then
        return otherPlayer ~= player
    end
    return player.Team ~= otherPlayer.Team
end

local function findPlayerWithBall()
    if isPark then
        local closestPlayer, closestDistance = nil, math.huge
        for _, model in pairs(workspace:GetChildren()) do
            if model:IsA("Model") and model:FindFirstChild("HumanoidRootPart") and model ~= player.Character then
                local tool = model:FindFirstChild("Basketball")
                if tool and tool:IsA("Tool") then
                    local dist = (model.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                    if dist < closestDistance then
                        closestDistance = dist
                        closestPlayer = model
                    end
                end
            end
        end
        if closestPlayer then return closestPlayer, closestPlayer:FindFirstChild("HumanoidRootPart") end
        return nil, nil
    end

    local looseBall = workspace:FindFirstChild("Basketball")
    if looseBall and looseBall:IsA("BasePart") then
        local closestPlayer, closestDistance = nil, math.huge
        for _, model in pairs(workspace:GetChildren()) do
            if model:IsA("Model") and model:FindFirstChild("HumanoidRootPart") and model ~= player.Character then
                if isOnDifferentTeam(model) then
                    local dist = (looseBall.Position - model.HumanoidRootPart.Position).Magnitude
                    if dist < closestDistance and dist < 15 then
                        closestDistance = dist
                        closestPlayer = model
                    end
                end
            end
        end
        if closestPlayer then return closestPlayer, closestPlayer:FindFirstChild("HumanoidRootPart") end
    end

    for _, model in pairs(workspace:GetChildren()) do
        if model:IsA("Model") and model:FindFirstChild("HumanoidRootPart") and model ~= player.Character then
            if isOnDifferentTeam(model) and model:FindFirstChild("Basketball") and model:FindFirstChild("Basketball"):IsA("Tool") then
                return model, model:FindFirstChild("HumanoidRootPart")
            end
        end
    end
    return nil, nil
end

local function playerHasBall()
    local char = player.Character
    if not char then return false end
    local b = char:FindFirstChild("Basketball")
    return b and b:IsA("Tool")
end

local function detectBallHand()
    local char = player.Character
    if not char then return "right" end
    local basketball = char:FindFirstChild("Basketball")
    if basketball and basketball:IsA("Tool") then
        local handle = basketball:FindFirstChild("Handle")
        if handle then
            local charRoot = char:FindFirstChild("HumanoidRootPart")
            if charRoot then
                local relativePos = charRoot.CFrame:ToObjectSpace(handle.CFrame)
                return relativePos.X > 0 and "right" or "left"
            end
        end
    end
    return "right"
end

local function getClosestOpponent()
    local char = player.Character
    if not char then return nil end
    local myRoot = char:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    local closest, minDist = nil, postActivationDistance
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            if isOnDifferentTeam(plr.Character) then
                local dist = (plr.Character.HumanoidRootPart.Position - myRoot.Position).Magnitude
                if dist < minDist then
                    closest = plr.Character.HumanoidRootPart
                    minDist = dist
                end
            end
        end
    end
    return closest
end

-- ================================================================
-- MAIN TAB — Auto Shooting
-- ================================================================
ShootingSection:Toggle({
    Name = "Auto Time",
    Flag = "AutoShoot",
    Default = false,
    Callback = function(value)
        autoShootEnabled = value
        if value then
            if not visibleConn then
                visibleConn = shootingElement:GetPropertyChangedSignal("Visible"):Connect(function()
                    if autoShootEnabled and shootingElement.Visible == true then
                        task.wait(0.25)
                        Shoot:FireServer(shootPower)
                    end
                end)
            end
        else
            if visibleConn then visibleConn:Disconnect() visibleConn = nil end
        end
    end
})

ShootingSection:Slider({
    Name = "Shot Timing",
    Flag = "ShootTiming",
    Default = 80,
    Min = 50,
    Max = 100,
    Decimal = 0,
    Suffix = "%",
    Callback = function(value)
        shootPower = value / 100
    end
})

ShootingSection:Label({ Name = "80 = Mediocre | 90 = Good | 95 = Great | 100 = Perfect" })

-- ================================================================
-- MAIN TAB — Auto Guard
-- ================================================================
local function autoGuard()
    if not autoGuardEnabled then return end
    if Players.LocalPlayer:FindFirstChild("Basketball") then return end
    local character = player.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not rootPart then return end

    local ballCarrier, ballCarrierRoot = findPlayerWithBall()
    if ballCarrier and ballCarrierRoot then
        local distance = (rootPart.Position - ballCarrierRoot.Position).Magnitude
        local currentPos = ballCarrierRoot.Position
        local velocity = Vector3.new(0, 0, 0)
        if lastPositions[ballCarrier] then
            velocity = (currentPos - lastPositions[ballCarrier]) / task.wait()
        end
        lastPositions[ballCarrier] = currentPos

        local predictedPos = currentPos + (velocity * predictionTime * 60)
        local directionToOpponent = (predictedPos - rootPart.Position).Unit
        local defensivePosition = Vector3.new(
            (predictedPos - directionToOpponent * 5).X,
            rootPart.Position.Y,
            (predictedPos - directionToOpponent * 5).Z
        )

        local VIM = game:GetService("VirtualInputManager")
        if distance <= guardDistance then
            humanoid:MoveTo(defensivePosition)
            if distance <= 10 then
                VIM:SendKeyEvent(true, Enum.KeyCode.F, false, game)
            else
                VIM:SendKeyEvent(false, Enum.KeyCode.F, false, game)
            end
        else
            VIM:SendKeyEvent(false, Enum.KeyCode.F, false, game)
        end
    else
        game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.F, false, game)
    end
end

GuardSection:Toggle({
    Name = "Auto Guard (Hold G)",
    Flag = "AutoGuard",
    Default = false,
    Callback = function(value)
        autoGuardToggleEnabled = value
        if not value then
            autoGuardEnabled = false
            if autoGuardConnection then autoGuardConnection:Disconnect() autoGuardConnection = nil end
            lastPositions = {}
            game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.F, false, game)
        end
    end
})

GuardSection:Slider({
    Name = "Guard Distance",
    Flag = "GuardDistance",
    Default = 10,
    Min = 5,
    Max = 20,
    Decimal = 0,
    Callback = function(value) guardDistance = value end
})

GuardSection:Slider({
    Name = "Prediction Time",
    Flag = "PredictionTime",
    Default = 3,
    Min = 1,
    Max = 8,
    Decimal = 1,
    Suffix = "s",
    Callback = function(value) predictionTime = value / 10 end
})

GuardSection:Label({ Name = "Hold G to activate (toggle must be enabled)" })

UserInputService.InputBegan:Connect(function(input, gp)
    if input.KeyCode == Enum.KeyCode.G and not gp then
        if autoGuardToggleEnabled then
            autoGuardEnabled = true
            lastPositions = {}
            if not autoGuardConnection then
                autoGuardConnection = RunService.Heartbeat:Connect(autoGuard)
            end
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.G then
        autoGuardEnabled = false
        if autoGuardConnection then autoGuardConnection:Disconnect() autoGuardConnection = nil end
        lastPositions = {}
        game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.F, false, game)
    end
end)

-- ================================================================
-- MAIN TAB — Auto Rebound & Steal
-- ================================================================
RunService.RenderStepped:Connect(function()
    if not teleportEnabled then return end
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local closestBall, closestDist = nil, math.huge
    local maxDistance = isPark and 100 or math.huge
    for _, child in ipairs(workspace:GetChildren()) do
        if child.Name == "Basketball" then
            local part = child:IsA("BasePart") and child or child:FindFirstChildWhichIsA("BasePart")
            if part then
                local dist = (part.Position - hrp.Position).Magnitude
                if dist < closestDist and dist <= maxDistance then
                    closestDist = dist
                    closestBall = part
                end
            end
        end
    end
    if closestBall then
        hrp.CFrame = CFrame.new(closestBall.Position + closestBall.CFrame.LookVector * offsetDistance)
    end
end)

ReboundSection:Toggle({
    Name = "Auto Rebound & Steal",
    Flag = "ReboundAutoSteal",
    Default = false,
    Callback = function(value)
        teleportEnabled = value
    end
})

ReboundSection:Slider({
    Name = "Offset Distance",
    Flag = "ReboundOffset",
    Default = 0,
    Min = 0,
    Max = 6,
    Decimal = 1,
    Callback = function(value) offsetDistance = value end
})

-- ================================================================
-- MAIN TAB — Post Aimbot
-- ================================================================
local function executePostAimbot()
    local currentTime = tick()
    if currentTime - lastPostUpdate < POST_UPDATE_INTERVAL then return end
    lastPostUpdate = currentTime
    if not postHoldActive then return end
    local char = player.Character
    if not char then return end
    local myRoot = char:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end

    local target = getClosestOpponent()
    if target then
        local dir = (target.Position - myRoot.Position).Unit
        local face = CFrame.new(myRoot.Position, myRoot.Position + dir)
        if playerHasBall() then
            local hand = detectBallHand()
            myRoot.CFrame = face * CFrame.Angles(0, math.rad(hand == "left" and 90 or -90), 0)
        else
            myRoot.CFrame = face
        end
    end
end

PostSection:Toggle({
    Name = "Post Aimbot",
    Flag = "PostAimbot",
    Default = false,
    Callback = function(value)
        postAimbotEnabled = value
        if not value then
            postHoldActive = false
            if postAimbotConnection then postAimbotConnection:Disconnect() postAimbotConnection = nil end
        end
    end
})

PostSection:Keybind({
    Name = "Post Aimbot Key",
    Flag = "PostAimbotKey",
    Key = Enum.KeyCode.P,
    Mode = "Hold",
    Callback = function(active)
        if not postAimbotEnabled then return end
        postHoldActive = active
        if active and not postAimbotConnection then
            postAimbotConnection = RunService.Heartbeat:Connect(executePostAimbot)
        elseif not active and postAimbotConnection then
            postAimbotConnection:Disconnect()
            postAimbotConnection = nil
        end
    end
})

PostSection:Slider({
    Name = "Activation Distance",
    Flag = "PostActivationDistance",
    Default = 10,
    Min = 5,
    Max = 20,
    Decimal = 0,
    Callback = function(value) postActivationDistance = value end
})

PostSection:Label({ Name = "Auto detects ball hand and posts accordingly" })

-- ================================================================
-- MAIN TAB — Follow Ball Carrier
-- ================================================================
local function enableFollowBallCarrier()
    if followEnabled then return end
    followEnabled = true
    followConnection = RunService.Heartbeat:Connect(function()
        if not followEnabled then return end
        local char = player.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local _, ballCarrierRoot = findPlayerWithBall()
        if ballCarrierRoot then
            local maxDistance = isPark and 100 or math.huge
            local dist = (hrp.Position - ballCarrierRoot.Position).Magnitude
            if dist <= maxDistance then
                hrp.CFrame = ballCarrierRoot.CFrame * CFrame.new(0, 0, followOffset)
            end
        end
    end)
end

local function disableFollowBallCarrier()
    followEnabled = false
    if followConnection then followConnection:Disconnect() followConnection = nil end
end

FollowSection:Toggle({
    Name = "Follow Ball Carrier",
    Flag = "FollowBallCarrier",
    Default = false,
    Callback = function(value)
        if value then enableFollowBallCarrier() else disableFollowBallCarrier() end
    end
})

FollowSection:Keybind({
    Name = "Follow Key",
    Flag = "FollowBallCarrierKey",
    Key = Enum.KeyCode.H,
    Mode = "Toggle",
    Callback = function(active)
        if active then enableFollowBallCarrier() else disableFollowBallCarrier() end
    end
})

FollowSection:Slider({
    Name = "Follow Offset",
    Flag = "FollowOffset",
    Default = 0,
    Min = -10,
    Max = 10,
    Decimal = 0,
    Callback = function(value) followOffset = value end
})

-- ================================================================
-- MAIN TAB — Reach
-- ================================================================
local function updateHitboxSizes()
    local char = player.Character
    if not char then return end
    local rightArm = char:FindFirstChild("Right Arm") or char:FindFirstChild("RightHand") or char:FindFirstChild("RightLowerArm")
    local leftArm  = char:FindFirstChild("Left Arm")  or char:FindFirstChild("LeftHand")  or char:FindFirstChild("LeftLowerArm")

    if stealReachEnabled then
        if rightArm then
            if not originalRightArmSize then originalRightArmSize = rightArm.Size end
            rightArm.Size = originalRightArmSize * stealReachMultiplier
            rightArm.Transparency = 1
            rightArm.CanCollide = false
            rightArm.Massless = true
        end
        if leftArm then
            if not originalLeftArmSize then originalLeftArmSize = leftArm.Size end
            leftArm.Size = originalLeftArmSize * stealReachMultiplier
            leftArm.Transparency = 1
            leftArm.CanCollide = false
            leftArm.Massless = true
        end
    else
        if rightArm and originalRightArmSize then
            rightArm.Size = originalRightArmSize
            rightArm.Transparency = 0
            rightArm.CanCollide = false
            rightArm.Massless = false
            originalRightArmSize = nil
        end
        if leftArm and originalLeftArmSize then
            leftArm.Size = originalLeftArmSize
            leftArm.Transparency = 0
            leftArm.CanCollide = false
            leftArm.Massless = false
            originalLeftArmSize = nil
        end
    end
end

RunService.RenderStepped:Connect(function()
    if stealReachEnabled then updateHitboxSizes() end
end)

ReachSection:Toggle({
    Name = "Steal Reach",
    Flag = "StealReach",
    Default = false,
    Callback = function(value)
        stealReachEnabled = value
        updateHitboxSizes()
    end
})

ReachSection:Slider({
    Name = "Reach Multiplier",
    Flag = "StealReachMultiplier",
    Default = 15,
    Min = 10,
    Max = 200,
    Decimal = 1,
    Suffix = "x",
    Callback = function(value)
        stealReachMultiplier = value / 10
        if stealReachEnabled then updateHitboxSizes() end
    end
})

-- ================================================================
-- MAIN TAB — Ball Magnet
-- ================================================================
MagnetSection:Toggle({
    Name = "Ball Magnet",
    Flag = "BallMagnet",
    Default = false,
    Callback = function(value)
        magnetEnabled = value
    end
})

MagnetSection:Keybind({
    Name = "Magnet Key",
    Flag = "BallMagnetKey",
    Key = Enum.KeyCode.M,
    Mode = "Toggle",
    Callback = function(active)
        magnetEnabled = active
    end
})

MagnetSection:Slider({
    Name = "Magnet Distance",
    Flag = "BallMagnetDistance",
    Default = 30,
    Min = 10,
    Max = 85,
    Decimal = 0,
    Callback = function(value) MagsDist = value end
})

magnetConnection = RunService.Heartbeat:Connect(function()
    if not magnetEnabled then return end
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Name == "Basketball" then
            if (hrp.Position - v.Position).Magnitude <= MagsDist then
                firetouchinterest(hrp, v, 0)
                firetouchinterest(hrp, v, 1)
            end
        end
    end
end)

-- ================================================================
-- PLAYER TAB — Speed Boost
-- ================================================================
local function startCFrameSpeed(speed)
    local connection
    connection = RunService.RenderStepped:Connect(function(deltaTime)
        local character = player.Character
        if not character then return end
        local root = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not root or not humanoid then return end
        local moveVec = humanoid.MoveDirection
        if moveVec.Magnitude > 0 then
            local speedDelta = math.max(speed - humanoid.WalkSpeed, 0)
            root.CFrame = root.CFrame + (moveVec.Unit * speedDelta * deltaTime)
        end
    end)
    return function()
        if connection then connection:Disconnect() end
    end
end

SpeedSection:Toggle({
    Name = "Speed Boost",
    Flag = "SpeedBoost",
    Default = false,
    Callback = function(value)
        speedBoostEnabled = value
        if value then
            if speedBoostConnection then speedBoostConnection() end
            speedBoostConnection = startCFrameSpeed(desiredSpeed)
        else
            if speedBoostConnection then speedBoostConnection() end
            speedBoostConnection = nil
        end
    end
})

SpeedSection:Slider({
    Name = "Speed Amount",
    Flag = "SpeedAmount",
    Default = 16,
    Min = 16,
    Max = 23,
    Decimal = 1,
    Callback = function(value)
        desiredSpeed = value
        if speedBoostEnabled then
            if speedBoostConnection then speedBoostConnection() end
            speedBoostConnection = startCFrameSpeed(desiredSpeed)
        end
    end
})

-- ================================================================
-- MISC TAB — Visuals
-- ================================================================
local function setBGVisibleToTrue()
    for _, model in pairs(workspace:GetChildren()) do
        if model:IsA("Model") and model:FindFirstChild("HumanoidRootPart") then
            for _, obj in pairs(model.HumanoidRootPart:GetDescendants()) do
                if obj.Name == "BG" and obj:IsA("BodyGyro") then
                    obj.Parent = model.HumanoidRootPart
                    obj.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
                    obj.P = 9e4
                    obj.D = 500
                    obj.CFrame = model.HumanoidRootPart.CFrame
                end
            end
        end
    end
end

local function hideBG()
    for _, model in pairs(workspace:GetChildren()) do
        if model:IsA("Model") and model:FindFirstChild("HumanoidRootPart") then
            for _, obj in pairs(model.HumanoidRootPart:GetDescendants()) do
                if obj.Name == "BG" and obj:IsA("BodyGyro") then
                    obj.Parent = nil
                end
            end
        end
    end
end

VisualsSection:Toggle({
    Name = "Show BodyGyro",
    Flag = "ShowBG",
    Default = false,
    Callback = function(value)
        if value then setBGVisibleToTrue() else hideBG() end
    end
})

-- ================================================================
-- MISC TAB — Animation Changer
-- ================================================================
local AnimationsFolder = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Animations_R15")
local selectedDunkAnim  = "Default"
local selectedEmoteAnim = "Dance_Casual"
local animationSpoofEnabled = false
local dunkSpoofConnection, emoteSpoofConnection = nil, nil
local charAddedConnDunk, charAddedConnEmote = nil, nil

local EmoteAnimations = {
    Default = "Dance_Casual",
    Dance_Sturdy = "Dance_Sturdy",
    Dance_Taunt = "Dance_Taunt",
    Dance_TakeFlight = "Dance_TakeFlight",
    Dance_Flex = "Dance_Flex",
    Dance_Bat = "Dance_Bat",
    Dance_Twist = "Dance_Twist",
    Dance_Griddy = "Dance_Griddy",
    Dance_Dab = "Dance_Dab",
    Dance_Drake = "Dance_Drake",
    Dance_Fresh = "Dance_Fresh",
    Dance_Hype = "Dance_Hype",
    Dance_Spongebob = "Dance_Spongebob",
    Dance_Backflip = "Dance_Backflip",
    Dance_L = "Dance_L",
    Dance_Facepalm = "Dance_Facepalm",
    Dance_Bow = "Dance_Bow",
}

local emoteOptions = {}
for key in pairs(EmoteAnimations) do table.insert(emoteOptions, key) end
table.sort(emoteOptions)

local function setupDunkSpoof(humanoid)
    local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)
    return animator.AnimationPlayed:Connect(function(track)
        if animationSpoofEnabled and track.Animation.Name == "Dunk_Default" and selectedDunkAnim ~= "Default" then
            track:Stop()
            local customAnim = AnimationsFolder:FindFirstChild("Dunk_" .. selectedDunkAnim)
            if customAnim then humanoid:LoadAnimation(customAnim):Play() end
        end
    end)
end

local function setupEmoteSpoof(humanoid)
    local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)
    return animator.AnimationPlayed:Connect(function(track)
        if animationSpoofEnabled and track.Animation.Name == "Dance_Casual" and selectedEmoteAnim ~= "Dance_Casual" then
            track:Stop()
            local customAnim = AnimationsFolder:FindFirstChild(selectedEmoteAnim)
            if customAnim then humanoid:LoadAnimation(customAnim):Play() end
        end
    end)
end

local function enableAnimationSpoof()
    local char = player.Character
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            if dunkSpoofConnection then dunkSpoofConnection:Disconnect() end
            if emoteSpoofConnection then emoteSpoofConnection:Disconnect() end
            dunkSpoofConnection = setupDunkSpoof(humanoid)
            emoteSpoofConnection = setupEmoteSpoof(humanoid)
        end
    end
    if charAddedConnDunk then charAddedConnDunk:Disconnect() end
    if charAddedConnEmote then charAddedConnEmote:Disconnect() end
    charAddedConnDunk = player.CharacterAdded:Connect(function(newChar)
        local h = newChar:WaitForChild("Humanoid")
        if dunkSpoofConnection then dunkSpoofConnection:Disconnect() end
        dunkSpoofConnection = setupDunkSpoof(h)
    end)
    charAddedConnEmote = player.CharacterAdded:Connect(function(newChar)
        local h = newChar:WaitForChild("Humanoid")
        if emoteSpoofConnection then emoteSpoofConnection:Disconnect() end
        emoteSpoofConnection = setupEmoteSpoof(h)
    end)
end

local function disableAnimationSpoof()
    if dunkSpoofConnection then dunkSpoofConnection:Disconnect() dunkSpoofConnection = nil end
    if emoteSpoofConnection then emoteSpoofConnection:Disconnect() emoteSpoofConnection = nil end
    if charAddedConnDunk then charAddedConnDunk:Disconnect() charAddedConnDunk = nil end
    if charAddedConnEmote then charAddedConnEmote:Disconnect() charAddedConnEmote = nil end
end

AnimSection:Toggle({
    Name = "Animation Changer",
    Flag = "AnimationSpoof",
    Default = false,
    Callback = function(value)
        animationSpoofEnabled = value
        if value then enableAnimationSpoof() else disableAnimationSpoof() end
    end
})

AnimSection:Dropdown({
    Name = "Dunk Animation",
    Flag = "DunkSpoof",
    Options = {"Default", "Testing", "Testing2", "Reverse", "360", "Testing3", "Tomahawk", "Windmill"},
    Callback = function(value) selectedDunkAnim = value end
})

AnimSection:Dropdown({
    Name = "Emote Animation",
    Flag = "EmoteSpoof",
    Options = emoteOptions,
    Callback = function(value) selectedEmoteAnim = EmoteAnimations[value] end
})

-- ================================================================
-- MISC TAB — Teleporter
-- ================================================================
local placesList = {}
local loadingPlaces = false
local Http = (syn and syn.request) or (http and http.request) or (fluxus and fluxus.request) or (request) or (http_request)

local PlaceDropdown = TeleportSection:Dropdown({
    Name = "Select Place",
    Flag = "TeleportPlace",
    Options = {"Loading places..."},
    Callback = function() end
})

local function loadPlaces()
    if loadingPlaces then return end
    loadingPlaces = true

    if not Http then
        PlaceDropdown.RefreshOptions({"Current Place"})
        placesList["Current Place"] = game.PlaceId
        loadingPlaces = false
        return
    end

    local url = "https://develop.roblox.com/v1/universes/" .. game.GameId .. "/places?limit=100"
    local success, response = pcall(function()
        return Http({ Url = url, Method = "GET", Headers = { ["User-Agent"] = "Roblox/WinInet", ["Content-Type"] = "application/json" } })
    end)

    if success and response and response.Body then
        local ok, data = pcall(function() return HttpService:JSONDecode(response.Body) end)
        if ok and data and data.data then
            for _, place in ipairs(data.data) do
                if place.name and place.id then
                    local displayName = place.name .. (place.isRootPlace and " (Root)" or "")
                    placesList[displayName] = place.id
                end
            end
        end
    end

    local placeNames = {}
    for name in pairs(placesList) do table.insert(placeNames, name) end
    table.sort(placeNames)

    if #placeNames > 0 then
        PlaceDropdown.RefreshOptions(placeNames)
    else
        PlaceDropdown.RefreshOptions({"Current Place"})
        placesList["Current Place"] = game.PlaceId
    end
    loadingPlaces = false
end

task.spawn(loadPlaces)

TeleportSection:Button({
    Name = "Teleport",
    Callback = function()
        local selected = Library.Flags["TeleportPlace"]
        local placeId = placesList[selected]
        if placeId then
            Notifications:Create({ Name = "Teleporting to " .. selected .. "..." })
            TeleportService:Teleport(placeId)
        end
    end
})

TeleportSection:Button({
    Name = "Rejoin Current Server",
    Callback = function()
        Notifications:Create({ Name = "Rejoining current server..." })
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
    end
})

TeleportSection:Button({
    Name = "Server Hop",
    Callback = function()
        local servers = {}
        local cursor = ""
        repeat
            local url = "https://games.roblox.com/v1/games/" .. tostring(game.PlaceId) .. "/servers/Public?sortOrder=Asc&limit=100&cursor=" .. cursor
            local success, result = pcall(function() return game:HttpGet(url) end)
            if success then
                local decoded = HttpService:JSONDecode(result)
                cursor = decoded.nextPageCursor or ""
                for _, server in pairs(decoded.data) do
                    if server.playing < server.maxPlayers and server.id ~= game.JobId then
                        table.insert(servers, server)
                    end
                end
            else
                break
            end
        until cursor == ""

        if #servers > 0 then
            table.sort(servers, function(a, b) return a.playing < b.playing end)
            TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[1].id, player)
        else
            Notifications:Create({ Name = "No available servers found!" })
        end
    end
})

-- ================================================================
-- Settings Tab (built-in XEZIOS config system)
-- ================================================================
Library:Configs(Window)

-- ================================================================
-- Cleanup on unload
-- ================================================================
-- (XEZIOS handles unload internally via getgenv().Library:Unload())
