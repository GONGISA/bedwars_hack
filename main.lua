local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local TextChatService = game:GetService("TextChatService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- 디스코드 클립보드 복사
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
frame.Size = UDim2.new(0, 340, 0, 420)
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
local optScroll    = createTab("Opt", "⚙️ 시스템")

for name, btn in pairs(tabs) do
    btn.MouseButton1Click:Connect(function() switchTab(name) end)
end

switchTab("Combat")

local featureStates = {}

local function createButton(parentScroll, keyName, displayName)
    featureStates[keyName] = false

    local btn = Instance.new("TextButton")
    btn.Name = keyName .. "Btn"
    btn.Size = UDim2.new(1, -6, 0, 34)
    btn.BackgroundColor3 = Color3.fromRGB(32, 32, 38)
    btn.Text = displayName .. " [OFF]"
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

local function setBtnState(btn, active, displayName)
    btn.BackgroundColor3 = active and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(32, 32, 38)
    btn.TextColor3 = active and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(220, 220, 220)
    btn.Text = displayName .. " [" .. (active and "ON" or "OFF") .. "]"
end

-- 전투 버튼
local killauraBtn   = createButton(combatScroll, "killaura", "KillAura (사거리 15 / 0.03초)")
local aimbotBtn     = createButton(combatScroll, "aimbot", "Bow Aimbot (낙사/이동예측)")
local autoclickBtn  = createButton(combatScroll, "autoclicker", "Auto Clicker (LMB 연타)")
local autoWeaponBtn = createButton(combatScroll, "autoweapon", "Auto Weapon Switch")
local reachBtn      = createButton(combatScroll, "reach", "Reach Multiplier (15 Studs)")

-- ESP 버튼
local espBtn        = createButton(espScroll, "playeresp", "Player ESP (하이라이트)")
local healthBtn     = createButton(espScroll, "healthesp", "Health ESP (체력 바)")
local itemEspBtn    = createButton(espScroll, "itemesp", "Item & Armor ESP (아이템/갑옷)")
local hitboxBtn     = createButton(espScroll, "hitbox", "Hitbox ESP (히트박스 확장)")
local bedGenBtn     = createButton(espScroll, "bedgenesp", "Bed & Gen ESP (침대/생성기)")

-- 유틸리티 버튼
local scaffoldBtn   = createButton(utilScroll, "scaffold", "Scaffold (Auto Bridge)")
local bedNukerBtn   = createButton(utilScroll, "bednuker", "Bed Nuker (자동 침대 파괴)")
local chestStealBtn = createButton(utilScroll, "cheststealer", "Chest Stealer (상자 자동 수거)")
local blinkBtn      = createButton(utilScroll, "blink", "Blink / Lag Switch (순간이동)")
local antiKbBtn     = createButton(utilScroll, "antikb", "Anti Knockback (넉백 무시)")
local noFallBtn     = createButton(utilScroll, "nofall", "No Fall Damage (낙사 방지)")
local sprintBtn     = createButton(utilScroll, "sprint", "Auto Sprint (자동 달리기)")
local spiderBtn     = createButton(utilScroll, "spider", "Spider (벽 타기)")

-- 시스템 & 최적화 버튼
local fpsBoostBtn   = createButton(optScroll, "fpsboost", "FPS Boost (렉제거 & 최적화)")
local staffDetBtn   = createButton(optScroll, "staffdetector", "Staff / Mod Detector (관리자 감지)")
local autoToxicBtn  = createButton(optScroll, "autotoxic", "Auto Toxic (자동 채팅 도발)")

-- 설정 저장 / 불러오기 전용 버튼 (Toggle 형태가 아닌 Action 버튼)
local saveConfigBtn = Instance.new("TextButton")
saveConfigBtn.Size = UDim2.new(1, -6, 0, 34)
saveConfigBtn.BackgroundColor3 = Color3.fromRGB(52, 152, 219)
saveConfigBtn.Text = "💾 설정 저장하기 (Save Config)"
saveConfigBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
saveConfigBtn.TextSize = 13
saveConfigBtn.Font = Enum.Font.SourceSansBold
saveConfigBtn.Parent = optScroll
local scCorner = Instance.new("UICorner") scCorner.CornerRadius = UDim.new(0, 6) scCorner.Parent = saveConfigBtn

local loadConfigBtn = Instance.new("TextButton")
loadConfigBtn.Size = UDim2.new(1, -6, 0, 34)
loadConfigBtn.BackgroundColor3 = Color3.fromRGB(155, 89, 182)
loadConfigBtn.Text = "📂 설정 불러오기 (Load Config)"
loadConfigBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
loadConfigBtn.TextSize = 13
loadConfigBtn.Font = Enum.Font.SourceSansBold
loadConfigBtn.Parent = optScroll
local lcCorner = Instance.new("UICorner") lcCorner.CornerRadius = UDim.new(0, 6) lcCorner.Parent = loadConfigBtn

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

local function sendChatMessage(msg)
    pcall(function()
        if TextChatService and TextChatService.ChatInputBarConfiguration then
            local channel = TextChatService.TextChannels.RBXGeneral
            if channel then channel:SendAsync(msg) end
        else
            ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(msg, "All")
        end
    end)
end

local function getBestSword()
    local char = LocalPlayer.Character
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    local bestSword = nil
    local bestPriority = 0
    local swordPriority = { ["emerald_sword"] = 5, ["diamond_sword"] = 4, ["iron_sword"] = 3, ["stone_sword"] = 2, ["wood_sword"] = 1 }

    for _, container in ipairs({char, backpack}) do
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
    for _, container in ipairs({LocalPlayer.Character, LocalPlayer:FindFirstChild("Backpack")}) do
        if container then
            for _, item in ipairs(container:GetChildren()) do
                if item:IsA("Tool") and (string.find(string.lower(item.Name), "wool") or string.find(string.lower(item.Name), "block")) then
                    return item
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
    featureStates.playeresp = not featureStates.playeresp
    setBtnState(espBtn, featureStates.playeresp, "Player ESP (하이라이트)")
    if featureStates.playeresp then
        task.spawn(function()
            while featureStates.playeresp do updateESP() task.wait(0.3) end
        end)
    else
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("TestESP") then p.Character.TestESP:Destroy() end
        end
    end
end)

-- ========================================================
-- 2. Health ESP
-- ========================================================
local function removeHealthESP()
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character.HumanoidRootPart:FindFirstChild("HealthESP_Gui") then
            p.Character.HumanoidRootPart.HealthESP_Gui:Destroy()
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
                    gui.Size = UDim2.new(0, 50, 0, 10)
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
    featureStates.healthesp = not featureStates.healthesp
    setBtnState(healthBtn, featureStates.healthesp, "Health ESP (체력 바)")
    if featureStates.healthesp then
        task.spawn(function()
            while featureStates.healthesp do updateHealthESP() task.wait(0.2) end
        end)
    else
        removeHealthESP()
    end
end)

-- ========================================================
-- 3. Item & Armor ESP
-- ========================================================
local function removeItemESP()
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character and p.Character:FindFirstChild("Head") and p.Character.Head:FindFirstChild("ItemESP_Gui") then
            p.Character.Head.ItemESP_Gui:Destroy()
        end
    end
end

local function updateItemESP()
    for _, p in ipairs(Players:GetPlayers()) do
        local isEnemy = (p ~= LocalPlayer) and (not p.Team or not LocalPlayer.Team or p.Team ~= LocalPlayer.Team)
        if isEnemy and p.Character then
            local head = p.Character:FindFirstChild("Head")
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if head and hum and hum.Health > 0 then
                local gui = head:FindFirstChild("ItemESP_Gui")
                if not gui then
                    gui = Instance.new("BillboardGui")
                    gui.Name = "ItemESP_Gui"
                    gui.Adornee = head
                    gui.Size = UDim2.new(0, 110, 0, 24)
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
    featureStates.itemesp = not featureStates.itemesp
    setBtnState(itemEspBtn, featureStates.itemesp, "Item & Armor ESP (아이템/갑옷)")
    if featureStates.itemesp then
        task.spawn(function()
            while featureStates.itemesp do updateItemESP() task.wait(0.3) end
        end)
    else
        removeItemESP()
    end
end)

-- ========================================================
-- 4. Hitbox ESP
-- ========================================================
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
                hrp.Size = Vector3.new(6, 6, 6)
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
    featureStates.hitbox = not featureStates.hitbox
    setBtnState(hitboxBtn, featureStates.hitbox, "Hitbox ESP (히트박스 확장)")
    if featureStates.hitbox then
        task.spawn(function()
            while featureStates.hitbox do updateHitbox() task.wait(0.3) end
        end)
    else
        removeHitbox()
    end
end)

-- ========================================================
-- 5. Bed & Gen ESP
-- ========================================================
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
                    bg.Size = UDim2.new(0, 80, 0, 16)
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
    featureStates.bedgenesp = not featureStates.bedgenesp
    setBtnState(bedGenBtn, featureStates.bedgenesp, "Bed & Gen ESP (침대/생성기)")
    if featureStates.bedgenesp then
        task.spawn(function()
            while featureStates.bedgenesp do updateBedGenESP() task.wait(2.0) end
        end)
    else
        removeBedGenESP()
    end
end)

-- ========================================================
-- 6. Scaffold
-- ========================================================
local scaffoldConn = nil
scaffoldBtn.MouseButton1Click:Connect(function()
    featureStates.scaffold = not featureStates.scaffold
    setBtnState(scaffoldBtn, featureStates.scaffold, "Scaffold (Auto Bridge)")
    if featureStates.scaffold then
        scaffoldConn = RunService.Heartbeat:Connect(function()
            if isMyCharAlive() then
                local hrp = LocalPlayer.Character.HumanoidRootPart
                local underPos = hrp.Position - Vector3.new(0, 3.5, 0)
                local ray = workspace:Raycast(hrp.Position, Vector3.new(0, -4, 0))
                if not ray then
                    local blockItem = getBlockItem()
                    if blockItem then
                        pcall(function()
                            local netManaged = ReplicatedStorage:FindFirstChild("rbxts_include")
                            if netManaged then
                                local placeNet = netManaged.node_modules["@rbxts"].net.out._NetManaged:FindFirstChild("PlaceBlock")
                                if placeNet then
                                    local gridPos = Vector3.new(math.floor(underPos.X / 3), math.floor(underPos.Y / 3), math.floor(underPos.Z / 3))
                                    placeNet:FireServer({
                                        ["position"] = gridPos,
                                        ["blockType"] = blockItem.Name
                                    })
                                end
                            end
                        end)
                    end
                end
            end
        end)
    else
        if scaffoldConn then scaffoldConn:Disconnect() scaffoldConn = nil end
    end
end)

-- ========================================================
-- 7. Bed Nuker
-- ========================================================
bedNukerBtn.MouseButton1Click:Connect(function()
    featureStates.bednuker = not featureStates.bednuker
    setBtnState(bedNukerBtn, featureStates.bednuker, "Bed Nuker (자동 침대 파괴)")
    if featureStates.bednuker then
        task.spawn(function()
            while featureStates.bednuker do
                if isMyCharAlive() then
                    pcall(function()
                        local myPos = LocalPlayer.Character.HumanoidRootPart.Position
                        for _, obj in ipairs(workspace:GetDescendants()) do
                            if obj:IsA("BasePart") and string.find(string.lower(obj.Name), "bed") and not string.find(string.lower(obj.Name), "bedroom") then
                                if (obj.Position - myPos).Magnitude <= 16 then
                                    local netManaged = ReplicatedStorage:FindFirstChild("rbxts_include")
                                    if netManaged then
                                        local damageNet = netManaged.node_modules["@rbxts"].net.out._NetManaged:FindFirstChild("DamageBlock")
                                        if damageNet then
                                            local blockPos = Vector3.new(math.floor(obj.Position.X/3), math.floor(obj.Position.Y/3), math.floor(obj.Position.Z/3))
                                            damageNet:InvokeServer({
                                                ["blockRef"] = { ["blockPosition"] = blockPos },
                                                ["hitPosition"] = obj.Position,
                                                ["hitNormal"] = Vector3.new(0, 1, 0)
                                            })
                                        end
                                    end
                                end
                            end
                        end
                    end)
                end
                task.wait(0.1)
            end
        end)
    end
end)

-- ========================================================
-- 8. Chest Stealer [신규]
-- ========================================================
chestStealBtn.MouseButton1Click:Connect(function()
    featureStates.cheststealer = not featureStates.cheststealer
    setBtnState(chestStealBtn, featureStates.cheststealer, "Chest Stealer (상자 자동 수거)")
    if featureStates.cheststealer then
        task.spawn(function()
            while featureStates.cheststealer do
                if isMyCharAlive() then
                    pcall(function()
                        local myPos = LocalPlayer.Character.HumanoidRootPart.Position
                        for _, chest in ipairs(workspace:GetDescendants()) do
                            if chest:IsA("Model") and string.find(string.lower(chest.Name), "chest") then
                                local primary = chest.PrimaryPart or chest:FindFirstChildWhichIsA("BasePart")
                                if primary and (primary.Position - myPos).Magnitude <= 15 then
                                    local netManaged = ReplicatedStorage:FindFirstChild("rbxts_include")
                                    if netManaged then
                                        local chestGetNet = netManaged.node_modules["@rbxts"].net.out._NetManaged:FindFirstChild("ChestGetItem")
                                        if chestGetNet then
                                            chestGetNet:InvokeServer(chest)
                                        end
                                    end
                                end
                            end
                        end
                    end)
                end
                task.wait(0.15)
            end
        end)
    end
end)

-- ========================================================
-- 9. Blink / Lag Switch [신규]
-- ========================================================
local blinkClone = nil
blinkBtn.MouseButton1Click:Connect(function()
    featureStates.blink = not featureStates.blink
    setBtnState(blinkBtn, featureStates.blink, "Blink / Lag Switch (순간이동)")
    if featureStates.blink then
        if isMyCharAlive() then
            local char = LocalPlayer.Character
            char.Archivable = true
            blinkClone = char:Clone()
            blinkClone.Parent = workspace
            for _, v in ipairs(blinkClone:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.Transparency = 0.5
                    v.CanCollide = false
                end
            end
            char.HumanoidRootPart.Anchored = true
        end
    else
        if isMyCharAlive() then
            LocalPlayer.Character.HumanoidRootPart.Anchored = false
            if blinkClone then blinkClone:Destroy() blinkClone = nil end
        end
    end
end)

-- ========================================================
-- 10. Auto Weapon Switch
-- ========================================================
local autoWeaponConn = nil
autoWeaponBtn.MouseButton1Click:Connect(function()
    featureStates.autoweapon = not featureStates.autoweapon
    setBtnState(autoWeaponBtn, featureStates.autoweapon, "Auto Weapon Switch")
    if featureStates.autoweapon then
        autoWeaponConn = RunService.RenderStepped:Connect(function()
            if isMyCharAlive() then
                local myPos = LocalPlayer.Character.HumanoidRootPart.Position
                local enemyNear = false
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and (not p.Team or not LocalPlayer.Team or p.Team ~= LocalPlayer.Team) then
                        if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                            if (p.Character.HumanoidRootPart.Position - myPos).Magnitude <= 18 then enemyNear = true break end
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
-- 11. Reach Multiplier & KillAura (사거리 15, 공속 0.03)
-- ========================================================
reachBtn.MouseButton1Click:Connect(function()
    featureStates.reach = not featureStates.reach
    setBtnState(reachBtn, featureStates.reach, "Reach Multiplier (15 Studs)")
end)

killauraBtn.MouseButton1Click:Connect(function()
    featureStates.killaura = not featureStates.killaura
    setBtnState(killauraBtn, featureStates.killaura, "KillAura (사거리 15 / 0.03초)")
    if featureStates.killaura then
        task.spawn(function()
            while featureStates.killaura do
                if isMyCharAlive() then
                    local currentReach = 15
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
                task.wait(0.03)
            end
        end)
    end
end)

-- ========================================================
-- 12. Bow Aimbot (활 낙차 / 이동 속도 예측 [개선])
-- ========================================================
local aimbotConn = nil
aimbotBtn.MouseButton1Click:Connect(function()
    featureStates.aimbot = not featureStates.aimbot
    setBtnState(aimbotBtn, featureStates.aimbot, "Bow Aimbot (낙사/이동예측)")
    if featureStates.aimbot then
        aimbotConn = RunService.RenderStepped:Connect(function()
            local rmbPressed = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
            if rmbPressed and isMyCharAlive() then
                local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                if tool and (string.find(string.lower(tool.Name), "bow") or string.find(string.lower(tool.Name), "crossbow")) then
                    local closestHead = nil
                    local shortestDist = math.huge
                    local targetVel = Vector3.zero

                    for _, p in ipairs(Players:GetPlayers()) do
                        if p ~= LocalPlayer and (not p.Team or not LocalPlayer.Team or p.Team ~= LocalPlayer.Team) then
                            if p.Character and p.Character:FindFirstChild("Head") and p.Character:FindFirstChild("HumanoidRootPart") then
                                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                                if hum and hum.Health > 0 then
                                    local dist = (LocalPlayer.Character.HumanoidRootPart.Position - p.Character.Head.Position).Magnitude
                                    if dist < shortestDist then
                                        shortestDist = dist
                                        closestHead = p.Character.Head
                                        targetVel = p.Character.HumanoidRootPart.AssemblyLinearVelocity
                                    end
                                end
                            end
                        end
                    end

                    if closestHead then
                        local arrowSpeed = 220 -- 화살의 속도
                        local travelTime = shortestDist / arrowSpeed
                        local dropCompensation = (shortestDist ^ 2) * 0.00018 -- 화살 낙차 보정
                        local predictedPosition = closestHead.Position + (targetVel * travelTime) + Vector3.new(0, dropCompensation, 0)
                        
                        Camera.CFrame = CFrame.new(Camera.CFrame.Position, predictedPosition)
                    end
                end
            end
        end)
    else
        if aimbotConn then aimbotConn:Disconnect() aimbotConn = nil end
    end
end)

-- ========================================================
-- 13. Auto Clicker [신규]
-- ========================================================
autoclickBtn.MouseButton1Click:Connect(function()
    featureStates.autoclicker = not featureStates.autoclicker
    setBtnState(autoclickBtn, featureStates.autoclicker, "Auto Clicker (LMB 연타)")
    if featureStates.autoclicker then
        task.spawn(function()
            while featureStates.autoclicker do
                if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                    pcall(function()
                        if mouse1click then mouse1click() end
                    end)
                end
                task.wait(0.02)
            end
        end)
    end
end)

-- ========================================================
-- 14. 이동 및 보조 유틸리티
-- ========================================================
local antiKbConn = nil
antiKbBtn.MouseButton1Click:Connect(function()
    featureStates.antikb = not featureStates.antikb
    setBtnState(antiKbBtn, featureStates.antikb, "Anti Knockback (넉백 무시)")
    if featureStates.antikb then
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

local noFallConn = nil
noFallBtn.MouseButton1Click:Connect(function()
    featureStates.nofall = not featureStates.nofall
    setBtnState(noFallBtn, featureStates.nofall, "No Fall Damage (낙사 방지)")
    if featureStates.nofall then
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

local sprintConn = nil
sprintBtn.MouseButton1Click:Connect(function()
    featureStates.sprint = not featureStates.sprint
    setBtnState(sprintBtn, featureStates.sprint, "Auto Sprint (자동 달리기)")
    if featureStates.sprint then
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

local spiderConn = nil
spiderBtn.MouseButton1Click:Connect(function()
    featureStates.spider = not featureStates.spider
    setBtnState(spiderBtn, featureStates.spider, "Spider (벽 타기)")
    if featureStates.spider then
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

-- ========================================================
-- 15. Staff / Mod Detector [신규]
-- ========================================================
staffDetBtn.MouseButton1Click:Connect(function()
    featureStates.staffdetector = not featureStates.staffdetector
    setBtnState(staffDetBtn, featureStates.staffdetector, "Staff / Mod Detector (관리자 감지)")
    if featureStates.staffdetector then
        task.spawn(function()
            while featureStates.staffdetector do
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer then
                        pcall(function()
                            local rank = p:GetRankInGroup(5774217) -- BedWars 디폴트 그룹 ID
                            if rank >= 100 then
                                title.Text = "🚨 경고: 관리자 " .. p.Name .. " 접속 감지!"
                                title.TextColor3 = Color3.fromRGB(255, 0, 0)
                            end
                        end)
                    end
                end
                task.wait(5.0)
            end
        end)
    end
end)

-- ========================================================
-- 16. Auto Toxic [신규]
-- ========================================================
autoToxicBtn.MouseButton1Click:Connect(function()
    featureStates.autotoxic = not featureStates.autotoxic
    setBtnState(autoToxicBtn, featureStates.autotoxic, "Auto Toxic (자동 채팅 도발)")
    if featureStates.autotoxic then
        sendChatMessage("RAGON_01 SCRIPT LOADED | EZ MATCH")
    end
end)

-- ========================================================
-- 17. 최적화 & 설정 저장 / 불러오기 [신규]
-- ========================================================
fpsBoostBtn.MouseButton1Click:Connect(function()
    featureStates.fpsboost = not featureStates.fpsboost
    setBtnState(fpsBoostBtn, featureStates.fpsboost, "FPS Boost (렉제거 & 최적화)")
    if featureStates.fpsboost then
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

-- Config Save Logic
saveConfigBtn.MouseButton1Click:Connect(function()
    pcall(function()
        if writefile then
            local json = HttpService:JSONEncode(featureStates)
            writefile("RAGON_01_Config.json", json)
            saveConfigBtn.Text = "✅ 저장 완료!"
            task.wait(1.5)
            saveConfigBtn.Text = "💾 설정 저장하기 (Save Config)"
        end
    end)
end)

-- Config Load Logic
loadConfigBtn.MouseButton1Click:Connect(function()
    pcall(function()
        if readfile and isfile and isfile("RAGON_01_Config.json") then
            local data = HttpService:JSONDecode(readfile("RAGON_01_Config.json"))
            for key, val in pairs(data) do
                if featureStates[key] ~= nil and featureStates[key] ~= val then
                    local btnName = key .. "Btn"
                    local btnObj = screenGui:FindFirstChild(btnName, true)
                    if btnObj and btnObj:IsA("TextButton") then
                        btnObj:MouseButton1Click()
                    end
                end
            end
            loadConfigBtn.Text = "✅ 불러오기 완료!"
            task.wait(1.5)
            loadConfigBtn.Text = "📂 설정 불러오기 (Load Config)"
        end
    end)
end)

print("[RAGON_01_V2] 요청하신 7가지 신규 기능 탑재 패치 완료!")
