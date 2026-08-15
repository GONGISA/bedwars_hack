local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

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

-- 메인 프레임 (버튼 증가로 높이 310 확장)
local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = UDim2.new(0, 220, 0, 280)
frame.Position = UDim2.new(0.05, 0, 0.3, 0)
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
local sprintBtn = createButton("Auto Sprint", 130)
local spiderBtn = createButton("Spider", 175)
local killauraBtn = createButton("KillAura", 220)

-- ========================================================
-- 1. ESP 기능 (상시 유지 루프)
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
-- 2. 세로 체력바 ESP (Health ESP)
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
        -- 상대팀 판정
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
                    gui.Size = UDim2.new(0, 4, 0, 40) -- 세로 슬림 체력바
                    gui.ExtentsOffset = Vector3.new(-2.2, 0.3, 0) -- 캐릭터 좌측에 위치
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

                -- 체력 비율 반영 및 색상 변경 (녹색 -> 노란색 -> 빨간색)
                local fill = gui.BG:FindFirstChild("Fill")
                if fill then
                    local healthPct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                    fill.Size = UDim2.new(1, 0, healthPct, 0)
                    fill.Position = UDim2.new(0, 0, 1 - healthPct, 0) -- 아래에서부터 채워짐

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
-- 3. Auto Sprint (자동 달리기)
-- ========================================================
local sprintActive = false
local sprintConnection = nil
local SPRINT_SPEED = 22 -- 베드워즈 달리기는 일반적으로 속도 22

sprintBtn.MouseButton1Click:Connect(function()
    sprintActive = not sprintActive
    if sprintActive then
        sprintBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
        sprintBtn.Text = "Auto Sprint [ON]"
        
        sprintConnection = RunService.RenderStepped:Connect(function()
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
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
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = 16 end -- 기본 속도로 복원
        end
    end
end)

-- ========================================================
-- 4. Spider (벽타기)
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
            local char = LocalPlayer.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hrp or not hum then return end

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
-- 5. Bedwars KillAura
-- ========================================================
local killauraActive = false
local range = 35

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
                local sword = getSword()
                local net = ReplicatedStorage.rbxts_include.node_modules:FindFirstChild("@rbxts")
                if net then
                    net = net.net.out._NetManaged:FindFirstChild("SwordHit")
                end

                if sword and net then
                    for _, p in pairs(Players:GetPlayers()) do
                        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            local pPos = p.Character.HumanoidRootPart.Position
                            local lpPos = LocalPlayer.Character.HumanoidRootPart.Position
                            
                            if dist(lpPos, pPos) <= range and p.Team ~= LocalPlayer.Team then
                                local args = {
                                    [1] = {
                                        ["entityInstance"] = p.Character,
                                        ["chargedAttack"] = {
                                            ["chargeRatio"] = 0
                                        },
                                        ["validate"] = {
                                            ["targetPosition"] = {
                                                ["value"] = pPos
                                            },
                                            ["selfPosition"] = {
                                                ["value"] = lpPos
                                            }
                                        },
                                        ["weapon"] = sword
                                    }
                                }
                                net:FireServer(unpack(args))
                            end
                        end
                    end
                end
                task.wait(0.05)
            end
        end)
    else
        killauraBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
        killauraBtn.Text = "KillAura [OFF]"
    end
end)

print("[RAGON_01] 기능 추가 완료 (Health ESP & AutoSprint).")
