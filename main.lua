local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- 디스코드 클립보드 복사
pcall(function()
    if setclipboard then
        setclipboard('https://discord.gg/VudXCDCaBN')
    end
end)

-- UI 컨테이너
local parentContainer = game:GetService("CoreGui")
if not pcall(function() local _ = parentContainer.Name end) then
    parentContainer = LocalPlayer:WaitForChild("PlayerGui")
end

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
frame.Size = UDim2.new(0, 320, 0, 380)
frame.Position = UDim2.new(0.03, 0, 0.15, 0)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

local frameStroke = Instance.new("UIStroke")
frameStroke.Color = Color3.fromRGB(220, 60, 60)
frameStroke.Thickness = 1.5
frameStroke.Parent = frame

-- 타이틀 Bar
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 34)
title.BackgroundTransparency = 1
title.Text = "RAGON_01 [Right Shift: UI 토글]"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 13
title.Font = Enum.Font.SourceSansBold
title.Parent = frame

-- [Right Shift] 토글
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.RightShift then
        frame.Visible = not frame.Visible
    end
end)

-- 탭 버튼 바
local tabBar = Instance.new("Frame")
tabBar.Name = "TabBar"
tabBar.Size = UDim2.new(1, -16, 0, 30)
tabBar.Position = UDim2.new(0, 8, 0, 34)
tabBar.BackgroundTransparency = 1
tabBar.Parent = frame

local tabLayout = Instance.new("UIListLayout")
tabLayout.Parent = tabBar
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Padding = UDim.new(0, 4)

-- 컨테이너 영역
local contentArea = Instance.new("Frame")
contentArea.Name = "ContentArea"
contentArea.Size = UDim2.new(1, -16, 1, -78)
contentArea.Position = UDim2.new(0, 8, 0, 70)
contentArea.BackgroundTransparency = 1
contentArea.Parent = frame

local tabs = {}
local categoryFrames = {}

local function createTab(tabName, iconText)
    local tabBtn = Instance.new("TextButton")
    tabBtn.Name = tabName .. "Tab"
    tabBtn.Size = UDim2.new(0.24, -2, 1, 0)
    tabBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 38)
    tabBtn.Text = iconText
    tabBtn.TextColor3 = Color3.fromRGB(170, 170, 170)
    tabBtn.TextSize = 12
    tabBtn.Font = Enum.Font.SourceSansBold
    tabBtn.Parent = tabBar

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = tabBtn

    local scroll = Instance.new("ScrollingFrame")
    scroll.Name = tabName .. "Frame"
    scroll.Size = UDim2.new(1, 0, 1, 0)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 4
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.Visible = false
    scroll.Parent = contentArea

    local scrollLayout = Instance.new("UIListLayout")
    scrollLayout.Parent = scroll
    scrollLayout.SortOrder = Enum.SortOrder.LayoutOrder
    scrollLayout.Padding = UDim.new(0, 6)

    scrollLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scroll.CanvasSize = UDim2.new(0, 0, 0, scrollLayout.AbsoluteContentSize.Y + 10)
    end)

    tabs[tabName] = tabBtn
    categoryFrames[tabName] = scroll

    return scroll
end

local function switchTab(selectedTab)
    for name, btn in pairs(tabs) do
        if name == selectedTab then
            btn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            categoryFrames[name].Visible = true
        else
            btn.BackgroundColor3 = Color3.fromRGB(32, 32, 38)
            btn.TextColor3 = Color3.fromRGB(170, 170, 170)
            categoryFrames[name].Visible = false
        end
    end
end

-- 4개 카테고리 탭 생성
local combatScroll = createTab("Combat", "⚔️ 전투")
local espScroll    = createTab("ESP", "👁️ ESP")
local utilScroll   = createTab("Utility", "🛠️ 유틸")
local optScroll    = createTab("Opt", "🚀 최적화")

for name, btn in pairs(tabs) do
    btn.MouseButton1Click:Connect(function() switchTab(name) end)
end

switchTab("Combat")

local function createButton(parentScroll, name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -6, 0, 34)
    btn.BackgroundColor3 = Color3.fromRGB(32, 32, 38)
    btn.Text = name .. " [OFF]"
    btn.TextColor3 = Color3.fromRGB(220, 220, 220)
    btn.TextSize = 13
    btn.Font = Enum.Font.SourceSansSemibold
    btn.Parent = parentScroll

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn

    local btnStroke = Instance.new("UIStroke")
    btnStroke.Color = Color3.fromRGB(48, 48, 56)
    btnStroke.Thickness = 1
    btnStroke.Parent = btn

    return btn
end

local function setBtnState(btn, active, name)
    btn.BackgroundColor3 = active and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(32, 32, 38)
    btn.TextColor3 = active and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(220, 220, 220)
    btn.Text = name .. " [" .. (active and "ON" or "OFF") .. "]"
end

-- 버튼 생성
local killauraBtn   = createButton(combatScroll, "KillAura (자동 공격)")
local aimbotBtn     = createButton(combatScroll, "Aimbot (RMB Hold)")
local autoWeaponBtn = createButton(combatScroll, "Auto Weapon Switch")
local reachBtn      = createButton(combatScroll, "Reach Multiplier (15 Studs)")

local espBtn        = createButton(espScroll, "Player ESP (하이라이트)")
local healthBtn     = createButton(espScroll, "Health ESP (체력 바)")
local itemEspBtn    = createButton(espScroll, "Item & Armor ESP (아이템/갑옷)")
local hitboxBtn     = createButton(espScroll, "Hitbox ESP (히트박스 확장)")
local bedGenBtn     = createButton(espScroll, "Bed & Gen ESP (침대/생성기)")

local scaffoldBtn   = createButton(utilScroll, "Scaffold (Auto Bridge)")
local bedNukerBtn   = createButton(utilScroll, "Bed Nuker (자동 침대 파괴)")
local antiKbBtn     = createButton(utilScroll, "Anti Knockback (넉백 무시)")
local noFallBtn     = createButton(utilScroll, "No Fall Damage (낙사 방지)")
local sprintBtn     = createButton(utilScroll, "Auto Sprint (자동 달리기)")
local spiderBtn     = createButton(utilScroll, "Spider (벽 타기)")

local fpsBoostBtn   = createButton(optScroll, "FPS Boost (렉제거 & 최적화)")

---------------------------------------------------------
-- 백엔드 헬퍼 로직
---------------------------------------------------------
local function isMyCharAlive()
    local char = LocalPlayer.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    return hum and hum.Health > 0 and hrp ~= nil
end

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

local function getBlockItem()
    local char = LocalPlayer.Character
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    local containers = {char, backpack}

    for _, container in ipairs(containers) do
        if container then
            for _, item in ipairs(container:GetChildren()) do
                if item:IsA("Tool") then
                    local name = string.lower(item.Name)
                    if string.find(name, "wool") or string.find(name, "block") or string.find(name, "wood") or string.find(name, "stone") then
                        return item
                    end
                end
            end
        end
    end
    return nil
end

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
        if string.find(name, "emerald") and (string.find(name, "helmet") or string.find(name, "chest") or string.find(name, "armor")) then detected = "에메갑"
        elseif string.find(name, "diamond") and (string.find(name, "helmet") or string.find(name, "chest") or string.find(name, "armor")) then detected = "다이아갑"
        elseif string.find(name, "iron") and (string.find(name, "helmet") or string.find(name, "chest") or string.find(name, "armor")) then detected = "철갑"
        elseif string.find(name, "leather") and (string.find(name, "helmet") or string.find(name, "chest") or string.find(name, "armor")) then detected = "가죽갑" end

        if detected and armorPriority[detected] > armorPriority[highestArmor] then highestArmor = detected end
    end
    return highestArmor
end

local function getResources(p)
    local iron, diamond, emerald = 0, 0, 0
    pcall(function()
        local invs = ReplicatedStorage:FindFirstChild("Inventories")
        if invs then
            local inv = invs:FindFirstChild(p.Name)
            if inv then
                for _, item in ipairs(inv:GetChildren()) do
                    local name = string.lower(item.Name)
                    local count = item:GetAttribute("Amount") or (item:FindFirstChild("Amount") and item.Amount.Value) or 1
                    if string.find(name, "iron") then iron = iron + count
                    elseif string.find(name, "diamond") then diamond = diamond + count
                    elseif string.find(name, "emerald") then emerald = emerald + count end
                end
            end
        end
    end)
    return iron, diamond, emerald
end

-- ========================================================
-- 1. Player ESP
-- ========================================================
local espActive = false
local function updateESP()
    for _, p in ipairs(Players:GetPlayers()) do
        local isEnemy = (p ~= LocalPlayer) and (not p.Team or not LocalPlayer.Team or p.Team ~= LocalPlayer.Team)
        if isEnemy and p.Character then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                if not p.Character:FindFirstChild("TestESP") then
                    local hl = Instance.new("Highlight")
                    hl.Name = "TestESP"
                    hl.Adornee = p.Character
                    hl.FillColor = Color3.fromRGB(255, 50, 50)
                    hl.FillTransparency = 0.5
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    hl.Parent = p.Character
                end
            else
                if p.Character:FindFirstChild("TestESP") then p.Character.TestESP:Destroy() end
            end
        end
    end
end

espBtn.MouseButton1Click:Connect(function()
    espActive = not espActive
    setBtnState(espBtn, espActive, "Player ESP (하이라이트)")
    if espActive then
        task.spawn(function()
            while espActive do updateESP() task.wait(0.3) end
        end)
    else
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("TestESP") then p.Character.TestESP:Destroy() end
        end
    end
end)

-- ========================================================
-- 2. Health ESP (슬림형 사이즈 축소)
-- ========================================================
local healthActive = false
local function removeHealthESP()
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp and hrp:FindFirstChild("HealthESP_Gui") then hrp.HealthESP_Gui:Destroy() end
        end
    end
end

local function updateHealthESP()
    for _, p in ipairs(Players:GetPlayers()) do
        local isEnemy = (p ~= LocalPlayer) and (not p.Team or not LocalPlayer.Team or p.Team ~= LocalPlayer.Team)
        if isEnemy and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health > 0 then
                local gui = hrp:FindFirstChild("HealthESP_Gui")
                if not gui then
                    gui = Instance.new("BillboardGui")
                    gui.Name = "HealthESP_Gui"
                    gui.Adornee = hrp
                    gui.Size = UDim2.new(0, 50, 0, 10) -- 컴팩트 사이즈
                    gui.ExtentsOffset = Vector3.new(0, 2.5, 0)
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

                    local txt = Instance.new("TextLabel")
                    txt.Name = "Txt"
                    txt.Size = UDim2.new(1, 0, 1, 0)
                    txt.BackgroundTransparency = 1
                    txt.TextColor3 = Color3.fromRGB(255, 255, 255)
                    txt.TextSize = 9
                    txt.Font = Enum.Font.SourceSansBold
                    txt.TextStrokeTransparency = 0
                    txt.Parent = bg
                end

                local fill = gui.BG:FindFirstChild("Fill")
                local txt = gui.BG:FindFirstChild("Txt")
                if fill and txt then
                    local pct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                    fill.Size = UDim2.new(pct, 0, 1, 0)
                    txt.Text = math.floor(hum.Health) .. " / " .. math.floor(hum.MaxHealth)
                    fill.BackgroundColor3 = pct > 0.5 and Color3.fromRGB(46, 204, 113) or (pct > 0.25 and Color3.fromRGB(241, 196, 15) or Color3.fromRGB(231, 76, 60))
                end
            else
                if hrp and hrp:FindFirstChild("HealthESP_Gui") then hrp.HealthESP_Gui:Destroy() end
            end
        end
    end
end

healthBtn.MouseButton1Click:Connect(function()
    healthActive = not healthActive
    setBtnState(healthBtn, healthActive, "Health ESP (체력 바)")
    if healthActive then
        task.spawn(function()
            while healthActive do updateHealthESP() task.wait(0.2) end
        end)
    else
        removeHealthESP()
    end
end)

-- ========================================================
-- 3. Item & Armor ESP (사이즈 축소 및 깔끔한 배치)
-- ========================================================
local itemEspActive = false
local function removeItemESP()
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then
            local head = p.Character:FindFirstChild("Head")
            if head and head:FindFirstChild("ItemESP_Gui") then head.ItemESP_Gui:Destroy() end
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
                    gui.Size = UDim2.new(0, 110, 0, 24) -- 대폭 축소된 크기
                    gui.ExtentsOffset = Vector3.new(0, 2.8, 0)
                    gui.AlwaysOnTop = true
                    gui.Parent = head

                    local txt = Instance.new("TextLabel")
                    txt.Name = "InfoLabel"
                    txt.Size = UDim2.new(1, 0, 1, 0)
                    txt.BackgroundTransparency = 1
                    txt.TextColor3 = Color3.fromRGB(255, 255, 255)
                    txt.TextSize = 10
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
                    label.Text = string.format("[%s|%s]\n⚪%d 🔷%d 🟩%d", weapon, armor, iron, dia, eme)
                end
            else
                if head and head:FindFirstChild("ItemESP_Gui") then head.ItemESP_Gui:Destroy() end
            end
        end
    end
end

itemEspBtn.MouseButton1Click:Connect(function()
    itemEspActive = not itemEspActive
    setBtnState(itemEspBtn, itemEspActive, "Item & Armor ESP (아이템/갑옷)")
    if itemEspActive then
        task.spawn(function()
            while itemEspActive do updateItemESP() task.wait(0.3) end
        end)
    else
        removeItemESP()
    end
end)

-- ========================================================
-- 4. Hitbox ESP
-- ========================================================
local hitboxActive = false
local HITBOX_SIZE = Vector3.new(6, 6, 6)

local function removeHitbox()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.Size = Vector3.new(2, 2, 1)
                hrp.Transparency = 1
                hrp.CanCollide = false
                if hrp:FindFirstChild("HitboxBox") then hrp.HitboxBox:Destroy() end
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
                hrp.Transparency = 0.8
                hrp.BrickColor = BrickColor.new("Really red")
                hrp.Material = Enum.Material.Neon
                hrp.CanCollide = false

                if not hrp:FindFirstChild("HitboxBox") then
                    local box = Instance.new("SelectionBox")
                    box.Name = "HitboxBox"
                    box.Adornee = hrp
                    box.Color3 = Color3.fromRGB(255, 60, 60)
                    box.LineThickness = 0.04
                    box.Parent = hrp
                end
            else
                if hrp then
                    hrp.Size = Vector3.new(2, 2, 1)
                    hrp.Transparency = 1
                    if hrp:FindFirstChild("HitboxBox") then hrp.HitboxBox:Destroy() end
                end
            end
        end
    end
end

hitboxBtn.MouseButton1Click:Connect(function()
    hitboxActive = not hitboxActive
    setBtnState(hitboxBtn, hitboxActive, "Hitbox ESP (히트박스 확장)")
    if hitboxActive then
        task.spawn(function()
            while hitboxActive do updateHitbox() task.wait(0.3) end
        end)
    else
        removeHitbox()
    end
end)

-- ========================================================
-- 5. Bed & Gen ESP (크기 축소)
-- ========================================================
local bedGenActive = false
local function removeBedGenESP()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:FindFirstChild("BedGen_ESP") then obj.BedGen_ESP:Destroy() end
    end
end

local function updateBedGenESP()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Model") then
            local name = string.lower(obj.Name)
            local espText, espColor = nil, nil

            if string.find(name, "bed") and not string.find(name, "bedroom") then
                espText = "🛏️ BED"
                espColor = Color3.fromRGB(255, 80, 80)
            elseif string.find(name, "diamond") and (string.find(name, "generator") or string.find(name, "gen")) then
                espText = "🔷 DIAMOND"
                espColor = Color3.fromRGB(0, 200, 255)
            elseif string.find(name, "emerald") and (string.find(name, "generator") or string.find(name, "gen")) then
                espText = "🟩 EMERALD"
                espColor = Color3.fromRGB(50, 255, 100)
            end

            if espText then
                local targetPart = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj
                if targetPart and not targetPart:FindFirstChild("BedGen_ESP") then
                    local bg = Instance.new("BillboardGui")
                    bg.Name = "BedGen_ESP"
                    bg.Adornee = targetPart
                    bg.Size = UDim2.new(0, 80, 0, 16) -- 컴팩트 사이즈
                    bg.AlwaysOnTop = true
                    bg.Parent = targetPart

                    local txt = Instance.new("TextLabel")
                    txt.Size = UDim2.new(1, 0, 1, 0)
                    txt.BackgroundTransparency = 1
                    txt.Text = espText
                    txt.TextColor3 = espColor
                    txt.TextSize = 11
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
    setBtnState(bedGenBtn, bedGenActive
