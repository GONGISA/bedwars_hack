-- Rayfield UI Library 불러오기
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Steal The Egg - RAGON Auto Hub",
    LoadingTitle = "RAGON Hub (Rayfield Ver.)",
    LoadingSubtitle = "By Assistant",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "StealTheEggRAGON",
        FileName = "Config"
    },
    Discord = { Enabled = false },
    KeySystem = false
})

-- 서비스
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- 설정값
local Config = {
    AutoSteal = false,
    TeleportToEgg = false,
    AutoReturnBase = false,
    FilterGoodEggs = true,
    Killaura = false,
    KillauraRange = 15,
    BedBreaker = false,
    BedRange = 20,
    GoodKeywords = {"Legendary", "Mythic", "Secret", "Gold", "Diamond", "Special", "전설", "신화", "보물"}
}

-- ------------------------------------------
-- 유틸리티 함수
-- ------------------------------------------

local function GetRoot()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function GetMyBasePosition()
    local bases = Workspace:FindFirstChild("Bases") or Workspace:FindFirstChild("Plots") or Workspace:FindFirstChild("Nests")
    if bases then
        for _, base in pairs(bases:GetChildren()) do
            local owner = base:FindFirstChild("Owner")
            if (owner and owner.Value == LocalPlayer) or base.Name:lower():find(LocalPlayer.Name:lower()) then
                return base:GetPivot().Position
            end
        end
    end
    return nil
end

local function IsGoodEgg(eggName)
    if not Config.FilterGoodEggs then return true end
    for _, keyword in pairs(Config.GoodKeywords) do
        if eggName:lower():find(keyword:lower()) then
            return true
        end
    end
    return false
end

local function StealEggRemote(eggObj)
    local prompt = eggObj:FindFirstChildOfClass("ProximityPrompt") or (eggObj.Parent and eggObj.Parent:FindFirstChildOfClass("ProximityPrompt"))
    if prompt and fireproximityprompt then
        fireproximityprompt(prompt)
    end
end

-- ------------------------------------------
-- UI 탭 설정
-- ------------------------------------------
local MainTab = Window:CreateTab("자동 알 수집", 4483345998)
local CombatTab = Window:CreateTab("전투 및 침대", 4483345998)
local FilterTab = Window:CreateTab("알 필터", 4483345998)

-- 알 수집 탭
MainTab:CreateToggle({
    Name = "자동 알 먹기 (Auto Steal)",
    CurrentValue = false,
    Flag = "AutoSteal",
    Callback = function(Value) Config.AutoSteal = Value end
})

MainTab:CreateToggle({
    Name = "알 위치로 순간이동 (TP to Egg)",
    CurrentValue = false,
    Flag = "TeleportToEgg",
    Callback = function(Value) Config.TeleportToEgg = Value end
})

MainTab:CreateToggle({
    Name = "알 먹은 후 내 기지로 복귀",
    CurrentValue = false,
    Flag = "AutoReturnBase",
    Callback = function(Value) Config.AutoReturnBase = Value end
})

local StatusLabel = MainTab:CreateLabel("상태: 대기 중...")

-- 전투 및 침대 탭
CombatTab:CreateToggle({
    Name = "킬아우라 (Killaura)",
    CurrentValue = false,
    Flag = "Killaura",
    Callback = function(Value) Config.Killaura = Value end
})

CombatTab:CreateSlider({
    Name = "킬아우라 사거리",
    Range = {5, 50},
    Increment = 1,
    Suffix = "Studs",
    CurrentValue = 15,
    Flag = "KillauraRange",
    Callback = function(Value) Config.KillauraRange = Value end
})

CombatTab:CreateToggle({
    Name = "침대 파괴기 (Bed Breaker)",
    CurrentValue = false,
    Flag = "BedBreaker",
    Callback = function(Value) Config.BedBreaker = Value end
})

CombatTab:CreateSlider({
    Name = "침대 파괴 사거리",
    Range = {5, 50},
    Increment = 1,
    Suffix = "Studs",
    CurrentValue = 20,
    Flag = "BedRange",
    Callback = function(Value) Config.BedRange = Value end
})

-- 필터 탭
FilterTab:CreateToggle({
    Name = "좋은 알만 골라 먹기 (필터링)",
    CurrentValue = true,
    Flag = "FilterGoodEggs",
    Callback = function(Value) Config.FilterGoodEggs = Value end
})

-- ------------------------------------------
-- 메인 동작 루프 (최적화 처리)
-- ------------------------------------------

-- 1. 알 수집 루프
task.spawn(function()
    while task.wait(0.25) do -- 탐색 주기를 조절하여 렉 대폭 감소
        if Config.AutoSteal then
            local root = GetRoot()
            if root then
                local foundEgg = nil
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj.Name:lower():find("egg") and IsGoodEgg(obj.Name) then
                        foundEgg = obj
                        break
                    end
                end

                if foundEgg then
                    local eggPart = foundEgg:IsA("BasePart") and foundEgg or foundEgg:FindFirstChildWhichIsA("BasePart")
                    if eggPart then
                        StatusLabel:Set("상태: [" .. foundEgg.Name .. "] 수집 시도 중!")
                        
                        if Config.TeleportToEgg then
                            root.CFrame = eggPart.CFrame * CFrame.new(0, 2, 0)
                            task.wait(0.05)
                        end
                        
                        StealEggRemote(foundEgg)
                        
                        if Config.AutoReturnBase then
                            local basePos = GetMyBasePosition()
                            if basePos then
                                task.wait(0.05)
                                root.CFrame = CFrame.new(basePos + Vector3.new(0, 3, 0))
                            end
                        end
                    end
                else
                    StatusLabel:Set("상태: 좋은 알 탐색 중...")
                end
            end
        end
    end
end)

-- 2. 킬아우라 (Killaura) 루프
task.spawn(function()
    while task.wait(0.1) do
        if Config.Killaura then
            local root = GetRoot()
            local char = LocalPlayer.Character
            if root and char then
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        local targetRoot = player.Character.HumanoidRootPart
                        local targetHum = player.Character:FindFirstChildOfClass("Humanoid")
                        
                        if targetHum and targetHum.Health > 0 then
                            local dist = (root.Position - targetRoot.Position).Magnitude
                            if dist <= Config.KillauraRange then
                                -- 도구 자동 착용 및 공격
                                local tool = char:FindFirstChildOfClass("Tool") or LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
                                if tool then
                                    if tool.Parent ~= char then
                                        char.Humanoid:EquipTool(tool)
                                    end
                                    tool:Activate()
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- 3. 침대 파괴기 (Bed Breaker) 루프
task.spawn(function()
    while task.wait(0.2) do
        if Config.BedBreaker then
            local root = GetRoot()
            if root then
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj.Name:lower():find("bed") then
                        local bedPart = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
                        if bedPart then
                            local dist = (root.Position - bedPart.Position).Magnitude
                            if dist <= Config.BedRange then
                                -- 상호작용 프롬프트 실행 또는 무기 공격
                                local prompt = obj:FindFirstChildOfClass("ProximityPrompt") or (obj.Parent and obj.Parent:FindFirstChildOfClass("ProximityPrompt"))
                                if prompt and fireproximityprompt then
                                    fireproximityprompt(prompt)
                                else
                                    local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
                                    if tool then tool:Activate() end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)
