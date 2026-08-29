--[[
    Raven Hub - Chill Dark/Red/Cyber Theme
    Optimized for readability with balanced contrast
]]

local Services = {
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    UIS = game:GetService("UserInputService"),
    TweenService = game:GetService("TweenService"),
    HttpService = game:GetService("HttpService"),
    Lighting = game:GetService("Lighting"),
    Stats = game:GetService("Stats"),
    NetworkClient = game:GetService("NetworkClient"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
}

local Players = Services.Players
local RunService = Services.RunService
local UIS = Services.UIS
local TweenService = Services.TweenService
local HttpService = Services.HttpService
local Lighting = Services.Lighting
local Stats = Services.Stats
local NetworkClient = Services.NetworkClient
local ReplicatedStorage = Services.ReplicatedStorage
local LP = Players.LocalPlayer
local PlayerGui = LP:WaitForChild("PlayerGui")

-- Sauvegarde des paramÃ¨tres d'Ã©clairage originaux
local OriginalLighting = {
    Technology = Lighting.Technology,
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    ExposureCompensation = Lighting.ExposureCompensation,
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    ColorShift_Top = Lighting.ColorShift_Top,
    ColorShift_Bottom = Lighting.ColorShift_Bottom,
    FogEnd = Lighting.FogEnd,
    FogStart = Lighting.FogStart,
    GlobalShadows = Lighting.GlobalShadows,
}

local function makeDraggable(guiObject)
    local dragging = false
    local dragStartPos = nil
    local startGuiPos = nil
    local dragInput = nil
    local function onInputBegan(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStartPos = input.Position
            startGuiPos = guiObject.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end
    local function onInputChanged(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end
    guiObject.InputBegan:Connect(onInputBegan)
    guiObject.InputChanged:Connect(onInputChanged)
    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStartPos
            guiObject.Position = UDim2.new(
                startGuiPos.X.Scale, startGuiPos.X.Offset + delta.X,
                startGuiPos.Y.Scale, startGuiPos.Y.Offset + delta.Y
            )
        end
    end)
end

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Datas = ReplicatedStorage:WaitForChild("Datas")
local Synchronizer = require(Packages:WaitForChild("Synchronizer"))
local AnimalsData = require(Datas:WaitForChild("Animals"))

-- Configuration du Speed Bypass
local SpeedBypassConfig = {
    Keybind = "V",
    Power = 90000,
    Version = "V1",
    LaggerKeybind = "L",
    LaggerVersion = "V1",
}

local State = {
    normalSpeed = 59, carrySpeed = 29,
    laggerModeEnabled = false, 
    laggerSpeed = 30,
    speedToggled = false, circleEnabled = false,
    infJumpEnabled = false, antiRagdollEnabled = false, fpsBoostEnabled = false,
    medusaCounterEnabled = false,
    skyMode = 0,  -- 0=Off, 1=Cyber, 2=Sakura, 3=Dark, 4=Galaxy, 5=Red, 6=SkyGround
    stretchResEnabled = false,
    guiVisible = true, isStealing = false, stealStartTime = nil,
    lastStealTick = 0, medusaLastUsed = 0, medusaDebounce = false,
    dropBrainrotActive = false, tpInProgress = false, tpUpDebounce = false,
    lastMoveDir = Vector3.new(0,0,0), animEnabled = false,
    floatingBtnsVisible = true,
    bypassGuiVisible = true,
    instaResetKey = "B",
    fov = 70,
    backgroundEnabled = false,
    backgroundIndex = 0,
    zombieModeEnabled = false,
    doubleJumpTpEnabled = false,
}

local Keys = {
    circle       = Enum.KeyCode.E,
    speed        = Enum.KeyCode.Q,
    guiHide      = Enum.KeyCode.RightControl,
    dropBrainrot = Enum.KeyCode.H,
    tpDown       = Enum.KeyCode.T,
    laggerToggle = Enum.KeyCode.R,
    instaReset   = Enum.KeyCode.B,
    doubleJumpTp = Enum.KeyCode.G,
}

local CONFIG = {
    AUTO_STEAL_ENABLED = false,
    HOLD_MIN = 1.3, HOLD_MAX = 3, ENTRY_DELAY = 0.3,
    COOLDOWN = 0.05, STEAL_RANGE = 100, PRIME_RANGE = 80,
}

local StealState = {
    active = false, startTime = 0, phase = "idle",
    label = "", lastResult = "", lastResultTime = 0,
    totalSteals = 0, failedSteals = 0,
}

local Cache = { allAnimals = {}, PromptMemory = {}, InternalSteal = {} }
local stealConnection = nil

local BarRefs = { gui = nil, fill = nil, label = nil, percent = nil, radius = nil }
local FloatingBtnsRefs = { carry = nil, lagger = nil, autoBat = nil }

local GuiToggleSetters = {}

local CONFIG_FILE = "CyberConfig.json"
local autoSaveScheduled = false
local function scheduleAutoSave()
    if autoSaveScheduled then return end
    autoSaveScheduled = true
    task.delay(0.3, function()
        autoSaveScheduled = false
        local cfg = {
            normalSpeed=State.normalSpeed, carrySpeed=State.carrySpeed,
            laggerSpeed=State.laggerSpeed,
            laggerModeEnabled=State.laggerModeEnabled,
            autoGrabEnabled=CONFIG.AUTO_STEAL_ENABLED,
            infJump=State.infJumpEnabled, antiRagdoll=State.antiRagdollEnabled,
            fpsBoost=State.fpsBoostEnabled, medusaCounter=State.medusaCounterEnabled,
            animEnabled=State.animEnabled,
            skyMode=State.skyMode,
            stretchResEnabled=State.stretchResEnabled,
            floatingBtnsVisible=State.floatingBtnsVisible,
            bypassGuiVisible=State.bypassGuiVisible,
            primeRange=CONFIG.PRIME_RANGE,
            circleKey=Keys.circle.Name, speedKey=Keys.speed.Name,
            guiHideKey=Keys.guiHide.Name, dropBrainrotKey=Keys.dropBrainrot.Name,
            tpDownKey=Keys.tpDown.Name, laggerToggleKey=Keys.laggerToggle.Name,
            instaResetKey=State.instaResetKey,
            fov=State.fov,
            backgroundEnabled=State.backgroundEnabled,
            backgroundIndex=State.backgroundIndex,
            zombieModeEnabled=State.zombieModeEnabled,
            doubleJumpTpEnabled=State.doubleJumpTpEnabled,
            doubleJumpTpKey=Keys.doubleJumpTp.Name,
            bypassKey = SpeedBypassConfig.Keybind,
            bypassPower = SpeedBypassConfig.Power,
            bypassVersion = SpeedBypassConfig.Version,
            bypassLaggerKey = SpeedBypassConfig.LaggerKeybind,
            bypassLaggerVersion = SpeedBypassConfig.LaggerVersion,
        }
        pcall(function() if writefile then writefile(CONFIG_FILE, HttpService:JSONEncode(cfg)) end end)
    end)
end

do
    local hasFile = false
    pcall(function() hasFile = isfile and isfile(CONFIG_FILE) end)
    if hasFile then
        local ok, cfg = pcall(function() return HttpService:JSONDecode(readfile(CONFIG_FILE)) end)
        if ok and cfg then
            if type(cfg.normalSpeed)=="number" then State.normalSpeed=cfg.normalSpeed end
            if type(cfg.carrySpeed)=="number" then State.carrySpeed=cfg.carrySpeed end
            if type(cfg.laggerSpeed)=="number" then State.laggerSpeed=cfg.laggerSpeed end
            if type(cfg.laggerModeEnabled)=="boolean" then State.laggerModeEnabled=cfg.laggerModeEnabled end
            if type(cfg.infJump)=="boolean" then State.infJumpEnabled=cfg.infJump end
            if type(cfg.antiRagdoll)=="boolean" then State.antiRagdollEnabled=cfg.antiRagdoll end
            if type(cfg.fpsBoost)=="boolean" then State.fpsBoostEnabled=cfg.fpsBoost end
            if type(cfg.medusaCounter)=="boolean" then State.medusaCounterEnabled=cfg.medusaCounter end
            if type(cfg.animEnabled)=="boolean" then State.animEnabled=cfg.animEnabled end
            if type(cfg.skyMode)=="number" then State.skyMode=cfg.skyMode end
            if type(cfg.stretchResEnabled)=="boolean" then State.stretchResEnabled=cfg.stretchResEnabled end
            if type(cfg.floatingBtnsVisible)=="boolean" then State.floatingBtnsVisible=cfg.floatingBtnsVisible end
            if type(cfg.bypassGuiVisible)=="boolean" then State.bypassGuiVisible=cfg.bypassGuiVisible end
            if type(cfg.primeRange)=="number" then CONFIG.PRIME_RANGE=math.clamp(cfg.primeRange,5,300) end
            if type(cfg.autoGrabEnabled)=="boolean" then CONFIG.AUTO_STEAL_ENABLED=cfg.autoGrabEnabled end
            if type(cfg.circleKey)=="string" and Enum.KeyCode[cfg.circleKey] then Keys.circle=Enum.KeyCode[cfg.circleKey] end
            if type(cfg.speedKey)=="string" and Enum.KeyCode[cfg.speedKey] then Keys.speed=Enum.KeyCode[cfg.speedKey] end
            if type(cfg.guiHideKey)=="string" and Enum.KeyCode[cfg.guiHideKey] then Keys.guiHide=Enum.KeyCode[cfg.guiHideKey] end
            if type(cfg.dropBrainrotKey)=="string" and Enum.KeyCode[cfg.dropBrainrotKey] then Keys.dropBrainrot=Enum.KeyCode[cfg.dropBrainrotKey] end
            if type(cfg.tpDownKey)=="string" and Enum.KeyCode[cfg.tpDownKey] then Keys.tpDown=Enum.KeyCode[cfg.tpDownKey] end
            if type(cfg.laggerToggleKey)=="string" and Enum.KeyCode[cfg.laggerToggleKey] then Keys.laggerToggle=Enum.KeyCode[cfg.laggerToggleKey] end
            if type(cfg.instaResetKey)=="string" then 
                State.instaResetKey=cfg.instaResetKey
                local keyCode = Enum.KeyCode[cfg.instaResetKey]
                if keyCode then
                    Keys.instaReset = keyCode
                else
                    Keys.instaReset = Enum.KeyCode.B
                    State.instaResetKey = "B"
                end
            end
            if type(cfg.fov)=="number" then State.fov=cfg.fov end
            if type(cfg.backgroundEnabled)=="boolean" then State.backgroundEnabled=cfg.backgroundEnabled end
            if type(cfg.backgroundIndex)=="number" then State.backgroundIndex=cfg.backgroundIndex end
            if type(cfg.zombieModeEnabled)=="boolean" then State.zombieModeEnabled=cfg.zombieModeEnabled end
            if type(cfg.doubleJumpTpEnabled)=="boolean" then State.doubleJumpTpEnabled=cfg.doubleJumpTpEnabled end
            if type(cfg.doubleJumpTpKey)=="string" and Enum.KeyCode[cfg.doubleJumpTpKey] then Keys.doubleJumpTp=Enum.KeyCode[cfg.doubleJumpTpKey] end
            if type(cfg.bypassKey)=="string" then SpeedBypassConfig.Keybind = cfg.bypassKey end
            if type(cfg.bypassPower)=="number" then SpeedBypassConfig.Power = cfg.bypassPower end
            if type(cfg.bypassVersion)=="string" then SpeedBypassConfig.Version = cfg.bypassVersion end
            if type(cfg.bypassLaggerKey)=="string" then SpeedBypassConfig.LaggerKeybind = cfg.bypassLaggerKey end
            if type(cfg.bypassLaggerVersion)=="string" then SpeedBypassConfig.LaggerVersion = cfg.bypassLaggerVersion end
        end
    end
end

local function getCurrentSpeed()
    local isLaggerMode = State.laggerModeEnabled
    local isCarryMode = State.speedToggled
    
    if isLaggerMode then
        return State.laggerSpeed
    end
    
    if isCarryMode then
        return State.carrySpeed
    else
        return State.normalSpeed
    end
end

local function toggleLaggerMode()
    State.laggerModeEnabled = not State.laggerModeEnabled
    if State.laggerModeEnabled then
        State.speedToggled = false
    end
    scheduleAutoSave()
    updateFloatingButtons()
    if GuiToggleSetters["laggerToggle"] then 
        GuiToggleSetters["laggerToggle"](State.laggerModeEnabled) 
    end
end

local FloatingBtnGuis = {}
local function applyFloatingBtnsVisibility(visible)
    State.floatingBtnsVisible = visible
    for _, sg in ipairs(FloatingBtnGuis) do if sg and sg.Parent then sg.Enabled = visible end end
    scheduleAutoSave()
end

local function updateFloatingButtons()
    if FloatingBtnsRefs.carry then
        FloatingBtnsRefs.carry.Text = "Carry: "..(State.speedToggled and "ON" or "OFF")
        FloatingBtnsRefs.carry.BackgroundColor3 = State.speedToggled and Color3.fromRGB(140,0,140) or Color3.fromRGB(18,12,20)
        FloatingBtnsRefs.carry.BackgroundTransparency = State.speedToggled and 0.3 or 0.15
    end
    if FloatingBtnsRefs.lagger then
        local text = State.laggerModeEnabled and "Lagger: ON" or "Lagger: OFF"
        FloatingBtnsRefs.lagger.Text = text
        FloatingBtnsRefs.lagger.BackgroundColor3 = State.laggerModeEnabled and Color3.fromRGB(140,0,140) or Color3.fromRGB(18,12,20)
        FloatingBtnsRefs.lagger.BackgroundTransparency = State.laggerModeEnabled and 0.3 or 0.15
    end
    if FloatingBtnsRefs.autoBat then
        FloatingBtnsRefs.autoBat.Text = "Auto Bat: "..(State.circleEnabled and "ON" or "OFF")
        FloatingBtnsRefs.autoBat.BackgroundColor3 = State.circleEnabled and Color3.fromRGB(140,0,140) or Color3.fromRGB(18,12,20)
        FloatingBtnsRefs.autoBat.BackgroundTransparency = State.circleEnabled and 0.3 or 0.15
    end
end

local stretchConnection = nil
local originalCFrame = nil

local function applyStretchRes()
    if stretchConnection then return end
    local Camera = workspace.CurrentCamera
    originalCFrame = Camera.CFrame
    stretchConnection = RunService.RenderStepped:Connect(function()
        if State.stretchResEnabled then
            local Camera = workspace.CurrentCamera
            Camera.CFrame = Camera.CFrame * CFrame.new(0, 0, 0, 1, 0, 0, 0, 0.65, 0, 0, 0, 1)
        end
    end)
end

local function stopStretchRes()
    if stretchConnection then
        stretchConnection:Disconnect()
        stretchConnection = nil
    end
    local Camera = workspace.CurrentCamera
    if originalCFrame then
        Camera.CFrame = originalCFrame
        originalCFrame = nil
    end
end

local function setStretchRes(enabled)
    State.stretchResEnabled = enabled
    if enabled then
        applyStretchRes()
    else
        stopStretchRes()
    end
    scheduleAutoSave()
    if GuiToggleSetters["stretchRes"] then
        GuiToggleSetters["stretchRes"](enabled)
    end
end

-- ============================================
-- FPS BOOST - FIXED VERSION
-- ============================================
local fpsConnection = nil
local originalFPSQuality = nil

local function applyFPSBoost()
    -- Remove FPS cap
    pcall(function() 
        setfpscap(999999999) 
    end)
    
    -- Disable throttle
    pcall(function()
        RunService:SetThrottleFpsEnabled(false)
    end)
    
    -- Save original quality and set to lowest
    pcall(function()
        local settings = game:GetService("UserSettings")
        local gameSettings = settings:GetService("UserGameSettings")
        originalFPSQuality = gameSettings.GraphicsQuality
        gameSettings:SetGraphicsQuality(1)
    end)
    
    -- Disable lighting effects
    pcall(function()
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        Lighting.Brightness = 1
        Lighting.EnvironmentDiffuseScale = 0
        Lighting.EnvironmentSpecularScale = 0
        
        for _, child in pairs(Lighting:GetChildren()) do
            if child:IsA('BloomEffect') or child:IsA('BlurEffect') or child:IsA('SunRaysEffect') then
                child.Enabled = false
            end
        end
    end)
    
    -- Disable particles and effects
    pcall(function()
        for _, descendant in pairs(workspace:GetDescendants()) do
            if descendant:IsA('ParticleEmitter') then
                descendant.Enabled = false
            elseif descendant:IsA('BasePart') then
                descendant.Material = Enum.Material.Plastic
                descendant.Reflectance = 0
                descendant.CastShadow = false
            elseif descendant:IsA('Decal') then
                descendant.Transparency = 1
            end
        end
    end)
    
    -- Set rendering quality
    pcall(function()
        settings().Rendering.QualityLevel = 1
    end)
    
    -- Start the FPS loop
    if not fpsConnection then
        fpsConnection = RunService.RenderStepped:Connect(function()
            if State.fpsBoostEnabled then
                pcall(function() setfpscap(999999999) end)
            end
        end)
    end
end

local function disableFPSBoost()
    -- Reset FPS cap
    pcall(function() 
        setfpscap(60) 
    end)
    
    -- Enable throttle
    pcall(function()
        RunService:SetThrottleFpsEnabled(true)
    end)
    
    -- Restore graphics quality
    pcall(function()
        local settings = game:GetService("UserSettings")
        local gameSettings = settings:GetService("UserGameSettings")
        if originalFPSQuality then
            gameSettings:SetGraphicsQuality(originalFPSQuality)
        else
            gameSettings:SetGraphicsQuality(2)
        end
    end)
    
    -- Restore lighting
    pcall(function()
        Lighting.GlobalShadows = OriginalLighting.GlobalShadows
        Lighting.FogEnd = OriginalLighting.FogEnd
        Lighting.Brightness = OriginalLighting.Brightness
        Lighting.EnvironmentDiffuseScale = 1
        Lighting.EnvironmentSpecularScale = 1
        
        for _, child in pairs(Lighting:GetChildren()) do
            if child:IsA('BloomEffect') or child:IsA('BlurEffect') or child:IsA('SunRaysEffect') then
                child.Enabled = true
            end
        end
    end)
    
    -- Stop FPS loop
    if fpsConnection then
        fpsConnection:Disconnect()
        fpsConnection = nil
    end
end

-- ============================================
-- UI BACKGROUND IMAGES
-- ============================================
local BG_IMAGES = {
    [1] = "111530810423203",
    [2] = "121253258902365",
    [3] = "106051123817603",
    [4] = "84648545412824",
    [5] = "82848490732343",
}

-- ============================================
-- CHILL THEME SKY EFFECTS
-- Balanced dark/red/cyber with reduced intensity
-- ============================================

-- SAVE ORIGINAL SKY SETTINGS
local originalSky = {
    Sky = nil,
    Bloom = nil,
    ColorCorrection = nil,
    Atmosphere = nil,
}

local function saveOriginalSkyObjects()
    for _, v in ipairs(Lighting:GetChildren()) do
        if v:IsA("Sky") then originalSky.Sky = v end
        if v:IsA("BloomEffect") then originalSky.Bloom = v end
        if v:IsA("ColorCorrectionEffect") then originalSky.ColorCorrection = v end
        if v:IsA("Atmosphere") then originalSky.Atmosphere = v end
    end
end

local function clearSkyEffects()
    for _, v in ipairs(Lighting:GetChildren()) do
        if v:IsA("Sky") or v:IsA("BloomEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("Atmosphere") or v:IsA("SunRaysEffect") then
            if v ~= originalSky.Sky and v ~= originalSky.Bloom and v ~= originalSky.ColorCorrection and v ~= originalSky.Atmosphere then
                v:Destroy()
            end
        end
    end
end

-- CHILL DARK SKY (Balanced, not too dark)
local function applyChillDarkSky()
    clearSkyEffects()
    
    Lighting.Technology = Enum.Technology.Future
    Lighting.Brightness = 0.8
    Lighting.ExposureCompensation = 0.1
    Lighting.Ambient = Color3.fromRGB(25, 22, 30)
    Lighting.OutdoorAmbient = Color3.fromRGB(20, 18, 25)
    Lighting.ColorShift_Top = Color3.fromRGB(40, 30, 55)
    Lighting.ColorShift_Bottom = Color3.fromRGB(20, 18, 30)
    Lighting.FogEnd = 800
    Lighting.FogStart = 180
    Lighting.GlobalShadows = true
    
    local sky = Instance.new("Sky")
    sky.Name = "ChillDarkSky"
    sky.SkyboxBk = "rbxassetid://9994573642"
    sky.SkyboxDn = "rbxassetid://9994573642"
    sky.SkyboxFt = "rbxassetid://9994573642"
    sky.SkyboxLf = "rbxassetid://9994573642"
    sky.SkyboxRt = "rbxassetid://9994573642"
    sky.SkyboxUp = "rbxassetid://9994573642"
    sky.Parent = Lighting
    
    local bloom = Instance.new("BloomEffect")
    bloom.Name = "ChillDarkBloom"
    bloom.Intensity = 0.15
    bloom.Size = 25
    bloom.Threshold = 0.85
    bloom.Parent = Lighting
    
    local cc = Instance.new("ColorCorrectionEffect")
    cc.Name = "ChillDarkCC"
    cc.Brightness = -0.05
    cc.Contrast = 0.1
    cc.Saturation = -0.1
    cc.TintColor = Color3.fromRGB(50, 35, 65)
    cc.Parent = Lighting
    
    local atmo = Instance.new("Atmosphere")
    atmo.Name = "ChillDarkAtmo"
    atmo.Density = 0.4
    atmo.Offset = 0.15
    atmo.Color = Color3.fromRGB(40, 30, 55)
    atmo.Decay = Color3.fromRGB(25, 18, 35)
    atmo.Glare = 0.15
    atmo.Haze = 0.6
    atmo.Parent = Lighting
end

-- CHILL CYBER SKY (Neon but not overwhelming)
local function applyChillCyberSky()
    clearSkyEffects()
    
    Lighting.Technology = Enum.Technology.Future
    Lighting.Brightness = 1.0
    Lighting.ExposureCompensation = 0.05
    Lighting.Ambient = Color3.fromRGB(20, 15, 30)
    Lighting.OutdoorAmbient = Color3.fromRGB(30, 20, 45)
    Lighting.ColorShift_Top = Color3.fromRGB(80, 180, 220)
    Lighting.ColorShift_Bottom = Color3.fromRGB(160, 40, 200)
    Lighting.FogEnd = 700
    Lighting.FogStart = 150
    Lighting.GlobalShadows = true
    
    local sky = Instance.new("Sky")
    sky.Name = "ChillCyberSky"
    sky.SkyboxBk = "rbxassetid://9994573642"
    sky.SkyboxDn = "rbxassetid://9994573642"
    sky.SkyboxFt = "rbxassetid://9994573642"
    sky.SkyboxLf = "rbxassetid://9994573642"
    sky.SkyboxRt = "rbxassetid://9994573642"
    sky.SkyboxUp = "rbxassetid://9994573642"
    sky.Parent = Lighting
    
    local bloom = Instance.new("BloomEffect")
    bloom.Name = "ChillCyberBloom"
    bloom.Intensity = 0.4
    bloom.Size = 45
    bloom.Threshold = 0.5
    bloom.Parent = Lighting
    
    local cc = Instance.new("ColorCorrectionEffect")
    cc.Name = "ChillCyberCC"
    cc.Brightness = 0.05
    cc.Contrast = 0.15
    cc.Saturation = 0.25
    cc.TintColor = Color3.fromRGB(80, 180, 220)
    cc.Parent = Lighting
    
    local atmo = Instance.new("Atmosphere")
    atmo.Name = "ChillCyberAtmo"
    atmo.Density = 0.25
    atmo.Offset = 0.08
    atmo.Color = Color3.fromRGB(80, 180, 220)
    atmo.Decay = Color3.fromRGB(120, 40, 160)
    atmo.Glare = 0.35
    atmo.Haze = 0.35
    atmo.Parent = Lighting
end

-- CHILL RED SKY (Aggressive but balanced)
local function applyChillRedSky()
    clearSkyEffects()
    
    Lighting.Technology = Enum.Technology.Future
    Lighting.Brightness = 1.5
    Lighting.ExposureCompensation = 0.05
    Lighting.Ambient = Color3.fromRGB(35, 18, 18)
    Lighting.OutdoorAmbient = Color3.fromRGB(50, 22, 22)
    Lighting.ColorShift_Top = Color3.fromRGB(180, 60, 60)
    Lighting.ColorShift_Bottom = Color3.fromRGB(100, 30, 30)
    Lighting.FogEnd = 850
    Lighting.FogStart = 200
    Lighting.GlobalShadows = true
    
    local sky = Instance.new("Sky")
    sky.Name = "ChillRedSky"
    sky.SkyboxBk = "rbxassetid://10747336532"
    sky.SkyboxDn = "rbxassetid://10747336532"
    sky.SkyboxFt = "rbxassetid://10747336532"
    sky.SkyboxLf = "rbxassetid://10747336532"
    sky.SkyboxRt = "rbxassetid://10747336532"
    sky.SkyboxUp = "rbxassetid://10747336532"
    sky.Parent = Lighting
    
    local bloom = Instance.new("BloomEffect")
    bloom.Name = "ChillRedBloom"
    bloom.Intensity = 0.35
    bloom.Size = 35
    bloom.Threshold = 0.65
    bloom.Parent = Lighting
    
    local cc = Instance.new("ColorCorrectionEffect")
    cc.Name = "ChillRedCC"
    cc.Brightness = 0.02
    cc.Contrast = 0.12
    cc.Saturation = 0.15
    cc.TintColor = Color3.fromRGB(200, 60, 60)
    cc.Parent = Lighting
    
    local atmo = Instance.new("Atmosphere")
    atmo.Name = "ChillRedAtmo"
    atmo.Density = 0.35
    atmo.Offset = 0.12
    atmo.Color = Color3.fromRGB(180, 60, 60)
    atmo.Decay = Color3.fromRGB(100, 30, 30)
    atmo.Glare = 0.25
    atmo.Haze = 0.55
    atmo.Parent = Lighting
end

-- CHILL GALAXY SKY (Softer cosmic)
local function applyChillGalaxySky()
    clearSkyEffects()
    
    Lighting.Technology = Enum.Technology.Future
    Lighting.Brightness = 1.2
    Lighting.ExposureCompensation = 0.1
    Lighting.Ambient = Color3.fromRGB(28, 18, 45)
    Lighting.OutdoorAmbient = Color3.fromRGB(40, 25, 60)
    Lighting.ColorShift_Top = Color3.fromRGB(120, 70, 200)
    Lighting.ColorShift_Bottom = Color3.fromRGB(60, 30, 120)
    Lighting.FogEnd = 750
    Lighting.FogStart = 160
    Lighting.GlobalShadows = true
    
    local sky = Instance.new("Sky")
    sky.Name = "ChillGalaxySky"
    sky.SkyboxBk = "rbxassetid://9994573642"
    sky.SkyboxDn = "rbxassetid://9994573642"
    sky.SkyboxFt = "rbxassetid://9994573642"
    sky.SkyboxLf = "rbxassetid://9994573642"
    sky.SkyboxRt = "rbxassetid://9994573642"
    sky.SkyboxUp = "rbxassetid://9994573642"
    sky.Parent = Lighting
    
    local bloom = Instance.new("BloomEffect")
    bloom.Name = "ChillGalaxyBloom"
    bloom.Intensity = 0.3
    bloom.Size = 40
    bloom.Threshold = 0.7
    bloom.Parent = Lighting
    
    local cc = Instance.new("ColorCorrectionEffect")
    cc.Name = "ChillGalaxyCC"
    cc.Brightness = 0.05
    cc.Contrast = 0.08
    cc.Saturation = 0.2
    cc.TintColor = Color3.fromRGB(120, 70, 200)
    cc.Parent = Lighting
    
    local atmo = Instance.new("Atmosphere")
    atmo.Name = "ChillGalaxyAtmo"
    atmo.Density = 0.3
    atmo.Offset = 0.1
    atmo.Color = Color3.fromRGB(120, 70, 200)
    atmo.Decay = Color3.fromRGB(70, 35, 130)
    atmo.Glare = 0.25
    atmo.Haze = 0.45
    atmo.Parent = Lighting
end

-- CHILL SAKURA SKY (Soft pink)
local function applyChillSakuraSky()
    clearSkyEffects()
    
    Lighting.Technology = Enum.Technology.Future
    Lighting.Brightness = 1.8
    Lighting.ExposureCompensation = 0.08
    Lighting.Ambient = Color3.fromRGB(70, 55, 70)
    Lighting.OutdoorAmbient = Color3.fromRGB(90, 65, 90)
    Lighting.ColorShift_Top = Color3.fromRGB(220, 140, 180)
    Lighting.ColorShift_Bottom = Color3.fromRGB(180, 100, 140)
    Lighting.FogEnd = 750
    Lighting.FogStart = 160
    Lighting.GlobalShadows = true
    
    local sky = Instance.new("Sky")
    sky.Name = "ChillSakuraSky"
    sky.SkyboxBk = "rbxassetid://10174567842"
    sky.SkyboxDn = "rbxassetid://10174567842"
    sky.SkyboxFt = "rbxassetid://10174567842"
    sky.SkyboxLf = "rbxassetid://10174567842"
    sky.SkyboxRt = "rbxassetid://10174567842"
    sky.SkyboxUp = "rbxassetid://10174567842"
    sky.Parent = Lighting
    
    local bloom = Instance.new("BloomEffect")
    bloom.Name = "ChillSakuraBloom"
    bloom.Intensity = 0.3
    bloom.Size = 35
    bloom.Threshold = 0.75
    bloom.Parent = Lighting
    
    local cc = Instance.new("ColorCorrectionEffect")
    cc.Name = "ChillSakuraCC"
    cc.Brightness = 0.03
    cc.Contrast = 0.05
    cc.Saturation = 0.1
    cc.TintColor = Color3.fromRGB(220, 140, 180)
    cc.Parent = Lighting
    
    local atmo = Instance.new("Atmosphere")
    atmo.Name = "ChillSakuraAtmo"
    atmo.Density = 0.3
    atmo.Offset = 0.1
    atmo.Color = Color3.fromRGB(220, 150, 190)
    atmo.Decay = Color3.fromRGB(140, 70, 110)
    atmo.Glare = 0.15
    atmo.Haze = 0.5
    atmo.Parent = Lighting
end

-- CHILL SKY GROUND
local function applyChillSkyGroundSky()
    clearSkyEffects()
    
    Lighting.Technology = Enum.Technology.Future
    Lighting.Brightness = 2.0
    Lighting.ExposureCompensation = 0.1
    Lighting.Ambient = Color3.fromRGB(50, 55, 70)
    Lighting.OutdoorAmbient = Color3.fromRGB(65, 70, 85)
    Lighting.ColorShift_Top = Color3.fromRGB(120, 160, 230)
    Lighting.ColorShift_Bottom = Color3.fromRGB(70, 110, 200)
    Lighting.FogEnd = 1000
    Lighting.FogStart = 250
    Lighting.GlobalShadows = true
    
    local sky = Instance.new("Sky")
    sky.Name = "ChillSkyGroundSky"
    sky.SkyboxBk = "rbxassetid://11345048622"
    sky.SkyboxDn = "rbxassetid://11345048622"
    sky.SkyboxFt = "rbxassetid://11345048622"
    sky.SkyboxLf = "rbxassetid://11345048622"
    sky.SkyboxRt = "rbxassetid://11345048622"
    sky.SkyboxUp = "rbxassetid://11345048622"
    sky.Parent = Lighting
    
    local bloom = Instance.new("BloomEffect")
    bloom.Name = "ChillSkyGroundBloom"
    bloom.Intensity = 0.2
    bloom.Size = 30
    bloom.Threshold = 0.8
    bloom.Parent = Lighting
    
    local cc = Instance.new("ColorCorrectionEffect")
    cc.Name = "ChillSkyGroundCC"
    cc.Brightness = 0.03
    cc.Contrast = 0.05
    cc.Saturation = 0.08
    cc.TintColor = Color3.fromRGB(120, 160, 230)
    cc.Parent = Lighting
    
    local atmo = Instance.new("Atmosphere")
    atmo.Name = "ChillSkyGroundAtmo"
    atmo.Density = 0.2
    atmo.Offset = 0.05
    atmo.Color = Color3.fromRGB(120, 160, 230)
    atmo.Decay = Color3.fromRGB(70, 100, 170)
    atmo.Glare = 0.1
    atmo.Haze = 0.35
    atmo.Parent = Lighting
end

local function restoreOriginalSky()
    clearSkyEffects()
    Lighting.Technology = OriginalLighting.Technology
    Lighting.Brightness = OriginalLighting.Brightness
    Lighting.ClockTime = OriginalLighting.ClockTime
    Lighting.ExposureCompensation = OriginalLighting.ExposureCompensation
    Lighting.Ambient = OriginalLighting.Ambient
    Lighting.OutdoorAmbient = OriginalLighting.OutdoorAmbient
    Lighting.ColorShift_Top = OriginalLighting.ColorShift_Top
    Lighting.ColorShift_Bottom = OriginalLighting.ColorShift_Bottom
    Lighting.FogEnd = OriginalLighting.FogEnd
    Lighting.FogStart = OriginalLighting.FogStart
    Lighting.GlobalShadows = OriginalLighting.GlobalShadows
end

-- MAIN SKY CONTROLLER
local skyClockTimeConnection = nil

local function applySkyMode(mode)
    if skyClockTimeConnection then
        skyClockTimeConnection:Disconnect()
        skyClockTimeConnection = nil
    end
    
    if mode == 0 then
        restoreOriginalSky()
    elseif mode == 1 then
        applyChillCyberSky()
    elseif mode == 2 then
        applyChillSakuraSky()
    elseif mode == 3 then
        applyChillDarkSky()
    elseif mode == 4 then
        applyChillGalaxySky()
    elseif mode == 5 then
        applyChillRedSky()
    elseif mode == 6 then
        applyChillSkyGroundSky()
    end
    State.skyMode = mode
    scheduleAutoSave()
end

local function getSkyModeText()
    local modes = {
        [0] = "Off",
        [1] = "Cyber",
        [2] = "Sakura",
        [3] = "Dark Mode",
        [4] = "Galaxy",
        [5] = "Red Theme",
        [6] = "Sky Ground",
    }
    return modes[State.skyMode] or "Off"
end

local function nextSkyMode()
    local newMode = (State.skyMode + 1) % 7
    applySkyMode(newMode)
    return getSkyModeText()
end

-- ANIMATION REMBEMBI
local RembembiAnims = {
    WalkAnim = 73718308412641,
    RunAnim = 135515454877967,
    JumpAnim = 78508480717326,
    FallAnim = 78147885297412,
    SwimIdle = 129183123083281,
    Swim = 110657013921774,
    ClimbAnim = 129447497744818,
    Animation1 = 92849173543269,
    Animation2 = 132238900951109,
}

local AnimRefs = { heartbeat=nil, savedAnimate=nil, originalAnims=nil }
local startAnimToggle, stopAnimToggle

do
    local function isRembembiAnim(id)
        if not id then return false end
        for _,v in pairs(RembembiAnims) do
            if v == id then return true end
        end
        return false
    end
    local function saveOriginalAnims(char)
        local animate = char:FindFirstChild("Animate")
        if not animate then return end
        local function g(obj) return obj and obj.AnimationId or nil end
        local ids = {
            walk = g(animate.walk and animate.walk.WalkAnim),
            run = g(animate.run and animate.run.RunAnim),
            jump = g(animate.jump and animate.jump.JumpAnim),
            fall = g(animate.fall and animate.fall.FallAnim),
            climb = g(animate.climb and animate.climb.ClimbAnim),
            swim = g(animate.swim and animate.swim.Swim),
            swimidle = g(animate.swimidle and animate.swimidle.SwimIdle),
            idle1 = g(animate.idle and animate.idle.Animation1),
            idle2 = g(animate.idle and animate.idle.Animation2),
        }
        if not isRembembiAnim(ids.walk) then
            AnimRefs.originalAnims = ids
        end
    end
    local function applyRembembiAnims(char)
        local animate = char:FindFirstChild("Animate")
        if not animate then return end
        local function s(obj, id)
            if obj then obj.AnimationId = "rbxassetid://" .. id end
        end
        s(animate.walk and animate.walk.WalkAnim, RembembiAnims.WalkAnim)
        s(animate.run and animate.run.RunAnim, RembembiAnims.RunAnim)
        s(animate.jump and animate.jump.JumpAnim, RembembiAnims.JumpAnim)
        s(animate.fall and animate.fall.FallAnim, RembembiAnims.FallAnim)
        s(animate.climb and animate.climb.ClimbAnim, RembembiAnims.ClimbAnim)
        s(animate.swim and animate.swim.Swim, RembembiAnims.Swim)
        s(animate.swimidle and animate.swimidle.SwimIdle, RembembiAnims.SwimIdle)
        s(animate.idle and animate.idle.Animation1, RembembiAnims.Animation1)
        s(animate.idle and animate.idle.Animation2, RembembiAnims.Animation2)
    end
    local function restoreOriginalAnims(char)
        local orig = AnimRefs.originalAnims
        if not orig then return end
        local animate = char:FindFirstChild("Animate")
        if not animate then return end
        local function s(obj, id)
            if obj and id then obj.AnimationId = id end
        end
        s(animate.walk and animate.walk.WalkAnim, orig.walk)
        s(animate.run and animate.run.RunAnim, orig.run)
        s(animate.jump and animate.jump.JumpAnim, orig.jump)
        s(animate.fall and animate.fall.FallAnim, orig.fall)
        s(animate.climb and animate.climb.ClimbAnim, orig.climb)
        s(animate.swim and animate.swim.Swim, orig.swim)
        s(animate.swimidle and animate.swimidle.SwimIdle, orig.swimidle)
        s(animate.idle and animate.idle.Animation1, orig.idle1)
        s(animate.idle and animate.idle.Animation2, orig.idle2)
    end
    function startAnimToggle()
        if AnimRefs.heartbeat then AnimRefs.heartbeat:Disconnect(); AnimRefs.heartbeat = nil end
        local char = LP.Character
        if char then saveOriginalAnims(char); applyRembembiAnims(char) end
        AnimRefs.heartbeat = RunService.Heartbeat:Connect(function()
            if not State.animEnabled then return end
            local c = LP.Character
            if c then applyRembembiAnims(c) end
        end)
    end
    function stopAnimToggle()
        if AnimRefs.heartbeat then AnimRefs.heartbeat:Disconnect(); AnimRefs.heartbeat = nil end
        local char = LP.Character
        if char then restoreOriginalAnims(char) end
    end
end

-- AUTO STEAL
local getMyPlotName, isMyBaseAnimal, findProximityPromptForAnimal
local getAnimalPosition, distToAnimal, pickClosest
local buildStealCallbacks, executeStealAsync, attemptSteal, scanAllPlots

do
    function getMyPlotName()
        local plots = workspace:FindFirstChild("Plots"); if not plots then return nil end
        for _, plot in ipairs(plots:GetChildren()) do
            local sign = plot:FindFirstChild("PlotSign"); if not sign then continue end
            local yourBase = sign:FindFirstChild("YourBase")
            if yourBase and yourBase:IsA("BillboardGui") and yourBase.Enabled then return plot.Name end
        end
        return nil
    end
    function isMyBaseAnimal(animalData)
        if not animalData or not animalData.plot then return false end
        local myPlot = getMyPlotName(); if not myPlot then return false end
        return animalData.plot == myPlot
    end
    function findProximityPromptForAnimal(animalData)
        if not animalData then return nil end
        local cached = Cache.PromptMemory[animalData.uid]
        if cached and cached.Parent then return cached end
        local plot = workspace.Plots:FindFirstChild(animalData.plot); if not plot then return nil end
        local podiums = plot:FindFirstChild("AnimalPodiums"); if not podiums then return nil end
        local podium = podiums:FindFirstChild(animalData.slot); if not podium then return nil end
        local base = podium:FindFirstChild("Base"); if not base then return nil end
        local spawn = base:FindFirstChild("Spawn"); if not spawn then return nil end
        local attach = spawn:FindFirstChild("PromptAttachment"); if not attach then return nil end
        for _, p in ipairs(attach:GetChildren()) do
            if p:IsA("ProximityPrompt") then Cache.PromptMemory[animalData.uid]=p; return p end
        end
        return nil
    end
    function getAnimalPosition(animalData)
        local plot = workspace.Plots:FindFirstChild(animalData.plot); if not plot then return nil end
        local podiums = plot:FindFirstChild("AnimalPodiums"); if not podiums then return nil end
        local podium = podiums:FindFirstChild(animalData.slot); if not podium then return nil end
        return podium:GetPivot().Position
    end
    function distToAnimal(animalData)
        local character = LP.Character; if not character then return math.huge end
        local hrp = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("UpperTorso")
        if not hrp then return math.huge end
        local pos = getAnimalPosition(animalData); if not pos then return math.huge end
        return (hrp.Position - pos).Magnitude
    end
    function pickClosest()
        local character = LP.Character; if not character then return nil end
        local hrp = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("UpperTorso")
        if not hrp then return nil end
        local best, bestDist = nil, math.huge
        for _, animalData in ipairs(Cache.allAnimals) do
            if isMyBaseAnimal(animalData) then continue end
            local pos = getAnimalPosition(animalData); if not pos then continue end
            local dist = (hrp.Position - pos).Magnitude
            if dist > CONFIG.PRIME_RANGE then continue end
            if dist < bestDist then bestDist=dist; best=animalData end
        end
        return best
    end
    function buildStealCallbacks(prompt)
        if Cache.InternalSteal[prompt] then return end
        local data = { holdCallbacks={}, triggerCallbacks={}, ready=true }
        local ok1, conns1 = pcall(getconnections, prompt.PromptButtonHoldBegan)
        if ok1 and type(conns1)=="table" then
            for _, conn in ipairs(conns1) do if type(conn.Function)=="function" then table.insert(data.holdCallbacks,conn.Function) end end
        end
        local ok2, conns2 = pcall(getconnections, prompt.Triggered)
        if ok2 and type(conns2)=="table" then
            for _, conn in ipairs(conns2) do if type(conn.Function)=="function" then table.insert(data.triggerCallbacks,conn.Function) end end
        end
        if (#data.holdCallbacks>0) or (#data.triggerCallbacks>0) then Cache.InternalSteal[prompt]=data end
    end
    function executeStealAsync(prompt, animalData)
        local data = Cache.InternalSteal[prompt]; if not data or not data.ready then return false end
        data.ready=false
        StealState.active=true; StealState.startTime=tick(); StealState.phase="holding"; StealState.label=animalData.name or "Animal"
        task.spawn(function()
            for _, fn in ipairs(data.holdCallbacks) do task.spawn(fn) end
            task.wait(CONFIG.HOLD_MIN)
            StealState.phase="waitingRange"
            local alreadyInRange = distToAnimal(animalData)<=CONFIG.STEAL_RANGE
            local fired=false
            while true do
                local elapsed=tick()-StealState.startTime
                if elapsed>CONFIG.HOLD_MAX then break end
                if not prompt.Parent then break end
                if distToAnimal(animalData)<=CONFIG.STEAL_RANGE then
                    if not alreadyInRange then task.wait(CONFIG.ENTRY_DELAY) end
                    for _, fn in ipairs(data.triggerCallbacks) do task.spawn(fn) end
                    fired=true; break
                end
                task.wait()
            end
            if fired then
                StealState.totalSteals=StealState.totalSteals+1
                StealState.lastResult="Stole "..(animalData.name or "")
            else
                StealState.failedSteals=StealState.failedSteals+1
                StealState.lastResult="Missed window: "..(animalData.name or "")
            end
            StealState.active=false; StealState.phase="idle"; StealState.lastResultTime=tick()
            task.wait(CONFIG.COOLDOWN); data.ready=true
        end)
        return true
    end
    function attemptSteal(prompt, animalData)
        if not prompt or not prompt.Parent then return false end
        if prompt.ObjectText==nil or prompt.ObjectText=="" then return false end
        buildStealCallbacks(prompt)
        if not Cache.InternalSteal[prompt] then return false end
        return executeStealAsync(prompt, animalData)
    end
    function scanAllPlots()
        local plots=workspace:FindFirstChild("Plots"); if not plots then return 0 end
        local newCache={}
        for _, plot in ipairs(plots:GetChildren()) do
            local podiums=plot:FindFirstChild("AnimalPodiums"); if not podiums then continue end
            for _, podium in ipairs(podiums:GetChildren()) do
                local base=podium:FindFirstChild("Base"); if not base then continue end
                local spawn=base:FindFirstChild("Spawn"); if not spawn then continue end
                local attach=spawn:FindFirstChild("PromptAttachment"); if not attach then continue end
                local hasPrompt=false
                for _, p in ipairs(attach:GetChildren()) do if p:IsA("ProximityPrompt") then hasPrompt=true; break end end
                if not hasPrompt then continue end
                local animalName=nil
                for _, child in ipairs(podium:GetChildren()) do
                    if child:IsA("Model") and AnimalsData[child.Name] then animalName=child.Name; break end
                end
                local slot=podium.Name
                table.insert(newCache,{
                    name=animalName and (AnimalsData[animalName].DisplayName or animalName) or slot,
                    plot=plot.Name, slot=slot, uid=plot.Name.."_"..slot,
                })
            end
        end
        Cache.allAnimals=newCache; return #Cache.allAnimals
    end
end

-- Couleurs - Chill Dark/Red/Cyber Theme
local C={
    bg=Color3.fromRGB(14,12,18),
    bgDark=Color3.fromRGB(18,14,22),
    row=Color3.fromRGB(22,18,28),
    input=Color3.fromRGB(22,18,28),
    blue=Color3.fromRGB(140,50,160),
    blueDim=Color3.fromRGB(100,40,120),
    blueDark=Color3.fromRGB(60,25,75),
    text=Color3.fromRGB(235,225,245),
    textDim=Color3.fromRGB(215,205,225),
    textMuted=Color3.fromRGB(190,180,200),
    white=Color3.fromRGB(255,255,255),
    divider=Color3.fromRGB(100,40,120),
    green=Color3.fromRGB(120,210,160),
    underline=Color3.fromRGB(140,50,160),
    red=Color3.fromRGB(200,60,60),
    cyber=Color3.fromRGB(80,200,240),
    darkBg=Color3.fromRGB(10,8,15),
}
local ADAPT_BLUE = C.blue

local createAutoStealBar, removeAutoStealBar
do
    function createAutoStealBar()
        if BarRefs.gui then return end
        local sg=Instance.new("ScreenGui"); sg.Name="AutoStealBar"; sg.ResetOnSpawn=false; sg.Parent=PlayerGui; sg.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
        BarRefs.gui=sg
        local container=Instance.new("Frame",sg); container.Size=UDim2.new(0,320,0,44); container.Position=UDim2.new(0.5,-160,1,-60)
        container.BackgroundColor3=C.bg; container.BorderSizePixel=0; container.Active=true; makeDraggable(container)
        Instance.new("UICorner",container).CornerRadius=UDim.new(1,0)
        local cs=Instance.new("UIStroke",container); cs.Color=ADAPT_BLUE; cs.Thickness=1.5; cs.Transparency=0.5
        BarRefs.label=Instance.new("TextLabel",container); BarRefs.label.Size=UDim2.new(0,54,1,0); BarRefs.label.Position=UDim2.new(0,14,0,0)
        BarRefs.label.BackgroundTransparency=1; BarRefs.label.Text="READY"; BarRefs.label.TextColor3=C.white
        BarRefs.label.Font=Enum.Font.GothamBlack; BarRefs.label.TextSize=13
        BarRefs.radius=Instance.new("TextLabel",container); BarRefs.radius.Size=UDim2.new(0,90,1,0); BarRefs.radius.Position=UDim2.new(1,-104,0,0)
        BarRefs.radius.BackgroundTransparency=1; BarRefs.radius.Text="Radius: "..CONFIG.PRIME_RANGE; BarRefs.radius.TextColor3=C.white
        BarRefs.radius.Font=Enum.Font.GothamBold; BarRefs.radius.TextSize=12; BarRefs.radius.TextXAlignment=Enum.TextXAlignment.Right
        local track=Instance.new("Frame",container); track.Size=UDim2.new(1,-28,0,7); track.Position=UDim2.new(0,14,1,-13)
        track.BackgroundColor3=C.darkBg; track.BorderSizePixel=0; Instance.new("UICorner",track).CornerRadius=UDim.new(1,0)
        BarRefs.fill=Instance.new("Frame",track); BarRefs.fill.Size=UDim2.new(0,0,1,0); BarRefs.fill.BackgroundColor3=ADAPT_BLUE; BarRefs.fill.BorderSizePixel=0
        Instance.new("UICorner",BarRefs.fill).CornerRadius=UDim.new(1,0)
        local fg=Instance.new("UIStroke",BarRefs.fill); fg.Color=ADAPT_BLUE; fg.Thickness=2; fg.Transparency=0.3
    end
    function removeAutoStealBar()
        if BarRefs.gui then BarRefs.gui:Destroy(); BarRefs.gui=nil; BarRefs.fill=nil; BarRefs.label=nil; BarRefs.percent=nil; BarRefs.radius=nil end
    end
end

do
    local lastFillPct=0
    RunService.RenderStepped:Connect(function(dt)
        if not BarRefs.fill then return end
        if BarRefs.radius then BarRefs.radius.Text="Radius: "..CONFIG.PRIME_RANGE end
        local active=StealState.active
        local justFinished=StealState.lastResultTime>0 and (tick()-StealState.lastResultTime)<1.2
        if active then
            local elapsed=tick()-StealState.startTime
            local targetPct=elapsed<CONFIG.HOLD_MIN and elapsed/CONFIG.HOLD_MIN or 1
            lastFillPct=lastFillPct+(targetPct-lastFillPct)*math.min(dt*14,1)
            BarRefs.fill.Size=UDim2.new(lastFillPct,0,1,0)
            if BarRefs.label then BarRefs.label.Text=math.floor(lastFillPct*100).."%" end
        elseif justFinished then
            lastFillPct=1; BarRefs.fill.Size=UDim2.new(1,0,1,0)
            local success=StealState.lastResult:find("Stole")
            if BarRefs.label then BarRefs.label.Text=success and "OK!" or "MISS" end
        else
            if lastFillPct~=0 then lastFillPct=0; BarRefs.fill.Size=UDim2.new(0,0,1,0); if BarRefs.label then BarRefs.label.Text="READY" end end
        end
    end)
end

local function startAutoSteal()
    if stealConnection then return end
    createAutoStealBar(); scanAllPlots()
    stealConnection=RunService.Heartbeat:Connect(function()
        if not CONFIG.AUTO_STEAL_ENABLED then return end
        if StealState.active then return end
        local target=pickClosest(); if not target then return end
        local prompt=Cache.PromptMemory[target.uid]
        if not prompt or not prompt.Parent then prompt=findProximityPromptForAnimal(target) end
        if prompt then attemptSteal(prompt,target) end
    end)
    task.spawn(function()
        while stealConnection do task.wait(5); if CONFIG.AUTO_STEAL_ENABLED then scanAllPlots() end end
    end)
end

local function stopAutoSteal()
    if stealConnection then stealConnection:Disconnect(); stealConnection=nil end
    removeAutoStealBar(); Cache.allAnimals={}; Cache.PromptMemory={}; Cache.InternalSteal={}
end

local function tpDown()
    local char=LP.Character; if not char then return end
    local root=char:FindFirstChild("HumanoidRootPart"); if not root then return end
    local params=RaycastParams.new(); params.FilterDescendantsInstances={char}; params.FilterType=Enum.RaycastFilterType.Blacklist
    local result=workspace:Raycast(root.Position,Vector3.new(0,-500,0),params)
    local targetY=result and (result.Position.Y+2.5) or (root.Position.Y-175)
    root.CFrame=CFrame.new(root.Position.X,targetY,root.Position.Z)
end

-- DOUBLE JUMP TP LOOP
local doubleJumpTpConnection = nil

local function tpUp()
    if State.tpUpDebounce then return end
    State.tpUpDebounce = true
    local char = LP.Character
    if not char then State.tpUpDebounce = false; return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then State.tpUpDebounce = false; return end
    local newPosition = root.Position + Vector3.new(0, 8.7, 0)
    root.CFrame = CFrame.new(newPosition)
    task.delay(0.37, function()
        State.tpUpDebounce = false
    end)
end

local function startDoubleJumpTpLoop()
    if doubleJumpTpConnection then return end
    State.doubleJumpTpEnabled = true
    doubleJumpTpConnection = task.spawn(function()
        while State.doubleJumpTpEnabled do
            local char = LP.Character
            if char then
                local root = char:FindFirstChild("HumanoidRootPart")
                if root then
                    root.Velocity = Vector3.new(root.Velocity.X, 52, root.Velocity.Z)
                    task.wait(0.08)
                    root.Velocity = Vector3.new(root.Velocity.X, 52, root.Velocity.Z)
                end
            end
            task.wait(0.1)
            tpUp()
            task.wait(0.18)
            tpDown()
            task.wait(0.15)
        end
        doubleJumpTpConnection = nil
    end)
end

local function stopDoubleJumpTpLoop()
    State.doubleJumpTpEnabled = false
    if doubleJumpTpConnection then
        doubleJumpTpConnection = nil
    end
end

local function toggleDoubleJumpTp()
    State.doubleJumpTpEnabled = not State.doubleJumpTpEnabled
    if State.doubleJumpTpEnabled then
        startDoubleJumpTpLoop()
    else
        stopDoubleJumpTpLoop()
    end
    scheduleAutoSave()
    return State.doubleJumpTpEnabled
end

-- INFINITE JUMP
local JumpRefs = { originalJumpPower=nil, spacePressed=false, heartbeat=nil }
local setInfJumpInternal
do
    local function applyInfiniteJumpHold()
        if JumpRefs.heartbeat then return end
        JumpRefs.heartbeat=RunService.Heartbeat:Connect(function()
            if not State.infJumpEnabled or not JumpRefs.spacePressed then return end
            local char=LP.Character; if not char then return end
            local root=char:FindFirstChild("HumanoidRootPart")
            if root then root.Velocity=Vector3.new(root.Velocity.X,52,root.Velocity.Z) end
        end)
    end
    local function stopInfiniteJumpHold()
        if JumpRefs.heartbeat then JumpRefs.heartbeat:Disconnect(); JumpRefs.heartbeat=nil end
    end
    function setInfJumpInternal(on)
        State.infJumpEnabled=on
        local char=LP.Character; if not char then return end
        local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return end
        if on then JumpRefs.originalJumpPower=hum.JumpPower; hum.JumpPower=0; if JumpRefs.spacePressed then applyInfiniteJumpHold() end
        else hum.JumpPower=JumpRefs.originalJumpPower or 50; stopInfiniteJumpHold() end
        scheduleAutoSave(); updateFloatingButtons()
    end
    UIS.InputBegan:Connect(function(input,gp)
        if gp then return end
        if input.KeyCode==Enum.KeyCode.Space then
            JumpRefs.spacePressed=true; if State.infJumpEnabled then applyInfiniteJumpHold() end
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.KeyCode==Enum.KeyCode.Space then JumpRefs.spacePressed=false end
    end)
    RunService.Heartbeat:Connect(function()
        if not State.infJumpEnabled then return end
        local char=LP.Character; if not char then return end
        local root=char:FindFirstChild("HumanoidRootPart")
        if root and root.Velocity.Y < -120 then root.Velocity=Vector3.new(root.Velocity.X,-120,root.Velocity.Z) end
    end)
end

-- MEDUSA COUNTER
local MEDUSA_COOLDOWN=25
local Conns={antiRag=nil,anchor={},circle=nil}
local setupMedusaCounter,stopMedusaCounter
do
    local function findMedusa()
        local char=LP.Character; if not char then return nil end
        for _,tool in ipairs(char:GetChildren()) do
            if tool:IsA("Tool") then local n=tool.Name:lower(); if n:find("medusa") or n:find("head") or n:find("stone") then return tool end end
        end
        local bp=LP:FindFirstChild("Backpack")
        if bp then for _,tool in ipairs(bp:GetChildren()) do
            if tool:IsA("Tool") then local n=tool.Name:lower(); if n:find("medusa") or n:find("head") or n:find("stone") then return tool end end
        end end
        return nil
    end
    local function useMedusaCounter()
        if State.medusaDebounce then return end
        if tick()-State.medusaLastUsed<MEDUSA_COOLDOWN then return end
        local char=LP.Character; if not char then return end
        State.medusaDebounce=true
        local med=findMedusa()
        if med then
            if med.Parent~=char then local hum=char:FindFirstChildOfClass("Humanoid"); if hum then hum:EquipTool(med) end end
            pcall(function() med:Activate() end); State.medusaLastUsed=tick()
        end
        State.medusaDebounce=false
    end
    local function onAnchorChanged(part)
        return part:GetPropertyChangedSignal("Anchored"):Connect(function()
            if part.Anchored and part.Transparency==1 then useMedusaCounter() end
        end)
    end
    function stopMedusaCounter()
        for _,c in ipairs(Conns.anchor) do pcall(function() c:Disconnect() end) end; Conns.anchor={}
    end
    function setupMedusaCounter(char)
        stopMedusaCounter(); if not char then return end
        for _,part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then table.insert(Conns.anchor,onAnchorChanged(part)) end
        end
        table.insert(Conns.anchor,char.DescendantAdded:Connect(function(part)
            if part:IsA("BasePart") then table.insert(Conns.anchor,onAnchorChanged(part)) end
        end))
    end
end

-- DROP BRAINROT
local _wfConns={}
local function runDropBrainrot()
    if State.dropBrainrotActive then return end
    if State.circleEnabled then
        State.circleEnabled=false
        if GuiToggleSetters["circle"] then GuiToggleSetters["circle"](false) end
        stopCircle()
    end
    State.dropBrainrotActive=true
    local colConn=RunService.Stepped:Connect(function()
        if not State.dropBrainrotActive then return end
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=LP and p.Character then
                for _,part in ipairs(p.Character:GetChildren()) do
                    if part:IsA("BasePart") then part.CanCollide=false end
                end
            end
        end
    end)
    table.insert(_wfConns,colConn)
    local flingThread=coroutine.create(function()
        while State.dropBrainrotActive do
            RunService.Heartbeat:Wait()
            local c=LP.Character
            local root=c and c:FindFirstChild("HumanoidRootPart")
            if not root then break end
            local vel=root.Velocity
            root.Velocity=vel*10000+Vector3.new(0,10000,0)
            RunService.RenderStepped:Wait()
            if root and root.Parent then root.Velocity=vel end
            RunService.Stepped:Wait()
            if root and root.Parent then root.Velocity=vel+Vector3.new(0,0.1,0) end
        end
    end)
    table.insert(_wfConns,flingThread)
    coroutine.resume(flingThread)
    task.delay(0.1,function()
        State.dropBrainrotActive=false
        for _,c in ipairs(_wfConns) do
            if typeof(c)=="RBXScriptConnection" then c:Disconnect()
            elseif type(c)=="thread" then pcall(coroutine.close,c) end
        end
        _wfConns={}
    end)
end

-- ZOMBIE MODE
local ZombieAnims = {
    WalkAnim = 10921355261,
    RunAnim = 616163682,
    JumpAnim = 10921351278,
    FallAnim = 10921350320,
    SwimIdle = 10921353442,
    Swim = 10921352344,
    Animation1 = 10921344533,
    Animation2 = 10921345304,
    ClimbAnim = 10921343576,
}

local ZombieRefs = { heartbeat = nil, originalAnims = nil }

local function saveOriginalAnimsZombie(char)
    local animate = char:FindFirstChild("Animate")
    if not animate then return end
    local function g(obj) return obj and obj.AnimationId or nil end
    ZombieRefs.originalAnims = {
        walk = g(animate.walk and animate.walk.WalkAnim),
        run = g(animate.run and animate.run.RunAnim),
        jump = g(animate.jump and animate.jump.JumpAnim),
        fall = g(animate.fall and animate.fall.FallAnim),
        swimidle = g(animate.swimidle and animate.swimidle.SwimIdle),
        swim = g(animate.swim and animate.swim.Swim),
        idle1 = g(animate.idle and animate.idle.Animation1),
        idle2 = g(animate.idle and animate.idle.Animation2),
        climb = g(animate.climb and animate.climb.ClimbAnim),
    }
end

local function applyZombieAnims(char)
    local animate = char:FindFirstChild("Animate")
    if not animate then return end
    local function s(obj, id) if obj then obj.AnimationId = "rbxassetid://" .. id end end
    s(animate.walk and animate.walk.WalkAnim, ZombieAnims.WalkAnim)
    s(animate.run and animate.run.RunAnim, ZombieAnims.RunAnim)
    s(animate.jump and animate.jump.JumpAnim, ZombieAnims.JumpAnim)
    s(animate.fall and animate.fall.FallAnim, ZombieAnims.FallAnim)
    s(animate.swimidle and animate.swimidle.SwimIdle, ZombieAnims.SwimIdle)
    s(animate.swim and animate.swim.Swim, ZombieAnims.Swim)
    s(animate.idle and animate.idle.Animation1, ZombieAnims.Animation1)
    s(animate.idle and animate.idle.Animation2, ZombieAnims.Animation2)
    s(animate.climb and animate.climb.ClimbAnim, ZombieAnims.ClimbAnim)
end

local function restoreOriginalAnimsZombie(char)
    local orig = ZombieRefs.originalAnims
    if not orig then return end
    local animate = char:FindFirstChild("Animate")
    if not animate then return end
    local function s(obj, id) if obj and id then obj.AnimationId = id end end
    s(animate.walk and animate.walk.WalkAnim, orig.walk)
    s(animate.run and animate.run.RunAnim, orig.run)
    s(animate.jump and animate.jump.JumpAnim, orig.jump)
    s(animate.fall and animate.fall.FallAnim, orig.fall)
    s(animate.swimidle and animate.swimidle.SwimIdle, orig.swimidle)
    s(animate.swim and animate.swim.Swim, orig.swim)
    s(animate.idle and animate.idle.Animation1, orig.idle1)
    s(animate.idle and animate.idle.Animation2, orig.idle2)
    s(animate.climb and animate.climb.ClimbAnim, orig.climb)
end

local function startZombieMode()
    if ZombieRefs.heartbeat then return end
    local char = LP.Character
    if char then saveOriginalAnimsZombie(char); applyZombieAnims(char) end
    ZombieRefs.heartbeat = RunService.Heartbeat:Connect(function()
        if not State.zombieModeEnabled then return end
        local c = LP.Character
        if c then applyZombieAnims(c) end
    end)
end

local function stopZombieMode()
    if ZombieRefs.heartbeat then ZombieRefs.heartbeat:Disconnect(); ZombieRefs.heartbeat = nil end
    local char = LP.Character
    if char then restoreOriginalAnimsZombie(char) end
end

local function setZombieMode(on)
    State.zombieModeEnabled = on
    if on then startZombieMode() else stopZombieMode() end
    scheduleAutoSave(); updateFloatingButtons()
end

-- ANTI RAGDOLL
local function startAntiRagdoll()
    if Conns.antiRag then return end
    Conns.antiRag = RunService.Heartbeat:Connect(function()
        if not State.antiRagdollEnabled then return end
        local char = LP.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        if not (hum and root) then return end
        local s = hum:GetState()
        local ragdolled = (s == Enum.HumanoidStateType.Physics or s == Enum.HumanoidStateType.Ragdoll or s == Enum.HumanoidStateType.FallingDown)
        local endTime = LP:GetAttribute("RagdollEndTime")
        if endTime and (endTime - workspace:GetServerTimeNow()) > 0 then
            ragdolled = true
        end
        if ragdolled then
            pcall(function() LP:SetAttribute("RagdollEndTime", workspace:GetServerTimeNow()) end)
            for _, d in ipairs(char:GetDescendants()) do
                if d:IsA("BallSocketConstraint") or (d:IsA("Attachment") and d.Name:find("RagdollAttachment")) then
                    d:Destroy()
                end
            end
            for _, obj in ipairs(char:GetDescendants()) do
                if obj:IsA("Motor6D") and obj.Enabled == false then
                    obj.Enabled = true
                end
            end
            if hum.Health > 0 then
                hum:ChangeState(Enum.HumanoidStateType.Running)
            end
            workspace.CurrentCamera.CameraSubject = hum
            root.Anchored = false
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
        end
    end)
end

local function stopAntiRagdoll()
    if Conns.antiRag then Conns.antiRag:Disconnect(); Conns.antiRag = nil end
end

-- INSTA RESET
local instaResetRemote = nil
local instaResetCooldown = false

pcall(function()
    if hookfunction and newcclosure then
        local _orig
        _orig = hookfunction(Instance.new("RemoteEvent").FireServer, newcclosure(function(self, ...)
            if not instaResetRemote and typeof(self)=="Instance" and self:IsA("RemoteEvent") and self.Name:sub(1,3)=="RE/" then
                instaResetRemote = self
            end
            return _orig(self, ...)
        end))
    end
end)

local function doInstaReset()
    if instaResetCooldown then return end
    if not instaResetRemote then return end
    instaResetCooldown = true
    local oldChar = LP.Character
    task.spawn(function()
        while LP.Character == oldChar do
            pcall(function() instaResetRemote:FireServer("f888ee6e-c86d-46e1-93d7-0639d6635d42", LP, "balloon") end)
            task.wait()
        end
        instaResetCooldown = false
    end)
end

-- AUTO BAT (CIRCLE COMBAT)
local CircleVars = {
    predictionSphere = nil,
    targetPlayer = nil,
    lastTargetPos = nil,
    targetVelocity = Vector3.new(0, 0, 0),
    smoothedVelocity = Vector3.new(0, 0, 0),
    velocityHistory = {},
    MAX_HISTORY = 8,
    airborneTime = 0,
    lastActivationTime = 0,
    highYVelocityTime = 0,
    pingHistory = {},
    currentPing = 0.1,
    accelerationHistory = {},
    MAX_ACCEL_HISTORY = 4,
    lastDirectionChangeTime = 0,
    previousDirection = nil,
    wasAirborne = false,
    aerialVelocityHistory = {},
    MAX_AERIAL_HISTORY = 6,
    aerialSmoothVelocity = Vector3.new(0, 0, 0),
    lastYVelocity = 0,
    peakHeight = 0,
    groundHeight = 0,
    lastJumpTime = 0,
    isMultiJumping = false,
    verticalVelocityHistory = {},
    MAX_VERTICAL_HISTORY = 5,
}

local CIRCLE_CONFIG = {
    FOLLOW_SPEED = 55,
    ACTIVATE_DISTANCE = 13,
    MIN_FOLLOW_DISTANCE = 1,
    PREDICTION_TIME = 0.22,
    PREDICT_AHEAD = 3,
    JUMP_SPEED_BOOST = 1.5,
    JUMP_THRESHOLD = 8,
    MAX_SPEED = 59,
    ACTIVATION_DELAY = 0.2,
    AIRBORNE_THRESHOLD = 0.15,
    FLOAT_Y_THRESHOLD = 3,
    FALLING_THRESHOLD = -8,
    RISING_THRESHOLD = 8,
    VERTICAL_OFFSET_MULTIPLIER = 0.15,
    JUMPBOOST_Y_THRESHOLD = 35,
    EXTREME_JUMPBOOST_THRESHOLD = 50,
    JUMPBOOST_SUSTAINED_TIME = 0.15,
    MAX_VELOCITY_CHANGE = 150,
    VELOCITY_SMOOTHING = 0.2,
    MAX_HORIZONTAL_VELOCITY = 80,
    ERRATIC_MOVEMENT_THRESHOLD = 3,
    SERVER_TICKRATE = 1/60,
    PING_SAMPLE_SIZE = 10,
    MIN_PING_COMPENSATION = 0.03,
    MAX_PING_COMPENSATION = 0.25,
    ACCELERATION_PREDICTION_WEIGHT = 0.3,
    DIRECTION_CHANGE_DETECTION_TIME = 0.12,
    QUICK_DIRECTION_CHANGE_MULTIPLIER = 1.5,
    GRAVITY = 196.2,
    AIR_CONTROL_FACTOR = 0.8,
    AERIAL_VELOCITY_DECAY = 0.95,
    AERIAL_DIRECTION_CHANGE_WEIGHT = 0.6,
    MIN_AIRBORNE_TIME = 0.08,
    AERIAL_SMOOTHING = 0.15,
    STRAFE_DETECTION_THRESHOLD = 0.7,
    HIGH_JUMP_THRESHOLD = 20,
    FALLING_SPEED_THRESHOLD = -15,
    GRAVITY_PREDICTION_WEIGHT = 1.0,
    MULTI_JUMP_DETECTION_WINDOW = 0.2,
    UPWARD_VELOCITY_RESET_THRESHOLD = 10,
    VERTICAL_POSITION_LEAD = 2.5,
    FALLING_VERTICAL_LEAD = 3.5,
    SPHERE_SMOOTH_SPEED = 15,
}

local Cvar = CircleVars
local CFG = CIRCLE_CONFIG

local function getNearestPlayer()
    local char = LP.Character
    if not char then return nil end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local myPos = root.Position
    local nearestDist = math.huge
    local nearestPlayer = nil
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local otherRoot = p.Character:FindFirstChild("HumanoidRootPart")
            if otherRoot then
                local dist = (myPos - otherRoot.Position).Magnitude
                if dist < nearestDist then
                    nearestDist = dist
                    nearestPlayer = p
                end
            end
        end
    end
    return nearestPlayer
end

local function getAverageVelocity()
    if #Cvar.velocityHistory == 0 then return Vector3.new(0, 0, 0) end
    local sum = Vector3.new(0, 0, 0)
    for _, vel in ipairs(Cvar.velocityHistory) do sum = sum + vel end
    return sum / #Cvar.velocityHistory
end

local function getAverageAcceleration()
    if #Cvar.accelerationHistory == 0 then return Vector3.new(0, 0, 0) end
    local sum = Vector3.new(0, 0, 0)
    for _, a in ipairs(Cvar.accelerationHistory) do sum = sum + a end
    return sum / #Cvar.accelerationHistory
end

local function getAverageAerialVelocity()
    if #Cvar.aerialVelocityHistory == 0 then return Vector3.new(0, 0, 0) end
    local sum = Vector3.new(0, 0, 0)
    for _, vel in ipairs(Cvar.aerialVelocityHistory) do
        sum = sum + Vector3.new(vel.X, 0, vel.Z)
    end
    return sum / #Cvar.aerialVelocityHistory
end

local function getAverageVerticalVelocity()
    if #Cvar.verticalVelocityHistory == 0 then return 0 end
    local sum = 0
    for _, y in ipairs(Cvar.verticalVelocityHistory) do sum = sum + y end
    return sum / #Cvar.verticalVelocityHistory
end

local function detectMultiJump(currentYVel, wasRising)
    local t = tick()
    if Cvar.lastYVelocity < -5 and currentYVel > CFG.UPWARD_VELOCITY_RESET_THRESHOLD then
        if t - Cvar.lastJumpTime < CFG.MULTI_JUMP_DETECTION_WINDOW then return true end
        Cvar.lastJumpTime = t
        return true
    end
    return false
end

local function isFallingFromHeight(currentPos, yVel)
    return (currentPos.Y - Cvar.groundHeight > CFG.HIGH_JUMP_THRESHOLD) and yVel < CFG.FALLING_SPEED_THRESHOLD
end

local function isAerialStrafing()
    if #Cvar.aerialVelocityHistory < 3 then return false end
    local dc = 0
    for i = 2, #Cvar.aerialVelocityHistory do
        local v1 = Vector3.new(Cvar.aerialVelocityHistory[i-1].X, 0, Cvar.aerialVelocityHistory[i-1].Z)
        local v2 = Vector3.new(Cvar.aerialVelocityHistory[i].X, 0, Cvar.aerialVelocityHistory[i].Z)
        if v1.Magnitude > 3 and v2.Magnitude > 3 then
            if v1.Unit:Dot(v2.Unit) < CFG.STRAFE_DETECTION_THRESHOLD then
                dc = dc + 1
            end
        end
    end
    return dc >= 2
end

local function detectDirectionChange(currentVel)
    local horizontal = Vector3.new(currentVel.X, 0, currentVel.Z)
    if horizontal.Magnitude < 5 then return false end
    if Cvar.previousDirection then
        local dot = Cvar.previousDirection:Dot(horizontal.Unit)
        if dot < 0.5 then
            local t = tick()
            if t - Cvar.lastDirectionChangeTime < CFG.DIRECTION_CHANGE_DETECTION_TIME then
                Cvar.previousDirection = horizontal.Unit
                Cvar.lastDirectionChangeTime = t
                return true
            end
            Cvar.lastDirectionChangeTime = t
        end
    end
    Cvar.previousDirection = horizontal.Unit
    return false
end

local function isErraticMovement()
    if #Cvar.velocityHistory < 3 then return false end
    local changes = 0
    for i = 2, #Cvar.velocityHistory do
        local v1 = Vector3.new(Cvar.velocityHistory[i-1].X, 0, Cvar.velocityHistory[i-1].Z)
        local v2 = Vector3.new(Cvar.velocityHistory[i].X, 0, Cvar.velocityHistory[i].Z)
        if v1.Magnitude > 5 and v2.Magnitude > 5 then
            if v1.Unit:Dot(v2.Unit) < 0.3 then changes = changes + 1 end
        end
    end
    return changes >= CFG.ERRATIC_MOVEMENT_THRESHOLD
end

local function isInfiniteJumping()
    if #Cvar.velocityHistory < 3 then return false end
    local yc = 0
    for i = 2, #Cvar.velocityHistory do
        if math.abs(Cvar.velocityHistory[i].Y - Cvar.velocityHistory[i-1].Y) > 15 then
            yc = yc + 1
        end
    end
    return yc >= 2
end

local function isJumpBoostCheat()
    return math.abs(Cvar.targetVelocity.Y) > CFG.JUMPBOOST_Y_THRESHOLD and Cvar.highYVelocityTime > CFG.JUMPBOOST_SUSTAINED_TIME
end

local function isExtremeJumpBoost()
    return math.abs(Cvar.targetVelocity.Y) > CFG.EXTREME_JUMPBOOST_THRESHOLD
end

local function isFloating()
    return Cvar.airborneTime > CFG.AIRBORNE_THRESHOLD and math.abs(Cvar.targetVelocity.Y) > CFG.FLOAT_Y_THRESHOLD
end

local function checkAirborne(targetRoot)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {Cvar.targetPlayer.Character, LP.Character}
    local rayResult = workspace:Raycast(targetRoot.Position, Vector3.new(0, -100, 0), params)
    if rayResult then
        Cvar.groundHeight = rayResult.Position.Y
        return false
    end
    return true
end

local function clampVelocityChange(newVel, oldVel, maxChange)
    local delta = newVel - oldVel
    if delta.Magnitude > maxChange then
        return oldVel + (delta.Unit * maxChange)
    end
    return newVel
end

local function smoothVelocity(current, target, alpha)
    return current:Lerp(target, alpha)
end

local function predictAerialPosition(currentPos, velocity, dt, isStrafing, isFastFalling, isMultiJump)
    local horizVel = Vector3.new(velocity.X, 0, velocity.Z)
    local vertVel = velocity.Y

    if isStrafing then
        local avgAerial = getAverageAerialVelocity()
        horizVel = Vector3.new(avgAerial.X, 0, avgAerial.Z) * CFG.AIR_CONTROL_FACTOR
    else
        horizVel = horizVel * CFG.AIR_CONTROL_FACTOR
    end

    horizVel = horizVel * CFG.AERIAL_VELOCITY_DECAY

    local gravityEffect = CFG.GRAVITY * CFG.GRAVITY_PREDICTION_WEIGHT
    if isMultiJump then
        gravityEffect = gravityEffect * 0.3
        vertVel = vertVel * 0.9
    end

    local verticalDisplacement
    if isFastFalling then
        verticalDisplacement = (vertVel * dt) - (0.5 * gravityEffect * 1.2 * dt * dt) - (CFG.FALLING_VERTICAL_LEAD * dt)
    else
        verticalDisplacement = (vertVel * dt) - (0.5 * gravityEffect * dt * dt)
    end

    if vertVel > CFG.RISING_THRESHOLD and not isMultiJump then
        verticalDisplacement = verticalDisplacement + (CFG.VERTICAL_POSITION_LEAD * dt)
    end

    return currentPos + horizVel * dt + Vector3.new(0, verticalDisplacement, 0)
end

local function predictServerPosition(currentPos, velocity, acceleration, ping, isQuickTurn, isAerial, isStrafing, isFastFalling, isMultiJump)
    local serverDelay = ping + CFG.SERVER_TICKRATE
    if isQuickTurn then serverDelay = serverDelay * CFG.QUICK_DIRECTION_CHANGE_MULTIPLIER end
    if isAerial then
        return predictAerialPosition(currentPos, velocity, serverDelay, isStrafing, isFastFalling, isMultiJump)
    end

    local predictedPos = currentPos + velocity * serverDelay
    if acceleration.Magnitude > 1 then
        predictedPos = predictedPos + (acceleration * CFG.ACCELERATION_PREDICTION_WEIGHT) * (serverDelay * serverDelay * 0.5)
    end
    return predictedPos
end

local function createPredictionSphere()
    if Cvar.predictionSphere then Cvar.predictionSphere:Destroy() end
    Cvar.predictionSphere = Instance.new("Part")
    Cvar.predictionSphere.Name = "PredictionSphere"
    Cvar.predictionSphere.Shape = Enum.PartType.Ball
    Cvar.predictionSphere.Size = Vector3.new(2, 2, 2)
    Cvar.predictionSphere.Anchored = true
    Cvar.predictionSphere.CanCollide = false
    Cvar.predictionSphere.Material = Enum.Material.Neon
    Cvar.predictionSphere.Color = Color3.fromRGB(140,50,160)
    Cvar.predictionSphere.Transparency = 0.3
    local light = Instance.new("PointLight")
    light.Color = Color3.fromRGB(140,50,160)
    light.Range = 6
    light.Brightness = 1.5
    light.Parent = Cvar.predictionSphere
    Cvar.predictionSphere.Parent = workspace
    return Cvar.predictionSphere
end

local function updatePredictionSphere(targetPosition, dt)
    if not Cvar.predictionSphere then return end
    local alpha = math.min(1, dt * CFG.SPHERE_SMOOTH_SPEED)
    Cvar.predictionSphere.CFrame = Cvar.predictionSphere.CFrame:Lerp(CFrame.new(targetPosition), alpha)
end

local function updateRotationAngular(lookDirection, rootPart)
    if not rootPart then return end
    if lookDirection.Magnitude < 0.01 then return end
    local currentLook = rootPart.CFrame.LookVector
    local targetDir = lookDirection.Unit
    local axis = currentLook:Cross(targetDir)
    local angle = math.asin(math.clamp(axis.Magnitude, -1, 1))
    if axis.Magnitude > 0.01 then
        local rotSpeed = 80
        rootPart.AssemblyAngularVelocity = axis.Unit * angle * rotSpeed
    else
        rootPart.AssemblyAngularVelocity = Vector3.zero
    end
end

local function startFollowing(char)
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    if not humanoid or not rootPart then return end
    humanoid.AutoRotate = false

    if not Cvar.predictionSphere then createPredictionSphere() end

    if Conns.circle then Conns.circle:Disconnect() end

    Conns.circle = RunService.RenderStepped:Connect(function(dt)
        if not State.circleEnabled then
            if Conns.circle then Conns.circle:Disconnect(); Conns.circle = nil end
            return
        end

        Cvar.targetPlayer = getNearestPlayer()
        if not Cvar.targetPlayer or not Cvar.targetPlayer.Character then
            if Cvar.predictionSphere then Cvar.predictionSphere.Transparency = 1 end
            Cvar.targetPlayer = nil
            Cvar.lastTargetPos = nil
            Cvar.targetVelocity = Vector3.zero
            Cvar.smoothedVelocity = Vector3.zero
            Cvar.velocityHistory = {}
            Cvar.accelerationHistory = {}
            Cvar.aerialVelocityHistory = {}
            Cvar.verticalVelocityHistory = {}
            Cvar.aerialSmoothVelocity = Vector3.zero
            Cvar.airborneTime = 0
            Cvar.highYVelocityTime = 0
            Cvar.previousDirection = nil
            Cvar.wasAirborne = false
            Cvar.lastYVelocity = 0
            Cvar.peakHeight = 0
            Cvar.isMultiJumping = false
            return
        end

        local targetRoot = Cvar.targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not targetRoot then
            if Cvar.predictionSphere then Cvar.predictionSphere.Transparency = 1 end
            return
        end

        if Cvar.predictionSphere then Cvar.predictionSphere.Transparency = 0.3 end

        local targetPos = targetRoot.Position
        local myPos = rootPart.Position

        if Cvar.lastTargetPos then
            local deltaPos = targetPos - Cvar.lastTargetPos
            local rawVelocity = deltaPos / dt
            rawVelocity = clampVelocityChange(rawVelocity, Cvar.targetVelocity, CFG.MAX_VELOCITY_CHANGE)

            local horizontalVel = Vector3.new(rawVelocity.X, 0, rawVelocity.Z)
            if horizontalVel.Magnitude > CFG.MAX_HORIZONTAL_VELOCITY then
                horizontalVel = horizontalVel.Unit * CFG.MAX_HORIZONTAL_VELOCITY
                rawVelocity = Vector3.new(horizontalVel.X, rawVelocity.Y, horizontalVel.Z)
            end

            local currentAcceleration = (rawVelocity - Cvar.targetVelocity) / dt
            table.insert(Cvar.accelerationHistory, currentAcceleration)
            if #Cvar.accelerationHistory > Cvar.MAX_ACCEL_HISTORY then table.remove(Cvar.accelerationHistory, 1) end

            table.insert(Cvar.verticalVelocityHistory, rawVelocity.Y)
            if #Cvar.verticalVelocityHistory > Cvar.MAX_VERTICAL_HISTORY then table.remove(Cvar.verticalVelocityHistory, 1) end

            Cvar.targetVelocity = rawVelocity
            Cvar.smoothedVelocity = smoothVelocity(Cvar.smoothedVelocity, Cvar.targetVelocity, CFG.VELOCITY_SMOOTHING)

            table.insert(Cvar.velocityHistory, Cvar.targetVelocity)
            if #Cvar.velocityHistory > Cvar.MAX_HISTORY then table.remove(Cvar.velocityHistory, 1) end
        end

        Cvar.lastTargetPos = targetPos

        if math.abs(Cvar.targetVelocity.Y) > CFG.JUMPBOOST_Y_THRESHOLD then
            Cvar.highYVelocityTime = Cvar.highYVelocityTime + dt
        else
            Cvar.highYVelocityTime = 0
        end

        local isAirborne = checkAirborne(targetRoot)
        if isAirborne then
            Cvar.airborneTime = Cvar.airborneTime + dt
            if targetPos.Y > Cvar.peakHeight then Cvar.peakHeight = targetPos.Y end

            if Cvar.airborneTime >= CFG.MIN_AIRBORNE_TIME then
                table.insert(Cvar.aerialVelocityHistory, Cvar.targetVelocity)
                if #Cvar.aerialVelocityHistory > Cvar.MAX_AERIAL_HISTORY then table.remove(Cvar.aerialVelocityHistory, 1) end
                Cvar.aerialSmoothVelocity = smoothVelocity(Cvar.aerialSmoothVelocity, Cvar.targetVelocity, CFG.AERIAL_SMOOTHING)
            end
            Cvar.wasAirborne = true
        else
            Cvar.airborneTime = 0
            Cvar.wasAirborne = false
            Cvar.aerialVelocityHistory = {}
            Cvar.aerialSmoothVelocity = Vector3.zero
            Cvar.peakHeight = 0
        end

        local isJumping = math.abs(Cvar.targetVelocity.Y) > CFG.JUMP_THRESHOLD
        local isInfJump = isInfiniteJumping()
        local isFloater = isFloating()
        local isJumpBoost = isJumpBoostCheat()
        local isExtremeBoost = isExtremeJumpBoost()
        local isErratic = isErraticMovement()
        local avgVelocity = getAverageVelocity()
        local avgAcceleration = getAverageAcceleration()
        local isQuickTurn = detectDirectionChange(Cvar.targetVelocity)
        local isStrafing = isAerialStrafing()
        local isTrulyAirborne = isAirborne and Cvar.airborneTime >= CFG.MIN_AIRBORNE_TIME
        local wasRising = Cvar.lastYVelocity > CFG.RISING_THRESHOLD
        Cvar.isMultiJumping = detectMultiJump(Cvar.targetVelocity.Y, wasRising)
        local isFastFalling = isFallingFromHeight(targetPos, Cvar.targetVelocity.Y)
        local avgYVel = getAverageVerticalVelocity()
        Cvar.lastYVelocity = Cvar.targetVelocity.Y

        local predictionVel = Cvar.targetVelocity
        local predictionAccel = avgAcceleration
        local useCurrentPos = false

        if isExtremeBoost then
            useCurrentPos = true
            predictionVel = Vector3.new(avgVelocity.X, 0, avgVelocity.Z)
            predictionAccel = Vector3.zero
        elseif isJumpBoost then
            local avgH = Vector3.new(avgVelocity.X, 0, avgVelocity.Z)
            predictionVel = Vector3.new(avgH.X, Cvar.targetVelocity.Y * 0.15, avgH.Z)
            predictionAccel = Vector3.new(avgAcceleration.X, 0, avgAcceleration.Z)
        elseif isInfJump or isFloater then
            local avgH = Vector3.new(avgVelocity.X, 0, avgVelocity.Z)
            predictionVel = Vector3.new(avgH.X, Cvar.targetVelocity.Y * 0.5, avgH.Z)
            predictionAccel = Vector3.new(avgAcceleration.X * 0.5, 0, avgAcceleration.Z * 0.5)
        elseif isTrulyAirborne and isStrafing then
            local avgAerial = getAverageAerialVelocity()
            predictionVel = Vector3.new(
                Cvar.aerialSmoothVelocity.X * CFG.AERIAL_DIRECTION_CHANGE_WEIGHT + avgAerial.X * (1 - CFG.AERIAL_DIRECTION_CHANGE_WEIGHT),
                avgYVel,
                Cvar.aerialSmoothVelocity.Z * CFG.AERIAL_DIRECTION_CHANGE_WEIGHT + avgAerial.Z * (1 - CFG.AERIAL_DIRECTION_CHANGE_WEIGHT)
            )
            predictionAccel = Vector3.new(avgAcceleration.X * 0.3, 0, avgAcceleration.Z * 0.3)
        elseif isTrulyAirborne then
            predictionVel = Vector3.new(Cvar.aerialSmoothVelocity.X, avgYVel, Cvar.aerialSmoothVelocity.Z)
            predictionAccel = Vector3.zero
        elseif isErratic then
            predictionVel = Vector3.new(Cvar.smoothedVelocity.X, Cvar.targetVelocity.Y, Cvar.smoothedVelocity.Z)
            predictionAccel = Vector3.new(avgAcceleration.X * 0.7, 0, avgAcceleration.Z * 0.7)
        end

        local serverPredictedPos
        if useCurrentPos then
            serverPredictedPos = targetPos
        else
            serverPredictedPos = predictServerPosition(targetPos, predictionVel, predictionAccel, Cvar.currentPing, isQuickTurn, isTrulyAirborne, isStrafing, isFastFalling, Cvar.isMultiJumping)
        end

        local predTime = CFG.PREDICTION_TIME * 1.1

        if isErratic then
            predTime = predTime * 0.6
        elseif isQuickTurn then
            predTime = predTime * 1.2
        elseif isTrulyAirborne and isStrafing then
            predTime = predTime * 0.7
        elseif isTrulyAirborne and isFastFalling then
            predTime = predTime * 1.3
        elseif isTrulyAirborne then
            predTime = predTime * 0.85
        end

        local predictedPos
        if isTrulyAirborne then
            predictedPos = predictAerialPosition(serverPredictedPos, predictionVel, predTime, isStrafing, isFastFalling, Cvar.isMultiJumping)
        else
            predictedPos = serverPredictedPos + predictionVel * predTime
        end

        local verticalOffset = Vector3.new(0, 0, 0)
        if not isTrulyAirborne and not isExtremeBoost and not isJumpBoost and not isInfJump then
            if Cvar.targetVelocity.Y < CFG.FALLING_THRESHOLD then
                verticalOffset = Vector3.new(0, Cvar.targetVelocity.Y * CFG.VERTICAL_OFFSET_MULTIPLIER, 0)
            elseif Cvar.targetVelocity.Y > CFG.RISING_THRESHOLD then
                verticalOffset = Vector3.new(0, Cvar.targetVelocity.Y * CFG.VERTICAL_OFFSET_MULTIPLIER, 0)
            end
        end
        predictedPos = predictedPos + verticalOffset

        local interceptOffset = Vector3.new(0, 0, 0)
        local horizontalVel = Vector3.new(predictionVel.X, 0, predictionVel.Z)
        if horizontalVel.Magnitude > 1 and not useCurrentPos then
            interceptOffset = horizontalVel.Unit * CFG.PREDICT_AHEAD
        end

        local interceptPoint = predictedPos + interceptOffset
        updatePredictionSphere(interceptPoint, dt)

        local toTarget = interceptPoint - myPos
        if toTarget.Magnitude > 0.1 then
            updateRotationAngular(toTarget, rootPart)
        end

        local actualDistance = (targetPos - myPos).Magnitude
        if actualDistance <= CFG.ACTIVATE_DISTANCE then
            local currentTime = tick()
            if currentTime - Cvar.lastActivationTime >= 0.3 then
                if useCurrentPos or (isErratic and not isTrulyAirborne) then
                    interceptPoint = serverPredictedPos
                elseif isTrulyAirborne then
                    interceptPoint = predictAerialPosition(serverPredictedPos, predictionVel, CFG.ACTIVATION_DELAY, isStrafing, isFastFalling, Cvar.isMultiJumping)
                else
                    interceptPoint = serverPredictedPos + predictionVel * CFG.ACTIVATION_DELAY
                end
                local tool = char:FindFirstChildOfClass("Tool")
                if tool then tool:Activate() end
                Cvar.lastActivationTime = currentTime
            end
        end

        local direction = interceptPoint - myPos
        if direction.Magnitude > CFG.MIN_FOLLOW_DISTANCE then
            local dirUnit = direction.Unit
            local currentSpeed = CFG.FOLLOW_SPEED

            if isJumping then currentSpeed = currentSpeed * CFG.JUMP_SPEED_BOOST end
            if isExtremeBoost then currentSpeed = currentSpeed * 1.3
            elseif isJumpBoost or isInfJump or isFloater then currentSpeed = currentSpeed * 1.15 end
            if isErratic then currentSpeed = currentSpeed * 0.9
            elseif isQuickTurn then currentSpeed = currentSpeed * 1.1
            elseif isTrulyAirborne and isStrafing then currentSpeed = currentSpeed * 0.95
            elseif isTrulyAirborne and isFastFalling then currentSpeed = currentSpeed * 1.15
            elseif isTrulyAirborne then currentSpeed = currentSpeed * 1.05 end

            currentSpeed = math.min(currentSpeed, CFG.MAX_SPEED)
            rootPart.AssemblyLinearVelocity = dirUnit * currentSpeed
        else
            rootPart.AssemblyLinearVelocity = Vector3.new(0, rootPart.AssemblyLinearVelocity.Y * 0.5, 0)
        end
    end)
end

local function stopCircle()
    if Conns.circle then
        Conns.circle:Disconnect()
        Conns.circle = nil
    end
    if Cvar.predictionSphere then
        Cvar.predictionSphere:Destroy()
        Cvar.predictionSphere = nil
    end
    local char = LP.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.AutoRotate = true end
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then root.AssemblyAngularVelocity = Vector3.zero end
    end
    Cvar.targetPlayer = nil
    Cvar.lastTargetPos = nil
    Cvar.targetVelocity = Vector3.zero
    Cvar.smoothedVelocity = Vector3.zero
    Cvar.velocityHistory = {}
    Cvar.accelerationHistory = {}
    Cvar.aerialVelocityHistory = {}
    Cvar.verticalVelocityHistory = {}
    Cvar.aerialSmoothVelocity = Vector3.zero
    Cvar.airborneTime = 0
    Cvar.highYVelocityTime = 0
    Cvar.previousDirection = nil
    Cvar.wasAirborne = false
    Cvar.lastYVelocity = 0
    Cvar.peakHeight = 0
    Cvar.isMultiJumping = false
    Cvar.lastActivationTime = 0
end

local function setCircleState(enabled)
    State.circleEnabled = enabled
    if enabled then
        local char = LP.Character
        if char then startFollowing(char) end
    else
        stopCircle()
    end
    scheduleAutoSave()
    updateFloatingButtons()
    if GuiToggleSetters["circle"] then GuiToggleSetters["circle"](enabled) end
end

local function toggleCircleCombat()
    setCircleState(not State.circleEnabled)
end

LP.CharacterAdded:Connect(function(char)
    if State.circleEnabled then
        task.wait(0.5)
        startFollowing(char)
    end
end)

if LP.Character then
    task.spawn(function()
        task.wait(0.5)
        if State.circleEnabled then startFollowing(LP.Character) end
    end)
end

local CharRefs = {humanoid = nil, hrp = nil, speedLabel = nil}

local function setupChar(char)
    local humanoid = char:WaitForChild("Humanoid", 5)
    local hrp = char:WaitForChild("HumanoidRootPart", 5)
    local head = char:WaitForChild("Head", 5)
    if not humanoid or not hrp or not head then return end
    CharRefs.humanoid = humanoid
    CharRefs.hrp = hrp
    local old = head:FindFirstChild("SpeedBillboard")
    if old then old:Destroy() end
    local bb = Instance.new("BillboardGui")
    bb.Name = "SpeedBillboard"
    bb.Size = UDim2.new(0, 140, 0, 25)
    bb.StudsOffset = Vector3.new(0, 3, 0)
    bb.AlwaysOnTop = true
    bb.Parent = head
    CharRefs.speedLabel = Instance.new("TextLabel")
    CharRefs.speedLabel.Size = UDim2.new(1, 0, 1, 0)
    CharRefs.speedLabel.BackgroundTransparency = 1
    CharRefs.speedLabel.TextColor3 = Color3.fromRGB(235,225,245)
    CharRefs.speedLabel.Font = Enum.Font.GothamBold
    CharRefs.speedLabel.TextScaled = true
    CharRefs.speedLabel.TextStrokeTransparency = 0
    CharRefs.speedLabel.Parent = bb
end

LP.CharacterAdded:Connect(function(char)
    task.wait(0.3)
    setupChar(char)
end)

if LP.Character then
    task.spawn(function()
        task.wait(0.3)
        setupChar(LP.Character)
    end)
end

-- ENEMY SPEED DISPLAY
local EnemySpeedLabels = {}

local function setupEnemySpeedDisplay()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LP then
            if player.Character then
                local head = player.Character:FindFirstChild("Head")
                if head then
                    local existing = head:FindFirstChild("EnemySpeedBillboard")
                    if existing then existing:Destroy() end

                    local bb = Instance.new("BillboardGui")
                    bb.Name = "EnemySpeedBillboard"
                    bb.Size = UDim2.new(0, 140, 0, 25)
                    bb.StudsOffset = Vector3.new(0, 3, 0)
                    bb.AlwaysOnTop = true
                    bb.Parent = head

                    local speedLabel = Instance.new("TextLabel")
                    speedLabel.Size = UDim2.new(1, 0, 1, 0)
                    speedLabel.BackgroundTransparency = 1
                    speedLabel.TextColor3 = Color3.fromRGB(235,225,245)
                    speedLabel.Font = Enum.Font.GothamBold
                    speedLabel.TextScaled = true
                    speedLabel.TextStrokeTransparency = 0
                    speedLabel.Parent = bb

                    EnemySpeedLabels[player] = speedLabel
                end
            end
        end
    end
end

local function updateEnemySpeedDisplay()
    for player, label in pairs(EnemySpeedLabels) do
        if player and player.Character then
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local vel = hrp.AssemblyLinearVelocity
                local speed = Vector3.new(vel.X, 0, vel.Z).Magnitude
                label.Text = string.format("%.1f", speed)
            else
                label.Text = "0.0"
            end
        else
            label.Text = "0.0"
        end
    end
end

local function onPlayerAdded(player)
    if player ~= LP then
        player.CharacterAdded:Connect(function(character)
            task.wait(0.3)
            local head = character:FindFirstChild("Head")
            if head then
                local existing = head:FindFirstChild("EnemySpeedBillboard")
                if existing then existing:Destroy() end

                local bb = Instance.new("BillboardGui")
                bb.Name = "EnemySpeedBillboard"
                bb.Size = UDim2.new(0, 140, 0, 25)
                bb.StudsOffset = Vector3.new(0, 3, 0)
                bb.AlwaysOnTop = true
                bb.Parent = head

                local speedLabel = Instance.new("TextLabel")
                speedLabel.Size = UDim2.new(1, 0, 1, 0)
                speedLabel.BackgroundTransparency = 1
                speedLabel.TextColor3 = Color3.fromRGB(235,225,245)
                speedLabel.Font = Enum.Font.GothamBold
                speedLabel.TextScaled = true
                speedLabel.TextStrokeTransparency = 0
                speedLabel.Parent = bb

                EnemySpeedLabels[player] = speedLabel
            end
        end)

        if player.Character then
            local head = player.Character:FindFirstChild("Head")
            if head then
                local bb = Instance.new("BillboardGui")
                bb.Name = "EnemySpeedBillboard"
                bb.Size = UDim2.new(0, 140, 0, 25)
                bb.StudsOffset = Vector3.new(0, 3, 0)
                bb.AlwaysOnTop = true
                bb.Parent = head

                local speedLabel = Instance.new("TextLabel")
                speedLabel.Size = UDim2.new(1, 0, 1, 0)
                speedLabel.BackgroundTransparency = 1
                speedLabel.TextColor3 = Color3.fromRGB(235,225,245)
                speedLabel.Font = Enum.Font.GothamBold
                speedLabel.TextScaled = true
                speedLabel.TextStrokeTransparency = 0
                speedLabel.Parent = bb

                EnemySpeedLabels[player] = speedLabel
            end
        end
    end
end

local function onPlayerRemoving(player)
    EnemySpeedLabels[player] = nil
end

for _, player in ipairs(Players:GetPlayers()) do
    onPlayerAdded(player)
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

task.spawn(function()
    while true do
        updateEnemySpeedDisplay()
        task.wait(0.1)
    end
end)

-- Couleurs - Refined
local C={
    bg=Color3.fromRGB(14,12,18),
    bgDark=Color3.fromRGB(18,14,22),
    row=Color3.fromRGB(22,18,28),
    input=Color3.fromRGB(22,18,28),
    blue=Color3.fromRGB(140,50,160),
    blueDim=Color3.fromRGB(100,40,120),
    blueDark=Color3.fromRGB(60,25,75),
    text=Color3.fromRGB(235,225,245),
    textDim=Color3.fromRGB(215,205,225),
    textMuted=Color3.fromRGB(190,180,200),
    white=Color3.fromRGB(255,255,255),
    divider=Color3.fromRGB(100,40,120),
    green=Color3.fromRGB(120,210,160),
    underline=Color3.fromRGB(140,50,160),
    red=Color3.fromRGB(200,60,60),
    cyber=Color3.fromRGB(80,200,240),
    darkBg=Color3.fromRGB(10,8,15),
}

local function guiCorner(p,r)
    local c=Instance.new("UICorner")
    c.CornerRadius=UDim.new(0,r or 10)
    c.Parent=p
    return c
end

local function guiStroke(p,col,t)
    local s=Instance.new("UIStroke")
    s.Color=col or C.divider
    s.Thickness=t or 1
    s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    s.Parent=p
    return s
end

local function tw(obj,props,t,sty,dir)
    TweenService:Create(obj,TweenInfo.new(t or 0.18,sty or Enum.EasingStyle.Quad,dir or Enum.EasingDirection.Out),props):Play()
end

for _,name in pairs({"ADAPTHub","ApinaGUI","SKSpeedBypass","AutoStealBar","CypherHub","VoidHub","SpeedBypassGUI","VoidBypassGUI","CyberHub", "CEED X LKN "}) do
    local old=PlayerGui:FindFirstChild(name)
    if old then old:Destroy() end
end

local GuiRefs = {}
local CategoryBar = nil

do
    local GuiHub=Instance.new("ScreenGui")
    GuiHub.Name="Raven Hub"
    GuiHub.ResetOnSpawn=false
    GuiHub.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
    GuiHub.Parent=PlayerGui
    GuiRefs.hub=GuiHub

    local Outer=Instance.new("Frame")
    Outer.Name="Outer"
    Outer.Size=UDim2.new(0,380,0,495)
    Outer.Position=UDim2.new(0,20,0,110)
    Outer.BackgroundTransparency=1
    Outer.BorderSizePixel=0
    Outer.ClipsDescendants=false
    Outer.Parent=GuiHub
    GuiRefs.outer=Outer
    makeDraggable(Outer)

    local Inner=Instance.new("Frame")
    Inner.Name="Inner"
    Inner.ClipsDescendants=false
    Inner.Size=UDim2.new(1,0,1,0)
    Inner.BackgroundColor3=C.bg
    Inner.BackgroundTransparency=0
    Inner.BorderSizePixel=0
    Inner.Parent=Outer
    guiCorner(Inner,24)
    guiStroke(Inner,Color3.fromRGB(55,45,70),1.5)
    GuiRefs.inner = Inner

    local BackgroundContainer = Instance.new("Frame")
    BackgroundContainer.Name = "BackgroundContainer"
    BackgroundContainer.Size = UDim2.new(1, 0, 1, 0)
    BackgroundContainer.BackgroundTransparency = 1
    BackgroundContainer.ZIndex = 0
    BackgroundContainer.Parent = Inner

    local BgGrad = Instance.new("Frame")
    BgGrad.Name = "BgGrad"
    BgGrad.Size = UDim2.new(1, 0, 1, 0)
    BgGrad.BackgroundColor3 = C.bgDark
    BgGrad.BorderSizePixel = 0
    BgGrad.ZIndex = 0
    BgGrad.Parent = BackgroundContainer
    guiCorner(BgGrad, 24)

    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(35,18,40)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(18,14,22)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(30,15,35))
    })
    grad.Rotation = 135
    grad.Parent = BgGrad
    GuiRefs.bgGrad = BgGrad

    local BackgroundImage = Instance.new("ImageLabel")
    BackgroundImage.Name = "BackgroundImage"
    BackgroundImage.Size = UDim2.new(1, 0, 1, 0)
    BackgroundImage.BackgroundTransparency = 1
    BackgroundImage.Image = ""
    BackgroundImage.ScaleType = Enum.ScaleType.Crop
    BackgroundImage.ZIndex = 0
    BackgroundImage.Visible = false
    BackgroundImage.Parent = BackgroundContainer
    guiCorner(BackgroundImage, 24)
    GuiRefs.backgroundImage = BackgroundImage

    local HeaderFrame=Instance.new("Frame")
    HeaderFrame.Name="HeaderFrame"
    HeaderFrame.Size=UDim2.new(1,0,0,62)
    HeaderFrame.BackgroundTransparency=1
    HeaderFrame.BorderSizePixel=0
    HeaderFrame.Parent=Inner
    HeaderFrame.ZIndex = 2

    local TitleLbl=Instance.new("TextLabel")
    TitleLbl.Position=UDim2.new(0,14,0,8)
    TitleLbl.Size=UDim2.new(1,-90,0,22)
    TitleLbl.BackgroundTransparency=1
    TitleLbl.Text="Raven Hub"
    TitleLbl.TextColor3=C.blue
    TitleLbl.TextSize=17
    TitleLbl.Font=Enum.Font.GothamBlack
    TitleLbl.TextXAlignment=Enum.TextXAlignment.Left
    TitleLbl.Parent=HeaderFrame
    TitleLbl.ZIndex = 3

    local MadeLbl=Instance.new("TextLabel")
    MadeLbl.Position=UDim2.new(0,14,0,32)
    MadeLbl.Size=UDim2.new(0,200,0,14)
    MadeLbl.BackgroundTransparency=1
    MadeLbl.Text="discord.gg/sQQRyHFfgZ"
    MadeLbl.TextColor3=C.textDim
    MadeLbl.TextSize=10
    MadeLbl.Font=Enum.Font.GothamBold
    MadeLbl.TextXAlignment=Enum.TextXAlignment.Left
    MadeLbl.Parent=HeaderFrame
    MadeLbl.ZIndex = 3

    local HeaderSep=Instance.new("Frame")
    HeaderSep.Position=UDim2.new(0,14,0,62)
    HeaderSep.Size=UDim2.new(1,-28,0,1)
    HeaderSep.BackgroundColor3=C.blue
    HeaderSep.BackgroundTransparency=0.5
    HeaderSep.BorderSizePixel=0
    HeaderSep.Parent=Inner
    HeaderSep.ZIndex = 2

    local ContentFrame=Instance.new("ScrollingFrame")
    ContentFrame.Name="ContentFrame"
    ContentFrame.Size=UDim2.new(1,-16,1,-118)
    ContentFrame.Position=UDim2.new(0,8,0,63)
    ContentFrame.BackgroundTransparency=1
    ContentFrame.BorderSizePixel=0
    ContentFrame.ScrollBarThickness=6
    ContentFrame.ScrollBarImageColor3=C.blue
    ContentFrame.CanvasSize=UDim2.new(0,0,0,0)
    ContentFrame.AutomaticCanvasSize=Enum.AutomaticSize.Y
    ContentFrame.ScrollingDirection = Enum.ScrollingDirection.Y
    ContentFrame.ScrollingEnabled = true
    ContentFrame.ElasticBehavior = Enum.ElasticBehavior.Never
    ContentFrame.Parent=Inner
    GuiRefs.contentFrame=ContentFrame

    local CLayout=Instance.new("UIListLayout")
    CLayout.SortOrder=Enum.SortOrder.LayoutOrder
    CLayout.Padding=UDim.new(0,6)
    CLayout.Parent=ContentFrame
    local CPad=Instance.new("UIPadding")
    CPad.PaddingLeft=UDim.new(0,12)
    CPad.PaddingRight=UDim.new(0,12)
    CPad.PaddingTop=UDim.new(0,10)
    CPad.PaddingBottom=UDim.new(0,8)
    CPad.Parent=ContentFrame

    local BottomSep=Instance.new("Frame")
    BottomSep.Position=UDim2.new(0,8,1,-54)
    BottomSep.Size=UDim2.new(1,-16,0,1)
    BottomSep.BackgroundColor3=C.blue
    BottomSep.BackgroundTransparency=0.5
    BottomSep.BorderSizePixel=0
    BottomSep.Parent=Inner
    BottomSep.ZIndex = 2

    CategoryBar = Instance.new("ScrollingFrame")
    CategoryBar.Name="CategoryBar"
    CategoryBar.Position=UDim2.new(0,8,1,-48)
    CategoryBar.Size=UDim2.new(1,-16,0,40)
    CategoryBar.BackgroundTransparency=1
    CategoryBar.BorderSizePixel=0
    CategoryBar.ScrollBarThickness=0
    CategoryBar.ScrollingDirection=Enum.ScrollingDirection.X
    CategoryBar.CanvasSize=UDim2.new(0,0,0,0)
    CategoryBar.AutomaticCanvasSize=Enum.AutomaticSize.X
    CategoryBar.ElasticBehavior=Enum.ElasticBehavior.Never
    CategoryBar.Parent=Inner
    CategoryBar.ZIndex = 5

    local CatBarLayout = Instance.new("UIListLayout")
    CatBarLayout.FillDirection=Enum.FillDirection.Horizontal
    CatBarLayout.SortOrder=Enum.SortOrder.LayoutOrder
    CatBarLayout.Padding=UDim.new(0,4)
    CatBarLayout.VerticalAlignment=Enum.VerticalAlignment.Center
    CatBarLayout.Parent=CategoryBar

    local CatBarPad = Instance.new("UIPadding")
    CatBarPad.PaddingLeft=UDim.new(0,6)
    CatBarPad.PaddingRight=UDim.new(0,6)
    CatBarPad.PaddingTop=UDim.new(0,4)
    CatBarPad.PaddingBottom=UDim.new(0,4)
    CatBarPad.Parent=CategoryBar
    GuiRefs.categoryBar = CategoryBar
end

-- KEYBIND CAPTURE SYSTEM
local KeyListen = { cb = nil, label = nil, active = false }

local KEY_DISPLAY_ALIASES = {
    ButtonA="A", ButtonB="B", ButtonX="X", ButtonY="Y",
    ButtonR1="RB", ButtonR2="RT", ButtonL1="LB", ButtonL2="LT",
    DPadUp="Dâ†‘", DPadDown="Dâ†“", DPadLeft="Dâ†", DPadRight="Dâ†’",
    ButtonStart="â–¶", ButtonSelect="â—€", ButtonR3="RS", ButtonL3="LS",
    Thumbstick1="L3", Thumbstick2="R3",
    LeftControl="Ctrl", RightControl="Ctrl",
    LeftShift="Shift", RightShift="Shift",
    LeftAlt="Alt", RightAlt="Alt",
    LeftMeta="Win", RightMeta="Win",
}

local function prettyKeyName(keyCode)
    local raw = keyCode.Name
    return KEY_DISPLAY_ALIASES[raw] or raw
end

local function cancelKeyListen()
    if KeyListen.label then
        KeyListen.label.BackgroundColor3 = C.blue
        KeyListen.label.BackgroundTransparency = 0.6
        KeyListen.label.TextColor3 = C.white
    end
    KeyListen.cb = nil
    KeyListen.label = nil
    KeyListen.active = false
end

local function startKeyListen(labelBtn, onKeySet)
    cancelKeyListen()
    KeyListen.cb = onKeySet
    KeyListen.label = labelBtn
    KeyListen.active = true
    labelBtn.Text = "..."
    labelBtn.BackgroundColor3 = C.green
    labelBtn.BackgroundTransparency = 0.3

    local captureId = labelBtn
    task.delay(8, function()
        if KeyListen.label == captureId and KeyListen.active then
            cancelKeyListen()
            if labelBtn and labelBtn.Parent then
                labelBtn.Text = prettyKeyName(Keys.guiHide)
                labelBtn.BackgroundColor3 = C.blue
                labelBtn.BackgroundTransparency = 0.6
                labelBtn.TextColor3 = C.white
            end
        end
    end)
end

UIS.InputBegan:Connect(function(input, gameProcessed)
    if not KeyListen.active then return end
    if gameProcessed then return end

    local ut = input.UserInputType
    if ut ~= Enum.UserInputType.Keyboard and ut ~= Enum.UserInputType.Gamepad1 and ut ~= Enum.UserInputType.Gamepad2 then
        return
    end

    local key = input.KeyCode

    if key == Enum.KeyCode.Escape then
        cancelKeyListen()
        return
    end

    local cb = KeyListen.cb
    local lbl = KeyListen.label
    cancelKeyListen()

    if lbl and lbl.Parent then
        lbl.Text = prettyKeyName(key)
        lbl.BackgroundColor3 = C.blue
        lbl.BackgroundTransparency = 0.6
        lbl.TextColor3 = C.white
    end

    if cb then
        task.spawn(cb, key)
    end
end)

-- ROW BUILDERS
local function addSectionLabel(parent,text,order)
    local wrapper=Instance.new("Frame")
    wrapper.Size=UDim2.new(1,0,0,22)
    wrapper.BackgroundTransparency=1
    wrapper.LayoutOrder=order
    wrapper.Parent=parent
    local L=Instance.new("TextLabel",wrapper)
    L.Size=UDim2.new(1,0,0,16)
    L.Position=UDim2.new(0,0,0,0)
    L.BackgroundTransparency=1
    L.Text=text
    L.TextColor3=C.textDim
    L.TextSize=10
    L.Font=Enum.Font.GothamBold
    L.TextXAlignment=Enum.TextXAlignment.Left
    return L
end

local function addInputRow(parent,label,value,order,callback)
    local Row=Instance.new("Frame")
    Row.Size=UDim2.new(1,0,0,36)
    Row.BackgroundColor3=C.row
    Row.BackgroundTransparency=0.4
    Row.BorderSizePixel=0
    Row.LayoutOrder=order
    Row.Parent=parent
    guiCorner(Row,10)
    guiStroke(Row,C.divider,1)
    local Lbl=Instance.new("TextLabel",Row)
    Lbl.Size=UDim2.new(0.6,0,0,16)
    Lbl.Position=UDim2.new(0,12,0,6)
    Lbl.BackgroundTransparency=1
    Lbl.Text=label
    Lbl.TextColor3=C.text
    Lbl.TextSize=11
    Lbl.Font=Enum.Font.GothamBold
    Lbl.TextXAlignment=Enum.TextXAlignment.Left
    local BoxContainer=Instance.new("Frame",Row)
    BoxContainer.ZIndex=6
    BoxContainer.Position=UDim2.new(1,-58,0.5,-10)
    BoxContainer.Size=UDim2.new(0,48,0,20)
    BoxContainer.BackgroundColor3=C.input
    BoxContainer.BackgroundTransparency=0.4
    BoxContainer.BorderSizePixel=0
    guiCorner(BoxContainer,6)
    guiStroke(BoxContainer,Color3.fromRGB(65,55,75),1)
    local Box=Instance.new("TextBox",BoxContainer)
    Box.ZIndex=7
    Box.Size=UDim2.new(1,0,1,0)
    Box.BackgroundTransparency=1
    Box.Text=tostring(value)
    Box.TextColor3=C.text
    Box.TextSize=11
    Box.Font=Enum.Font.GothamBold
    Box.ClearTextOnFocus=false
    Box.FocusLost:Connect(function()
        local num=tonumber(Box.Text)
        if num and num>0 then callback(num) else Box.Text=tostring(value) end
    end)
    local hover=Instance.new("TextButton",Row)
    hover.Size=UDim2.new(1,0,1,0)
    hover.BackgroundTransparency=1
    hover.Text=""
    hover.ZIndex=0
    hover.MouseEnter:Connect(function() tw(Row,{BackgroundTransparency=0.2}) end)
    hover.MouseLeave:Connect(function() tw(Row,{BackgroundTransparency=0.4}) end)
    return Row, Box
end

local function addToggleRow(parent,label,enabled,order,keybindKey,onToggle)
    local hasKB=keybindKey~=nil
    local Row=Instance.new("Frame")
    Row.Size=UDim2.new(1,0,0,hasKB and 50 or 38)
    Row.BackgroundColor3=C.row
    Row.BackgroundTransparency=0.4
    Row.BorderSizePixel=0
    Row.LayoutOrder=order
    Row.Parent=parent
    guiCorner(Row,10)
    guiStroke(Row,C.divider,1)
    local Lbl=Instance.new("TextLabel",Row)
    Lbl.Size=UDim2.new(0.6,0,0,16)
    Lbl.Position=UDim2.new(0,12,0,6)
    Lbl.BackgroundTransparency=1
    Lbl.Text=label
    Lbl.TextColor3=C.text
    Lbl.TextSize=11
    Lbl.Font=Enum.Font.GothamBold
    Lbl.TextXAlignment=Enum.TextXAlignment.Left
    if hasKB then
        local KBtn=Instance.new("TextButton",Row)
        KBtn.Size=UDim2.new(0,35,0,16)
        KBtn.Position=UDim2.new(0,12,1,-20)
        KBtn.BackgroundColor3 = C.blue
        KBtn.BackgroundTransparency=0.7
        KBtn.BorderSizePixel=0
        KBtn.Text=prettyKeyName(Keys[keybindKey])
        KBtn.TextColor3=C.white
        KBtn.TextSize=9
        KBtn.Font=Enum.Font.GothamBold
        KBtn.ZIndex = 3
        guiCorner(KBtn,5)
        guiStroke(KBtn,Color3.fromRGB(255,255,255),1)
        KBtn.MouseButton1Click:Connect(function()
            startKeyListen(KBtn,function(newKey)
                Keys[keybindKey]=newKey
                KBtn.Text=prettyKeyName(newKey)
                scheduleAutoSave()
            end)
        end)
    end
    local Track=Instance.new("Frame",Row)
    Track.Size=UDim2.new(0,36,0,18)
    Track.Position=UDim2.new(1,-46,0,10)
    Track.BackgroundColor3=C.blueDark
    Track.BackgroundTransparency=0.4
    Track.BorderSizePixel=0
    guiCorner(Track,10)
    guiStroke(Track,C.blueDim,1)
    local Knob=Instance.new("Frame",Track)
    Knob.Size=UDim2.new(0,14,0,14)
    Knob.Position=enabled and UDim2.new(0.5,2,0.5,-7) or UDim2.new(0,2,0.5,-7)
    Knob.BackgroundColor3=C.blue
    Knob.BackgroundTransparency=enabled and 0.2 or 0.4
    Knob.BorderSizePixel=0
    guiCorner(Knob,7)
    local state=enabled
    local function setV(on)
        state=on
        tw(Knob,{Position=on and UDim2.new(0.5,2,0.5,-7) or UDim2.new(0,2,0.5,-7)})
        tw(Knob,{BackgroundTransparency=on and 0.2 or 0.4})
    end
    local Btn=Instance.new("TextButton",Row)
    Btn.Size=UDim2.new(0,36,0,18)
    Btn.Position=UDim2.new(1,-46,0,10)
    Btn.BackgroundTransparency=1
    Btn.Text=""
    Btn.MouseButton1Click:Connect(function()
        state=not state
        setV(state)
        if onToggle then onToggle(state) end
    end)
    local hover=Instance.new("TextButton",Row)
    hover.Size=UDim2.new(1,0,1,0)
    hover.BackgroundTransparency=1
    hover.Text=""
    hover.ZIndex=0
    hover.MouseEnter:Connect(function() tw(Row,{BackgroundTransparency=0.2}) end)
    hover.MouseLeave:Connect(function() tw(Row,{BackgroundTransparency=0.4}) end)
    if keybindKey then GuiToggleSetters[keybindKey] = setV end
    return Row, setV
end

local function addActionRow(parent,label,keybindKey,onAction,order)
    local Row=Instance.new("Frame")
    Row.Size=UDim2.new(1,0,0,42)
    Row.BackgroundColor3=C.row
    Row.BackgroundTransparency=0.4
    Row.BorderSizePixel=0
    Row.LayoutOrder=order
    Row.Parent=parent
    guiCorner(Row,10)
    guiStroke(Row,C.divider,1)
    local Lbl=Instance.new("TextLabel",Row)
    Lbl.Size=UDim2.new(0.55,0,0,16)
    Lbl.Position=UDim2.new(0,12,0,8)
    Lbl.BackgroundTransparency=1
    Lbl.Text=label
    Lbl.TextColor3=C.text
    Lbl.TextSize=11
    Lbl.Font=Enum.Font.GothamBold
    Lbl.TextXAlignment=Enum.TextXAlignment.Left
    local KBtn=Instance.new("TextButton",Row)
    KBtn.Size=UDim2.new(0,40,0,22)
    KBtn.Position=UDim2.new(1,-48,0.5,-11)
    KBtn.BackgroundColor3 = C.blue
    KBtn.BackgroundTransparency=0.7
    KBtn.BorderSizePixel=0
    KBtn.Text=prettyKeyName(Keys[keybindKey])
    KBtn.TextColor3=C.white
    KBtn.TextSize=9
    KBtn.Font=Enum.Font.GothamBold
    KBtn.ZIndex = 3
    guiCorner(KBtn,5)
    guiStroke(KBtn,Color3.fromRGB(255,255,255),1)
    KBtn.MouseButton1Click:Connect(function()
        startKeyListen(KBtn,function(newKey)
            Keys[keybindKey]=newKey
            KBtn.Text=prettyKeyName(newKey)
            scheduleAutoSave()
        end)
    end)
    local ActionBtn=Instance.new("TextButton",Row)
    ActionBtn.Size=UDim2.new(0.55,0,1,0)
    ActionBtn.BackgroundTransparency=1
    ActionBtn.Text=""
    ActionBtn.MouseButton1Click:Connect(onAction)
    local hover=Instance.new("TextButton",Row)
    hover.Size=UDim2.new(1,0,1,0)
    hover.BackgroundTransparency=1
    hover.Text=""
    hover.ZIndex=0
    hover.MouseEnter:Connect(function() tw(Row,{BackgroundTransparency=0.2}) end)
    hover.MouseLeave:Connect(function() tw(Row,{BackgroundTransparency=0.4}) end)
    return Row
end

local function addCycleRow(parent, label, value, order, onCycle)
    local Row=Instance.new("Frame")
    Row.Size=UDim2.new(1,0,0,38)
    Row.BackgroundColor3=C.row
    Row.BackgroundTransparency=0.4
    Row.BorderSizePixel=0
    Row.LayoutOrder=order
    Row.Parent=parent
    guiCorner(Row,10)
    guiStroke(Row,C.divider,1)
    local Lbl=Instance.new("TextLabel",Row)
    Lbl.Size=UDim2.new(0.6,0,0,16)
    Lbl.Position=UDim2.new(0,12,0,6)
    Lbl.BackgroundTransparency=1
    Lbl.Text=label
    Lbl.TextColor3=C.text
    Lbl.TextSize=11
    Lbl.Font=Enum.Font.GothamBold
    Lbl.TextXAlignment=Enum.TextXAlignment.Left
    local CycleBtn=Instance.new("TextButton",Row)
    CycleBtn.Size=UDim2.new(0,70,0,22)
    CycleBtn.Position=UDim2.new(1,-80,0.5,-11)
    CycleBtn.BackgroundColor3=C.blue
    CycleBtn.BackgroundTransparency=0.4
    CycleBtn.BorderSizePixel=0
    CycleBtn.Text=value
    CycleBtn.TextColor3=C.white
    CycleBtn.TextSize=10
    CycleBtn.Font=Enum.Font.GothamBold
    guiCorner(CycleBtn,5)
    CycleBtn.MouseButton1Click:Connect(function()
        local newVal = onCycle()
        CycleBtn.Text = newVal
    end)
    local hover=Instance.new("TextButton",Row)
    hover.Size=UDim2.new(1,0,1,0)
    hover.BackgroundTransparency=1
    hover.Text=""
    hover.ZIndex=0
    hover.MouseEnter:Connect(function() tw(Row,{BackgroundTransparency=0.2}) end)
    hover.MouseLeave:Connect(function() tw(Row,{BackgroundTransparency=0.4}) end)
    return Row, CycleBtn
end

-- CATEGORIES
local Categories = {"Speed", "Mechanics", "Movement", "Visual", "Utils", "Settings"}
local CategoryRefs = {contents={}, btnsBottom={}, active="Speed"}

do
    for _,name in pairs(Categories) do
        local page=Instance.new("Frame")
        page.Size=UDim2.new(1,0,1,0)
        page.BackgroundTransparency=1
        page.Visible=(name=="Speed")
        page.Parent=GuiRefs.contentFrame
        CategoryRefs.contents[name]=page
        local layout=Instance.new("UIListLayout")
        layout.SortOrder=Enum.SortOrder.LayoutOrder
        layout.Padding=UDim.new(0,6)
        layout.Parent=page
    end

    for i,name in ipairs(Categories) do
        local btn=Instance.new("TextButton")
        btn.Size=UDim2.new(0,90,0,34)
        btn.BackgroundTransparency=1
        btn.Text=name
        btn.TextColor3=(name=="Speed") and C.white or C.textMuted
        btn.TextSize=11
        btn.Font=Enum.Font.GothamBold
        btn.BorderSizePixel=0
        btn.LayoutOrder=i
        btn.Parent=GuiRefs.categoryBar

        CategoryRefs.btnsBottom[name]=btn
        btn.MouseButton1Click:Connect(function()
            for _,f in pairs(CategoryRefs.contents) do f.Visible=false end
            CategoryRefs.contents[name].Visible=true
            CategoryRefs.active=name
            for n,b in pairs(CategoryRefs.btnsBottom) do
                local active=(n==name)
                b.TextColor3=active and C.white or C.textMuted
            end
        end)
        btn.MouseEnter:Connect(function()
            if CategoryRefs.active~=name then btn.TextColor3=C.textDim end
        end)
        btn.MouseLeave:Connect(function()
            if CategoryRefs.active~=name then btn.TextColor3=C.textMuted end
        end)
    end

    if CategoryRefs.btnsBottom["Speed"] then
        CategoryRefs.btnsBottom["Speed"].TextColor3 = C.white
    end
end

-- SPEED PAGE
do
    local sp=CategoryRefs.contents["Speed"]
    addSectionLabel(sp,"SPEED CONFIGURATION",0)
    addInputRow(sp,"Normal Speed",State.normalSpeed,1,function(v) State.normalSpeed=v; scheduleAutoSave() end)
    addInputRow(sp,"Carry Speed",State.carrySpeed,2,function(v) State.carrySpeed=v; scheduleAutoSave() end)
    addSectionLabel(sp,"LAGGER MODE",3)
    addInputRow(sp,"Lagger Speed",State.laggerSpeed,4,function(v) State.laggerSpeed=v; scheduleAutoSave() end)
    addSectionLabel(sp,"CONTROLS",5)
    addToggleRow(sp,"Carry Mode",State.speedToggled,6,"speed",function(on) State.speedToggled=on; scheduleAutoSave(); updateFloatingButtons() end)
    addToggleRow(sp,"Lagger Mode (R key)",State.laggerModeEnabled,7,"laggerToggle",function(on) 
        toggleLaggerMode()
    end)
end

-- MECHANICS PAGE
do
    local mp=CategoryRefs.contents["Mechanics"]
    addSectionLabel(mp,"AUTO GRAB",0)
    addToggleRow(mp,"Auto Grab",CONFIG.AUTO_STEAL_ENABLED,1,nil,function(on) CONFIG.AUTO_STEAL_ENABLED=on; if on then startAutoSteal() else stopAutoSteal() end; scheduleAutoSave() end)
    addInputRow(mp,"Scan Range",CONFIG.PRIME_RANGE,2,function(v) CONFIG.PRIME_RANGE=math.clamp(math.floor(v),5,300); scheduleAutoSave() end)
    addSectionLabel(mp,"COMBAT",3)
    addToggleRow(mp,"Auto Bat",State.circleEnabled,4,"circle",function(on) setCircleState(on) end)
    addSectionLabel(mp,"MOVEMENT",5)
    addToggleRow(mp,"Auto Dodge",State.doubleJumpTpEnabled,6,"doubleJumpTp",function(on)
        if on then startDoubleJumpTpLoop() else stopDoubleJumpTpLoop() end
        scheduleAutoSave()
    end)
    addSectionLabel(mp,"DEFENSE",7)
    addToggleRow(mp,"Anti Ragdoll",State.antiRagdollEnabled,8,nil,function(on) State.antiRagdollEnabled=on; if on then startAntiRagdoll() else stopAntiRagdoll() end; scheduleAutoSave() end)
    addToggleRow(mp,"Medusa Counter",State.medusaCounterEnabled,9,nil,function(on) State.medusaCounterEnabled=on; if on then setupMedusaCounter(LP.Character) else stopMedusaCounter() end; scheduleAutoSave() end)
end

-- MOVEMENT PAGE
do
    local mv = CategoryRefs.contents["Movement"]
    
    addSectionLabel(mv, "JUMP", 0)
    addToggleRow(mv, "Infinite Jump", State.infJumpEnabled, 1, nil, function(on) setInfJumpInternal(on) end)
    
    addSectionLabel(mv, "ANIMATIONS", 2)
    addToggleRow(mv, "rembembi", State.animEnabled, 3, nil, function(on) 
        State.animEnabled = on
        if on then 
            startAnimToggle() 
        else 
            stopAnimToggle() 
        end
        scheduleAutoSave() 
    end)
    addToggleRow(mv, "Zombie", State.zombieModeEnabled, 4, nil, function(on) 
        setZombieMode(on) 
    end)
    
    addSectionLabel(mv, "ANIMATION PRESETS", 5)
    
    local animContainer = Instance.new("ScrollingFrame")
    animContainer.Size = UDim2.new(1, 0, 0, 180)
    animContainer.BackgroundTransparency = 1
    animContainer.BorderSizePixel = 0
    animContainer.ScrollBarThickness = 3
    animContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    animContainer.LayoutOrder = 6
    animContainer.Parent = mv
    
    local animLayout = Instance.new("UIListLayout")
    animLayout.SortOrder = Enum.SortOrder.LayoutOrder
    animLayout.Padding = UDim.new(0, 3)
    animLayout.Parent = animContainer
    
    local allAnimations = {
        {name = "Ninja", anims = {["idle.Animation1"]="656117400",["idle.Animation2"]="656118341",["walk.WalkAnim"]="656121766",["run.RunAnim"]="656118852",["jump.JumpAnim"]="656117878",["climb.ClimbAnim"]="656114359",["fall.FallAnim"]="656115606"}},
        {name = "Levitation", anims = {["idle.Animation1"]="616006778",["idle.Animation2"]="616008087",["walk.WalkAnim"]="616013216",["run.RunAnim"]="616010382",["jump.JumpAnim"]="616008936",["climb.ClimbAnim"]="616003713",["fall.FallAnim"]="616005863"}},
        {name = "Werewolf", anims = {["idle.Animation1"]="1083195517",["idle.Animation2"]="1083214717",["walk.WalkAnim"]="1083178339",["run.RunAnim"]="1083216690",["jump.JumpAnim"]="1083218792",["climb.ClimbAnim"]="1083182000",["fall.FallAnim"]="1083189019"}},
        {name = "Stylish", anims = {["idle.Animation1"]="616136790",["idle.Animation2"]="616138447",["walk.WalkAnim"]="616146177",["run.RunAnim"]="616140816",["jump.JumpAnim"]="616139451",["climb.ClimbAnim"]="616133594",["fall.FallAnim"]="616134815"}},
        {name = "Robot", anims = {["idle.Animation1"]="616088211",["idle.Animation2"]="616089559",["walk.WalkAnim"]="616095330",["run.RunAnim"]="616091570",["jump.JumpAnim"]="616090535",["climb.ClimbAnim"]="616086039",["fall.FallAnim"]="616087089"}},
        {name = "Bubbly", anims = {["idle.Animation1"]="910004836",["idle.Animation2"]="910009958",["walk.WalkAnim"]="910034870",["run.RunAnim"]="910025107",["jump.JumpAnim"]="910016857",["fall.FallAnim"]="910001910",["swimidle.SwimIdle"]="910030921",["swim.Swim"]="910028158"}},
        {name = "Cartoony", anims = {["idle.Animation1"]="742637544",["idle.Animation2"]="742638445",["walk.WalkAnim"]="742640026",["run.RunAnim"]="742638842",["jump.JumpAnim"]="742637942",["climb.ClimbAnim"]="742636889",["fall.FallAnim"]="742637151"}},
        {name = "SuperHero", anims = {["idle.Animation1"]="616111295",["idle.Animation2"]="616113536",["walk.WalkAnim"]="616122287",["run.RunAnim"]="616117076",["jump.JumpAnim"]="616115533",["climb.ClimbAnim"]="616104706",["fall.FallAnim"]="616108001"}},
        {name = "Knight", anims = {["idle.Animation1"]="657595757",["idle.Animation2"]="657568135",["walk.WalkAnim"]="657552124",["run.RunAnim"]="657564596",["jump.JumpAnim"]="658409194",["climb.ClimbAnim"]="658360781",["fall.FallAnim"]="657600338"}},
        {name = "Zombie", anims = {["idle.Animation1"]="616158929",["idle.Animation2"]="616160636",["walk.WalkAnim"]="616168032",["run.RunAnim"]="616163682",["jump.JumpAnim"]="616161997",["climb.ClimbAnim"]="616156119",["fall.FallAnim"]="616157476"}},
        {name = "Elder", anims = {["idle.Animation1"]="845397899",["idle.Animation2"]="845400520",["walk.WalkAnim"]="845403856",["run.RunAnim"]="845386501",["jump.JumpAnim"]="845398858",["climb.ClimbAnim"]="845392038",["fall.FallAnim"]="845396048"}},
        {name = "Astronaut", anims = {["idle.Animation1"]="891621366",["idle.Animation2"]="891633237",["walk.WalkAnim"]="891667138",["run.RunAnim"]="891636393",["jump.JumpAnim"]="891627522",["climb.ClimbAnim"]="891609353",["fall.FallAnim"]="891617961"}},
        {name = "Adidas", anims = {["idle.Animation1"]="18537376492",["idle.Animation2"]="18537371272",["walk.WalkAnim"]="18537392113",["run.RunAnim"]="18537384940",["jump.JumpAnim"]="18537380791",["climb.ClimbAnim"]="18537363391",["fall.FallAnim"]="18537367238",["swim.Swim"]="18537389531",["swimidle.SwimIdle"]="18537387180",["pose.StylishPose"]="18537374150"}},
        {name = "Toy", anims = {["idle.Animation1"]="782841498",["idle.Animation2"]="782845736",["walk.WalkAnim"]="782843345",["run.RunAnim"]="782842708",["jump.JumpAnim"]="782847020",["climb.ClimbAnim"]="782843869",["fall.FallAnim"]="782846423"}},
        {name = "Pirate", anims = {["idle.Animation1"]="750781874",["idle.Animation2"]="750782770",["walk.WalkAnim"]="750785693",["run.RunAnim"]="750783738",["jump.JumpAnim"]="750782230",["climb.ClimbAnim"]="750779899",["fall.FallAnim"]="750780242"}},
        {name = "Vampire", anims = {["idle.Animation1"]="1083445855",["idle.Animation2"]="1083450166",["walk.WalkAnim"]="1083473930",["run.RunAnim"]="1083462077",["jump.JumpAnim"]="1083455352",["climb.ClimbAnim"]="1083439238",["fall.FallAnim"]="1083443587"}},
        {name = "Patrol", anims = {["idle.Animation1"]="1149612882",["idle.Animation2"]="1150842221",["walk.WalkAnim"]="1151231493",["run.RunAnim"]="1150967949",["jump.JumpAnim"]="1148811837",["climb.ClimbAnim"]="1148811837",["fall.FallAnim"]="1148863382"}},
        {name = "Confident", anims = {["idle.Animation1"]="1069977950",["idle.Animation2"]="1069987858",["walk.WalkAnim"]="1070017263",["run.RunAnim"]="1070001516",["jump.JumpAnim"]="1069984524",["climb.ClimbAnim"]="1069946257",["fall.FallAnim"]="1069973677"}},
        {name = "Popstar", anims = {["idle.Animation1"]="1212900985",["idle.Animation2"]="1150842221",["walk.WalkAnim"]="1212980338",["run.RunAnim"]="1212980348",["jump.JumpAnim"]="1212954642",["climb.ClimbAnim"]="1213044953",["fall.FallAnim"]="1212900995"}},
        {name = "Sneaky", anims = {["idle.Animation1"]="1132473842",["idle.Animation2"]="1132477671",["walk.WalkAnim"]="1132510133",["run.RunAnim"]="1132494274",["jump.JumpAnim"]="1132489853",["climb.ClimbAnim"]="1132461372",["fall.FallAnim"]="1132469004"}},
        {name = "Princess", anims = {["idle.Animation1"]="941003647",["idle.Animation2"]="941013098",["walk.WalkAnim"]="941028902",["run.RunAnim"]="941015281",["jump.JumpAnim"]="941008832",["climb.ClimbAnim"]="940996062",["fall.FallAnim"]="941000007"}},
        {name = "Cowboy", anims = {["idle.Animation1"]="1014390418",["idle.Animation2"]="1014398616",["walk.WalkAnim"]="1014421541",["run.RunAnim"]="1014401683",["jump.JumpAnim"]="1014394726",["climb.ClimbAnim"]="1014380606",["fall.FallAnim"]="1014384571"}},
        {name = "Ghost", anims = {["idle.Animation1"]="616006778",["idle.Animation2"]="616008087",["walk.WalkAnim"]="616013216",["run.RunAnim"]="616013216",["jump.JumpAnim"]="616008936",["fall.FallAnim"]="616005863",["swimidle.SwimIdle"]="616012453",["swim.Swim"]="616011509"}},
        {name = "None", anims = {["idle.Animation1"]="0",["idle.Animation2"]="0",["walk.WalkAnim"]="0",["run.RunAnim"]="0",["jump.JumpAnim"]="0",["fall.FallAnim"]="0",["swimidle.SwimIdle"]="0",["swim.Swim"]="0"}},
        {name = "Anthro", anims = {["idle.Animation1"]="2510196951",["idle.Animation2"]="2510197257",["walk.WalkAnim"]="2510202577",["run.RunAnim"]="2510198475",["jump.JumpAnim"]="2510197830",["climb.ClimbAnim"]="2510192778",["fall.FallAnim"]="2510195892",["swim.Swim"]="10921264784",["swimidle.SwimIdle"]="10921265698"}},
    }
    
    local function createAnimButton(parent, labelText, anims)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -4, 0, 28)
        btn.BackgroundColor3 = C.row
        btn.BackgroundTransparency = 0.3
        btn.BorderSizePixel = 0
        btn.AutoButtonColor = false
        btn.Text = ""
        btn.Parent = parent
        guiCorner(btn, 6)
        guiStroke(btn, C.divider, 0.8)

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -8, 1, 0)
        lbl.Position = UDim2.new(0, 4, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = labelText
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 10
        lbl.TextColor3 = C.text
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = btn

        local busy = false
        btn.MouseButton1Click:Connect(function()
            if busy then return end
            local animate = LP.Character and LP.Character:FindFirstChild("Animate")
            if not animate then return end
            busy = true
            local oldText = lbl.Text
            lbl.Text = "âœ“"
            tw(btn, {BackgroundColor3 = C.blue, BackgroundTransparency = 0.2}, 0.15)
            
            for key, id in pairs(anims) do
                local path = string.split(key, ".")
                local current = animate
                for i = 1, #path do
                    current = current[path[i]]
                    if not current then break end
                end
                if current and current:IsA("Animation") then
                    current.AnimationId = "http://www.roblox.com/asset/?id=" .. id
                end
            end
            if LP.Character and LP.Character:FindFirstChild("Humanoid") then
                LP.Character.Humanoid.Jump = true
            end
            
            task.delay(0.3, function()
                lbl.Text = oldText
                tw(btn, {BackgroundColor3 = C.row, BackgroundTransparency = 0.3}, 0.15)
                busy = false
            end)
        end)
        
        btn.MouseEnter:Connect(function()
            if not busy then tw(btn, {BackgroundTransparency = 0.15}, 0.1) end
        end)
        btn.MouseLeave:Connect(function()
            if not busy then tw(btn, {BackgroundTransparency = 0.3}, 0.1) end
        end)
        
        return btn
    end
    
    for _, animData in ipairs(allAnimations) do
        createAnimButton(animContainer, animData.name, animData.anims)
    end
    
    task.wait(0.1)
    local layout = animContainer:FindFirstChildWhichIsA("UIListLayout")
    if layout then
        animContainer.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            animContainer.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
        end)
    end
end

-- VISUAL PAGE
do
    local vi = CategoryRefs.contents["Visual"]

    addSectionLabel(vi, "CUSTOM SKY", 0)
    
    local skyRow, skyBtn = addCycleRow(vi, "Sky Effect", getSkyModeText(), 1, function()
        nextSkyMode()
        return getSkyModeText()
    end)

    addSectionLabel(vi, "BACKGROUND IMAGE", 2)

    local BgRow = Instance.new("Frame")
    BgRow.Size = UDim2.new(1, 0, 0, 56)
    BgRow.BackgroundColor3 = C.row
    BgRow.BackgroundTransparency = 0.4
    BgRow.BorderSizePixel = 0
    BgRow.LayoutOrder = 3
    BgRow.ZIndex = 2
    BgRow.Parent = vi
    guiCorner(BgRow, 10)
    guiStroke(BgRow, C.divider, 1)

    local BtnNone = Instance.new("TextButton", BgRow)
    BtnNone.Size = UDim2.new(0, 30, 0, 38)
    BtnNone.Position = UDim2.new(0, 4, 0.5, -19)
    BtnNone.BackgroundColor3 = C.blue
    BtnNone.BackgroundTransparency = State.backgroundIndex == 0 and 0.2 or 0.5
    BtnNone.BorderSizePixel = 0
    BtnNone.Text = "âœ•"
    BtnNone.TextColor3 = C.white
    BtnNone.TextSize = 14
    BtnNone.Font = Enum.Font.GothamBold
    BtnNone.ZIndex = 3
    guiCorner(BtnNone, 7)
    local StrokeNone = guiStroke(BtnNone, State.backgroundIndex == 0 and C.blue or C.divider, 1.5)

    local previews = {}
    local strokes = {}
    local btns = {}
    local imgSize = 34
    local spacing = 2
    local startX = 38

    for i = 1, 5 do
        local xPos = startX + (i - 1) * (imgSize + spacing)
        
        local Preview = Instance.new("Frame", BgRow)
        Preview.Size = UDim2.new(0, imgSize, 0, 38)
        Preview.Position = UDim2.new(0, xPos, 0.5, -19)
        Preview.BackgroundColor3 = C.darkBg
        Preview.BorderSizePixel = 0
        guiCorner(Preview, 7)
        local Stroke = guiStroke(Preview, State.backgroundIndex == i and C.blue or C.divider, 1.5)
        strokes[i] = Stroke
        
        local Img = Instance.new("ImageLabel", Preview)
        Img.Size = UDim2.new(1, 0, 1, 0)
        Img.BackgroundTransparency = 1
        Img.Image = "rbxassetid://" .. BG_IMAGES[i]
        Img.ScaleType = Enum.ScaleType.Crop
        guiCorner(Img, 7)
        
        local numLbl = Instance.new("TextLabel", Preview)
        numLbl.Size = UDim2.new(1, 0, 10, 0)
        numLbl.Position = UDim2.new(0, 0, 1, -10)
        numLbl.BackgroundTransparency = 1
        numLbl.Text = tostring(i)
        numLbl.TextColor3 = C.textDim
        numLbl.TextSize = 8
        numLbl.Font = Enum.Font.GothamBold
        numLbl.TextXAlignment = Enum.TextXAlignment.Center
        numLbl.ZIndex = 5
        
        local Btn = Instance.new("TextButton", Preview)
        Btn.Size = UDim2.new(1, 0, 1, 0)
        Btn.BackgroundTransparency = 1
        Btn.Text = ""
        Btn.ZIndex = 4
        btns[i] = Btn
        
        previews[i] = Preview
    end

    local function updateBgButtons(index)
        tw(BtnNone, {BackgroundTransparency = index == 0 and 0.2 or 0.5})
        StrokeNone.Color = index == 0 and C.blue or C.divider
        for i = 1, 5 do
            if strokes[i] then
                strokes[i].Color = index == i and C.blue or C.divider
            end
        end
    end

    local function applyBg(index)
        State.backgroundIndex = index or 0
        if not GuiRefs.backgroundImage then return end
        
        if State.backgroundIndex == 0 then
            GuiRefs.backgroundImage.Visible = false
            if GuiRefs.bgGrad then GuiRefs.bgGrad.Visible = true end
            if BypassBgImage then BypassBgImage.Visible = false end
            if BypassBgGrad then BypassBgGrad.Visible = true end
            State.backgroundEnabled = false
        else
            local imgId = BG_IMAGES[State.backgroundIndex]
            if imgId then
                GuiRefs.backgroundImage.Image = "rbxassetid://" .. imgId
                GuiRefs.backgroundImage.Visible = true
                if GuiRefs.bgGrad then GuiRefs.bgGrad.Visible = false end
                if BypassBgImage then 
                    BypassBgImage.Image = "rbxassetid://" .. imgId
                    BypassBgImage.Visible = true
                end
                if BypassBgGrad then BypassBgGrad.Visible = false end
                State.backgroundEnabled = true
            end
        end
        updateBgButtons(index)
        scheduleAutoSave()
    end

    BtnNone.MouseButton1Click:Connect(function()
        applyBg(0)
    end)

    for i = 1, 5 do
        btns[i].MouseButton1Click:Connect(function()
            applyBg(i)
        end)
    end

    BgRow.MouseEnter:Connect(function() tw(BgRow, {BackgroundTransparency=0.2}) end)
    BgRow.MouseLeave:Connect(function() tw(BgRow, {BackgroundTransparency=0.4}) end)

    addSectionLabel(vi, "CAMERA", 4)
    local _, fovBox = addInputRow(vi, "FOV", State.fov, 5, function(v)
        local clamped = math.clamp(math.floor(v), 70, 120)
        State.fov = clamped
        pcall(function() workspace.CurrentCamera.FieldOfView = clamped end)
        scheduleAutoSave()
    end)

    addToggleRow(vi, "Stretch Rez", State.stretchResEnabled, 6, nil, function(on)
        setStretchRes(on)
    end)
end

-- UTILS PAGE
local BypassGuiRef = nil
local BypassBgImage = nil
local BypassBgGrad = nil

do
    local ut = CategoryRefs.contents["Utils"]
    addSectionLabel(ut, "ACTIONS", 0)
    addActionRow(ut, "Drop Brainrot", "dropBrainrot", function() runDropBrainrot() end, 1)
    addActionRow(ut, "TP Down", "tpDown", function() tpDown() end, 2)
    addActionRow(ut, "Reset", "instaReset", function() doInstaReset() end, 3)
    
    local resetRow = Instance.new("Frame")
    resetRow.Size = UDim2.new(1, 0, 0, 42)
    resetRow.BackgroundColor3 = C.row
    resetRow.BackgroundTransparency = 0.4
    resetRow.BorderSizePixel = 0
    resetRow.LayoutOrder = 4
    resetRow.Parent = ut
    guiCorner(resetRow, 10)
    guiStroke(resetRow, C.divider, 1)

    local resetLbl = Instance.new("TextLabel", resetRow)
    resetLbl.Size = UDim2.new(0.6, 0, 0, 16)
    resetLbl.Position = UDim2.new(0, 12, 0, 8)
    resetLbl.BackgroundTransparency = 1
    resetLbl.Text = "Instant Reset Key"
    resetLbl.TextColor3 = C.text
    resetLbl.TextSize = 11
    resetLbl.Font = Enum.Font.GothamBold
    resetLbl.TextXAlignment = Enum.TextXAlignment.Left

    local resetKBtn = Instance.new("TextButton", resetRow)
    resetKBtn.Size = UDim2.new(0, 45, 0, 22)
    resetKBtn.Position = UDim2.new(1, -52, 0.5, -11)
    resetKBtn.BackgroundColor3 = C.blue
    resetKBtn.BackgroundTransparency = 0.7
    resetKBtn.BorderSizePixel = 0
    resetKBtn.Text = prettyKeyName(Keys.instaReset)
    resetKBtn.TextColor3 = C.white
    resetKBtn.TextSize = 9
    resetKBtn.Font = Enum.Font.GothamBold
    resetKBtn.ZIndex = 3
    guiCorner(resetKBtn, 5)
    guiStroke(resetKBtn, Color3.fromRGB(255,255,255), 1)
    resetKBtn.MouseButton1Click:Connect(function()
        startKeyListen(resetKBtn, function(newKey)
            Keys.instaReset = newKey
            State.instaResetKey = newKey.Name
            resetKBtn.Text = prettyKeyName(newKey)
            scheduleAutoSave()
        end)
    end)
end

-- SETTINGS PAGE
do
    local sg = CategoryRefs.contents["Settings"]
    addSectionLabel(sg, "PERFORMANCE", 0)
    
    -- FPS BOOST TOGGLE - FIXED
    addToggleRow(sg, "FPS Boost", State.fpsBoostEnabled, 1, nil, function(on)
        State.fpsBoostEnabled = on
        if on then 
            applyFPSBoost() 
        else 
            disableFPSBoost() 
        end
        scheduleAutoSave()
    end)

    addSectionLabel(sg, "GUI", 2)
    addToggleRow(sg, "Side Buttons", State.floatingBtnsVisible, 3, nil, function(on)
        applyFloatingBtnsVisibility(on)
    end)
    addToggleRow(sg, "Bypass GUI", State.bypassGuiVisible, 4, nil, function(on)
        State.bypassGuiVisible = on
        if BypassGuiRef then BypassGuiRef.Enabled = on end
        scheduleAutoSave()
    end)

    local guiRow = Instance.new("Frame")
    guiRow.Size = UDim2.new(1, 0, 0, 42)
    guiRow.BackgroundColor3 = C.row
    guiRow.BackgroundTransparency = 0.4
    guiRow.BorderSizePixel = 0
    guiRow.LayoutOrder = 5
    guiRow.Parent = sg
    guiCorner(guiRow, 10)
    guiStroke(guiRow, C.divider, 1)

    local guiRowLbl = Instance.new("TextLabel", guiRow)
    guiRowLbl.Size = UDim2.new(0.6, 0, 0, 16)
    guiRowLbl.Position = UDim2.new(0, 12, 0, 8)
    guiRowLbl.BackgroundTransparency = 1
    guiRowLbl.Text = "Hide GUI Key"
    guiRowLbl.TextColor3 = C.text
    guiRowLbl.TextSize = 11
    guiRowLbl.Font = Enum.Font.GothamBold
    guiRowLbl.TextXAlignment = Enum.TextXAlignment.Left

    local guiKBtn = Instance.new("TextButton", guiRow)
    guiKBtn.Size = UDim2.new(0, 45, 0, 22)
    guiKBtn.Position = UDim2.new(1, -52, 0.5, -11)
    guiKBtn.BackgroundColor3 = C.blue
    guiKBtn.BackgroundTransparency = 0.7
    guiKBtn.BorderSizePixel = 0
    guiKBtn.Text = prettyKeyName(Keys.guiHide)
    guiKBtn.TextColor3 = C.white
    guiKBtn.TextSize = 9
    guiKBtn.Font = Enum.Font.GothamBold
    guiKBtn.ZIndex = 3
    guiCorner(guiKBtn, 5)
    guiStroke(guiKBtn, Color3.fromRGB(255,255,255), 1)
    guiKBtn.MouseButton1Click:Connect(function()
        startKeyListen(guiKBtn, function(newKey)
            Keys.guiHide = newKey
            guiKBtn.Text = prettyKeyName(newKey)
            scheduleAutoSave()
        end)
    end)
end

-- SPEED BYPASS GUI
local function createSpeedBypassGUI()
    local DEPTH=296
    local SBC = SpeedBypassConfig
    local SBState={laggerRunning=false,laggerBomb=nil,laggerThread=nil}
    local LAGGER_PRESETS={V1={power=400000,wait=0.34,depth=296},V2={power=55000,wait=0.17,depth=296}}
    local SBUI={}
    local updateUI
    local function buildBomb(power,depth)
        local mt={}
        local st={}
        table.insert(st,{})
        local z=st[1]
        for i=1,depth do
            local t={}
            table.insert(z,t)
            z=t
        end
        for i=1,math.floor(power/(depth+2)) do
            table.insert(mt,st)
        end
        return mt
    end
    local function startLagger()
        if SBState.laggerRunning then return end
        SBState.laggerRunning=true
        NetworkClient:SetOutgoingKBPSLimit(math.huge)
        local preset=LAGGER_PRESETS[SBC.LaggerVersion]
        SBState.laggerBomb=buildBomb(preset.power,preset.depth)
        local waitTime=preset.wait
        SBState.laggerThread=task.spawn(function()
            while SBState.laggerRunning do
                pcall(function() game.RobloxReplicatedStorage.SetPlayerBlockList:FireServer(SBState.laggerBomb) end)
                task.wait(waitTime)
            end
        end)
    end
    local function stopLagger()
        if not SBState.laggerRunning then return end
        SBState.laggerRunning=false
        if SBState.laggerThread then task.cancel(SBState.laggerThread) end
        SBState.laggerBomb=nil
        NetworkClient:SetOutgoingKBPSLimit(0)
    end
    local function toggleLaggerBypass()
        if SBState.laggerRunning then stopLagger() else startLagger() end
        updateUI()
    end
    local function restartLagger()
        if SBState.laggerRunning then
            stopLagger()
            task.wait(0.1)
            startLagger()
        end
    end

    function updateUI()
        if SBUI.lagBtn then
            SBUI.lagBtn.Text=(SBState.laggerRunning and "Stop" or "Start").." Lagger"
            SBUI.lagBtn.BackgroundColor3=SBState.laggerRunning and C.green or C.blue
        end
        if SBUI.lvLabel then SBUI.lvLabel.Text="Lagger: "..SBC.LaggerVersion end
        if SBUI.lv1 and SBUI.lv2 then
            SBUI.lv1.BackgroundColor3=SBC.LaggerVersion=="V1" and C.blue or C.blueDark
            SBUI.lv1.BackgroundTransparency=SBC.LaggerVersion=="V1" and 0.3 or 0.5
            SBUI.lv2.BackgroundColor3=SBC.LaggerVersion=="V2" and C.blue or C.blueDark
            SBUI.lv2.BackgroundTransparency=SBC.LaggerVersion=="V2" and 0.3 or 0.5
        end
    end

    local bg=Instance.new("ScreenGui")
    bg.Name="RavenBypassGUI"
    bg.ResetOnSpawn=false
    bg.Enabled=State.bypassGuiVisible
    bg.Parent=PlayerGui
    BypassGuiRef = bg

    local bm=Instance.new("Frame",bg)
    bm.Size=UDim2.new(0,200,0,170)
    bm.Position=UDim2.new(1,-210,0.5,-85)
    bm.BackgroundColor3=C.bgDark
    bm.BackgroundTransparency=0.05
    bm.BorderSizePixel=0
    bm.ClipsDescendants=true
    bm.ZIndex = 1
    guiCorner(bm,16)
    guiStroke(bm,Color3.fromRGB(55,45,70),1.5)
    makeDraggable(bm)

    local bypassBgContainer = Instance.new("Frame", bm)
    bypassBgContainer.Name = "BypassBgContainer"
    bypassBgContainer.Size = UDim2.new(1, 0, 1, 0)
    bypassBgContainer.BackgroundTransparency = 1
    bypassBgContainer.ZIndex = 0
    bypassBgContainer.Parent = bm

    BypassBgGrad = Instance.new("Frame", bypassBgContainer)
    BypassBgGrad.Name = "BypassBgGrad"
    BypassBgGrad.Size = UDim2.new(1, 0, 1, 0)
    BypassBgGrad.BackgroundColor3 = C.bgDark
    BypassBgGrad.BorderSizePixel = 0
    BypassBgGrad.ZIndex = 0
    guiCorner(BypassBgGrad, 16)
    local bypassGrad = Instance.new("UIGradient", BypassBgGrad)
    bypassGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(35,18,40)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(18,14,22))
    })
    bypassGrad.Rotation = 135

    BypassBgImage = Instance.new("ImageLabel", bypassBgContainer)
    BypassBgImage.Name = "BypassBgImage"
    BypassBgImage.Size = UDim2.new(1, 0, 1, 0)
    BypassBgImage.BackgroundTransparency = 1
    BypassBgImage.ScaleType = Enum.ScaleType.Crop
    BypassBgImage.Visible = false
    BypassBgImage.ZIndex = 0
    guiCorner(BypassBgImage, 16)

    if State.backgroundIndex == 0 then
        BypassBgImage.Visible = false
        BypassBgGrad.Visible = true
    else
        local imgId = BG_IMAGES[State.backgroundIndex]
        if imgId then
            BypassBgImage.Image = "rbxassetid://" .. imgId
            BypassBgImage.Visible = true
            BypassBgGrad.Visible = false
        end
    end

    local bh=Instance.new("Frame",bm)
    bh.Size=UDim2.new(1,0,0,38)
    bh.BackgroundColor3=C.bgDark
    bh.BackgroundTransparency=0.3
    bh.BorderSizePixel=0
    bh.ZIndex = 2
    guiCorner(bh,16)
    local bhFill=Instance.new("Frame",bh)
    bhFill.Size=UDim2.new(1,0,0,16)
    bhFill.Position=UDim2.new(0,0,1,-16)
    bhFill.BackgroundColor3=C.bgDark
    bhFill.BackgroundTransparency=0.3
    bhFill.BorderSizePixel=0
    local bt=Instance.new("TextLabel",bh)
    bt.Size=UDim2.new(1,-40,1,0)
    bt.Position=UDim2.new(0,10,0,0)
    bt.BackgroundTransparency=1
    bt.Text="Lagger"
    bt.TextColor3=C.text
    bt.TextSize=12
    bt.Font=Enum.Font.GothamBlack
    bt.TextXAlignment=Enum.TextXAlignment.Left
    bt.ZIndex = 3
    local bSep=Instance.new("Frame",bm)
    bSep.Size=UDim2.new(1,-20,0,1)
    bSep.Position=UDim2.new(0,10,0,38)
    bSep.BackgroundColor3=C.blue
    bSep.BackgroundTransparency=0.5
    bSep.BorderSizePixel=0
    bSep.ZIndex = 2
    local y=46
    local function bRow(h)
        local f=Instance.new("Frame",bm)
        f.Size=UDim2.new(0.84,0,0,h)
        f.Position=UDim2.new(0.08,0,0,y)
        f.BackgroundColor3=C.row
        f.BackgroundTransparency=0.4
        f.BorderSizePixel=0
        f.ZIndex = 2
        guiCorner(f,8)
        guiStroke(f,C.divider,1)
        y=y+h+6
        return f
    end
    local function bBtn(text,h,pink)
        local f=Instance.new("TextButton",bm)
        f.Size=UDim2.new(0.84,0,0,h)
        f.Position=UDim2.new(0.08,0,0,y)
        f.BackgroundColor3=pink and C.blue or C.row
        f.BackgroundTransparency=0.3
        f.BorderSizePixel=0
        f.Text=text
        f.TextColor3=C.white
        f.TextSize=12
        f.Font=Enum.Font.GothamBold
        f.ZIndex = 3
        guiCorner(f,8)
        guiStroke(f,C.divider,1)
        y=y+h+6
        return f
    end

    SBUI.lagBtn=bBtn("Start Lagger",28,true)
    SBUI.lagBtn.MouseButton1Click:Connect(toggleLaggerBypass)

    local lvRow=bRow(28)
    SBUI.lvLabel=Instance.new("TextLabel",lvRow)
    SBUI.lvLabel.Size=UDim2.new(0.5,0,1,0)
    SBUI.lvLabel.Position=UDim2.new(0,8,0,0)
    SBUI.lvLabel.BackgroundTransparency=1
    SBUI.lvLabel.Text="Lagger: V1"
    SBUI.lvLabel.TextColor3=C.text
    SBUI.lvLabel.TextSize=10
    SBUI.lvLabel.Font=Enum.Font.Gotham
    SBUI.lvLabel.TextXAlignment=Enum.TextXAlignment.Left
    SBUI.lvLabel.ZIndex = 3
    SBUI.lv1=Instance.new("TextButton",lvRow)
    SBUI.lv1.Size=UDim2.new(0.2,0,0.7,0)
    SBUI.lv1.Position=UDim2.new(0.56,0,0.15,0)
    SBUI.lv1.BackgroundColor3=C.blue
    SBUI.lv1.BackgroundTransparency=0.3
    SBUI.lv1.Text="V1"
    SBUI.lv1.TextColor3=C.white
    SBUI.lv1.TextSize=9
    SBUI.lv1.Font=Enum.Font.GothamBold
    SBUI.lv1.BorderSizePixel=0
    SBUI.lv1.ZIndex = 3
    guiCorner(SBUI.lv1,4)
    SBUI.lv1.MouseButton1Click:Connect(function()
        SBC.LaggerVersion="V1"
        updateUI()
        restartLagger()
        scheduleAutoSave()
    end)
    SBUI.lv2=Instance.new("TextButton",lvRow)
    SBUI.lv2.Size=UDim2.new(0.2,0,0.7,0)
    SBUI.lv2.Position=UDim2.new(0.77,0,0.15,0)
    SBUI.lv2.BackgroundColor3=C.blueDark
    SBUI.lv2.BackgroundTransparency=0.5
    SBUI.lv2.Text="V2"
    SBUI.lv2.TextColor3=C.white
    SBUI.lv2.TextSize=9
    SBUI.lv2.Font=Enum.Font.GothamBold
    SBUI.lv2.BorderSizePixel=0
    SBUI.lv2.ZIndex = 3
    guiCorner(SBUI.lv2,4)
    SBUI.lv2.MouseButton1Click:Connect(function()
        SBC.LaggerVersion="V2"
        updateUI()
        restartLagger()
        scheduleAutoSave()
    end)
    local lkRow=bRow(24)
    local lkLbl=Instance.new("TextLabel",lkRow)
    lkLbl.Size=UDim2.new(0.55,0,1,0)
    lkLbl.Position=UDim2.new(0,8,0,0)
    lkLbl.BackgroundTransparency=1
    lkLbl.Text="Lagger Key"
    lkLbl.TextColor3=C.text
    lkLbl.TextSize=10
    lkLbl.Font=Enum.Font.Gotham
    lkLbl.TextXAlignment=Enum.TextXAlignment.Left
    lkLbl.ZIndex = 3
    local lkBtn=Instance.new("TextButton",lkRow)
    lkBtn.Size=UDim2.new(0.3,0,0.7,0)
    lkBtn.Position=UDim2.new(0.62,0,0.15,0)
    lkBtn.BackgroundColor3=C.blue
    lkBtn.BackgroundTransparency=0.7
    lkBtn.BorderSizePixel=0
    lkBtn.Text=SBC.LaggerKeybind
    lkBtn.TextColor3=C.white
    lkBtn.TextSize=9
    lkBtn.Font=Enum.Font.GothamBold
    lkBtn.ZIndex = 3
    guiCorner(lkBtn,4)
    guiStroke(lkBtn,Color3.fromRGB(255,255,255),1)
    lkBtn.MouseButton1Click:Connect(function()
        startKeyListen(lkBtn,function(nk)
            SBC.LaggerKeybind=nk.Name
            lkBtn.Text=prettyKeyName(nk)
            updateUI()
            scheduleAutoSave()
        end)
    end)

    updateUI()

    local bypassKeyConn
    bypassKeyConn=UIS.InputBegan:Connect(function(input,gp)
        if gp or KeyListen.active then return end
        if input.KeyCode.Name==SBC.LaggerKeybind then toggleLaggerBypass() end
    end)
    bg.AncestryChanged:Connect(function()
        if not bg.Parent then
            stopLagger()
            bypassKeyConn:Disconnect()
        end
    end)
end

-- FORCE SCROLL
task.spawn(function()
    task.wait(0.5)
    if GuiRefs.contentFrame then
        GuiRefs.contentFrame.ScrollingEnabled = true
        GuiRefs.contentFrame.ScrollBarThickness = 6
        local layout = GuiRefs.contentFrame:FindFirstChildWhichIsA("UIListLayout")
        if layout then
            layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                GuiRefs.contentFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
            end)
            task.wait(0.1)
            GuiRefs.contentFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
        end
    end
end)

-- FLOATING BUTTONS
task.spawn(function()
    repeat task.wait() until State~=nil
    local function createFloatingButton(name,initialState,isToggle,toggleFunc,actionFunc,posY)
        local sg=Instance.new("ScreenGui")
        sg.Name="FloatingBtn_"..name
        sg.ResetOnSpawn=false
        sg.Enabled=State.floatingBtnsVisible
        sg.Parent=PlayerGui
        table.insert(FloatingBtnGuis,sg)
        local btn=Instance.new("TextButton",sg)
        btn.Size=UDim2.new(0,110,0,32)
        btn.Position=UDim2.new(0.85,-55,posY,0)
        btn.BackgroundColor3=C.darkBg
        btn.BackgroundTransparency=0.15
        btn.TextColor3=C.text
        btn.Font=Enum.Font.GothamBold
        btn.TextSize=11
        btn.BorderSizePixel=0
        btn.AutoButtonColor=false
        if isToggle then
            btn.Text=name..": "..(initialState and "ON" or "OFF")
            btn.BackgroundColor3=initialState and C.blue or C.darkBg
            btn.BackgroundTransparency=initialState and 0.3 or 0.15
        else
            btn.Text=name
        end
        guiCorner(btn,10)
        guiStroke(btn,C.blue,1)
        makeDraggable(btn)
        btn.MouseButton1Click:Connect(function()
            pcall(function()
                if isToggle then
                    local newState=toggleFunc()
                    if type(newState)=="boolean" then
                        btn.Text=name..": "..(newState and "ON" or "OFF")
                        btn.BackgroundColor3=newState and C.blue or C.darkBg
                        btn.BackgroundTransparency=newState and 0.3 or 0.15
                    end
                else
                    actionFunc()
                    btn.BackgroundColor3=C.blue
                    btn.BackgroundTransparency=0.2
                    task.delay(0.15,function()
                        btn.BackgroundColor3=C.darkBg
                        btn.BackgroundTransparency=0.15
                    end)
                end
            end)
        end)
        return btn
    end
    local function toggleCarry()
        State.speedToggled=not State.speedToggled
        scheduleAutoSave()
        updateFloatingButtons()
        if GuiToggleSetters["speed"] then GuiToggleSetters["speed"](State.speedToggled) end
        return State.speedToggled
    end
    local function toggleLaggerFloat()
        toggleLaggerMode()
        return State.laggerModeEnabled
    end
    local function toggleAutoBatFloat()
        setCircleState(not State.circleEnabled)
        updateFloatingButtons()
        return State.circleEnabled
    end
    local spacing=0.07
    local startY=0.15
    FloatingBtnsRefs.carry=createFloatingButton("Carry",State.speedToggled,true,toggleCarry,nil,startY)
    FloatingBtnsRefs.lagger=createFloatingButton("Lagger",State.laggerModeEnabled,true,toggleLaggerFloat,nil,startY+spacing)
    FloatingBtnsRefs.autoBat=createFloatingButton("Auto Bat",State.circleEnabled,true,toggleAutoBatFloat,nil,startY+2*spacing)
    createFloatingButton("TP Down",false,false,nil,function() tpDown() end,startY+3*spacing)
    createFloatingButton("Drop Brain",false,false,nil,function() runDropBrainrot() end,startY+4*spacing)
    updateFloatingButtons()
end)

-- GLOBAL KEYBINDS
UIS.InputBegan:Connect(function(inp, gp)
    if gp or KeyListen.active then return end

    local keyCode = inp.KeyCode

    if keyCode == Keys.guiHide then
        GuiRefs.outer.Visible = not GuiRefs.outer.Visible
    elseif keyCode == Keys.speed then
        State.speedToggled = not State.speedToggled
        scheduleAutoSave()
        updateFloatingButtons()
        if GuiToggleSetters["speed"] then GuiToggleSetters["speed"](State.speedToggled) end
    elseif keyCode == Keys.circle then
        toggleCircleCombat()
    elseif keyCode == Keys.dropBrainrot then
        runDropBrainrot()
    elseif keyCode == Keys.tpDown then
        tpDown()
    elseif keyCode == Keys.laggerToggle then
        toggleLaggerMode()
    elseif keyCode == Keys.instaReset then
        task.spawn(doInstaReset)
    elseif keyCode == Keys.doubleJumpTp then
        toggleDoubleJumpTp()
    end
end)

-- SPEED LOOP
do
    local MOVE_KEYS={[Enum.KeyCode.W]=true,[Enum.KeyCode.A]=true,[Enum.KeyCode.S]=true,[Enum.KeyCode.D]=true,[Enum.KeyCode.Up]=true,[Enum.KeyCode.Left]=true,[Enum.KeyCode.Down]=true,[Enum.KeyCode.Right]=true}
    RunService.RenderStepped:Connect(function()
        local h,hrp,lbl=CharRefs.humanoid,CharRefs.hrp,CharRefs.speedLabel
        if not (h and hrp) then return end
        if State.tpInProgress or State.circleEnabled then return end
        local md=h.MoveDirection
        local spd=getCurrentSpeed()
        if md.Magnitude>0 then
            State.lastMoveDir=md
            hrp.Velocity=Vector3.new(md.X*spd,hrp.Velocity.Y,md.Z*spd)
        elseif State.antiRagdollEnabled and State.lastMoveDir.Magnitude>0 then
            local anyHeld=false
            for key in pairs(MOVE_KEYS) do
                if UIS:IsKeyDown(key) then anyHeld=true; break end
            end
            if anyHeld then
                hrp.Velocity=Vector3.new(State.lastMoveDir.X*spd,hrp.Velocity.Y,State.lastMoveDir.Z*spd)
            end
        end
        if lbl then lbl.Text="Speed: "..string.format("%.1f",Vector3.new(hrp.Velocity.X,0,hrp.Velocity.Z).Magnitude) end
    end)
end

-- NO COLLIDE
do
    local trackedPlayers={}
    local function disableCanCollide(part)
        if part:IsA("BasePart") and part.CanCollide then part.CanCollide=false end
    end
    local function trackCharacter(character)
        for _,part in pairs(character:GetChildren()) do disableCanCollide(part) end
        character.ChildAdded:Connect(function(child) disableCanCollide(child) end)
    end
    local function trackPlayer(player)
        if player==LP then return end
        if player.Character then trackCharacter(player.Character) end
        player.CharacterAdded:Connect(trackCharacter)
        trackedPlayers[player]=true
    end
    for _,player in pairs(Players:GetPlayers()) do trackPlayer(player) end
    Players.PlayerAdded:Connect(trackPlayer)
    RunService.RenderStepped:Connect(function()
        for player,_ in pairs(trackedPlayers) do
            local character=player.Character
            if character then
                for _,part in pairs(character:GetChildren()) do disableCanCollide(part) end
            end
        end
    end)
end

-- APPLY FOV
local function applyFOV(v)
    pcall(function() workspace.CurrentCamera.FieldOfView = v end)
end
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    applyFOV(State.fov)
end)

task.wait(0.1)
task.wait(0.5)

if GuiRefs and GuiRefs.backgroundImage then
    if State.backgroundIndex == 0 then
        GuiRefs.backgroundImage.Visible = false
        if GuiRefs.bgGrad then GuiRefs.bgGrad.Visible = true end
    elseif State.backgroundIndex >= 1 and State.backgroundIndex <= 5 then
        local imgId = BG_IMAGES[State.backgroundIndex]
        if imgId then
            GuiRefs.backgroundImage.Image = "rbxassetid://" .. imgId
            GuiRefs.backgroundImage.Visible = true
            if GuiRefs.bgGrad then GuiRefs.bgGrad.Visible = false end
        end
    end
end

-- Apply saved sky mode
applySkyMode(State.skyMode)

createSpeedBypassGUI()
applyFOV(State.fov)
setStretchRes(State.stretchResEnabled)

if CONFIG.AUTO_STEAL_ENABLED then startAutoSteal() end
if State.infJumpEnabled then setInfJumpInternal(true) end
if State.antiRagdollEnabled then startAntiRagdoll() end
if State.fpsBoostEnabled then applyFPSBoost() end
if State.medusaCounterEnabled then setupMedusaCounter(LP.Character) end
if State.animEnabled then startAnimToggle() end
if State.zombieModeEnabled then setZombieMode(true) end
setCircleState(State.circleEnabled)

if State.doubleJumpTpEnabled then
    startDoubleJumpTpLoop()
end

print("========================================")
print("Raven Hub - Chill Theme Loaded!")
print("Custom Sky Effects (Balanced & Chill):")
print("  0: Off (Default)")
print("  1: Cyber (Neon Cyberpunk - Subtle)")
print("  2: Sakura (Soft Pink)")
print("  3: Dark Mode (Dark & Moody - Balanced)")
print("  4: Galaxy (Cosmic Purple - Softened)")
print("  5: Red Theme (Aggressive Red - Tamed)")
print("  6: Sky Ground (Clouds Below)")
print("========================================")
print("FPS Boost - Fixed & Working!")
print("   - Removes FPS cap")
print("   - Disables visual effects")
print("   - Reduces graphics quality")
print("   - Disables particles & shadows")
print("========================================")