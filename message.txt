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

local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles

local Window = Library:CreateWindow({
    Title = "Aethel Hub",
    Footer = "",
    NotifySide = "Right",
    ShowCustomCursor = false,
})

local Tabs = {
    Main = Window:AddTab("Main", "house"),
    Player = Window:AddTab("Player", "user"),
    Misc = Window:AddTab("Misc", "settings"),
    ["UI Settings"] = Window:AddTab("UI Settings", "monitor"),
}

local function IsPark()
    if workspace:WaitForChild("Game"):FindFirstChild("Courts") then
        return true
    else
        return false
    end
end

local isPark = IsPark()
local ShootingGroup = Tabs.Main:AddLeftGroupbox("Auto Shooting", "target")
local GuardGroup = Tabs.Main:AddRightGroupbox("Auto Guard", "shield")
local ReboundGroup = Tabs.Main:AddLeftGroupbox("Auto Rebound & Steal", "backpack")
local PostGroup = Tabs.Main:AddRightGroupbox("Post Aimbot", "rotate-cw")
local SpeedGroup = Tabs.Player:AddLeftGroupbox("Speed Boost", "zap")
local MiscGroup = Tabs.Misc:AddLeftGroupbox("Visuals", "eye")
local AnimationGroup = Tabs.Misc:AddRightGroupbox("Animation Changer", "play")
local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu", "wrench")

local visualGui = player.PlayerGui:WaitForChild("Visual")
local shootingElement = visualGui:WaitForChild("Shooting")
local Shoot = ReplicatedStorage.Packages.Knit.Services.ControlService.RE.Shoot

local autoShootEnabled = false
local autoGuardEnabled = false
local autoGuardToggleEnabled = false
local holdingG = false
local speedBoostEnabled = false
local postAimbotEnabled = false

local desiredSpeed = 30
local predictionTime = 0.3
local guardDistance = 10
local shootPower = 0.8
local postActivationDistance = 10

local visibleConn = nil
local autoGuardConnection = nil
local speedBoostConnection = nil
local postAimbotConnection = nil
local lastPositions = {}

local postHoldActive = false
local lastPostUpdate = 0
local POST_UPDATE_INTERVAL = 0.033

ShootingGroup:AddToggle("AutoShoot", {
    Text = "Auto Time",
    Default = false,
    Tooltip = "Automatically shoots with perfect timing",
    Callback = function(value)
        autoShootEnabled = value
        if autoShootEnabled then
            if not visibleConn then
                visibleConn = shootingElement:GetPropertyChangedSignal("Visible"):Connect(function()
                    if autoShootEnabled and shootingElement.Visible == true then
                        task.wait(0.25)
                        Shoot:FireServer(shootPower)
                    end
                end)
            end
        else
            if visibleConn then
                visibleConn:Disconnect()
                visibleConn = nil
            end
        end
    end
})

ShootingGroup:AddSlider("ShootTiming", {
    Text = "Shot Timing",
    Default = 80,
    Min = 50,
    Max = 100,
    Rounding = 0,
    Tooltip = "Adjust the timing of the shot (80 = Mediocre, 90 = Good, 95 = Great, 100 = Perfect)",
    Callback = function(value)
        shootPower = value / 100
    end
})

ShootingGroup:AddLabel("Shot Timing Guide:\n80 = Mediocre\n90 = Good\n95 = Great\n100 = Perfect", true)

local function getPlayerFromModel(model)
    for _, plr in pairs(Players:GetPlayers()) do
        if plr.Character == model then
            return plr
        end
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
        local closestPlayer = nil
        local closestDistance = math.huge

        for _, model in pairs(workspace:GetChildren()) do
            if model:IsA("Model") and model:FindFirstChild("HumanoidRootPart") and model ~= player.Character then
                local tool = model:FindFirstChild("Basketball")
                if tool and tool:IsA("Tool") then
                    local hrp = model.HumanoidRootPart
                    local dist = (hrp.Position - player.Character.HumanoidRootPart.Position).Magnitude
                    if dist < closestDistance then
                        closestDistance = dist
                        closestPlayer = model
                    end
                end
            end
        end

        if closestPlayer then
            return closestPlayer, closestPlayer:FindFirstChild("HumanoidRootPart")
        end

        return nil, nil
    end

    local looseBall = workspace:FindFirstChild("Basketball")
    if looseBall and looseBall:IsA("BasePart") then
        local closestPlayer = nil
        local closestDistance = math.huge
        
        for _, model in pairs(workspace:GetChildren()) do
            if model:IsA("Model") and model:FindFirstChild("HumanoidRootPart") and model ~= player.Character then
                if isOnDifferentTeam(model) then
                    local rootPart = model:FindFirstChild("HumanoidRootPart")
                    local distance = (looseBall.Position - rootPart.Position).Magnitude
                    
                    if distance < closestDistance and distance < 15 then
                        closestDistance = distance
                        closestPlayer = model
                    end
                end
            end
        end
        
        if closestPlayer then
            return closestPlayer, closestPlayer:FindFirstChild("HumanoidRootPart")
        end
    end
    
    for _, model in pairs(workspace:GetChildren()) do
        if model:IsA("Model") and model:FindFirstChild("HumanoidRootPart") and model ~= player.Character then
            if isOnDifferentTeam(model) then
                local humanoidRootPart = model:FindFirstChild("HumanoidRootPart")
                local basketball = model:FindFirstChild("Basketball")
                
                if basketball and basketball:IsA("Tool") then
                    return model, humanoidRootPart
                end
            end
        end
    end
    
    return nil, nil
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
                local enemyRoot = plr.Character.HumanoidRootPart
                local dist = (enemyRoot.Position - myRoot.Position).Magnitude
                if dist < minDist then
                    closest = enemyRoot
                    minDist = dist
                end
            end
        end
    end
    return closest
end

local function playerHasBall()
    local char = player.Character
    if not char then return false end
    local basketballTool = char:FindFirstChild("Basketball")
    return basketballTool and basketballTool:IsA("Tool")
end

local function detectBallHand()
    local char = player.Character
    if not char then return "right" end
    
    local basketballTool = char:FindFirstChild("Basketball")
    if basketballTool and basketballTool:IsA("Tool") then
        local handle = basketballTool:FindFirstChild("Handle")
        if handle then
            local charRoot = char:FindFirstChild("HumanoidRootPart")
            if charRoot then
                local relativePos = charRoot.CFrame:ToObjectSpace(handle.CFrame)
                if relativePos.X > 0 then
                    return "right"
                else
                    return "left"
                end
            end
        end
    end
    return "right"
end

local function executePostAimbot()
    local currentTime = tick()
    if currentTime - lastPostUpdate < POST_UPDATE_INTERVAL then
        return
    end
    lastPostUpdate = currentTime

    if not postHoldActive then return end
    
    local char = player.Character
    if not char then return end
    local myRoot = char:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    
    local hasBall = playerHasBall()
    local target = getClosestOpponent()
    
    if target then
        local directionToTarget = (target.Position - myRoot.Position).Unit
        local faceTarget = CFrame.new(myRoot.Position, myRoot.Position + directionToTarget)
        
        if hasBall then
            local ballHand = detectBallHand()
            if ballHand == "left" then
                myRoot.CFrame = faceTarget * CFrame.Angles(0, math.rad(90), 0)
            else
                myRoot.CFrame = faceTarget * CFrame.Angles(0, math.rad(-90), 0)
            end
        else
            myRoot.CFrame = faceTarget
        end
    end
end

PostGroup:AddToggle("PostAimbot", {
    Text = "Post Aimbot",
    Default = false,
    Tooltip = "Automatically face opponents when posting up (detects ball hand)",
    Callback = function(value)
        postAimbotEnabled = value
        if not value then
            postHoldActive = false
            if postAimbotConnection then
                postAimbotConnection:Disconnect()
                postAimbotConnection = nil
            end
        end
    end
}):AddKeyPicker("PostAimbotKey", {
    Default = "P",
    SyncToggleState = false,
    Mode = "Hold",
    Text = "Post Aimbot Key",
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

PostGroup:AddSlider("PostActivationDistance", {
    Text = "Activation Distance",
    Default = 10,
    Min = 5,
    Max = 20,
    Rounding = 0,
    Tooltip = "Maximum distance to detect opponents",
    Callback = function(value)
        postActivationDistance = value
    end
})

PostGroup:AddLabel("Automatically detects which hand\nhas the ball and posts accordingly", true)

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
        local defensiveOffset = directionToOpponent * 5
        local defensivePosition = predictedPos - defensiveOffset
        
        defensivePosition = Vector3.new(defensivePosition.X, rootPart.Position.Y, defensivePosition.Z)
        
        if distance <= guardDistance then
            humanoid:MoveTo(defensivePosition)
            
            local VirtualInputManager = game:GetService("VirtualInputManager")
            if distance <= 10 then
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
            else
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
            end
        else
            local VirtualInputManager = game:GetService("VirtualInputManager")
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
        end
    else
        local VirtualInputManager = game:GetService("VirtualInputManager")
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
    end
end

GuardGroup:AddToggle("AutoGuard", {
    Text = "Auto Guard",
    Default = false,
    Tooltip = "Enable auto guard feature (hold G to activate)",
    Callback = function(value)
        autoGuardToggleEnabled = value
        
        if not value then
            autoGuardEnabled = false
            if autoGuardConnection then
                autoGuardConnection:Disconnect()
                autoGuardConnection = nil
            end
            
            lastPositions = {}
            
            local VirtualInputManager = game:GetService("VirtualInputManager")
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
        end
    end
})

local teleportEnabled = false
local offsetDistance = 3 

RunService.RenderStepped:Connect(function()
    if not teleportEnabled then return end
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local closestBall
    local closestDist = math.huge
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
        local targetPosition = closestBall.Position + closestBall.CFrame.LookVector * offsetDistance
        hrp.CFrame = CFrame.new(targetPosition)
    end
end)

local function toggleTeleport()
    teleportEnabled = not teleportEnabled
end

ReboundGroup:AddToggle("ReboundAutoSteal", {
    Text = "Auto Rebound & Steal",
    Default = false,
    Tooltip = "Will automatically rebound and steal the ball",
    Callback = function(enabled)
        toggleTeleport(enabled) 
    end
})
:AddKeyPicker("ReboundAutoStealKey", {
    Default = "T",
    SyncToggleState = true,
    Mode = "Toggle",
    Text = "Auto Rebound & Steal Key",
    Callback = function(active)
        ReboundGroup:SetToggle("ReboundAutoSteal", active)
    end
})

ReboundGroup:AddSlider("Offset distance", {
    Text = "Rebound & Steal offset distance",
    Default = 0,
    Min = 0,
    Max = 6,
    Rounding = 1,
    Tooltip = "how far ahead of the basketball you will be teleported to",
    Callback = function(value)
        offsetDistance = value
    end
})

local FollowBallCarrierGroup = Tabs.Main:AddLeftGroupbox("Follow Ball Carrier", "users")

local followEnabled = false
local followConnection = nil
local followOffset = 3

local function enableFollowBallCarrier()
    if followEnabled then return end
    followEnabled = true
    
    followConnection = RunService.Heartbeat:Connect(function()
        if not followEnabled then return end
        
        local char = player.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        local ballCarrier, ballCarrierRoot = findPlayerWithBall()
        
        if ballCarrier and ballCarrierRoot then
            local maxDistance = isPark and 100 or math.huge
            local dist = (hrp.Position - ballCarrierRoot.Position).Magnitude
            
            if dist <= maxDistance then
                hrp.CFrame = ballCarrierRoot.CFrame * CFrame.new(0, 0, followOffset)
            end
        end
    end)
end

local function disableFollowBallCarrier()
    if not followEnabled then return end
    followEnabled = false
    
    if followConnection then
        followConnection:Disconnect()
        followConnection = nil
    end
end

FollowBallCarrierGroup:AddToggle("FollowBallCarrier", {
    Text = "Follow Ball Carrier",
    Default = false,
    Tooltip = "Instantly teleports you to whoever has the ball",
    Callback = function(value)
        if value then
            enableFollowBallCarrier()
        else
            disableFollowBallCarrier()
        end
    end
}):AddKeyPicker("FollowBallCarrierKey", {
    Default = "H",
    SyncToggleState = true,
    Mode = "Toggle",
    Text = "Follow Ball Carrier Key",
    Callback = function(active)
        FollowBallCarrierGroup:SetToggle("FollowBallCarrier", active)
    end
})

FollowBallCarrierGroup:AddSlider("FollowOffset", {
    Text = "Follow Offset",
    Default = -10,
    Min = -10,
    Max = 10,
    Rounding = 0,
    Tooltip = "Distance in front of the ball carrier",
    Callback = function(value)
        followOffset = value
    end
})

local MagsDist = 30
local magnetEnabled = false
local magnetConnection = nil

local stealReachEnabled = false
local stealReachMultiplier = 1.5
local originalRightArmSize, originalLeftArmSize

local function updateHitboxSizes()
    local char = player.Character
    if not char then return end
    
    local rightArm = char:FindFirstChild("Right Arm") or char:FindFirstChild("RightHand") or char:FindFirstChild("RightLowerArm")
    local leftArm = char:FindFirstChild("Left Arm") or char:FindFirstChild("LeftHand") or char:FindFirstChild("LeftLowerArm")
    
    if stealReachEnabled then
        if rightArm then
            if not originalRightArmSize then originalRightArmSize = rightArm.Size end
            rightArm.Size = Vector3.new(
                originalRightArmSize.X * stealReachMultiplier,
                originalRightArmSize.Y * stealReachMultiplier,
                originalRightArmSize.Z * stealReachMultiplier
            )
            rightArm.Transparency = 1
            rightArm.CanCollide = false
            rightArm.Massless = true
        end
        
        if leftArm then
            if not originalLeftArmSize then originalLeftArmSize = leftArm.Size end
            leftArm.Size = Vector3.new(
                originalLeftArmSize.X * stealReachMultiplier,
                originalLeftArmSize.Y * stealReachMultiplier,
                originalLeftArmSize.Z * stealReachMultiplier
            )
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
    if stealReachEnabled then
        updateHitboxSizes()
    end
end)


local Reach = Tabs.Main:AddLeftGroupbox("Reach")

local stealReachEnabled = false
local stealReachMultiplier = 1.5

Reach:AddToggle("StealReach", {
    Text = "Steal Reach",
    Default = false,
    Tooltip = "Enable or disable extended reach for stealing",
    Callback = function(value)
        stealReachEnabled = value
        updateHitboxSizes()
    end
})

Reach:AddSlider("StealReachMultiplier", {
    Text = "Steal Reach Multiplier",
    Default = 1.5,
    Min = 1,
    Max = 20,
    Rounding = 1,
    Tooltip = "Adjust how far your reach extends",
    Callback = function(value)
        stealReachMultiplier = value
        if stealReachEnabled then
            updateHitboxSizes()
        end
    end
})


local BallMagnetGroup = Tabs.Main:AddRightGroupbox("Ball Magnet")

BallMagnetGroup:AddToggle("BallMagnet", {
    Text = "Ball Magnet",
    Default = false,
    Tooltip = "Automatically magnets you to the basketball",
    Callback = function(value)
        magnetEnabled = value
        if not value and magnetConnection then
            magnetConnection:Disconnect()
            magnetConnection = nil
        end
    end
}):AddKeyPicker("BallMagnetKey", {
    Default = "M",
    SyncToggleState = true,
    Mode = "Toggle",
    Text = "Ball Magnet Key",
    Callback = function(active)
        BallMagnetGroup:SetToggle("BallMagnet", active)
    end
})

BallMagnetGroup:AddSlider("BallMagnetDistance", {
    Text = "Magnet Distance",
    Default = 30,
    Min = 10,
    Max = 85,
    Rounding = 0,
    Tooltip = "Maximum distance to magnet from",
    Callback = function(value)
        MagsDist = value
    end
})

magnetConnection = RunService.Heartbeat:Connect(function()
    if not magnetEnabled then return end
    
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Name == "Basketball" then
            local dist = (hrp.Position - v.Position).Magnitude
            if dist <= MagsDist then
                local touch = v:FindFirstChildOfClass("TouchTransmitter")
                if not touch then
                    for _, d in ipairs(v:GetDescendants()) do
                        if d:IsA("TouchTransmitter") then
                            touch = d
                            break
                        end
                    end
                end
                if touch then
                    firetouchinterest(hrp, v, 0)
                    firetouchinterest(hrp, v, 1)
                end
            end
        end
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.G and not gameProcessed then
        if autoGuardToggleEnabled then
            holdingG = true
            autoGuardEnabled = true
            lastPositions = {}
            if not autoGuardConnection then
                autoGuardConnection = RunService.Heartbeat:Connect(autoGuard)
            end
        end
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.G then
        holdingG = false
        autoGuardEnabled = false
        
        if autoGuardConnection then
            autoGuardConnection:Disconnect()
            autoGuardConnection = nil
        end
        
        lastPositions = {}
        
        local VirtualInputManager = game:GetService("VirtualInputManager")
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
    end
end)

GuardGroup:AddLabel("Hold G to activate auto guard\n(toggle must be enabled)", true)

GuardGroup:AddSlider("GuardDistance", {
    Text = "Guard Distance",
    Default = 10,
    Min = 5,
    Max = 20,
    Rounding = 0,
    Tooltip = "Maximum distance to start guarding",
    Callback = function(value)
        guardDistance = value
    end
})

GuardGroup:AddSlider("PredictionTime", {
    Text = "Prediction Time",
    Default = 0.3,
    Min = 0.1,
    Max = 0.8,
    Rounding = 1,
    Tooltip = "How far ahead to predict opponent movement (seconds)",
    Callback = function(value)
        predictionTime = value
    end
})

GuardGroup:AddLabel("Auto Guard will predict opponent\nmovement and position defensively\nin front of them while holding F.", true)

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
        if connection then
            connection:Disconnect()
        end
    end
end

SpeedGroup:AddToggle("SpeedBoost", {
    Text = "Speed Boost",
    Default = false,
    Tooltip = "Enable or disable speed boost (CFrame method)",
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

SpeedGroup:AddSlider("SpeedAmount", {
    Text = "Speed Amount",
    Default = 16,
    Min = 16,
    Max = 23,
    Rounding = 1,
    Tooltip = "Adjust the speed boost amount",
    Callback = function(value)
        desiredSpeed = value
        if speedBoostEnabled then
            if speedBoostConnection then speedBoostConnection() end
            speedBoostConnection = startCFrameSpeed(desiredSpeed)
        end
    end
})

local function setBGVisibleToTrue()
    for _, model in pairs(workspace:GetChildren()) do
        if model:IsA("Model") and model:FindFirstChild("HumanoidRootPart") then
            local humanoidRootPart = model.HumanoidRootPart
            for _, obj in pairs(humanoidRootPart:GetDescendants()) do
                if obj.Name == "BG" and obj:IsA("BodyGyro") then
                    obj.Parent = humanoidRootPart
                    obj.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
                    obj.P = 9e4
                    obj.D = 500
                    obj.CFrame = humanoidRootPart.CFrame
                end
            end
        end
    end
end

local function hideBG()
    for _, model in pairs(workspace:GetChildren()) do
        if model:IsA("Model") and model:FindFirstChild("HumanoidRootPart") then
            local humanoidRootPart = model.HumanoidRootPart
            for _, obj in pairs(humanoidRootPart:GetDescendants()) do
                if obj.Name == "BG" and obj:IsA("BodyGyro") then
                    obj.Parent = nil
                end
            end
        end
    end
end

MiscGroup:AddToggle("ShowBG", {
    Text = "Show BodyGyro",
    Default = false,
    Tooltip = "Makes BodyGyro visible for all players",
    Callback = function(value)
        if value then
            setBGVisibleToTrue()
        else
            hideBG()
        end
    end
})

local AnimationsFolder = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Animations_R15")
local selectedDunkAnim = "Default"
local selectedEmoteAnim = "Dance_Casual"
local animationSpoofEnabled = false
local dunkSpoofConnection = nil
local emoteSpoofConnection = nil
local charAddedConnDunk = nil
local charAddedConnEmote = nil

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
    Dance_Bow = "Dance_Bow"
}

local emoteOptions = {}
for key, _ in pairs(EmoteAnimations) do
    table.insert(emoteOptions, key)
end
table.sort(emoteOptions)

local function setupDunkSpoof(humanoid)
    local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)
    return animator.AnimationPlayed:Connect(function(track)
        if animationSpoofEnabled and track.Animation.Name == "Dunk_Default" and selectedDunkAnim ~= "Default" then
            track:Stop()
            local customAnim = AnimationsFolder:FindFirstChild("Dunk_" .. selectedDunkAnim)
            if customAnim then
                humanoid:LoadAnimation(customAnim):Play()
            end
        end
    end)
end

local function setupEmoteSpoof(humanoid)
    local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)
    return animator.AnimationPlayed:Connect(function(track)
        if animationSpoofEnabled and track.Animation.Name == "Dance_Casual" and selectedEmoteAnim ~= "Dance_Casual" then
            track:Stop()
            local customAnim = AnimationsFolder:FindFirstChild(selectedEmoteAnim)
            if customAnim then
                humanoid:LoadAnimation(customAnim):Play()
            end
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
        local humanoid = newChar:WaitForChild("Humanoid")
        if dunkSpoofConnection then dunkSpoofConnection:Disconnect() end
        dunkSpoofConnection = setupDunkSpoof(humanoid)
    end)

    charAddedConnEmote = player.CharacterAdded:Connect(function(newChar)
        local humanoid = newChar:WaitForChild("Humanoid")
        if emoteSpoofConnection then emoteSpoofConnection:Disconnect() end
        emoteSpoofConnection = setupEmoteSpoof(humanoid)
    end)
end

local function disableAnimationSpoof()
    if dunkSpoofConnection then
        dunkSpoofConnection:Disconnect()
        dunkSpoofConnection = nil
    end
    if emoteSpoofConnection then
        emoteSpoofConnection:Disconnect()
        emoteSpoofConnection = nil
    end
    if charAddedConnDunk then
        charAddedConnDunk:Disconnect()
        charAddedConnDunk = nil
    end
    if charAddedConnEmote then
        charAddedConnEmote:Disconnect()
        charAddedConnEmote = nil
    end
end

AnimationGroup:AddToggle("AnimationSpoof", {
    Text = "Animation Changer",
    Default = false,
    Tooltip = "Enable animation spoofing for dunks and emotes",
    Callback = function(value)
        animationSpoofEnabled = value
        if value then
            enableAnimationSpoof()
        else
            disableAnimationSpoof()
        end
    end
})

AnimationGroup:AddDropdown("DunkSpoof", {
    Values = {"Default", "Testing", "Testing2", "Reverse", "360", "Testing3", "Tomahawk", "Windmill"},
    Default = 1,
    Multi = false,
    Text = "Dunk Animation",
    Tooltip = "Change your dunk animation",
    Callback = function(value)
        selectedDunkAnim = value
    end
})

AnimationGroup:AddDropdown("EmoteSpoof", {
    Values = emoteOptions,
    Default = 1,
    Multi = false,
    Text = "Emote Animation",
    Tooltip = "Change your emote/dance animation",
    Callback = function(value)
        selectedEmoteAnim = EmoteAnimations[value]
    end
})

local Http = (syn and syn.request) or (http and http.request) or (fluxus and fluxus.request) or (request) or (http_request)

local placesList = {}
local loadingPlaces = false

local TeleporterGroup = Tabs.Misc:AddLeftGroupbox("Teleporter", "move")

local PlaceDropdown = TeleporterGroup:AddDropdown("TeleportPlace", {
    Values = {"Loading places..."},
    Default = 1,
    Multi = false,
    Text = "Select Place",
    Tooltip = "Choose a place to teleport to"
})

local function loadPlaces()
    if loadingPlaces then return end
    loadingPlaces = true
    
    if not Http then
        PlaceDropdown:SetValues({"Current Place"})
        placesList["Current Place"] = game.PlaceId
        loadingPlaces = false
        return
    end
    
    local universeId = game.GameId
    local url = "https://develop.roblox.com/v1/universes/" .. universeId .. "/places?limit=100"
    
    local success, response = pcall(function()
        return Http({
            Url = url,
            Method = "GET",
            Headers = {
                ["User-Agent"] = "Roblox/WinInet",
                ["Content-Type"] = "application/json"
            }
        })
    end)
    
    if success and response and response.Body then
        local decodeSuccess, data = pcall(function()
            return HttpService:JSONDecode(response.Body)
        end)
        
        if decodeSuccess and data and data.data then
            for _, place in ipairs(data.data) do
                if place.name and place.id then
                    local displayName = place.name
                    if place.isRootPlace then
                        displayName = displayName .. " (Root)"
                    end
                    placesList[displayName] = place.id
                end
            end
        end
    end
    
    local placeNames = {}
    for name, _ in pairs(placesList) do
        table.insert(placeNames, name)
    end
    table.sort(placeNames)
    
    if #placeNames > 0 then
        PlaceDropdown:SetValues(placeNames)
        PlaceDropdown:SetValue(placeNames[1])
    else
        PlaceDropdown:SetValues({"Current Place"})
        placesList["Current Place"] = game.PlaceId
    end
    
    loadingPlaces = false
end

task.spawn(loadPlaces)

TeleporterGroup:AddButton({
    Text = "Teleport",
    Func = function()
        local selected = Options.TeleportPlace.Value
        local placeId = placesList[selected]
        
        if placeId then
            Library:Notify({
                Title = "Teleporting",
                Description = "Teleporting to " .. selected .. "...",
                Time = 3,
            })
            
            TeleportService:Teleport(placeId)
        end
    end,
    Tooltip = "Teleport to selected place"
})

TeleporterGroup:AddButton({
    Text = "Rejoin Current Server",
    Func = function()
        Library:Notify({
            Title = "Rejoining",
            Description = "Rejoining current server...",
            Time = 3,
        })
        
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
    end,
    Tooltip = "Rejoin your current server"
})

TeleporterGroup:AddButton({
    Text = "Server Hop",
    Func = function()
        Library:Notify({
            Title = "Server Hopping",
            Description = "Finding best server...",
            Time = 3,
        })
        
        local servers = {}
        local cursor = ""
        
        repeat
            local url = "https://games.roblox.com/v1/games/" .. tostring(game.PlaceId) .. "/servers/Public?sortOrder=Asc&limit=100&cursor=" .. cursor
            
            local success, result = pcall(function()
                return game:HttpGet(url)
            end)
            
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
            table.sort(servers, function(a, b)
                return a.playing < b.playing
            end)
            
            TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[1].id, player)
        else
            Library:Notify({
                Title = "Server Hop Failed",
                Description = "No available servers found",
                Time = 3,
            })
        end
    end,
    Tooltip = "Join the server with the least players"
})

MenuGroup:AddToggle("KeybindMenuOpen", {
    Default = Library.KeybindFrame.Visible,
    Text = "Open Keybind Menu",
    Callback = function(value)
        Library.KeybindFrame.Visible = value
    end,
})

MenuGroup:AddToggle("ShowCustomCursor", {
    Text = "Custom Cursor",
    Default = false,
    Callback = function(Value)
        Library.ShowCustomCursor = Value
    end,
})

MenuGroup:AddDropdown("NotificationSide", {
    Values = { "Left", "Right" },
    Default = "Right",
    Text = "Notification Side",
    Callback = function(Value)
        Library:SetNotifySide(Value)
    end,
})

MenuGroup:AddDropdown("DPIDropdown", {
    Values = { "50%", "75%", "100%", "125%", "150%", "175%", "200%" },
    Default = "100%",
    Text = "DPI Scale",
    Callback = function(Value)
        Value = Value:gsub("%%", "")
        local DPI = tonumber(Value)
        Library:SetDPIScale(DPI)
    end,
})

MenuGroup:AddDivider()

MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { 
    Default = "LeftControl", 
    NoUI = true, 
    Text = "Menu keybind" 
})

MenuGroup:AddButton("Unload", function()
    Library:Unload()
end)

Library.ToggleKeybind = Options.MenuKeybind

MenuGroup:AddDivider()
MenuGroup:AddLabel("ThemeManager", true)
MenuGroup:AddLabel("SaveManager", true)

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })

ThemeManager:SetFolder("KairoHub")
SaveManager:SetFolder("KairoHub/configs")

SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:ApplyToTab(Tabs["UI Settings"])

SaveManager:LoadAutoloadConfig()

Library:OnUnload(function()
    Library.Unloaded = true
    if visibleConn then
        visibleConn:Disconnect()
    end
    if autoGuardConnection then
        autoGuardConnection:Disconnect()
    end
    if speedBoostConnection then
        speedBoostConnection()
    end
    if magnetConnection then
        magnetConnection:Disconnect()
    end
    if postAimbotConnection then
        postAimbotConnection:Disconnect()
    end
    disableAnimationSpoof()
end)