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

-- 메인 프레임 (PC 전용)
local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = UDim2.new(0, 240, 0, 430)
frame.Position = UDim2.new(0.03, 0, 0.15, 0)
frame.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
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

-- 타이틀
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 38)
title.BackgroundTransparency = 1
title.Text = "RAGON_01 [PC ONLY]"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 15
title.Font = Enum.Font.SourceSansBold
title.Parent = frame

-- [Right Shift] 키로 메뉴 토글 기능
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.RightShift then
        frame.Visible = not frame.Visible
    end
end)

-- 스크롤 영역
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -12, 1, -48)
scrollFrame.Position = UDim2.new(0, 6, 0, 42)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 5
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 610)
scrollFrame.Parent = frame

local listLayout = Instance.new("UIListLayout")
listLayout.Parent = scrollFrame
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 5)

local layoutOrder = 0
local function createButton(name)
    layoutOrder = layoutOrder + 1
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -8, 0, 32)
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

-- 버튼 생성
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
local aimbotBtn     = createButton("Aimbot (RMB Hold)")
local fpsBoostBtn   = createButton("FPS Boost (렉제거)")

-- 캐릭터 생존 판별
local function isMyCharAlive()
    local char = LocalPlayer.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    return hum and hum.Health > 0 and hrp ~= nil
end

-- 최고 등급 검 검색
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

-- 무기 정보 감지
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

-- 갑옷 정보 감지
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

-- 인벤토리 자원 감지
local function getResources(p)
    local iron, diamond, emerald = 0, 0, 0
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
    return iron, diamond, emerald
end

-- ========================================================
-- 1. 🟥 Highlight ESP (수정완료)
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

-- ========================================================
-- 2. 🟢 Health ESP (수정완료)
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
                    gui.Size = UDim2.new(0, 65, 0, 16)
                    gui.ExtentsOffset = Vector3.new(0, 3, 0)
                    gui.AlwaysOnTop = true
                    gui.Parent = hrp

                    local bg = Instance.new("Frame")
                    bg.Name = "BG"
                    bg.Size = UDim2.new(1, 0, 1, 0)
                    bg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
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
                    txt.TextSize = 11
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
    healthBtn.BackgroundColor3 = healthActive and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(220, 60, 60)
    healthBtn.Text = "Health ESP [" .. (healthActive and "ON" or "OFF") .. "]"
    if healthActive then
        task.spawn(function()
            while healthActive do updateHealthESP() task.wait(0.1) end
        end)
    else
        removeHealthESP()
    end
end)

-- ========================================================
-- 3. 🔍 Item & Armor ESP (크기 대폭확원 / 수정완료)
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
                    gui.Size = UDim2.new(0, 280, 0, 60)
                    gui.ExtentsOffset = Vector3.new(0, 3.8, 0)
                    gui.AlwaysOnTop = true
                    gui.Parent = head

                    local txt = Instance.new("TextLabel")
                    txt.Name = "InfoLabel"
                    txt.Size = UDim2.new(1, 0, 1, 0)
                    txt.BackgroundTransparency = 1
                    txt.TextColor3 = Color3.fromRGB(255, 255, 255)
                    txt.TextSize = 16
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
                if head and head:FindFirstChild("ItemESP_Gui") then head.ItemESP_Gui:Destroy() end
            end
        end
    end
end

itemEspBtn.MouseButton1Click:Connect(function()
    itemEspActive = not itemEspActive
    itemEspBtn.BackgroundColor3 = itemEspActive and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(220, 60, 60)
    itemEspBtn.Text = "Item ESP [" .. (itemEspActive and "ON" or "OFF") .. "]"
    if itemEspActive then
        task.spawn(function()
            while itemEspActive do updateItemESP() task.wait(0.2) end
        end)
    else
        removeItemESP()
    end
end)

-- ========================================================
-- 4. 📦 Hitbox ESP (수정완료)
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
                    if hrp:FindFirstChild("HitboxBox") then hrp.HitboxBox:Destroy() end
                end
            end
        end
    end
end

hitboxBtn.MouseButton1Click:Connect(function()
    hitboxActive = not hitboxActive
    hitboxBtn.BackgroundColor3 = hitboxActive and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(220, 60, 60)
    hitboxBtn.Text = "Hitbox ESP [" .. (hitboxActive and "ON" or "OFF") .. "]"
    if hitboxActive then
        task.spawn(function()
            while hitboxActive do updateHitbox() task.wait(0.2) end
        end)
    else
        removeHitbox()
    end
end)

-- ========================================================
-- 5. 🛏️ Bed & Generator ESP (수정완료)
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
    bedGenBtn.BackgroundColor3 = bedGenActive and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(220, 60, 60)
    bedGenBtn.Text = "Bed & Gen ESP [" .. (bedGenActive and "ON" or "OFF") .. "]"
    if bedGenActive then
        task.spawn(function()
            while bedGenActive do updateBedGenESP() task.wait(2.0) end
        end)
    else
        removeBedGenESP()
    end
end)

-- ========================================================
-- 6. 🧱 Scaffold (Auto Bridge)
-- ========================================================
local scaffoldActive, scaffoldConn = false, nil
scaffoldBtn.MouseButton1Click:Connect(function()
    scaffoldActive = not scaffoldActive
    scaffoldBtn.BackgroundColor3 = scaffoldActive and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(220, 60, 60)
    scaffoldBtn.Text = "Scaffold [" .. (scaffoldActive and "ON" or "OFF") .. "]"

    if scaffoldActive then
        scaffoldConn = RunService.Heartbeat:Connect(function()
            if isMyCharAlive() then
                local hrp = LocalPlayer.Character.HumanoidRootPart
                local underPos = hrp.Position - Vector3.new(0, 3.5, 0)
                if not workspace:Raycast(hrp.Position, Vector3.new(0, -4, 0)) then
                    local wool = nil
                    for _, item in ipairs(LocalPlayer.Character:GetChildren()) do
                        if item:IsA("Tool") and string.find(string.lower(item.Name), "wool") then wool = item break end
                    end
                    if wool then
                        local placeNet = ReplicatedStorage:FindFirstChild("rbxts_include")
                        if placeNet then
                            placeNet = placeNet.node_modules["@rbxts"].net.out._NetManaged:FindFirstChild("PlaceBlock")
                            if placeNet then
                                placeNet:FireServer({
                                    ["position"] = Vector3.new(math.floor(underPos.X / 3) * 3, math.floor(underPos.Y / 3) * 3, math.floor(underPos.Z / 3) * 3),
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
-- 7. 💣 Bed Nuker (자동 침대 파괴)
-- ========================================================
local bedNukerActive = false
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
                            if (obj.Position - myPos).Magnitude <= 16 then
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
-- 8. ⚔️ Auto Weapon Switch
-- ========================================================
local autoWeaponActive, autoWeaponConn = false, nil
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
-- 9. 📏 Reach Multiplier & KillAura
-- ========================================================
local reachActive = false
reachBtn.MouseButton1Click:Connect(function()
    reachActive = not reachActive
    reachBtn.BackgroundColor3 = reachActive and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(220, 60, 60)
    reachBtn.Text = "Reach Multiplier [" .. (reachActive and "ON" or "OFF") .. "]"
end)

local killauraActive = false
killauraBtn.MouseButton1Click:Connect(function()
    killauraActive = not killauraActive
    killauraBtn.BackgroundColor3 = killauraActive and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(220, 60, 60)
    killauraBtn.Text = "KillAura [" .. (killauraActive and "ON" or "OFF") .. "]"

    if killauraActive then
        task.spawn(function()
            while killauraActive do
                if isMyCharAlive() then
                    local currentReach = reachActive and 21 or 14
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
-- 10. 이동/낙사방지/스프린트/스파이더
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

-- ================================================= realm: PC Aimbot (마우스 우클릭 연동)
local aimbotActive, aimbotConn = false, nil
aimbotBtn.MouseButton1Click:Connect(function()
    aimbotActive = not aimbotActive
    aimbotBtn.BackgroundColor3 = aimbotActive and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(220, 60, 60)
    aimbotBtn.Text = "Aimbot [" .. (aimbotActive and "ON" or "OFF") .. "]"

    if aimbotActive then
        aimbotConn = RunService.RenderStepped:Connect(function()
            local rmbPressed = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
            if rmbPressed and isMyCharAlive() then
                local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                if tool and (string.find(string.lower(tool.Name), "bow") or string.find(string.lower(tool.Name), "crossbow")) then
                    local closestHead = nil
                    local shortestDist = math.huge
                    for _, p in ipairs(Players:GetPlayers()) do
                        if p ~= LocalPlayer and (not p.Team or not LocalPlayer.Team or p.Team ~= LocalPlayer.Team) then
                            if p.Character and p.Character:FindFirstChild("Head") then
                                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                                if hum and hum.Health > 0 then
                                    local dist = (LocalPlayer.Character.HumanoidRootPart.Position - p.Character.Head.Position).Magnitude
                                    if dist < shortestDist then shortestDist = dist closestHead = p.Character.Head end
                                end
                            end
                        end
                    end
                    if closestHead then
                        Camera.CFrame = CFrame.new(Camera.CFrame.Position, closestHead.Position + Vector3.new(0, shortestDist*0.08, 0))
                    end
                end
            end
        end)
    else
        if aimbotConn then aimbotConn:Disconnect() aimbotConn = nil end
    end
end)

-- ========================================================
-- 11. 🚀 FPS Boost (렉제거)
-- ========================================================
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

print("[RAGON_01_PC_FINAL] Health, Item, Hitbox ESP 완벽 복구 및 PC 패치 완료! (Right Shift 키로 메뉴 토글 가능)")
