local UserInputService = game:GetService("UserInputService")

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Daddy-Dylan/The-Tower/main/library.lua", true))()
if not Library then
    warn("Library failed to load!")
    return
end

wait(0.5)

local Window = Library:CreateWindow("Daddy's Ez Hub...", Vector2.new(492, 598), Enum.KeyCode.RightControl)
local RunnerTab = Window:CreateTab("RUNNER")
local VisualsTab = Window:CreateTab("VISUALS")
local MiscTab = Window:CreateTab("MISC")
local SniperTab = Window:CreateTab("SNIPER")

local miscSection = MiscTab:CreateSector("Cursor Settings", "right")
local CursorForced = false
local ToggleKey = Enum.KeyCode.LeftAlt 

miscSection:AddToggle("Force Cursor (Disable Shift-Lock)", false, function(state)
    CursorForced = state
end)

miscSection:AddKeybind("Toggle Cursor Key", ToggleKey, function(key)
    ToggleKey = key
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == ToggleKey then
        CursorForced = not CursorForced
        print("Cursor Force:", CursorForced and "ON (No Shift-Lock)" or "OFF (Shift-Lock Works)")
    end
end)

game:GetService("RunService").RenderStepped:Connect(function()
    if CursorForced then
        UserInputService.MouseIconEnabled = true
    end
end)

local flareSection = RunnerTab:CreateSector("Flares", "left")
local flareOptions, flareParts, selectedFlare, flareHighlight = {}, {}, nil, nil
local function scanFlares()
    flareOptions, flareParts = {}, {}
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name == "Flare" and obj:IsA("BasePart") then
            table.insert(flareOptions, obj:GetFullName())
            table.insert(flareParts, obj)
        end
    end
    selectedFlare = flareParts[1]
end
scanFlares()
local flareDropdown = flareSection:AddDropdown("Flare List", flareOptions, flareOptions[1] or "None", false, function(choice)
    for i, path in ipairs(flareOptions) do
        if path == choice then
            selectedFlare = flareParts[i]
            if flareHighlight then flareHighlight:Destroy() end
            flareHighlight = Instance.new("Highlight", selectedFlare)
            flareHighlight.FillColor = Color3.fromRGB(0, 255, 0)
            flareHighlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        end
    end
end)
flareSection:AddButton("TP TO FLARE", function()
    pcall(function()
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") and selectedFlare then
            char.HumanoidRootPart.CFrame = selectedFlare.CFrame + Vector3.new(0, 5, 0)
        end
    end)
end)
flareSection:AddButton("RESCAN FLARES", function()
    scanFlares()
    flareDropdown:Refresh(flareOptions, flareOptions[1] or "None")
end)

local runnerSection = RunnerTab:CreateSector("Teleports", "right")
local function createTeleport(title, targetNames, innerTarget, color)
    local options, parts, selected, highlight = {}, {}, nil, nil
    local function scanTargets()
        options, parts = {}, {}
        for _, obj in pairs(workspace:GetDescendants()) do
            for _, name in ipairs(targetNames) do
                if obj.Name == name and obj:IsA("Model") then
                    table.insert(options, obj:GetFullName())
                    table.insert(parts, obj)
                end
            end
        end
        selected = parts[1]
    end
    scanTargets()
    local dropdown = runnerSection:AddDropdown(title .. " List", options, options[1] or "None", false, function(choice)
        for i, path in ipairs(options) do
            if path == choice then
                selected = parts[i]
                if highlight then highlight:Destroy() end
                highlight = Instance.new("Highlight", selected)
                highlight.FillColor = color
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            end
        end
    end)
    runnerSection:AddButton("TP TO " .. title, function()
        pcall(function()
            local char = game.Players.LocalPlayer.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") or not selected then return end
            if innerTarget then
                local inner = selected:FindFirstChild(innerTarget, true)
                if inner and inner:IsA("BasePart") then
                    char.HumanoidRootPart.CFrame = inner.CFrame + Vector3.new(0, 5, 0)
                end
            else
                char.HumanoidRootPart.CFrame = selected:GetModelCFrame() + Vector3.new(0, 5, 0)
            end
        end)
    end)
    runnerSection:AddButton("RESCAN " .. title, function()
        scanTargets()
        dropdown:Refresh(options, options[1] or "None")
    end)
    task.spawn(function()
        while task.wait(10) do
            scanTargets()
            dropdown:Refresh(options, options[1] or "None")
        end
    end)
end

createTeleport("Keys", {"SafeKey", "KeyUnlockable"}, "Plane_Plane", Color3.fromRGB(0, 180, 255))
createTeleport("Safes", {"SafeUnlockable"}, "Cube", Color3.fromRGB(255, 100, 100))
createTeleport("Advanced Safes", {"AdvancedSafeUnlockable"}, "Door", Color3.fromRGB(255, 50, 200))
createTeleport("Advanced Safe Key", {"AdvancedSafeKey"}, "Plane", Color3.fromRGB(200, 100, 255))
createTeleport("AirdropKey", {"AirdropKey"}, "Plane.001_Plane.001", Color3.fromRGB(0, 255, 255))
createTeleport("Airdrop", {"AirdropUnlockable"}, nil, Color3.fromRGB(255, 215, 0))
createTeleport("Parachute", {"Parachute"}, "Plane", Color3.fromRGB(255, 215, 0))

local nameEspSection = VisualsTab:CreateSector("Name ESP", "left")
local NameEspEnabled = false
local NameEspCache = {}
local function CreateNameEsp(plr)
    if plr == game.Players.LocalPlayer or not plr.Character then return end
    local head = plr.Character:FindFirstChild("Head")
    if not head then return end
    local bill = Instance.new("BillboardGui")
    bill.Adornee = head
    bill.Size = UDim2.new(0, 200, 0, 50)
    bill.StudsOffset = Vector3.new(0, 3, 0)
    bill.AlwaysOnTop = true
    bill.Parent = game.CoreGui
    local text = Instance.new("TextLabel", bill)
    text.Size = UDim2.new(1,0,1,0)
    text.BackgroundTransparency = 1
    text.Text = plr.Name
    text.TextColor3 = Color3.fromRGB(255,255,255)
    text.TextStrokeTransparency = 0
    text.TextStrokeColor3 = Color3.fromRGB(0,0,0)
    text.Font = Enum.Font.GothamBold
    text.TextSize = 16
    NameEspCache[plr] = bill
end
nameEspSection:AddToggle("Name ESP", false, function(state)
    NameEspEnabled = state
    if state then
        for _, plr in pairs(game.Players:GetPlayers()) do
            if plr.Character then CreateNameEsp(plr) end
            plr.CharacterAdded:Connect(function() CreateNameEsp(plr) end)
        end
        game.Players.PlayerAdded:Connect(function(plr)
            plr.CharacterAdded:Connect(function() CreateNameEsp(plr) end)
        end)
    else
        for _, bill in pairs(NameEspCache) do bill:Destroy() end
        NameEspCache = {}
    end
end)

local healthBarSection = VisualsTab:CreateSector("Health Bar ESP", "left")
local HealthBarEnabled = false
local HealthBarCache = {}
local function CreateHealthBar(plr)
    if plr == game.Players.LocalPlayer or not plr.Character then return end
    local head = plr.Character:FindFirstChild("Head")
    local hum = plr.Character:FindFirstChild("Humanoid")
    if not head or not hum then return end
    local bill = Instance.new("BillboardGui")
    bill.Name = "HealthBar_ESP"
    bill.Adornee = head
    bill.Size = UDim2.new(4, 0, 0.8, 0)
    bill.AlwaysOnTop = true
    bill.ExtentsOffsetWorldSpace = Vector3.new(0, 3.5, 0)
    bill.Parent = game.CoreGui
    local back = Instance.new("Frame", bill)
    back.Size = UDim2.new(0.9, 0, 0.35, 0)
    back.Position = UDim2.new(0.05, 0, 0.4, 0)
    back.BackgroundColor3 = Color3.new(0,0,0)
    back.BorderSizePixel = 0
    local fill = Instance.new("Frame", back)
    fill.Size = UDim2.new(1, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    fill.BorderSizePixel = 0
    HealthBarCache[plr] = {Gui = bill, Fill = fill, Hum = hum}
end
local function UpdateHealthBars()
    for plr, data in pairs(HealthBarCache) do
        if not plr.Character or not data.Hum or data.Hum.Health <= 0 then
            if data.Gui then data.Gui:Destroy() end
            HealthBarCache[plr] = nil
        else
            local pct = math.clamp(data.Hum.Health / data.Hum.MaxHealth, 0, 1)
            data.Fill.Size = UDim2.new(pct, 0, 1, 0)
            data.Fill.BackgroundColor3 = Color3.fromRGB(255,0,0):Lerp(Color3.fromRGB(0,255,0), pct)
        end
    end
end
healthBarSection:AddToggle("Health Bar ESP", false, function(state)
    HealthBarEnabled = state
    if state then
        for _, plr in pairs(game.Players:GetPlayers()) do
            if plr.Character then CreateHealthBar(plr) end
            plr.CharacterAdded:Connect(function() CreateHealthBar(plr) end)
        end
        game.Players.PlayerAdded:Connect(function(plr)
            plr.CharacterAdded:Connect(function() CreateHealthBar(plr) end)
        end)
    else
        for _, data in pairs(HealthBarCache) do if data.Gui then data.Gui:Destroy() end end
        HealthBarCache = {}
    end
end)
game:GetService("RunService").Heartbeat:Connect(function()
    if HealthBarEnabled then UpdateHealthBars() end
end)

local visualsSection = VisualsTab:CreateSector("Visuals", "left")
local Chams_Enabled = false
local Chams_Highlights = {}
local function ApplyHealthChams()
    if not Chams_Enabled then return end
    for _, obj in pairs(workspace:GetChildren()) do
        if obj:IsA("Model") and game.Players:GetPlayerFromCharacter(obj) and obj ~= game.Players.LocalPlayer.Character then
            local hum = obj:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                local fillColor = hum.Health / hum.MaxHealth >= 0.8 and Color3.fromRGB(0,255,0) or hum.Health / hum.MaxHealth >= 0.6 and Color3.fromRGB(255,255,0) or Color3.fromRGB(255,0,0)
                for _, part in pairs(obj:GetChildren()) do
                    if part:IsA("BasePart") then
                        if not Chams_Highlights[part] then
                            local hl = Instance.new("Highlight")
                            hl.Parent = part
                            hl.FillTransparency = 0.5
                            hl.OutlineTransparency = 0
                            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                            Chams_Highlights[part] = hl
                        end
                        Chams_Highlights[part].FillColor = fillColor
                    end
                end
            end
        end
    end
end
local function RemoveChams()
    for _, hl in pairs(Chams_Highlights) do if hl and hl.Parent then hl:Destroy() end end
    Chams_Highlights = {}
end
visualsSection:AddToggle("Health Chams", false, function(state)
    Chams_Enabled = state
    if state then ApplyHealthChams() else RemoveChams() end
end)
game:GetService("RunService").Heartbeat:Connect(function() if Chams_Enabled then ApplyHealthChams() end end)

-- PARTICLES SECTION
local particlesSection = SniperTab:CreateSector("Particles", "right")
local Particles_Enabled = false
local Particle_Highlights = {}

local function ApplyParticles()
    if not Particles_Enabled then 
        for _, hl in pairs(Particle_Highlights) do 
            if hl and hl.Parent then hl:Destroy() end 
        end 
        Particle_Highlights = {} 
        return 
    end
    for _, obj in pairs(workspace:GetDescendants()) do
        if (obj.Name == "Flare" or obj.Name == "EffectDropServer" or obj.Name == "SmokeVolume" or obj.Name == "SmokeGrenadeMesh" or obj.Name == "Glare") and obj:IsA("BasePart") and not Particle_Highlights[obj] then
            local hl = Instance.new("Highlight")
            hl.Parent = obj
            hl.FillColor = Color3.fromRGB(255, 165, 0)
            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
            hl.FillTransparency = 0.5
            hl.OutlineTransparency = 0
            Particle_Highlights[obj] = hl
        end
    end
end

particlesSection:AddToggle("Show Particles", false, function(state) 
    Particles_Enabled = state 
    ApplyParticles() 
end)

game:GetService("RunService").Heartbeat:Connect(function() 
    if Particles_Enabled then ApplyParticles() end 
end)

-- AIMBOT SECTION
local aimbotSection = SniperTab:CreateSector("Aimbot", "left")

aimbotSection:AddLabel("Auto-aim at closest enemy head")

local AimbotEnabled = false
local AimbotSmoothing = 0.2

aimbotSection:AddToggle("Enable Aimbot", false, function(state)
    AimbotEnabled = state
    print("Aimbot:", state and "ON" or "OFF")
end)

aimbotSection:AddSlider("Smoothing", 0, 1, 100, 20, function(value)
    AimbotSmoothing = value / 100
end)

-- Try to load modules safely
local CameraRotation = nil
local Turret = nil

local success1, result1 = pcall(function()
    return require(game:GetService("Players").LocalPlayer.PlayerScripts.Leglo.Camera.CameraRotation)
end)

-- Turret module seems broken, let's try to get SniperCFrame another way
local success2, result2 = pcall(function()
    local turretModule = game.ReplicatedStorage.Turret
    -- Try to read it without requiring
    return turretModule
end)

if success1 then
    CameraRotation = result1
    print("✅ CameraRotation loaded")
else
    warn("❌ CameraRotation failed:", result1)
    aimbotSection:AddLabel("ERROR: Camera not found")
end

-- Since Turret module is broken, let's find the sniper manually
local SniperModel = nil
local function FindSniper()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name == "Sniper" and obj:IsA("Model") then
            SniperModel = obj
            return true
        end
    end
    return false
end

if FindSniper() then
    print("✅ Found Sniper model in workspace")
    aimbotSection:AddLabel("Sniper found!")
else
    warn("❌ Sniper model not found")
    aimbotSection:AddLabel("ERROR: Join sniper team first")
end

local function GetClosestEnemyHead()
    if not SniperModel then 
        FindSniper()
        if not SniperModel then return nil end
    end
    
    local sniperPos = SniperModel:GetPivot().Position
    local closestHead = nil
    local shortestDistance = math.huge
    local localPlayer = game.Players.LocalPlayer
    
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= localPlayer and player.Team == game.Teams.Runner and player.Character then
            local head = player.Character:FindFirstChild("Head")
            local humanoid = player.Character:FindFirstChild("Humanoid")
            
            if head and humanoid and humanoid.Health > 0 then
                local distance = (head.Position - sniperPos).Magnitude
                if distance < shortestDistance then
                    closestHead = head
                    shortestDistance = distance
                end
            end
        end
    end
    
    return closestHead
end

local function GetAnglesToTarget(targetPos)
    if not SniperModel then return 0, 0 end
    
    local sniperCFrame = SniperModel:GetPivot()
    local sniperPos = sniperCFrame.Position
    
    -- Calculate direction vector
    local direction = (targetPos - sniperPos).Unit
    
    -- Convert to camera angles (pitch and yaw)
    local x = math.asin(direction.Y)
    local y = math.atan2(direction.X, -direction.Z)
    
    return x, y
end

game:GetService("RunService").RenderStepped:Connect(function()
    if AimbotEnabled and CameraRotation and game.Players.LocalPlayer.Team == game.Teams.Sniper then
        local target = GetClosestEnemyHead()
        if target then
            local targetX, targetY = GetAnglesToTarget(target.Position)
            local currentX, currentY = CameraRotation:GetTwoAxis()
            
            -- Smoothly interpolate to target angles
            local newX = currentX + (targetX - currentX) * AimbotSmoothing
            local newY = currentY + (targetY - currentY) * AimbotSmoothing
            
            -- Set camera rotation
            CameraRotation:SetRotation(newX, newY)
        end
    end
end)

-- PLAYER TP SECTION (FIXED - removed Refresh calls)
local playerTpSection = MiscTab:CreateSector("Player TP", "left")
local selectedPlayerName = nil

local playerList = {}
for _, obj in pairs(workspace:GetChildren()) do
    if obj:IsA("Model") and game.Players:FindFirstChild(obj.Name) and obj.Name ~= game.Players.LocalPlayer.Name then
        table.insert(playerList, obj.Name)
    end
end
table.sort(playerList)

local playerDropdown = playerTpSection:AddDropdown("Select Player", playerList, playerList[1] or "No players", false, function(name)
    selectedPlayerName = name
end)

playerTpSection:AddButton("Teleport To Player", function()
    if not selectedPlayerName then return end
    local target = workspace:FindFirstChild(selectedPlayerName)
    if target and target:FindFirstChild("Head") then
        local lp = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
        if lp:FindFirstChild("HumanoidRootPart") then
            lp.HumanoidRootPart.CFrame = target.Head.CFrame + Vector3.new(0, 3, 0)
        end
    end
end)
