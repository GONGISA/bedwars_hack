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

-- 메인 프레임 (버튼 증가로 높이 조정 510px)
local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = UDim2.new(0, 230, 0, 510)
frame.Position = UDim2.new(0.04, 0, 0.15, 0)
frame.BackgroundColor3 = Color3.fromRGB(28, 28, 33)
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
title.Text = "RAGON_01 [BEDWARS]"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 16
title.Font = Enum.Font.SourceSansBold
title.Parent = frame

-- 버튼 생성 함수
local function createButton(name, posY)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.88, 0, 0, 32)
    btn.Position = UDim2.new(0.06, 0, 0, posY)
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

local espBtn        = createButton("ESP", 40)
local healthBtn     = createButton("Health ESP", 77)
local itemEspBtn    = createButton("Item & Armor ESP (Big)", 114)
local hitboxBtn     = createButton("Hitbox ESP", 151)
local bedGenBtn     = createButton("Bed & Gen ESP", 188)
local antiKbBtn     = createButton("Anti Knockback", 225)
local noFallBtn     = createButton("No Fall Damage", 262)
local sprintBtn     = createButton("Auto Sprint", 299)
local spiderBtn     = createButton("Spider", 336)
local killauraBtn   = createButton("KillAura", 373)
local aimbotBtn     = createButton("Aimbot", 410)
local fpsBoostBtn   = createButton("FPS Boost (렉제거)", 447)

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
-- 2. 동적 체력바 ESP
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
    local myHrp = isMyCharAlive() and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

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

                local distScale = 1
                if myHrp then
                    local dist = (myHrp.Position - hrp.Position).Magnitude
                    distScale = math.clamp(85 / math.max(dist, 10), 0.4, 2.5)
                end
                
                local hitboxYRatio = hrp.Size.Y / 2
                local barWidth = math.max(4, math.floor(5 * distScale))
                local barHeight = math.floor(38 * distScale * hitboxYRatio)
                
                gui.Size = UDim2.new(0, barWidth, 0, barHeight)
                gui.ExtentsOffset = Vector3.new(-2.0 * (distScale * math.max(1, hrp.Size.X / 3)), 0, 0)

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
-- 3. Item & Armor ESP (크기 및 폰트 대폭 확대)
-- ========================================================
local itemEspActive = false

local function getHeldWeapon(p)
    local char = p.Character
    if not char then return "맨손" end

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
                    gui.Size = UDim2.new(0, 280, 0, 60) -- 기존보다 크게 확대
                    gui.ExtentsOffset = Vector3.new(0, 3.2, 0)
                    gui.AlwaysOnTop = true
                    gui.Parent = head

                    local txt = Instance.new("TextLabel")
                    txt.Name = "InfoLabel"
                    txt.Size = UDim2.new(1, 0, 1, 0)
                    txt.BackgroundTransparency = 1
                    txt.TextColor3 = Color3.fromRGB(255, 255, 255)
                    txt.TextSize = 16 -- 글씨 크기 12 -> 16 확대
                    txt.Font = Enum.Font.SourceSansBold
                    txt.TextStrokeTransparency = 0
                    txt.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                    txt.Parent = gui
                end

                local label = gui:FindFirstChild("InfoLabel")
                if label then
                    local weapon = getHeldWeapon(p)
                    local armor = getEquippedArmor(p)
                    local iron, dia, eme = getResources(p)
                    
                    label.Text = string.format("⚔️ [%s | %s]\n⚪ %d  |  🔷 %d  |  🟩 %d", weapon, armor, iron, dia, eme)
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
                task.wait(0.2)
            end
        end)
    else
        itemEspBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
        itemEspBtn.Text = "Item ESP [OFF]"
        removeAllItemESP()
    end
end)

-- ========================================================
-- 4. Hitbox ESP
-- ========================================================
local hitboxActive = false
local HITBOX_SIZE = Vector3.new(6, 6, 6)

local function removeAllHitbox()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.Size = Vector3.new(2, 2, 1)
                hrp.Transparency = 1
                hrp.CanCollide = false
                if hrp:FindFirstChild("HitboxBox") then
                    hrp.HitboxBox:Destroy()
                end
            end
        end
    end
end

local function updateHitbox()
    for _, p in ipairs(Players:GetPlayers()) do
        local isEnemy = (p ~= LocalPlayer) and (not p.Team or not LocalPlayer.Team or p.Team ~= LocalPlayer.Team)
        if isEnemy and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            local hum = p.Character:FindFirstChildOfClass("Humanoid")

            if hrp and hum and hum.Health > 0 then
                hrp.Size = HITBOX_SIZE
                hrp.Transparency = 0.75
                hrp.BrickColor = BrickColor.new("Really red")
                hrp.Material = Enum.Material.Neon
                hrp.CanCollide = false

                if not hrp:FindFirstChild("HitboxBox") then
                    local box = Instance.new("SelectionBox")
                    box.Name = "HitboxBox"
                    box.Adornee = hrp
                    box.Color3 = Color3.fromRGB(255, 60, 60)
                    box.LineThickness = 0.05
                    box.Parent = hrp
                end
            else
                if hrp then
                    hrp.Size = Vector3.new(2, 2, 1)
                    hrp.Transparency = 1
                    if hrp:FindFirstChild("HitboxBox") then
                        hrp.HitboxBox:Destroy()
                    end
                end
            end
        end
    end
end

hitboxBtn.MouseButton1Click:Connect(function()
    hitboxActive = not hitboxActive
    if hitboxActive then
        hitboxBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
        hitboxBtn.Text = "Hitbox ESP [ON]"
        task.spawn(function()
            while hitboxActive do
                updateHitbox()
                task.wait(0.2)
            end
        end)
    else
        hitboxBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
        hitboxBtn.Text = "Hitbox ESP [OFF]"
        removeAllHitbox()
    end
end)

-- ========================================================
-- 5. 침대 및 제너레이터 ESP
-- ========================================================
local bedGenActive = false

local function removeBedGenESP()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:FindFirstChild("BedGen_ESP") then
            obj.BedGen_ESP:Destroy()
        end
    end
end

local function updateBedGenESP()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Model") then
            local name = string.lower(obj.Name)
            local espText, espColor = nil, nil

            if string.find(name, "bed") and not string.find(name, "bedroom") then
                espText = "🛏️ [BED]"
                espColor = Color3.fromRGB(255, 80, 80)
            elseif string.find(name, "diamond") and (string.find(name, "generator") or string.find(name, "gen")) then
                espText = "🔷 [DIAMOND GEN]"
                espColor = Color3.fromRGB(0, 200, 255)
            elseif string.find(name, "emerald") and (string.find(name, "generator") or string.find(name, "gen")) then
                espText = "🟩 [EMERALD GEN]"
                espColor = Color3.fromRGB(50, 255, 100)
            end

            if espText then
                local targetPart = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj
                if targetPart and not targetPart:FindFirstChild("BedGen_ESP") then
                    local bg = Instance.new("BillboardGui")
                    bg.Name = "BedGen_ESP"
                    bg.Adornee = targetPart
                    bg.Size = UDim2.new(0, 160, 0, 30)
                    bg.AlwaysOnTop = true
                    bg.Parent = targetPart

                    local txt = Instance.new("TextLabel")
                    txt.Size = UDim2.new(1, 0, 1, 0)
                    txt.BackgroundTransparency = 1
                    txt.Text = espText
                    txt.TextColor3 = espColor
                    txt.TextSize = 14
                    txt.Font = Enum.Font.SourceSansBold
                    txt.TextStrokeTransparency = 0
                    txt.Parent = bg
                end
            end
        end
    end
end

bedGenBtn.MouseButton1Click:Connect(function()
    bedGenActive = not bedGenActive
    if bedGenActive then
        bedGenBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
        bedGenBtn.Text = "Bed & Gen ESP [ON]"
        task.spawn(function()
            while bedGenActive do
                updateBedGenESP()
                task.wait(2.0)
            end
        end)
    else
        bedGenBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
        bedGenBtn.Text = "Bed & Gen ESP [OFF]"
        removeBedGenESP()
    end
end)

-- ========================================================
-- 6. Anti Knockback (넉백 감소)
-- ========================================================
local antiKbActive = false
local antiKbConn = nil

antiKbBtn.MouseButton1Click:Connect(function()
    antiKbActive = not antiKbActive
    if antiKbActive then
        antiKbBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
        antiKbBtn.Text = "Anti KB [ON]"
        
        antiKbConn = RunService.Heartbeat:Connect(function()
            if isMyCharAlive() then
                local hrp = LocalPlayer.Character.HumanoidRootPart
                local vel = hrp.AssemblyLinearVelocity
                -- 피격 시 수평 방향 넉백 속도 제한/제거
                if math.abs(vel.X) > 25 or math.abs(vel.Z) > 25 then
                    hrp.AssemblyLinearVelocity = Vector3.new(vel.X * 0.1, vel.Y, vel.Z * 0.1)
                end
            end
        end)
    else
        antiKbBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
        antiKbBtn.Text = "Anti KB [OFF]"
        if antiKbConn then
            antiKbConn:Disconnect()
            antiKbConn = nil
        end
    end
end)

-- ========================================================
-- 7. No Fall Damage (낙사 방지)
-- ========================================================
local noFallActive = false
local noFallConn = nil

noFallBtn.MouseButton1Click:Connect(function()
    noFallActive = not noFallActive
    if noFallActive then
        noFallBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
        noFallBtn.Text = "No Fall [ON]"

        noFallConn = RunService.RenderStepped:Connect(function()
            if isMyCharAlive() then
                local hrp = LocalPlayer.Character.HumanoidRootPart
                if hrp.AssemblyLinearVelocity.Y < -35 then
                    local ray = workspace:Raycast(hrp.Position, Vector3.new(0, -12, 0))
                    if ray then
                        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -5, hrp.AssemblyLinearVelocity.Z)
                    end
                end
            end
        end)
    else
        noFallBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
        noFallBtn.Text = "No Fall [OFF]"
        if noFallConn then
            noFallConn:Disconnect()
            noFallConn = nil
        end
    end
end)

-- ========================================================
-- 8. Auto Sprint
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
-- 9. Spider
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
-- 10. Bedwars KillAura
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
-- 11. Aimbot
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
                if targetHead then
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

-- ========================================================
-- 12. FPS Boost (렉제거 & 최적화)
-- ========================================================
local fpsBoostActive = false

fpsBoostBtn.MouseButton1Click:Connect(function()
    fpsBoostActive = not fpsBoostActive
    if fpsBoostActive then
        fpsBoostBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
        fpsBoostBtn.Text = "FPS Boost [ON]"

        pcall(function()
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 9e9
            
            for _, v in ipairs(workspace:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.Material = Enum.Material.SmoothPlastic
                elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") then
                    v.Enabled = false
                end
            end
        end)
    else
        fpsBoostBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
        fpsBoostBtn.Text = "FPS Boost [OFF]"
    end
end)

-- ========================================================
-- 📢 적팀 침대 파괴 감지 및 실시간 화면 알림
-- ========================================================
local alertGui = Instance.new("BillboardGui")
alertGui.Name = "BedAlertBanner"

local function showBedBreakAlert(msg)
    local alertLabel = Instance.new("TextLabel")
    alertLabel.Size = UDim2.new(0, 360, 0, 45)
    alertLabel.Position = UDim2.new(0.5, -180, 0.1, 0)
    alertLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    alertLabel.BackgroundTransparency = 0.2
    alertLabel.TextColor3 = Color3.fromRGB(255, 220, 50)
    alertLabel.TextSize = 16
    alertLabel.Font = Enum.Font.SourceSansBold
    alertLabel.Text = "⚠️ " .. msg
    alertLabel.Parent = screenGui

    local alertCorner = Instance.new("UICorner")
    alertCorner.CornerRadius = UDim.new(0, 8)
    alertCorner.Parent = alertLabel

    task.delay(4, function()
        if alertLabel then alertLabel:Destroy() end
    end)
end

workspace.DescendantRemoving:Connect(function(descendant)
    if string.find(string.lower(descendant.Name), "bed") and not string.find(string.lower(descendant.Name), "bedroom") then
        showBedBreakAlert("팀 침대 파괴 감지! [침대 제거됨]")
    end
end)

print("[RAGON_01] 넉백제어, 낙사방지, Bed/Gen ESP, FPS 보스트 및 확대된 Item ESP 연동 완료!")
