local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
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
frame.Size = UDim2.new(0, 220, 0, 370)
frame.Position = UDim2.new(0.05, 0, 0.25, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = frame

-- 타이틀
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundTransparency = 1
title.Text = "RAGON_01"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 18
title.Font = Enum.Font.SourceSansBold
title.Parent = frame

-- 버튼 생성 함수
local function createButton(name, posY)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.85, 0, 0, 36)
    btn.Position = UDim2.new(0.075, 0, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
    btn.Text = name .. " [OFF]"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 13
    btn.Font = Enum.Font.SourceSansSemibold
    btn.Parent = frame

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn

    return btn
end

local espBtn = createButton("ESP", 40)
local healthBtn = createButton("Health ESP", 85)
local itemEspBtn = createButton("Item & Armor ESP", 130)
local sprintBtn = createButton("Auto Sprint", 175)
local spiderBtn = createButton("Spider", 220)
local killauraBtn = createButton("KillAura", 265)
local aimbotBtn = createButton("Aimbot", 310)

-- 내 캐릭터 생존 확인 함수
local function isMyCharAlive()
    local char = LocalPlayer.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    return hum and hum.Health > 0 and hrp ~= nil
end

-- ========================================================
-- 1. ESP 기능
-- ========================================================
local espActive = false

local function removeAllESP()
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character and p.Character:FindFirstChild("TestESP") then
            p.Character.TestESP:Destroy()
        end
    end
end

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
                if char:FindFirstChild("TestESP") then
                    char.TestESP:Destroy()
                end
            end
        end
    end
end

espBtn.MouseButton1Click:Connect(function()
    espActive = not espActive
    if espActive then
        espBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
        espBtn.Text = "ESP [ON]"
        task.spawn(function()
            while espActive do
                updateESP()
                task.wait(0.2)
            end
        end)
    else
        espBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
        espBtn.Text = "ESP [OFF]"
        removeAllESP()
    end
end)

-- ========================================================
-- 2. 세로 체력바 ESP
-- ========================================================
local healthActive = false

local function removeAllHealthBars()
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp and hrp:FindFirstChild("HealthESP_Gui") then
                hrp.HealthESP_Gui:Destroy()
            end
        end
    end
end

local function updateHealthBars()
    for _, p in ipairs(Players:GetPlayers()) do
        local isEnemy = (p ~= LocalPlayer) and (not p.Team or not LocalPlayer.Team or p.Team ~= LocalPlayer.Team)
        
        if isEnemy and p.Character then
            local char = p.Character
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")

            if hrp and hum and hum.Health > 0 then
                local gui = hrp:FindFirstChild("HealthESP_Gui")
                if not gui then
                    gui = Instance.new("BillboardGui")
                    gui.Name = "HealthESP_Gui"
                    gui.Adornee = hrp
                    gui.Size = UDim2.new(0, 4, 0, 40)
                    gui.ExtentsOffset = Vector3.new(-2.2, 0.3, 0)
                    gui.AlwaysOnTop = true
                    gui.Parent = hrp

                    local bg = Instance.new("Frame")
                    bg.Name = "BG"
                    bg.Size = UDim2.new(1, 0, 1, 0)
                    bg.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
                    bg.BorderSizePixel = 1
                    bg.BorderColor3 = Color3.fromRGB(0, 0, 0)
                    bg.Parent = gui

                    local fill = Instance.new("Frame")
                    fill.Name = "Fill"
                    fill.Size = UDim2.new(1, 0, 1, 0)
                    fill.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
                    fill.BorderSizePixel = 0
                    fill.Parent = bg
                end

                local fill = gui.BG:FindFirstChild("Fill")
                if fill then
                    local healthPct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                    fill.Size = UDim2.new(1, 0, healthPct, 0)
                    fill.Position = UDim2.new(0, 0, 1 - healthPct, 0)

                    if healthPct > 0.5 then
                        fill.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
                    elseif healthPct > 0.25 then
                        fill.BackgroundColor3 = Color3.fromRGB(241, 196, 15)
                    else
                        fill.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
                    end
                end
            else
                if hrp and hrp:FindFirstChild("HealthESP_Gui") then
                    hrp.HealthESP_Gui:Destroy()
                end
            end
        end
    end
end

healthBtn.MouseButton1Click:Connect(function()
    healthActive = not healthActive
    if healthActive then
        healthBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
        healthBtn.Text = "Health ESP [ON]"
        task.spawn(function()
            while healthActive do
                updateHealthBars()
                task.wait(0.1)
            end
        end)
    else
        healthBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
        healthBtn.Text = "Health ESP [OFF]"
        removeAllHealthBars()
    end
end)

-- ========================================================
-- 3. Item & Armor ESP (무기 및 갑옷 정밀 탐지)
-- ========================================================
local itemEspActive = false

-- 플레이어가 들고 있는 무기 감지
local function getHeldWeapon(p)
    local char = p.Character
    if not char then return "맨손" end

    -- 1. Tool 객체 탐지
    local tool = char:FindFirstChildOfClass("Tool")
    if tool then
        local name = string.lower(tool.Name)
        if string.find(name, "emerald_sword") then return "에메검" end
        if string.find(name, "diamond_sword") then return "다이아검" end
        if string.find(name, "iron_sword") then return "철검" end
        if string.find(name, "stone_sword") then return "돌검" end
        if string.find(name, "wood_sword") then return "나무검" end
        if string.find(name, "bow") or string.find(name, "crossbow") then return "활/석궁" end
        return tool.Name
    end

    -- 2. HandItem Mesh/Accessory 탐지 (베드워즈 특수 연동)
    for _, child in ipairs(char:GetChildren()) do
        local name = string.lower(child.Name)
        if string.find(name, "emerald_sword") then return "에메검" end
        if string.find(name, "diamond_sword") then return "다이아검" end
        if string.find(name, "iron_sword") then return "철검" end
        if string.find(name, "stone_sword") then return "돌검" end
        if string.find(name, "wood_sword") then return "나무검" end
    end

    return "맨손"
end

-- 플레이어가 입고 있는 갑옷 감지
local function getEquippedArmor(p)
    local char = p.Character
    if not char then return "노갑" end

    local highestArmor = "노갑"
    local armorPriority = { ["노갑"] = 0, ["가죽갑"] = 1, ["철갑"] = 2, ["다이아갑"] = 3, ["에메갑"] = 4 }

    for _, child in ipairs(char:GetDescendants()) do
        local name = string.lower(child.Name)
        local detected = nil
        
        if string.find(name, "emerald") and (string.find(name, "helmet") or string.find(name, "chest") or string.find(name, "boots") or string.find(name, "armor")) then
            detected = "에메갑"
        elseif string.find(name, "diamond") and (string.find(name, "helmet") or string.find(name, "chest") or string.find(name, "boots") or string.find(name, "armor")) then
            detected = "다이아갑"
        elseif string.find(name, "iron") and (string.find(name, "helmet") or string.find(name, "chest") or string.find(name, "boots") or string.find(name, "armor")) then
            detected = "철갑"
        elseif string.find(name, "leather") and (string.find(name, "helmet") or string.find(name, "chest") or string.find(name, "boots") or string.find(name, "armor")) then
            detected = "가죽갑"
        end

        if detected and armorPriority[detected] > armorPriority[highestArmor] then
            highestArmor = detected
        end
    end

    return highestArmor
end

-- 인벤토리 자원 감지 (보관함 참조 가능 시)
local function getResources(p)
    local iron, diamond, emerald = 0, 0, 0
    local invs = ReplicatedStorage:FindFirstChild("Inventories")
    if invs then
        local inv = invs:FindFirstChild(p.Name)
        if inv then
            for _, item in ipairs(inv:GetChildren()) do
                local name = string.lower(item.Name)
                local amt = item:FindFirstChild("Amount") or item:FindFirstChild("Quantity")
                local count = (amt and amt.Value) or item:GetAttribute("Amount") or 1

                if string.find(name, "iron") then iron = iron + count
                elseif string.find(name, "diamond") then diamond = diamond + count
                elseif string.find(name, "emerald") then emerald = emerald + count end
            end
        end
    end
    return iron, diamond, emerald
end

local function removeAllItemESP()
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then
            local head = p.Character:FindFirstChild("Head")
            if head and head:FindFirstChild("ItemESP_Gui") then
                head.ItemESP_Gui:Destroy()
            end
        end
    end
end

local function updateItemESP()
    for _, p in ipairs(Players:GetPlayers()) do
        local isEnemy = (p ~= LocalPlayer) and (not p.Team or not LocalPlayer.Team or p.Team ~= LocalPlayer.Team)
        
        if isEnemy and p.Character then
            local char = p.Character
            local head = char:FindFirstChild("Head")
            local hum = char:FindFirstChildOfClass("Humanoid")

            if head and hum and hum.Health > 0 then
                local gui = head:FindFirstChild("ItemESP_Gui")
                if not gui then
                    gui = Instance.new("BillboardGui")
                    gui.Name = "ItemESP_Gui"
                    gui.Adornee = head
                    gui.Size = UDim2.new(0, 200, 0, 40)
                    gui.ExtentsOffset = Vector3.new(0, 2.8, 0)
                    gui.AlwaysOnTop = true
                    gui.Parent = head

                    local txt = Instance.new("TextLabel")
                    txt.Name = "InfoLabel"
                    txt.Size = UDim2.new(1, 0, 1, 0)
                    txt.BackgroundTransparency = 1
                    txt.TextColor3 = Color3.fromRGB(255, 255, 255)
                    txt.TextSize = 12
                    txt.Font = Enum.Font.SourceSansBold
                    txt.TextStrokeTransparency = 0.2
                    txt.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                    txt.Parent = gui
                end

                local label = gui:FindFirstChild("InfoLabel")
                if label then
                    local weapon = getHeldWeapon(p)
                    local armor = getEquippedArmor(p)
                    local iron, dia, eme = getResources(p)
                    
                    label.Text = string.format("[%s | %s]\n⚪ %d | 🔷 %d | 🟩 %d", weapon, armor, iron, dia, eme)
                end
            else
                if head and head:FindFirstChild("ItemESP_Gui") then
                    head.ItemESP_Gui:Destroy()
                end
            end
        end
    end
end

itemEspBtn.MouseButton1Click:Connect(function()
    itemEspActive = not itemEspActive
    if itemEspActive then
        itemEspBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
        itemEspBtn.Text = "Item ESP [ON]"
        task.spawn(function()
            while itemEspActive do
                updateItemESP()
                task.wait(0.25)
            end
        end)
    else
        itemEspBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
        itemEspBtn.Text = "Item ESP [OFF]"
        removeAllItemESP()
    end
end)

-- ========================================================
-- 4. Auto Sprint
-- ========================================================
local sprintActive = false
local sprintConnection = nil
local SPRINT_SPEED = 22

sprintBtn.MouseButton1Click:Connect(function()
    sprintActive = not sprintActive
    if sprintActive then
        sprintBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
        sprintBtn.Text = "Auto Sprint [ON]"
        
        sprintConnection = RunService.RenderStepped:Connect(function()
            if isMyCharAlive() then
                local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum and hum.WalkSpeed < SPRINT_SPEED then
                    hum.WalkSpeed = SPRINT_SPEED
                end
            end
        end)
    else
        sprintBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
        sprintBtn.Text = "Auto Sprint [OFF]"
        if sprintConnection then
            sprintConnection:Disconnect()
            sprintConnection = nil
        end
        if isMyCharAlive() then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = 16 end
        end
    end
end)

-- ========================================================
-- 5. Spider
-- ========================================================
local spiderActive = false
local spiderConnection = nil
local RAY_DIST = 2.5
local CLIMB_SPEED = 25
local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude

spiderBtn.MouseButton1Click:Connect(function()
    spiderActive = not spiderActive
    if spiderActive then
        spiderBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
        spiderBtn.Text = "Spider [ON]"
        
        spiderConnection = RunService.RenderStepped:Connect(function()
            if not isMyCharAlive() then return end
            local char = LocalPlayer.Character
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")

            rayParams.FilterDescendantsInstances = {char}
            local rayResult = workspace:Raycast(hrp.Position, hrp.CFrame.LookVector * RAY_DIST, rayParams)

            if rayResult and rayResult.Instance and rayResult.Instance.CanCollide then
                if hum.MoveDirection.Magnitude > 0 then
                    hrp.AssemblyLinearVelocity = Vector3.new(
                        hrp.AssemblyLinearVelocity.X,
                        CLIMB_SPEED,
                        hrp.AssemblyLinearVelocity.Z
                    )
                end
            end
        end)
    else
        spiderBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
        spiderBtn.Text = "Spider [OFF]"
        if spiderConnection then
            spiderConnection:Disconnect()
            spiderConnection = nil
        end
    end
end)

-- ========================================================
-- 6. Bedwars KillAura
-- ========================================================
local killauraActive = false
local range = 14

local function getSword()
    local inv = ReplicatedStorage.Inventories:FindFirstChild(LocalPlayer.Name)
    if not inv then return nil end
    return inv:FindFirstChild("wood_sword") or
           inv:FindFirstChild("stone_sword") or
           inv:FindFirstChild("iron_sword") or
           inv:FindFirstChild("diamond_sword") or
           inv:FindFirstChild("emerald_sword")
end

local function dist(p1, p2)
    return (p1 - p2).Magnitude
end

killauraBtn.MouseButton1Click:Connect(function()
    killauraActive = not killauraActive
    if killauraActive then
        killauraBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
        killauraBtn.Text = "KillAura [ON]"

        task.spawn(function()
            while killauraActive do
                if isMyCharAlive() then
                    local sword = getSword()
                    local net = ReplicatedStorage.rbxts_include.node_modules:FindFirstChild("@rbxts")
                    if net then
                        net = net.net.out._NetManaged:FindFirstChild("SwordHit")
                    end

                    if sword and net then
                        for _, p in pairs(Players:GetPlayers()) do
                            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                                local pHum = p.Character:FindFirstChildOfClass("Humanoid")
                                if pHum and pHum.Health > 0 then
                                    local pPos = p.Character.HumanoidRootPart.Position
                                    local lpPos = LocalPlayer.Character.HumanoidRootPart.Position
                                    
                                    if dist(lpPos, pPos) <= range and (not p.Team or not LocalPlayer.Team or p.Team ~= LocalPlayer.Team) then
                                        local args = {
                                            [1] = {
                                                ["entityInstance"] = p.Character,
                                                ["chargedAttack"] = { ["chargeRatio"] = 0 },
                                                ["validate"] = {
                                                    ["targetPosition"] = { ["value"] = pPos },
                                                    ["selfPosition"] = { ["value"] = lpPos }
                                                },
                                                ["weapon"] = sword
                                            }
                                        }
                                        net:FireServer(unpack(args))
                                    end
                                end
                            end
                        end
                    end
                end
                task.wait(0.04)
            end
        end)
    else
        killauraBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
        killauraBtn.Text = "KillAura [OFF]"
    end
end)

-- ========================================================
-- 7. 원거리 무기 Aimbot (차징 시간 기반 보정)
-- ========================================================
local aimbotActive = false
local aimbotConnection = nil
local chargeStart = 0
local isCharging = false

local MIN_SPEED = 90
local MAX_SPEED = 280
local MAX_CHARGE_TIME = 1.0
local GRAVITY = workspace.Gravity

local function isHoldingRangedWeapon()
    if not isMyCharAlive() then return false end
    local char = LocalPlayer.Character
    local tool = char:FindFirstChildOfClass("Tool")
    if tool then
        local name = string.lower(tool.Name)
        if string.find(name, "bow") or string.find(name, "crossbow") or string.find(name, "headhunter") then
            return true
        end
    end
    return false
end

local function getClosestEnemy()
    local closestHead = nil
    local shortestDist = math.huge
    if not isMyCharAlive() then return nil end
    local myHrp = LocalPlayer.Character.HumanoidRootPart

    for _, p in ipairs(Players:GetPlayers()) do
        local isEnemy = (p ~= LocalPlayer) and (not p.Team or not LocalPlayer.Team or p.Team ~= LocalPlayer.Team)
        if isEnemy and p.Character then
            local head = p.Character:FindFirstChild("Head")
            local hum = p.Character:FindFirstChildOfClass("Humanoid")

            if head and hum and hum.Health > 0 then
                local distance = (myHrp.Position - head.Position).Magnitude
                if distance < shortestDist then
                    shortestDist = distance
                    closestHead = head
                end
            end
        end
    end
    return closestHead
end

local function calculatePredictedPosition(targetPosition, currentSpeed)
    local camPos = Camera.CFrame.Position
    local distance = (targetPosition - camPos).Magnitude
    local timeOfFlight = distance / currentSpeed
    local dropCompensation = 0.5 * GRAVITY * (timeOfFlight ^ 2)
    
    return targetPosition + Vector3.new(0, dropCompensation, 0)
end

aimbotBtn.MouseButton1Click:Connect(function()
    aimbotActive = not aimbotActive
    if aimbotActive then
        aimbotBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
        aimbotBtn.Text = "Aimbot [ON]"

        aimbotConnection = RunService.RenderStepped:Connect(function()
            local rmbPressed = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
            
            if rmbPressed and isHoldingRangedWeapon() then
                if not isCharging then
                    isCharging = true
                    chargeStart = tick()
                end

                local holdTime = math.min(tick() - chargeStart, MAX_CHARGE_TIME)
                local chargeRatio = holdTime / MAX_CHARGE_TIME
                local currentSpeed = MIN_SPEED + (MAX_SPEED - MIN_SPEED) * chargeRatio

                local targetHead = getClosestEnemy()
                if targetHead me then
                    local targetPos = calculatePredictedPosition(targetHead.Position, currentSpeed)
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPos)
                end
            else
                isCharging = false
            end
        end)
    else
        aimbotBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
        aimbotBtn.Text = "Aimbot [OFF]"
        if aimbotConnection then
            aimbotConnection:Disconnect()
            aimbotConnection = nil
        end
        isCharging = false
    end
end)

print("[RAGON_01] 베드워즈 전용 Item & Armor ESP 업데이트 완료.")
