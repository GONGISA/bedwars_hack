local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- 디스코드 링크 클립보드 복사 (실행 환경에 따라 지원 안 할 수 있어 pcall 처리)
pcall(function()
    if setclipboard then
        setclipboard('https://discord.gg/VudXCDCaBN')
    end
end)

-- UI 생성 (CoreGui 지원 안 될 시 PlayerGui 사용)
local parentContainer = game:GetService("CoreGui")
if not pcall(function() local _ = parentContainer.Name end) then
    parentContainer = LocalPlayer:WaitForChild("PlayerGui")
end

-- 기존 UI가 있다면 삭제
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
frame.Size = UDim2.new(0, 220, 0, 240)
frame.Position = UDim2.new(0.05, 0, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true -- UI 마우스 드래그 이동 가능
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = frame

-- 타이틀 (RAGON_01 로 변경 완료)
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "RAGON_01"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 18
title.Font = Enum.Font.SourceSansBold
title.Parent = frame

-- 버튼 생성용 도우미 함수
local function createButton(name, posY)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.85, 0, 0, 40)
    btn.Position = UDim2.new(0.075, 0, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(220, 60, 60) -- 초기 상태: 빨간색 (OFF)
    btn.Text = name .. " [OFF]"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 14
    btn.Font = Enum.Font.SourceSansSemibold
    btn.Parent = frame

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn

    return btn
end

local espBtn = createButton("ESP", 50)
local spiderBtn = createButton("Spider", 100)
local killauraBtn = createButton("KillAura", 150)

-- ========================================================
-- 1. ESP 기능 구현 (Toggle)
-- ========================================================
local espActive = false
local espConnections = {}

local function removeESP(player)
    if player.Character and player.Character:FindFirstChild("TestESP") then
        player.Character.TestESP:Destroy()
    end
end

local function applyESP(player)
    if player == LocalPlayer then return end
    
    local function setup(char)
        if not espActive then return end
        if char:FindFirstChild("TestESP") then return end
        local hl = Instance.new("Highlight")
        hl.Name = "TestESP"
        hl.Adornee = char
        hl.FillColor = Color3.fromRGB(255, 50, 50)
        hl.FillTransparency = 0.5
        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent = char
    end

    if player.Character then setup(player.Character) end
    local conn = player.CharacterAdded:Connect(setup)
    table.insert(espConnections, conn)
end

espBtn.MouseButton1Click:Connect(function()
    espActive = not espActive
    if espActive then
        espBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113) -- 초록색 (ON)
        espBtn.Text = "ESP [ON]"
        for _, p in ipairs(Players:GetPlayers()) do applyESP(p) end
        local conn = Players.PlayerAdded:Connect(applyESP)
        table.insert(espConnections, conn)
    else
        espBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60) -- 빨간색 (OFF)
        espBtn.Text = "ESP [OFF]"
        for _, conn in ipairs(espConnections) do conn:Disconnect() end
        espConnections = {}
        for _, p in ipairs(Players:GetPlayers()) do removeESP(p) end
    end
end)

-- ========================================================
-- 2. Spider (벽타기) 기능 구현 (Toggle)
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
-- 3. Bedwars KillAura (제시해주신 로직 통합)
-- ========================================================
local killauraActive = false
local range = 20

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

        -- 루프 동작 (토글이 켜져 있을 때만 작동)
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
                            
                            -- 사거리 측정 및 팀 확인
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
                task.wait(0.07)
            end
        end)
    else
        killauraBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
        killauraBtn.Text = "KillAura [OFF]"
    end
end)

print("[RAGON_01] 패널이 성공적으로 로드되었습니다.")
