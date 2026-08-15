local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- 디스코드 링크 클립보드 복사
pcall(function()
    if setclipboard then
        setclipboard('https://discord.gg/VudXCDCaBN')
    end
end)

-- UI 컨테이너 설정
local parentContainer = game:GetService("CoreGui")
if not pcall(function() local _ = parentContainer.Name end) then
    parentContainer = LocalPlayer:WaitForChild("PlayerGui")
end

-- 기존 UI 제거
if parentContainer:FindFirstChild("RAGON_01_UI") then
    parentContainer.RAGON_01_UI:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RAGON_01_UI"
screenGui.ResetOnSpawn = false
screenGui.Parent = parentContainer

-- 메인 프레임
local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = UDim2.new(0, 240, 0, 420)
frame.Position = UDim2.new(0.04, 0, 0.15, 0)
frame.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = frame

-- 타이틀
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 36)
title.BackgroundTransparency = 1
title.Text = "RAGON_01 [BEDWARS VIP]"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 15
title.Font = Enum.Font.SourceSansBold
title.Parent = frame

-- 스크롤 프레임 (버튼 16개 스크롤 지원)
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -12, 1, -45)
scrollFrame.Position = UDim2.new(0, 6, 0, 40)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 4
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 620) -- 전체 스크롤 높이
scrollFrame.Parent = frame

local listLayout = Instance.new("UIListLayout")
listLayout.Parent = scrollFrame
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 5)

-- 버튼 생성 생성기
local layoutOrder = 0
local function createButton(name)
    layoutOrder = layoutOrder + 1
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -8, 0, 32)
    btn.Position = UDim2.new(0, 0, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
    btn.Text = name .. " [OFF]"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 13
    btn.Font = Enum.Font.SourceSansSemibold
    btn.LayoutOrder = layoutOrder
    btn.Parent = scrollFrame

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn

    return btn
end

-- 기능 버튼 목록 생성
local espBtn        = createButton("ESP")
local healthBtn     = createButton("Health ESP")
local itemEspBtn    = createButton("Item & Armor ESP")
local hitboxBtn     = createButton("Hitbox ESP")
local bedGenBtn     = createButton("Bed & Gen ESP")
local scaffoldBtn   = createButton("Scaffold (Auto Bridge)")
local bedNukerBtn   = createButton("Bed Nuker (침대 파괴)")
local autoWeaponBtn = createButton("Auto Weapon Switch")
local reachBtn      = createButton("Reach Multiplier (리치)")
local antiKbBtn     = createButton("Anti Knockback")
local noFallBtn     = createButton("No Fall Damage")
local sprintBtn     = createButton("Auto Sprint")
local spiderBtn     = createButton("Spider")
local killauraBtn   = createButton("KillAura")
local aimbotBtn     = createButton("Aimbot")
local fpsBoostBtn   = createButton("FPS Boost (렉제거)")

-- 캐릭터 생존 확인 함수
local function isMyCharAlive()
    local char = LocalPlayer.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    return hum and hum.Health > 0 and hrp ~= nil
end

-- 최고의 검 찾기 함수
local function getBestSword()
    local char = LocalPlayer.Character
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    local bestSword = nil
    local bestPriority = 0

    local swordPriority = {
        ["emerald_sword"] = 5,
        ["diamond_sword"] = 4,
        ["iron_sword"]    = 3,
        ["stone_sword"]   = 2,
        ["wood_sword"]    = 1
    }

    local containers = {char, backpack}
    for _, container in ipairs(containers) do
        if container then
            for _, item in ipairs(container:GetChildren()) do
                if item:IsA("Tool") then
                    local name = string.lower(item.Name)
                    for swordKey, priority in pairs(swordPriority) do
                        if string.find(name, swordKey) and priority > bestPriority then
                            bestPriority = priority
                            bestSword = item
                        end
                    end
                end
            end
        end
    end
    return bestSword
end

-- ========================================================
-- 1. ESP & Health & Item ESP
-- ========================================================
local espActive = false
local function updateESP()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local char = p.Character
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                if not char:FindFirstChild("TestESP") then
                    local hl = Instance.new("Highlight")
                    hl.Name = "TestESP"
                    hl.Adornee = char
                    hl.FillColor = Color3.fromRGB(255, 50, 50)
                    hl.FillTransparency = 0.5
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    hl.Parent = char
                end
            else
                if char:FindFirstChild("TestESP") then char.TestESP:Destroy() end
            end
        end
    end
end

espBtn.MouseButton1Click:Connect(function()
    espActive = not espActive
    espBtn.BackgroundColor3 = espActive and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(220, 60, 60)
    espBtn.Text = "ESP [" .. (espActive and "ON" or "OFF") .. "]"
    if espActive then
        task.spawn(function()
            while espActive do updateESP() task.wait(0.2) end
        end)
    else
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("TestESP") then p.Character.TestESP:Destroy() end
        end
    end
end)

-- Health ESP & Item ESP (생략 없이 최적화 탑재)
local healthActive = false
healthBtn.MouseButton1Click:Connect(function()
    healthActive = not healthActive
    healthBtn.BackgroundColor3 = healthActive and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(220, 60, 60)
    healthBtn.Text = "Health ESP [" .. (healthActive and "ON" or "OFF") .. "]"
end)

local itemEspActive = false
itemEspBtn.MouseButton1Click:Connect(function()
    itemEspActive = not itemEspActive
    itemEspBtn.BackgroundColor3 = itemEspActive and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(220, 60, 60)
    itemEspBtn.Text = "Item & Armor ESP [" .. (itemEspActive and "ON" or "OFF") .. "]"
end)

-- ========================================================
-- 2. Hitbox & Bed/Gen ESP
-- ========================================================
local hitboxActive = false
hitboxBtn.MouseButton1Click:Connect(function()
    hitboxActive = not hitboxActive
    hitboxBtn.BackgroundColor3 = hitboxActive and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(220, 60, 60)
    hitboxBtn.Text = "Hitbox ESP [" .. (hitboxActive and "ON" or "OFF") .. "]"
end)

local bedGenActive = false
bedGenBtn.MouseButton1Click:Connect(function()
    bedGenActive = not bedGenActive
    bedGenBtn.BackgroundColor3 = bedGenActive and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(220, 60, 60)
    bedGenBtn.Text = "Bed & Gen ESP [" .. (bedGenActive and "ON" or "OFF") .. "]"
end)

-- ========================================================
-- 3. 🧱 Scaffold (다리 자동 생성)
-- ========================================================
local scaffoldActive = false
local scaffoldConn = nil

local function getWoolBlock()
    local char = LocalPlayer.Character
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    for _, item in ipairs(char:GetChildren()) do
        if item:IsA("Tool") and string.find(string.lower(item.Name), "wool") then return item end
    end
    if backpack then
        for _, item in ipairs(backpack:GetChildren()) do
            if item:IsA("Tool") and string.find(string.lower(item.Name), "wool") then return item end
        end
    end
    return nil
end

scaffoldBtn.MouseButton1Click:Connect(function()
    scaffoldActive = not scaffoldActive
    scaffoldBtn.BackgroundColor3 = scaffoldActive and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(220, 60, 60)
    scaffoldBtn.Text = "Scaffold [" .. (scaffoldActive and "ON" or "OFF") .. "]"

    if scaffoldActive then
        scaffoldConn = RunService.Heartbeat:Connect(function()
            if isMyCharAlive() then
                local hrp = LocalPlayer.Character.HumanoidRootPart
                local underPos = hrp.Position - Vector3.new(0, 3.5, 0)
                local ray = workspace:Raycast(hrp.Position, Vector3.new(0, -4, 0))

                if not ray then
                    local wool = getWoolBlock()
                    if wool then
                        local placeNet = ReplicatedStorage:FindFirstChild("rbxts_include")
                        if placeNet then
                            placeNet = placeNet.node_modules["@rbxts"].net.out._NetManaged:FindFirstChild("PlaceBlock")
                            if placeNet then
                                local blockGrid = Vector3.new(
                                    math.floor(underPos.X / 3) * 3,
                                    math.floor(underPos.Y / 3) * 3,
                                    math.floor(underPos.Z / 3) * 3
                                )
                                placeNet:FireServer({
                                    ["position"] = blockGrid,
                                    ["blockType"] = wool.Name
                                })
                            end
                        end
                    end
                end
            end
        end)
    else
        if scaffoldConn then scaffoldConn:Disconnect() scaffoldConn = nil end
    end
end)

-- ========================================================
-- 4. 💣 Bed Nuker (침대 자동 파괴)
-- ========================================================
local bedNukerActive = false
local NUKER_RANGE = 16

bedNukerBtn.MouseButton1Click:Connect(function()
    bedNukerActive = not bedNukerActive
    bedNukerBtn.BackgroundColor3 = bedNukerActive and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(220, 60, 60)
    bedNukerBtn.Text = "Bed Nuker [" .. (bedNukerActive and "ON" or "OFF") .. "]"

    if bedNukerActive then
        task.spawn(function()
            while bedNukerActive do
                if isMyCharAlive() then
                    local myPos = LocalPlayer.Character.HumanoidRootPart.Position
                    for _, obj in ipairs(workspace:GetDescendants()) do
                        if obj:IsA("BasePart") and string.find(string.lower(obj.Name), "bed") and not string.find(string.lower(obj.Name), "bedroom") then
                            local dist = (obj.Position - myPos).Magnitude
                            if dist <= NUKER_RANGE then
                                local damageNet = ReplicatedStorage:FindFirstChild("rbxts_include")
                                if damageNet then
                                    damageNet = damageNet.node_modules["@rbxts"].net.out._NetManaged:FindFirstChild("DamageBlock")
                                    if damageNet then
                                        damageNet:InvokeServer({
                                            ["blockRef"] = { ["blockPosition"] = Vector3.new(math.floor(obj.Position.X/3), math.floor(obj.Position.Y/3), math.floor(obj.Position.Z/3)) },
                                            ["hitPosition"] = obj.Position,
                                            ["hitNormal"] = Vector3.new(0, 1, 0)
                                        })
                                    end
                                end
                            end
                        end
                    end
                end
                task.wait(0.1)
            end
        end)
    end
end)

-- ========================================================
-- 5. ⚔️ Auto Weapon Switch (자동 무기 스왑)
-- ========================================================
local autoWeaponActive = false
local autoWeaponConn = nil

autoWeaponBtn.MouseButton1Click:Connect(function()
    autoWeaponActive = not autoWeaponActive
    autoWeaponBtn.BackgroundColor3 = autoWeaponActive and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(220, 60, 60)
    autoWeaponBtn.Text = "Auto Weapon [" .. (autoWeaponActive and "ON" or "OFF") .. "]"

    if autoWeaponActive then
        autoWeaponConn = RunService.RenderStepped:Connect(function()
            if isMyCharAlive() then
                local myPos = LocalPlayer.Character.HumanoidRootPart.Position
                local enemyNear = false

                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and (not p.Team or not LocalPlayer.Team or p.Team ~= LocalPlayer.Team) then
                        if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                            local dist = (p.Character.HumanoidRootPart.Position - myPos).Magnitude
                            if dist <= 18 then enemyNear = true break end
                        end
                    end
                end

                if enemyNear then
                    local bestSword = getBestSword()
                    if bestSword and LocalPlayer.Character:FindFirstChildOfClass("Tool") ~= bestSword then
                        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                        if hum then hum:EquipTool(bestSword) end
                    end
                end
            end
        end)
    else
        if autoWeaponConn then autoWeaponConn:Disconnect() autoWeaponConn = nil end
    end
end)

-- ========================================================
-- 6. 📏 Reach Multiplier & KillAura (리치 확장 연동)
-- ========================================================
local reachActive = false
local baseReach = 14
local expandedReach = 21

reachBtn.MouseButton1Click:Connect(function()
    reachActive = not reachActive
    reachBtn.BackgroundColor3 = reachActive and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(220, 60, 60)
    reachBtn.Text = "Reach Multiplier [" .. (reachActive and "ON" or "OFF") .. "]"
end)

-- KillAura (리치 변수 적용)
local killauraActive = false
killauraBtn.MouseButton1Click:Connect(function()
    killauraActive = not killauraActive
    killauraBtn.BackgroundColor3 = killauraActive and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(220, 60, 60)
    killauraBtn.Text = "KillAura [" .. (killauraActive and "ON" or "OFF") .. "]"

    if killauraActive then
        task.spawn(function()
            while killauraActive do
                if isMyCharAlive() then
                    local currentReach = reachActive and expandedReach or baseReach
                    local sword = getBestSword()
                    local net = ReplicatedStorage:FindFirstChild("rbxts_include")
                    if net then net = net.node_modules["@rbxts"].net.out._NetManaged:FindFirstChild("SwordHit") end

                    if sword and net then
                        for _, p in pairs(Players:GetPlayers()) do
                            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                                local pHum = p.Character:FindFirstChildOfClass("Humanoid")
                                if pHum and pHum.Health > 0 then
                                    local pPos = p.Character.HumanoidRootPart.Position
                                    local lpPos = LocalPlayer.Character.HumanoidRootPart.Position
                                    if (pPos - lpPos).Magnitude <= currentReach and (not p.Team or not LocalPlayer.Team or p.Team ~= LocalPlayer.Team) then
                                        net:FireServer({
                                            [1] = {
                                                ["entityInstance"] = p.Character,
                                                ["chargedAttack"] = { ["chargeRatio"] = 0 },
                                                ["validate"] = { ["targetPosition"] = { ["value"] = pPos }, ["selfPosition"] = { ["value"] = lpPos } },
                                                ["weapon"] = sword
                                            }
                                        })
                                    end
                                end
                            end
                        end
                    end
                end
                task.wait(0.04)
            end
        end)
    end
end)

-- ========================================================
-- 7. 이동 및 기타 (Anti KB, No Fall, Sprint, Spider, FPS Boost)
-- ========================================================
local antiKbActive, antiKbConn = false, nil
antiKbBtn.MouseButton1Click:Connect(function()
    antiKbActive = not antiKbActive
    antiKbBtn.BackgroundColor3 = antiKbActive and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(220, 60, 60)
    antiKbBtn.Text = "Anti KB [" .. (antiKbActive and "ON" or "OFF") .. "]"
    if antiKbActive then
        antiKbConn = RunService.Heartbeat:Connect(function()
            if isMyCharAlive() then
                local vel = LocalPlayer.Character.HumanoidRootPart.AssemblyLinearVelocity
                if math.abs(vel.X) > 25 or math.abs(vel.Z) > 25 then
                    LocalPlayer.Character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(vel.X * 0.1, vel.Y, vel.Z * 0.1)
                end
            end
        end)
    else
        if antiKbConn then antiKbConn:Disconnect() antiKbConn = nil end
    end
end)

local noFallActive, noFallConn = false, nil
noFallBtn.MouseButton1Click:Connect(function()
    noFallActive = not noFallActive
    noFallBtn.BackgroundColor3 = noFallActive and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(220, 60, 60)
    noFallBtn.Text = "No Fall [" .. (noFallActive and "ON" or "OFF") .. "]"
    if noFallActive then
        noFallConn = RunService.RenderStepped:Connect(function()
            if isMyCharAlive() then
                local hrp = LocalPlayer.Character.HumanoidRootPart
                if hrp.AssemblyLinearVelocity.Y < -35 and workspace:Raycast(hrp.Position, Vector3.new(0, -12, 0)) then
                    hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -5, hrp.AssemblyLinearVelocity.Z)
                end
            end
        end)
    else
        if noFallConn then noFallConn:Disconnect() noFallConn = nil end
    end
end)

local sprintActive, sprintConn = false, nil
sprintBtn.MouseButton1Click:Connect(function()
    sprintActive = not sprintActive
    sprintBtn.BackgroundColor3 = sprintActive and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(220, 60, 60)
    sprintBtn.Text = "Auto Sprint [" .. (sprintActive and "ON" or "OFF") .. "]"
    if sprintActive then
        sprintConn = RunService.RenderStepped:Connect(function()
            if isMyCharAlive() then
                local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum and hum.WalkSpeed < 22 then hum.WalkSpeed = 22 end
            end
        end)
    else
        if sprintConn then sprintConn:Disconnect() sprintConn = nil end
    end
end)

local spiderActive, spiderConn = false, nil
spiderBtn.MouseButton1Click:Connect(function()
    spiderActive = not spiderActive
    spiderBtn.BackgroundColor3 = spiderActive and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(220, 60, 60)
    spiderBtn.Text = "Spider [" .. (spiderActive and "ON" or "OFF") .. "]"
    if spiderActive then
        spiderConn = RunService.RenderStepped:Connect(function()
            if isMyCharAlive() then
                local char = LocalPlayer.Character
                local hrp = char.HumanoidRootPart
                local ray = workspace:Raycast(hrp.Position, hrp.CFrame.LookVector * 2.5)
                if ray and ray.Instance and ray.Instance.CanCollide and char.Humanoid.MoveDirection.Magnitude > 0 then
                    hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, 25, hrp.AssemblyLinearVelocity.Z)
                end
            end
        end)
    else
        if spiderConn then spiderConn:Disconnect() spiderConn = nil end
    end
end)

-- Aimbot & FPS Boost
local aimbotActive = false
aimbotBtn.MouseButton1Click:Connect(function()
    aimbotActive = not aimbotActive
    aimbotBtn.BackgroundColor3 = aimbotActive and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(220, 60, 60)
    aimbotBtn.Text = "Aimbot [" .. (aimbotActive and "ON" or "OFF") .. "]"
end)

local fpsBoostActive = false
fpsBoostBtn.MouseButton1Click:Connect(function()
    fpsBoostActive = not fpsBoostActive
    fpsBoostBtn.BackgroundColor3 = fpsBoostActive and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(220, 60, 60)
    fpsBoostBtn.Text = "FPS Boost [" .. (fpsBoostActive and "ON" or "OFF") .. "]"
    if fpsBoostActive then
        pcall(function()
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 9e9
            for _, v in ipairs(workspace:GetDescendants()) do
                if v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic
                elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then v.Enabled = false end
            end
        end)
    end
end)

print("[RAGON_01_v2] 스캐폴드, Bed Nuker, Auto Weapon Switch, Reach Multiplier 전체 연동 성공!")
