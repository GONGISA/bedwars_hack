local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- UI 생성 (CoreGui 지원 안 될 시 PlayerGui 사용)
local parentContainer = game:GetService("CoreGui")
if not pcall(function() local _ = parentContainer.Name end) then
    parentContainer = LocalPlayer:WaitForChild("PlayerGui")
end

-- 기존 UI가 있다면 삭제
if parentContainer:FindFirstChild("SecurityTestUI") then
    parentContainer.SecurityTestUI:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SecurityTestUI"
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

-- 타이틀
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "Security Test Panel"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 16
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
-- 3. KillAura (근접 자동 공격 모의) 기능 구현 (Toggle)
-- ========================================================
local killauraActive = false
local killauraConnection = nil
local ATTACK_RANGE = 15 -- 사거리 테스트 (스터드)

killauraBtn.MouseButton1Click:Connect(function()
    killauraActive = not killauraActive
    if killauraActive then
        killauraBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
        killauraBtn.Text = "KillAura [ON]"

        killauraConnection = RunService.RenderStepped:Connect(function()
            local myChar = LocalPlayer.Character
            if not myChar then return end
            local myHrp = myChar:FindFirstChild("HumanoidRootPart")
            if not myHrp then return end

            -- 주변 15스터드 내 플레이어 검색
            for _, target in ipairs(Players:GetPlayers()) do
                if target ~= LocalPlayer and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                    local targetHrp = target.Character.HumanoidRootPart
                    local dist = (myHrp.Position - targetHrp.Position).Magnitude

                    if dist <= ATTACK_RANGE then
                        -- 게임 내 공격 리모트 이벤트명을 넣어서 검증
                        local attackRemote = ReplicatedStorage:FindFirstChild("AttackRemote")
                        if attackRemote then
                            attackRemote:FireServer(target)
                        end
                    end
                end
            end
        end)
    else
        killauraBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
        killauraBtn.Text = "KillAura [OFF]"
        if killauraConnection then
            killauraConnection:Disconnect()
            killauraConnection = nil
        end
    end
end)

print("[TestPanel] 성공적으로 로드되었습니다.")
