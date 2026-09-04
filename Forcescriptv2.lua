if _G.FORCEHUBRunning then return end
_G.FORCEHUBRunning = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local HS = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LP = Players.LocalPlayer
local camera = workspace.CurrentCamera
local ContentProvider = game:GetService("ContentProvider")

-- ============================================================
-- FUNCIONES DE ARCHIVO ROBUSTAS (tomadas de Ace Duels)
-- ============================================================
local CONFIG_FILE = "FORCEHUB_Config.json"
local KEYBINDS_FILE = "FORCEHUB_Keybinds.json"

local _ace_isfile = isfile or (syn and syn.isfile) or function(path)
    local ok, result = pcall(function() return readfile(path) end)
    return ok and result ~= nil
end
local _ace_readfile = readfile or (syn and syn.readfile)
local _ace_writefile = writefile or (syn and syn.writefile)
local canSaveConfig = (type(_ace_readfile) == "function" and type(_ace_writefile) == "function")

-- ============================================================
-- INTRO (se ejecuta antes que cualquier otra cosa)
-- ============================================================
local function runIntro()
    local Images = {
        "rbxassetid://96533744445232",
        "rbxassetid://118993542874276",
        "rbxassetid://99866892158060",
        "rbxassetid://84540124030580",
        "rbxassetid://132934292097292",
        "rbxassetid://104010736352149",
        "rbxassetid://94361033271077",
        "rbxassetid://72190372137981",
        "rbxassetid://103523696318850",
        "rbxassetid://101803539971689",
        "rbxassetid://107529606059299",
        "rbxassetid://130784948902307",
        "rbxassetid://114784420279972",
        "rbxassetid://105123015099972",
        "rbxassetid://131596264264581",
        "rbxassetid://117641319299892",
        "rbxassetid://77534392596501",
        "rbxassetid://137414609886581",
        "rbxassetid://83131507934505",
        "rbxassetid://120539267437814",
        "rbxassetid://75439074806720",
        "rbxassetid://115488810796302",
        "rbxassetid://112728809681073",
        "rbxassetid://134318680085983",
        "rbxassetid://123066810237014",
        "rbxassetid://102121135737318",
        "rbxassetid://139699026047974",
        "rbxassetid://74182313853112",
        "rbxassetid://121416642632033",
        "rbxassetid://134801197105164",
        "rbxassetid://93349115381247",
        "rbxassetid://128713300077569",
        "rbxassetid://105980529035481",
        "rbxassetid://120098855834318",
        "rbxassetid://78738310303690",
        "rbxassetid://120357336501453",
        "rbxassetid://118779397888922",
        "rbxassetid://132769993677180",
        "rbxassetid://104815503921105",
        "rbxassetid://77088103549177",
        "rbxassetid://72670821879917",
        "rbxassetid://70849955940425",
        "rbxassetid://108744596090889",
        "rbxassetid://76080560700977",
        "rbxassetid://78134833803844",
        "rbxassetid://88784536566963",
        "rbxassetid://98157171075972",
        "rbxassetid://110334342917414",
        "rbxassetid://97359534131775",
        "rbxassetid://72958519562189",
        "rbxassetid://92480523122234",
        "rbxassetid://117453595633818"
    }

    local FPS = 30
    local LOOP = true
    local skipRequested = false

    local assets = {}
    for _, id in ipairs(Images) do
        table.insert(assets, id)
    end
    ContentProvider:PreloadAsync(assets)
    task.wait(0.2)

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "forcehub intro"
    screenGui.Parent = LP:FindFirstChild("PlayerGui") or LP:WaitForChild("PlayerGui")
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = Color3.new(0, 0, 0)
    frame.BackgroundTransparency = 0
    frame.Parent = screenGui

    local layer1 = Instance.new("ImageLabel")
    layer1.Size = UDim2.new(1, 0, 1, 0)
    layer1.BackgroundTransparency = 1
    layer1.ScaleType = Enum.ScaleType.Crop
    layer1.ZIndex = 2
    layer1.Parent = frame

    local layer2 = Instance.new("ImageLabel")
    layer2.Size = UDim2.new(1, 0, 1, 0)
    layer2.BackgroundTransparency = 1
    layer2.ScaleType = Enum.ScaleType.Crop
    layer2.ZIndex = 1
    layer2.Parent = frame

    layer1.Image = Images[1]
    layer2.Image = Images[1]

    local continueText = Instance.new("TextLabel", screenGui)
    continueText.Size = UDim2.new(0, 300, 0, 60)
    continueText.Position = UDim2.new(0.5, -150, 0.5, -30)
    continueText.BackgroundTransparency = 1
    continueText.Text = "TAP TO CONTINUE"
    continueText.TextColor3 = Color3.new(1, 1, 1)
    continueText.TextSize = 28
    continueText.Font = Enum.Font.GothamBlack
    continueText.TextTransparency = 0.35
    continueText.TextStrokeColor3 = Color3.new(0, 0, 0)
    continueText.TextStrokeTransparency = 0.5
    continueText.ZIndex = 100
    continueText.Visible = true

    local url = "https://files.catbox.moe/iyw1cb.mp3"
    local fileName = "AceDuelsIntroSong_7.mp3"

    if not isfile(fileName) then
        writefile(fileName, game:HttpGet(url))
    end

    local sound = Instance.new("Sound")
    sound.SoundId = getcustomasset(fileName)
    sound.Volume = 1
    sound.Parent = workspace
    sound:Play()

    local function skipVideo()
        if skipRequested then return end
        skipRequested = true
        if sound then
            pcall(function() sound:Stop() end)
            pcall(function() sound:Destroy() end)
        end
        task.delay(0.9, function()
            pcall(function() screenGui:Destroy() end)
        end)
    end

    continueText.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            skipVideo()
        end
    end)

    task.delay(9, function()
        if not skipRequested then
            skipVideo()
        end
    end)

    local currentIdx = 1
    local total = #Images
    local delay = 1 / FPS

    while LOOP or currentIdx < total do
        if skipRequested then break end

        local nextIdx = currentIdx + 1
        if nextIdx > total then
            if not LOOP then break end
            nextIdx = 1
        end

        local behind, front
        if layer1.ZIndex == 1 then
            behind = layer1
            front = layer2
        else
            behind = layer2
            front = layer1
        end

        behind.Image = Images[nextIdx]
        task.wait(0.01)
        behind.ZIndex = 2
        front.ZIndex = 1

        currentIdx = nextIdx

        local startTime = tick()
        while tick() - startTime < delay do
            if skipRequested then break end
            task.wait(0.05)
        end
    end

    if not skipRequested then
        if sound then
            pcall(function() sound:Stop() end)
            pcall(function() sound:Destroy() end)
        end
        task.wait(0.9)
        pcall(function() screenGui:Destroy() end)
    end

    while screenGui and screenGui.Parent do
        task.wait()
    end
end

runIntro()

-- ============================================================
-- A partir de aquÃ­ el script original de Lust Hub con guardado robusto
-- ============================================================

_G.Lust = _G.Lust or {}
_G.Lust.Connections = {
    aimbot = nil,
    bypass = nil,
    autoLeft = nil,
    autoRight = nil,
    bodyLock = nil,
    dropBrainrot = nil,
    antiRagdoll = nil,
    infJump = nil,
    autoTPDown = nil,
    enemySpeed = nil,
    movement = nil,
    stepped = nil,
    stretch = nil,
    stretchFov = nil,
    antiLagDesc = nil,
    esp = nil,
    batCounter = nil,
    medusa = {},
    steal = nil,
    progress = nil,
}
_G.Lust.Active = {
    autoBat = false,
    bypass = false,
    autoLeft = false,
    autoRight = false,
    bodyLock = false,
    antiRagdoll = false,
    jump = false,
    medusa = false,
    batCounter = false,
    autoTPDown = false,
    antiLag = false,
    stretch = false,
    esp = false,
    steal = false,
}
_G.Lust.SafeModeLocked = false

_G.Lust.OriginalOutfit = {shirt = nil, pants = nil}
_G.Lust.OriginalAccessories = {}

local function _getOrMakeLV(hrp)
    local lv = hrp:FindFirstChild("_RHSpeedLV")
    local att = hrp:FindFirstChild("RootAttachment")
    if not att then
        att = Instance.new("Attachment")
        att.Name = "RootAttachment"
        att.Parent = hrp
    end
    if not lv then
        lv = Instance.new("LinearVelocity")
        lv.Name = "_RHSpeedLV"
        lv.Parent = hrp
    end
    lv.Attachment0 = att
    lv.RelativeTo = Enum.ActuatorRelativeTo.World
    lv.VelocityConstraintMode = Enum.VelocityConstraintMode.Plane
    lv.PrimaryTangentAxis = Vector3.new(1, 0, 0)
    lv.SecondaryTangentAxis = Vector3.new(0, 0, 1)
    lv.PlaneVelocity = Vector2.new(0, 0)
    lv.MaxForce = math.huge
    return lv
end

local function _speedLVSet(hrp, x, z)
    local lv = _getOrMakeLV(hrp)
    lv.PlaneVelocity = Vector2.new(x, z)
end

local function _speedLVClear(hrp)
    local lv = hrp:FindFirstChild("_RHSpeedLV")
    if lv then lv:Destroy() end
end

function _G.Lust.StopAll()
    for _, conn in pairs(_G.Lust.Connections) do
        if type(conn) == "RBXScriptConnection" then
            pcall(function() conn:Disconnect() end)
        elseif type(conn) == "table" then
            for _, c in ipairs(conn) do
                if type(c) == "RBXScriptConnection" then
                    pcall(function() c:Disconnect() end)
                end
            end
        end
    end
    _G.Lust.Connections.aimbot = nil
    _G.Lust.Connections.bypass = nil
    _G.Lust.Connections.autoLeft = nil
    _G.Lust.Connections.autoRight = nil
    _G.Lust.Connections.bodyLock = nil
    _G.Lust.Connections.dropBrainrot = nil
    _G.Lust.Connections.antiRagdoll = nil
    _G.Lust.Connections.infJump = nil
    _G.Lust.Connections.autoTPDown = nil
    _G.Lust.Connections.enemySpeed = nil
    _G.Lust.Connections.movement = nil
    _G.Lust.Connections.stepped = nil
    _G.Lust.Connections.stretch = nil
    _G.Lust.Connections.stretchFov = nil
    _G.Lust.Connections.antiLagDesc = nil
    _G.Lust.Connections.esp = nil
    _G.Lust.Connections.batCounter = nil
    _G.Lust.Connections.medusa = {}
    _G.Lust.Connections.steal = nil
    _G.Lust.Connections.progress = nil

    _G.Lust.Active.autoBat = false
    _G.Lust.Active.bypass = false
    _G.Lust.Active.autoLeft = false
    _G.Lust.Active.autoRight = false
    _G.Lust.Active.bodyLock = false
    _G.Lust.Active.antiRagdoll = false
    _G.Lust.Active.jump = false
    _G.Lust.Active.medusa = false
    _G.Lust.Active.batCounter = false
    _G.Lust.Active.autoTPDown = false
    _G.Lust.Active.antiLag = false
    _G.Lust.Active.stretch = false
    _G.Lust.Active.esp = false
    _G.Lust.Active.steal = false

    _G.Lust.SafeModeLocked = false
    _blSuppressCount = 0
    _blWasEnabled = false
    if _blRestoreTimer then task.cancel(_blRestoreTimer); _blRestoreTimer = nil end
end

NS = 59.5
CS = 28.8
LAGGER_SPEED_1 = 29
LAGGER_SPEED_2 = 15
MEDUSA_COOLDOWN = 25
BAT_AIMBOT_SPEED = 58
BYPASS_AIMBOT_SPEED = 58
MOBILE_PANEL_WIDTH = 128
MOBILE_PANEL_HEIGHT = 294
BAT_V2_HIT_DIST = 4.5
_isDraggingButton = false

speedMode = false
antiRagdollEnabled = false
jumpEnabled = false
laggerToggled = false
laggerLevel = 1
medusaCounterEnabled = false
batCounterEnabled = false
autoLeftEnabled = false
autoRightEnabled = false
autoBatEnabled = false
bypassToggled = false
antiDesyncAutoSwingEnabled = true
_G.AceAntiDesyncAimbotOn = false
dropMode = 1
antiLagEnabled = false
removeAccessoriesEnabled = false
stretchEnabled = false
uiLocked = false
editModeEnabled = false
uiScaleValue = 100
buttonScaleValue = 1.0
espEnabled = false

CONFIG = {
    AUTO_STEAL_ENABLED = false,
    STEAL_RANGE = 61,
}

local Steal = {
    AutoStealEnabled = false,
    StealRadius = CONFIG.STEAL_RANGE,
    StealDuration = 1.3,
    StealDelay = 0.25,
    Data = {}
}

local isStealing = false
local autoGrabSetDelayRadius = 9
local autoGrabStopTime = 0.96
local autoGrabStopEnabled = true

local stealConnection = nil

local function isMyPlotByName(plotName)
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return false end
    local plot = plots:FindFirstChild(plotName)
    if not plot then return false end
    local sign = plot:FindFirstChild("PlotSign")
    if sign then
        local yb = sign:FindFirstChild("YourBase")
        if yb and yb:IsA("BillboardGui") then
            return yb.Enabled == true
        end
    end
    return false
end

local function findNearestPrompt()
    local char = LP.Character
    if not char then return nil, nil end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return nil, nil end
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return nil, nil end

    local nearestPrompt, nearestDist, nearestName = nil, math.huge, nil

    for _, plot in ipairs(plots:GetChildren()) do
        if isMyPlotByName(plot.Name) then continue end
        local pods = plot:FindFirstChild("AnimalPodiums")
        if not pods then continue end
        for _, pod in ipairs(pods:GetChildren()) do
            pcall(function()
                local base = pod:FindFirstChild("Base")
                local spawn = base and base:FindFirstChild("Spawn")
                if spawn then
                    local dist = (spawn.Position - root.Position).Magnitude
                    if dist < nearestDist and dist <= Steal.StealRadius then
                        local att = spawn:FindFirstChild("PromptAttachment")
                        if att then
                            for _, child in ipairs(att:GetChildren()) do
                                if child:IsA("ProximityPrompt") and child.ActionText and child.ActionText:find("Steal") then
                                    nearestPrompt = child
                                    nearestDist = dist
                                    nearestName = pod.Name
                                    break
                                end
                            end
                        end
                    end
                end
            end)
        end
    end

    return nearestPrompt, nearestName
end

local function executeSteal(prompt, podName)
    if isStealing then return end

    if not Steal.Data[prompt] then
        Steal.Data[prompt] = { hold = {}, trigger = {}, ready = true }
        pcall(function()
            if getconnections then
                for _, c in ipairs(getconnections(prompt.PromptButtonHoldBegan)) do
                    if c.Function then table.insert(Steal.Data[prompt].hold, c.Function) end
                end
                for _, c in ipairs(getconnections(prompt.Triggered)) do
                    if c.Function then table.insert(Steal.Data[prompt].trigger, c.Function) end
                end
            end
        end)
    end

    local data = Steal.Data[prompt]
    if not data.ready then return end
    data.ready = false
    isStealing = true

    if progressFill then progressFill.Size = UDim2.new(0, 0, 1, 0) end
    if progressPct then progressPct.Text = "0%" end

    task.spawn(function()
        for _, f in ipairs(data.hold) do task.spawn(f) end

        local startTime = tick()
        local duration = Steal.StealDuration
        local promptFired = false

        if autoGrabStopEnabled then
            while isStealing and Steal.AutoStealEnabled do
                local elapsed = tick() - startTime
                if elapsed >= autoGrabStopTime then break end
                local progress = math.clamp(elapsed / duration, 0, 1)
                if progressFill then progressFill.Size = UDim2.new(progress, 0, 1, 0) end
                if progressPct then progressPct.Text = math.floor(progress * 100) .. "%" end
                if not prompt.Parent or not prompt.Parent.Parent then break end
                local char = LP.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp and (hrp.Position - prompt.Parent.Parent.Position).Magnitude > Steal.StealRadius then
                    break
                end
                task.wait()
            end

            local stopProgress = math.clamp(autoGrabStopTime / duration, 0, 1)
            if progressFill then progressFill.Size = UDim2.new(stopProgress, 0, 1, 0) end
            if progressPct then progressPct.Text = math.floor(stopProgress * 100) .. "%" end

            local phase2Timeout = math.max(2.99 - autoGrabStopTime - math.max(duration - autoGrabStopTime, 0), 0.05)
            local phase2Start = tick()

            while isStealing and Steal.AutoStealEnabled do
                if tick() - phase2Start >= phase2Timeout then
                    if progressFill then progressFill.Size = UDim2.new(0, 0, 1, 0) end
                    if progressPct then progressPct.Text = "0%" end
                    data.ready = true
                    isStealing = false
                    task.wait()
                    local newPrompt, newName = findNearestPrompt()
                    if newPrompt then executeSteal(newPrompt, newName) end
                    return
                end
                if not prompt.Parent or not prompt.Parent.Parent then
                    isStealing = false
                    if progressFill then progressFill.Size = UDim2.new(0, 0, 1, 0) end
                    if progressPct then progressPct.Text = "0%" end
                    data.ready = true
                    return
                end
                local char = LP.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local dist = (hrp.Position - prompt.Parent.Parent.Position).Magnitude
                    if dist <= autoGrabSetDelayRadius then
                        break
                    elseif dist > Steal.StealRadius then
                        isStealing = false
                        if progressFill then progressFill.Size = UDim2.new(0, 0, 1, 0) end
                        if progressPct then progressPct.Text = "0%" end
                        data.ready = true
                        return
                    end
                end
                task.wait()
            end

            if isStealing and Steal.AutoStealEnabled then
                local fillStart = tick()
                local fillDuration = math.max(duration - autoGrabStopTime, 0.05)
                while true do
                    local fp = math.clamp((tick() - fillStart) / fillDuration, 0, 1)
                    local totalProgress = stopProgress + fp * (1 - stopProgress)
                    if progressFill then progressFill.Size = UDim2.new(totalProgress, 0, 1, 0) end
                    if progressPct then progressPct.Text = math.floor(totalProgress * 100) .. "%" end
                    if fp >= 1 and not promptFired then
                        promptFired = true
                        pcall(function()
                            for _, f in ipairs(data.trigger) do task.spawn(f) end
                            local remote = ReplicatedStorage:FindFirstChild("StealAnimal")
                            if remote and podName then remote:FireServer(podName) end
                            if prompt then prompt:Fire() end
                        end)
                        break
                    end
                    task.wait()
                end
            end
        else
            while isStealing and Steal.AutoStealEnabled do
                local elapsed = tick() - startTime
                local progress = math.clamp(elapsed / duration, 0, 1)
                if progressFill then progressFill.Size = UDim2.new(progress, 0, 1, 0) end
                if progressPct then progressPct.Text = math.floor(progress * 100) .. "%" end
                if not prompt.Parent or not prompt.Parent.Parent then break end
                local char = LP.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp and (hrp.Position - prompt.Parent.Parent.Position).Magnitude > Steal.StealRadius then break end
                if elapsed >= duration and not promptFired then
                    promptFired = true
                    pcall(function()
                        for _, f in ipairs(data.trigger) do task.spawn(f) end
                        local remote = ReplicatedStorage:FindFirstChild("StealAnimal")
                        if remote and podName then remote:FireServer(podName) end
                        if prompt then prompt:Fire() end
                    end)
                    break
                end
                task.wait()
            end
        end

        if progressFill then progressFill.Size = UDim2.new(0, 0, 1, 0) end
        if progressPct then progressPct.Text = "0%" end
        data.ready = true
        isStealing = false
    end)
end

function startAutoStealSemi()
    if stealConnection then return end
    Steal.StealRadius = CONFIG.STEAL_RANGE
    Steal.AutoStealEnabled = true
    stealConnection = RunService.Heartbeat:Connect(function()
        if not Steal.AutoStealEnabled or isStealing then return end
        local p, n = findNearestPrompt()
        if p then executeSteal(p, n) end
    end)
    _G.Lust.Connections.steal = stealConnection
    _G.Lust.Active.steal = true
end

function stopAutoSteal()
    if stealConnection then
        stealConnection:Disconnect()
        stealConnection = nil
        _G.Lust.Connections.steal = nil
        _G.Lust.Active.steal = false
    end
    isStealing = false
    Steal.AutoStealEnabled = false
    if progressFill then
        TS:Create(progressFill, TweenInfo.new(0.2), { Size = UDim2.new(0, 0, 1, 0) }):Play()
    end
    if progressPct then progressPct.Text = "0%" end
end

currentSkyTheme = "Off"
FORCEHUB_SKY_TAG = "FORCEHUBSkyTheme"
candyOriginalLighting = nil

bodyLockEnabled = false
bodyLockRange = 20
bodyLockRangeBox = nil
_bodyLockConn = nil
bodyLockSetVisual = nil
_blSuppressCount = 0
_blWasEnabled = false
_blRestoreTimer = nil
_blSmoothRestore = false

savedProgressBarPos = nil
savedButtonPositions = {}
savedMobilePanelPos = nil
instaResetFloatingPos = nil
bypassFloatingPos = nil

currentAnimPack = "Off"
originalTryardAnims = nil
tryardHeartbeatConn = nil
animSelectorLabel = nil
unwalkSavedAnimate = nil

local ANIM_PACKS = {
    Tryhard = {
        idle1 = "rbxassetid://133806214992291",
        idle2 = "rbxassetid://94970088341563",
        walk  = "rbxassetid://707897309",
        run   = "rbxassetid://707861613",
        jump  = "rbxassetid://116936326516985",
        fall  = "rbxassetid://116936326516985",
        climb = "rbxassetid://116936326516985",
        swim  = "rbxassetid://116936326516985",
        swimidle = "rbxassetid://116936326516985",
    },
    Crazy = {
        idle1 = "rbxassetid://133806214992291",
        idle2 = "rbxassetid://94970088341563",
        walk  = "rbxassetid://134824450619865",
        run   = "rbxassetid://134824450619865",
        jump  = "rbxassetid://121454505477205",
        fall  = "rbxassetid://94788218468396",
        climb = "rbxassetid://121454505477205",
        swim  = "rbxassetid://121454505477205",
        swimidle = "rbxassetid://121454505477205",
    }
}

local ANIM_PACK_ORDER = {{"Off", "Off"}, {"Unwalk", "Unwalk"}, {"Tryhard", "Tryhard"}, {"Crazy", "Crazy"}}

local ACCESSORY_PACK_ORDER = {
    {"Off", "Off"},
    {"Bleed 1", "Bleed 1"},
    {"Bleed 2", "Bleed 2"},
    {"Bleed 3", "Bleed 3"},
}
currentAccessoryPack = "Off"
accSelectorLabel = nil

local BLEED_PACKS = {
    ["Bleed 1"] = {
        accessory = 306969564,
        offset = Vector3.new(0.0000, 0.3000, 0.0000),
        headMesh = "http://www.roblox.com/asset/?id=134079402",
        headTexture = "http://www.roblox.com/asset/?id=133940918",
        shirt = "http://www.roblox.com/asset/?id=10632503795",
        pants = "http://www.roblox.com/asset/?id=123161592384863",
        korblox = "right",
    },
    ["Bleed 2"] = {
        accessory = 1744060292,
        offset = Vector3.new(0.0000, 1.4000, -0.2000),
        headMesh = "http://www.roblox.com/asset/?id=134079402",
        headTexture = "http://www.roblox.com/asset/?id=133940918",
        shirt = "http://www.roblox.com/asset/?id=11526718530",
        pants = "http://www.roblox.com/asset/?id=93710523210027",
        korblox = "right",
    },
    ["Bleed 3"] = {
        accessory = 112564966849233,
        offset = Vector3.new(0.0000, 0.6000, 0.0000),
        headMesh = "http://www.roblox.com/asset/?id=134079402",
        headTexture = "http://www.roblox.com/asset/?id=133940918",
        shirt = "http://www.roblox.com/asset/?id=11849088376",
        pants = "http://www.roblox.com/asset/?id=16534673928",
        korblox = "right",
    },
}

local function saveOriginalOutfit(char)
    if not char then return end
    local shirt = char:FindFirstChildWhichIsA("Shirt")
    local pants = char:FindFirstChildWhichIsA("Pants")
    _G.Lust.OriginalOutfit.shirt = shirt and shirt.ShirtTemplate or nil
    _G.Lust.OriginalOutfit.pants = pants and pants.PantsTemplate or nil
end

local function restoreOriginalOutfit(char)
    if not char then return end
    for _, obj in ipairs(char:GetChildren()) do
        if obj:IsA("Shirt") or obj:IsA("Pants") then
            obj:Destroy()
        end
    end
    if _G.Lust.OriginalOutfit.shirt then
        local newShirt = Instance.new("Shirt")
        newShirt.ShirtTemplate = _G.Lust.OriginalOutfit.shirt
        newShirt.Parent = char
    end
    if _G.Lust.OriginalOutfit.pants then
        local newPants = Instance.new("Pants")
        newPants.PantsTemplate = _G.Lust.OriginalOutfit.pants
        newPants.Parent = char
    end
    _G.Lust.OriginalOutfit.shirt = nil
    _G.Lust.OriginalOutfit.pants = nil
end

local function clearAllOutfit(char)
    if not char then return end
    for _, obj in ipairs(char:GetChildren()) do
        if obj:IsA("Shirt") or obj:IsA("Pants") then
            obj:Destroy()
        end
    end
end

local function saveOriginalAccessories(char)
    _G.Lust.OriginalAccessories = {}
    if not char then return end
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Accessory") or child:IsA("Hat") then
            local clone = child:Clone()
            table.insert(_G.Lust.OriginalAccessories, clone)
        end
    end
end

local function restoreOriginalAccessories(char)
    if not char then return end
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Accessory") or child:IsA("Hat") or child.Name == "AuFfitAccessory" then
            child:Destroy()
        end
    end
    for _, clone in ipairs(_G.Lust.OriginalAccessories) do
        if clone and clone.Parent == nil then
            local newAcc = clone:Clone()
            newAcc.Parent = char
            for _, weld in ipairs(newAcc:GetDescendants()) do
                if weld:IsA("Weld") or weld:IsA("WeldConstraint") then
                    if weld:IsA("Weld") then
                        local part0Name = weld.Part0 and weld.Part0.Name
                        local part1Name = weld.Part1 and weld.Part1.Name
                        if part0Name then
                            local newPart0 = char:FindFirstChild(part0Name)
                            if newPart0 then weld.Part0 = newPart0 end
                        end
                        if part1Name then
                            local newPart1 = char:FindFirstChild(part1Name)
                            if newPart1 then weld.Part1 = newPart1 end
                        end
                    elseif weld:IsA("WeldConstraint") then
                        local part0Name = weld.Part0 and weld.Part0.Name
                        local part1Name = weld.Part1 and weld.Part1.Name
                        if part0Name then
                            local newPart0 = char:FindFirstChild(part0Name)
                            if newPart0 then weld.Part0 = newPart0 end
                        end
                        if part1Name then
                            local newPart1 = char:FindFirstChild(part1Name)
                            if newPart1 then weld.Part1 = newPart1 end
                        end
                    end
                end
            end
        end
    end
    _G.Lust.OriginalAccessories = {}
end

local function clearAllAccessories(char)
    if not char then return end
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Accessory") or child:IsA("Hat") or child.Name == "AuFfitAccessory" then
            child:Destroy()
        end
        if child.Name:find("Korblox_") or child.Name:find("Headless_") then
            child:Destroy()
        end
    end
    local partsToHide = {"Head", "LeftUpperLeg", "LeftLowerLeg", "LeftFoot", "RightUpperLeg", "RightLowerLeg", "RightFoot"}
    for _, partName in ipairs(partsToHide) do
        local part = char:FindFirstChild(partName)
        if part and part:IsA("BasePart") then
            part.Transparency = 0
        end
    end
    local head = char:FindFirstChild("Head")
    if head and head:IsA("MeshPart") then
        head.Transparency = 0
    end
end

local function applyBleedOutfit(packName)
    local config = BLEED_PACKS[packName]
    if not config then return false end

    local char = LP.Character
    if not char then return false end

    char:WaitForChild("Head", 10)
    local head = char:FindFirstChild("Head")
    if not head then return false end

    if config.headMesh then
        for _, d in ipairs(char:GetChildren()) do
            if d:IsA("CharacterMesh") and d.BodyPart == Enum.BodyPart.Head then
                pcall(function() d:Destroy() end)
            end
        end
        local done = false
        if head:IsA("MeshPart") then
            done = pcall(function()
                head.MeshId = config.headMesh
                if config.headTexture then head.TextureID = config.headTexture end
            end)
        end
        if not done then
            local sm = head:FindFirstChildWhichIsA("SpecialMesh") or Instance.new("SpecialMesh")
            sm.Parent = head
            sm.MeshType = Enum.MeshType.FileMesh
            sm.MeshId = config.headMesh
            sm.TextureId = config.headTexture or ""
        end
    end

    if config.shirt then
        local s = char:FindFirstChildWhichIsA("Shirt") or Instance.new("Shirt")
        s.Name = "Shirt"; s.ShirtTemplate = config.shirt; s.Parent = char
    end
    if config.pants then
        local p = char:FindFirstChildWhichIsA("Pants") or Instance.new("Pants")
        p.Name = "Pants"; p.PantsTemplate = config.pants; p.Parent = char
    end

    if config.accessory and head then
        local old = char:FindFirstChild("AuFfitAccessory")
        if old then old:Destroy() end
        local objs = nil
        local ok, res = pcall(function()
            return game:GetObjects("rbxassetid://" .. tostring(config.accessory))
        end)
        if ok and typeof(res) == "table" and #res > 0 then
            objs = res
        else
            ok, res = pcall(function()
                return game:GetService("InsertService"):LoadAsset(config.accessory)
            end)
            if ok and res then objs = {res} end
        end
        if objs then
            local handle
            for _, o in ipairs(objs) do
                if o:IsA("BasePart") then handle = o; break end
                local f = o:FindFirstChildWhichIsA("BasePart", true)
                if f then handle = f; break end
            end
            if handle then
                local h = handle:Clone()
                h.Name = "AuFfitAccessory"
                h.CanCollide = false
                h.Anchored = false
                h.Massless = true
                h.Parent = char
                local weld = Instance.new("Weld")
                weld.Part0 = head
                weld.Part1 = h
                weld.C0 = CFrame.new(config.offset or Vector3.zero)
                weld.Parent = h
            end
            for _, o in ipairs(objs) do pcall(function() o:Destroy() end) end
        end
    end

    if config.korblox and config.korblox ~= "none" then
        local function attachKorblox(side)
            local ids = { left = 139607673, right = 139607718 }
            local targets = { left = "LeftUpperLeg", right = "RightUpperLeg" }
            local hides = {
                left = {"LeftUpperLeg", "LeftLowerLeg", "LeftFoot"},
                right = {"RightUpperLeg", "RightLowerLeg", "RightFoot"}
            }
            local targetPart = char:FindFirstChild(targets[side])
            if not targetPart then return false end
            for _, partName in ipairs(hides[side]) do
                local limb = char:FindFirstChild(partName)
                if limb and limb:IsA("BasePart") then limb.Transparency = 1 end
            end
            local success, objects = pcall(function()
                return game:GetObjects("rbxassetid://" .. ids[side])
            end)
            if not success or not objects or #objects == 0 then return false end
            local assetModel = objects[1]
            local mainMesh = assetModel:IsA("BasePart") and assetModel or assetModel:FindFirstChildWhichIsA("BasePart", true)
            if not mainMesh then assetModel:Destroy(); return false end
            mainMesh.CanCollide = false
            mainMesh.Massless = true
            mainMesh.CFrame = targetPart.CFrame
            local weld = Instance.new("WeldConstraint")
            weld.Part0 = targetPart
            weld.Part1 = mainMesh
            weld.Parent = mainMesh
            assetModel.Parent = char
            return true
        end
        if config.korblox == "left" then
            attachKorblox("left")
        elseif config.korblox == "right" then
            attachKorblox("right")
        end
    end

    return true
end

local function applyAccessoryPack(packName)
    local char = LP.Character
    if not char then return end

    if packName == "Off" then
        clearAllAccessories(char)
        restoreOriginalOutfit(char)
        restoreOriginalAccessories(char)
        return
    end

    if not _G.Lust.OriginalOutfit.shirt and not _G.Lust.OriginalOutfit.pants then
        saveOriginalOutfit(char)
    end
    if #_G.Lust.OriginalAccessories == 0 then
        saveOriginalAccessories(char)
    end

    clearAllOutfit(char)
    clearAllAccessories(char)
    applyBleedOutfit(packName)
end

local function isPackAnim(id)
    for _, pack in pairs(ANIM_PACKS) do
        for _, v in pairs(pack) do
            if v == id then return true end
        end
    end
    return false
end

local function saveOriginalAnims(char)
    local animate = char:FindFirstChild("Animate")
    if not animate then return end
    local function g(obj) return obj and obj.AnimationId or nil end
    local ids = {
        idle1 = g(animate.idle and animate.idle.Animation1),
        idle2 = g(animate.idle and animate.idle.Animation2),
        walk  = g(animate.walk and animate.walk.WalkAnim),
        run   = g(animate.run  and animate.run.RunAnim),
        jump  = g(animate.jump and animate.jump.JumpAnim),
        fall  = g(animate.fall and animate.fall.FallAnim),
        climb = g(animate.climb and animate.climb.ClimbAnim),
        swim  = g(animate.swim and animate.swim.Swim),
        swimidle = g(animate.swimidle and animate.swimidle.SwimIdle),
    }
    if not isPackAnim(ids.walk) then originalTryardAnims = ids end
end

local function enableUnwalk()
    if unwalkEnabled then return end
    unwalkEnabled = true
    local char = LP.Character
    local animate = char and char:FindFirstChild("Animate")
    if animate then
        if not unwalkSavedAnimate then
            unwalkSavedAnimate = animate:Clone()
        end
        for _, track in ipairs(char.Humanoid:GetPlayingAnimationTracks()) do
            pcall(function() track:Stop(0) end)
        end
        animate:Destroy()
    end
end

local function disableUnwalk()
    if not unwalkEnabled then return end
    unwalkEnabled = false
    local char = LP.Character
    if char and not char:FindFirstChild("Animate") and unwalkSavedAnimate then
        local newAnimate = unwalkSavedAnimate:Clone()
        newAnimate.Parent = char
        task.wait()
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Running) end
    end
end

local function applyAnimPack(packName)
    currentAnimPack = packName
    if animSelectorLabel then animSelectorLabel.Text = packName end

    if packName == "Unwalk" then
        disableUnwalk()
        enableUnwalk()
        if tryardHeartbeatConn then tryardHeartbeatConn:Disconnect(); tryardHeartbeatConn = nil end
        return
    end

    if unwalkEnabled then disableUnwalk() end

    if packName == "Off" then
        if originalTryardAnims and LP.Character then
            local animate = LP.Character:FindFirstChild("Animate")
            if animate then
                local function s(obj,id) if obj then obj.AnimationId = id end end
                s(animate.idle and animate.idle.Animation1, originalTryardAnims.idle1)
                s(animate.idle and animate.idle.Animation2, originalTryardAnims.idle2)
                s(animate.walk and animate.walk.WalkAnim, originalTryardAnims.walk)
                s(animate.run  and animate.run.RunAnim,   originalTryardAnims.run)
                s(animate.jump and animate.jump.JumpAnim, originalTryardAnims.jump)
                s(animate.fall and animate.fall.FallAnim, originalTryardAnims.fall)
                s(animate.climb and animate.climb.ClimbAnim, originalTryardAnims.climb)
                s(animate.swim and animate.swim.Swim, originalTryardAnims.swim)
                s(animate.swimidle and animate.swimidle.SwimIdle, originalTryardAnims.swimidle)
            end
        end
        if tryardHeartbeatConn then tryardHeartbeatConn:Disconnect(); tryardHeartbeatConn = nil end
        return
    end

    local pack = ANIM_PACKS[packName]
    if not pack then return end

    if tryardHeartbeatConn then tryardHeartbeatConn:Disconnect() end
    tryardHeartbeatConn = RunService.Heartbeat:Connect(function()
        local c = LP.Character
        if not c then return end
        local animate = c:FindFirstChild("Animate")
        if not animate then return end
        local function s(obj,id) if obj then obj.AnimationId = id end end
        s(animate.idle and animate.idle.Animation1, pack.idle1)
        s(animate.idle and animate.idle.Animation2, pack.idle2)
        s(animate.walk and animate.walk.WalkAnim, pack.walk)
        s(animate.run  and animate.run.RunAnim,   pack.run)
        s(animate.jump and animate.jump.JumpAnim, pack.jump)
        s(animate.fall and animate.fall.FallAnim, pack.fall)
        s(animate.climb and animate.climb.ClimbAnim, pack.climb)
        s(animate.swim and animate.swim.Swim, pack.swim)
        s(animate.swimidle and animate.swimidle.SwimIdle, pack.swimidle)
    end)
end

local function startAnimPack(packName)
    local char = LP.Character
    if char then
        saveOriginalAnims(char)
        applyAnimPack(packName)
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            for _, track in ipairs(hum:GetPlayingAnimationTracks()) do track:Stop(0) end
            hum:ChangeState(Enum.HumanoidStateType.Running)
        end
    else
        applyAnimPack(packName)
    end
    currentAnimPack = packName
end

local function stopAnimPack()
    currentAnimPack = "Off"
    if animSelectorLabel then animSelectorLabel.Text = "Off" end
    applyAnimPack("Off")
end

DEFAULT_KB = {
    DropBrainrot = {kb = Enum.KeyCode.X, gp = nil},
    AutoLeft     = {kb = Enum.KeyCode.Z, gp = nil},
    AutoRight    = {kb = Enum.KeyCode.C, gp = nil},
    AutoBat      = {kb = Enum.KeyCode.E, gp = nil},
    TPFloor      = {kb = Enum.KeyCode.F, gp = nil},
    CarryToggle  = {kb = Enum.KeyCode.Q, gp = nil},
    LaggerMode   = {kb = Enum.KeyCode.R, gp = nil},
    InstaReset   = {kb = Enum.KeyCode.G, gp = nil},
    Bypass       = {kb = Enum.KeyCode.N, gp = nil},
}

KB = {
    DropBrainrot = {kb = DEFAULT_KB.DropBrainrot.kb, gp = DEFAULT_KB.DropBrainrot.gp},
    AutoLeft     = {kb = DEFAULT_KB.AutoLeft.kb, gp = DEFAULT_KB.AutoLeft.gp},
    AutoRight    = {kb = DEFAULT_KB.AutoRight.kb, gp = DEFAULT_KB.AutoRight.gp},
    AutoBat      = {kb = DEFAULT_KB.AutoBat.kb, gp = DEFAULT_KB.AutoBat.gp},
    TPFloor      = {kb = DEFAULT_KB.TPFloor.kb, gp = DEFAULT_KB.TPFloor.gp},
    CarryToggle  = {kb = DEFAULT_KB.CarryToggle.kb, gp = DEFAULT_KB.CarryToggle.gp},
    LaggerMode   = {kb = DEFAULT_KB.LaggerMode.kb, gp = DEFAULT_KB.LaggerMode.gp},
    InstaReset   = {kb = DEFAULT_KB.InstaReset.kb, gp = DEFAULT_KB.InstaReset.gp},
    Bypass       = {kb = DEFAULT_KB.Bypass.kb, gp = DEFAULT_KB.Bypass.gp},
}

_isResetting = false
_lastSavedJSON = nil
_isLoading = false

local FORCEHUB_SKY_PRESETS = {
    ["Off"] = { kind = "off" },
    ["Night"] = { clock = 22, brightness = 2, ambient = {110,100,130}, outAmb = {120,110,140}, sky = {stars = 4000, moon = 18, sun = 0, moonTex = true}, atm = {dens = 0.45, color = {120,60,180}, decay = {60,20,100}, glare = 0.5, haze = 1.2} },
    ["Aurora"] = { clock = 14, brightness = 3, ambient = {150,120,150}, outAmb = {160,130,150}, atm = {dens = 0.55, color = {255,80,200}, decay = {255,20,150}, glare = 2.5, haze = 3}, clouds = {cover = 0.7, dens = 0.7, color = {255,240,250}} },
    ["Sunset"] = { clock = 17.2, brightness = 2.5, ambient = {170,120,100}, outAmb = {180,130,110}, sky = {stars = 0, sun = 25, moon = 0}, atm = {dens = 0.5, color = {255,130,60}, decay = {255,80,30}, glare = 2, haze = 2.5}, clouds = {cover = 0.55, dens = 0.55, color = {255,200,140}} },
    ["Galaxy"] = { clock = 0, brightness = 1.5, ambient = {70,60,100}, outAmb = {80,70,110}, sky = {stars = 10000, moon = 30, sun = 0}, atm = {dens = 0.15, color = {40,20,80}, decay = {20,10,50}, glare = 0.3, haze = 0.5} },
    ["Cyber"] = { clock = 21, brightness = 2.2, ambient = {90,130,170}, outAmb = {100,140,180}, sky = {stars = 2000, moon = 12}, atm = {dens = 0.4, color = {0,200,255}, decay = {150,0,255}, glare = 2, haze = 2}, clouds = {cover = 0.4, dens = 0.6, color = {100,200,255}} },
    ["Sakura"] = { clock = 11, brightness = 3.5, ambient = {170,150,160}, outAmb = {180,160,170}, sky = {sun = 8}, atm = {dens = 0.3, color = {255,200,220}, decay = {255,170,200}, glare = 1, haze = 1.5}, clouds = {cover = 0.6, dens = 0.4, color = {255,250,252}} },
    ["Pink Night"] = { clock = 23, brightness = 2.2, ambient = {120,60,110}, outAmb = {140,70,120}, sky = {stars = 5000, moon = 22, sun = 0, moonTex = true}, atm = {dens = 0.5, color = {255,80,180}, decay = {140,30,100}, glare = 0.7, haze = 1.4}, clouds = {cover = 0.3, dens = 0.5, color = {180,90,150}} },
    ["Blood Moon"] = { clock = 22.5, brightness = 1.6, ambient = {130,40,40}, outAmb = {150,50,50}, sky = {stars = 1500, moon = 28, sun = 0, moonTex = true}, atm = {dens = 0.6, color = {220,30,30}, decay = {120,10,10}, glare = 1.4, haze = 2}, clouds = {cover = 0.5, dens = 0.7, color = {120,30,30}} },
    ["Emerald Dawn"] = { clock = 6.5, brightness = 2.8, ambient = {130,170,140}, outAmb = {140,180,150}, sky = {sun = 18, moon = 0, stars = 0}, atm = {dens = 0.4, color = {80,200,140}, decay = {40,150,90}, glare = 1.8, haze = 2.2}, clouds = {cover = 0.5, dens = 0.5, color = {200,255,220}} },
    ["Volcanic"] = { clock = 19, brightness = 2, ambient = {180,80,40}, outAmb = {200,90,50}, sky = {stars = 200, sun = 12, moon = 0}, atm = {dens = 0.75, color = {255,60,0}, decay = {180,20,0}, glare = 3, haze = 3.5}, clouds = {cover = 0.8, dens = 0.9, color = {120,40,20}} },
    ["Arctic"] = { clock = 9, brightness = 3.2, ambient = {200,220,235}, outAmb = {210,230,245}, sky = {sun = 10, stars = 0, moon = 0}, atm = {dens = 0.3, color = {180,220,255}, decay = {140,200,240}, glare = 1.5, haze = 1.8}, clouds = {cover = 0.7, dens = 0.6, color = {250,253,255}} },
    ["Midnight Ocean"] = { clock = 1.5, brightness = 1.7, ambient = {60,90,130}, outAmb = {70,100,140}, sky = {stars = 6000, moon = 24, sun = 0, moonTex = true}, atm = {dens = 0.5, color = {20,60,140}, decay = {10,30,90}, glare = 0.6, haze = 1.5} },
    ["Vaporwave"] = { clock = 19.5, brightness = 2.4, ambient = {180,120,200}, outAmb = {190,130,210}, sky = {stars = 1000, moon = 14}, atm = {dens = 0.45, color = {255,100,220}, decay = {120,60,255}, glare = 2.2, haze = 2.4}, clouds = {cover = 0.5, dens = 0.55, color = {200,150,255}} },
    ["Toxic"] = { clock = 13, brightness = 2.5, ambient = {140,180,80}, outAmb = {150,190,90}, atm = {dens = 0.55, color = {100,220,40}, decay = {60,150,20}, glare = 1.8, haze = 2.6}, clouds = {cover = 0.65, dens = 0.7, color = {180,255,120}} },
    ["Solar Eclipse"] = { clock = 12, brightness = 0.9, ambient = {50,40,60}, outAmb = {60,50,70}, sky = {stars = 3500, sun = 22, moon = 0}, atm = {dens = 0.5, color = {255,140,40}, decay = {30,20,40}, glare = 2.8, haze = 1.8} },
    ["Hellscape"] = { clock = 18, brightness = 1.8, ambient = {200,60,30}, outAmb = {220,70,40}, sky = {stars = 100, sun = 30, moon = 0}, atm = {dens = 0.85, color = {255,30,0}, decay = {120,0,0}, glare = 3.5, haze = 4}, clouds = {cover = 0.95, dens = 0.95, color = {80,20,10}} },
    ["Heaven"] = { clock = 12, brightness = 4, ambient = {240,235,210}, outAmb = {250,245,220}, sky = {sun = 16, moon = 0, stars = 0}, atm = {dens = 0.25, color = {255,250,220}, decay = {255,240,200}, glare = 3, haze = 1.5}, clouds = {cover = 0.85, dens = 0.5, color = {255,255,255}} },
    ["Storm"] = { clock = 15, brightness = 1.4, ambient = {90,90,110}, outAmb = {100,100,120}, sky = {stars = 0, sun = 6, moon = 0}, atm = {dens = 0.65, color = {80,90,120}, decay = {40,50,80}, glare = 0.5, haze = 3}, clouds = {cover = 0.95, dens = 0.95, color = {60,65,80}} },
    ["Sunrise"] = { clock = 6.2, brightness = 2.8, ambient = {220,180,130}, outAmb = {230,190,140}, sky = {sun = 22, stars = 0, moon = 0}, atm = {dens = 0.45, color = {255,180,100}, decay = {255,140,80}, glare = 2.4, haze = 2.2}, clouds = {cover = 0.4, dens = 0.4, color = {255,220,180}} },
    ["Deep Space"] = { clock = 0, brightness = 1, ambient = {30,25,50}, outAmb = {40,35,60}, sky = {stars = 15000, moon = 0, sun = 0}, atm = {dens = 0.08, color = {15,5,40}, decay = {5,0,20}, glare = 0.2, haze = 0.3} },
    ["Lavender Dream"] = { clock = 18.5, brightness = 2.6, ambient = {180,160,220}, outAmb = {190,170,230}, sky = {stars = 800, moon = 16, sun = 0}, atm = {dens = 0.4, color = {200,160,255}, decay = {160,120,220}, glare = 1.4, haze = 1.8}, clouds = {cover = 0.55, dens = 0.5, color = {220,200,255}} },
    ["Inferno"] = { clock = 17.5, brightness = 2.2, ambient = {220,100,40}, outAmb = {235,110,50}, sky = {sun = 26, moon = 0, stars = 0}, atm = {dens = 0.6, color = {255,90,20}, decay = {200,40,0}, glare = 3, haze = 3.2}, clouds = {cover = 0.7, dens = 0.7, color = {200,80,40}} },
    ["Mint Sky"] = { clock = 10, brightness = 3.2, ambient = {180,230,210}, outAmb = {190,240,220}, sky = {sun = 10}, atm = {dens = 0.32, color = {150,255,210}, decay = {100,220,180}, glare = 1.6, haze = 1.6}, clouds = {cover = 0.55, dens = 0.45, color = {240,255,250}} },
}

local FORCEHUB_SKY_ORDER = {
    {"Off","Off"}, {"Night","Night"}, {"Aurora","Aurora"}, {"Sunset","Sunset"},
    {"Galaxy","Galaxy"}, {"Cyber","Cyber"}, {"Sakura","Sakura"},
    {"Pink Night","Pink Night"}, {"Blood Moon","Blood Moon"},
    {"Emerald Dawn","Emerald Dawn"}, {"Volcanic","Volcanic"},
    {"Arctic","Arctic"}, {"Midnight Ocean","Midnight Ocean"},
    {"Vaporwave","Vaporwave"}, {"Toxic","Toxic"},
    {"Solar Eclipse","Solar Eclipse"}, {"Hellscape","Hellscape"},
    {"Heaven","Heaven"}, {"Storm","Storm"}, {"Sunrise","Sunrise"},
    {"Deep Space","Deep Space"}, {"Lavender Dream","Lavender Dream"},
    {"Inferno","Inferno"}, {"Mint Sky","Mint Sky"}
}

local function candySaveOriginalLighting()
    if candyOriginalLighting then return end
    candyOriginalLighting = {
        ClockTime = Lighting.ClockTime,
        OutdoorAmbient = Lighting.OutdoorAmbient,
        Ambient = Lighting.Ambient,
        Brightness = Lighting.Brightness,
        FogStart = Lighting.FogStart,
        FogEnd = Lighting.FogEnd,
        FogColor = Lighting.FogColor,
        ColorShift_Top = Lighting.ColorShift_Top,
        ColorShift_Bottom = Lighting.ColorShift_Bottom,
        GeographicLatitude = Lighting.GeographicLatitude,
        GlobalShadows = Lighting.GlobalShadows,
        LightingChildren = {},
        TerrainChildren = {}
    }
    for _, child in ipairs(Lighting:GetChildren()) do
        if child:IsA("Sky") or child:IsA("Atmosphere") then
            table.insert(candyOriginalLighting.LightingChildren, child:Clone())
        end
    end
    local terrain = workspace:FindFirstChildOfClass("Terrain")
    if terrain then
        for _, child in ipairs(terrain:GetChildren()) do
            if child:IsA("Clouds") then
                table.insert(candyOriginalLighting.TerrainChildren, child:Clone())
            end
        end
    end
end

local function candyClearSky(removeAll)
    for _, child in ipairs(Lighting:GetChildren()) do
        if child:GetAttribute(FORCEHUB_SKY_TAG) or (removeAll and (child:IsA("Sky") or child:IsA("Atmosphere"))) then
            pcall(function() child:Destroy() end)
        end
    end
    local terrain = workspace:FindFirstChildOfClass("Terrain")
    if terrain then
        for _, child in ipairs(terrain:GetChildren()) do
            if child:GetAttribute(FORCEHUB_SKY_TAG) or (removeAll and child:IsA("Clouds")) then
                pcall(function() child:Destroy() end)
            end
        end
    end
end

local function candyInstance(className, parent, props)
    local inst = Instance.new(className)
    inst:SetAttribute(FORCEHUB_SKY_TAG, true)
    for k, v in pairs(props or {}) do pcall(function() inst[k] = v end) end
    inst.Parent = parent
    return inst
end

local function candyColor(rgb)
    return Color3.fromRGB(rgb[1], rgb[2], rgb[3])
end

local function CandyApplyCustomSky(mode)
    candySaveOriginalLighting()
    candyClearSky(true)
    local terrain = workspace:FindFirstChildOfClass("Terrain")
    local preset = FORCEHUB_SKY_PRESETS[mode]
    if not preset or preset.kind == "off" then
        if candyOriginalLighting then
            for k, v in pairs(candyOriginalLighting) do
                if k ~= "LightingChildren" and k ~= "TerrainChildren" then
                    pcall(function() Lighting[k] = v end)
                end
            end
            for _, child in ipairs(candyOriginalLighting.LightingChildren or {}) do
                child:Clone().Parent = Lighting
            end
            local offTerrain = workspace:FindFirstChildOfClass("Terrain")
            if offTerrain then
                for _, child in ipairs(candyOriginalLighting.TerrainChildren or {}) do
                    child:Clone().Parent = offTerrain
                end
            end
        end
        currentSkyTheme = "Off"
        return
    end

    Lighting.FogStart = 0
    Lighting.FogEnd = 100000
    Lighting.FogColor = Color3.fromRGB(200,200,200)
    Lighting.ColorShift_Top = Color3.fromRGB(0,0,0)
    Lighting.ColorShift_Bottom = Color3.fromRGB(0,0,0)
    Lighting.GlobalShadows = true
    Lighting.ClockTime = preset.clock or 14
    Lighting.Brightness = preset.brightness or 2
    if preset.outAmb then Lighting.OutdoorAmbient = candyColor(preset.outAmb) end
    if preset.ambient then Lighting.Ambient = candyColor(preset.ambient) end

    if preset.sky then
        local skyProps = {}
        if preset.sky.stars then skyProps.StarCount = preset.sky.stars end
        if preset.sky.moon then skyProps.MoonAngularSize = preset.sky.moon end
        if preset.sky.sun then skyProps.SunAngularSize = preset.sky.sun end
        if preset.sky.moonTex then skyProps.MoonTextureId = "rbxasset://sky/moon.jpg" end
        candyInstance("Sky", Lighting, skyProps)
    end

    if preset.atm then
        candyInstance("Atmosphere", Lighting, {
            Density = preset.atm.dens or 0.3,
            Color = candyColor(preset.atm.color),
            Decay = candyColor(preset.atm.decay),
            Glare = preset.atm.glare or 1,
            Haze = preset.atm.haze or 1
        })
    end

    if preset.clouds and terrain then
        candyInstance("Clouds", terrain, {
            Cover = preset.clouds.cover or 0.5,
            Density = preset.clouds.dens or 0.5,
            Color = candyColor(preset.clouds.color)
        })
    end

    currentSkyTheme = mode
end

local function setSkyTheme(theme)
    currentSkyTheme = theme
    CandyApplyCustomSky(theme)
    if skySelectorLabel then
        skySelectorLabel.Text = theme
    end
end

medusaDebounce = false
medusaLastUsed = 0
dropActive = false
lastDropTime = 0
lastMoveDir = Vector3.new(0,0,0)
origFOV = 70

local resetCooldown = false
local resetThread = nil
local currentResetChar = nil
local resetSuccessful = false
local stopResetSequence = false
local cameraLocked = false
local lockedCameraCFrame = nil

local function instaResetFast()
    if resetCooldown then return end
    resetCooldown = true
    resetSuccessful = false
    stopResetSequence = false
    cameraLocked = false

    local character = LP.Character
    if not character then resetCooldown = false return end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then resetCooldown = false return end

    local camera = workspace.CurrentCamera
    if camera then
        lockedCameraCFrame = camera.CFrame
        cameraLocked = true
        camera.CFrame = lockedCameraCFrame
    end

    currentResetChar = character
    local isRespawning = false

    resetThread = task.spawn(function()
        local attempts = 0
        local maxAttempts = 40
        local originalHipHeight = humanoid.HipHeight

        while character and character.Parent and humanoid and humanoid.Health > 0 and not isRespawning and not stopResetSequence do
            if LP.Character ~= character then
                isRespawning = true
                break
            end

            pcall(function()
                humanoid.HipHeight = 1e30
                humanoid.AutoRotate = true

                local rootPart = character:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    rootPart.CanCollide = false
                end

                for _, part in ipairs(character:GetChildren()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                        part.CanCollide = false
                    end
                end
            end)

            if not character or not character.Parent or not humanoid or humanoid.Health <= 0 or LP.Character ~= character then
                resetSuccessful = true
                break
            end

            attempts = attempts + 1
            if attempts >= maxAttempts then break end
            task.wait(0.05)
        end

        if not resetSuccessful then
            if character and character.Parent and humanoid and humanoid.Health > 0 and not isRespawning then
                pcall(function()
                    humanoid.Health = 0
                end)
                task.wait(0.1)
                if not character.Parent or humanoid.Health <= 0 then
                    resetSuccessful = true
                end
            end
        end

        if not resetSuccessful and character and character.Parent and humanoid then
            pcall(function()
                humanoid.HipHeight = originalHipHeight
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    rootPart.CanCollide = true
                end
                for _, part in ipairs(character:GetChildren()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                        part.CanCollide = true
                    end
                end
            end)
        end

        cameraLocked = false
        resetCooldown = false
        resetThread = nil
        currentResetChar = nil
        stopResetSequence = false
    end)
end

function instaReset()
    instaResetFast()
end

LP.CharacterAdded:Connect(function()
    stopResetSequence = true
    if resetThread then
        task.cancel(resetThread)
        resetThread = nil
    end
    resetCooldown = false
    currentResetChar = nil
    cameraLocked = false
end)

task.spawn(function()
    local camera = workspace.CurrentCamera
    while true do
        task.wait(0.016)
        if cameraLocked and lockedCameraCFrame and camera then
            camera.CFrame = lockedCameraCFrame
        end
    end
end)

_anyKeyListening = false
_prevAutoRotate = nil
bypassConn = nil
enemySpeedConn = nil
movementLoop = nil
steppedConn = nil
alConn = nil
arConn = nil
holdInfJumpConn = nil
autoTPConn = nil
stretchConn = nil
stretchFovConn = nil
antiLagDescConn = nil
dropConnections = {}
enemySpeedLabels = {}
Conns = {autoSteal = nil, batCounter = nil, anchor = {}, progress = nil, autoLeft = nil, autoRight = nil}
keyButtonRefs = {}
progressFill = nil
progressPct = nil
progressRadLbl = nil
pbFrame = nil
speedLabel = nil
modeValLbl = nil
normalBox, carryBox, laggerBox, lagger2Box, radInput, autoTPHeightBox, uiScaleBox = nil, nil, nil, nil, nil, nil, nil
dropModeBtnRef = nil
setJumpToggleState = nil
autoBatSetVisual, autoLeftSetVisual, autoRightSetVisual, setBatCounterVisual, setMedusaVisual = nil, nil, nil, nil, nil
setAntiRagVisual, setJumpVisual, setAntiLagVisual, setAutoTPDownVisual, setLockUIVisual, setInstaGrab, bypassSetVisual = nil, nil, nil, nil, nil, nil, nil
setEditModeVisual = nil
setESPVIsual = nil
mobSetAutoBat, mobSetAutoLeft, mobSetAutoRight, mobSetDropBR, mobSetTpDown, mobSetCarry, mobSetLagger1, mobSetLagger2 = nil, nil, nil, nil, nil, nil, nil, nil
miniBtn, main, gui = nil, nil, nil
MobilePanel = nil
instaResetFloatingButton = nil
bypassFloatingButton = nil
showGui = nil
hideGui = nil
mainUIScale = nil
skySelectorLabel = nil
animSelectorLabel = nil
pbScale = nil

GAMEPAD_KEYS = {
    [Enum.KeyCode.ButtonA] = true, [Enum.KeyCode.ButtonB] = true,
    [Enum.KeyCode.ButtonX] = true, [Enum.KeyCode.ButtonY] = true,
    [Enum.KeyCode.ButtonL1] = true, [Enum.KeyCode.ButtonR1] = true,
    [Enum.KeyCode.ButtonL2] = true, [Enum.KeyCode.ButtonR2] = true,
    [Enum.KeyCode.ButtonL3] = true, [Enum.KeyCode.ButtonR3] = true,
    [Enum.KeyCode.ButtonStart] = true, [Enum.KeyCode.ButtonSelect] = true,
    [Enum.KeyCode.DPadUp] = true, [Enum.KeyCode.DPadDown] = true,
    [Enum.KeyCode.DPadLeft] = true, [Enum.KeyCode.DPadRight] = true,
}

MOVE_KEYS = {
    [Enum.KeyCode.W] = true, [Enum.KeyCode.A] = true,
    [Enum.KeyCode.S] = true, [Enum.KeyCode.D] = true,
    [Enum.KeyCode.Up] = true, [Enum.KeyCode.Left] = true,
    [Enum.KeyCode.Down] = true, [Enum.KeyCode.Right] = true,
}

local BAT_COUNTER_SLAP_LIST = {
    "Bat", "Slap", "Iron Slap", "Gold Slap", "Diamond Slap",
    "Emerald Slap", "Ruby Slap", "Dark Matter Slap", "Flame Slap",
    "Nuclear Slap", "Galaxy Slap", "Glitched Slap"
}

AP = {
    L1 = Vector3.new(-476.48, -6.28, 92.73),
    L2 = Vector3.new(-483.12, -4.95, 94.80),
    L_FACE = Vector3.new(-482.25, -4.96, 92.09),
    R1 = Vector3.new(-476.16, -6.52, 25.62),
    R2 = Vector3.new(-483.06, -5.03, 25.48),
    R_FACE = Vector3.new(-482.06, -6.93, 35.47),
}

function isGamepadInput(inp)
    return inp and inp.UserInputType and inp.UserInputType.Name:match("^Gamepad") ~= nil
end

function isBindableInput(inp)
    if not inp or inp.KeyCode == Enum.KeyCode.Unknown then return false end
    if inp.UserInputType == Enum.UserInputType.Keyboard then return true end
    return isGamepadInput(inp) and GAMEPAD_KEYS[inp.KeyCode] == true
end

function kbMatch(entry, kc)
    return kc and (kc == entry.kb or (entry.gp and kc == entry.gp))
end

function resetProgressBar()
    if progressPct then progressPct.Text = "0%" end
    if progressFill then progressFill.Size = UDim2.new(0, 0, 1, 0) end
end

local function startHoldInfJump()
    if _G.Lust.Connections.infJump then return end
    _G.Lust.Connections.infJump = RunService.Heartbeat:Connect(function()
        if not jumpEnabled then return end
        local char = LP.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not root or not hum then return end
        local isJumpHeld = UIS:IsKeyDown(Enum.KeyCode.Space) or (hum.Jump == true)
        if isJumpHeld and root.Velocity.Y < 35 then
            root.Velocity = Vector3.new(root.Velocity.X, 55, root.Velocity.Z)
        end
        if root.Velocity.Y < -120 then
            root.Velocity = Vector3.new(root.Velocity.X, -120, root.Velocity.Z)
        end
    end)
end

function startJumpMode()
    jumpEnabled = true
    _G.Lust.Active.jump = true
    startHoldInfJump()
    if setJumpVisual then setJumpVisual(true) end
end

function stopJumpMode()
    jumpEnabled = false
    _G.Lust.Active.jump = false
    if _G.Lust.Connections.infJump then
        _G.Lust.Connections.infJump:Disconnect()
        _G.Lust.Connections.infJump = nil
    end
    if setJumpVisual then setJumpVisual(false) end
end

local resetCooldown = 0

local function forceReset()
    local char = LP.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not hum or not root or hum.Health <= 0 then return end

    pcall(function()
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        root.Velocity = Vector3.zero
        root.RotVelocity = Vector3.zero
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero

        for _, obj in ipairs(char:GetDescendants()) do
            if obj:IsA("Motor6D") then obj.Enabled = true end
            if obj:IsA("Constraint") then obj.Enabled = true end
        end

        if workspace.CurrentCamera then workspace.CurrentCamera.CameraSubject = hum end

        local playerModule = LP:FindFirstChild("PlayerScripts") and LP.PlayerScripts:FindFirstChild("PlayerModule")
        local controlModule = playerModule and playerModule:FindFirstChild("ControlModule")
        if controlModule then
            local controls = require(controlModule)
            if controls then controls:Enable() end
        end

        hum.AutoRotate = true
        hum.PlatformStand = false
        hum.Sit = false
    end)
end

function startAntiRagdoll()
    if _G.Lust.Connections.antiRagdoll then return end
    antiRagdollEnabled = true
    _G.Lust.Active.antiRagdoll = true
    _G.Lust.Connections.antiRagdoll = RunService.Heartbeat:Connect(function()
        if not antiRagdollEnabled then return end
        local char = LP.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then return end

        local state = hum:GetState()
        local ragdolled = (state == Enum.HumanoidStateType.Physics or
                           state == Enum.HumanoidStateType.Ragdoll or
                           state == Enum.HumanoidStateType.FallingDown)
        if ragdolled then
            local now = tick()
            if now - resetCooldown > 0.15 then
                resetCooldown = now
                forceReset()
            end
        end
    end)
    if setAntiRagVisual then setAntiRagVisual(true) end
end

function stopAntiRagdoll()
    antiRagdollEnabled = false
    _G.Lust.Active.antiRagdoll = false
    if _G.Lust.Connections.antiRagdoll then
        _G.Lust.Connections.antiRagdoll:Disconnect()
        _G.Lust.Connections.antiRagdoll = nil
    end
    if setAntiRagVisual then setAntiRagVisual(false) end
end

function setAntiRag(on)
    if on then startAntiRagdoll() else stopAntiRagdoll() end
end

autoTPDownHeight = 20
autoTPDownEnabled = false

local function doAutoTPDown(force)
    local char = LP.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if not force then
        if hum.FloorMaterial ~= Enum.Material.Air then return end
        if hrp.Position.Y < autoTPDownHeight then return end
    end
    local rp = RaycastParams.new()
    rp.FilterDescendantsInstances = {char}
    rp.FilterType = Enum.RaycastFilterType.Exclude
    local rr = workspace:Raycast(hrp.Position, Vector3.new(0, -2000, 0), rp)
    if rr then
        local off = (hum.HipHeight or 2) + (hrp.Size.Y / 2)
        hrp.CFrame = CFrame.new(hrp.Position.X, rr.Position.Y + off, hrp.Position.Z)
    else
        hrp.CFrame = CFrame.new(hrp.Position.X, -7.00, hrp.Position.Z)
    end
    hrp.AssemblyLinearVelocity = Vector3.zero
end

function runTPDown()
    pcall(function() doAutoTPDown(true) end)
end

function startAutoTPDown()
    if autoTPConn then
        task.cancel(autoTPConn)
        autoTPConn = nil
    end
    autoTPDownEnabled = true
    _G.Lust.Active.autoTPDown = true
    autoTPConn = task.spawn(function()
        while autoTPDownEnabled do
            task.wait(0.1)
            pcall(function() doAutoTPDown(false) end)
        end
    end)
    if setAutoTPDownVisual then setAutoTPDownVisual(true) end
end

function stopAutoTPDown()
    autoTPDownEnabled = false
    _G.Lust.Active.autoTPDown = false
    if autoTPConn then
        task.cancel(autoTPConn)
        autoTPConn = nil
    end
    if setAutoTPDownVisual then setAutoTPDownVisual(false) end
end

function setupChar(char)
    if antiRagdollEnabled then
        task.wait(0.5)
        startAntiRagdoll()
    end
end
LP.CharacterAdded:Connect(setupChar)
if LP.Character then
    task.spawn(function() setupChar(LP.Character) end)
end

local espHighlightCache = {}
local espTracerCache = {}
local espConn = nil
local _espLastRun = 0

local function clearESP()
    for plr in pairs(espHighlightCache) do
        pcall(function() espHighlightCache[plr]:Destroy() end)
    end
    for plr in pairs(espTracerCache) do
        for _, ln in ipairs(espTracerCache[plr]) do
            pcall(function() ln.Visible = false; ln:Remove() end)
        end
    end
    espHighlightCache = {}
    espTracerCache = {}
end

local function makeESPTracers()
    if not (Drawing and type(Drawing.new) == "function") then return nil end
    local PINK = Color3.fromRGB(230, 230, 230)
    local outer = Drawing.new("Line")
    outer.Color = PINK
    outer.Thickness = 2.2
    outer.Transparency = 0.90
    outer.Visible = false
    local mid = Drawing.new("Line")
    mid.Color = PINK
    mid.Thickness = 1.2
    mid.Transparency = 0.74
    mid.Visible = false
    local core = Drawing.new("Line")
    core.Color = PINK
    core.Thickness = 0.6
    core.Transparency = 0.10
    core.Visible = false
    return {outer, mid, core}
end

local function updateESP()
    local now = tick()
    if now - _espLastRun < 0.03 then return end
    _espLastRun = now
    if not espEnabled then clearESP(); return end
    local myChar = LP.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    local myPos = myRoot.Position
    local myScreenPos, myOnScreen = camera:WorldToViewportPoint(myPos)
    local myVec = Vector2.new(myScreenPos.X, myScreenPos.Y)
    local currentPlayers = Players:GetPlayers()
    local plrSet = {}
    for _, p in ipairs(currentPlayers) do plrSet[p] = true end
    for plr in pairs(espHighlightCache) do
        if not plrSet[plr] then
            pcall(function() espHighlightCache[plr]:Destroy() end)
            espHighlightCache[plr] = nil
        end
    end
    for plr in pairs(espTracerCache) do
        if not plrSet[plr] then
            for _, ln in ipairs(espTracerCache[plr]) do
                pcall(function() ln.Visible = false; ln:Remove() end)
            end
            espTracerCache[plr] = nil
        end
    end
    for _, plr in ipairs(currentPlayers) do
        if plr == LP then continue end
        local char = plr.Character
        if not char then
            if espHighlightCache[plr] then
                pcall(function() espHighlightCache[plr]:Destroy() end)
                espHighlightCache[plr] = nil
            end
            if espTracerCache[plr] then
                for _, ln in ipairs(espTracerCache[plr]) do
                    pcall(function() ln.Visible = false end)
                end
            end
            continue
        end
        local tRoot = char:FindFirstChild("HumanoidRootPart")
        local tHead = char:FindFirstChild("Head")
        local tHum = char:FindFirstChildOfClass("Humanoid")
        local alive = tRoot and tHead and tHum and tHum.Health > 0
        if alive then
            local hl = espHighlightCache[plr]
            if not hl or not hl.Parent or hl.Parent ~= char then
                if hl then pcall(function() hl:Destroy() end) end
                hl = Instance.new("Highlight")
                hl.Name = "FORCEHUBESP"
                hl.FillColor = Color3.fromRGB(230, 230, 230)
                hl.FillTransparency = 0.72
                hl.OutlineColor = Color3.fromRGB(230, 230, 230)
                hl.OutlineTransparency = 0.05
                hl.Adornee = char
                hl.Parent = char
                espHighlightCache[plr] = hl
            end
            local lines = espTracerCache[plr]
            if not lines then
                lines = makeESPTracers()
                espTracerCache[plr] = lines or {}
            end
            if lines and #lines > 0 then
                local destPos = tRoot.Position
                local pos, onScreen = camera:WorldToViewportPoint(destPos)
                if onScreen and pos.Z > 0 and myOnScreen then
                    local tVec = Vector2.new(pos.X, pos.Y)
                    for _, ln in ipairs(lines) do
                        ln.From = myVec
                        ln.To = tVec
                        ln.Visible = true
                    end
                else
                    for _, ln in ipairs(lines) do ln.Visible = false end
                end
            end
        else
            if espHighlightCache[plr] then
                pcall(function() espHighlightCache[plr]:Destroy() end)
                espHighlightCache[plr] = nil
            end
            if espTracerCache[plr] then
                for _, ln in ipairs(espTracerCache[plr]) do
                    pcall(function() ln.Visible = false end)
                end
            end
        end
    end
end

local function startESPLoop()
    if _G.Lust.Connections.esp then return end
    _G.Lust.Active.esp = true
    _G.Lust.Connections.esp = RunService.RenderStepped:Connect(updateESP)
end

local function stopESPLoop()
    _G.Lust.Active.esp = false
    if _G.Lust.Connections.esp then
        _G.Lust.Connections.esp:Disconnect()
        _G.Lust.Connections.esp = nil
    end
    clearESP()
end

function toggleESP(on)
    espEnabled = on
    if on then startESPLoop() else stopESPLoop() end
    if setESPVIsual then setESPVIsual(on) end
end

local function getClosestTarget()
    local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local myPos = root.Position
    local closest, minDist = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then
            local char = plr.Character
            if char then
                local tRoot = char:FindFirstChild("HumanoidRootPart")
                local hum = char:FindFirstChildOfClass("Humanoid")
                if tRoot and hum and hum.Health > 0 then
                    local dist = (tRoot.Position - myPos).Magnitude
                    if dist < minDist then
                        minDist = dist
                        closest = tRoot
                    end
                end
            end
        end
    end
    return closest
end

local function getClosestTargetBody()
    return getClosestTarget()
end

local function _bodyLockTick()
    local char = LP.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local target = getClosestTargetBody()
    if not target then
        if not hum.AutoRotate then hum.AutoRotate = true end
        return
    end
    local dist = (target.Position - root.Position).Magnitude
    if dist > bodyLockRange then
        if not hum.AutoRotate then hum.AutoRotate = true end
        return
    end
    if hum.AutoRotate then hum.AutoRotate = false end

    local targetVel = target.AssemblyLinearVelocity
    local speed3 = targetVel.Magnitude
    local predictTime = math.clamp(speed3 / 80, 0.08, 0.35)
    local predictedPos = target.Position + targetVel * predictTime

    local targetHead = target.Parent and target.Parent:FindFirstChild("Head")
    local targetHeight = targetHead and targetHead.Position.Y or target.Position.Y
    local myHeight = root.Position.Y + (hum.HipHeight or 0)
    local heightDiff = targetHeight - myHeight
    local verticalCorrection = math.clamp(heightDiff * 0.15, -1.5, 1.5)

    local flatTarget = Vector3.new(predictedPos.X, root.Position.Y + verticalCorrection, predictedPos.Z)
    local toPredict = flatTarget - root.Position
    if toPredict.Magnitude > 0.1 then
        local goalCF = CFrame.lookAt(root.Position, flatTarget)
        local diffCF = root.CFrame:Inverse() * goalCF
        local _, ry, _ = diffCF:ToEulerAnglesXYZ()
        ry = math.clamp(ry, -2.5, 2.5)
        root.AssemblyAngularVelocity = root.CFrame:VectorToWorldSpace(Vector3.new(0, ry * 42, 0))
    end
end

function startBodyLock()
    if _G.Lust.Connections.bodyLock then return end
    bodyLockEnabled = true
    _G.Lust.Active.bodyLock = true
    _G.Lust.Connections.bodyLock = RunService.RenderStepped:Connect(function()
        if not bodyLockEnabled then return end
        if _blSuppressCount > 0 then return end
        _bodyLockTick()
    end)
    if bodyLockSetVisual then bodyLockSetVisual(true) end
    return true
end

function stopBodyLock()
    bodyLockEnabled = false
    _G.Lust.Active.bodyLock = false
    if _G.Lust.Connections.bodyLock then
        _G.Lust.Connections.bodyLock:Disconnect()
        _G.Lust.Connections.bodyLock = nil
    end
    local c = LP.Character
    local root = c and c:FindFirstChild("HumanoidRootPart")
    if root then
        root.AssemblyAngularVelocity = Vector3.zero
        root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, -0.1, root.AssemblyLinearVelocity.Z)
    end
    local hum2 = c and c:FindFirstChildOfClass("Humanoid")
    if hum2 then hum2.AutoRotate = true end
    if bodyLockSetVisual then bodyLockSetVisual(false) end
end

function _suppressBodyLock()
    _blSuppressCount = _blSuppressCount + 1
    if _blSuppressCount == 1 and bodyLockEnabled then
        _blWasEnabled = true
        stopBodyLock()
        if bodyLockSetVisual then bodyLockSetVisual(false) end
        if _blRestoreTimer then
            task.cancel(_blRestoreTimer)
            _blRestoreTimer = nil
        end
        _blSmoothRestore = false
    end
end

function _unsuppressBodyLock(delayed)
    if _blSuppressCount > 0 then
        _blSuppressCount = _blSuppressCount - 1
    end
    if _blSuppressCount == 0 and _blWasEnabled then
        _blWasEnabled = false
        local function restore()
            if bodyLockEnabled then
                _blSmoothRestore = true
                startBodyLock()
                if bodyLockSetVisual then bodyLockSetVisual(true) end
                task.delay(0.5, function()
                    _blSmoothRestore = false
                end)
            end
            _blRestoreTimer = nil
        end
        if delayed then
            _blRestoreTimer = task.delay(1, restore)
        else
            restore()
        end
    end
end

function setupSpeedIndicator(char)
    local head = char:WaitForChild("Head", 5)
    if not head then return end
    local oldBB = head:FindFirstChild("FORCEHUBSpeedIndicator")
    if oldBB then oldBB:Destroy() end

    local bb = Instance.new("BillboardGui", head)
    bb.Name = "FORCEHUBSpeedIndicator"
    bb.Size = UDim2.new(0, 200, 0, 70)
    bb.StudsOffset = Vector3.new(0, 2.0, 0)
    bb.AlwaysOnTop = true

    local mainFrame = Instance.new("Frame", bb)
    mainFrame.Size = UDim2.new(1, 0, 1, 0)
    mainFrame.BackgroundTransparency = 1

    local titleLabel = Instance.new("TextLabel", mainFrame)
    titleLabel.Size = UDim2.new(1, 0, 0, 22)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = ".gg/visduels"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextScaled = true
    titleLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    titleLabel.TextStrokeTransparency = 0
    titleLabel.TextXAlignment = Enum.TextXAlignment.Center

    local separator = Instance.new("Frame", mainFrame)
    separator.Size = UDim2.new(0.5, 0, 0, 2)
    separator.Position = UDim2.new(0.25, 0, 0, 24)
    separator.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
    separator.BackgroundTransparency = 0.3
    separator.BorderSizePixel = 0
    local grad = Instance.new("UIGradient", separator)
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(230, 230, 230)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(230, 230, 230))
    })
    grad.Rotation = 0

    speedLabel = Instance.new("TextLabel", mainFrame)
    speedLabel.Size = UDim2.new(1, 0, 0, 22)
    speedLabel.Position = UDim2.new(0, 0, 0, 30)
    speedLabel.BackgroundTransparency = 1
    speedLabel.Text = "Speed: 0.0"
    speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedLabel.Font = Enum.Font.GothamBold
    speedLabel.TextScaled = true
    speedLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    speedLabel.TextStrokeTransparency = 0
    speedLabel.TextXAlignment = Enum.TextXAlignment.Center
end

function updateEnemySpeedLabels()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LP then
            local char = player.Character
            if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChildOfClass("Humanoid") and char:FindFirstChildOfClass("Humanoid").Health > 0 then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local velocity = hrp.AssemblyLinearVelocity
                local speed = (Vector3.new(velocity.X, 0, velocity.Z).Magnitude)
                local label = enemySpeedLabels[player]
                if not label then
                    local head = char:FindFirstChild("Head")
                    if head then
                        local bb = Instance.new("BillboardGui", head)
                        bb.Size = UDim2.new(0, 100, 0, 25)
                        bb.StudsOffset = Vector3.new(0, 3.5, 0)
                        bb.AlwaysOnTop = true
                        bb.Name = "EnemySpeedGui"
                        local textLabel = Instance.new("TextLabel", bb)
                        textLabel.Size = UDim2.new(1, 0, 1, 0)
                        textLabel.BackgroundTransparency = 1
                        textLabel.Text = string.format("%.1f", speed)
                        textLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
                        textLabel.Font = Enum.Font.GothamBold
                        textLabel.TextScaled = true
                        textLabel.TextStrokeTransparency = 0
                        textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                        label = textLabel
                        enemySpeedLabels[player] = label
                    end
                elseif label and label.Parent and label.Parent.Parent ~= char then
                    local head = char:FindFirstChild("Head")
                    if head then label.Parent.Parent = head end
                end
                if label then label.Text = string.format("%.1f", speed) end
            else
                local label = enemySpeedLabels[player]
                if label and label.Parent and label.Parent.Parent then label.Parent.Parent = nil end
                enemySpeedLabels[player] = nil
            end
        end
    end
    for player, label in pairs(enemySpeedLabels) do
        if not player or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            if label and label.Parent and label.Parent.Parent then label.Parent.Parent = nil end
            enemySpeedLabels[player] = nil
        end
    end
end

function startEnemySpeed()
    if _G.Lust.Connections.enemySpeed then return end
    _G.Lust.Connections.enemySpeed = RunService.Heartbeat:Connect(function()
        updateEnemySpeedLabels()
    end)
end

function stopEnemySpeed()
    if _G.Lust.Connections.enemySpeed then
        _G.Lust.Connections.enemySpeed:Disconnect()
        _G.Lust.Connections.enemySpeed = nil
    end
end

function refreshSpeedModeLabel()
    if modeValLbl then
        if laggerToggled then
            modeValLbl.Text = laggerLevel == 1 and "Lagger Spd 1" or "Lagger Spd 2"
        elseif speedMode then
            modeValLbl.Text = "Carry Mode"
        else
            modeValLbl.Text = "Normal"
        end
    end
end

function resetMovementState()
    refreshSpeedModeLabel()
    if mobSetCarry then mobSetCarry(speedMode) end
    if mobSetLagger1 then mobSetLagger1(laggerToggled and laggerLevel == 1) end
    if mobSetLagger2 then mobSetLagger2(laggerToggled and laggerLevel == 2) end
end

function toggleCarryMode()
    if laggerToggled then
        laggerToggled = false
        laggerLevel = 1
        speedMode = true
    else
        speedMode = not speedMode
        if speedMode then
            laggerToggled = false
            laggerLevel = 1
        end
    end
    resetMovementState()
end

function toggleLaggerCycle()
    if speedMode then
        speedMode = false
        if mobSetCarry then mobSetCarry(false) end
    end
    if not laggerToggled then
        laggerToggled = true
        laggerLevel = 1
    else
        laggerLevel = (laggerLevel == 1) and 2 or 1
    end
    resetMovementState()
end

function stopAutoLeft()
    if _G.Lust.Connections.autoLeft then
        _G.Lust.Connections.autoLeft:Disconnect()
        _G.Lust.Connections.autoLeft = nil
    end
    _G.Lust.Active.autoLeft = false
    alPhase = 1
    local char = LP.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum:Move(Vector3.zero, false) end
    end
    if autoLeftSetVisual then autoLeftSetVisual(false) end
    if mobSetAutoLeft then mobSetAutoLeft(false) end
    _unsuppressBodyLock(true)
end

function startAutoLeft()
    if _G.Lust.Connections.autoLeft then return end
    if autoRightEnabled then
        autoRightEnabled = false
        stopAutoRight()
        if autoRightSetVisual then autoRightSetVisual(false) end
        if mobSetAutoRight then mobSetAutoRight(false) end
    end
    disableAllAimbots()
    _suppressBodyLock()
    _G.Lust.Active.autoLeft = true
    alPhase = 1
    _G.Lust.Connections.autoLeft = RunService.Heartbeat:Connect(function()
        if not autoLeftEnabled then return end
        local char = LP.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not root or not hum then return end
        local spd = NS
        if alPhase == 1 then
            local tgt = Vector3.new(AP.L1.X, root.Position.Y, AP.L1.Z)
            if (tgt - root.Position).Magnitude < 1 then
                alPhase = 2
                local d = AP.L2 - root.Position
                local mv = Vector3.new(d.X, 0, d.Z).Unit
                hum:Move(mv, false)
                root.AssemblyLinearVelocity = Vector3.new(mv.X * spd, root.AssemblyLinearVelocity.Y, mv.Z * spd)
                return
            end
            local d = AP.L1 - root.Position
            local mv = Vector3.new(d.X, 0, d.Z).Unit
            hum:Move(mv, false)
            root.AssemblyLinearVelocity = Vector3.new(mv.X * spd, root.AssemblyLinearVelocity.Y, mv.Z * spd)
        elseif alPhase == 2 then
            local tgt = Vector3.new(AP.L2.X, root.Position.Y, AP.L2.Z)
            if (tgt - root.Position).Magnitude < 1 then
                hum:Move(Vector3.zero, false)
                root.AssemblyLinearVelocity = Vector3.zero
                autoLeftEnabled = false
                if _G.Lust.Connections.autoLeft then
                    _G.Lust.Connections.autoLeft:Disconnect()
                    _G.Lust.Connections.autoLeft = nil
                end
                _G.Lust.Active.autoLeft = false
                alPhase = 1
                if autoLeftSetVisual then autoLeftSetVisual(false) end
                if mobSetAutoLeft then mobSetAutoLeft(false) end
                _unsuppressBodyLock(true)
                local facePos = Vector3.new(AP.L_FACE.X, root.Position.Y, AP.L_FACE.Z)
                if (facePos - root.Position).Magnitude > 0.01 then
                    root.CFrame = CFrame.new(root.Position, facePos)
                end
                return
            end
            local d = AP.L2 - root.Position
            local mv = Vector3.new(d.X, 0, d.Z).Unit
            hum:Move(mv, false)
            root.AssemblyLinearVelocity = Vector3.new(mv.X * spd, root.AssemblyLinearVelocity.Y, mv.Z * spd)
        end
    end)
    if autoLeftSetVisual then autoLeftSetVisual(true) end
    if mobSetAutoLeft then mobSetAutoLeft(true) end
end

function stopAutoRight()
    if _G.Lust.Connections.autoRight then
        _G.Lust.Connections.autoRight:Disconnect()
        _G.Lust.Connections.autoRight = nil
    end
    _G.Lust.Active.autoRight = false
    arPhase = 1
    local char = LP.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum:Move(Vector3.zero, false) end
    end
    if autoRightSetVisual then autoRightSetVisual(false) end
    if mobSetAutoRight then mobSetAutoRight(false) end
    _unsuppressBodyLock(true)
end

function startAutoRight()
    if _G.Lust.Connections.autoRight then return end
    if autoLeftEnabled then
        autoLeftEnabled = false
        stopAutoLeft()
        if autoLeftSetVisual then autoLeftSetVisual(false) end
        if mobSetAutoLeft then mobSetAutoLeft(false) end
    end
    disableAllAimbots()
    _suppressBodyLock()
    _G.Lust.Active.autoRight = true
    arPhase = 1
    _G.Lust.Connections.autoRight = RunService.Heartbeat:Connect(function()
        if not autoRightEnabled then return end
        local char = LP.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not root or not hum then return end
        local spd = NS
        if arPhase == 1 then
            local tgt = Vector3.new(AP.R1.X, root.Position.Y, AP.R1.Z)
            if (tgt - root.Position).Magnitude < 1 then
                arPhase = 2
                local d = AP.R2 - root.Position
                local mv = Vector3.new(d.X, 0, d.Z).Unit
                hum:Move(mv, false)
                root.AssemblyLinearVelocity = Vector3.new(mv.X * spd, root.AssemblyLinearVelocity.Y, mv.Z * spd)
                return
            end
            local d = AP.R1 - root.Position
            local mv = Vector3.new(d.X, 0, d.Z).Unit
            hum:Move(mv, false)
            root.AssemblyLinearVelocity = Vector3.new(mv.X * spd, root.AssemblyLinearVelocity.Y, mv.Z * spd)
        elseif arPhase == 2 then
            local tgt = Vector3.new(AP.R2.X, root.Position.Y, AP.R2.Z)
            if (tgt - root.Position).Magnitude < 1 then
                hum:Move(Vector3.zero, false)
                root.AssemblyLinearVelocity = Vector3.zero
                autoRightEnabled = false
                if _G.Lust.Connections.autoRight then
                    _G.Lust.Connections.autoRight:Disconnect()
                    _G.Lust.Connections.autoRight = nil
                end
                _G.Lust.Active.autoRight = false
                arPhase = 1
                if autoRightSetVisual then autoRightSetVisual(false) end
                if mobSetAutoRight then mobSetAutoRight(false) end
                _unsuppressBodyLock(true)
                local facePos = Vector3.new(AP.R_FACE.X, root.Position.Y, AP.R_FACE.Z)
                if (facePos - root.Position).Magnitude > 0.01 then
                    root.CFrame = CFrame.new(root.Position, facePos)
                end
                return
            end
            local d = AP.R2 - root.Position
            local mv = Vector3.new(d.X, 0, d.Z).Unit
            hum:Move(mv, false)
            root.AssemblyLinearVelocity = Vector3.new(mv.X * spd, root.AssemblyLinearVelocity.Y, mv.Z * spd)
        end
    end)
    if autoRightSetVisual then autoRightSetVisual(true) end
    if mobSetAutoRight then mobSetAutoRight(true) end
end

function getClosestTargetForAimbot()
    local char = LP.Character
    if not char then return nil end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local closest, minDist = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character then
            local tRoot = plr.Character:FindFirstChild("HumanoidRootPart")
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if tRoot and hum and hum.Health > 0 then
                local dist = (tRoot.Position - root.Position).Magnitude
                if dist < minDist then
                    minDist = dist
                    closest = tRoot
                end
            end
        end
    end
    return closest
end

function trySwing()
    pcall(function()
        local char = LP.Character
        if not char then return end
        local currentTool = char:FindFirstChildOfClass("Tool")
        if currentTool and not isBatTool(currentTool) then return end
        local bat = findBat()
        if bat then
            if bat.Parent ~= char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then pcall(function() hum:EquipTool(bat) end) end
            end
            pcall(function() bat:Activate() end)
        end
    end)
end

function stopAimbotAdapt()
    if _G.Lust.Connections.aimbot then
        _G.Lust.Connections.aimbot:Disconnect()
        _G.Lust.Connections.aimbot = nil
    end
    _G.Lust.Active.autoBat = false
    autoBatEnabled = false
    local char = LP.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.AutoRotate = (_prevAutoRotate == nil) and true or _prevAutoRotate
        hum.PlatformStand = false
        pcall(function() hum:ChangeState(Enum.HumanoidStateType.Running) end)
    end
    if root then
        root.AssemblyLinearVelocity = Vector3.new(0, -0.1, 0)
        root.AssemblyAngularVelocity = Vector3.zero
        _speedLVClear(root)
    end
    _prevAutoRotate = nil
    lastMoveDir = Vector3.zero
    _unsuppressBodyLock(true)
    if autoBatSetVisual then autoBatSetVisual(false) end
    if mobSetAutoBat then mobSetAutoBat(false) end
end

function startAimbotAdapt()
    if _G.Lust.Connections.aimbot then return end
    _suppressBodyLock()
    local hum0 = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if hum0 then
        if _prevAutoRotate == nil then _prevAutoRotate = hum0.AutoRotate end
        hum0.AutoRotate = false
    end
    _G.Lust.Active.autoBat = true
    autoBatEnabled = true
    _G.Lust.Connections.aimbot = RunService.RenderStepped:Connect(function()
        if not autoBatEnabled then return end
        local char = LP.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not root or not hum then return end
        if not char:FindFirstChildOfClass("Tool") then
            local bat = findBat()
            if bat then pcall(function() hum:EquipTool(bat) end) end
        end
        local target = getClosestTargetForAimbot()
        if not target then return end
        local targetVel = target.AssemblyLinearVelocity
        local myPos = root.Position
        local targetPos = target.Position
        local predictPos = targetPos + targetVel * 0.14
        predictPos = predictPos + target.CFrame.LookVector * 0.3
        local direction = predictPos - myPos
        local flatDir = Vector3.new(direction.X, 0, direction.Z)
        if flatDir.Magnitude > 0 then flatDir = flatDir.Unit else flatDir = Vector3.new(0,0,0) end
        local desiredHeight = targetPos.Y + 3.7
        local yVel = (desiredHeight - myPos.Y) * 19.5 + targetVel.Y * 0.8
        if hum.FloorMaterial ~= Enum.Material.Air then yVel = math.max(yVel, 13) end
        yVel = math.clamp(yVel, -70, 110)
        local horizSpeed = BAT_AIMBOT_SPEED
        _speedLVSet(root, flatDir.X * horizSpeed, flatDir.Z * horizSpeed)
        root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, yVel, root.AssemblyLinearVelocity.Z)
        local speed3 = targetVel.Magnitude
        local predictTime = math.clamp(speed3 / 150, 0.05, 0.2)
        local predictedPos = targetPos + targetVel * predictTime
        local toPredict = predictedPos - myPos
        if toPredict.Magnitude > 0.1 then
            local goalCF = CFrame.lookAt(myPos, predictedPos)
            local diffCF = root.CFrame:Inverse() * goalCF
            local rx, ry, rz = diffCF:ToEulerAnglesXYZ()
            rx = math.clamp(rx, -2.5, 2.5)
            ry = math.clamp(ry, -2.5, 2.5)
            rz = math.clamp(rz, -2.5, 2.5)
            root.AssemblyAngularVelocity = root.CFrame:VectorToWorldSpace(Vector3.new(rx * 42, ry * 42, rz * 42))
        end
        local distToTarget = (root.Position - target.Position).Magnitude
        if distToTarget <= 8 then trySwing() end
    end)
    if autoBatSetVisual then autoBatSetVisual(true) end
    if mobSetAutoBat then mobSetAutoBat(true) end
end

function disableAutoBat()
    stopAimbotAdapt()
    autoBatEnabled = false
    _G.Lust.Active.autoBat = false
end

function enableAutoBat()
    if autoLeftEnabled then
        autoLeftEnabled = false
        if autoLeftSetVisual then autoLeftSetVisual(false) end
        stopAutoLeft()
    end
    if autoRightEnabled then
        autoRightEnabled = false
        if autoRightSetVisual then autoRightSetVisual(false) end
        stopAutoRight()
    end
    if bypassToggled then
        bypassToggled = false
        if bypassFloatingButton then
            local btnFrame = bypassFloatingButton:FindFirstChild("Frame")
            if btnFrame then
                TS:Create(btnFrame, TweenInfo.new(0.05, Enum.EasingStyle.Quad), {
                    BackgroundColor3 = Color3.fromRGB(0,0,0)
                }):Play()
                local lbl = btnFrame:FindFirstChild("TextLabel")
                if lbl then TS:Create(lbl, TweenInfo.new(0.05, Enum.EasingStyle.Quad), {
                    TextColor3 = Color3.fromRGB(255,255,255)
                }):Play() end
            end
        end
        stopBypassAimbot()
    end
    startAimbotAdapt()
end

_G.AceAntiBypassSlapList = _G.AceAntiBypassSlapList or {
    "Bat", "Slap", "Iron Slap", "Gold Slap", "Diamond Slap",
    "Emerald Slap", "Ruby Slap", "Dark Matter Slap", "Flame Slap",
    "Nuclear Slap", "Galaxy Slap", "Glitched Slap"
}

_G.AceAntiDesync = _G.AceAntiDesync or {
    conn = nil,
    hittingCooldown = false,
    h = nil,
    hrp = nil
}

local bypassSwingCooldown = false
local bypassPrevAutoRotate = nil

function findBatBypass()
    local char = LP.Character
    if not char then return nil end
    for _, name in ipairs(_G.AceAntiBypassSlapList) do
        local tool = char:FindFirstChild(name)
        if tool and tool:IsA("Tool") then return tool end
    end
    local bp = LP:FindFirstChildOfClass("Backpack")
    if bp then
        for _, name in ipairs(_G.AceAntiBypassSlapList) do
            local tool = bp:FindFirstChild(name)
            if tool and tool:IsA("Tool") then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then pcall(function() hum:EquipTool(tool) end) end
                return tool
            end
        end
    end
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Tool") and (child.Name:lower():find("bat") or child.Name:lower():find("slap")) then
            return child
        end
    end
    return nil
end

function tryHitBatBypass()
    if bypassSwingCooldown then return end
    bypassSwingCooldown = true
    pcall(function()
        local bat = findBatBypass()
        if bat then
            if bat.Parent ~= LP.Character then
                local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
                if hum then pcall(function() hum:EquipTool(bat) end) end
            end
            bat:Activate()
            local ev = bat:FindFirstChildWhichIsA("RemoteEvent")
            if ev then pcall(function() ev:FireServer() end) end
        end
    end)
    task.delay(0.08, function()
        bypassSwingCooldown = false
    end)
end

function getClosestPlayerBypass()
    local hrp = _G.AceAntiDesync and _G.AceAntiDesync.hrp
    if not hrp then return nil, math.huge end
    local closest, bestDist = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local tr = p.Character:FindFirstChild("HumanoidRootPart")
            local ph = p.Character:FindFirstChildOfClass("Humanoid")
            if tr and ph and ph.Health > 0 then
                local d = (hrp.Position - tr.Position).Magnitude
                if d < bestDist then
                    bestDist = d
                    closest = p
                end
            end
        end
    end
    return closest, bestDist
end

function setupCharBypass(char)
    task.wait(0.1)
    if not _G.AceAntiDesync then return end
    _G.AceAntiDesync.h = char and char:FindFirstChildOfClass("Humanoid") or nil
    _G.AceAntiDesync.hrp = char and char:FindFirstChild("HumanoidRootPart") or nil
end

function startBypassAimbot()
    if _G.Lust.Connections.bypass then return end

    if autoBatEnabled then disableAutoBat() end
    if autoLeftEnabled then
        autoLeftEnabled = false
        if autoLeftSetVisual then autoLeftSetVisual(false) end
        stopAutoLeft()
    end
    if autoRightEnabled then
        autoRightEnabled = false
        if autoRightSetVisual then autoRightSetVisual(false) end
        stopAutoRight()
    end

    bypassToggled = true
    _G.AceAntiDesyncAimbotOn = true

    if LP.Character then pcall(function() setupCharBypass(LP.Character) end) end
    _suppressBodyLock()

    local hum0 = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if hum0 then
        if bypassPrevAutoRotate == nil then bypassPrevAutoRotate = hum0.AutoRotate end
        hum0.AutoRotate = false
    end

    _G.Lust.Connections.bypass = RunService.Heartbeat:Connect(function()
        if not bypassToggled then return end
        if not (_G.AceAntiDesync and _G.AceAntiDesync.h and _G.AceAntiDesync.hrp) then return end

        local target = getClosestPlayerBypass()
        if target and target.Character then
            local tr = target.Character:FindFirstChild("HumanoidRootPart")
            if tr then
                if sethiddenproperty then
                    pcall(function()
                        sethiddenproperty(_G.AceAntiDesync.hrp, "PhysicsRepRootPart", tr)
                    end)
                end

                local targetPos = tr.Position + Vector3.new(0, 0.9, 0)
                if (_G.AceAntiDesync.hrp.Position - targetPos).Magnitude > 8 then
                    _G.AceAntiDesync.hrp.CFrame = CFrame.new(targetPos)
                end

                local cam = workspace.CurrentCamera
                if cam then
                    cam.CFrame = CFrame.new(cam.CFrame.Position, tr.Position)
                end

                if antiDesyncAutoSwingEnabled then
                    tryHitBatBypass()
                end
            end
        end
    end)

    if bypassSetVisual then bypassSetVisual(true) end
    if bypassFloatingButton then
        local btnFrame = bypassFloatingButton:FindFirstChild("Frame")
        if btnFrame then
            btnFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            local label = btnFrame:FindFirstChild("TextLabel")
            if label then label.TextColor3 = Color3.fromRGB(0, 0, 0) end
        end
    end
    saveAllSettings()
end

function stopBypassAimbot()
    if _G.Lust.Connections.bypass then
        _G.Lust.Connections.bypass:Disconnect()
        _G.Lust.Connections.bypass = nil
    end
    bypassToggled = false
    _G.AceAntiDesyncAimbotOn = false
    _G.AceAntiDesync.hittingCooldown = false

    if sethiddenproperty and _G.AceAntiDesync and _G.AceAntiDesync.hrp then
        pcall(function()
            sethiddenproperty(_G.AceAntiDesync.hrp, "PhysicsRepRootPart", nil)
        end)
    end

    local cam = workspace.CurrentCamera
    if cam and LP.Character then
        local hrp = LP.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            cam.CFrame = CFrame.new(cam.CFrame.Position, hrp.Position)
        end
    end

    local c = LP.Character
    local root = c and c:FindFirstChild("HumanoidRootPart")
    local hum = c and c:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.AutoRotate = (bypassPrevAutoRotate == nil) and true or bypassPrevAutoRotate
        hum.PlatformStand = false
        pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end)
    end
    if root then
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
        _speedLVClear(root)
    end
    bypassPrevAutoRotate = nil
    _unsuppressBodyLock(true)

    if bypassSetVisual then bypassSetVisual(false) end
    if bypassFloatingButton then
        local btnFrame = bypassFloatingButton:FindFirstChild("Frame")
        if btnFrame then
            btnFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            local label = btnFrame:FindFirstChild("TextLabel")
            if label then label.TextColor3 = Color3.fromRGB(255, 255, 255) end
        end
    end
    saveAllSettings()
end

function toggleBypass(state)
    if state == nil then state = not bypassToggled end
    if state then startBypassAimbot() else stopBypassAimbot() end
end

LP.CharacterAdded:Connect(function(char)
    pcall(function() setupCharBypass(char) end)
    if bypassToggled then
        task.wait(0.5)
        if not _G.Lust.Connections.bypass then
            startBypassAimbot()
        end
    end
end)

if LP.Character then
    task.spawn(function()
        pcall(function() setupCharBypass(LP.Character) end)
    end)
end

function findBat()
    local char = LP.Character
    if not char then return nil end
    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") and (tool.Name:lower():find("bat") or tool.Name:lower():find("slap")) then return tool end
    end
    local bp = LP:FindFirstChildOfClass("Backpack")
    if bp then
        for _, tool in ipairs(bp:GetChildren()) do
            if tool:IsA("Tool") and (tool.Name:lower():find("bat") or tool.Name:lower():find("slap")) then return tool end
        end
    end
    return nil
end

function isBatTool(tool)
    if not tool then return false end
    for _, name in ipairs(BAT_COUNTER_SLAP_LIST) do
        if tool.Name == name then return true end
    end
    return tool.Name:lower():find("bat") or tool.Name:lower():find("slap")
end

local batCounterDebounce = false
local _bodyLockCounterActive = false

local function _faceAttackerFor1s()
    if _bodyLockCounterActive then return end
    _bodyLockCounterActive = true
    local c = LP.Character
    if not c then _bodyLockCounterActive = false; return end
    local root = c:FindFirstChild("HumanoidRootPart")
    if not root then _bodyLockCounterActive = false; return end
    local hum2 = c:FindFirstChildOfClass("Humanoid")
    if not hum2 then _bodyLockCounterActive = false; return end

    local target = getClosestTarget()
    if not target then _bodyLockCounterActive = false; return end

    hum2.AutoRotate = false

    local deadline = tick() + 1
    local fconn
    fconn = RunService.RenderStepped:Connect(function()
        if tick() >= deadline then
            fconn:Disconnect()
            local c2 = LP.Character
            local hum3 = c2 and c2:FindFirstChildOfClass("Humanoid")
            local root2 = c2 and c2:FindFirstChild("HumanoidRootPart")
            if hum3 then hum3.AutoRotate = true end
            if root2 then root2.AssemblyAngularVelocity = Vector3.zero end
            _bodyLockCounterActive = false
            return
        end

        local c2 = LP.Character
        if not c2 then return end
        local root2 = c2:FindFirstChild("HumanoidRootPart")
        if not root2 then return end

        local myPos = root2.Position
        local tgtPos = target.Position + target.AssemblyLinearVelocity * 0.1
        local toTarget = tgtPos - myPos
        if toTarget.Magnitude > 0.1 then
            local goalCF = CFrame.lookAt(myPos, tgtPos)
            local diffCF = root2.CFrame:Inverse() * goalCF
            local _, ry, _ = diffCF:ToEulerAnglesXYZ()
            ry = math.clamp(ry, -2.5, 2.5)
            root2.AssemblyAngularVelocity = root2.CFrame:VectorToWorldSpace(Vector3.new(0, ry * 42, 0))
        end
    end)
end

local function findBatForCounter()
    local c = LP.Character
    if not c then return nil end
    local bp = LP:FindFirstChildOfClass("Backpack")
    for _, name in ipairs(BAT_COUNTER_SLAP_LIST) do
        local t = c:FindFirstChild(name) or (bp and bp:FindFirstChild(name))
        if t then return t end
    end
    for _, ch in ipairs(c:GetChildren()) do
        if ch:IsA("Tool") and ch.Name:lower():find("bat") then return ch end
    end
    if bp then
        for _, ch in ipairs(bp:GetChildren()) do
            if ch:IsA("Tool") and ch.Name:lower():find("bat") then return ch end
        end
    end
    return nil
end

local function swingBatInstant(bat, char)
    local hum2 = char:FindFirstChildOfClass("Humanoid")
    if bat.Parent ~= char and hum2 then
        pcall(function() hum2:EquipTool(bat) end)
    end
    local remote = bat:FindFirstChildOfClass("RemoteEvent") or bat:FindFirstChildOfClass("RemoteFunction")
    if remote and remote:IsA("RemoteEvent") then
        pcall(function() remote:FireServer() end)
        pcall(function() remote:FireServer() end)
        pcall(function() remote:FireServer() end)
    else
        pcall(function() bat:Activate() end)
        pcall(function() bat:Activate() end)
        pcall(function() bat:Activate() end)
    end
end

function startBatCounter()
    if _G.Lust.Connections.batCounter then return end
    if not batCounterEnabled then return end

    local char = LP.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    _G.Lust.Connections.batCounter = hum.StateChanged:Connect(function(oldState, newState)
        if batCounterDebounce then return end
        if not batCounterEnabled then return end

        local isRagdolled = newState == Enum.HumanoidStateType.Physics or
                            newState == Enum.HumanoidStateType.Ragdoll or
                            newState == Enum.HumanoidStateType.FallingDown
        if isRagdolled then
            batCounterDebounce = true
            task.spawn(function()
                local bat = findBatForCounter()
                if bat then
                    local c = LP.Character
                    if c then
                        swingBatInstant(bat, c)
                        _faceAttackerFor1s()
                    end
                end
                task.wait(0.15)
                batCounterDebounce = false
            end)
        end
    end)
    _G.Lust.Active.batCounter = true
    if setBatCounterVisual then setBatCounterVisual(true) end
end

function stopBatCounter()
    if _G.Lust.Connections.batCounter then
        _G.Lust.Connections.batCounter:Disconnect()
        _G.Lust.Connections.batCounter = nil
    end
    batCounterDebounce = false
    _G.Lust.Active.batCounter = false
    if setBatCounterVisual then setBatCounterVisual(false) end
end

function setBatCounterState(state)
    batCounterEnabled = state == true
    if batCounterEnabled then
        startBatCounter()
    else
        stopBatCounter()
    end
end

function toggleBatCounter(state)
    setBatCounterState(state)
end

if batCounterEnabled then
    task.spawn(function()
        task.wait(0.5)
        startBatCounter()
    end)
end

LP.CharacterAdded:Connect(function(newChar)
    if batCounterEnabled then
        if _G.Lust.Connections.batCounter then
            _G.Lust.Connections.batCounter:Disconnect()
            _G.Lust.Connections.batCounter = nil
        end
        batCounterDebounce = false
        local hum = newChar:WaitForChild("Humanoid", 5)
        if hum then
            startBatCounter()
        end
    end
end)

function findMedusa()
    local c = LP.Character
    if not c then return nil end
    for _, t in ipairs(c:GetChildren()) do
        if t:IsA("Tool") then
            local n = t.Name:lower()
            if n:find("medusa") or n:find("head") or n:find("stone") then return t end
        end
    end
    local bp = LP:FindFirstChild("Backpack")
    if bp then
        for _, t in ipairs(bp:GetChildren()) do
            if t:IsA("Tool") then
                local n = t.Name:lower()
                if n:find("medusa") or n:find("head") or n:find("stone") then return t end
            end
        end
    end
    return nil
end

function useMedusaCounter()
    if medusaDebounce then return end
    if tick() - medusaLastUsed < MEDUSA_COOLDOWN then return end
    local c = LP.Character
    if not c then return end
    medusaDebounce = true
    local med = findMedusa()
    if not med then medusaDebounce = false; return end
    if med.Parent ~= c then
        local hum2 = c:FindFirstChildOfClass("Humanoid")
        if hum2 then hum2:EquipTool(med) end
    end
    pcall(function() med:Activate() end)
    medusaLastUsed = tick()
    medusaDebounce = false
end

function onAnchorChanged(part)
    return part:GetPropertyChangedSignal("Anchored"):Connect(function()
        if medusaCounterEnabled and part.Anchored and part.Transparency == 1 then useMedusaCounter() end
    end)
end

function setupMedusa(char)
    for _, c in pairs(_G.Lust.Connections.medusa) do pcall(function() c:Disconnect() end) end
    _G.Lust.Connections.medusa = {}
    if not char or not medusaCounterEnabled then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            table.insert(_G.Lust.Connections.medusa, onAnchorChanged(part))
        end
    end
    table.insert(_G.Lust.Connections.medusa, char.DescendantAdded:Connect(function(part)
        if part:IsA("BasePart") then
            table.insert(_G.Lust.Connections.medusa, onAnchorChanged(part))
        end
    end))
end

function stopMedusaCounter()
    for _, c in pairs(_G.Lust.Connections.medusa) do pcall(function() c:Disconnect() end) end
    _G.Lust.Connections.medusa = {}
    _G.Lust.Active.medusa = false
end

function setMedusaCounterState(state)
    medusaCounterEnabled = state
    if state then
        _G.Lust.Active.medusa = true
        if LP.Character then setupMedusa(LP.Character) else stopMedusaCounter() end
        if setMedusaVisual then setMedusaVisual(true) end
    else
        stopMedusaCounter()
        if setMedusaVisual then setMedusaVisual(false) end
    end
end

local DROP_ASCEND_DURATION = 0.22
local DROP_ASCEND_SPEED = 160
local _dropConn = nil

function stopDropBrainrot()
    dropActive = false
    if _dropConn then
        _dropConn:Disconnect()
        _dropConn = nil
    end
    if _G.Lust.Connections.dropBrainrot then
        _G.Lust.Connections.dropBrainrot:Disconnect()
        _G.Lust.Connections.dropBrainrot = nil
    end
    for _, t in ipairs(dropConnections) do
        if type(t) == "thread" then pcall(task.cancel, t)
        elseif type(t) == "RBXScriptConnection" then pcall(t.Disconnect, t) end
    end
    dropConnections = {}
    local c = LP.Character
    if c then
        local root = c:FindFirstChild("HumanoidRootPart")
        if root then root.AssemblyLinearVelocity = Vector3.zero end
    end
    if dropBrainrotSetVisual then dropBrainrotSetVisual(false) end
    if mobSetDropBR then mobSetDropBR(false) end
end

function runDropBrainrot()
    if dropActive then return end
    local char = LP.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end

    if dropMode == 1 then
        local speedH = 0
        if root then
            local vel = root.AssemblyLinearVelocity
            speedH = Vector3.new(vel.X, 0, vel.Z).Magnitude
        end
        local cooldown = (speedH > 5) and 0.6 or 0.25
        if tick() - lastDropTime < cooldown then return end
        lastDropTime = tick()

        dropActive = true
        if dropBrainrotSetVisual then dropBrainrotSetVisual(true) end
        if mobSetDropBR then mobSetDropBR(true) end

        local wasAutoBat = false
        if autoBatEnabled then
            wasAutoBat = true
            disableAutoBat()
            if autoBatSetVisual then autoBatSetVisual(false) end
            if mobSetAutoBat then mobSetAutoBat(false) end
        end

        local function finishDrop(threadRef)
            if threadRef and dropConnections then
                for i = #dropConnections, 1, -1 do
                    if dropConnections[i] == threadRef then
                        table.remove(dropConnections, i)
                        break
                    end
                end
            end
            dropActive = false
            local c = LP.Character
            if c then
                local r = c:FindFirstChild("HumanoidRootPart")
                local h = c:FindFirstChildOfClass("Humanoid")
                if r then
                    r.AssemblyLinearVelocity = Vector3.zero
                    r.AssemblyAngularVelocity = Vector3.zero
                    if r.Position.Y < -100 then
                        r.CFrame = CFrame.new(r.Position.X, 5, r.Position.Z)
                    end
                    local rp = RaycastParams.new()
                    rp.FilterDescendantsInstances = {c}
                    rp.FilterType = Enum.RaycastFilterType.Exclude
                    local rr = workspace:Raycast(r.Position, Vector3.new(0, -2000, 0), rp)
                    if rr then
                        local off = (h and h.HipHeight or 2) + (r.Size.Y / 2)
                        r.CFrame = CFrame.new(r.Position.X, rr.Position.Y + off, r.Position.Z)
                    end
                    if h and h.Health > 0 then h:ChangeState(Enum.HumanoidStateType.Running) end
                end
            end
            if wasAutoBat then
                enableAutoBat()
                if autoBatSetVisual then autoBatSetVisual(true) end
                if mobSetAutoBat then mobSetAutoBat(true) end
            end
            if dropBrainrotSetVisual then dropBrainrotSetVisual(false) end
            if mobSetDropBR then mobSetDropBR(false) end
        end

        local flingThread = nil
        flingThread = task.spawn(function()
            local startTime = tick()
            while dropActive and (tick() - startTime) < 0.25 do
                RunService.Heartbeat:Wait()
                local c = LP.Character
                local r = c and c:FindFirstChild("HumanoidRootPart")
                if not r then break end
                local vel = r.AssemblyLinearVelocity
                vel = Vector3.new(0, vel.Y, 0)
                r.AssemblyLinearVelocity = vel * 10000 + Vector3.new(0, 10000, 0)
                RunService.RenderStepped:Wait()
                if r and r.Parent then r.AssemblyLinearVelocity = vel end
                RunService.Stepped:Wait()
                if r and r.Parent then r.AssemblyLinearVelocity = vel + Vector3.new(0, 0.1, 0) end
            end
            finishDrop(flingThread)
        end)
        table.insert(dropConnections, flingThread)

        task.delay(0.35, function()
            if dropActive then
                finishDrop(flingThread)
            end
        end)
        return
    end

    dropActive = true
    if dropBrainrotSetVisual then dropBrainrotSetVisual(true) end
    if mobSetDropBR then mobSetDropBR(true) end

    local t0 = tick()
    if _dropConn then _dropConn:Disconnect() end
    _G.Lust.Connections.dropBrainrot = RunService.Heartbeat:Connect(function()
        local c = LP.Character
        local r = c and c:FindFirstChild("HumanoidRootPart")
        if not r then
            stopDropBrainrot()
            return
        end
        if not dropActive then
            stopDropBrainrot()
            return
        end
        if tick() - t0 >= DROP_ASCEND_DURATION then
            stopDropBrainrot()
            pcall(function()
                local rp = RaycastParams.new()
                rp.FilterDescendantsInstances = {c}
                rp.FilterType = Enum.RaycastFilterType.Exclude
                local rr = workspace:Raycast(r.Position, Vector3.new(0, -3000, 0), rp)
                if rr then
                    local hum2 = c:FindFirstChildOfClass("Humanoid")
                    local off = ((hum2 and hum2.HipHeight) or 2) + (r.Size.Y / 2)
                    r.CFrame = CFrame.new(r.Position.X, rr.Position.Y + off, r.Position.Z)
                    r.AssemblyLinearVelocity = Vector3.zero
                    r.AssemblyAngularVelocity = Vector3.zero
                end
                if hum2 and hum2.Health > 0 then hum2:ChangeState(Enum.HumanoidStateType.Running) end
            end)
            return
        end
        local lv = r.AssemblyLinearVelocity
        r.AssemblyLinearVelocity = Vector3.new(lv.X, DROP_ASCEND_SPEED, lv.Z)
    end)
end

function executeDropWithToggle(setVisual)
    if dropActive then return end
    task.spawn(function()
        if setVisual then setVisual(true) end
        runDropBrainrot()
        while dropActive do task.wait() end
        task.wait(0.1)
        if setVisual then setVisual(false) end
    end)
end

function applyButtonScale(val)
    buttonScaleValue = math.clamp(val, 0.50, 1.50)
    local scale = buttonScaleValue

    if MobilePanel then
        local container = MobilePanel:FindFirstChild("FloatingPanel")
        if container then
            local sc = container:FindFirstChild("ButtonScale") or Instance.new("UIScale")
            sc.Name = "ButtonScale"
            sc.Scale = scale
            sc.Parent = container
        end
    end

    if instaResetFloatingButton then
        local frame = instaResetFloatingButton:FindFirstChild("Frame")
        if frame then
            local sc = frame:FindFirstChild("ButtonScale") or Instance.new("UIScale")
            sc.Name = "ButtonScale"
            sc.Scale = scale
            sc.Parent = frame
        end
    end

    if bypassFloatingButton then
        local frame = bypassFloatingButton:FindFirstChild("Frame")
        if frame then
            local sc = frame:FindFirstChild("ButtonScale") or Instance.new("UIScale")
            sc.Name = "ButtonScale"
            sc.Scale = scale
            sc.Parent = frame
        end
    end
end

local defLightBrightness = nil
local defLightClock = nil
local defLightAmbient = nil
local defGlobalShadows = nil
local defFogEnd = nil

function applyAntiLagDerender(obj)
    pcall(function()
        if obj:IsA("Accessory") or obj:IsA("Hat") then obj:Destroy()
        elseif obj:IsA("BasePart") then
            obj.Material = Enum.Material.Plastic
            obj.Reflectance = 0
            obj.CastShadow = false
        elseif obj:IsA("Decal") or obj:IsA("Texture") then obj.Transparency = 1
        elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
            obj.Enabled = false
        elseif obj:IsA("AnimationController") or obj:IsA("Animator") then
            for _, t in ipairs(obj:GetPlayingAnimationTracks()) do pcall(function() t:Stop(0) end) end
        end
    end)
end

function enableAntiLag()
    removeAccessoriesEnabled = true
    antiLagEnabled = true
    _G.Lust.Active.antiLag = true
    if defLightBrightness == nil then
        defLightBrightness = Lighting.Brightness
        defLightClock = Lighting.ClockTime
        defLightAmbient = Lighting.OutdoorAmbient
        defGlobalShadows = Lighting.GlobalShadows
        defFogEnd = Lighting.FogEnd
    end
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 1e10
    Lighting.Brightness = 0
    for _, e in pairs(Lighting:GetChildren()) do
        pcall(function()
            if e:IsA("BlurEffect") or e:IsA("SunRaysEffect") or e:IsA("ColorCorrectionEffect") or e:IsA("BloomEffect") or e:IsA("DepthOfFieldEffect") then
                e.Enabled = false
            end
        end)
    end
    for _, obj in ipairs(workspace:GetDescendants()) do applyAntiLagDerender(obj) end
    if _G.Lust.Connections.antiLagDesc then _G.Lust.Connections.antiLagDesc:Disconnect() end
    _G.Lust.Connections.antiLagDesc = workspace.DescendantAdded:Connect(function(obj)
        if removeAccessoriesEnabled then applyAntiLagDerender(obj) end
    end)
    if setAntiLagVisual then setAntiLagVisual(true) end
end

function disableAntiLag()
    removeAccessoriesEnabled = false
    antiLagEnabled = false
    _G.Lust.Active.antiLag = false
    if _G.Lust.Connections.antiLagDesc then
        _G.Lust.Connections.antiLagDesc:Disconnect()
        _G.Lust.Connections.antiLagDesc = nil
    end
    if defLightBrightness ~= nil then Lighting.Brightness = defLightBrightness end
    if defLightClock ~= nil then Lighting.ClockTime = defLightClock end
    if defLightAmbient ~= nil then Lighting.OutdoorAmbient = defLightAmbient end
    if defGlobalShadows ~= nil then Lighting.GlobalShadows = defGlobalShadows end
    if defFogEnd ~= nil then Lighting.FogEnd = defFogEnd end
    for _, e in pairs(Lighting:GetChildren()) do
        pcall(function()
            if e:IsA("BlurEffect") or e:IsA("SunRaysEffect") or e:IsA("ColorCorrectionEffect") or e:IsA("BloomEffect") or e:IsA("DepthOfFieldEffect") then
                e.Enabled = true
            end
        end)
    end
    if setAntiLagVisual then setAntiLagVisual(false) end
end

function applyStretchFOV(val)
    local cam = workspace.CurrentCamera
    if cam then pcall(function() cam.FieldOfView = val end) end
end

function enableStretch()
    if _G.Lust.Connections.stretch then return end
    _G.Lust.Active.stretch = true
    stretchEnabled = true
    local cam = workspace.CurrentCamera
    if not cam then return end
    origFOV = cam.FieldOfView or 70
    applyStretchFOV(120)
    _G.Lust.Connections.stretch = RunService.RenderStepped:Connect(function()
        if not stretchEnabled then
            _G.Lust.Connections.stretch:Disconnect()
            _G.Lust.Connections.stretch = nil
            return
        end
        local c = workspace.CurrentCamera
        if c then c.CFrame = c.CFrame * CFrame.new(0,0,0,1,0,0,0,0.7,0,0,0,1) end
    end)
    if _G.Lust.Connections.stretchFov then _G.Lust.Connections.stretchFov:Disconnect() end
    _G.Lust.Connections.stretchFov = RunService.RenderStepped:Connect(function()
        if stretchEnabled then applyStretchFOV(120)
        else _G.Lust.Connections.stretchFov:Disconnect(); _G.Lust.Connections.stretchFov = nil end
    end)
    if _G.stretchToggleSetter then _G.stretchToggleSetter(true) end
end

function disableStretch()
    _G.Lust.Active.stretch = false
    stretchEnabled = false
    if _G.Lust.Connections.stretch then
        _G.Lust.Connections.stretch:Disconnect()
        _G.Lust.Connections.stretch = nil
    end
    if _G.Lust.Connections.stretchFov then
        _G.Lust.Connections.stretchFov:Disconnect()
        _G.Lust.Connections.stretchFov = nil
    end
    local cam = workspace.CurrentCamera
    if cam then pcall(function() cam.FieldOfView = origFOV or 70 end) end
    if _G.stretchToggleSetter then _G.stretchToggleSetter(false) end
end

local function drag(f)
    local dn, ds, sp, di = false
    f.InputBegan:Connect(function(i)
        if uiLocked then return end
        if _isDraggingButton then return end
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dn = true; ds = i.Position; sp = f.Position
            i.Changed:Connect(function() if i.UserInputState == Enum.InputUserState.End then dn = false end end)
        end
    end)
    f.InputChanged:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then di = i end
    end)
    UIS.InputChanged:Connect(function(i)
        if i == di and dn then
            if uiLocked then dn = false; return end
            if _isDraggingButton then return end
            local nX = sp.X.Offset + (i.Position.X - ds.X)
            local nY = sp.Y.Offset + (i.Position.Y - ds.Y)
            f.Position = UDim2.new(sp.X.Scale, nX, sp.Y.Scale, nY)
        end
    end)
end

function setupMovementAndIndicators(char)
    if _G.Lust.Connections.movement then _G.Lust.Connections.movement:Disconnect(); _G.Lust.Connections.movement = nil end
    if _G.Lust.Connections.stepped then _G.Lust.Connections.stepped:Disconnect(); _G.Lust.Connections.stepped = nil end

    _G.Lust.Connections.stepped = RunService.Stepped:Connect(function()
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP and p.Character then
                for _, part in ipairs(p.Character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end
    end)

    _G.Lust.Connections.movement = RunService.RenderStepped:Connect(function()
        local char2 = LP.Character
        if not char2 then return end
        local hum = char2:FindFirstChildOfClass("Humanoid")
        local hrp = char2:FindFirstChild("HumanoidRootPart")
        if not hum or not hrp then return end

        if not autoBatEnabled and not bypassToggled and not autoLeftEnabled and not autoRightEnabled then
            local md = hum.MoveDirection
            local spd
            if laggerToggled then
                spd = (laggerLevel == 2) and LAGGER_SPEED_2 or LAGGER_SPEED_1
            else
                spd = speedMode and CS or NS
            end

            if md.Magnitude > 0 then
                lastMoveDir = md
                _speedLVSet(hrp, md.X * spd, md.Z * spd)
            elseif antiRagdollEnabled and lastMoveDir.Magnitude > 0 then
                local anyHeld = false
                for key in pairs(MOVE_KEYS) do
                    if UIS:IsKeyDown(key) then
                        anyHeld = true
                        break
                    end
                end
                if anyHeld then
                    _speedLVSet(hrp, lastMoveDir.X * spd, lastMoveDir.Z * spd)
                else
                    _speedLVClear(hrp)
                end
            else
                _speedLVClear(hrp)
            end
        end

        if speedLabel then
            local v = hrp.AssemblyLinearVelocity or hrp.Velocity
            local flatSpeed = math.sqrt(v.X * v.X + v.Z * v.Z)
            speedLabel.Text = "Speed: " .. string.format("%.1f", flatSpeed)
        end
    end)

    setupSpeedIndicator(char)
    startEnemySpeed()
end

function toggleLockUI(state)
    if state == nil then uiLocked = not uiLocked else uiLocked = state end
    if uiLocked and editModeEnabled then
        editModeEnabled = false
        if setEditModeVisual then setEditModeVisual(false) end
    end
    if setLockUIVisual then setLockUIVisual(uiLocked) end
end

function toggleEditMode(state)
    if state == nil then state = not editModeEnabled end
    if state and uiLocked then state = false end
    editModeEnabled = state
    if setEditModeVisual then setEditModeVisual(editModeEnabled) end
end

function disableAllAimbots()
    if autoBatEnabled then disableAutoBat() end
    if bypassToggled then toggleBypass(false) end
end

function stopAllBackgroundTasks()
    _G.Lust.StopAll()
    for _, t in ipairs(dropConnections) do
        if type(t) == "thread" then pcall(task.cancel, t)
        elseif type(t) == "RBXScriptConnection" then pcall(t.Disconnect, t) end
    end
    dropConnections = {}
    dropActive = false
    alPhase = 1
    arPhase = 1
    lastDropTime = 0
    medusaDebounce = false
    medusaLastUsed = 0
end

local BackgroundImages = {
    "rbxassetid://126860692354524",
    "rbxassetid://88369503310562",
    "rbxassetid://80708025126373",
    "rbxassetid://102253425322931",
    "rbxassetid://71300527482258",
}
local currentBgIndex = 1
local bgImageRef = nil
local bgImageCorner = nil

local function applyBackgroundImage(index)
    index = math.clamp(index or currentBgIndex, 1, #BackgroundImages)
    currentBgIndex = index
    local asset = BackgroundImages[index]
    if bgImageRef then
        bgImageRef.Image = asset
        bgImageRef.Visible = true
        bgImageRef.ImageTransparency = 0
        if not bgImageCorner then
            bgImageCorner = Instance.new("UICorner")
            bgImageCorner.CornerRadius = UDim.new(0, 18)
            bgImageCorner.Parent = bgImageRef
        end
    end
    saveAllSettings()
end

local function setupBackgroundImage()
    if bgImageRef then return end
    local bg = Instance.new("ImageLabel")
    bg.Name = "FORCEHUBBackgroundImage"
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.Position = UDim2.new(0, 0, 0, 0)
    bg.BackgroundTransparency = 1
    bg.Image = BackgroundImages[currentBgIndex] or ""
    bg.ImageTransparency = 0
    bg.ScaleType = Enum.ScaleType.Crop
    bg.ZIndex = 0
    bg.Parent = main
    bgImageCorner = Instance.new("UICorner")
    bgImageCorner.CornerRadius = UDim.new(0, 18)
    bgImageCorner.Parent = bg
    bgImageRef = bg
    bgImageRef.Visible = true
end

-- ============================================================
-- NUEVA FUNCIÃ“N buildConfigTable (con separaciÃ³n de keybinds)
-- ============================================================
function buildConfigTable()
    local config = {
        normalSpeed = NS,
        carrySpeed = CS,
        laggerSpeed1 = LAGGER_SPEED_1,
        laggerSpeed2 = LAGGER_SPEED_2,
        stealRadius = CONFIG.STEAL_RANGE,
        autoTPDownHeight = autoTPDownHeight,
        antiRagdoll = antiRagdollEnabled,
        autoSteal = CONFIG.AUTO_STEAL_ENABLED,
        jumpEnabled = jumpEnabled,
        medusaCounter = medusaCounterEnabled,
        batCounter = batCounterEnabled,
        laggerToggled = laggerToggled,
        laggerLevel = laggerLevel,
        carryMode = speedMode,
        batAimbotSpeed = BAT_AIMBOT_SPEED,
        bypassSpeed = BYPASS_AIMBOT_SPEED,
        dropMode = dropMode,
        stretchEnabled = stretchEnabled,
        uiScale = uiScaleValue,
        buttonScale = buttonScaleValue,
        skyTheme = currentSkyTheme,
        animPack = currentAnimPack,
        accessoryPack = currentAccessoryPack,
        espEnabled = espEnabled,
        antiLag = antiLagEnabled,
        mobileButtonPositions = savedButtonPositions,
        instaResetFloatingPos = instaResetFloatingPos,
        bypassFloatingPos = bypassFloatingPos,
        bodyLockEnabled = bodyLockEnabled,
        bodyLockRange = bodyLockRange,
        lockUI = uiLocked,
        editMode = editModeEnabled,
        backgroundIndex = currentBgIndex,
    }
    if pbFrame then
        config.progressBarPos = {
            XScale = pbFrame.Position.X.Scale,
            XOffset = pbFrame.Position.X.Offset,
            YScale = pbFrame.Position.Y.Scale,
            YOffset = pbFrame.Position.Y.Offset
        }
    end
    if MobilePanel and MobilePanel:FindFirstChild("FloatingPanel") then
        local container = MobilePanel:FindFirstChild("FloatingPanel")
        config.mobilePanelPos = {
            XScale = container.Position.X.Scale,
            XOffset = container.Position.X.Offset,
            YScale = container.Position.Y.Scale,
            YOffset = container.Position.Y.Offset
        }
    end
    return config
end

-- ============================================================
-- NUEVAS FUNCIONES saveAllSettings y loadAllSettings (robustas)
-- ============================================================
function saveAllSettings()
    if not canSaveConfig then return false end
    if _isResetting then return true end

    -- Construir configuraciÃ³n principal
    local config = buildConfigTable()

    -- Separar keybinds
    local keybinds = {}
    for k, v in pairs(KB) do
        keybinds[k] = {
            kb = v.kb and v.kb.Name,
            gp = v.gp and v.gp.Name
        }
    end
    -- Eliminar keybinds del config principal (no los guardamos en el mismo campo)
    local mainConfig = {}
    for k, v in pairs(config) do
        if k ~= "dropBrainrotKey" and k ~= "autoLeftKey" and k ~= "autoRightKey" and
           k ~= "autoBatKey" and k ~= "tpFloorKey" and k ~= "carryToggleKey" and
           k ~= "laggerModeKey" and k ~= "instaResetKey" and k ~= "bypassKey" then
            mainConfig[k] = v
        end
    end
    mainConfig.keybinds = keybinds

    local json = HS:JSONEncode(mainConfig)
    if json == _lastSavedJSON then return true end

    local success, err = pcall(function()
        _ace_writefile(CONFIG_FILE, json)
    end)
    if success then
        _lastSavedJSON = json
        print("[FORCEHUB] Config saved to " .. CONFIG_FILE)
        return true
    else
        warn("[FORCEHUB] Failed to save config: " .. tostring(err))
        return false
    end
end

function loadAllSettings()
    if not canSaveConfig then return false end
    if not _ace_isfile(CONFIG_FILE) then
        -- Crear archivo por defecto
        local defaultConfig = buildConfigTable()
        local keybinds = {}
        for k, v in pairs(KB) do
            keybinds[k] = {
                kb = v.kb and v.kb.Name,
                gp = v.gp and v.gp.Name
            }
        end
        local mainConfig = {}
        for k, v in pairs(defaultConfig) do
            if k ~= "dropBrainrotKey" and k ~= "autoLeftKey" and k ~= "autoRightKey" and
               k ~= "autoBatKey" and k ~= "tpFloorKey" and k ~= "carryToggleKey" and
               k ~= "laggerModeKey" and k ~= "instaResetKey" and k ~= "bypassKey" then
                mainConfig[k] = v
            end
        end
        mainConfig.keybinds = keybinds
        local defaultJson = HS:JSONEncode(mainConfig)
        pcall(function() _ace_writefile(CONFIG_FILE, defaultJson) end)
        _lastSavedJSON = defaultJson
        print("[FORCEHUB] Created default config file.")
        return false
    end

    local success, data = pcall(function()
        return HS:JSONDecode(_ace_readfile(CONFIG_FILE))
    end)
    if not success or type(data) ~= "table" then
        warn("[FORCEHUB] Failed to load config, using defaults.")
        return false
    end

    _isLoading = true

    -- Cargar keybinds
    local keybinds = data.keybinds or {}
    for keyId, val in pairs(keybinds) do
        if KB[keyId] then
            KB[keyId].kb = val.kb and Enum.KeyCode[val.kb] or nil
            KB[keyId].gp = val.gp and Enum.KeyCode[val.gp] or nil
        end
    end

    -- Cargar el resto de variables
    NS = data.normalSpeed or NS
    CS = data.carrySpeed or CS
    LAGGER_SPEED_1 = data.laggerSpeed1 or LAGGER_SPEED_1
    LAGGER_SPEED_2 = data.laggerSpeed2 or LAGGER_SPEED_2
    CONFIG.STEAL_RANGE = data.stealRadius or CONFIG.STEAL_RANGE
    autoTPDownHeight = data.autoTPDownHeight or 20
    uiLocked = data.lockUI or false
    editModeEnabled = data.editMode or false
    antiRagdollEnabled = data.antiRagdoll or false
    CONFIG.AUTO_STEAL_ENABLED = data.autoSteal or false
    jumpEnabled = data.jumpEnabled or false
    medusaCounterEnabled = data.medusaCounter or false
    batCounterEnabled = data.batCounter or false
    antiLagEnabled = data.antiLag or false
    laggerToggled = data.laggerToggled or false
    speedMode = data.carryMode or false
    laggerLevel = data.laggerLevel or 1
    uiScaleValue = data.uiScale or 100
    buttonScaleValue = data.buttonScale or 1.0
    espEnabled = data.espEnabled or false
    stretchEnabled = data.stretchEnabled or false
    BAT_AIMBOT_SPEED = data.batAimbotSpeed or BAT_AIMBOT_SPEED
    BYPASS_AIMBOT_SPEED = data.bypassSpeed or BYPASS_AIMBOT_SPEED
    dropMode = data.dropMode or 1
    bodyLockEnabled = data.bodyLockEnabled or false
    bodyLockRange = data.bodyLockRange or 20
    currentSkyTheme = data.skyTheme or "Off"
    currentAnimPack = data.animPack or "Off"
    currentAccessoryPack = data.accessoryPack or "Off"
    currentBgIndex = data.backgroundIndex or 1

    -- Posiciones flotantes
    if data.instaResetFloatingPos then instaResetFloatingPos = data.instaResetFloatingPos end
    if data.bypassFloatingPos then bypassFloatingPos = data.bypassFloatingPos end
    if data.progressBarPos then savedProgressBarPos = data.progressBarPos end
    if data.mobileButtonPositions then savedButtonPositions = data.mobileButtonPositions end
    if data.mobilePanelPos then savedMobilePanelPos = data.mobilePanelPos end

    _lastSavedJSON = HS:JSONEncode(buildConfigTable())
    _isLoading = false
    print("[FORCEHUB] Config loaded successfully from " .. CONFIG_FILE)
    return true
end

function forceResetUI()
    if normalBox then normalBox.Text = tostring(NS) end
    if carryBox then carryBox.Text = tostring(CS) end
    if radInput then radInput.Text = tostring(CONFIG.STEAL_RANGE) end
    if laggerBox then laggerBox.Text = tostring(LAGGER_SPEED_1) end
    if lagger2Box then lagger2Box.Text = tostring(LAGGER_SPEED_2) end
    if autoTPHeightBox then autoTPHeightBox.Text = tostring(autoTPDownHeight) end
    if uiScaleBox then uiScaleBox.Text = tostring(uiScaleValue) end
    if _G.uiScaleValueLabel then _G.uiScaleValueLabel.Text = string.format("%.2f", uiScaleValue / 100) end
    if _G.buttonScaleValueLabel then _G.buttonScaleValueLabel.Text = string.format("%.2f", buttonScaleValue) end
    applyButtonScale(buttonScaleValue)
    if dropModeBtnRef then dropModeBtnRef.Text = dropMode == 1 and "Fling" or "Jump Drop" end
    if bodyLockRangeBox then bodyLockRangeBox.Text = tostring(bodyLockRange) end

    local function safeSet(fn, val) if fn then fn(val) end end
    safeSet(autoBatSetVisual, false)
    safeSet(autoLeftSetVisual, false)
    safeSet(autoRightSetVisual, false)
    safeSet(setBatCounterVisual, false)
    safeSet(setMedusaVisual, false)
    safeSet(setAntiRagVisual, false)
    safeSet(setJumpVisual, false)
    safeSet(setAntiLagVisual, false)
    safeSet(setAutoTPDownVisual, false)
    safeSet(setLockUIVisual, false)
    safeSet(setEditModeVisual, false)
    safeSet(setInstaGrab, false)
    safeSet(bypassSetVisual, false)
    safeSet(setESPVIsual, false)
    safeSet(bodyLockSetVisual, false)
    if _G.stretchToggleSetter then _G.stretchToggleSetter(false) end

    safeSet(mobSetAutoBat, false)
    safeSet(mobSetAutoLeft, false)
    safeSet(mobSetAutoRight, false)
    safeSet(mobSetDropBR, false)
    safeSet(mobSetTpDown, false)
    safeSet(mobSetCarry, false)
    safeSet(mobSetLagger1, false)
    safeSet(mobSetLagger2, false)

    if setJumpToggleState then setJumpToggleState(false) end
    refreshSpeedModeLabel()
    updateProgressBarVisibility()
    setSkyTheme("Off")
    disableAntiLag()

    for _, ref in ipairs(keyButtonRefs) do
        local entry = ref.entry
        local label = (entry.gp and entry.gp.Name) or (entry.kb and entry.kb.Name) or "None"
        ref.btn.Text = label
    end

    if accSelectorLabel then accSelectorLabel.Text = "Off" end
    currentAccessoryPack = "Off"
    clearAllAccessories(LP.Character)
end

function resetFloatingPositions()
    if MobilePanel and MobilePanel:FindFirstChild("FloatingPanel") then
        local container = MobilePanel:FindFirstChild("FloatingPanel")
        container.Position = UDim2.new(1, -MOBILE_PANEL_WIDTH - 10, 0, 0)
        savedButtonPositions = {}
        if container:FindFirstChild("ButtonsContainer") then
            for _, btn in ipairs(container.ButtonsContainer:GetChildren()) do
                if btn:IsA("TextButton") and btn.Name then
                    local defX, defY = getDefaultButtonPosition(btn.Name)
                    btn.Position = UDim2.new(0, defX, 0, defY)
                end
            end
        end
    end
    if instaResetFloatingButton and instaResetFloatingButton:FindFirstChild("Frame") then
        local btnFrame = instaResetFloatingButton:FindFirstChild("Frame")
        btnFrame.Position = UDim2.new(1, -MOBILE_PANEL_WIDTH - 10, 0, MOBILE_PANEL_HEIGHT + 10)
        instaResetFloatingPos = nil
    end
    if bypassFloatingButton and bypassFloatingButton:FindFirstChild("Frame") then
        local btnFrame = bypassFloatingButton:FindFirstChild("Frame")
        btnFrame.Position = UDim2.new(1, -10 - 60, 0, MOBILE_PANEL_HEIGHT + 10)
        bypassFloatingPos = nil
    end
    if pbFrame then
        pbFrame.Position = UDim2.new(0.5, -150, 1, -50)
        savedProgressBarPos = nil
    end
    savedMobilePanelPos = nil
    instaResetFloatingPos = nil
    bypassFloatingPos = nil
end

function resetToFactoryDefaults()
    _isResetting = true

    stopAllBackgroundTasks()
    stopAutoSteal()
    stopAutoTPDown()
    stopBatCounter()
    stopMedusaCounter()
    stopAntiRagdoll()
    stopJumpMode()
    disableAutoBat()
    toggleBypass(false)
    stopBodyLock()
    if espEnabled then toggleESP(false) end
    if stretchEnabled then disableStretch() end
    if antiLagEnabled then disableAntiLag() end
    if dropActive then stopDropBrainrot() end

    NS = 59.5
    CS = 28.8
    LAGGER_SPEED_1 = 29
    LAGGER_SPEED_2 = 15
    CONFIG.STEAL_RANGE = 61
    autoTPDownHeight = 20
    speedMode = false
    laggerToggled = false
    laggerLevel = 1
    antiRagdollEnabled = false
    jumpEnabled = false
    medusaCounterEnabled = false
    batCounterEnabled = false
    autoBatEnabled = false
    autoLeftEnabled = false
    autoRightEnabled = false
    antiLagEnabled = false
    autoTPDownEnabled = false
    uiLocked = false
    editModeEnabled = false
    CONFIG.AUTO_STEAL_ENABLED = false
    BAT_AIMBOT_SPEED = 58
    BYPASS_AIMBOT_SPEED = 58
    bypassToggled = false
    dropMode = 1
    stretchEnabled = false
    uiScaleValue = 100
    if mainUIScale then mainUIScale.Scale = 1 end
    if pbScale then pbScale.Scale = 1 end
    buttonScaleValue = 1.0
    applyButtonScale(1.0)
    espEnabled = false
    bodyLockEnabled = false
    bodyLockRange = 20

    currentAnimPack = "Off"
    stopAnimPack()

    currentAccessoryPack = "Off"
    clearAllAccessories(LP.Character)
    if accSelectorLabel then accSelectorLabel.Text = "Off" end

    for key, val in pairs(DEFAULT_KB) do
        if KB[key] then
            KB[key].kb = val.kb
            KB[key].gp = val.gp
        end
    end

    if isfile and isfile(CONFIG_FILE) then
        pcall(delfile, CONFIG_FILE)
    end

    resetFloatingPositions()
    forceResetUI()
    setSkyTheme("Off")
    updateProgressBarVisibility()
    refreshSpeedModeLabel()
    currentBgIndex = 1
    applyBackgroundImage(1)

    _lastSavedJSON = nil
    saveAllSettings()

    if LP.Character then
        setupMovementAndIndicators(LP.Character)
    end

    _isResetting = false
end

function updateProgressBarVisibility()
    if pbFrame then pbFrame.Visible = CONFIG.AUTO_STEAL_ENABLED end
end

function applyShimmerToText(obj, speed)
    speed = speed or 0.8
    local grad = Instance.new("UIGradient", obj)
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(80,80,80)),
        ColorSequenceKeypoint.new(0.3, Color3.fromRGB(200,200,200)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255,255,255)),
        ColorSequenceKeypoint.new(0.7, Color3.fromRGB(200,200,200)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(80,80,80))
    })
    grad.Rotation = 45
    grad.Offset = Vector2.new(0,0)
    task.spawn(function()
        local t = 0
        while grad and grad.Parent do
            t = t + 0.02
            grad.Offset = Vector2.new(math.sin(t * speed) * 0.4, 0)
            task.wait(0.04)
        end
    end)
    return grad
end

function getDefaultButtonPosition(btnName)
    local BTN_W, BTN_H = 60, 60
    local GAP = 8
    local orderMap = {
        DropBR = 0, AutoLeft = 1, AutoBat = 2, AutoRight = 3,
        TpDown = 4, Carry = 5, Lagger1 = 6, Lagger2 = 7
    }
    local order = orderMap[btnName] or 0
    local row = math.floor(order / 2)
    local col = order % 2
    return col * (BTN_W + GAP), row * (BTN_H + GAP + 10)
end

-- ============================================================
-- CONSTRUCCIÃ“N DE LA GUI (buildGui) - igual que antes
-- ============================================================
function buildGui()
    local SILVER = Color3.fromRGB(180, 180, 190)
    local BG = Color3.fromRGB(0, 0, 0)
    local BG2 = Color3.fromRGB(6, 6, 9)
    local ROW_BG = Color3.fromRGB(6, 6, 9)
    local ROW_BORDER = Color3.fromRGB(90, 90, 105)
    local WHITE = Color3.fromRGB(255, 255, 255)
    local GRAY = Color3.fromRGB(180, 180, 190)
    local INP = Color3.fromRGB(5, 5, 8)
    local TAB_ACTIVE = Color3.fromRGB(255, 255, 255)
    local TAB_INACT = Color3.fromRGB(170, 170, 180)
    local SECT_LBL = Color3.fromRGB(245, 245, 255)
    local TOGGLE_BG = Color3.fromRGB(18, 18, 26)
    local KNOB = Color3.fromRGB(238, 238, 245)
    local TRACK_ACTIVE = Color3.fromRGB(36, 36, 46)

    local GUI_W, GUI_H = 340, 430

    local old = game:GetService("CoreGui"):FindFirstChild("FORCEHUB")
    if old then old:Destroy() end
    local pg = LP:FindFirstChild("PlayerGui")
    if pg then local o = pg:FindFirstChild("FORCEHUB"); if o then o:Destroy() end end

    gui = Instance.new("ScreenGui")
    gui.Name = "FORCEHUB"
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 10
    gui.IgnoreGuiInset = true
    pcall(function() if syn and syn.protect_gui then syn.protect_gui(gui) end end)
    if not pcall(function() gui.Parent = game:GetService("CoreGui") end) then
        gui.Parent = LP:WaitForChild("PlayerGui")
    end

    main = Instance.new("Frame", gui)
    main.Size = UDim2.new(0, GUI_W, 0, GUI_H)
    main.Position = UDim2.new(0, 20, 0, 2)
    main.BackgroundColor3 = BG
    main.BackgroundTransparency = 1
    main.BorderSizePixel = 0
    main.ClipsDescendants = true
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 18)

    mainUIScale = Instance.new("UIScale", main)
    mainUIScale.Scale = uiScaleValue / 100

    setupBackgroundImage()
    applyBackgroundImage(currentBgIndex)

    local shadow = Instance.new("Frame", main)
    shadow.Size = UDim2.new(1, 12, 1, 12)
    shadow.Position = UDim2.new(0, -6, 0, 6)
    shadow.BackgroundColor3 = Color3.fromRGB(0,0,0)
    shadow.BackgroundTransparency = 0.9
    shadow.BorderSizePixel = 0
    shadow.ZIndex = 2
    Instance.new("UICorner", shadow).CornerRadius = UDim.new(0, 22)

    local titleLabel = Instance.new("TextLabel", main)
    titleLabel.Size = UDim2.new(1, -80, 0, 44)
    titleLabel.Position = UDim2.new(0, 16, 0, 4)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "FORCE HUB"
    titleLabel.TextColor3 = WHITE
    titleLabel.Font = Enum.Font.GothamBlack
    titleLabel.TextSize = 26
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextStrokeColor3 = Color3.fromRGB(40,40,40)
    titleLabel.TextStrokeTransparency = 0.2
    titleLabel.ZIndex = 20
    local grad = Instance.new("UIGradient", titleLabel)
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, WHITE),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(200,200,200)),
        ColorSequenceKeypoint.new(1, WHITE)
    })
    grad.Rotation = 15

    local closeBtn = Instance.new("TextButton", main)
    closeBtn.Size = UDim2.new(0, 34, 0, 34)
    closeBtn.Position = UDim2.new(1, -44, 0, 6)
    closeBtn.BackgroundColor3 = Color3.fromRGB(0,0,0)
    closeBtn.BackgroundTransparency = 1
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "âˆ’"
    closeBtn.TextColor3 = WHITE
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 26
    closeBtn.AutoButtonColor = false
    closeBtn.ZIndex = 200
    closeBtn.MouseEnter:Connect(function()
        closeBtn.TextColor3 = GRAY
    end)
    closeBtn.MouseLeave:Connect(function()
        closeBtn.TextColor3 = WHITE
    end)

    miniBtn = Instance.new("TextButton", gui)
    miniBtn.Size = UDim2.new(0, 118, 0, 30)
    miniBtn.Position = UDim2.new(0, 16, 0, 58)
    miniBtn.BackgroundColor3 = BG2
    miniBtn.BackgroundTransparency = 0
    miniBtn.BorderSizePixel = 0
    miniBtn.Text = "FORCE HUB"
    miniBtn.TextColor3 = WHITE
    miniBtn.Font = Enum.Font.GothamBold
    miniBtn.TextSize = 12
    miniBtn.ZIndex = 20
    miniBtn.Visible = false
    Instance.new("UICorner", miniBtn).CornerRadius = UDim.new(0, 8)
    applyShimmerToText(miniBtn, 0.9)

    local animating = false
    local function animateShow()
        if animating then return end
        animating = true
        main.Visible = true
        main.Size = UDim2.new(0, GUI_W, 0, GUI_H)
        main.Position = UDim2.new(1, 20, 0, 2)
        TS:Create(main, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = UDim2.new(0, 20, 0, 2)
        }):Play()
        miniBtn.Visible = false
        task.delay(0.5, function() animating = false end)
    end

    local function animateHide()
        if animating then return end
        animating = true
        TS:Create(main, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = UDim2.new(1, 20, 0, 2)
        }):Play()
        task.delay(0.35, function()
            main.Visible = false
            main.Position = UDim2.new(0, 20, 0, 2)
            miniBtn.Visible = true
            animating = false
        end)
    end

    showGui = function()
        if main.Visible then return end
        animateShow()
    end
    hideGui = function()
        if not main.Visible then return end
        animateHide()
    end

    closeBtn.MouseButton1Click:Connect(hideGui)
    miniBtn.MouseButton1Click:Connect(showGui)

    local tabBar = Instance.new("Frame", main)
    tabBar.Size = UDim2.new(1, -24, 0, 36)
    tabBar.Position = UDim2.new(0, 12, 0, 50)
    tabBar.BackgroundTransparency = 1
    tabBar.ZIndex = 10

    local tabs = {"Moment", "Combat", "Main", "Keybinds"}
    local tabButtons = {}
    local tabContent = Instance.new("Frame", main)
    tabContent.Size = UDim2.new(1, -14, 1, -100)
    tabContent.Position = UDim2.new(0, 7, 0, 90)
    tabContent.BackgroundTransparency = 1
    tabContent.ClipsDescendants = true
    tabContent.ZIndex = 5

    local contentPages = {}

    for i, name in ipairs(tabs) do
        local btn = Instance.new("TextButton", tabBar)
        btn.Size = UDim2.new(1 / #tabs, -4, 1, 0)
        btn.Position = UDim2.new((i-1)/#tabs, 2, 0, 0)
        btn.BackgroundColor3 = Color3.fromRGB(0,0,0)
        btn.BackgroundTransparency = 0.5
        btn.BorderSizePixel = 0
        btn.Text = name
        btn.TextColor3 = TAB_INACT
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 13
        btn.AutoButtonColor = false
        btn.ZIndex = 11
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        local stroke = Instance.new("UIStroke", btn)
        stroke.Color = ROW_BORDER
        stroke.Thickness = 1

        local page = Instance.new("ScrollingFrame", tabContent)
        page.Size = UDim2.new(1, 0, 1, 0)
        page.Position = UDim2.new(0, 0, 0, 0)
        page.BackgroundColor3 = Color3.fromRGB(5,5,5)
        page.BackgroundTransparency = 0.6
        page.BorderSizePixel = 0
        page.ClipsDescendants = true
        page.ScrollBarThickness = 0
        page.ScrollBarImageTransparency = 1
        page.CanvasSize = UDim2.new(0, 0, 0, 0)
        page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        page.ScrollingDirection = Enum.ScrollingDirection.Y
        page.ZIndex = 6
        Instance.new("UICorner", page).CornerRadius = UDim.new(0, 16)
        page.Visible = (i == 1)

        local layout = Instance.new("UIListLayout", page)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 4)
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

        local padding = Instance.new("UIPadding", page)
        padding.PaddingLeft = UDim.new(0, 8)
        padding.PaddingRight = UDim.new(0, 8)
        padding.PaddingTop = UDim.new(0, 4)
        padding.PaddingBottom = UDim.new(0, 8)

        contentPages[name] = page

        btn.MouseButton1Click:Connect(function()
            for _, pg in pairs(contentPages) do pg.Visible = false end
            page.Visible = true
            for _, b in ipairs(tabButtons) do
                b.TextColor3 = TAB_INACT
                b.BackgroundColor3 = Color3.fromRGB(0,0,0)
            end
            btn.TextColor3 = TAB_ACTIVE
            btn.BackgroundColor3 = Color3.fromRGB(20,20,20)
        end)

        table.insert(tabButtons, btn)
    end

    if tabButtons[1] then
        tabButtons[1].TextColor3 = TAB_ACTIVE
        tabButtons[1].BackgroundColor3 = Color3.fromRGB(20,20,20)
    end

    local pageCounters = {}

    local function getNextOrder(page)
        if not pageCounters[page] then pageCounters[page] = 0 end
        pageCounters[page] = pageCounters[page] + 1
        return pageCounters[page]
    end

    local function mkSect(page, txt)
        local f = Instance.new("Frame", page)
        f.Size = UDim2.new(1, 0, 0, 24)
        f.BackgroundTransparency = 1
        f.BorderSizePixel = 0
        f.LayoutOrder = getNextOrder(page)
        f.ZIndex = 7
        local l = Instance.new("TextLabel", f)
        l.Size = UDim2.new(1, -16, 1, 0)
        l.Position = UDim2.new(0, 8, 0, 0)
        l.BackgroundTransparency = 1
        l.Text = txt:upper()
        l.TextColor3 = SECT_LBL
        l.Font = Enum.Font.GothamBlack
        l.TextSize = 11
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.TextStrokeColor3 = Color3.fromRGB(60,60,60)
        l.TextStrokeTransparency = 0.3
        l.ZIndex = 8
        return f
    end

    local function mkRow(page, h)
        h = h or 30
        local f = Instance.new("Frame", page)
        f.Size = UDim2.new(1, -4, 0, h)
        f.BackgroundColor3 = ROW_BG
        f.BackgroundTransparency = 0.6
        f.BorderSizePixel = 0
        f.LayoutOrder = getNextOrder(page)
        f.ZIndex = 7
        Instance.new("UICorner", f).CornerRadius = UDim.new(0, 10)
        local rowStroke = Instance.new("UIStroke", f)
        rowStroke.Color = ROW_BORDER
        rowStroke.Thickness = 1
        rowStroke.Transparency = 0.4
        f.MouseEnter:Connect(function()
            f.BackgroundColor3 = Color3.fromRGB(12,12,18)
        end)
        f.MouseLeave:Connect(function()
            f.BackgroundColor3 = ROW_BG
        end)
        return f
    end

    local function mkLabel(row, txt)
        local l = Instance.new("TextLabel", row)
        l.Size = UDim2.new(0.55, 0, 1, 0)
        l.Position = UDim2.new(0, 10, 0, 0)
        l.BackgroundTransparency = 1
        l.Text = txt
        l.TextColor3 = WHITE
        l.Font = Enum.Font.GothamBlack
        l.TextSize = 11
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.TextTruncate = Enum.TextTruncate.AtEnd
        l.TextStrokeColor3 = Color3.fromRGB(0,0,0)
        l.TextStrokeTransparency = 0.5
        l.ZIndex = 8
        return l
    end

    local function mkPill(row, offset)
        local pill = Instance.new("Frame", row)
        pill.Size = UDim2.new(0, 34, 0, 18)
        pill.Position = UDim2.new(1, -(offset or 44), 0.5, -9)
        pill.BackgroundColor3 = TOGGLE_BG
        pill.BorderSizePixel = 0
        pill.ZIndex = 8
        Instance.new("UICorner", pill).CornerRadius = UDim.new(1, 0)
        local stroke = Instance.new("UIStroke", pill)
        stroke.Color = ROW_BORDER
        stroke.Thickness = 1.2
        stroke.Transparency = 0.6
        local dot = Instance.new("Frame", pill)
        dot.Size = UDim2.new(0, 13, 0, 13)
        dot.Position = UDim2.new(0, 3, 0.5, -6.5)
        dot.BackgroundColor3 = KNOB
        dot.BorderSizePixel = 0
        dot.ZIndex = 9
        Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
        return pill, dot
    end

    local function animPill(pill, dot, on)
        TS:Create(pill, TweenInfo.new(0.08, Enum.EasingStyle.Quad), {
            BackgroundColor3 = on and TRACK_ACTIVE or TOGGLE_BG
        }):Play()
        TS:Create(dot, TweenInfo.new(0.08, Enum.EasingStyle.Quad), {
            Position = on and UDim2.new(1, -17, 0.5, -6.5) or UDim2.new(0, 3, 0.5, -6.5),
            BackgroundColor3 = on and Color3.fromRGB(255,255,255) or KNOB
        }):Play()
        local stroke = pill:FindFirstChildOfClass("UIStroke")
        if stroke then
            TS:Create(stroke, TweenInfo.new(0.08, Enum.EasingStyle.Quad), {
                Color = on and WHITE or ROW_BORDER,
                Transparency = on and 0 or 0.6
            }):Play()
        end
    end

    local function mkToggle(page, txt, cb)
        local row = mkRow(page, 34)
        mkLabel(row, txt)
        local pill, dot = mkPill(row, 44)
        local on = false
        local function sv(s) on = s; animPill(pill, dot, s) end
        local clk = Instance.new("TextButton", pill)
        clk.Size = UDim2.new(1,0,1,0)
        clk.BackgroundTransparency = 1
        clk.Text = ""
        clk.AutoButtonColor = false
        clk.ZIndex = 10
        clk.MouseButton1Click:Connect(function()
            if editModeEnabled and not uiLocked then
                pcall(cb, not on)
            else
                on = not on
                sv(on)
                pcall(cb, on)
            end
        end)
        return sv
    end

    local function mkSelector(parent, default, options, cb)
        local container = Instance.new("Frame", parent)
        container.Size = UDim2.new(0, 160, 1, 0)
        container.Position = UDim2.new(1, -170, 0, 0)
        container.BackgroundTransparency = 1
        container.ZIndex = 8

        local btn = Instance.new("TextButton", container)
        local textWidth = 120
        btn.Size = UDim2.new(0, textWidth, 0, 24)
        btn.Position = UDim2.new(0.5, -textWidth/2, 0.5, -12)
        btn.BackgroundColor3 = INP
        btn.BackgroundTransparency = 0.3
        btn.BorderSizePixel = 0
        btn.Text = default
        btn.TextColor3 = WHITE
        btn.Font = Enum.Font.GothamBlack
        btn.TextSize = 11
        btn.TextXAlignment = Enum.TextXAlignment.Center
        btn.AutoButtonColor = false
        btn.ZIndex = 9
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        local stroke = Instance.new("UIStroke", btn)
        stroke.Color = ROW_BORDER
        stroke.Thickness = 1.2
        stroke.Transparency = 0.3

        local arrow = Instance.new("TextLabel", btn)
        arrow.Size = UDim2.new(0, 20, 1, 0)
        arrow.Position = UDim2.new(1, -24, 0, 0)
        arrow.BackgroundTransparency = 1
        arrow.Text = "â–¼"
        arrow.TextColor3 = GRAY
        arrow.Font = Enum.Font.GothamBlack
        arrow.TextSize = 12
        arrow.TextXAlignment = Enum.TextXAlignment.Center
        arrow.ZIndex = 10

        btn.MouseEnter:Connect(function()
            btn.BackgroundColor3 = Color3.fromRGB(12,12,18)
            stroke.Color = WHITE
            stroke.Transparency = 0.1
        end)
        btn.MouseLeave:Connect(function()
            btn.BackgroundColor3 = INP
            stroke.Color = ROW_BORDER
            stroke.Transparency = 0.3
        end)

        local function updateBtn(newText)
            btn.Text = newText
            if newText == default then
                TS:Create(btn, TweenInfo.new(0.05, Enum.EasingStyle.Quad), {
                    BackgroundColor3 = INP,
                    TextColor3 = WHITE
                }):Play()
                TS:Create(stroke, TweenInfo.new(0.05, Enum.EasingStyle.Quad), {
                    Color = ROW_BORDER,
                    Transparency = 0.3
                }):Play()
            else
                TS:Create(btn, TweenInfo.new(0.05, Enum.EasingStyle.Quad), {
                    BackgroundColor3 = TRACK_ACTIVE,
                    TextColor3 = WHITE
                }):Play()
                TS:Create(stroke, TweenInfo.new(0.05, Enum.EasingStyle.Quad), {
                    Color = WHITE,
                    Transparency = 0
                }):Play()
            end
        end

        btn.MouseButton1Click:Connect(function()
            if cb then cb(btn) end
        end)

        return btn
    end

    local function mkBox(parent, default, w, xOff, cb)
        local tb = Instance.new("TextBox", parent)
        local bw = w or 50
        local xo = math.max(xOff or 56, bw + 12)
        tb.Size = UDim2.new(0, bw, 0, 22)
        tb.Position = UDim2.new(1, -xo, 0.5, -11)
        tb.BackgroundColor3 = INP
        tb.BackgroundTransparency = 0.7
        tb.BorderSizePixel = 0
        tb.Text = tostring(default)
        tb.TextColor3 = WHITE
        tb.Font = Enum.Font.GothamBlack
        tb.TextSize = 11
        tb.ClearTextOnFocus = false
        tb.ZIndex = 8
        Instance.new("UICorner", tb).CornerRadius = UDim.new(0, 6)
        local bs = Instance.new("UIStroke", tb)
        bs.Color = ROW_BORDER
        bs.Thickness = 1.2
        bs.Transparency = 0.25
        tb.Focused:Connect(function() bs.Color = WHITE; bs.Transparency = 0 end)
        tb.FocusLost:Connect(function()
            bs.Color = ROW_BORDER
            bs.Transparency = 0.25
            if cb then local n = tonumber(tb.Text); if n then cb(n) else tb.Text = tostring(default) end end
        end)
        return tb
    end

    local function mkKeyButton(parent, kbEntry)
        local btn = Instance.new("TextButton", parent)
        btn.Size = UDim2.new(0, 80, 0, 22)
        btn.Position = UDim2.new(1, -88, 0.5, -11)
        btn.BackgroundColor3 = INP
        btn.BackgroundTransparency = 0.5
        btn.BorderSizePixel = 0
        local function getLabel() return (kbEntry.gp and kbEntry.gp.Name) or (kbEntry.kb and kbEntry.kb.Name) or "None" end
        btn.Text = getLabel()
        btn.TextColor3 = WHITE
        btn.Font = Enum.Font.GothamBlack
        btn.TextSize = 9
        btn.ZIndex = 8
        btn.AutoButtonColor = false
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        local bs = Instance.new("UIStroke", btn)
        bs.Color = ROW_BORDER
        bs.Thickness = 1
        local li = false; local lc; local pv = btn.Text; local listenStart = 0
        btn.Activated:Connect(function()
            if li then li = false; _anyKeyListening = false; if lc then lc:Disconnect(); lc = nil end; btn.Text = pv; btn.TextColor3 = WHITE; return end
            pv = btn.Text; li = true; _anyKeyListening = true; listenStart = tick(); btn.Text = "..."; btn.TextColor3 = WHITE
            lc = UIS.InputBegan:Connect(function(inp)
                if not li then return end
                if inp.KeyCode == Enum.KeyCode.Escape then li = false; _anyKeyListening = false; if lc then lc:Disconnect(); lc = nil end; btn.Text = pv; btn.TextColor3 = WHITE; return end
                local isGp = isGamepadInput(inp)
                if isGp and tick()-listenStart < 0.15 then return end
                if not isBindableInput(inp) then return end
                btn.Text = inp.KeyCode.Name; pv = inp.KeyCode.Name; btn.TextColor3 = WHITE
                li = false; _anyKeyListening = false; if lc then lc:Disconnect(); lc = nil end
                if isGp then kbEntry.gp = inp.KeyCode; kbEntry.kb = nil else kbEntry.kb = inp.KeyCode; kbEntry.gp = nil end
            end)
        end)
        table.insert(keyButtonRefs, {btn = btn, entry = kbEntry})
        return btn
    end

    local function addKeybindRow(page, labelText, kbEntry)
        local row = mkRow(page, 34)
        mkLabel(row, labelText)
        mkKeyButton(row, kbEntry)
    end

    local momentPage = contentPages["Moment"]

    mkSect(momentPage, "Speed")
    do local row = mkRow(momentPage, 30); mkLabel(row, "Normal Speed"); normalBox = mkBox(row, NS, 50, 56, function(v) if v > 0 and v <= 500 then NS = v end; saveAllSettings() end) end
    do local row = mkRow(momentPage, 30); mkLabel(row, "Carry Speed"); carryBox = mkBox(row, CS, 50, 56, function(v) if v > 0 and v <= 500 then CS = v end; saveAllSettings() end) end
    do local row = mkRow(momentPage, 30); mkLabel(row, "Lagger 1 Speed"); laggerBox = mkBox(row, LAGGER_SPEED_1, 50, 56, function(v) if v > 0 and v <= 500 then LAGGER_SPEED_1 = v end; saveAllSettings() end) end
    do local row = mkRow(momentPage, 30); mkLabel(row, "Lagger 2 Speed"); lagger2Box = mkBox(row, LAGGER_SPEED_2, 50, 56, function(v) if v > 0 and v <= 500 then LAGGER_SPEED_2 = v end; saveAllSettings() end) end
    do
        local row = mkRow(momentPage, 30)
        mkLabel(row, "Current Mode")
        modeValLbl = Instance.new("TextLabel", row)
        modeValLbl.Size = UDim2.new(0, 110, 1, 0)
        modeValLbl.Position = UDim2.new(1, -118, 0, 0)
        modeValLbl.BackgroundTransparency = 1
        modeValLbl.Text = "Normal"
        modeValLbl.TextColor3 = GRAY
        modeValLbl.Font = Enum.Font.GothamBlack
        modeValLbl.TextSize = 11
        modeValLbl.TextXAlignment = Enum.TextXAlignment.Right
        modeValLbl.ZIndex = 8
        local clk = Instance.new("TextButton", row)
        clk.Size = UDim2.new(1,0,1,0)
        clk.BackgroundTransparency = 1
        clk.Text = ""
        clk.AutoButtonColor = false
        clk.ZIndex = 8
        clk.MouseButton1Click:Connect(function() toggleCarryMode(); saveAllSettings() end)
    end

    mkSect(momentPage, "Jump & Movement")
    do
        local row = mkRow(momentPage, 30)
        mkLabel(row, "Infinite Jump")
        local jumpPill, jumpDot = mkPill(row, 44)
        local jumpOn = false
        setJumpToggleState = function(state)
            if jumpOn == state then return end
            jumpOn = state
            animPill(jumpPill, jumpDot, state)
            if state then startJumpMode() else stopJumpMode() end
            saveAllSettings()
        end
        local jumpClk = Instance.new("TextButton", jumpPill)
        jumpClk.Size = UDim2.new(1,0,1,0)
        jumpClk.BackgroundTransparency = 1
        jumpClk.Text = ""
        jumpClk.AutoButtonColor = false
        jumpClk.ZIndex = 10
        jumpClk.MouseButton1Click:Connect(function()
            if editModeEnabled and not uiLocked then
                if jumpOn then stopJumpMode() else startJumpMode() end
            else
                setJumpToggleState(not jumpOn)
            end
        end)
        setJumpVisual = function(state) setJumpToggleState(state) end
    end

    autoLeftSetVisual = mkToggle(momentPage, "Auto Left", function(on)
        autoLeftEnabled = on
        if on then startAutoLeft() else stopAutoLeft() end
        if mobSetAutoLeft then mobSetAutoLeft(on) end
        saveAllSettings()
    end)

    autoRightSetVisual = mkToggle(momentPage, "Auto Right", function(on)
        autoRightEnabled = on
        if on then startAutoRight() else stopAutoRight() end
        if mobSetAutoRight then mobSetAutoRight(on) end
        saveAllSettings()
    end)

    mkSect(momentPage, "Drop & TP")
    dropBrainrotSetVisual = mkToggle(momentPage, "Drop Brainrot", function(on)
        if on then
            executeDropWithToggle(function(v)
                dropBrainrotSetVisual(v)
                if mobSetDropBR then mobSetDropBR(v) end
            end)
        end
    end)

    do
        local row = mkRow(momentPage, 30)
        mkLabel(row, "Drop Mode")
        dropModeBtnRef = mkSelector(row, dropMode == 1 and "Fling" or "Jump Drop", {"Fling", "Jump Drop"}, function(btn)
            if dropActive then stopDropBrainrot() end
            dropMode = dropMode == 1 and 2 or 1
            btn.Text = dropMode == 1 and "Fling" or "Jump Drop"
            saveAllSettings()
        end)
    end

    do
        local row = mkRow(momentPage, 30)
        mkLabel(row, "TP Down")
        local clk = Instance.new("TextButton", row)
        clk.Size = UDim2.new(0.58, 0, 1, 0)
        clk.BackgroundTransparency = 1
        clk.Text = ""
        clk.AutoButtonColor = false
        clk.ZIndex = 8
        clk.MouseButton1Click:Connect(function()
            runTPDown()
        end)
        local actLbl = Instance.new("TextLabel", row)
        actLbl.Size = UDim2.new(0, 70, 1, 0)
        actLbl.Position = UDim2.new(1, -78, 0, 0)
        actLbl.BackgroundTransparency = 1
        actLbl.Text = "ACTIVATE"
        actLbl.TextColor3 = WHITE
        actLbl.Font = Enum.Font.GothamBlack
        actLbl.TextSize = 9
        actLbl.TextXAlignment = Enum.TextXAlignment.Right
        actLbl.ZIndex = 8
    end

    setAutoTPDownVisual = mkToggle(momentPage, "Auto TP Down", function(on)
        if on then startAutoTPDown() else stopAutoTPDown() end
        saveAllSettings()
    end)
    do
        local row = mkRow(momentPage, 30)
        mkLabel(row, "Height Y")
        autoTPHeightBox = mkBox(row, autoTPDownHeight, 50, 56, function(v)
            if v and v >= 1 and v <= 500 then autoTPDownHeight = v end
            saveAllSettings()
        end)
    end

    setInstaResetVisual = mkToggle(momentPage, "Insta Reset", function(on)
        if on then
            instaReset()
            if instaResetFloatingButton and instaResetFloatingButton:FindFirstChild("Frame") then
                local btnFrame = instaResetFloatingButton:FindFirstChild("Frame")
                local label = btnFrame and btnFrame:FindFirstChild("TextLabel")
                if btnFrame then
                    TS:Create(btnFrame, TweenInfo.new(0.05, Enum.EasingStyle.Quad), {
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    }):Play()
                    if label then TS:Create(label, TweenInfo.new(0.05, Enum.EasingStyle.Quad), {
                        TextColor3 = Color3.fromRGB(0, 0, 0)
                    }):Play() end
                    task.delay(0.2, function()
                        if btnFrame then
                            TS:Create(btnFrame, TweenInfo.new(0.08, Enum.EasingStyle.Quad), {
                                BackgroundColor3 = Color3.fromRGB(0,0,0)
                            }):Play()
                            if label then TS:Create(label, TweenInfo.new(0.08, Enum.EasingStyle.Quad), {
                                TextColor3 = Color3.fromRGB(255,255,255)
                            }):Play() end
                        end
                    end)
                end
            end
            task.delay(0.3, function() if setInstaResetVisual then setInstaResetVisual(false) end end)
        end
    end)

    local combatPage = contentPages["Combat"]

    mkSect(combatPage, "Aimbots")
    autoBatSetVisual = mkToggle(combatPage, "Auto Bat", function(on)
        if on then enableAutoBat() else disableAutoBat() end
        if mobSetAutoBat then mobSetAutoBat(on) end
        saveAllSettings()
    end)

    bypassSetVisual = mkToggle(combatPage, "TP Bat", function(on)
        toggleBypass(on)
        if bypassFloatingButton then
            local btnFrame = bypassFloatingButton:FindFirstChild("Frame")
            if btnFrame then
                local label = btnFrame:FindFirstChild("TextLabel")
                TS:Create(btnFrame, TweenInfo.new(0.05, Enum.EasingStyle.Quad), {
                    BackgroundColor3 = on and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(0,0,0)
                }):Play()
                if label then TS:Create(label, TweenInfo.new(0.05, Enum.EasingStyle.Quad), {
                    TextColor3 = on and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255,255,255)
                }):Play() end
            end
        end
        saveAllSettings()
    end)
    if bypassSetVisual then bypassSetVisual(bypassToggled) end

    mkSect(combatPage, "Counters")
    setBatCounterVisual = mkToggle(combatPage, "Bat Counter", function(on)
        setBatCounterState(on)
        saveAllSettings()
    end)

    setMedusaVisual = mkToggle(combatPage, "Medusa Counter", function(on) setMedusaCounterState(on); saveAllSettings() end)

    mkSect(combatPage, "Defense")
    setAntiRagVisual = mkToggle(combatPage, "Anti Ragdoll", function(on)
        setAntiRag(on)
        saveAllSettings()
    end)

    bodyLockSetVisual = mkToggle(combatPage, "Body Lock", function(on)
        bodyLockEnabled = on
        if on then
            if _blSuppressCount == 0 then startBodyLock() end
        else
            stopBodyLock()
        end
        saveAllSettings()
    end)
    do
        local row = mkRow(combatPage, 30)
        mkLabel(row, "Body Lock Range")
        bodyLockRangeBox = mkBox(row, bodyLockRange, 50, 56, function(v)
            if v and v > 0 then
                bodyLockRange = math.clamp(math.floor(v), 5, 200)
                if bodyLockRangeBox then bodyLockRangeBox.Text = tostring(bodyLockRange) end
                saveAllSettings()
            end
        end)
    end

    local mainPage = contentPages["Main"]

    mkSect(mainPage, "Auto Steal")
    setInstaGrab = mkToggle(mainPage, "Auto Steal", function(on)
        CONFIG.AUTO_STEAL_ENABLED = on
        if on then pcall(startAutoStealSemi) else stopAutoSteal() end
        updateProgressBarVisibility()
        saveAllSettings()
    end)

    do
        local row = mkRow(mainPage, 30)
        mkLabel(row, "Steal Radius")
        radInput = mkBox(row, CONFIG.STEAL_RANGE, 50, 56, function(v)
            if v and v >= 5 and v <= 300 then
                CONFIG.STEAL_RANGE = math.floor(v+0.5)
                Steal.StealRadius = CONFIG.STEAL_RANGE
                radInput.Text = tostring(CONFIG.STEAL_RANGE)
                saveAllSettings()
            end
        end)
    end

    mkSect(mainPage, "Visual")
    do
        local row = mkRow(mainPage, 55)
        local container = Instance.new("Frame", row)
        container.Size = UDim2.new(1, -10, 1, -6)
        container.Position = UDim2.new(0, 5, 0, 3)
        container.BackgroundTransparency = 1
        container.ClipsDescendants = true
        container.ZIndex = 8

        local galleryLayout = Instance.new("UIListLayout", container)
        galleryLayout.FillDirection = Enum.FillDirection.Horizontal
        galleryLayout.Padding = UDim.new(0, 4)
        galleryLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        galleryLayout.VerticalAlignment = Enum.VerticalAlignment.Center

        local bgButtons = {}

        local function updateBgGallery()
            for i, btn in ipairs(bgButtons) do
                local st = btn:FindFirstChildOfClass("UIStroke")
                if st then
                    local selected = (i == currentBgIndex)
                    st.Color = selected and Color3.fromRGB(255,255,255) or Color3.fromRGB(100,100,120)
                    st.Thickness = selected and 2.5 or 1
                    st.Transparency = selected and 0.1 or 0.6
                end
            end
        end

        for i, asset in ipairs(BackgroundImages) do
            local btn = Instance.new("ImageButton", container)
            btn.Size = UDim2.new(0, 50, 0, 40)
            btn.BackgroundColor3 = Color3.fromRGB(20,20,25)
            btn.BackgroundTransparency = 0.2
            btn.Image = asset
            btn.ImageTransparency = 0
            btn.ScaleType = Enum.ScaleType.Crop
            btn.ZIndex = 9
            btn.AutoButtonColor = false
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
            local st = Instance.new("UIStroke", btn)
            st.Color = (i == currentBgIndex) and Color3.fromRGB(255,255,255) or Color3.fromRGB(100,100,120)
            st.Thickness = (i == currentBgIndex) and 2.5 or 1
            st.Transparency = (i == currentBgIndex) and 0.1 or 0.6

            bgButtons[i] = btn

            btn.MouseButton1Click:Connect(function()
                if currentBgIndex ~= i then
                    applyBackgroundImage(i)
                    updateBgGallery()
                    saveAllSettings()
                end
            end)
        end

        updateBgGallery()
    end

    do
        local row = mkRow(mainPage, 30)
        mkLabel(row, "Sky Theme")
        local currentIndex = 1
        for i, entry in ipairs(FORCEHUB_SKY_ORDER) do
            if entry[2] == currentSkyTheme then currentIndex = i; break end
        end
        local container = Instance.new("Frame", row)
        container.Size = UDim2.new(0, 160, 1, 0)
        container.Position = UDim2.new(1, -168, 0, 0)
        container.BackgroundTransparency = 1
        container.ZIndex = 8

        local leftBtn = Instance.new("TextButton", container)
        leftBtn.Size = UDim2.new(0, 32, 0, 26)
        leftBtn.Position = UDim2.new(0, 0, 0.5, -13)
        leftBtn.BackgroundColor3 = INP
        leftBtn.BackgroundTransparency = 0.7
        leftBtn.BorderSizePixel = 0
        leftBtn.Text = "<"
        leftBtn.TextColor3 = WHITE
        leftBtn.Font = Enum.Font.GothamBlack
        leftBtn.TextSize = 13
        leftBtn.AutoButtonColor = false
        leftBtn.ZIndex = 9
        Instance.new("UICorner", leftBtn).CornerRadius = UDim.new(0, 6)
        local leftStroke = Instance.new("UIStroke", leftBtn)
        leftStroke.Color = ROW_BORDER
        leftStroke.Thickness = 1

        skySelectorLabel = Instance.new("TextLabel", container)
        skySelectorLabel.Size = UDim2.new(0, 80, 0, 26)
        skySelectorLabel.Position = UDim2.new(0.5, -40, 0.5, -13)
        skySelectorLabel.BackgroundTransparency = 1
        skySelectorLabel.Text = FORCEHUB_SKY_ORDER[currentIndex][2]
        skySelectorLabel.TextColor3 = WHITE
        skySelectorLabel.Font = Enum.Font.GothamBlack
        skySelectorLabel.TextSize = 12
        skySelectorLabel.TextXAlignment = Enum.TextXAlignment.Center
        skySelectorLabel.ZIndex = 9

        local rightBtn = Instance.new("TextButton", container)
        rightBtn.Size = UDim2.new(0, 32, 0, 26)
        rightBtn.Position = UDim2.new(1, -32, 0.5, -13)
        rightBtn.BackgroundColor3 = INP
        rightBtn.BackgroundTransparency = 0.7
        rightBtn.BorderSizePixel = 0
        rightBtn.Text = ">"
        rightBtn.TextColor3 = WHITE
        rightBtn.Font = Enum.Font.GothamBlack
        rightBtn.TextSize = 13
        rightBtn.AutoButtonColor = false
        rightBtn.ZIndex = 9
        Instance.new("UICorner", rightBtn).CornerRadius = UDim.new(0, 6)
        local rightStroke = Instance.new("UIStroke", rightBtn)
        rightStroke.Color = ROW_BORDER
        rightStroke.Thickness = 1

        local function updateSkySelector(direction)
            local idx = 1
            for i, entry in ipairs(FORCEHUB_SKY_ORDER) do
                if entry[2] == currentSkyTheme then idx = i; break end
            end
            local newIdx = idx + direction
            if newIdx < 1 then newIdx = #FORCEHUB_SKY_ORDER end
            if newIdx > #FORCEHUB_SKY_ORDER then newIdx = 1 end
            setSkyTheme(FORCEHUB_SKY_ORDER[newIdx][2])
            saveAllSettings()
        end
        leftBtn.MouseButton1Click:Connect(function() updateSkySelector(-1) end)
        rightBtn.MouseButton1Click:Connect(function() updateSkySelector(1) end)
    end

    do
        local row = mkRow(mainPage, 30)
        mkLabel(row, "Pack Accessory")
        local currentIndex = 1
        for i, entry in ipairs(ACCESSORY_PACK_ORDER) do
            if entry[2] == currentAccessoryPack then currentIndex = i; break end
        end

        local container = Instance.new("Frame", row)
        container.Size = UDim2.new(0, 160, 1, 0)
        container.Position = UDim2.new(1, -168, 0, 0)
        container.BackgroundTransparency = 1
        container.ZIndex = 8

        local leftBtn = Instance.new("TextButton", container)
        leftBtn.Size = UDim2.new(0, 32, 0, 26)
        leftBtn.Position = UDim2.new(0, 0, 0.5, -13)
        leftBtn.BackgroundColor3 = INP
        leftBtn.BackgroundTransparency = 0.7
        leftBtn.BorderSizePixel = 0
        leftBtn.Text = "<"
        leftBtn.TextColor3 = WHITE
        leftBtn.Font = Enum.Font.GothamBlack
        leftBtn.TextSize = 13
        leftBtn.AutoButtonColor = false
        leftBtn.ZIndex = 9
        Instance.new("UICorner", leftBtn).CornerRadius = UDim.new(0, 6)
        local leftStroke = Instance.new("UIStroke", leftBtn)
        leftStroke.Color = ROW_BORDER
        leftStroke.Thickness = 1

        accSelectorLabel = Instance.new("TextLabel", container)
        accSelectorLabel.Size = UDim2.new(0, 80, 0, 26)
        accSelectorLabel.Position = UDim2.new(0.5, -40, 0.5, -13)
        accSelectorLabel.BackgroundTransparency = 1
        accSelectorLabel.Text = ACCESSORY_PACK_ORDER[currentIndex][2]
        accSelectorLabel.TextColor3 = WHITE
        accSelectorLabel.Font = Enum.Font.GothamBlack
        accSelectorLabel.TextSize = 12
        accSelectorLabel.TextXAlignment = Enum.TextXAlignment.Center
        accSelectorLabel.ZIndex = 9

        local rightBtn = Instance.new("TextButton", container)
        rightBtn.Size = UDim2.new(0, 32, 0, 26)
        rightBtn.Position = UDim2.new(1, -32, 0.5, -13)
        rightBtn.BackgroundColor3 = INP
        rightBtn.BackgroundTransparency = 0.7
        rightBtn.BorderSizePixel = 0
        rightBtn.Text = ">"
        rightBtn.TextColor3 = WHITE
        rightBtn.Font = Enum.Font.GothamBlack
        rightBtn.TextSize = 13
        rightBtn.AutoButtonColor = false
        rightBtn.ZIndex = 9
        Instance.new("UICorner", rightBtn).CornerRadius = UDim.new(0, 6)
        local rightStroke = Instance.new("UIStroke", rightBtn)
        rightStroke.Color = ROW_BORDER
        rightStroke.Thickness = 1

        local function updateAccessorySelector(direction)
            local idx = 1
            for i, entry in ipairs(ACCESSORY_PACK_ORDER) do
                if entry[2] == currentAccessoryPack then idx = i; break end
            end
            local newIdx = idx + direction
            if newIdx < 1 then newIdx = #ACCESSORY_PACK_ORDER end
            if newIdx > #ACCESSORY_PACK_ORDER then newIdx = 1 end
            local packName = ACCESSORY_PACK_ORDER[newIdx][2]
            currentAccessoryPack = packName
            accSelectorLabel.Text = packName
            applyAccessoryPack(packName)
            saveAllSettings()
        end

        leftBtn.MouseButton1Click:Connect(function() updateAccessorySelector(-1) end)
        rightBtn.MouseButton1Click:Connect(function() updateAccessorySelector(1) end)
    end

    do
        local row = mkRow(mainPage, 30)
        mkLabel(row, "Anim Pack")
        local currentIndex = 1
        for i, entry in ipairs(ANIM_PACK_ORDER) do
            if entry[2] == currentAnimPack then currentIndex = i; break end
        end
        local container = Instance.new("Frame", row)
        container.Size = UDim2.new(0, 160, 1, 0)
        container.Position = UDim2.new(1, -168, 0, 0)
        container.BackgroundTransparency = 1
        container.ZIndex = 8

        local leftBtn = Instance.new("TextButton", container)
        leftBtn.Size = UDim2.new(0, 32, 0, 26)
        leftBtn.Position = UDim2.new(0, 0, 0.5, -13)
        leftBtn.BackgroundColor3 = INP
        leftBtn.BackgroundTransparency = 0.7
        leftBtn.BorderSizePixel = 0
        leftBtn.Text = "<"
        leftBtn.TextColor3 = WHITE
        leftBtn.Font = Enum.Font.GothamBlack
        leftBtn.TextSize = 13
        leftBtn.AutoButtonColor = false
        leftBtn.ZIndex = 9
        Instance.new("UICorner", leftBtn).CornerRadius = UDim.new(0, 6)
        local leftStroke = Instance.new("UIStroke", leftBtn)
        leftStroke.Color = ROW_BORDER
        leftStroke.Thickness = 1

        animSelectorLabel = Instance.new("TextLabel", container)
        animSelectorLabel.Size = UDim2.new(0, 80, 0, 26)
        animSelectorLabel.Position = UDim2.new(0.5, -40, 0.5, -13)
        animSelectorLabel.BackgroundTransparency = 1
        animSelectorLabel.Text = ANIM_PACK_ORDER[currentIndex][2]
        animSelectorLabel.TextColor3 = WHITE
        animSelectorLabel.Font = Enum.Font.GothamBlack
        animSelectorLabel.TextSize = 12
        animSelectorLabel.TextXAlignment = Enum.TextXAlignment.Center
        animSelectorLabel.ZIndex = 9

        local rightBtn = Instance.new("TextButton", container)
        rightBtn.Size = UDim2.new(0, 32, 0, 26)
        rightBtn.Position = UDim2.new(1, -32, 0.5, -13)
        rightBtn.BackgroundColor3 = INP
        rightBtn.BackgroundTransparency = 0.7
        rightBtn.BorderSizePixel = 0
        rightBtn.Text = ">"
        rightBtn.TextColor3 = WHITE
        rightBtn.Font = Enum.Font.GothamBlack
        rightBtn.TextSize = 13
        rightBtn.AutoButtonColor = false
        rightBtn.ZIndex = 9
        Instance.new("UICorner", rightBtn).CornerRadius = UDim.new(0, 6)
        local rightStroke = Instance.new("UIStroke", rightBtn)
        rightStroke.Color = ROW_BORDER
        rightStroke.Thickness = 1

        local function updateAnimSelector(direction)
            local idx = 1
            for i, entry in ipairs(ANIM_PACK_ORDER) do
                if entry[2] == currentAnimPack then idx = i; break end
            end
            local newIdx = idx + direction
            if newIdx < 1 then newIdx = #ANIM_PACK_ORDER end
            if newIdx > #ANIM_PACK_ORDER then newIdx = 1 end
            local packName = ANIM_PACK_ORDER[newIdx][2]
            if packName == "Off" then
                stopAnimPack()
            else
                startAnimPack(packName)
            end
            saveAllSettings()
        end
        leftBtn.MouseButton1Click:Connect(function() updateAnimSelector(-1) end)
        rightBtn.MouseButton1Click:Connect(function() updateAnimSelector(1) end)
    end

    setESPVIsual = mkToggle(mainPage, "Player ESP", function(on)
        toggleESP(on)
        saveAllSettings()
    end)

    local stretchToggleSetter
    stretchToggleSetter = mkToggle(mainPage, "Stretch Rez", function(on)
        if on then enableStretch() else disableStretch() end
        stretchEnabled = on
        saveAllSettings()
    end)
    _G.stretchToggleSetter = stretchToggleSetter
    stretchToggleSetter(stretchEnabled)

    setAntiLagVisual = mkToggle(mainPage, "Anti Lag", function(on)
        if on then enableAntiLag() else disableAntiLag() end
        saveAllSettings()
    end)

    mkSect(mainPage, "Interface")
    setEditModeVisual = mkToggle(mainPage, "Edit Button", function(on)
        toggleEditMode(on)
        if on and uiLocked then
            editModeEnabled = false
            setEditModeVisual(false)
        end
        saveAllSettings()
    end)
    if setEditModeVisual then setEditModeVisual(editModeEnabled) end

    setLockUIVisual = mkToggle(mainPage, "Lock UI", function(on)
        toggleLockUI(on)
        if on and editModeEnabled then
            editModeEnabled = false
            if setEditModeVisual then setEditModeVisual(false) end
        end
        saveAllSettings()
    end)

    do
        local row = mkRow(mainPage, 34)
        mkLabel(row, "Button Scale")
        local container = Instance.new("Frame", row)
        container.Size = UDim2.new(0, 150, 1, 0)
        container.Position = UDim2.new(1, -160, 0, 0)
        container.BackgroundTransparency = 1
        container.ZIndex = 8

        local leftBtn = Instance.new("TextButton", container)
        leftBtn.Size = UDim2.new(0, 32, 0, 26)
        leftBtn.Position = UDim2.new(0, 0, 0.5, -13)
        leftBtn.BackgroundColor3 = INP
        leftBtn.BackgroundTransparency = 0.7
        leftBtn.BorderSizePixel = 0
        leftBtn.Text = "<"
        leftBtn.TextColor3 = WHITE
        leftBtn.Font = Enum.Font.GothamBlack
        leftBtn.TextSize = 13
        leftBtn.AutoButtonColor = false
        leftBtn.ZIndex = 9
        Instance.new("UICorner", leftBtn).CornerRadius = UDim.new(0, 6)
        local leftStroke = Instance.new("UIStroke", leftBtn)
        leftStroke.Color = ROW_BORDER
        leftStroke.Thickness = 1

        local valueLabel = Instance.new("TextLabel", container)
        valueLabel.Size = UDim2.new(0, 70, 0, 26)
        valueLabel.Position = UDim2.new(0.5, -35, 0.5, -13)
        valueLabel.BackgroundTransparency = 1
        valueLabel.Text = string.format("%.2f", buttonScaleValue)
        valueLabel.TextColor3 = WHITE
        valueLabel.Font = Enum.Font.GothamBlack
        valueLabel.TextSize = 12
        valueLabel.TextXAlignment = Enum.TextXAlignment.Center
        valueLabel.ZIndex = 9

        local rightBtn = Instance.new("TextButton", container)
        rightBtn.Size = UDim2.new(0, 32, 0, 26)
        rightBtn.Position = UDim2.new(1, -32, 0.5, -13)
        rightBtn.BackgroundColor3 = INP
        rightBtn.BackgroundTransparency = 0.7
        rightBtn.BorderSizePixel = 0
        rightBtn.Text = ">"
        rightBtn.TextColor3 = WHITE
        rightBtn.Font = Enum.Font.GothamBlack
        rightBtn.TextSize = 13
        rightBtn.AutoButtonColor = false
        rightBtn.ZIndex = 9
        Instance.new("UICorner", rightBtn).CornerRadius = UDim.new(0, 6)
        local rightStroke = Instance.new("UIStroke", rightBtn)
        rightStroke.Color = ROW_BORDER
        rightStroke.Thickness = 1

        local function updateButtonScale(delta)
            local newVal = math.clamp(buttonScaleValue + delta, 0.50, 1.50)
            if newVal ~= buttonScaleValue then
                buttonScaleValue = newVal
                valueLabel.Text = string.format("%.2f", buttonScaleValue)
                applyButtonScale(buttonScaleValue)
                saveAllSettings()
            end
        end

        leftBtn.MouseButton1Click:Connect(function() updateButtonScale(-0.05) end)
        rightBtn.MouseButton1Click:Connect(function() updateButtonScale(0.05) end)

        _G.buttonScaleValueLabel = valueLabel
    end

    do
        local row = mkRow(mainPage, 34)
        mkLabel(row, "UI Scale")
        local container = Instance.new("Frame", row)
        container.Size = UDim2.new(0, 150, 1, 0)
        container.Position = UDim2.new(1, -160, 0, 0)
        container.BackgroundTransparency = 1
        container.ZIndex = 8

        local leftBtn = Instance.new("TextButton", container)
        leftBtn.Size = UDim2.new(0, 32, 0, 26)
        leftBtn.Position = UDim2.new(0, 0, 0.5, -13)
        leftBtn.BackgroundColor3 = INP
        leftBtn.BackgroundTransparency = 0.7
        leftBtn.BorderSizePixel = 0
        leftBtn.Text = "<"
        leftBtn.TextColor3 = WHITE
        leftBtn.Font = Enum.Font.GothamBlack
        leftBtn.TextSize = 13
        leftBtn.AutoButtonColor = false
        leftBtn.ZIndex = 9
        Instance.new("UICorner", leftBtn).CornerRadius = UDim.new(0, 6)
        local leftStroke = Instance.new("UIStroke", leftBtn)
        leftStroke.Color = ROW_BORDER
        leftStroke.Thickness = 1

        local valueLabel = Instance.new("TextLabel", container)
        valueLabel.Size = UDim2.new(0, 70, 0, 26)
        valueLabel.Position = UDim2.new(0.5, -35, 0.5, -13)
        valueLabel.BackgroundTransparency = 1
        valueLabel.Text = string.format("%.2f", uiScaleValue / 100)
        valueLabel.TextColor3 = WHITE
        valueLabel.Font = Enum.Font.GothamBlack
        valueLabel.TextSize = 12
        valueLabel.TextXAlignment = Enum.TextXAlignment.Center
        valueLabel.ZIndex = 9

        local rightBtn = Instance.new("TextButton", container)
        rightBtn.Size = UDim2.new(0, 32, 0, 26)
        rightBtn.Position = UDim2.new(1, -32, 0.5, -13)
        rightBtn.BackgroundColor3 = INP
        rightBtn.BackgroundTransparency = 0.7
        rightBtn.BorderSizePixel = 0
        rightBtn.Text = ">"
        rightBtn.TextColor3 = WHITE
        rightBtn.Font = Enum.Font.GothamBlack
        rightBtn.TextSize = 13
        rightBtn.AutoButtonColor = false
        rightBtn.ZIndex = 9
        Instance.new("UICorner", rightBtn).CornerRadius = UDim.new(0, 6)
        local rightStroke = Instance.new("UIStroke", rightBtn)
        rightStroke.Color = ROW_BORDER
        rightStroke.Thickness = 1

        local function updateUIScale(delta)
            local newVal = uiScaleValue + delta
            newVal = math.clamp(newVal, 50, 150)
            if newVal ~= uiScaleValue then
                uiScaleValue = newVal
                if mainUIScale then mainUIScale.Scale = uiScaleValue / 100 end
                if pbScale then pbScale.Scale = uiScaleValue / 100 end
                valueLabel.Text = string.format("%.2f", uiScaleValue / 100)
                saveAllSettings()
            end
        end

        leftBtn.MouseButton1Click:Connect(function() updateUIScale(-5) end)
        rightBtn.MouseButton1Click:Connect(function() updateUIScale(5) end)

        _G.uiScaleValueLabel = valueLabel
    end

    mkSect(mainPage, "Config")

    do
        local row = mkRow(mainPage, 44)
        row.Size = UDim2.new(1, 0, 0, 44)
        local saveBtn = Instance.new("TextButton", row)
        saveBtn.Size = UDim2.new(1, -12, 0.8, 0)
        saveBtn.Position = UDim2.new(0, 6, 0.1, 0)
        saveBtn.BackgroundColor3 = Color3.fromRGB(30,30,35)
        saveBtn.BackgroundTransparency = 0.5
        saveBtn.BorderSizePixel = 0
        saveBtn.Text = "SAVE NOW"
        saveBtn.TextColor3 = WHITE
        saveBtn.Font = Enum.Font.GothamBold
        saveBtn.TextSize = 13
        saveBtn.TextStrokeColor3 = Color3.fromRGB(60,60,60)
        saveBtn.TextStrokeTransparency = 0
        saveBtn.AutoButtonColor = false
        saveBtn.ZIndex = 8
        Instance.new("UICorner", saveBtn).CornerRadius = UDim.new(0, 8)
        local saveStroke = Instance.new("UIStroke", saveBtn)
        saveStroke.Color = ROW_BORDER
        saveStroke.Thickness = 1.2
        saveStroke.Transparency = 0.5
        saveBtn.MouseButton1Click:Connect(function()
            local ok = saveAllSettings()
            saveBtn.Text = ok and "SAVED âœ“" or "ERROR"
            task.delay(1.2, function()
                if saveBtn and saveBtn.Parent then
                    saveBtn.Text = "SAVE NOW"
                end
            end)
        end)
    end

    do
        local row = mkRow(mainPage, 44)
        row.Size = UDim2.new(1, 0, 0, 44)
        local resetPosBtn = Instance.new("TextButton", row)
        resetPosBtn.Size = UDim2.new(1, -12, 0.8, 0)
        resetPosBtn.Position = UDim2.new(0, 6, 0.1, 0)
        resetPosBtn.BackgroundColor3 = Color3.fromRGB(30,30,35)
        resetPosBtn.BackgroundTransparency = 0.5
        resetPosBtn.BorderSizePixel = 0
        resetPosBtn.Text = "RESET POSITIONS"
        resetPosBtn.TextColor3 = WHITE
        resetPosBtn.Font = Enum.Font.GothamBold
        resetPosBtn.TextSize = 13
        resetPosBtn.TextStrokeColor3 = Color3.fromRGB(60,60,60)
        resetPosBtn.TextStrokeTransparency = 0
        resetPosBtn.AutoButtonColor = false
        resetPosBtn.ZIndex = 8
        Instance.new("UICorner", resetPosBtn).CornerRadius = UDim.new(0, 8)
        local resetStroke = Instance.new("UIStroke", resetPosBtn)
        resetStroke.Color = ROW_BORDER
        resetStroke.Thickness = 1.2
        resetStroke.Transparency = 0.5
        local resetDebounce = false
        resetPosBtn.MouseButton1Click:Connect(function()
            if resetDebounce then return end
            resetDebounce = true
            resetFloatingPositions()
            saveAllSettings()
            resetPosBtn.Text = "RESET âœ“"
            task.delay(1.2, function()
                if resetPosBtn and resetPosBtn.Parent then
                    resetPosBtn.Text = "RESET POSITIONS"
                    resetDebounce = false
                end
            end)
        end)
    end

    do
        local row = mkRow(mainPage, 44)
        row.Size = UDim2.new(1, 0, 0, 44)
        local delBtn = Instance.new("TextButton", row)
        delBtn.Size = UDim2.new(1, -12, 0.8, 0)
        delBtn.Position = UDim2.new(0, 6, 0.1, 0)
        delBtn.BackgroundColor3 = Color3.fromRGB(140, 25, 65)
        delBtn.BackgroundTransparency = 0.5
        delBtn.BorderSizePixel = 0
        delBtn.Text = "DELETE SETTINGS"
        delBtn.TextColor3 = WHITE
        delBtn.Font = Enum.Font.GothamBold
        delBtn.TextSize = 13
        delBtn.TextStrokeColor3 = Color3.fromRGB(60,60,60)
        delBtn.TextStrokeTransparency = 0
        delBtn.AutoButtonColor = false
        delBtn.ZIndex = 8
        Instance.new("UICorner", delBtn).CornerRadius = UDim.new(0, 8)
        local delStroke = Instance.new("UIStroke", delBtn)
        delStroke.Color = ROW_BORDER
        delStroke.Thickness = 1.2
        delStroke.Transparency = 0.5
        local deleteState = 0
        local originalDeleteText = "DELETE SETTINGS"
        local delDebounce = false
        delBtn.MouseButton1Click:Connect(function()
            if delDebounce then return end
            if deleteState == 0 then
                deleteState = 1
                delBtn.Text = "CONFIRM?"
                delBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 80)
                task.delay(2, function()
                    if delBtn and delBtn.Parent and deleteState == 1 then
                        deleteState = 0
                        delBtn.Text = originalDeleteText
                        delBtn.BackgroundColor3 = Color3.fromRGB(140, 25, 65)
                    end
                end)
            elseif deleteState == 1 then
                delDebounce = true
                local success = pcall(resetToFactoryDefaults)
                delBtn.Text = success and "DELETED âœ“" or "ERROR"
                delBtn.BackgroundColor3 = Color3.fromRGB(140, 25, 65)
                deleteState = 0
                task.delay(1.5, function()
                    if delBtn and delBtn.Parent then
                        delBtn.Text = originalDeleteText
                        delBtn.BackgroundColor3 = Color3.fromRGB(140, 25, 65)
                        delDebounce = false
                    end
                end)
            end
        end)
    end

    local keyPage = contentPages["Keybinds"]
    mkSect(keyPage, "Keybinds")
    addKeybindRow(keyPage, "Carry Mode", KB.CarryToggle)
    addKeybindRow(keyPage, "Lagger Mode", KB.LaggerMode)
    addKeybindRow(keyPage, "Auto Left", KB.AutoLeft)
    addKeybindRow(keyPage, "Auto Right", KB.AutoRight)
    addKeybindRow(keyPage, "Auto Bat", KB.AutoBat)
    addKeybindRow(keyPage, "TP Bat", KB.Bypass)
    addKeybindRow(keyPage, "TP Down", KB.TPFloor)
    addKeybindRow(keyPage, "Drop Brainrot", KB.DropBrainrot)
    addKeybindRow(keyPage, "Insta Reset", KB.InstaReset)

    local spacer = Instance.new("Frame", keyPage)
    spacer.Size = UDim2.new(1, 0, 0, 16)
    spacer.BackgroundTransparency = 1
    spacer.LayoutOrder = getNextOrder(keyPage)
    spacer.ZIndex = 7

    pbFrame = Instance.new("Frame", gui)
    pbFrame.Size = UDim2.new(0, 340, 0, 40)
    pbFrame.Position = UDim2.new(0.5, -170, 1, -56)
    pbFrame.BackgroundColor3 = BG
    pbFrame.BackgroundTransparency = 0.15
    pbFrame.BorderSizePixel = 0
    pbFrame.Active = true
    pbFrame.ClipsDescendants = true
    pbFrame.Visible = CONFIG.AUTO_STEAL_ENABLED
    pbFrame.ZIndex = 10

    pbScale = Instance.new("UIScale", pbFrame)
    pbScale.Scale = uiScaleValue / 100

    if savedProgressBarPos then
        pbFrame.Position = UDim2.new(
            savedProgressBarPos.XScale or 0.5,
            savedProgressBarPos.XOffset or -170,
            savedProgressBarPos.YScale or 1,
            savedProgressBarPos.YOffset or -56
        )
    end

    Instance.new("UICorner", pbFrame).CornerRadius = UDim.new(1, 0)

    local pbSt = Instance.new("UIStroke", pbFrame)
    pbSt.Color = SILVER
    pbSt.Thickness = 2
    pbSt.Transparency = 0.15

    local fillRegion = Instance.new("Frame", pbFrame)
    fillRegion.Size = UDim2.new(0, 220, 1, -8)
    fillRegion.Position = UDim2.new(0, 4, 0, 4)
    fillRegion.BackgroundColor3 = Color3.fromRGB(20,20,25)
    fillRegion.BackgroundTransparency = 0.4
    fillRegion.BorderSizePixel = 0
    fillRegion.ClipsDescendants = true
    fillRegion.ZIndex = 11
    Instance.new("UICorner", fillRegion).CornerRadius = UDim.new(1, 0)

    local fillRegStroke = Instance.new("UIStroke", fillRegion)
    fillRegStroke.Color = SILVER
    fillRegStroke.Thickness = 1.5
    fillRegStroke.Transparency = 0.3

    progressFill = Instance.new("Frame", fillRegion)
    progressFill.Size = UDim2.new(0, 0, 1, 0)
    progressFill.Position = UDim2.new(0, 0, 0, 0)
    progressFill.BackgroundColor3 = SILVER
    progressFill.BorderSizePixel = 0
    progressFill.ZIndex = 12
    Instance.new("UICorner", progressFill).CornerRadius = UDim.new(1, 0)

    local glow = Instance.new("Frame", progressFill)
    glow.Size = UDim2.new(1, 0, 1, 0)
    glow.Position = UDim2.new(0, 0, 0, 0)
    glow.BackgroundColor3 = Color3.fromRGB(255,255,255)
    glow.BackgroundTransparency = 0.85
    glow.BorderSizePixel = 0
    glow.ZIndex = 13
    Instance.new("UICorner", glow).CornerRadius = UDim.new(1, 0)

    local stealLbl = Instance.new("TextLabel", fillRegion)
    stealLbl.Size = UDim2.new(0, 50, 1, 0)
    stealLbl.Position = UDim2.new(0, 8, 0, 0)
    stealLbl.BackgroundTransparency = 1
    stealLbl.Text = "STEAL"
    stealLbl.TextColor3 = WHITE
    stealLbl.Font = Enum.Font.GothamBlack
    stealLbl.TextSize = 12
    stealLbl.TextXAlignment = Enum.TextXAlignment.Left
    stealLbl.TextStrokeColor3 = Color3.fromRGB(0,0,0)
    stealLbl.TextStrokeTransparency = 0.2
    stealLbl.ZIndex = 14

    progressPct = Instance.new("TextLabel", fillRegion)
    progressPct.Size = UDim2.new(0, 44, 1, 0)
    progressPct.Position = UDim2.new(1, -52, 0, 0)
    progressPct.BackgroundTransparency = 1
    progressPct.Text = "0%"
    progressPct.TextColor3 = WHITE
    progressPct.Font = Enum.Font.GothamBold
    progressPct.TextSize = 10
    progressPct.TextXAlignment = Enum.TextXAlignment.Right
    progressPct.TextStrokeColor3 = Color3.fromRGB(0,0,0)
    progressPct.TextStrokeTransparency = 0.2
    progressPct.ZIndex = 14

    local pbDiv = Instance.new("Frame", pbFrame)
    pbDiv.Size = UDim2.new(0, 1, 0, 14)
    pbDiv.Position = UDim2.new(0, 230, 0.5, -7)
    pbDiv.BackgroundColor3 = SILVER
    pbDiv.BackgroundTransparency = 0.4
    pbDiv.BorderSizePixel = 0
    pbDiv.ZIndex = 12

    progressRadLbl = Instance.new("TextLabel", pbFrame)
    progressRadLbl.Size = UDim2.new(0, 100, 1, 0)
    progressRadLbl.Position = UDim2.new(0, 234, 0, 0)
    progressRadLbl.BackgroundTransparency = 1
    progressRadLbl.Text = "--FPS Â· --ms"
    progressRadLbl.TextColor3 = Color3.fromRGB(200,200,200)
    progressRadLbl.Font = Enum.Font.GothamBold
    progressRadLbl.TextSize = 9
    progressRadLbl.TextXAlignment = Enum.TextXAlignment.Center
    progressRadLbl.TextStrokeColor3 = Color3.fromRGB(0,0,0)
    progressRadLbl.TextStrokeTransparency = 0.2
    progressRadLbl.ZIndex = 14

    drag(pbFrame)

    task.spawn(function()
        local lastFrame = tick()
        local fpsSamples = {}
        local fpsAvg = 60
        RunService.RenderStepped:Connect(function()
            local now = tick()
            local dt = now - lastFrame
            lastFrame = now
            if dt > 0 then
                table.insert(fpsSamples, 1 / dt)
                if #fpsSamples > 30 then table.remove(fpsSamples, 1) end
                local sum = 0
                for _, v in ipairs(fpsSamples) do sum = sum + v end
                fpsAvg = sum / #fpsSamples
            end
        end)
        while true do
            local ping = 0
            pcall(function() ping = LP:GetNetworkPing() * 1000 end)
            if progressRadLbl then
                progressRadLbl.Text = string.format("%dFPS Â· %dms", math.floor(fpsAvg + 0.5), math.floor(ping + 0.5))
            end
            task.wait(0.5)
        end
    end)
end

function createMobilePanel()
    local panel = Instance.new("ScreenGui")
    panel.Name = "FORCEHUBMobilePanel"
    panel.ResetOnSpawn = false
    panel.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function() if syn and syn.protect_gui then syn.protect_gui(panel) end end)
    if not pcall(function() panel.Parent = game:GetService("CoreGui") end) then
        panel.Parent = LP:WaitForChild("PlayerGui")
    end

    local BTN_W, BTN_H = 60, 60
    local GAP = 8
    local COLUMNS = 2
    local ROWS = 4
    local PANEL_W = BTN_W * COLUMNS + GAP * (COLUMNS - 1)
    local PANEL_H = BTN_H * ROWS + (GAP + 10) * (ROWS - 1)

    local container = Instance.new("Frame", panel)
    container.Name = "FloatingPanel"
    container.Size = UDim2.new(0, PANEL_W, 0, PANEL_H)
    container.Position = UDim2.new(1, -PANEL_W - 10, 0, 0)
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    container.Active = true
    container.Selectable = true
    container.ClipsDescendants = false

    local btnContainer = Instance.new("Frame", container)
    btnContainer.Name = "ButtonsContainer"
    btnContainer.Size = UDim2.new(1, 0, 1, 0)
    btnContainer.BackgroundTransparency = 1
    btnContainer.ClipsDescendants = false

    local PINK = Color3.fromRGB(230, 230, 230)
    local WHITE = Color3.fromRGB(255, 255, 255)
    local INACTIVE_BG = Color3.fromRGB(10,10,10)
    local INACTIVE_TEXT = Color3.fromRGB(225,225,225)
    local STROKE_COLOR = Color3.fromRGB(70,70,70)
    local ACTIVE_BG = Color3.fromRGB(255, 255, 255)
    local ACTIVE_TEXT = Color3.fromRGB(0, 0, 0)

    local buttons = {}
    local buttonNames = {"DropBR", "AutoLeft", "AutoBat", "AutoRight", "TpDown", "Carry", "Lagger1", "Lagger2"}
    local buttonTexts = {"DROP\nBR", "AUTO\nLEFT", "BAT\nAIMBOT", "AUTO\nRIGHT", "TP\nDOWN", "CARRY\nSPD", "LAGGER\n1", "LAGGER\n2"}

    local function createButton(name, text, order, isToggle, callback)
        local btn = Instance.new("TextButton", btnContainer)
        btn.Name = name
        btn.Size = UDim2.new(0, BTN_W, 0, BTN_H)
        btn.BackgroundColor3 = INACTIVE_BG
        btn.BorderSizePixel = 0
        btn.Text = ""
        btn.AutoButtonColor = false
        btn.ZIndex = 10

        local savedPos = savedButtonPositions[name]
        if savedPos then
            btn.Position = UDim2.new(0, savedPos.X or 0, 0, savedPos.Y or 0)
        else
            local defX, defY = getDefaultButtonPosition(name)
            btn.Position = UDim2.new(0, defX, 0, defY)
        end

        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 18)
        local stroke = Instance.new("UIStroke", btn)
        stroke.Color = STROKE_COLOR
        stroke.Thickness = 1.2
        stroke.Transparency = 0.4
        stroke.Name = "NormalStroke"

        local label = Instance.new("TextLabel", btn)
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = INACTIVE_TEXT
        label.Font = Enum.Font.GothamBlack
        label.TextSize = 10
        label.TextWrapped = true
        label.ZIndex = 11

        local active = false
        local function setActive(state)
            active = state
            if active then
                TS:Create(btn, TweenInfo.new(0.05, Enum.EasingStyle.Quad), {
                    BackgroundColor3 = ACTIVE_BG
                }):Play()
                TS:Create(label, TweenInfo.new(0.05, Enum.EasingStyle.Quad), {
                    TextColor3 = ACTIVE_TEXT
                }):Play()
                TS:Create(stroke, TweenInfo.new(0.05, Enum.EasingStyle.Quad), {
                    Color = PINK,
                    Transparency = 0
                }):Play()
            else
                TS:Create(btn, TweenInfo.new(0.05, Enum.EasingStyle.Quad), {
                    BackgroundColor3 = INACTIVE_BG
                }):Play()
                TS:Create(label, TweenInfo.new(0.05, Enum.EasingStyle.Quad), {
                    TextColor3 = INACTIVE_TEXT
                }):Play()
                TS:Create(stroke, TweenInfo.new(0.05, Enum.EasingStyle.Quad), {
                    Color = STROKE_COLOR,
                    Transparency = 0.4
                }):Play()
            end
        end

        local dragging = false
        local hasMoved = false
        local dragStart = nil
        local startPos = nil
        local movedDistance = 0

        local function onInputBegan(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                hasMoved = false
                movedDistance = 0
                dragStart = input.Position
                startPos = btn.Position
                _isDraggingButton = true
            end
        end

        local function onInputChanged(input)
            if not dragging then return end
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                local delta = input.Position - dragStart
                movedDistance = delta.Magnitude
                if editModeEnabled and not uiLocked then
                    hasMoved = true
                    btn.Position = UDim2.new(0, startPos.X.Offset + delta.X, 0, startPos.Y.Offset + delta.Y)
                end
            end
        end

        local function onInputEnded(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                if dragging then
                    if movedDistance < 3 then
                        if isToggle then
                            if editModeEnabled and not uiLocked then
                                if callback then callback(function() end) end
                            else
                                if callback then callback(setActive) end
                            end
                        else
                            if callback then callback(setActive, active) end
                        end
                    elseif editModeEnabled and not uiLocked and hasMoved then
                        savedButtonPositions[name] = {
                            X = btn.Position.X.Offset,
                            Y = btn.Position.Y.Offset
                        }
                    end
                    dragging = false
                    hasMoved = false
                    dragStart = nil
                    startPos = nil
                    movedDistance = 0
                    _isDraggingButton = false
                end
            end
        end

        btn.InputBegan:Connect(onInputBegan)
        btn.InputChanged:Connect(onInputChanged)
        btn.InputEnded:Connect(onInputEnded)

        buttons[name] = {btn = btn, setActive = setActive, label = label}
        return setActive
    end

    for i, name in ipairs(buttonNames) do
        local text = buttonTexts[i]
        local callback
        if name == "DropBR" then
            callback = function(setActive)
                if autoBatEnabled then return end
                setActive(true)
                executeDropWithToggle(function(v)
                    if dropBrainrotSetVisual then dropBrainrotSetVisual(v) end
                end)
                task.delay(0.3, function() setActive(false) end)
            end
        elseif name == "AutoLeft" then
            callback = function(setActive)
                autoLeftEnabled = not autoLeftEnabled
                setActive(autoLeftEnabled)
                if autoLeftEnabled then startAutoLeft() else stopAutoLeft() end
                if autoLeftSetVisual then autoLeftSetVisual(autoLeftEnabled) end
                saveAllSettings()
            end
        elseif name == "AutoBat" then
            callback = function(setActive)
                if not autoBatEnabled then enableAutoBat() else disableAutoBat() end
                setActive(autoBatEnabled)
                saveAllSettings()
            end
        elseif name == "AutoRight" then
            callback = function(setActive)
                autoRightEnabled = not autoRightEnabled
                setActive(autoRightEnabled)
                if autoRightEnabled then startAutoRight() else stopAutoRight() end
                if autoRightSetVisual then autoRightSetVisual(autoRightEnabled) end
                saveAllSettings()
            end
        elseif name == "TpDown" then
            callback = function(setActive)
                runTPDown()
                setActive(true)
                task.delay(0.2, function() setActive(false) end)
            end
        elseif name == "Carry" then
            callback = function(setActive)
                if not speedMode then
                    speedMode = true; laggerToggled = false; laggerLevel = 1; setActive(true)
                    if buttons.Lagger1 and buttons.Lagger1.setActive then buttons.Lagger1.setActive(false) end
                    if buttons.Lagger2 and buttons.Lagger2.setActive then buttons.Lagger2.setActive(false) end
                else
                    speedMode = false; setActive(false)
                end
                refreshSpeedModeLabel()
                saveAllSettings()
            end
        elseif name == "Lagger1" then
            callback = function(setActive)
                if speedMode then speedMode = false; if mobSetCarry then mobSetCarry(false) end end
                if not laggerToggled or laggerLevel ~= 1 then
                    laggerToggled = true; laggerLevel = 1; setActive(true)
                    if buttons.Lagger2 and buttons.Lagger2.setActive then buttons.Lagger2.setActive(false) end
                else
                    laggerToggled = false; laggerLevel = 1; setActive(false)
                end
                refreshSpeedModeLabel()
                saveAllSettings()
            end
        elseif name == "Lagger2" then
            callback = function(setActive)
                if speedMode then speedMode = false; if mobSetCarry then mobSetCarry(false) end end
                if not laggerToggled or laggerLevel ~= 2 then
                    laggerToggled = true; laggerLevel = 2; setActive(true)
                    if buttons.Lagger1 and buttons.Lagger1.setActive then buttons.Lagger1.setActive(false) end
                else
                    laggerToggled = false; laggerLevel = 1; setActive(false)
                end
                refreshSpeedModeLabel()
                saveAllSettings()
            end
        end
        mobSetAutoBat = buttons.AutoBat and buttons.AutoBat.setActive
        mobSetAutoLeft = buttons.AutoLeft and buttons.AutoLeft.setActive
        mobSetAutoRight = buttons.AutoRight and buttons.AutoRight.setActive
        mobSetDropBR = buttons.DropBR and buttons.DropBR.setActive
        mobSetTpDown = buttons.TpDown and buttons.TpDown.setActive
        mobSetCarry = buttons.Carry and buttons.Carry.setActive
        mobSetLagger1 = buttons.Lagger1 and buttons.Lagger1.setActive
        mobSetLagger2 = buttons.Lagger2 and buttons.Lagger2.setActive

        local setActive = createButton(name, text, i-1, true, callback)
        if name == "AutoBat" then mobSetAutoBat = setActive end
        if name == "AutoLeft" then mobSetAutoLeft = setActive end
        if name == "AutoRight" then mobSetAutoRight = setActive end
        if name == "DropBR" then mobSetDropBR = setActive end
        if name == "TpDown" then mobSetTpDown = setActive end
        if name == "Carry" then mobSetCarry = setActive end
        if name == "Lagger1" then mobSetLagger1 = setActive end
        if name == "Lagger2" then mobSetLagger2 = setActive end
    end

    if buttons.AutoBat and buttons.AutoBat.setActive then buttons.AutoBat.setActive(autoBatEnabled) end
    if buttons.AutoLeft and buttons.AutoLeft.setActive then buttons.AutoLeft.setActive(autoLeftEnabled) end
    if buttons.AutoRight and buttons.AutoRight.setActive then buttons.AutoRight.setActive(autoRightEnabled) end
    if buttons.Carry and buttons.Carry.setActive then buttons.Carry.setActive(speedMode) end
    if buttons.Lagger1 and buttons.Lagger1.setActive then buttons.Lagger1.setActive(laggerToggled and laggerLevel == 1) end
    if buttons.Lagger2 and buttons.Lagger2.setActive then buttons.Lagger2.setActive(laggerToggled and laggerLevel == 2) end

    if savedMobilePanelPos then
        container.Position = UDim2.new(
            savedMobilePanelPos.XScale or 1,
            savedMobilePanelPos.XOffset or (-PANEL_W - 10),
            savedMobilePanelPos.YScale or 0,
            savedMobilePanelPos.YOffset or 0
        )
    end

    local draggingPanel = false
    local dragStartPos = nil
    local dragStartMousePos = nil
    local function startDragPanel(input)
        if uiLocked or _isDraggingButton or editModeEnabled then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingPanel = true
            dragStartPos = container.Position
            dragStartMousePos = input.Position
        end
    end
    local function onDragPanel(input)
        if not draggingPanel or uiLocked then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if dragStartPos and dragStartMousePos then
                local delta = input.Position - dragStartMousePos
                local newX = dragStartPos.X.Offset + delta.X
                local newY = dragStartPos.Y.Offset + delta.Y
                container.Position = UDim2.new(dragStartPos.X.Scale, newX, dragStartPos.Y.Scale, newY)
            end
        end
    end
    local function endDragPanel()
        if draggingPanel then
            draggingPanel = false
            savedMobilePanelPos = {
                XScale = container.Position.X.Scale,
                XOffset = container.Position.X.Offset,
                YScale = container.Position.Y.Scale,
                YOffset = container.Position.Y.Offset
            }
        end
        dragStartPos = nil
        dragStartMousePos = nil
    end
    container.InputBegan:Connect(startDragPanel)
    container.InputEnded:Connect(endDragPanel)
    UIS.InputChanged:Connect(onDragPanel)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            endDragPanel()
        end
    end)

    return panel
end

function createInstaResetFloatingButton()
    local ACCENT = Color3.fromRGB(255,255,255)
    local panel = Instance.new("ScreenGui")
    panel.Name = "InstaResetButton"
    panel.ResetOnSpawn = false
    panel.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    panel.DisplayOrder = 20
    pcall(function() if syn and syn.protect_gui then syn.protect_gui(panel) end end)
    if not pcall(function() panel.Parent = game:GetService("CoreGui") end) then
        panel.Parent = LP:WaitForChild("PlayerGui")
    end

    local btnFrame = Instance.new("Frame", panel)
    btnFrame.Size = UDim2.new(0, 60, 0, 60)
    btnFrame.Name = "Frame"
    if instaResetFloatingPos then
        btnFrame.Position = UDim2.new(instaResetFloatingPos.XScale or 1,
                                      instaResetFloatingPos.XOffset or (-MOBILE_PANEL_WIDTH - 10),
                                      instaResetFloatingPos.YScale or 0,
                                      instaResetFloatingPos.YOffset or (MOBILE_PANEL_HEIGHT + 10))
    else
        btnFrame.Position = UDim2.new(1, -MOBILE_PANEL_WIDTH - 10, 0, MOBILE_PANEL_HEIGHT + 10)
    end
    btnFrame.BackgroundColor3 = Color3.fromRGB(0,0,0)
    btnFrame.BackgroundTransparency = 0
    btnFrame.BorderSizePixel = 0
    btnFrame.ZIndex = 20
    Instance.new("UICorner", btnFrame).CornerRadius = UDim.new(0, 18)
    local label = Instance.new("TextLabel", btnFrame)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "RESET"
    label.TextColor3 = ACCENT
    label.Font = Enum.Font.GothamBlack
    label.TextSize = 12
    label.TextWrapped = true
    label.ZIndex = 21

    local function setActive(state)
        if state then
            TS:Create(btnFrame, TweenInfo.new(0.05, Enum.EasingStyle.Quad), {
                BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            }):Play()
            TS:Create(label, TweenInfo.new(0.05, Enum.EasingStyle.Quad), {
                TextColor3 = Color3.fromRGB(0, 0, 0)
            }):Play()
        else
            TS:Create(btnFrame, TweenInfo.new(0.08, Enum.EasingStyle.Quad), {
                BackgroundColor3 = Color3.fromRGB(0,0,0)
            }):Play()
            TS:Create(label, TweenInfo.new(0.08, Enum.EasingStyle.Quad), {
                TextColor3 = Color3.fromRGB(255,255,255)
            }):Play()
        end
    end

    local dragging = false; local hasMoved = false; local dragStart, startPos
    btnFrame.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = true; hasMoved = false; dragStart = inp.Position; startPos = btnFrame.Position
        end
    end)
    btnFrame.InputChanged:Connect(function(inp)
        if not dragging then return end
        if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
            local delta = inp.Position - dragStart
            if delta.Magnitude > 5 then hasMoved = true end
            if hasMoved and not uiLocked then
                btnFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                              startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end
    end)
    btnFrame.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            if dragging then
                if not hasMoved then
                    setActive(true)
                    instaReset()
                    if setInstaResetVisual then setInstaResetVisual(true) end
                    task.delay(0.2, function()
                        if setInstaResetVisual then setInstaResetVisual(false) end
                        setActive(false)
                    end)
                elseif not uiLocked and hasMoved then
                    instaResetFloatingPos = {
                        XScale = btnFrame.Position.X.Scale,
                        XOffset = btnFrame.Position.X.Offset,
                        YScale = btnFrame.Position.Y.Scale,
                        YOffset = btnFrame.Position.Y.Offset
                    }
                end
                dragging = false; hasMoved = false
            end
        end
    end)
    return panel
end

function createBypassFloatingButton()
    local ACCENT = Color3.fromRGB(255,255,255)
    local panel = Instance.new("ScreenGui")
    panel.Name = "BypassButton"
    panel.ResetOnSpawn = false
    panel.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    panel.DisplayOrder = 21
    pcall(function() if syn and syn.protect_gui then syn.protect_gui(panel) end end)
    if not pcall(function() panel.Parent = game:GetService("CoreGui") end) then
        panel.Parent = LP:WaitForChild("PlayerGui")
    end

    local btnFrame = Instance.new("Frame", panel)
    btnFrame.Size = UDim2.new(0, 60, 0, 60)
    btnFrame.Name = "Frame"
    if bypassFloatingPos then
        btnFrame.Position = UDim2.new(bypassFloatingPos.XScale or 1,
                                      bypassFloatingPos.XOffset or (-10 - 60),
                                      bypassFloatingPos.YScale or 0,
                                      bypassFloatingPos.YOffset or (MOBILE_PANEL_HEIGHT + 10))
    else
        btnFrame.Position = UDim2.new(1, -10 - 60, 0, MOBILE_PANEL_HEIGHT + 10)
    end
    btnFrame.BackgroundColor3 = bypassToggled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(0,0,0)
    btnFrame.BackgroundTransparency = 0
    btnFrame.BorderSizePixel = 0
    btnFrame.ZIndex = 20
    Instance.new("UICorner", btnFrame).CornerRadius = UDim.new(0, 18)
    local label = Instance.new("TextLabel", btnFrame)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "TP\nBAT"
    label.TextColor3 = bypassToggled and Color3.fromRGB(0,0,0) or Color3.fromRGB(255,255,255)
    label.Font = Enum.Font.GothamBlack
    label.TextSize = 11
    label.TextWrapped = true
    label.ZIndex = 21

    local function setActive(state)
        if state then
            TS:Create(btnFrame, TweenInfo.new(0.05, Enum.EasingStyle.Quad), {
                BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            }):Play()
            TS:Create(label, TweenInfo.new(0.05, Enum.EasingStyle.Quad), {
                TextColor3 = Color3.fromRGB(0, 0, 0)
            }):Play()
        else
            TS:Create(btnFrame, TweenInfo.new(0.08, Enum.EasingStyle.Quad), {
                BackgroundColor3 = Color3.fromRGB(0,0,0)
            }):Play()
            TS:Create(label, TweenInfo.new(0.08, Enum.EasingStyle.Quad), {
                TextColor3 = Color3.fromRGB(255,255,255)
            }):Play()
        end
    end

    local dragging = false; local hasMoved = false; local dragStart, startPos
    btnFrame.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = true; hasMoved = false; dragStart = inp.Position; startPos = btnFrame.Position
        end
    end)
    btnFrame.InputChanged:Connect(function(inp)
        if not dragging then return end
        if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
            local delta = inp.Position - dragStart
            if delta.Magnitude > 5 then hasMoved = true end
            if hasMoved and not uiLocked then
                btnFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                              startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end
    end)
    btnFrame.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            if dragging then
                if not hasMoved then
                    setActive(not bypassToggled)
                    toggleBypass()
                elseif not uiLocked and hasMoved then
                    bypassFloatingPos = {
                        XScale = btnFrame.Position.X.Scale,
                        XOffset = btnFrame.Position.X.Offset,
                        YScale = btnFrame.Position.Y.Scale,
                        YOffset = btnFrame.Position.Y.Offset
                    }
                end
                dragging = false; hasMoved = false
            end
        end
    end)
    bypassFloatingButton = panel
    return panel
end

function reapplyAllStates()
    if antiRagdollEnabled then setAntiRag(true) else setAntiRag(false) end

    if jumpEnabled then startJumpMode() else stopJumpMode() end

    if autoLeftEnabled then startAutoLeft() else stopAutoLeft() end
    if autoRightEnabled then startAutoRight() else stopAutoRight() end

    if autoBatEnabled then enableAutoBat() else disableAutoBat() end

    if bypassToggled then toggleBypass(true) else toggleBypass(false) end

    if bodyLockEnabled then
        startBodyLock()
    else
        stopBodyLock()
    end

    if autoTPDownEnabled then
        startAutoTPDown()
    else
        stopAutoTPDown()
    end

    if medusaCounterEnabled then
        setMedusaCounterState(true)
    else
        setMedusaCounterState(false)
    end

    if batCounterEnabled then
        startBatCounter()
    else
        stopBatCounter()
    end

    if espEnabled then toggleESP(true) else toggleESP(false) end

    if antiLagEnabled then enableAntiLag() else disableAntiLag() end

    if stretchEnabled then enableStretch() else disableStretch() end

    if setJumpVisual then setJumpVisual(jumpEnabled) end
    if setAntiRagVisual then setAntiRagVisual(antiRagdollEnabled) end
    if setAutoTPDownVisual then setAutoTPDownVisual(autoTPDownEnabled) end
    if bodyLockSetVisual then bodyLockSetVisual(bodyLockEnabled) end

    if CONFIG.AUTO_STEAL_ENABLED then
        pcall(startAutoStealSemi)
    else
        stopAutoSteal()
    end

    if currentAnimPack ~= "Off" then
        startAnimPack(currentAnimPack)
    else
        stopAnimPack()
    end
    if currentAccessoryPack and currentAccessoryPack ~= "Off" then
        applyAccessoryPack(currentAccessoryPack)
    end

    updateProgressBarVisibility()
    refreshSpeedModeLabel()
    applyBackgroundImage(currentBgIndex)

    saveAllSettings()
end

function updateUIFromLoaded()
    task.wait()
    if normalBox then normalBox.Text = tostring(NS) end
    if carryBox then carryBox.Text = tostring(CS) end
    if radInput then radInput.Text = tostring(CONFIG.STEAL_RANGE) end
    if laggerBox then laggerBox.Text = tostring(LAGGER_SPEED_1) end
    if lagger2Box then lagger2Box.Text = tostring(LAGGER_SPEED_2) end
    if autoTPHeightBox then autoTPHeightBox.Text = tostring(autoTPDownHeight) end
    if uiScaleBox then uiScaleBox.Text = tostring(uiScaleValue) end
    if _G.uiScaleValueLabel then _G.uiScaleValueLabel.Text = string.format("%.2f", uiScaleValue / 100) end
    if _G.buttonScaleValueLabel then _G.buttonScaleValueLabel.Text = string.format("%.2f", buttonScaleValue) end
    applyButtonScale(buttonScaleValue)
    if dropModeBtnRef then dropModeBtnRef.Text = dropMode == 1 and "Fling" or "Jump Drop" end
    if bodyLockRangeBox then bodyLockRangeBox.Text = tostring(bodyLockRange) end
    refreshSpeedModeLabel()

    for _, ref in ipairs(keyButtonRefs) do
        local entry = ref.entry
        local label = (entry.gp and entry.gp.Name) or (entry.kb and entry.kb.Name) or "None"
        ref.btn.Text = label
    end

    if savedProgressBarPos and pbFrame then
        pbFrame.Position = UDim2.new(
            savedProgressBarPos.XScale or 0.5,
            savedProgressBarPos.XOffset or -150,
            savedProgressBarPos.YScale or 1,
            savedProgressBarPos.YOffset or -50
        )
    end

    if uiLocked and setLockUIVisual then setLockUIVisual(true) end
    if editModeEnabled and setEditModeVisual then setEditModeVisual(true) end
    if antiRagdollEnabled then
        if setAntiRagVisual then setAntiRagVisual(true) end
        startAntiRagdoll()
    end
    if CONFIG.AUTO_STEAL_ENABLED and setInstaGrab then setInstaGrab(true); pcall(startAutoStealSemi) end
    if jumpEnabled then
        if setJumpVisual then setJumpVisual(true) end
        startJumpMode()
    else
        if setJumpVisual then setJumpVisual(false) end
    end

    if medusaCounterEnabled then
        if setMedusaVisual then setMedusaVisual(true) end
        if LP.Character then setupMedusa(LP.Character) end
    else
        if setMedusaVisual then setMedusaVisual(false) end
        stopMedusaCounter()
    end

    if batCounterEnabled then
        if setBatCounterVisual then setBatCounterVisual(true) end
        startBatCounter()
    else
        if setBatCounterVisual then setBatCounterVisual(false) end
        stopBatCounter()
    end

    if autoTPDownEnabled then
        if setAutoTPDownVisual then setAutoTPDownVisual(true) end
        startAutoTPDown()
    end
    if antiLagEnabled then
        if setAntiLagVisual then setAntiLagVisual(true) end
        enableAntiLag()
    else
        if setAntiLagVisual then setAntiLagVisual(false) end
        disableAntiLag()
    end
    if espEnabled then
        toggleESP(true)
        if setESPVIsual then setESPVIsual(true) end
    else
        toggleESP(false)
        if setESPVIsual then setESPVIsual(false) end
    end

    if stretchEnabled then
        enableStretch()
        if _G.stretchToggleSetter then _G.stretchToggleSetter(true) end
    else
        if _G.stretchToggleSetter then _G.stretchToggleSetter(false) end
    end

    if mobSetAutoBat then mobSetAutoBat(autoBatEnabled) end
    if mobSetAutoLeft then mobSetAutoLeft(autoLeftEnabled) end
    if mobSetAutoRight then mobSetAutoRight(autoRightEnabled) end
    if mobSetCarry then mobSetCarry(speedMode) end
    if mobSetLagger1 then mobSetLagger1(laggerToggled and laggerLevel == 1) end
    if mobSetLagger2 then mobSetLagger2(laggerToggled and laggerLevel == 2) end

    if bodyLockEnabled and bodyLockSetVisual then
        if _blSuppressCount == 0 then
            bodyLockSetVisual(true)
            startBodyLock()
        else
            bodyLockSetVisual(false)
        end
    end

    updateProgressBarVisibility()
    startEnemySpeed()

    if currentAccessoryPack and currentAccessoryPack ~= "Off" then
        task.wait(0.2)
        applyAccessoryPack(currentAccessoryPack)
    end
    if accSelectorLabel then
        accSelectorLabel.Text = currentAccessoryPack
    end
    applyBackgroundImage(currentBgIndex)
end

local function createNameTag()
    return
end

buildGui()

if loadAllSettings() then
    updateUIFromLoaded()
end

MobilePanel = createMobilePanel()
instaResetFloatingButton = createInstaResetFloatingButton()
bypassFloatingButton = createBypassFloatingButton()
applyButtonScale(buttonScaleValue)

if LP.Character then
    task.wait(0.1)
    while not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") or not LP.Character:FindFirstChildOfClass("Humanoid") do
        task.wait()
    end
    setupMovementAndIndicators(LP.Character)
    if currentAnimPack ~= "Off" then
        startAnimPack(currentAnimPack)
    end
    if currentAccessoryPack ~= "Off" then
        task.wait(0.3)
        applyAccessoryPack(currentAccessoryPack)
    end
    createNameTag()
end

LP.CharacterAdded:Connect(function(char)
    stopAutoSteal()
    stopAutoLeft()
    stopAutoRight()
    stopBatCounter()
    stopMedusaCounter()
    stopDropBrainrot()
    if autoBatEnabled then disableAutoBat() end
    if bypassToggled then stopBypassAimbot() end

    task.wait(0.1)
    while not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") or not LP.Character:FindFirstChildOfClass("Humanoid") do
        task.wait()
    end

    setupMovementAndIndicators(char)
    createNameTag()

    reapplyAllStates()

    updateProgressBarVisibility()
    refreshSpeedModeLabel()
end)

local lastLaggerToggle = 0
local LAGGER_COOLDOWN = 0.3

UIS.InputBegan:Connect(function(input, gpe)
    if _anyKeyListening then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        if gpe or UIS:GetFocusedTextBox() then return end
    elseif not isGamepadInput(input) then
        return
    end
    if not isBindableInput(input) then return end

    local kc = input.KeyCode
    if not kc then return end

    if kbMatch(KB.LaggerMode, kc) then
        if tick() - lastLaggerToggle >= LAGGER_COOLDOWN then
            lastLaggerToggle = tick()
            toggleLaggerCycle()
            saveAllSettings()
        end
        return
    end
    if kbMatch(KB.CarryToggle, kc) then toggleCarryMode(); saveAllSettings(); return end
    if kbMatch(KB.DropBrainrot, kc) then
        if not dropActive then
            if dropBrainrotSetVisual then dropBrainrotSetVisual(true) end
            executeDropWithToggle(dropBrainrotSetVisual)
        end
        return
    end
    if kbMatch(KB.TPFloor, kc) then runTPDown(); return end
    if kbMatch(KB.InstaReset, kc) then instaReset(); return end
    if kbMatch(KB.AutoLeft, kc) then
        autoLeftEnabled = not autoLeftEnabled
        if autoLeftEnabled then startAutoLeft() else stopAutoLeft() end
        if autoLeftSetVisual then autoLeftSetVisual(autoLeftEnabled) end
        if mobSetAutoLeft then mobSetAutoLeft(autoLeftEnabled) end
        saveAllSettings()
        return
    end
    if kbMatch(KB.AutoRight, kc) then
        autoRightEnabled = not autoRightEnabled
        if autoRightEnabled then startAutoRight() else stopAutoRight() end
        if autoRightSetVisual then autoRightSetVisual(autoRightEnabled) end
        if mobSetAutoRight then mobSetAutoRight(autoRightEnabled) end
        saveAllSettings()
        return
    end
    if kbMatch(KB.AutoBat, kc) then
        if not autoBatEnabled then
            enableAutoBat()
            if autoBatSetVisual then autoBatSetVisual(true) end
            if mobSetAutoBat then mobSetAutoBat(true) end
        else
            disableAutoBat()
            if autoBatSetVisual then autoBatSetVisual(false) end
            if mobSetAutoBat then mobSetAutoBat(false) end
        end
        saveAllSettings()
        return
    end
    if kbMatch(KB.Bypass, kc) then toggleBypass(); saveAllSettings(); return end
end)

task.spawn(function()
    while task.wait(30) do
        pcall(function()
            collectgarbage("collect")
            if #_G.Lust.Connections > 0 then
                for k, v in pairs(_G.Lust.Connections) do
                    if type(v) == "table" and #v == 0 then
                        _G.Lust.Connections[k] = nil
                    end
                end
            end
            if #enemySpeedLabels > 30 then
                for player in pairs(enemySpeedLabels) do
                    if not player or not player.Character then
                        enemySpeedLabels[player] = nil
                    end
                end
            end
        end)
    end
end)