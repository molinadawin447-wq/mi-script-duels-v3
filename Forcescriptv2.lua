-- ============================================================
-- AXONIC HUB v2.0 - COMPLETE FULL SCRIPT (MODIFIED)
-- ADDED: Controller button support in Keybinds tab
-- ADDED: Auto Exit Duel now says "GGS" when leaving
-- ADDED: Controller buttons show in Keybinds tab
-- ============================================================

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local HS = game:GetService("HttpService")
local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")
local CoreGui = game:GetService("CoreGui")
local camera = workspace.CurrentCamera
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local TextChatService = game:GetService("TextChatService")
local ContextActionService = game:GetService("ContextActionService")

local LOGO_ID = "rbxassetid://139885277738859"
local SOUL_LOGO_ASSET_ID = "rbxassetid://115490552666225"

-- STATE
local State = {
    normalSpeed=60, carrySpeed=30, laggerSpeed=10.1,
    speedToggled=false, laggerEnabled=false,
    infJumpEnabled=false, holdInfJumpEnabled=false,
    antiRagdollEnabled=false, fpsBoostEnabled=false,
    guiVisible=true, uiLocked=false,
    isStealing=false, stealStartTime=nil, lastStealTick=0,
    autoLeftEnabled=false, autoRightEnabled=false,
    autoLeftPhase=1, autoRightPhase=1,
    medusaLastUsed=0, medusaDebounce=false, medusaCounterEnabled=false,
    -- New Bat Aimbot state
    batAimbotToggled=false, autoSwingEnabled=true, batAimbotSpeed=58,
    hittingCooldown=false,
    batCounterEnabled=false, batCounterDebounce=false,
    dropEnabled=false, _tpInProgress=false,
    lastMoveDir=Vector3.new(0,0,0),
    unwalkEnabled=false, stackButtonsHidden=false,
    _prevCarry=30, _prevSpeed=false,
    autoTPDownEnabled=false,
    autoTPDownY=-20,
    instantResetOnMedusa=true,
    _medusaResetCooldown=false,
    _lastResetTime=0,
    -- Visual Settings
    fovOn=false, galaxyOn=false, antiBatOn=false,
    -- Simple FOV
    simpleFovEnabled=false,
    simpleFovValue=70,
    currentSkyTheme="Off",
    -- Keybinds (Keyboard)
    keybinds = {
        drop = Enum.KeyCode.Unknown,
        batAimbot = Enum.KeyCode.Unknown,
        laggerMode = Enum.KeyCode.Unknown,
        carrySpeed = Enum.KeyCode.Unknown,
        normalSpeed = Enum.KeyCode.Unknown,
        tpDown = Enum.KeyCode.Unknown,
        autoLeft = Enum.KeyCode.Unknown,
        autoRight = Enum.KeyCode.Unknown,
        instantReset = Enum.KeyCode.T, -- Default T key
    },
    -- Controller keybinds
    controllerKeybinds = {
        drop = Enum.KeyCode.Unknown,
        batAimbot = Enum.KeyCode.Unknown,
        laggerMode = Enum.KeyCode.Unknown,
        carrySpeed = Enum.KeyCode.Unknown,
        normalSpeed = Enum.KeyCode.Unknown,
        tpDown = Enum.KeyCode.Unknown,
        autoLeft = Enum.KeyCode.Unknown,
        autoRight = Enum.KeyCode.Unknown,
        instantReset = Enum.KeyCode.Unknown,
    },
    -- Speed Bypass
    speedBypassEnabled = false,
    speedBypassPower = 97000,
    -- Anti Bat Bypass
    antiBatBypassEnabled = false,
    batThreshold = 75,
    capSpeed = 63,
    -- Intro Music System
    introEnabled = true,
    selectedMusic = 1,
    cachedSongs = {},
    isDownloading = false,
    -- Ragdoll Timer
    ragdollTimerEnabled = true,
    -- Auto Exit Duel
    autoExitDuelEnabled = false,
    -- Controller state
    _listeningForController = false,
}

-- Music URLs (9 songs)
local musicURLs = {
    "https://files.catbox.moe/zuid5n.mp3",
    "https://files.catbox.moe/z6eqnt.mp3",
    "https://files.catbox.moe/t0nlhv.mp3",
    "https://files.catbox.moe/mthg31.mp3",
    "https://files.catbox.moe/ddnbup.mp3",
    "https://files.catbox.moe/hg5cr4.mp3",
    "https://files.catbox.moe/nps6gk.mp3",
    "https://files.catbox.moe/iyw1cb.mp3",
    "https://files.catbox.moe/2w0wtv.mp3",
}

-- Intro state
local introSound = nil
local previewSound = nil
local introGuiRef = nil

-- Candy Bat Aimbot specific state
local _aimbotTarget = nil
local _aimbotTargetPlr = nil

-- V1 Anti-Ragdoll State
local antiRagdollMode = nil
local ragdollConnections = {}
local cachedCharData = {}
local isBoosting = false
local BOOST_SPEED = 400
local DEFAULT_SPEED = 16

-- Ragdoll Timer State
local hitCountdownEnabled = true
local hitCountdownActive = false
local hitCountdownToken = 0
local hitCountdownLabel = nil
local numberSizeMultiplier = 0.5
local ragdollTimerGui = nil

-- Auto Exit Duel State
local autoExitConnections = {}
local autoExitDuelEnabled = false
local autoExitLeaving = false

local POS = {
    L1=Vector3.new(-476.48,-6.28,92.73), L2=Vector3.new(-483.12,-4.95,94.80),
    R1=Vector3.new(-476.16,-6.52,25.62), R2=Vector3.new(-483.04,-5.09,23.14),
}

local Steal = {
    AutoStealEnabled=false, StealRadius=60, StealDuration=1.3,
    Data={}, plotCache={}, plotCacheTime={}, cachedPrompts={}, promptCacheTime=0,
}

local PLOT_CACHE_DURATION=2; local PROMPT_CACHE_REFRESH=0.15
local STEAL_COOLDOWN=0.1; local MEDUSA_COOLDOWN=25; local DROP_AUTO_OFF_DELAY=0.15
local MOVE_KEYS = {[Enum.KeyCode.W]=true,[Enum.KeyCode.A]=true,[Enum.KeyCode.S]=true,[Enum.KeyCode.D]=true,
    [Enum.KeyCode.Up]=true,[Enum.KeyCode.Left]=true,[Enum.KeyCode.Down]=true,[Enum.KeyCode.Right]=true}

local Conns = {autoSteal=nil,antiRag=nil,autoLeft=nil,autoRight=nil,aimbot=nil,anchor={},progress=nil,batCounter=nil,unwalk=nil,autoTPDown=nil,holdInfJump=nil,speedBypass=nil,antiBatBypass=nil,ragdollTimer=nil,autoExit=nil,controller=nil}

local h,hrp
local stackBtnRefs={}; local stackWrappers={}; 
local normalBox,carryBox,laggerBox,stealRadBox
local progressFill,fillGlow,stealPctLbl,radLbl
local setHideButtonsToggle, setAutoTPDownToggle

local tracerLines = {}

local cursedResetRemote = nil
local CURSED_RESET_GUID = "f888ee6e-c86d-46e1-93d7-0639d6635d42"
local resetCooldown = false

-- Visual State
local defBrightness, defClock, defAmbient = Lighting.Brightness, Lighting.ClockTime, Lighting.OutdoorAmbient
local candyOriginalLighting = nil
local CANDY_SKY_TAG = "AxonicSkyTheme"
local simpleFovConn = nil
local _defFov = 70

-- COLORS
local C = {
    winBg = Color3.fromRGB(8,8,8), winBorder = Color3.fromRGB(220,220,220),
    topTitle = Color3.fromRGB(255,255,255), topDivider = Color3.fromRGB(50,50,50),
    tabIdle = Color3.fromRGB(18,18,18), tabIdleTxt = Color3.fromRGB(120,120,120),
    tabActiveBg = Color3.fromRGB(45,45,45), tabActTxt = Color3.fromRGB(255,255,255),
    sectionTxt = Color3.fromRGB(180,180,180), rowBg = Color3.fromRGB(12,12,12),
    rowBorder = Color3.fromRGB(45,45,45), rowLabel = Color3.fromRGB(240,240,240),
    rowSub = Color3.fromRGB(120,120,120), cardBg = Color3.fromRGB(12,12,12),
    cardHov = Color3.fromRGB(22,22,22), accent = Color3.fromRGB(200,200,200),
    inputBg = Color3.fromRGB(8,8,8), inputBorder = Color3.fromRGB(60,60,60),
    inputFocus = Color3.fromRGB(200,200,200), inputTxt = Color3.fromRGB(255,255,255),
    pillOff = Color3.fromRGB(35,35,35), pillOn = Color3.fromRGB(190,190,190),
    dotOff = Color3.fromRGB(70,70,70), dotOn = Color3.fromRGB(255,255,255),
    pillBorder = Color3.fromRGB(90,90,90), chipBg = Color3.fromRGB(18,18,18),
    chipBorder = Color3.fromRGB(70,70,70), mobOff = Color3.fromRGB(18,18,18),
    mobOn = Color3.fromRGB(210,210,210), mobText = Color3.fromRGB(220,220,220),
    mobTextOn = Color3.fromRGB(0,0,0), mobStroke = Color3.fromRGB(55,55,55),
    mobStrokeOn = Color3.fromRGB(255,255,255), sbTrack = Color3.fromRGB(28,28,28),
    sbFill = Color3.fromRGB(200,200,200), sbGlow = Color3.fromRGB(255,255,255),
    controllerBg = Color3.fromRGB(20,25,35),
    controllerBorder = Color3.fromRGB(60,70,90),
    controllerBtnBg = Color3.fromRGB(40,45,60),
    controllerBtnText = Color3.fromRGB(200,210,230),
}

-- HELPERS
local function mkCorner(p,r) local c=Instance.new("UICorner",p); c.CornerRadius=UDim.new(0,r or 6); return c end
local function mkStroke(p,col,th) local s=Instance.new("UIStroke",p); s.Color=col; s.Thickness=th or 1; s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; return s end

local function makeDraggable(frame,handle)
    local src=handle or frame
    local dragging,dragInput,dragStart,startPos=false,nil,nil,nil
    src.InputBegan:Connect(function(inp)
        if State.uiLocked then return end
        if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
            dragging=true; dragStart=inp.Position; startPos=frame.Position
            inp.Changed:Connect(function() if inp.UserInputState==Enum.UserInputState.End then dragging=false end end)
        end
    end)
    src.InputChanged:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseMovement or inp.UserInputType==Enum.UserInputType.Touch then dragInput=inp end end)
    UIS.InputChanged:Connect(function(inp) if inp==dragInput and dragging and not State.uiLocked then local dx=inp.Position.X-dragStart.X; local dy=inp.Position.Y-dragStart.Y; frame.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+dx,startPos.Y.Scale,startPos.Y.Offset+dy) end end)
end

-- CLEANUP
for _,name in pairs({"MoonDuels","MoonDuelsStealBar","ExodoDuelsV1","ExodoDuelsV2","DriftAntiBat","AutoTPDownGUI","InstantResetButton","CrazedDuelsTracers","NgasDualHelper_V2","SimpleMobileGUI","AxonicBypassPanel","CandyBatAimbot","IrishHubDuels","UGC_Duels","UGC_SpeedCustomizer","LXHubBypassGUI","EnvyHubGUI","EnvyHubIntro","AxonicIntro","RagdollTimerGUI","IrishHub_Save","AutoExitDuel"}) do
    pcall(function() local o=PG:FindFirstChild(name); if o then o:Destroy() end end)
    pcall(function() local o=CoreGui:FindFirstChild(name); if o then o:Destroy() end end)
end

-- ============================================================
-- CONTROLLER BUTTON NAME MAP
-- ============================================================
local function getControllerButtonName(keyCode)
    local names = {
        [Enum.KeyCode.ButtonA] = "A",
        [Enum.KeyCode.ButtonB] = "B",
        [Enum.KeyCode.ButtonX] = "X",
        [Enum.KeyCode.ButtonY] = "Y",
        [Enum.KeyCode.ButtonL1] = "LB",
        [Enum.KeyCode.ButtonR1] = "RB",
        [Enum.KeyCode.ButtonL2] = "LT",
        [Enum.KeyCode.ButtonR2] = "RT",
        [Enum.KeyCode.ButtonL3] = "LS",
        [Enum.KeyCode.ButtonR3] = "RS",
        [Enum.KeyCode.DPadUp] = "DPADâ†‘",
        [Enum.KeyCode.DPadDown] = "DPADâ†“",
        [Enum.KeyCode.DPadLeft] = "DPADâ†",
        [Enum.KeyCode.DPadRight] = "DPADâ†’",
        [Enum.KeyCode.ButtonStart] = "START",
        [Enum.KeyCode.ButtonSelect] = "SELECT",
        [Enum.KeyCode.ButtonL4] = "L4",
        [Enum.KeyCode.ButtonR4] = "R4",
        [Enum.KeyCode.ButtonL5] = "L5",
        [Enum.KeyCode.ButtonR5] = "R5",
        [Enum.KeyCode.ButtonL6] = "L6",
        [Enum.KeyCode.ButtonR6] = "R6",
    }
    return names[keyCode] or keyCode.Name or "Unknown"
end

local function isControllerButton(keyCode)
    local controllerTypes = {
        Enum.KeyCode.ButtonA, Enum.KeyCode.ButtonB, Enum.KeyCode.ButtonX, Enum.KeyCode.ButtonY,
        Enum.KeyCode.ButtonL1, Enum.KeyCode.ButtonR1, Enum.KeyCode.ButtonL2, Enum.KeyCode.ButtonR2,
        Enum.KeyCode.ButtonL3, Enum.KeyCode.ButtonR3, Enum.KeyCode.DPadUp, Enum.KeyCode.DPadDown,
        Enum.KeyCode.DPadLeft, Enum.KeyCode.DPadRight, Enum.KeyCode.ButtonStart, Enum.KeyCode.ButtonSelect,
        Enum.KeyCode.ButtonL4, Enum.KeyCode.ButtonR4, Enum.KeyCode.ButtonL5, Enum.KeyCode.ButtonR5,
        Enum.KeyCode.ButtonL6, Enum.KeyCode.ButtonR6
    }
    for _, ct in ipairs(controllerTypes) do
        if keyCode == ct then return true end
    end
    return false
end

-- ============================================================
-- AUTO EXIT DUEL SYSTEM (WITH GGS)
-- ============================================================
local function sendGG()
    pcall(function()
        -- Try multiple methods to send GGS
        local success = false
        
        -- Method 1: ChatInputBar
        local chat = TextChatService:FindFirstChild("ChatInputBar")
        if chat then
            local textBox = chat:FindFirstChild("TextChannelButton")
            if textBox then
                pcall(function()
                    textBox.Text = "GGS"
                    textBox:Fire()
                    success = true
                end)
            end
        end
        
        -- Method 2: SayMessageRequest
        if not success then
            pcall(function()
                local args = {[1] = "GGS", [2] = "All"}
                local remote = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
                if remote then
                    local sayMsg = remote:FindFirstChild("SayMessageRequest")
                    if sayMsg then
                        sayMsg:FireServer(unpack(args))
                        success = true
                    end
                end
            end)
        end
        
        -- Method 3: TextChatService
        if not success then
            pcall(function()
                local channel = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
                if channel then
                    channel:SendAsync("GGS")
                    success = true
                end
            end)
        end
        
        -- Method 4: Direct chat via Player
        if not success then
            pcall(function()
                LP.Chatted:Fire("GGS")
            end)
        end
    end)
end

local function watchAutoExitDuel(sound)
    if sound:IsA("Sound") and sound.Name == "GameWin" then
        local conn = sound:GetPropertyChangedSignal("Playing"):Connect(function()
            if sound.Playing and not autoExitLeaving then
                autoExitLeaving = true
                task.wait(0.5)
                sendGG()
                task.wait(0.5)
                pcall(function() LP:Kick("GGS!") end)
                task.wait(2)
                autoExitLeaving = false
            end
        end)
        table.insert(autoExitConnections, conn)
    end
end

local function enableAutoExitDuel()
    if autoExitDuelEnabled then return end
    autoExitDuelEnabled = true
    State.autoExitDuelEnabled = true
    
    for _, v in ipairs(game:GetDescendants()) do 
        watchAutoExitDuel(v) 
    end
    
    local addedConn = game.DescendantAdded:Connect(watchAutoExitDuel)
    table.insert(autoExitConnections, addedConn)
end

local function disableAutoExitDuel()
    if not autoExitDuelEnabled then return end
    autoExitDuelEnabled = false
    State.autoExitDuelEnabled = false
    autoExitLeaving = false
    
    for _, conn in ipairs(autoExitConnections) do 
        pcall(function() conn:Disconnect() end) 
    end
    autoExitConnections = {}
end

local function toggleAutoExitDuel()
    if autoExitDuelEnabled then
        disableAutoExitDuel()
    else
        enableAutoExitDuel()
    end
end

-- ============================================================
-- RAGDOLL TIMER SYSTEM
-- ============================================================
local function setupRagdollBillboard(char)
    if not char then return end

    local head = char:FindFirstChild("Head") or char:WaitForChild("Head",5)
    if not head then return end

    local old = head:FindFirstChild("HitCountdownBB")
    if old then old:Destroy() end

    local bb = Instance.new("BillboardGui")
    bb.Name = "HitCountdownBB"
    bb.Size = UDim2.new(0,180 * numberSizeMultiplier,0,60 * numberSizeMultiplier)
    bb.StudsOffset = Vector3.new(0,5,0)
    bb.AlwaysOnTop = true
    bb.Parent = head

    local lbl = Instance.new("TextLabel")
    lbl.Name = "Countdown"
    lbl.Size = UDim2.new(1,0,1,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = ""
    lbl.Visible = false
    lbl.TextScaled = true
    lbl.Font = Enum.Font.GothamBold
    lbl.TextColor3 = Color3.fromRGB(255,0,0)
    lbl.TextStrokeTransparency = 0
    lbl.TextStrokeColor3 = Color3.fromRGB(0,0,0)
    lbl.Parent = bb

    hitCountdownLabel = lbl
end

local function startRagdollCountdown()
    if hitCountdownActive then return end

    if not hitCountdownLabel or not hitCountdownLabel.Parent then
        setupRagdollBillboard(LP.Character)
    end

    if not hitCountdownLabel then return end

    hitCountdownActive = true
    hitCountdownToken = hitCountdownToken + 1

    local token = hitCountdownToken
    local lbl = hitCountdownLabel

    task.spawn(function()
        lbl.Visible = true

        for i = 3,1,-1 do
            if token ~= hitCountdownToken then return end
            lbl.Text = tostring(i)
            task.wait(1)
        end

        if token ~= hitCountdownToken then return end

        lbl.Text = "GO!"

        repeat
            task.wait(0.1)
            local char = LP.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if not hum then break end
            local state = hum:GetState()
            if state ~= Enum.HumanoidStateType.Physics
            and state ~= Enum.HumanoidStateType.Ragdoll
            and state ~= Enum.HumanoidStateType.FallingDown then
                break
            end
        until false

        if token ~= hitCountdownToken then return end

        task.wait(0.25)

        lbl.Visible = false
        lbl.Text = ""
        hitCountdownActive = false
    end)
end

local function startRagdollTimer()
    if Conns.ragdollTimer then return end
    
    if LP.Character then
        setupRagdollBillboard(LP.Character)
    end

    LP.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        setupRagdollBillboard(char)
    end)

    Conns.ragdollTimer = RunService.Heartbeat:Connect(function()
        if not State.ragdollTimerEnabled then return end

        local char = LP.Character
        if not char then return end

        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end

        local state = hum:GetState()

        if state == Enum.HumanoidStateType.Physics
        or state == Enum.HumanoidStateType.Ragdoll
        or state == Enum.HumanoidStateType.FallingDown then
            startRagdollCountdown()
        end
    end)
end

local function stopRagdollTimer()
    if Conns.ragdollTimer then
        Conns.ragdollTimer:Disconnect()
        Conns.ragdollTimer = nil
    end
    hitCountdownActive = false
    if hitCountdownLabel then
        hitCountdownLabel.Visible = false
        hitCountdownLabel.Text = ""
    end
end

-- ============================================================
-- V1 ANTI-RAGDOLL SYSTEM
-- ============================================================
local function cacheCharacterData()
    local char = LP.Character
    if not char then return false end
    
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    
    if not hum or not root then return false end
    
    cachedCharData = {
        character = char,
        humanoid = hum,
        root = root
    }
    return true
end

local function disconnectAll()
    for _, conn in ipairs(ragdollConnections) do
        pcall(function() conn:Disconnect() end)
    end
    ragdollConnections = {}
end

local function isRagdolled()
    if not cachedCharData.humanoid then return false end
    local state = cachedCharData.humanoid:GetState()
    
    local ragdollStates = {
        [Enum.HumanoidStateType.Physics] = true,
        [Enum.HumanoidStateType.Ragdoll] = true,
        [Enum.HumanoidStateType.FallingDown] = true
    }
    
    if ragdollStates[state] then return true end
    
    local endTime = LP:GetAttribute("RagdollEndTime")
    if endTime and (endTime - workspace:GetServerTimeNow()) > 0 then
        return true
    end
    
    return false
end

local function forceExitRagdoll()
    if not cachedCharData.humanoid or not cachedCharData.root then return end
    
    pcall(function()
        LP:SetAttribute("RagdollEndTime", workspace:GetServerTimeNow())
    end)
    
    -- Clear physics constraints locally
    for _, descendant in ipairs(cachedCharData.character:GetDescendants()) do
        if descendant:IsA("BallSocketConstraint") or (descendant:IsA("Attachment") and descendant.Name:find("RagdollAttachment")) then
            descendant:Destroy()
        end
    end
    
    -- Apply the 400 speed boost
    if not isBoosting then
        isBoosting = true
        cachedCharData.humanoid.WalkSpeed = BOOST_SPEED
    end
    
    -- Force state back to running
    if cachedCharData.humanoid.Health > 0 then
        cachedCharData.humanoid:ChangeState(Enum.HumanoidStateType.Running)
    end
    
    cachedCharData.root.Anchored = false
end

local function v1HeartbeatLoop()
    while State.antiRagdollEnabled do
        task.wait()
        
        local currentlyRagdolled = isRagdolled()
        
        if currentlyRagdolled then
            forceExitRagdoll()
        elseif isBoosting and not currentlyRagdolled then
            -- Reset to default speed once the stun/ragdoll ends
            isBoosting = false
            if cachedCharData.humanoid then
                cachedCharData.humanoid.WalkSpeed = DEFAULT_SPEED
            end
        end
    end
end

local function EnableAntiRagdoll()
    if not State.antiRagdollEnabled then return end
    if antiRagdollMode == "v1" then return end
    if not cacheCharacterData() then return end
    
    antiRagdollMode = "v1"
    
    local camConn = RunService.RenderStepped:Connect(function()
        local cam = workspace.CurrentCamera
        if cam and cachedCharData.humanoid then
            cam.CameraSubject = cachedCharData.humanoid
        end
    end)
    table.insert(ragdollConnections, camConn)
    
    local respawnConn = LP.CharacterAdded:Connect(function()
        isBoosting = false 
        task.wait(0.5)
        cacheCharacterData()
    end)
    table.insert(ragdollConnections, respawnConn)

    task.spawn(v1HeartbeatLoop)
end

local function DisableAntiRagdoll()
    antiRagdollMode = nil
    if isBoosting and cachedCharData.humanoid then
        cachedCharData.humanoid.WalkSpeed = DEFAULT_SPEED
    end
    isBoosting = false
    disconnectAll()
    cachedCharData = {}
end

-- ============================================================
-- MUSIC SYSTEM
-- ============================================================
local function downloadSong(index)
    return pcall(function()
        local url = musicURLs[index]
        if not url then return false end
        
        -- Check if already cached
        local cacheName = "AxonicSong_" .. index .. ".mp3"
        if isfile and isfile(cacheName) then
            State.cachedSongs[index] = getcustomasset(cacheName)
            return true
        end
        
        -- Download the song
        if not writefile then return false end
        
        local songData = game:HttpGet(url)
        writefile(cacheName, songData)
        State.cachedSongs[index] = getcustomasset(cacheName)
        return true
    end)
end

local function playSong(soundParent, index, volume)
    volume = volume or 1
    local success, asset = pcall(function()
        if not State.cachedSongs[index] then
            downloadSong(index)
        end
        return State.cachedSongs[index]
    end)
    
    if success and asset then
        local sound = Instance.new("Sound")
        sound.SoundId = asset
        sound.Volume = volume
        sound.PlaybackSpeed = 1
        sound.Parent = soundParent
        sound:Play()
        return sound
    end
    return nil
end

function playPreview(idx)
    pcall(function()
        -- Stop any existing preview
        if previewSound then
            previewSound:Stop()
            previewSound:Destroy()
            previewSound = nil
        end
        
        local sound = playSong(CoreGui, idx, 0.3)
        if sound then
            previewSound = sound
            task.delay(4, function()
                if previewSound then
                    previewSound:Stop()
                    previewSound:Destroy()
                    previewSound = nil
                end
            end)
        end
    end)
end

-- ============================================================
-- INTRO ANIMATION (AXONIC HUB)
-- ============================================================
function playIntroAnimation()
    if not State.introEnabled then return end
    
    -- Make sure song is downloaded
    if not State.cachedSongs[State.selectedMusic] then
        local success = downloadSong(State.selectedMusic)
        if not success then
            print("Failed to download song!")
            return
        end
    end
    
    local introGui = Instance.new("ScreenGui")
    introGui.Name = "AxonicIntro"
    introGui.ResetOnSpawn = false
    introGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    introGui.DisplayOrder = 999
    introGui.IgnoreGuiInset = true
    introGui.Parent = CoreGui
    introGuiRef = introGui

    local introFrame = Instance.new("Frame")
    introFrame.Size = UDim2.new(1, 0, 1, 0)
    introFrame.BackgroundColor3 = Color3.fromRGB(5, 8, 18)
    introFrame.BackgroundTransparency = 0.35
    introFrame.BorderSizePixel = 0
    introFrame.Parent = introGui

    local logoImage = Instance.new("ImageLabel")
    logoImage.Size = UDim2.new(0, 300, 0, 300)
    logoImage.Position = UDim2.new(0.5, 0, 0.5, 0)
    logoImage.AnchorPoint = Vector2.new(0.5, 0.5)
    logoImage.BackgroundTransparency = 1
    logoImage.Image = SOUL_LOGO_ASSET_ID
    logoImage.ImageTransparency = 0
    logoImage.ScaleType = Enum.ScaleType.Fit
    logoImage.ZIndex = 0
    logoImage.Parent = introFrame

    -- "AXONIC" Label
    local axonicLabel = Instance.new("TextLabel")
    axonicLabel.Size = UDim2.new(0, 500, 0, 120)
    axonicLabel.Position = UDim2.new(0, -450, 0.5, -100)
    axonicLabel.AnchorPoint = Vector2.new(0.5, 0.5)
    axonicLabel.BackgroundTransparency = 1
    axonicLabel.Text = "AXONIC"
    axonicLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
    axonicLabel.TextTransparency = 0
    axonicLabel.TextSize = 100
    axonicLabel.Font = Enum.Font.GothamBold
    axonicLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    axonicLabel.TextStrokeTransparency = 1
    axonicLabel.ZIndex = 2
    axonicLabel.Parent = introFrame

    -- "HUB" Label
    local hubLabel = Instance.new("TextLabel")
    hubLabel.Size = UDim2.new(0, 500, 0, 120)
    hubLabel.Position = UDim2.new(1, 450, 0.5, 100)
    hubLabel.AnchorPoint = Vector2.new(0.5, 0.5)
    hubLabel.BackgroundTransparency = 1
    hubLabel.Text = "HUB"
    hubLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
    hubLabel.TextTransparency = 0
    hubLabel.TextSize = 100
    hubLabel.Font = Enum.Font.GothamBold
    hubLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    hubLabel.TextStrokeTransparency = 1
    hubLabel.ZIndex = 2
    hubLabel.Parent = introFrame

    local introCompleteEvent = Instance.new("BindableEvent")
    
    task.spawn(function()
        -- Play selected song
        local sound = playSong(introGui, State.selectedMusic, 1)
        
        -- Preload logo
        pcall(function()
            game:GetService("ContentProvider"):PreloadAsync({SOUL_LOGO_ASSET_ID})
        end)
        
        task.wait(0.3)
        
        -- Add blur effect
        local camera = workspace.CurrentCamera
        local blur = Instance.new("BlurEffect")
        blur.Size = 56
        blur.Parent = camera

        -- Flickering animation
        local flickering = true
        task.spawn(function()
            while flickering do
                logoImage.ImageTransparency = 1
                axonicLabel.TextTransparency = 1
                axonicLabel.TextStrokeTransparency = 1
                hubLabel.TextTransparency = 1
                hubLabel.TextStrokeTransparency = 1
                task.wait(0.08)
                
                if not flickering then break end
                
                logoImage.ImageTransparency = 0
                axonicLabel.TextTransparency = 0.25
                axonicLabel.TextStrokeTransparency = 0.3
                hubLabel.TextTransparency = 0.25
                hubLabel.TextStrokeTransparency = 0.3
                task.wait(0.08)
            end
        end)

        -- Animate labels
        local tweenInfo = TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local axonicTween = TS:Create(axonicLabel, tweenInfo, {Position = UDim2.new(0.5, 0, 0.5, -100)})
        axonicTween:Play()
        
        task.wait(0.55)
        
        local hubTween = TS:Create(hubLabel, tweenInfo, {Position = UDim2.new(0.5, 0, 0.5, 100)})
        hubTween:Play()
        
        axonicTween.Completed:Wait()
        task.wait(0.5)

        flickering = false
        task.wait(1.2)

        -- Fade out
        local fadeInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad)
        TS:Create(logoImage, fadeInfo, {ImageTransparency = 1}):Play()
        TS:Create(axonicLabel, fadeInfo, {TextTransparency = 1, TextStrokeTransparency = 1}):Play()
        TS:Create(hubLabel, fadeInfo, {TextTransparency = 1, TextStrokeTransparency = 1}):Play()
        TS:Create(introFrame, fadeInfo, {BackgroundTransparency = 1}):Play()
        
        task.wait(0.55)

        pcall(function() blur:Destroy() end)
        if sound then
            pcall(function() sound:Stop() end)
            pcall(function() sound:Destroy() end)
        end
        introGui:Destroy()
        introGuiRef = nil
        introCompleteEvent:Fire()
    end)

    introCompleteEvent.Event:Wait()
    introCompleteEvent:Destroy()
end

-- ============================================================
-- ANTI BAT BYPASS SYSTEM
-- ============================================================
local function startAntiBatBypass()
    if Conns.antiBatBypass then Conns.antiBatBypass:Disconnect() end
    if not State.antiBatBypassEnabled then return end
    
    Conns.antiBatBypass = RunService.Heartbeat:Connect(function()
        if not State.antiBatBypassEnabled then return end
        
        local char = LP.Character
        if not char then return end
        
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        
        local vel = root.AssemblyLinearVelocity
        local hSpd = Vector3.new(vel.X, 0, vel.Z).Magnitude
        
        if hSpd > State.batThreshold then
            local md = hum.MoveDirection
            if md.Magnitude > 0 then
                root.AssemblyLinearVelocity = Vector3.new(md.X * State.capSpeed, vel.Y, md.Z * State.capSpeed)
            else
                root.AssemblyLinearVelocity = Vector3.new(0, vel.Y, 0)
            end
        end
        
        if root.AssemblyAngularVelocity.Magnitude > 0.3 then
            root.AssemblyAngularVelocity = Vector3.zero
        end
        
        local hs = hum:GetState()
        if hs == Enum.HumanoidStateType.Physics
        or hs == Enum.HumanoidStateType.Ragdoll
        or hs == Enum.HumanoidStateType.FallingDown then
            hum:ChangeState(Enum.HumanoidStateType.Running)
            hum.PlatformStand = false
            root.AssemblyAngularVelocity = Vector3.zero
        end
    end)
end

local function stopAntiBatBypass()
    if Conns.antiBatBypass then
        Conns.antiBatBypass:Disconnect()
        Conns.antiBatBypass = nil
    end
end

local function restartAntiBatBypass()
    if State.antiBatBypassEnabled then
        stopAntiBatBypass()
        startAntiBatBypass()
    end
end

-- ============================================================
-- SPEED BYPASS SYSTEM
-- ============================================================
local function getLagAmount()
    local power = State.speedBypassPower
    return ((math.clamp(power, 10000, 500000) - 10000) / 490000) * 0.2
end

local function startSpeedBypass()
    if Conns.speedBypass then Conns.speedBypass:Disconnect() end
    if not State.speedBypassEnabled then return end
    Conns.speedBypass = RunService.RenderStepped:Connect(function()
        local lagAmount = getLagAmount()
        if lagAmount > 0 then
            local t = tick()
            while tick() - t < lagAmount do end
        end
    end)
end

local function stopSpeedBypass()
    if Conns.speedBypass then
        Conns.speedBypass:Disconnect()
        Conns.speedBypass = nil
    end
end

local function restartSpeedBypass()
    if State.speedBypassEnabled then
        stopSpeedBypass()
        startSpeedBypass()
    end
end

-- ========== KEYBIND SYSTEM ==========
local keybindListeners = {}

-- Check if a key is a controller button
local function isControllerKey(keyCode)
    local controllerKeys = {
        Enum.KeyCode.ButtonA, Enum.KeyCode.ButtonB, Enum.KeyCode.ButtonX, Enum.KeyCode.ButtonY,
        Enum.KeyCode.ButtonL1, Enum.KeyCode.ButtonR1, Enum.KeyCode.ButtonL2, Enum.KeyCode.ButtonR2,
        Enum.KeyCode.ButtonL3, Enum.KeyCode.ButtonR3, Enum.KeyCode.DPadUp, Enum.KeyCode.DPadDown,
        Enum.KeyCode.DPadLeft, Enum.KeyCode.DPadRight, Enum.KeyCode.ButtonStart, Enum.KeyCode.ButtonSelect
    }
    for _, k in ipairs(controllerKeys) do
        if keyCode == k then return true end
    end
    return false
end

local function getKeyDisplayName(keyCode)
    if isControllerKey(keyCode) then
        return "ðŸŽ® " .. getControllerButtonName(keyCode)
    else
        return keyCode.Name or "None"
    end
end

local function startKeybindListen()
    -- Clear old listeners
    for _, conn in ipairs(keybindListeners) do
        pcall(function() conn:Disconnect() end)
    end
    keybindListeners = {}
    
    -- Create new listeners for each keybind (both keyboard and controller)
    for action, keyCode in pairs(State.keybinds) do
        if keyCode ~= Enum.KeyCode.Unknown then
            local conn = UIS.InputBegan:Connect(function(input, gp)
                if gp then return end
                if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
                if input.KeyCode ~= keyCode then return end
                
                -- Execute the action
                if action == "drop" then
                    State.dropEnabled = not State.dropEnabled
                    if State.dropEnabled then runDropBrainrot() else stopDropBrainrot() end
                    if stackBtnRefs.drop then stackBtnRefs.drop.setOn(State.dropEnabled) end
                elseif action == "batAimbot" then
                    if not State.batAimbotToggled then
                        if State.autoLeftEnabled then State.autoLeftEnabled=false; stopAutoLeft(); if stackBtnRefs.autoLeft then stackBtnRefs.autoLeft.setOn(false) end end
                        if State.autoRightEnabled then State.autoRightEnabled=false; stopAutoRight(); if stackBtnRefs.autoRight then stackBtnRefs.autoRight.setOn(false) end end
                        pcall(startBatAimbot)
                    else
                        pcall(stopBatAimbot)
                    end
                    if stackBtnRefs.aimbot then stackBtnRefs.aimbot.setOn(State.batAimbotToggled) end
                elseif action == "laggerMode" then
                    State.laggerEnabled = not State.laggerEnabled
                    if stackBtnRefs.lagger then stackBtnRefs.lagger.setOn(State.laggerEnabled) end
                    if State.laggerEnabled then
                        State._prevCarry=State.carrySpeed
                        State._prevSpeed=State.speedToggled
                        State.speedToggled=false
                        if stackBtnRefs.carrySpeed then stackBtnRefs.carrySpeed.setOn(false) end
                        if carryBox then carryBox.Text=tostring(State.laggerSpeed) end
                    else
                        State.carrySpeed=State._prevCarry or 30
                        State.speedToggled=State._prevSpeed or false
                        if carryBox then carryBox.Text=tostring(State.carrySpeed) end
                        if stackBtnRefs.carrySpeed then stackBtnRefs.carrySpeed.setOn(State.speedToggled) end
                    end
                elseif action == "carrySpeed" then
                    State.speedToggled = not State.speedToggled
                    if stackBtnRefs.carrySpeed then stackBtnRefs.carrySpeed.setOn(State.speedToggled) end
                elseif action == "normalSpeed" then
                    State.speedToggled = false
                    if stackBtnRefs.carrySpeed then stackBtnRefs.carrySpeed.setOn(false) end
                elseif action == "tpDown" then
                    doTpDown()
                elseif action == "autoLeft" then
                    State.autoLeftEnabled = not State.autoLeftEnabled
                    if State.autoLeftEnabled then
                        if State.batAimbotToggled then
                            State.batAimbotToggled=false; stopBatAimbot()
                            if stackBtnRefs.aimbot then stackBtnRefs.aimbot.setOn(false) end
                        end
                        startAutoLeft()
                    else
                        stopAutoLeft()
                    end
                    if stackBtnRefs.autoLeft then stackBtnRefs.autoLeft.setOn(State.autoLeftEnabled) end
                elseif action == "autoRight" then
                    State.autoRightEnabled = not State.autoRightEnabled
                    if State.autoRightEnabled then
                        if State.batAimbotToggled then
                            State.batAimbotToggled=false; stopBatAimbot()
                            if stackBtnRefs.aimbot then stackBtnRefs.aimbot.setOn(false) end
                        end
                        startAutoRight()
                    else
                        stopAutoRight()
                    end
                    if stackBtnRefs.autoRight then stackBtnRefs.autoRight.setOn(State.autoRightEnabled) end
                elseif action == "instantReset" then
                    performInstantReset()
                end
            end)
            table.insert(keybindListeners, conn)
        end
    end
    
    -- Controller keybind listeners
    for action, keyCode in pairs(State.controllerKeybinds) do
        if keyCode ~= Enum.KeyCode.Unknown then
            local conn = UIS.InputBegan:Connect(function(input, gp)
                if gp then return end
                if input.UserInputType ~= Enum.UserInputType.Gamepad1 and input.UserInputType ~= Enum.UserInputType.Gamepad2 then return end
                if input.KeyCode ~= keyCode then return end
                
                -- Execute the action (same as above)
                if action == "drop" then
                    State.dropEnabled = not State.dropEnabled
                    if State.dropEnabled then runDropBrainrot() else stopDropBrainrot() end
                    if stackBtnRefs.drop then stackBtnRefs.drop.setOn(State.dropEnabled) end
                elseif action == "batAimbot" then
                    if not State.batAimbotToggled then
                        if State.autoLeftEnabled then State.autoLeftEnabled=false; stopAutoLeft(); if stackBtnRefs.autoLeft then stackBtnRefs.autoLeft.setOn(false) end end
                        if State.autoRightEnabled then State.autoRightEnabled=false; stopAutoRight(); if stackBtnRefs.autoRight then stackBtnRefs.autoRight.setOn(false) end end
                        pcall(startBatAimbot)
                    else
                        pcall(stopBatAimbot)
                    end
                    if stackBtnRefs.aimbot then stackBtnRefs.aimbot.setOn(State.batAimbotToggled) end
                elseif action == "laggerMode" then
                    State.laggerEnabled = not State.laggerEnabled
                    if stackBtnRefs.lagger then stackBtnRefs.lagger.setOn(State.laggerEnabled) end
                    if State.laggerEnabled then
                        State._prevCarry=State.carrySpeed
                        State._prevSpeed=State.speedToggled
                        State.speedToggled=false
                        if stackBtnRefs.carrySpeed then stackBtnRefs.carrySpeed.setOn(false) end
                        if carryBox then carryBox.Text=tostring(State.laggerSpeed) end
                    else
                        State.carrySpeed=State._prevCarry or 30
                        State.speedToggled=State._prevSpeed or false
                        if carryBox then carryBox.Text=tostring(State.carrySpeed) end
                        if stackBtnRefs.carrySpeed then stackBtnRefs.carrySpeed.setOn(State.speedToggled) end
                    end
                elseif action == "carrySpeed" then
                    State.speedToggled = not State.speedToggled
                    if stackBtnRefs.carrySpeed then stackBtnRefs.carrySpeed.setOn(State.speedToggled) end
                elseif action == "normalSpeed" then
                    State.speedToggled = false
                    if stackBtnRefs.carrySpeed then stackBtnRefs.carrySpeed.setOn(false) end
                elseif action == "tpDown" then
                    doTpDown()
                elseif action == "autoLeft" then
                    State.autoLeftEnabled = not State.autoLeftEnabled
                    if State.autoLeftEnabled then
                        if State.batAimbotToggled then
                            State.batAimbotToggled=false; stopBatAimbot()
                            if stackBtnRefs.aimbot then stackBtnRefs.aimbot.setOn(false) end
                        end
                        startAutoLeft()
                    else
                        stopAutoLeft()
                    end
                    if stackBtnRefs.autoLeft then stackBtnRefs.autoLeft.setOn(State.autoLeftEnabled) end
                elseif action == "autoRight" then
                    State.autoRightEnabled = not State.autoRightEnabled
                    if State.autoRightEnabled then
                        if State.batAimbotToggled then
                            State.batAimbotToggled=false; stopBatAimbot()
                            if stackBtnRefs.aimbot then stackBtnRefs.aimbot.setOn(false) end
                        end
                        startAutoRight()
                    else
                        stopAutoRight()
                    end
                    if stackBtnRefs.autoRight then stackBtnRefs.autoRight.setOn(State.autoRightEnabled) end
                elseif action == "instantReset" then
                    performInstantReset()
                end
            end)
            table.insert(keybindListeners, conn)
        end
    end
end

-- AUTO TP DOWN
local function startAutoTPDown()
    if Conns.autoTPDown then return end
    Conns.autoTPDown = RunService.Heartbeat:Connect(function()
        if not State.autoTPDownEnabled then return end
        local char = LP.Character if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart") if not root then return end
        if root.Position.Y >= math.abs(State.autoTPDownY) then root.CFrame = CFrame.new(root.Position.X, State.autoTPDownY, root.Position.Z) end
    end)
end
local function stopAutoTPDown() if Conns.autoTPDown then Conns.autoTPDown:Disconnect(); Conns.autoTPDown=nil end end

-- ========== HOLD INFINITE JUMP ==========
local function startHoldInfJump()
    if Conns.holdInfJump then return end
    
    -- JumpRequest for immediate jumps
    local jumpConn = UIS.JumpRequest:Connect(function()
        if not State.holdInfJumpEnabled then return end
        local char = LP.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then
            root.Velocity = Vector3.new(root.Velocity.X, 55, root.Velocity.Z)
        end
    end)
    
    -- Heartbeat for hold jumping
    local heartConn = RunService.Heartbeat:Connect(function()
        if not State.holdInfJumpEnabled then return end
        local char = LP.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        -- Hold jump to keep jumping
        local hum = char:FindFirstChildOfClass("Humanoid")
        local jumpHeld = UIS:IsKeyDown(Enum.KeyCode.Space) or (hum and hum.Jump == true)
        if jumpHeld and root.Velocity.Y < 30 then
            root.Velocity = Vector3.new(root.Velocity.X, 55, root.Velocity.Z)
        end
        
        -- Fall speed limit
        if root.Velocity.Y < -120 then
            root.Velocity = Vector3.new(root.Velocity.X, -120, root.Velocity.Z)
        end
    end)
    
    Conns.holdInfJump = {jump = jumpConn, heart = heartConn}
end

local function stopHoldInfJump()
    if Conns.holdInfJump then
        if Conns.holdInfJump.jump then Conns.holdInfJump.jump:Disconnect() end
        if Conns.holdInfJump.heart then Conns.holdInfJump.heart:Disconnect() end
        Conns.holdInfJump = nil
    end
end

-- INSTANT RESET (Main function)
local function findResetRemote()
    for _, desc in ipairs(game:GetDescendants()) do if desc:IsA("RemoteEvent") and desc.Name:sub(1,3) == "RE/" then cursedResetRemote = desc; return true end end
    return false
end
pcall(function() if hookfunction and newcclosure then local oldFire; oldFire = hookfunction(Instance.new("RemoteEvent").FireServer, newcclosure(function(self,...) if not cursedResetRemote and typeof(self)=="Instance" and self:IsA("RemoteEvent") and self.Name:sub(1,3)=="RE/" then cursedResetRemote=self end; return oldFire(self,...) end)) end end)
task.spawn(function() task.wait(1); if not cursedResetRemote then findResetRemote() end end)

local function performInstantReset()
    if resetCooldown then return end; resetCooldown = true
    if not cursedResetRemote then findResetRemote() end
    if not cursedResetRemote then for _, desc in ipairs(game:GetDescendants()) do if desc:IsA("RemoteEvent") and desc.Name:sub(1,3)=="RE/" then cursedResetRemote=desc; break end end end
    if cursedResetRemote then
        local character = LP.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.Health <= 0 then pcall(function() cursedResetRemote:FireServer(CURSED_RESET_GUID, LP, "balloon") end); task.delay(0.3, function() resetCooldown=false end); return end
        local resetDetected = false; local conns = {}
        if humanoid then table.insert(conns, humanoid.Died:Connect(function() resetDetected=true end)); table.insert(conns, humanoid:GetPropertyChangedSignal("Health"):Connect(function() if humanoid.Health <= 0 then resetDetected=true end end)) end
        if character then table.insert(conns, character.AncestryChanged:Connect(function(_, parent) if not parent then resetDetected=true end end)) end
        task.spawn(function() for i=1,50 do if resetDetected then break end; pcall(function() cursedResetRemote:FireServer(CURSED_RESET_GUID, LP, "balloon") end); task.wait() end; for _, conn in ipairs(conns) do pcall(function() conn:Disconnect() end) end; task.delay(0.3, function() resetCooldown=false end) end)
    else
        local char = LP.Character; local hum = char and char:FindFirstChildOfClass("Humanoid"); if hum then hum.Health=0 end; task.delay(0.3, function() resetCooldown=false end)
    end
end

-- MEDUSA RESET - Now uses the main Instant Reset
local function checkMedusaForInstantReset()
    if not State.instantResetOnMedusa then return end
    if State._medusaResetCooldown then return end
    if tick()-State._lastResetTime < 3 then return end
    local char = LP.Character
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.Anchored and part.Transparency == 1 then
            State._medusaResetCooldown = true
            State._lastResetTime = tick()
            -- Use the main instant reset function
            performInstantReset()
            task.wait(2)
            State._medusaResetCooldown = false
            break
        end
    end
end

local function onAnchorChanged(part)
    return part:GetPropertyChangedSignal("Anchored"):Connect(function()
        if part.Anchored and part.Transparency==1 then
            checkMedusaForInstantReset()
        end
    end)
end

local function setupMedusaDetection(char)
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            onAnchorChanged(part)
        end
    end
    char.DescendantAdded:Connect(function(part)
        if part:IsA("BasePart") then
            onAnchorChanged(part)
        end
    end)
end

-- TRACERS (Black color)
local function clearTracers() for _, line in pairs(tracerLines) do pcall(function() line:Remove() end) end; tracerLines={} end
local function updateTracers()
    if not State.tracersEnabled then clearTracers(); return end
    local camera = workspace.CurrentCamera; local char = LP.Character; local myHRP = char and char:FindFirstChild("HumanoidRootPart")
    if not myHRP or not camera then clearTracers(); return end
    local validKeys = {}
    for _, plr in ipairs(Players:GetPlayers()) do if plr ~= LP and plr.Character then local tHRP = plr.Character:FindFirstChild("HumanoidRootPart"); if tHRP then validKeys[tostring(plr.UserId)] = {plr=plr, hrp=tHRP} end end end
    for key, line in pairs(tracerLines) do if not validKeys[key] then pcall(function() line:Remove() end); tracerLines[key]=nil end end
    local screenSize = camera.ViewportSize; local fromX = screenSize.X / 2; local fromY = screenSize.Y
    for key, data in pairs(validKeys) do local tPos, onScreen = camera:WorldToViewportPoint(data.hrp.Position); if onScreen then local line = tracerLines[key]; if not line and Drawing then line = Drawing.new("Line"); line.Thickness=2; line.Color=Color3.fromRGB(0,0,0); line.Transparency=0.7; line.Visible=true; tracerLines[key]=line end; if line then line.From=Vector2.new(fromX,fromY); line.To=Vector2.new(tPos.X,tPos.Y); line.Visible=true end else local line=tracerLines[key]; if line then line.Visible=false end end end
end

-- SIMPLE FOV
local function toggleSimpleFOV()
    State.simpleFovEnabled = not State.simpleFovEnabled
    if State.simpleFovEnabled then
        _defFov = workspace.CurrentCamera.FieldOfView
        if not simpleFovConn then
            simpleFovConn = RunService.RenderStepped:Connect(function()
                if State.simpleFovEnabled then
                    workspace.CurrentCamera.FieldOfView = State.simpleFovValue
                end
            end)
        end
    else
        if simpleFovConn then
            simpleFovConn:Disconnect()
            simpleFovConn = nil
        end
        workspace.CurrentCamera.FieldOfView = _defFov
    end
end

local function setSimpleFOV(val)
    State.simpleFovValue = math.clamp(val, 70, 120)
    if State.simpleFovEnabled then
        workspace.CurrentCamera.FieldOfView = State.simpleFovValue
    end
end

-- SKY THEME SYSTEM
local CANDY_SKY_PRESETS = {
    ["Off"] = {kind = "off"},
    ["Night"] = {clock = 22, brightness = 2, ambient = {110,100,130}, outAmb = {120,110,140}},
    ["Aurora"] = {clock = 14, brightness = 3, ambient = {150,120,150}, outAmb = {160,130,160}},
    ["Sunset"] = {clock = 17.2, brightness = 2.5, ambient = {170,120,100}, outAmb = {180,130,110}},
    ["Galaxy"] = {clock = 0, brightness = 1.5, ambient = {70,60,100}, outAmb = {80,70,110}},
    ["Cyber"] = {clock = 21, brightness = 2.2, ambient = {90,130,170}, outAmb = {100,140,180}},
    ["Sakura"] = {clock = 11, brightness = 3.5, ambient = {170,150,160}, outAmb = {180,160,170}},
    ["Blood Moon"] = {clock = 22.5, brightness = 1.6, ambient = {130,40,40}, outAmb = {150,50,50}},
    ["Emerald Dawn"] = {clock = 6.5, brightness = 2.8, ambient = {130,170,140}, outAmb = {140,180,150}},
    ["Arctic"] = {clock = 9, brightness = 3.2, ambient = {200,220,235}, outAmb = {210,230,245}},
    ["Vaporwave"] = {clock = 19.5, brightness = 2.4, ambient = {180,120,200}, outAmb = {190,130,210}},
    ["Solar Eclipse"] = {clock = 12, brightness = 0.9, ambient = {50,40,60}, outAmb = {60,50,70}},
    ["Heaven"] = {clock = 12, brightness = 4, ambient = {240,235,210}, outAmb = {250,245,220}},
    ["Inferno"] = {clock = 17.5, brightness = 2.2, ambient = {220,100,40}, outAmb = {235,110,50}},
}

local SkyOrder = {
    "Off","Night","Aurora","Sunset","Galaxy","Cyber","Sakura",
    "Blood Moon","Emerald Dawn","Arctic","Vaporwave",
    "Solar Eclipse","Heaven","Inferno"
}

local function candyColor(rgb) return Color3.fromRGB(rgb[1], rgb[2], rgb[3]) end

local function candySaveOriginalLighting()
    if candyOriginalLighting then return end
    candyOriginalLighting = {
        ClockTime = Lighting.ClockTime,
        OutdoorAmbient = Lighting.OutdoorAmbient,
        Ambient = Lighting.Ambient,
        Brightness = Lighting.Brightness,
    }
end

local function candyClearSky()
    for _, child in ipairs(Lighting:GetChildren()) do
        if child:GetAttribute(CANDY_SKY_TAG) then
            pcall(function() child:Destroy() end)
        end
    end
end

local function CandyApplyCustomSky(mode)
    candySaveOriginalLighting()
    candyClearSky()
    local preset = CANDY_SKY_PRESETS[mode]
    if not preset or preset.kind == "off" then
        if candyOriginalLighting then
            for k, v in pairs(candyOriginalLighting) do
                pcall(function() Lighting[k] = v end)
            end
        end
        State.currentSkyTheme = "Off"
        return
    end
    Lighting.ClockTime = preset.clock or 14
    Lighting.Brightness = preset.brightness or 2
    if preset.outAmb then Lighting.OutdoorAmbient = candyColor(preset.outAmb) end
    if preset.ambient then Lighting.Ambient = candyColor(preset.ambient) end
    State.currentSkyTheme = mode
end

-- VISUAL FEATURES
local function updateGalaxy()
    if State.galaxyOn then
        local sky = Lighting:FindFirstChild("NgasGalaxySky") or Instance.new("Sky")
        sky.Name = "NgasGalaxySky"
        sky.SkyboxBk, sky.SkyboxDn, sky.SkyboxFt, sky.SkyboxLf, sky.SkyboxRt, sky.SkyboxUp =
            "rbxassetid://159454299","rbxassetid://159454296","rbxassetid://159454293",
            "rbxassetid://159454286","rbxassetid://159454289","rbxassetid://159454291"
        sky.Parent = Lighting
        Lighting.Brightness, Lighting.ClockTime, Lighting.ExposureCompensation = 0, 0, -2
        Lighting.OutdoorAmbient = Color3.fromRGB(0, 0, 0)
    else
        if Lighting:FindFirstChild("NgasGalaxySky") then Lighting.NgasGalaxySky:Destroy() end
        Lighting.Brightness, Lighting.ClockTime, Lighting.ExposureCompensation = defBrightness, defClock, 0
        Lighting.OutdoorAmbient = defAmbient
    end
end

-- ANTI BAT SPIN (deprecated but kept for compatibility)
local detectDistance = 15

-- ============================================================
-- NEW CANDY BAT AIMBOT SYSTEM
-- ============================================================

-- FIND BAT TOOL
local function findBat()
    local char = LP.Character
    if not char then return nil end
    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") and (tool.Name:lower():find("bat") or tool.Name:lower():find("slap")) then
            return tool
        end
    end
    local bp = LP:FindFirstChild("Backpack")
    if bp then
        for _, tool in ipairs(bp:GetChildren()) do
            if tool:IsA("Tool") and (tool.Name:lower():find("bat") or tool.Name:lower():find("slap")) then
                return tool
            end
        end
    end
    return nil
end

-- GET CLOSEST TARGET (Sticky)
local function getClosestTarget()
    local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not root then return nil, nil end
    local closest, closestPlr, minDist = nil, nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character then
            local tRoot = plr.Character:FindFirstChild("HumanoidRootPart")
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if tRoot and hum and hum.Health > 0 then
                local dist = (tRoot.Position - root.Position).Magnitude
                if dist < minDist then
                    minDist = dist
                    closest = tRoot
                    closestPlr = plr
                end
            end
        end
    end
    return closest, closestPlr, minDist
end

local function getStickyTarget(currentRoot)
    local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not root then return nil, nil end
    local newClosest, newPlr, newDist = getClosestTarget()
    if not newClosest then return nil, nil end
    if currentRoot and currentRoot.Parent then
        local currentPlr = Players:GetPlayerFromCharacter(currentRoot.Parent)
        local hum = currentRoot.Parent:FindFirstChildOfClass("Humanoid")
        if currentPlr and hum and hum.Health > 0 then
            local currentDist = (currentRoot.Position - root.Position).Magnitude
            if currentPlr == newPlr or newDist > currentDist * 0.7 then
                return currentRoot, currentPlr
            end
        end
    end
    return newClosest, newPlr
end

-- SWING BAT
local function swingCurrentBat(char)
    if not State.autoSwingEnabled then return end
    local bat = findBat()
    if bat and bat.Parent == char and bat:IsA("Tool") then
        pcall(function() bat:Activate() end)
    end
end

-- START / STOP AIMBOT
local function startBatAimbot()
    if Conns.aimbot then Conns.aimbot:Disconnect() end
    
    State.batAimbotToggled = true
    local hum0 = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if hum0 then hum0.AutoRotate = false end

    Conns.aimbot = RunService.RenderStepped:Connect(function()
        if not State.batAimbotToggled then return end
        local char = LP.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end

        -- Equip bat if not holding one
        if not char:FindFirstChildOfClass("Tool") then
            local bat = findBat()
            if bat then pcall(function() hum:EquipTool(bat) end) end
        end

        -- Get sticky target
        local target, targetPlr = getStickyTarget(_aimbotTarget)
        if not target then
            _aimbotTarget = nil
            _aimbotTargetPlr = nil
            swingCurrentBat(char)
            return
        end
        _aimbotTarget = target
        _aimbotTargetPlr = targetPlr

        local targetVel = target.Velocity
        local myPos = root.Position
        local targetPos = target.Position
        local distance = (targetPos - myPos).Magnitude

        -- Adaptive prediction
        local speedFactor = math.clamp(targetVel.Magnitude / 40, 0, 1.2)
        local distFactor = math.clamp(distance / 80, 0, 1)
        local leadTime = 0.14 + speedFactor * 0.12 + distFactor * 0.08
        local predictPos = targetPos + targetVel * leadTime
        predictPos = predictPos + target.CFrame.LookVector * 0.3

        local direction = predictPos - myPos
        local flatDir = Vector3.new(direction.X, 0, direction.Z)
        if flatDir.Magnitude > 0.01 then flatDir = flatDir.Unit else flatDir = Vector3.new(0, 0, 0) end

        -- Chase speed
        local chaseSpeed = State.batAimbotSpeed

        -- Height tracking
        local jumpOffset = math.max(0, targetVel.Y * 0.18)
        local desiredHeight = targetPos.Y + 3.7 + jumpOffset
        local yVel = (desiredHeight - myPos.Y) * 22 + targetVel.Y * 1.1
        if hum.FloorMaterial ~= Enum.Material.Air then
            yVel = math.max(yVel, 13)
        end
        yVel = math.clamp(yVel, -70, 135)

        local desiredVel = Vector3.new(flatDir.X * chaseSpeed, yVel, flatDir.Z * chaseSpeed)
        root.Velocity = root.Velocity:Lerp(desiredVel, 0.85)

        -- Rotation tracking
        local rotPredictTime = math.clamp(targetVel.Magnitude / 120, 0.05, 0.25)
        local predictedPos = targetPos + targetVel * rotPredictTime
        local toPredict = predictedPos - myPos
        if toPredict.Magnitude > 0.1 then
            local goalCF = CFrame.lookAt(myPos, predictedPos)
            local diffCF = root.CFrame:Inverse() * goalCF
            local rx, ry, rz = diffCF:ToEulerAnglesXYZ()
            rx = math.clamp(rx, -2.5, 2.5)
            ry = math.clamp(ry, -2.5, 2.5)
            rz = math.clamp(rz, -2.5, 2.5)
            root.AssemblyAngularVelocity = root.CFrame:VectorToWorldSpace(Vector3.new(rx * 50, ry * 50, rz * 50))
        end

        swingCurrentBat(char)
    end)
end

local function stopBatAimbot()
    if Conns.aimbot then
        Conns.aimbot:Disconnect()
        Conns.aimbot = nil
    end
    _aimbotTarget = nil
    _aimbotTargetPlr = nil
    State.batAimbotToggled = false
    local char = LP.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then
        root.Velocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
    end
    local hum2 = char and char:FindFirstChildOfClass("Humanoid")
    if hum2 then hum2.AutoRotate = true end
end

-- CHARACTER RESPAWN HANDLER
LP.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    if State.batAimbotToggled then
        task.wait(0.2)
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then
            root.Velocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
        end
        startBatAimbot()
    end
    -- Restart speed bypass on respawn
    task.wait(1)
    if State.speedBypassEnabled then
        restartSpeedBypass()
    end
    -- Restart anti bat bypass on respawn
    if State.antiBatBypassEnabled then
        restartAntiBatBypass()
    end
    -- Setup ragdoll timer on respawn
    if State.ragdollTimerEnabled then
        task.wait(0.5)
        setupRagdollBillboard(char)
    end
end)

-- ============================================================
-- CREATE GUI
-- ============================================================
local gui = Instance.new("ScreenGui"); gui.Name="AxonicHub"; gui.ResetOnSpawn=false; gui.DisplayOrder=10; gui.IgnoreGuiInset=true; gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; gui.Parent=PG
local uiScaleObj_inst = Instance.new("UIScale",gui); uiScaleObj_inst.Scale=1.0

-- FLOATING BUTTON
local vBtnFrame = Instance.new("ImageButton",gui); vBtnFrame.Name="AxonicPill"; vBtnFrame.Size=UDim2.new(0,48,0,48); vBtnFrame.Position=UDim2.new(1,-58,0,14); vBtnFrame.BackgroundColor3=Color3.fromRGB(0,0,0); vBtnFrame.BackgroundTransparency=0.1; vBtnFrame.BorderSizePixel=0; vBtnFrame.Active=true; vBtnFrame.ZIndex=20; mkCorner(vBtnFrame,12); mkStroke(vBtnFrame,Color3.fromRGB(200,200,200),1.5); vBtnFrame.Image=LOGO_ID; vBtnFrame.ImageTransparency=0.1

-- MAIN WINDOW
local WIN_W=340; local WIN_H=440
local TITLE_H=38; local TAB_COL_W=76
local mainOuter = Instance.new("Frame",gui); mainOuter.Name="MainOuter"; mainOuter.Size=UDim2.new(0,WIN_W,0,WIN_H); mainOuter.Position=UDim2.new(0.5,-WIN_W/2,0.5,-WIN_H/2); mainOuter.BackgroundColor3=C.winBg; mainOuter.BorderSizePixel=0; mainOuter.ClipsDescendants=true; mkCorner(mainOuter,10); mkStroke(mainOuter,C.winBorder,2); makeDraggable(mainOuter); mainOuter.Visible=true

-- BUTTON CLICK
vBtnFrame.MouseButton1Click:Connect(function()
    State.guiVisible = not State.guiVisible; mainOuter.Visible = State.guiVisible
    if State.guiVisible then vBtnFrame.ImageTransparency=0.1; vBtnFrame.BackgroundTransparency=0.1 else vBtnFrame.ImageTransparency=0.6; vBtnFrame.BackgroundTransparency=0.5 end
end)

-- DRAG
local vDragging,vDragInput,vDragStart,vStartPos=false,nil,nil,nil; local vMoved=false
vBtnFrame.InputBegan:Connect(function(inp) if inp.UserInputType~=Enum.UserInputType.MouseButton1 and inp.UserInputType~=Enum.UserInputType.Touch then return end; vDragging=true; vMoved=false; vDragStart=inp.Position; vStartPos=vBtnFrame.Position; inp.Changed:Connect(function() if inp.UserInputState==Enum.UserInputState.End then vDragging=false; vMoved=false end end) end)
vBtnFrame.InputChanged:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseMovement or inp.UserInputType==Enum.UserInputType.Touch then vDragInput=inp end end)
UIS.InputChanged:Connect(function(inp) if inp~=vDragInput or not vDragging then return end; local dx=inp.Position.X-vDragStart.X; local dy=inp.Position.Y-vDragStart.Y; if math.abs(dx)>4 or math.abs(dy)>4 then vMoved=true end; if vMoved then vBtnFrame.Position=UDim2.new(vStartPos.X.Scale,vStartPos.X.Offset+dx,vStartPos.Y.Scale,vStartPos.Y.Offset+dy) end end)
vBtnFrame.MouseEnter:Connect(function() if State.guiVisible then TS:Create(vBtnFrame,TweenInfo.new(0.15),{BackgroundTransparency=0.05}):Play() else TS:Create(vBtnFrame,TweenInfo.new(0.15),{BackgroundTransparency=0.3}):Play() end end)
vBtnFrame.MouseLeave:Connect(function() if State.guiVisible then TS:Create(vBtnFrame,TweenInfo.new(0.15),{BackgroundTransparency=0.1}):Play() else TS:Create(vBtnFrame,TweenInfo.new(0.15),{BackgroundTransparency=0.5}):Play() end end)

-- BG
local bgImg=Instance.new("ImageLabel",mainOuter); bgImg.Size=UDim2.new(1,0,1,0); bgImg.BackgroundColor3=C.winBg; bgImg.BackgroundTransparency=1; bgImg.Image=LOGO_ID; bgImg.ScaleType=Enum.ScaleType.Crop; bgImg.ImageTransparency=0.15; bgImg.ZIndex=2; mkCorner(bgImg,10)
local bgOverlay=Instance.new("Frame",mainOuter); bgOverlay.Size=UDim2.new(1,0,1,0); bgOverlay.BackgroundColor3=Color3.fromRGB(0,0,0); bgOverlay.BackgroundTransparency=0.55; bgOverlay.BorderSizePixel=0; bgOverlay.ZIndex=1; mkCorner(bgOverlay,10)

-- TITLE BAR
local titleBar=Instance.new("Frame",mainOuter); titleBar.Size=UDim2.new(1,0,0,TITLE_H); titleBar.BackgroundColor3=Color3.fromRGB(6,6,6); titleBar.BackgroundTransparency=0.05; titleBar.BorderSizePixel=0; titleBar.ZIndex=5; mkCorner(titleBar,10)
local titleAccent=Instance.new("Frame",titleBar); titleAccent.Size=UDim2.new(1,0,0,2); titleAccent.BackgroundColor3=C.winBorder; titleAccent.BorderSizePixel=0; titleAccent.ZIndex=6
local titleLbl=Instance.new("TextLabel",titleBar); titleLbl.Size=UDim2.new(1,-110,1,0); titleLbl.Position=UDim2.new(0,12,0,0); titleLbl.BackgroundTransparency=1; titleLbl.Text="AXONIC HUB"; titleLbl.TextColor3=C.topTitle; titleLbl.Font=Enum.Font.GothamBlack; titleLbl.TextSize=15; titleLbl.TextXAlignment=Enum.TextXAlignment.Left; titleLbl.TextStrokeTransparency=0.5; titleLbl.TextStrokeColor3=Color3.fromRGB(0,0,0); titleLbl.ZIndex=6
local closeBtn=Instance.new("TextButton",titleBar); closeBtn.Size=UDim2.new(0,24,0,24); closeBtn.Position=UDim2.new(1,-34,0.5,-12); closeBtn.BackgroundColor3=C.chipBg; closeBtn.BorderSizePixel=0; closeBtn.Text="Ã—"; closeBtn.TextColor3=C.accent; closeBtn.Font=Enum.Font.GothamBlack; closeBtn.TextSize=16; closeBtn.ZIndex=7; mkCorner(closeBtn,5); mkStroke(closeBtn,C.chipBorder,1); closeBtn.MouseButton1Click:Connect(function() State.guiVisible=false; mainOuter.Visible=false; vBtnFrame.ImageTransparency=0.6; vBtnFrame.BackgroundTransparency=0.5 end)
local lockBtn=Instance.new("TextButton",titleBar); lockBtn.Size=UDim2.new(0,24,0,24); lockBtn.Position=UDim2.new(1,-62,0.5,-12); lockBtn.BackgroundColor3=C.chipBg; lockBtn.BorderSizePixel=0; lockBtn.Text="ðŸ”“"; lockBtn.Font=Enum.Font.GothamBold; lockBtn.TextSize=11; lockBtn.ZIndex=7; mkCorner(lockBtn,5); mkStroke(lockBtn,C.chipBorder,1); lockBtn.MouseButton1Click:Connect(function() State.uiLocked=not State.uiLocked; lockBtn.Text=State.uiLocked and "ðŸ”’" or "ðŸ”“" end)
local titleDiv=Instance.new("Frame",mainOuter); titleDiv.Size=UDim2.new(1,0,0,1); titleDiv.Position=UDim2.new(0,0,0,TITLE_H); titleDiv.BackgroundColor3=C.topDivider; titleDiv.BorderSizePixel=0; titleDiv.ZIndex=5

-- TAB COLUMN
local tabCol=Instance.new("Frame",mainOuter); tabCol.Size=UDim2.new(0,TAB_COL_W,1,-TITLE_H); tabCol.Position=UDim2.new(0,0,0,TITLE_H); tabCol.BackgroundColor3=C.winBg; tabCol.BackgroundTransparency=0.12; tabCol.BorderSizePixel=0; tabCol.ZIndex=4
local tabColDiv=Instance.new("Frame",tabCol); tabColDiv.Size=UDim2.new(0,1,1,0); tabColDiv.Position=UDim2.new(1,-1,0,0); tabColDiv.BackgroundColor3=C.topDivider; tabColDiv.BorderSizePixel=0; tabColDiv.ZIndex=5
local tabList=Instance.new("Frame",tabCol); tabList.Size=UDim2.new(1,0,1,0); tabList.BackgroundTransparency=1; tabList.ZIndex=6
local tabLL=Instance.new("UIListLayout",tabList); tabLL.SortOrder=Enum.SortOrder.LayoutOrder; tabLL.Padding=UDim.new(0,4)
local tabPad=Instance.new("UIPadding",tabList); tabPad.PaddingTop=UDim.new(0,8); tabPad.PaddingLeft=UDim.new(0,5); tabPad.PaddingRight=UDim.new(0,5)

-- CONTENT AREA
local contentArea=Instance.new("Frame",mainOuter); contentArea.Name="Content"; contentArea.Size=UDim2.new(0,WIN_W-TAB_COL_W,1,-TITLE_H); contentArea.Position=UDim2.new(0,TAB_COL_W,0,TITLE_H); contentArea.BackgroundTransparency=1; contentArea.BorderSizePixel=0; contentArea.ClipsDescendants=true; contentArea.ZIndex=2

-- TABS (Speed, Bat Aimbot, Mechanics, Visual, Keybinds, Settings)
local TABS={"Speed","Bat Aimbot","Mechanics","Visual","Keybinds","Settings"}
local currentTab="Speed"; local tabBtns={}; local tabPages={}
local function switchTab(name) currentTab=name; for _,n in ipairs(TABS) do local t=tabBtns[n]; local isA=(n==name); TS:Create(t.frame,TweenInfo.new(0.14),{BackgroundColor3=isA and C.tabActiveBg or C.tabIdle}):Play(); TS:Create(t.lbl,TweenInfo.new(0.14),{TextColor3=isA and C.tabActTxt or C.tabIdleTxt}):Play(); if tabPages[n] then tabPages[n].Visible=isA end end end
for i,name in ipairs(TABS) do
    local btn=Instance.new("TextButton",tabList); btn.Size=UDim2.new(1,0,0,34); btn.BackgroundColor3=(name==currentTab) and C.tabActiveBg or C.tabIdle; btn.BorderSizePixel=0; btn.Text=""; btn.LayoutOrder=i; btn.ZIndex=7; btn.AutoButtonColor=false; mkCorner(btn,7)
    local lbl=Instance.new("TextLabel",btn); lbl.Size=UDim2.new(1,0,1,0); lbl.BackgroundTransparency=1; lbl.Text=name; lbl.TextColor3=(name==currentTab) and C.tabActTxt or C.tabIdleTxt; lbl.Font=Enum.Font.GothamBold; lbl.TextSize=9; lbl.TextWrapped=true; lbl.ZIndex=8
    tabBtns[name]={frame=btn,lbl=lbl}
    local page=Instance.new("ScrollingFrame",contentArea); page.Size=UDim2.new(1,0,1,0); page.BackgroundTransparency=1; page.BorderSizePixel=0; page.ScrollBarThickness=3; page.ScrollBarImageColor3=C.accent; page.ScrollBarImageTransparency=0.4; page.AutomaticCanvasSize=Enum.AutomaticSize.Y; page.CanvasSize=UDim2.new(0,0,0,0); page.Visible=(name=="Speed"); page.ZIndex=3
    local pll=Instance.new("UIListLayout",page); pll.SortOrder=Enum.SortOrder.LayoutOrder; pll.Padding=UDim.new(0,0)
    local pp=Instance.new("UIPadding",page); pp.PaddingLeft=UDim.new(0,8); pp.PaddingRight=UDim.new(0,8); pp.PaddingTop=UDim.new(0,10); pp.PaddingBottom=UDim.new(0,10)
    tabPages[name]=page
    btn.MouseButton1Click:Connect(function() switchTab(name) end)
    btn.MouseEnter:Connect(function() if currentTab~=name then TS:Create(btn,TweenInfo.new(0.1),{BackgroundColor3=C.cardHov}):Play() end end)
    btn.MouseLeave:Connect(function() if currentTab~=name then TS:Create(btn,TweenInfo.new(0.1),{BackgroundColor3=C.tabIdle}):Play() end end)
end

-- ROW BUILDERS
local currentPage=nil; local lo=0
local function LO() lo=lo+1; return lo end
local _anyKeyListening=false
local function makeGap(px) local f=Instance.new("Frame",currentPage); f.Size=UDim2.new(1,0,0,px or 6); f.BackgroundTransparency=1; f.BorderSizePixel=0; f.LayoutOrder=LO() end
local function makeSectionHeader(label) local wrap=Instance.new("Frame",currentPage); wrap.Size=UDim2.new(1,0,0,26); wrap.BackgroundColor3=Color3.fromRGB(14,14,14); wrap.BackgroundTransparency=0.5; wrap.BorderSizePixel=0; wrap.LayoutOrder=LO(); mkCorner(wrap,0); local accent=Instance.new("Frame",wrap); accent.Size=UDim2.new(0,3,0.6,0); accent.Position=UDim2.new(0,0,0.2,0); accent.BackgroundColor3=C.accent; accent.BorderSizePixel=0; mkCorner(accent,2); local lbl=Instance.new("TextLabel",wrap); lbl.Size=UDim2.new(1,-28,1,0); lbl.Position=UDim2.new(0,12,0,0); lbl.BackgroundTransparency=1; lbl.Text=label and label:upper() or ""; lbl.TextColor3=C.sectionTxt; lbl.Font=Enum.Font.GothamBold; lbl.TextSize=10; lbl.TextXAlignment=Enum.TextXAlignment.Left end
local function makeInputRow(label,default,onChange) local row=Instance.new("Frame",currentPage); row.Size=UDim2.new(1,0,0,40); row.BackgroundColor3=C.cardBg; row.BorderSizePixel=0; row.LayoutOrder=LO(); mkCorner(row,7); mkStroke(row,C.rowBorder,1); row.MouseEnter:Connect(function() TS:Create(row,TweenInfo.new(0.1),{BackgroundColor3=C.cardHov}):Play() end); row.MouseLeave:Connect(function() TS:Create(row,TweenInfo.new(0.1),{BackgroundColor3=C.cardBg}):Play() end); local lbl=Instance.new("TextLabel",row); lbl.Size=UDim2.new(1,-90,1,0); lbl.Position=UDim2.new(0,10,0,0); lbl.BackgroundTransparency=1; lbl.Text=label; lbl.TextColor3=C.rowLabel; lbl.Font=Enum.Font.GothamBold; lbl.TextSize=11; lbl.TextXAlignment=Enum.TextXAlignment.Left; local boxWrap=Instance.new("Frame",row); boxWrap.Size=UDim2.new(0,66,0,24); boxWrap.Position=UDim2.new(1,-76,0.5,-12); boxWrap.BackgroundColor3=C.inputBg; boxWrap.BorderSizePixel=0; mkCorner(boxWrap,6); local bs=mkStroke(boxWrap,C.inputBorder,1); local box=Instance.new("TextBox",boxWrap); box.Size=UDim2.new(1,-6,1,0); box.Position=UDim2.new(0,3,0,0); box.BackgroundTransparency=1; box.Text=tostring(default); box.TextColor3=C.inputTxt; box.Font=Enum.Font.GothamBold; box.TextSize=11; box.ClearTextOnFocus=false; box.ZIndex=8; box.TextXAlignment=Enum.TextXAlignment.Center; box.Focused:Connect(function() TS:Create(bs,TweenInfo.new(0.15),{Color=C.inputFocus}):Play() end); box.FocusLost:Connect(function() TS:Create(bs,TweenInfo.new(0.15),{Color=C.inputBorder}):Play(); if onChange then local n=tonumber(box.Text); if n then onChange(n) else box.Text=tostring(default) end end; task.spawn(function() if saveConfig then pcall(saveConfig) end end) end); return box,row end
local function makeToggleRow(label,defaultOn,onToggle,subtext) local rowH=subtext and 52 or 40; local row=Instance.new("Frame",currentPage); row.Size=UDim2.new(1,0,0,rowH); row.BackgroundColor3=C.cardBg; row.BorderSizePixel=0; row.LayoutOrder=LO(); mkCorner(row,7); mkStroke(row,C.rowBorder,1); row.MouseEnter:Connect(function() TS:Create(row,TweenInfo.new(0.1),{BackgroundColor3=C.cardHov}):Play() end); row.MouseLeave:Connect(function() TS:Create(row,TweenInfo.new(0.1),{BackgroundColor3=C.cardBg}):Play() end); local lbl=Instance.new("TextLabel",row); if subtext then lbl.Size=UDim2.new(1,-68,0,20); lbl.Position=UDim2.new(0,10,0,7) else lbl.Size=UDim2.new(1,-68,1,0); lbl.Position=UDim2.new(0,10,0,0) end; lbl.BackgroundTransparency=1; lbl.Text=label; lbl.TextColor3=C.rowLabel; lbl.Font=Enum.Font.GothamBold; lbl.TextSize=11; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.TextYAlignment=Enum.TextYAlignment.Center; if subtext then local s2=Instance.new("TextLabel",row); s2.Size=UDim2.new(1,-68,0,14); s2.Position=UDim2.new(0,10,0,27); s2.BackgroundTransparency=1; s2.Text=subtext; s2.TextColor3=C.rowSub; s2.Font=Enum.Font.Gotham; s2.TextSize=9; s2.TextXAlignment=Enum.TextXAlignment.Left end; local pillBg=Instance.new("Frame",row); pillBg.Size=UDim2.new(0,40,0,20); pillBg.Position=UDim2.new(1,-52,0.5,-10); pillBg.BackgroundColor3=defaultOn and C.pillOn or C.pillOff; pillBg.BorderSizePixel=0; pillBg.ZIndex=7; mkCorner(pillBg,10); mkStroke(pillBg,C.pillBorder,1); local dot=Instance.new("Frame",pillBg); dot.Size=UDim2.new(0,14,0,14); dot.Position=defaultOn and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7); dot.BackgroundColor3=defaultOn and C.dotOn or C.dotOff; dot.BorderSizePixel=0; dot.ZIndex=8; mkCorner(dot,7); local isOn=defaultOn or false; local function setV(on) isOn=on; TS:Create(pillBg,TweenInfo.new(0.18,Enum.EasingStyle.Quad),{BackgroundColor3=on and C.pillOn or C.pillOff}):Play(); TS:Create(dot,TweenInfo.new(0.18,Enum.EasingStyle.Back),{Position=on and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7), BackgroundColor3=on and C.dotOn or C.dotOff}):Play() end; local function toggle() isOn=not isOn; setV(isOn); if onToggle then pcall(onToggle,isOn) end; task.spawn(function() if saveConfig then pcall(saveConfig) end end) end; local clk=Instance.new("TextButton",row); clk.Size=UDim2.new(1,-52,1,0); clk.BackgroundTransparency=1; clk.Text=""; clk.ZIndex=5; clk.BorderSizePixel=0; clk.MouseButton1Click:Connect(toggle); local pClk=Instance.new("TextButton",pillBg); pClk.Size=UDim2.new(1,0,1,0); pClk.BackgroundTransparency=1; pClk.Text=""; pClk.ZIndex=9; pClk.BorderSizePixel=0; pClk.MouseButton1Click:Connect(toggle); return setV end

-- BUILD PAGES
local function buildPage(tabName,buildFn) currentPage=tabPages[tabName]; lo=0; buildFn(); currentPage=nil end

-- SPEED PAGE
buildPage("Speed",function()
    makeGap(4); makeSectionHeader("Speed Settings"); makeGap(4)
    normalBox=makeInputRow("Normal Speed",State.normalSpeed,function(n) if n>0 and n<=500 then State.normalSpeed=n end end)
    makeGap(2)
    carryBox=makeInputRow("Carry Speed",State.carrySpeed,function(n) if n>0 and n<=500 then State.carrySpeed=n end end)
    makeGap(2)
    laggerBox=makeInputRow("Lagger Speed",State.laggerSpeed,function(n) if n>0 and n<=500 then State.laggerSpeed=n end end)
    makeGap(6)
    local modeRow=Instance.new("Frame",currentPage); modeRow.Size=UDim2.new(1,0,0,40); modeRow.BackgroundColor3=C.cardBg; modeRow.BorderSizePixel=0; modeRow.LayoutOrder=LO(); mkCorner(modeRow,7); mkStroke(modeRow,C.rowBorder,1)
    local mLbl=Instance.new("TextLabel",modeRow); mLbl.Size=UDim2.new(0,60,1,0); mLbl.Position=UDim2.new(0,10,0,0); mLbl.BackgroundTransparency=1; mLbl.Text="Mode"; mLbl.TextColor3=C.rowLabel; mLbl.Font=Enum.Font.GothamBold; mLbl.TextSize=11; mLbl.TextXAlignment=Enum.TextXAlignment.Left
    local mValLbl=Instance.new("TextLabel",modeRow); mValLbl.Size=UDim2.new(0,70,1,0); mValLbl.Position=UDim2.new(0,70,0,0); mValLbl.BackgroundTransparency=1; mValLbl.Text="Normal"; mValLbl.TextColor3=C.rowSub; mValLbl.Font=Enum.Font.GothamBold; mValLbl.TextSize=11; mValLbl.TextXAlignment=Enum.TextXAlignment.Left
    local mClk=Instance.new("TextButton",modeRow); mClk.Size=UDim2.new(0.65,0,1,0); mClk.BackgroundTransparency=1; mClk.Text=""; mClk.ZIndex=6; mClk.MouseButton1Click:Connect(function() State.speedToggled=not State.speedToggled; mValLbl.Text=State.speedToggled and "Carry" or "Normal"; if stackBtnRefs.carrySpeed then stackBtnRefs.carrySpeed.setOn(State.speedToggled) end; task.spawn(function() if saveConfig then pcall(saveConfig) end end) end)
    makeGap(8); makeSectionHeader("Bat Aimbot Speed"); makeGap(4)
    makeInputRow("Aimbot Speed",State.batAimbotSpeed,function(n) if n>=10 and n<=200 then State.batAimbotSpeed=n end end)
end)

-- BAT AIMBOT PAGE (Updated with Candy Bat Aimbot)
buildPage("Bat Aimbot",function()
    makeGap(4); makeSectionHeader("Candy Bat Aimbot"); makeGap(4)
    setAimbot=makeToggleRow("Bat Aimbot",false,function(on) 
        if on then 
            if State.autoLeftEnabled then State.autoLeftEnabled=false; stopAutoLeft(); if stackBtnRefs.autoLeft then stackBtnRefs.autoLeft.setOn(false) end end
            if State.autoRightEnabled then State.autoRightEnabled=false; stopAutoRight(); if stackBtnRefs.autoRight then stackBtnRefs.autoRight.setOn(false) end end
            pcall(startBatAimbot) 
        else 
            pcall(stopBatAimbot) 
        end
        if stackBtnRefs.aimbot then stackBtnRefs.aimbot.setOn(on) end
    end)
    makeGap(2)
    setAutoSwing=makeToggleRow("Auto Swing",true,function(on) State.autoSwingEnabled=on end)
    makeGap(2)
    setBatCounter=makeToggleRow("Bat Counter",false,function(on) State.batCounterEnabled=on; if on then startBatCounter() else stopBatCounter() end end)
    makeGap(8)
    local infoLabel=Instance.new("TextLabel",currentPage); 
    infoLabel.Size=UDim2.new(1,0,0,30); 
    infoLabel.BackgroundTransparency=1; 
    infoLabel.Text="âš”ï¸ Candy Bat Aimbot\nSticky targeting â€¢ Adaptive prediction â€¢ Auto-swing"; 
    infoLabel.TextColor3=C.rowSub; 
    infoLabel.Font=Enum.Font.Gotham; 
    infoLabel.TextSize=9; 
    infoLabel.TextWrapped=true;
    infoLabel.TextXAlignment=Enum.TextXAlignment.Center;
    infoLabel.LayoutOrder=LO()
end)

-- MECHANICS PAGE
buildPage("Mechanics",function()
    makeGap(4); makeSectionHeader("Stealing"); makeGap(4)
    setInstaGrab=makeToggleRow("Auto Steal",false,function(on) Steal.AutoStealEnabled=on; if on then pcall(startAutoSteal) else stopAutoSteal() end end)
    makeGap(2)
    stealRadBox=makeInputRow("Steal Radius",Steal.StealRadius,function(n) if n>=5 and n<=300 then Steal.StealRadius=math.floor(n); Steal.cachedPrompts={}; Steal.promptCacheTime=0 end end)
    makeGap(2)
    makeInputRow("Steal Duration",Steal.StealDuration,function(n) if n>=0.05 and n<=5 then Steal.StealDuration=n end end)
    makeGap(8); makeSectionHeader("Combat / Defense"); makeGap(4)
    setInfJump=makeToggleRow("Infinite Jump (Hold)",false,function(on) 
        State.infJumpEnabled=on
        State.holdInfJumpEnabled=on
        if on then 
            startHoldInfJump() 
        else 
            stopHoldInfJump() 
        end
    end)
    makeGap(2)
    -- V1 Anti-Ragdoll Toggle
    setAntiRag=makeToggleRow("Anti Ragdoll (V1)",false,function(on) 
        State.antiRagdollEnabled=on
        if on then 
            EnableAntiRagdoll()
        else 
            DisableAntiRagdoll()
        end
        task.spawn(function() if saveConfig then pcall(saveConfig) end end)
    end, "400 speed boost on ragdoll exit")
    makeGap(2)
    -- Ragdoll Timer Toggle
    setRagdollTimer=makeToggleRow("Ragdoll Timer",State.ragdollTimerEnabled,function(on)
        State.ragdollTimerEnabled = on
        if on then
            startRagdollTimer()
        else
            stopRagdollTimer()
        end
        task.spawn(function() if saveConfig then pcall(saveConfig) end end)
    end, "Shows 3-2-1-GO! countdown when ragdolled")
    makeGap(2)
    setFps=makeToggleRow("FPS Boost",false,function(on) State.fpsBoostEnabled=on; if on then pcall(applyFPSBoost) end end)
    makeGap(2)
    setMedusaCounter=makeToggleRow("Medusa Counter",false,function(on) State.medusaCounterEnabled=on; if on then setupMedusaCounter(LP.Character) else stopMedusaCounter() end end)
    makeGap(2)
    setUnwalkToggle=makeToggleRow("Unwalk",false,function(on) State.unwalkEnabled=on; if on then startUnwalk() else stopUnwalk() end end)
    makeGap(2)
    -- Anti Bat Bypass Toggle
    setAntiBatBypass=makeToggleRow("Anti Bat Bypass",false,function(on) 
        State.antiBatBypassEnabled=on
        if on then 
            startAntiBatBypass() 
        else 
            stopAntiBatBypass() 
        end
        task.spawn(function() if saveConfig then pcall(saveConfig) end end)
    end, "Limits bat speed to prevent flinging")
    makeGap(2)
    
    -- Anti Bat Bypass Settings Row
    local bypassRow = Instance.new("Frame",currentPage)
    bypassRow.Size=UDim2.new(1,0,0,80)
    bypassRow.BackgroundColor3=C.cardBg
    bypassRow.BorderSizePixel=0
    bypassRow.LayoutOrder=LO()
    mkCorner(bypassRow,7)
    mkStroke(bypassRow,C.rowBorder,1)
    
    -- Threshold input
    local threshLbl = Instance.new("TextLabel",bypassRow)
    threshLbl.Size=UDim2.new(0.4,0,0.4,0)
    threshLbl.Position=UDim2.new(0,8,0,2)
    threshLbl.BackgroundTransparency=1
    threshLbl.Text="Bat Threshold"
    threshLbl.TextColor3=C.rowLabel
    threshLbl.Font=Enum.Font.GothamBold
    threshLbl.TextSize=10
    threshLbl.TextXAlignment=Enum.TextXAlignment.Left
    
    local threshBox = Instance.new("TextBox",bypassRow)
    threshBox.Size=UDim2.new(0.3,0,0.35,0)
    threshBox.Position=UDim2.new(0.45,0,0.02,0)
    threshBox.BackgroundColor3=C.inputBg
    threshBox.BorderSizePixel=0
    threshBox.Text=tostring(State.batThreshold)
    threshBox.TextColor3=C.inputTxt
    threshBox.Font=Enum.Font.GothamBold
    threshBox.TextSize=10
    threshBox.TextXAlignment=Enum.TextXAlignment.Center
    mkCorner(threshBox,6)
    mkStroke(threshBox,C.inputBorder,1)
    threshBox.FocusLost:Connect(function()
        local n = tonumber(threshBox.Text)
        if n and n > 0 then
            State.batThreshold = n
            if State.antiBatBypassEnabled then restartAntiBatBypass() end
            task.spawn(function() if saveConfig then pcall(saveConfig) end end)
        else
            threshBox.Text = tostring(State.batThreshold)
        end
    end)
    
    -- Cap Speed input
    local capLbl = Instance.new("TextLabel",bypassRow)
    capLbl.Size=UDim2.new(0.4,0,0.4,0)
    capLbl.Position=UDim2.new(0,8,0.45,0)
    capLbl.BackgroundTransparency=1
    capLbl.Text="Cap Speed"
    capLbl.TextColor3=C.rowLabel
    capLbl.Font=Enum.Font.GothamBold
    capLbl.TextSize=10
    capLbl.TextXAlignment=Enum.TextXAlignment.Left
    
    local capBox = Instance.new("TextBox",bypassRow)
    capBox.Size=UDim2.new(0.3,0,0.35,0)
    capBox.Position=UDim2.new(0.45,0,0.47,0)
    capBox.BackgroundColor3=C.inputBg
    capBox.BorderSizePixel=0
    capBox.Text=tostring(State.capSpeed)
    capBox.TextColor3=C.inputTxt
    capBox.Font=Enum.Font.GothamBold
    capBox.TextSize=10
    capBox.TextXAlignment=Enum.TextXAlignment.Center
    mkCorner(capBox,6)
    mkStroke(capBox,C.inputBorder,1)
    capBox.FocusLost:Connect(function()
        local n = tonumber(capBox.Text)
        if n and n > 0 then
            State.capSpeed = n
            if State.antiBatBypassEnabled then restartAntiBatBypass() end
            task.spawn(function() if saveConfig then pcall(saveConfig) end end)
        else
            capBox.Text = tostring(State.capSpeed)
        end
    end)
    
    makeGap(2)
    local bypassInfo = Instance.new("TextLabel",currentPage)
    bypassInfo.Size=UDim2.new(1,0,0,16)
    bypassInfo.BackgroundTransparency=1
    bypassInfo.Text="Threshold: speed to detect â€¢ Cap: max speed limit"
    bypassInfo.TextColor3=C.rowSub
    bypassInfo.Font=Enum.Font.Gotham
    bypassInfo.TextSize=8
    bypassInfo.TextXAlignment=Enum.TextXAlignment.Center
    bypassInfo.LayoutOrder=LO()
    
    makeGap(8); makeSectionHeader("Auto TP Down"); makeGap(4)
    setAutoTPDownToggle=makeToggleRow("Auto TP Down",false,function(on) State.autoTPDownEnabled=on; if on then startAutoTPDown() else stopAutoTPDown() end end)
    makeGap(2)
    local tpYBox=makeInputRow("TP Y Position",20,function(n) if n and n>0 then State.autoTPDownY = -math.abs(n) end end)
    makeGap(8); makeSectionHeader("Tracers"); makeGap(4)
    local tracerToggle = makeToggleRow("Enable Tracers",State.tracersEnabled,function(on) State.tracersEnabled=on; if not on then clearTracers() end end)
    makeGap(2)
    local tracerInfo = Instance.new("TextLabel",currentPage); tracerInfo.Size=UDim2.new(1,0,0,20); tracerInfo.BackgroundTransparency=1; tracerInfo.Text="Press F to toggle Tracers"; tracerInfo.TextColor3=C.rowSub; tracerInfo.Font=Enum.Font.Gotham; tracerInfo.TextSize=10; tracerInfo.TextXAlignment=Enum.TextXAlignment.Center; tracerInfo.LayoutOrder=LO()
    makeGap(8); makeSectionHeader("Instant Reset on Medusa"); makeGap(4)
    local medusaToggle = makeToggleRow("Auto Reset on Medusa",State.instantResetOnMedusa,function(on) State.instantResetOnMedusa=on end)
    makeGap(2)
    local medusaInfo = Instance.new("TextLabel",currentPage); medusaInfo.Size=UDim2.new(1,0,0,20); medusaInfo.BackgroundTransparency=1; medusaInfo.Text="Medusa auto-reset uses main Instant Reset"; medusaInfo.TextColor3=C.rowSub; medusaInfo.Font=Enum.Font.Gotham; medusaInfo.TextSize=10; medusaInfo.TextXAlignment=Enum.TextXAlignment.Center; medusaInfo.LayoutOrder=LO()
    makeGap(8); makeSectionHeader("Instant Reset"); makeGap(4)
    local resetRow=Instance.new("Frame",currentPage); resetRow.Size=UDim2.new(1,0,0,45); resetRow.BackgroundColor3=C.cardBg; resetRow.BorderSizePixel=0; resetRow.LayoutOrder=LO(); mkCorner(resetRow,7); mkStroke(resetRow,C.rowBorder,1)
    local resetBtn=Instance.new("TextButton",resetRow); resetBtn.Size=UDim2.new(1,-20,1,-8); resetBtn.Position=UDim2.new(0,10,0,4); resetBtn.BackgroundColor3=Color3.fromRGB(200,50,50); resetBtn.BorderSizePixel=0; resetBtn.Text="INSTANT RESET (T Key)"; resetBtn.TextColor3=Color3.fromRGB(255,255,255); resetBtn.Font=Enum.Font.GothamBold; resetBtn.TextSize=13; mkCorner(resetBtn,6); resetBtn.MouseButton1Click:Connect(function() performInstantReset(); TS:Create(resetBtn,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(255,0,0)}):Play(); task.delay(0.15,function() TS:Create(resetBtn,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(200,50,50)}):Play() end) end)
end)

-- VISUAL PAGE
buildPage("Visual",function()
    makeGap(4); makeSectionHeader("Visual Settings"); makeGap(4)
    
    -- FOV Toggle
    local fovToggle = makeToggleRow("FOV (110)",State.fovOn,function(on)
        State.fovOn = on
        camera.FieldOfView = on and 110 or 70
    end)
    makeGap(2)
    
    -- Galaxy Toggle
    local galaxyToggle = makeToggleRow("Galaxy Sky",State.galaxyOn,function(on)
        State.galaxyOn = on
        updateGalaxy()
    end)
    makeGap(2)
    
    -- Anti Bat Toggle (deprecated but kept)
    local antiBatToggle = makeToggleRow("Anti Bat (Spin)",State.antiBatOn,function(on)
        State.antiBatOn = on
    end)
    makeGap(8)
    
    makeSectionHeader("Simple FOV + Sky Theme")
    makeGap(4)
    
    -- Simple FOV Toggle
    local simpleFovToggle = makeToggleRow("Simple FOV",State.simpleFovEnabled,function(on)
        State.simpleFovEnabled = on
        toggleSimpleFOV()
    end)
    makeGap(2)
    
    -- Simple FOV Slider
    local fovSliderRow = Instance.new("Frame",currentPage)
    fovSliderRow.Size=UDim2.new(1,0,0,40)
    fovSliderRow.BackgroundColor3=C.cardBg
    fovSliderRow.BorderSizePixel=0
    fovSliderRow.LayoutOrder=LO()
    mkCorner(fovSliderRow,7)
    mkStroke(fovSliderRow,C.rowBorder,1)
    
    local fovSliderLbl = Instance.new("TextLabel",fovSliderRow)
    fovSliderLbl.Size=UDim2.new(0.3,0,1,0)
    fovSliderLbl.Position=UDim2.new(0,8,0,0)
    fovSliderLbl.BackgroundTransparency=1
    fovSliderLbl.Text="FOV Value"
    fovSliderLbl.TextColor3=C.rowLabel
    fovSliderLbl.Font=Enum.Font.GothamBold
    fovSliderLbl.TextSize=11
    fovSliderLbl.TextXAlignment=Enum.TextXAlignment.Left
    
    local fovValLbl = Instance.new("TextLabel",fovSliderRow)
    fovValLbl.Size=UDim2.new(0.15,0,1,0)
    fovValLbl.Position=UDim2.new(0.35,0,0,0)
    fovValLbl.BackgroundTransparency=1
    fovValLbl.Text=tostring(State.simpleFovValue)
    fovValLbl.TextColor3=Color3.fromRGB(100,200,255)
    fovValLbl.Font=Enum.Font.GothamBold
    fovValLbl.TextSize=11
    fovValLbl.TextXAlignment=Enum.TextXAlignment.Center
    
    local fovSliderBg = Instance.new("Frame",fovSliderRow)
    fovSliderBg.Size=UDim2.new(0.4,0,0,6)
    fovSliderBg.Position=UDim2.new(0.55,0,0.5,-3)
    fovSliderBg.BackgroundColor3=Color3.fromRGB(40,40,50)
    fovSliderBg.BorderSizePixel=0
    mkCorner(fovSliderBg,3)
    
    local fovSliderFill = Instance.new("Frame",fovSliderBg)
    local pct = (State.simpleFovValue - 70) / 50
    fovSliderFill.Size=UDim2.new(pct,0,1,0)
    fovSliderFill.BackgroundColor3=Color3.fromRGB(100,200,255)
    fovSliderFill.BorderSizePixel=0
    mkCorner(fovSliderFill,3)
    
    local fovHandle = Instance.new("Frame",fovSliderBg)
    fovHandle.Size=UDim2.new(0,10,0,14)
    fovHandle.Position=UDim2.new(pct,-5,0.5,-7)
    fovHandle.BackgroundColor3=Color3.fromRGB(255,255,255)
    fovHandle.BorderSizePixel=0
    mkCorner(fovHandle,5)
    
    local fovSliderBtn = Instance.new("TextButton",fovSliderBg)
    fovSliderBtn.Size=UDim2.new(1,0,1,12)
    fovSliderBtn.Position=UDim2.new(0,0,0.5,-6)
    fovSliderBtn.BackgroundTransparency=1
    fovSliderBtn.Text=""
    
    local fovDragging = false
    fovSliderBtn.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            fovDragging = true
            local abs = fovSliderBg.AbsolutePosition
            local sz = fovSliderBg.AbsoluteSize
            local pct2 = math.clamp((inp.Position.X - abs.X) / sz.X, 0, 1)
            local val = math.floor(70 + pct2 * 50)
            setSimpleFOV(val)
            fovValLbl.Text = tostring(val)
            fovSliderFill.Size = UDim2.new(pct2,0,1,0)
            fovHandle.Position = UDim2.new(pct2,-5,0.5,-7)
        end
    end)
    
    fovSliderBtn.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            fovDragging = false
        end
    end)
    
    UIS.InputChanged:Connect(function(inp)
        if not fovDragging then return end
        if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
            local abs = fovSliderBg.AbsolutePosition
            local sz = fovSliderBg.AbsoluteSize
            local pct2 = math.clamp((inp.Position.X - abs.X) / sz.X, 0, 1)
            local val = math.floor(70 + pct2 * 50)
            setSimpleFOV(val)
            fovValLbl.Text = tostring(val)
            fovSliderFill.Size = UDim2.new(pct2,0,1,0)
            fovHandle.Position = UDim2.new(pct2,-5,0.5,-7)
        end
    end)
    
    makeGap(2)
    
    -- Sky Theme Selector
    local skyRow = Instance.new("Frame",currentPage)
    skyRow.Size=UDim2.new(1,0,0,45)
    skyRow.BackgroundColor3=C.cardBg
    skyRow.BorderSizePixel=0
    skyRow.LayoutOrder=LO()
    mkCorner(skyRow,7)
    mkStroke(skyRow,C.rowBorder,1)
    
    local skyLbl = Instance.new("TextLabel",skyRow)
    skyLbl.Size=UDim2.new(0.4,0,1,0)
    skyLbl.Position=UDim2.new(0,8,0,0)
    skyLbl.BackgroundTransparency=1
    skyLbl.Text="Sky Theme"
    skyLbl.TextColor3=C.rowLabel
    skyLbl.Font=Enum.Font.GothamBold
    skyLbl.TextSize=11
    skyLbl.TextXAlignment=Enum.TextXAlignment.Left
    
    local skyThemeLbl = Instance.new("TextLabel",skyRow)
    skyThemeLbl.Size=UDim2.new(0.3,0,1,0)
    skyThemeLbl.Position=UDim2.new(0.4,0,0,0)
    skyThemeLbl.BackgroundTransparency=1
    skyThemeLbl.Text=State.currentSkyTheme or "Off"
    skyThemeLbl.TextColor3=Color3.fromRGB(200,200,200)
    skyThemeLbl.Font=Enum.Font.GothamBold
    skyThemeLbl.TextSize=11
    skyThemeLbl.TextXAlignment=Enum.TextXAlignment.Center
    
    local skyBtn = Instance.new("TextButton",skyRow)
    skyBtn.Size=UDim2.new(0.2,0,0.7,0)
    skyBtn.Position=UDim2.new(0.73,0,0.15,0)
    skyBtn.BackgroundColor3=Color3.fromRGB(60,60,80)
    skyBtn.BorderSizePixel=0
    skyBtn.Text="Next"
    skyBtn.TextColor3=Color3.fromRGB(255,255,255)
    skyBtn.TextSize=11
    skyBtn.Font=Enum.Font.GothamBold
    mkCorner(skyBtn,6)
    
    local skyIndex = 1
    for i, name in ipairs(SkyOrder) do
        if name == State.currentSkyTheme then
            skyIndex = i
            break
        end
    end
    
    skyBtn.MouseButton1Click:Connect(function()
        skyIndex = skyIndex % #SkyOrder + 1
        local newTheme = SkyOrder[skyIndex]
        skyThemeLbl.Text = newTheme
        CandyApplyCustomSky(newTheme)
        State.currentSkyTheme = newTheme
    end)
end)

-- ============================================================
-- KEYBINDS PAGE (with Controller Buttons)
-- ============================================================
buildPage("Keybinds",function()
    makeGap(4); makeSectionHeader("Keyboard Keybinds"); makeGap(4)
    
    local keybindActions = {
        {action="drop", label="DROP BR"},
        {action="batAimbot", label="BAT AIMBOT"},
        {action="laggerMode", label="LAGGER MODE"},
        {action="carrySpeed", label="CARRY SPEED"},
        {action="normalSpeed", label="NORMAL SPEED"},
        {action="tpDown", label="TP DOWN"},
        {action="autoLeft", label="AUTO LEFT"},
        {action="autoRight", label="AUTO RIGHT"},
        {action="instantReset", label="INSTANT RESET"},
    }
    
    local keybindBtns = {}
    
    for _, data in ipairs(keybindActions) do
        local currentKey = State.keybinds[data.action]
        local keyName = currentKey and currentKey ~= Enum.KeyCode.Unknown and currentKey.Name or "None"
        
        local row = Instance.new("Frame",currentPage)
        row.Size=UDim2.new(1,0,0,36)
        row.BackgroundColor3=C.cardBg
        row.BorderSizePixel=0
        row.LayoutOrder=LO()
        mkCorner(row,7)
        mkStroke(row,C.rowBorder,1)
        
        local lbl = Instance.new("TextLabel",row)
        lbl.Size=UDim2.new(0.5,0,1,0)
        lbl.Position=UDim2.new(0,10,0,0)
        lbl.BackgroundTransparency=1
        lbl.Text=data.label
        lbl.TextColor3=C.rowLabel
        lbl.Font=Enum.Font.GothamBold
        lbl.TextSize=11
        lbl.TextXAlignment=Enum.TextXAlignment.Left
        
        local keyBtn = Instance.new("TextButton",row)
        keyBtn.Size=UDim2.new(0.35,0,0.7,0)
        keyBtn.Position=UDim2.new(0.6,0,0.15,0)
        keyBtn.BackgroundColor3=Color3.fromRGB(40,40,50)
        keyBtn.BorderSizePixel=0
        keyBtn.Text=keyName
        keyBtn.TextColor3=Color3.fromRGB(255,255,255)
        keyBtn.Font=Enum.Font.GothamBold
        keyBtn.TextSize=11
        mkCorner(keyBtn,6)
        mkStroke(keyBtn,Color3.fromRGB(60,60,70),1)
        
        local function startListening()
            if _anyKeyListening then return end
            _anyKeyListening = true
            keyBtn.Text = "Press key..."
            keyBtn.BackgroundColor3 = Color3.fromRGB(255,200,0)
            
            local conn
            conn = UIS.InputBegan:Connect(function(input, gp)
                if gp then return end
                if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
                
                -- Don't allow controller buttons for keyboard binds
                if isControllerButton(input.KeyCode) then
                    _anyKeyListening = false
                    keyBtn.Text = keyName
                    keyBtn.BackgroundColor3 = Color3.fromRGB(40,40,50)
                    if conn then conn:Disconnect() end
                    return
                end
                
                State.keybinds[data.action] = input.KeyCode
                keyBtn.Text = input.KeyCode.Name
                keyBtn.BackgroundColor3 = Color3.fromRGB(40,40,50)
                _anyKeyListening = false
                conn:Disconnect()
                
                -- Restart keybind listeners with new key
                startKeybindListen()
                
                -- Save config
                task.spawn(function() if saveConfig then pcall(saveConfig) end end)
            end)
            
            -- Timeout after 5 seconds
            task.delay(5, function()
                if _anyKeyListening then
                    _anyKeyListening = false
                    keyBtn.Text = keyName
                    keyBtn.BackgroundColor3 = Color3.fromRGB(40,40,50)
                    if conn then conn:Disconnect() end
                end
            end)
        end
        
        keyBtn.MouseButton1Click:Connect(startListening)
        
        table.insert(keybindBtns, {btn=keyBtn, action=data.action})
    end
    
    makeGap(8)
    makeSectionHeader("ðŸŽ® Controller Keybinds"); makeGap(4)
    
    -- Controller button actions (same list)
    local controllerActions = {
        {action="drop", label="DROP BR"},
        {action="batAimbot", label="BAT AIMBOT"},
        {action="laggerMode", label="LAGGER MODE"},
        {action="carrySpeed", label="CARRY SPEED"},
        {action="normalSpeed", label="NORMAL SPEED"},
        {action="tpDown", label="TP DOWN"},
        {action="autoLeft", label="AUTO LEFT"},
        {action="autoRight", label="AUTO RIGHT"},
        {action="instantReset", label="INSTANT RESET"},
    }
    
    local controllerBtns = {}
    
    for _, data in ipairs(controllerActions) do
        local currentKey = State.controllerKeybinds[data.action]
        local keyName = currentKey and currentKey ~= Enum.KeyCode.Unknown and getControllerButtonName(currentKey) or "None"
        
        local row = Instance.new("Frame",currentPage)
        row.Size=UDim2.new(1,0,0,36)
        row.BackgroundColor3=C.cardBg
        row.BorderSizePixel=0
        row.LayoutOrder=LO()
        mkCorner(row,7)
        mkStroke(row,C.rowBorder,1)
        
        local lbl = Instance.new("TextLabel",row)
        lbl.Size=UDim2.new(0.5,0,1,0)
        lbl.Position=UDim2.new(0,10,0,0)
        lbl.BackgroundTransparency=1
        lbl.Text=data.label
        lbl.TextColor3=C.rowLabel
        lbl.Font=Enum.Font.GothamBold
        lbl.TextSize=11
        lbl.TextXAlignment=Enum.TextXAlignment.Left
        
        local keyBtn = Instance.new("TextButton",row)
        keyBtn.Size=UDim2.new(0.35,0,0.7,0)
        keyBtn.Position=UDim2.new(0.6,0,0.15,0)
        keyBtn.BackgroundColor3=Color3.fromRGB(30,40,60)
        keyBtn.BorderSizePixel=0
        keyBtn.Text=keyName
        keyBtn.TextColor3=Color3.fromRGB(100,200,255)
        keyBtn.Font=Enum.Font.GothamBold
        keyBtn.TextSize=11
        mkCorner(keyBtn,6)
        mkStroke(keyBtn,Color3.fromRGB(50,80,120),1)
        
        local function startControllerListening()
            if _anyKeyListening then return end
            _anyKeyListening = true
            keyBtn.Text = "Press ðŸŽ®..."
            keyBtn.BackgroundColor3 = Color3.fromRGB(255,200,0)
            
            local conn
            conn = UIS.InputBegan:Connect(function(input, gp)
                if gp then return end
                if input.UserInputType ~= Enum.UserInputType.Gamepad1 and input.UserInputType ~= Enum.UserInputType.Gamepad2 then return end
                
                -- Only allow controller buttons
                if not isControllerButton(input.KeyCode) then
                    _anyKeyListening = false
                    keyBtn.Text = keyName
                    keyBtn.BackgroundColor3 = Color3.fromRGB(30,40,60)
                    if conn then conn:Disconnect() end
                    return
                end
                
                State.controllerKeybinds[data.action] = input.KeyCode
                keyBtn.Text = getControllerButtonName(input.KeyCode)
                keyBtn.BackgroundColor3 = Color3.fromRGB(30,40,60)
                _anyKeyListening = false
                conn:Disconnect()
                
                -- Restart keybind listeners with new key
                startKeybindListen()
                
                -- Save config
                task.spawn(function() if saveConfig then pcall(saveConfig) end end)
            end)
            
            -- Timeout after 5 seconds
            task.delay(5, function()
                if _anyKeyListening then
                    _anyKeyListening = false
                    keyBtn.Text = keyName
                    keyBtn.BackgroundColor3 = Color3.fromRGB(30,40,60)
                    if conn then conn:Disconnect() end
                end
            end)
        end
        
        keyBtn.MouseButton1Click:Connect(startControllerListening)
        
        table.insert(controllerBtns, {btn=keyBtn, action=data.action})
    end
    
    makeGap(8)
    
    -- Controller layout info
    local layoutInfo = Instance.new("Frame",currentPage)
    layoutInfo.Size=UDim2.new(1,0,0,100)
    layoutInfo.BackgroundColor3=C.controllerBg
    layoutInfo.BorderSizePixel=0
    layoutInfo.LayoutOrder=LO()
    mkCorner(layoutInfo,7)
    mkStroke(layoutInfo,C.controllerBorder,1)
    
    local layoutLbl = Instance.new("TextLabel",layoutInfo)
    layoutLbl.Size=UDim2.new(1,0,1,0)
    layoutLbl.Position=UDim2.new(0,0,0,0)
    layoutLbl.BackgroundTransparency=1
    layoutLbl.Text = [[ðŸŽ® CONTROLLER LAYOUT:
    
    LT=LB / RT=RB
    A=Right  / B=Left  / X=Down  / Y=Up
    LS=Stick / RS=Stick
    DPAD=Directions]]
    layoutLbl.TextColor3=Color3.fromRGB(180,190,210)
    layoutLbl.Font=Enum.Font.Gotham
    layoutLbl.TextSize=10
    layoutLbl.TextXAlignment=Enum.TextXAlignment.Center
    layoutLbl.TextYAlignment=Enum.TextYAlignment.Center
    layoutLbl.TextWrapped=true
    
    makeGap(8)
    
    -- Reset buttons
    local resetRow = Instance.new("Frame",currentPage)
    resetRow.Size=UDim2.new(1,0,0,70)
    resetRow.BackgroundColor3=C.cardBg
    resetRow.BorderSizePixel=0
    resetRow.LayoutOrder=LO()
    mkCorner(resetRow,7)
    mkStroke(resetRow,C.rowBorder,1)
    
    local resetLabel = Instance.new("TextLabel",resetRow)
    resetLabel.Size=UDim2.new(1,0,0,20)
    resetLabel.Position=UDim2.new(0,10,0,4)
    resetLabel.BackgroundTransparency=1
    resetLabel.Text="Reset Keybinds"
    resetLabel.TextColor3=C.rowLabel
    resetLabel.Font=Enum.Font.GothamBold
    resetLabel.TextSize=11
    resetLabel.TextXAlignment=Enum.TextXAlignment.Left
    
    local resetAllBtn = Instance.new("TextButton",resetRow)
    resetAllBtn.Size=UDim2.new(0.3,0,0.35,0)
    resetAllBtn.Position=UDim2.new(0.05,0,0.3,0)
    resetAllBtn.BackgroundColor3=Color3.fromRGB(200,50,50)
    resetAllBtn.BorderSizePixel=0
    resetAllBtn.Text="RESET ALL"
    resetAllBtn.TextColor3=Color3.fromRGB(255,255,255)
    resetAllBtn.Font=Enum.Font.GothamBold
    resetAllBtn.TextSize=10
    mkCorner(resetAllBtn,6)
    
    resetAllBtn.MouseButton1Click:Connect(function()
        -- Reset keyboard keybinds to Unknown
        for action, _ in pairs(State.keybinds) do
            State.keybinds[action] = Enum.KeyCode.Unknown
        end
        State.keybinds.instantReset = Enum.KeyCode.T
        
        -- Reset controller keybinds to Unknown
        for action, _ in pairs(State.controllerKeybinds) do
            State.controllerKeybinds[action] = Enum.KeyCode.Unknown
        end
        
        -- Update keyboard buttons
        for _, data in ipairs(keybindBtns) do
            local keyName2 = State.keybinds[data.action] and State.keybinds[data.action] ~= Enum.KeyCode.Unknown and State.keybinds[data.action].Name or "None"
            data.btn.Text = keyName2
            data.btn.BackgroundColor3 = Color3.fromRGB(40,40,50)
        end
        
        -- Update controller buttons
        for _, data in ipairs(controllerBtns) do
            local keyName2 = State.controllerKeybinds[data.action] and State.controllerKeybinds[data.action] ~= Enum.KeyCode.Unknown and getControllerButtonName(State.controllerKeybinds[data.action]) or "None"
            data.btn.Text = keyName2
            data.btn.BackgroundColor3 = Color3.fromRGB(30,40,60)
        end
        
        startKeybindListen()
        task.spawn(function() if saveConfig then pcall(saveConfig) end end)
    end)
    
    local resetKbBtn = Instance.new("TextButton",resetRow)
    resetKbBtn.Size=UDim2.new(0.3,0,0.35,0)
    resetKbBtn.Position=UDim2.new(0.38,0,0.3,0)
    resetKbBtn.BackgroundColor3=Color3.fromRGB(200,150,50)
    resetKbBtn.BorderSizePixel=0
    resetKbBtn.Text="RESET KB"
    resetKbBtn.TextColor3=Color3.fromRGB(255,255,255)
    resetKbBtn.Font=Enum.Font.GothamBold
    resetKbBtn.TextSize=10
    mkCorner(resetKbBtn,6)
    
    resetKbBtn.MouseButton1Click:Connect(function()
        -- Reset keyboard keybinds only
        for action, _ in pairs(State.keybinds) do
            State.keybinds[action] = Enum.KeyCode.Unknown
        end
        State.keybinds.instantReset = Enum.KeyCode.T
        
        for _, data in ipairs(keybindBtns) do
            local keyName2 = State.keybinds[data.action] and State.keybinds[data.action] ~= Enum.KeyCode.Unknown and State.keybinds[data.action].Name or "None"
            data.btn.Text = keyName2
            data.btn.BackgroundColor3 = Color3.fromRGB(40,40,50)
        end
        
        startKeybindListen()
        task.spawn(function() if saveConfig then pcall(saveConfig) end end)
    end)
    
    local resetCtrlBtn = Instance.new("TextButton",resetRow)
    resetCtrlBtn.Size=UDim2.new(0.3,0,0.35,0)
    resetCtrlBtn.Position=UDim2.new(0.71,0,0.3,0)
    resetCtrlBtn.BackgroundColor3=Color3.fromRGB(50,150,200)
    resetCtrlBtn.BorderSizePixel=0
    resetCtrlBtn.Text="RESET ðŸŽ®"
    resetCtrlBtn.TextColor3=Color3.fromRGB(255,255,255)
    resetCtrlBtn.Font=Enum.Font.GothamBold
    resetCtrlBtn.TextSize=10
    mkCorner(resetCtrlBtn,6)
    
    resetCtrlBtn.MouseButton1Click:Connect(function()
        -- Reset controller keybinds only
        for action, _ in pairs(State.controllerKeybinds) do
            State.controllerKeybinds[action] = Enum.KeyCode.Unknown
        end
        
        for _, data in ipairs(controllerBtns) do
            local keyName2 = State.controllerKeybinds[data.action] and State.controllerKeybinds[data.action] ~= Enum.KeyCode.Unknown and getControllerButtonName(State.controllerKeybinds[data.action]) or "None"
            data.btn.Text = keyName2
            data.btn.BackgroundColor3 = Color3.fromRGB(30,40,60)
        end
        
        startKeybindListen()
        task.spawn(function() if saveConfig then pcall(saveConfig) end end)
    end)
end)

-- SETTINGS PAGE
buildPage("Settings",function()
    makeGap(4); makeSectionHeader("Interface"); makeGap(4)
    setHideButtonsToggle=makeToggleRow("Hide Mobile Buttons",false,function(on) 
        State.stackButtonsHidden=on
        -- Hide everything including the background
        for _,wrapper in pairs(stackWrappers) do 
            wrapper.Visible=not on 
        end
        if mobBox then
            mobBox.Visible = not on
        end
        if mobBoxOverlay then
            mobBoxOverlay.Visible = not on
        end
        if mobBgImage then
            mobBgImage.Visible = not on
        end
    end)
    
    makeGap(8); makeSectionHeader("Save / Load"); makeGap(4)
    
    -- Save Button Row
    local saveRow = Instance.new("Frame",currentPage)
    saveRow.Size=UDim2.new(1,0,0,45)
    saveRow.BackgroundColor3=C.cardBg
    saveRow.BorderSizePixel=0
    saveRow.LayoutOrder=LO()
    mkCorner(saveRow,7)
    mkStroke(saveRow,C.rowBorder,1)
    
    local saveLbl = Instance.new("TextLabel",saveRow)
    saveLbl.Size=UDim2.new(0.5,0,1,0)
    saveLbl.Position=UDim2.new(0,10,0,0)
    saveLbl.BackgroundTransparency=1
    saveLbl.Text="Save Configuration"
    saveLbl.TextColor3=C.rowLabel
    saveLbl.Font=Enum.Font.GothamBold
    saveLbl.TextSize=11
    saveLbl.TextXAlignment=Enum.TextXAlignment.Left
    
    local saveBtn = Instance.new("TextButton",saveRow)
    saveBtn.Size=UDim2.new(0.35,0,0.7,0)
    saveBtn.Position=UDim2.new(0.6,0,0.15,0)
    saveBtn.BackgroundColor3=Color3.fromRGB(0,170,0)
    saveBtn.BorderSizePixel=0
    saveBtn.Text="ðŸ’¾ SAVE"
    saveBtn.TextColor3=Color3.fromRGB(255,255,255)
    saveBtn.Font=Enum.Font.GothamBold
    saveBtn.TextSize=11
    mkCorner(saveBtn,6)
    mkStroke(saveBtn,Color3.fromRGB(0,200,0),1)
    
    saveBtn.MouseButton1Click:Connect(function()
        saveConfig()
        -- Visual feedback
        local originalText = saveBtn.Text
        saveBtn.Text = "âœ“ SAVED!"
        saveBtn.BackgroundColor3 = Color3.fromRGB(0,255,0)
        TS:Create(saveBtn,TweenInfo.new(0.2),{BackgroundColor3=Color3.fromRGB(0,200,0)}):Play()
        task.delay(0.8,function()
            saveBtn.Text = originalText
            saveBtn.BackgroundColor3 = Color3.fromRGB(0,170,0)
        end)
    end)
    
    makeGap(2)
    local saveInfo = Instance.new("TextLabel",currentPage)
    saveInfo.Size=UDim2.new(1,0,0,16)
    saveInfo.BackgroundTransparency=1
    saveInfo.Text="Saves all settings to AxonicHubConfig.json"
    saveInfo.TextColor3=C.rowSub
    saveInfo.Font=Enum.Font.Gotham
    saveInfo.TextSize=8
    saveInfo.TextXAlignment=Enum.TextXAlignment.Center
    saveInfo.LayoutOrder=LO()
    
    makeGap(8); makeSectionHeader("Auto Exit Duel"); makeGap(4)
    
    -- Auto Exit Duel Toggle
    local autoExitRow = Instance.new("Frame",currentPage)
    autoExitRow.Size=UDim2.new(1,0,0,45)
    autoExitRow.BackgroundColor3=C.cardBg
    autoExitRow.BorderSizePixel=0
    autoExitRow.LayoutOrder=LO()
    mkCorner(autoExitRow,7)
    mkStroke(autoExitRow,C.rowBorder,1)
    
    local autoExitLbl = Instance.new("TextLabel",autoExitRow)
    autoExitLbl.Size=UDim2.new(0.6,0,1,0)
    autoExitLbl.Position=UDim2.new(0,10,0,0)
    autoExitLbl.BackgroundTransparency=1
    autoExitLbl.Text="Auto Exit Duel (GGS)"
    autoExitLbl.TextColor3=C.rowLabel
    autoExitLbl.Font=Enum.Font.GothamBold
    autoExitLbl.TextSize=11
    autoExitLbl.TextXAlignment=Enum.TextXAlignment.Left
    
    local autoExitPillBg = Instance.new("Frame",autoExitRow)
    autoExitPillBg.Size=UDim2.new(0,40,0,20)
    autoExitPillBg.Position=UDim2.new(1,-52,0.5,-10)
    autoExitPillBg.BackgroundColor3=State.autoExitDuelEnabled and C.pillOn or C.pillOff
    autoExitPillBg.BorderSizePixel=0
    autoExitPillBg.ZIndex=7
    mkCorner(autoExitPillBg,10)
    mkStroke(autoExitPillBg,C.pillBorder,1)
    
    local autoExitDot = Instance.new("Frame",autoExitPillBg)
    autoExitDot.Size=UDim2.new(0,14,0,14)
    autoExitDot.Position=State.autoExitDuelEnabled and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7)
    autoExitDot.BackgroundColor3=State.autoExitDuelEnabled and C.dotOn or C.dotOff
    autoExitDot.BorderSizePixel=0
    autoExitDot.ZIndex=8
    mkCorner(autoExitDot,7)
    
    local autoExitClk = Instance.new("TextButton",autoExitRow)
    autoExitClk.Size=UDim2.new(1,-52,1,0)
    autoExitClk.BackgroundTransparency=1
    autoExitClk.Text=""
    autoExitClk.ZIndex=5
    autoExitClk.BorderSizePixel=0
    autoExitClk.MouseButton1Click:Connect(function()
        toggleAutoExitDuel()
        local isOn = autoExitDuelEnabled
        TS:Create(autoExitPillBg,TweenInfo.new(0.18,Enum.EasingStyle.Quad),{BackgroundColor3=isOn and C.pillOn or C.pillOff}):Play()
        TS:Create(autoExitDot,TweenInfo.new(0.18,Enum.EasingStyle.Back),{
            Position=isOn and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7),
            BackgroundColor3=isOn and C.dotOn or C.dotOff
        }):Play()
        task.spawn(function() if saveConfig then pcall(saveConfig) end end)
    end)
    
    local pClkAutoExit = Instance.new("TextButton",autoExitPillBg)
    pClkAutoExit.Size=UDim2.new(1,0,1,0)
    pClkAutoExit.BackgroundTransparency=1
    pClkAutoExit.Text=""
    pClkAutoExit.ZIndex=9
    pClkAutoExit.BorderSizePixel=0
    pClkAutoExit.MouseButton1Click:Connect(function()
        toggleAutoExitDuel()
        local isOn = autoExitDuelEnabled
        TS:Create(autoExitPillBg,TweenInfo.new(0.18,Enum.EasingStyle.Quad),{BackgroundColor3=isOn and C.pillOn or C.pillOff}):Play()
        TS:Create(autoExitDot,TweenInfo.new(0.18,Enum.EasingStyle.Back),{
            Position=isOn and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7),
            BackgroundColor3=isOn and C.dotOn or C.dotOff
        }):Play()
        task.spawn(function() if saveConfig then pcall(saveConfig) end end)
    end)
    
    makeGap(2)
    local autoExitInfo = Instance.new("TextLabel",currentPage)
    autoExitInfo.Size=UDim2.new(1,0,0,16)
    autoExitInfo.BackgroundTransparency=1
    autoExitInfo.Text="Auto sends GGS then leaves when GameWin sound plays"
    autoExitInfo.TextColor3=C.rowSub
    autoExitInfo.Font=Enum.Font.Gotham
    autoExitInfo.TextSize=8
    autoExitInfo.TextXAlignment=Enum.TextXAlignment.Center
    autoExitInfo.LayoutOrder=LO()
    
    makeGap(8); makeSectionHeader("Intro Music"); makeGap(4)
    
    -- Intro Toggle
    local introToggleRow = Instance.new("Frame",currentPage)
    introToggleRow.Size=UDim2.new(1,0,0,40)
    introToggleRow.BackgroundColor3=C.cardBg
    introToggleRow.BorderSizePixel=0
    introToggleRow.LayoutOrder=LO()
    mkCorner(introToggleRow,7)
    mkStroke(introToggleRow,C.rowBorder,1)
    
    local introLbl = Instance.new("TextLabel",introToggleRow)
    introLbl.Size=UDim2.new(0.6,0,1,0)
    introLbl.Position=UDim2.new(0,10,0,0)
    introLbl.BackgroundTransparency=1
    introLbl.Text="Intro Animation"
    introLbl.TextColor3=C.rowLabel
    introLbl.Font=Enum.Font.GothamBold
    introLbl.TextSize=11
    introLbl.TextXAlignment=Enum.TextXAlignment.Left
    
    local introPillBg = Instance.new("Frame",introToggleRow)
    introPillBg.Size=UDim2.new(0,40,0,20)
    introPillBg.Position=UDim2.new(1,-52,0.5,-10)
    introPillBg.BackgroundColor3=State.introEnabled and C.pillOn or C.pillOff
    introPillBg.BorderSizePixel=0
    introPillBg.ZIndex=7
    mkCorner(introPillBg,10)
    mkStroke(introPillBg,C.pillBorder,1)
    
    local introDot = Instance.new("Frame",introPillBg)
    introDot.Size=UDim2.new(0,14,0,14)
    introDot.Position=State.introEnabled and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7)
    introDot.BackgroundColor3=State.introEnabled and C.dotOn or C.dotOff
    introDot.BorderSizePixel=0
    introDot.ZIndex=8
    mkCorner(introDot,7)
    
    local introClk = Instance.new("TextButton",introToggleRow)
    introClk.Size=UDim2.new(1,-52,1,0)
    introClk.BackgroundTransparency=1
    introClk.Text=""
    introClk.ZIndex=5
    introClk.BorderSizePixel=0
    introClk.MouseButton1Click:Connect(function()
        State.introEnabled = not State.introEnabled
        TS:Create(introPillBg,TweenInfo.new(0.18,Enum.EasingStyle.Quad),{BackgroundColor3=State.introEnabled and C.pillOn or C.pillOff}):Play()
        TS:Create(introDot,TweenInfo.new(0.18,Enum.EasingStyle.Back),{
            Position=State.introEnabled and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7),
            BackgroundColor3=State.introEnabled and C.dotOn or C.dotOff
        }):Play()
        task.spawn(function() if saveConfig then pcall(saveConfig) end end)
    end)
    
    local pClk2 = Instance.new("TextButton",introPillBg)
    pClk2.Size=UDim2.new(1,0,1,0)
    pClk2.BackgroundTransparency=1
    pClk2.Text=""
    pClk2.ZIndex=9
    pClk2.BorderSizePixel=0
    pClk2.MouseButton1Click:Connect(function()
        State.introEnabled = not State.introEnabled
        TS:Create(introPillBg,TweenInfo.new(0.18,Enum.EasingStyle.Quad),{BackgroundColor3=State.introEnabled and C.pillOn or C.pillOff}):Play()
        TS:Create(introDot,TweenInfo.new(0.18,Enum.EasingStyle.Back),{
            Position=State.introEnabled and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7),
            BackgroundColor3=State.introEnabled and C.dotOn or C.dotOff
        }):Play()
        task.spawn(function() if saveConfig then pcall(saveConfig) end end)
    end)
    
    makeGap(2)
    
    -- Music Selector Row
    local musicRow = Instance.new("Frame",currentPage)
    musicRow.Size=UDim2.new(1,0,0,65)
    musicRow.BackgroundColor3=C.cardBg
    musicRow.BorderSizePixel=0
    musicRow.LayoutOrder=LO()
    mkCorner(musicRow,7)
    mkStroke(musicRow,C.rowBorder,1)
    
    local musicLbl = Instance.new("TextLabel",musicRow)
    musicLbl.Size=UDim2.new(1,0,0,18)
    musicLbl.Position=UDim2.new(0,10,0,4)
    musicLbl.BackgroundTransparency=1
    musicLbl.Text="Select Music (1-9)"
    musicLbl.TextColor3=C.rowLabel
    musicLbl.Font=Enum.Font.GothamBold
    musicLbl.TextSize=10
    musicLbl.TextXAlignment=Enum.TextXAlignment.Left
    
    local musicDisplay = Instance.new("TextLabel",musicRow)
    musicDisplay.Size=UDim2.new(1,-20,0,22)
    musicDisplay.Position=UDim2.new(0,10,0,25)
    musicDisplay.BackgroundColor3=C.inputBg
    musicDisplay.BackgroundTransparency=0.5
    musicDisplay.Text="Music " .. State.selectedMusic
    musicDisplay.TextColor3=C.inputTxt
    musicDisplay.Font=Enum.Font.GothamBold
    musicDisplay.TextSize=12
    musicDisplay.TextXAlignment=Enum.TextXAlignment.Center
    mkCorner(musicDisplay,6)
    mkStroke(musicDisplay,C.inputBorder,1)
    
    local musicBtnFrame = Instance.new("Frame",musicRow)
    musicBtnFrame.Size=UDim2.new(1,-20,0,22)
    musicBtnFrame.Position=UDim2.new(0,10,0,25)
    musicBtnFrame.BackgroundTransparency=1
    
    -- Previous Button
    local prevBtn = Instance.new("TextButton",musicBtnFrame)
    prevBtn.Size=UDim2.new(0,30,1,0)
    prevBtn.Position=UDim2.new(0,0,0,0)
    prevBtn.BackgroundColor3=C.chipBg
    prevBtn.BorderSizePixel=0
    prevBtn.Text="â—„"
    prevBtn.TextColor3=C.rowLabel
    prevBtn.Font=Enum.Font.GothamBold
    prevBtn.TextSize=12
    mkCorner(prevBtn,4)
    prevBtn.MouseButton1Click:Connect(function()
        State.selectedMusic = State.selectedMusic - 1
        if State.selectedMusic < 1 then State.selectedMusic = #musicURLs end
        musicDisplay.Text = "Music " .. State.selectedMusic
        -- Download and preview
        task.spawn(function()
            local success = downloadSong(State.selectedMusic)
            if success then
                playPreview(State.selectedMusic)
            end
        end)
        task.spawn(function() if saveConfig then pcall(saveConfig) end end)
    end)
    
    -- Play Intro Button
    local playIntroBtn = Instance.new("TextButton",musicBtnFrame)
    playIntroBtn.Size=UDim2.new(0,80,1,0)
    playIntroBtn.Position=UDim2.new(0.5,-40,0,0)
    playIntroBtn.BackgroundColor3=Color3.fromRGB(70,80,160)
    playIntroBtn.BorderSizePixel=0
    playIntroBtn.Text="â–¶ PLAY"
    playIntroBtn.TextColor3=Color3.fromRGB(255,255,255)
    playIntroBtn.Font=Enum.Font.GothamBold
    playIntroBtn.TextSize=11
    mkCorner(playIntroBtn,4)
    playIntroBtn.MouseButton1Click:Connect(function()
        if not State.cachedSongs[State.selectedMusic] then
            task.spawn(function()
                local success = downloadSong(State.selectedMusic)
                if success then
                    playIntroAnimation()
                end
            end)
        else
            playIntroAnimation()
        end
    end)
    playIntroBtn.MouseEnter:Connect(function()
        TS:Create(playIntroBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(100,110,200)}):Play()
    end)
    playIntroBtn.MouseLeave:Connect(function()
        TS:Create(playIntroBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(70,80,160)}):Play()
    end)
    
    -- Next Button
    local nextBtn = Instance.new("TextButton",musicBtnFrame)
    nextBtn.Size=UDim2.new(0,30,1,0)
    nextBtn.Position=UDim2.new(1,-30,0,0)
    nextBtn.BackgroundColor3=C.chipBg
    nextBtn.BorderSizePixel=0
    nextBtn.Text="â–º"
    nextBtn.TextColor3=C.rowLabel
    nextBtn.Font=Enum.Font.GothamBold
    nextBtn.TextSize=12
    mkCorner(nextBtn,4)
    nextBtn.MouseButton1Click:Connect(function()
        State.selectedMusic = State.selectedMusic + 1
        if State.selectedMusic > #musicURLs then State.selectedMusic = 1 end
        musicDisplay.Text = "Music " .. State.selectedMusic
        task.spawn(function()
            local success = downloadSong(State.selectedMusic)
            if success then
                playPreview(State.selectedMusic)
            end
        end)
        task.spawn(function() if saveConfig then pcall(saveConfig) end end)
    end)
    
    -- Hide the music display text when buttons are shown
    musicDisplay.Visible = false
    
    makeGap(2)
    
    local musicInfo = Instance.new("TextLabel",currentPage)
    musicInfo.Size=UDim2.new(1,0,0,16)
    musicInfo.BackgroundTransparency=1
    musicInfo.Text="Songs are cached for smooth playback"
    musicInfo.TextColor3=C.rowSub
    musicInfo.Font=Enum.Font.Gotham
    musicInfo.TextSize=8
    musicInfo.TextXAlignment=Enum.TextXAlignment.Center
    musicInfo.LayoutOrder=LO()
    
    makeGap(8); makeSectionHeader("Speed Bypass"); makeGap(4)
    
    -- Speed Bypass Toggle
    local bypassToggle = makeToggleRow("Enable Speed Bypass",State.speedBypassEnabled,function(on)
        State.speedBypassEnabled = on
        if on then
            startSpeedBypass()
        else
            stopSpeedBypass()
        end
        task.spawn(function() if saveConfig then pcall(saveConfig) end end)
    end)
    
    makeGap(2)
    
    -- Speed Bypass Power Slider Row
    local powerRow = Instance.new("Frame",currentPage)
    powerRow.Size=UDim2.new(1,0,0,50)
    powerRow.BackgroundColor3=C.cardBg
    powerRow.BorderSizePixel=0
    powerRow.LayoutOrder=LO()
    mkCorner(powerRow,7)
    mkStroke(powerRow,C.rowBorder,1)
    
    local powerLbl = Instance.new("TextLabel",powerRow)
    powerLbl.Size=UDim2.new(0.4,0,0.4,0)
    powerLbl.Position=UDim2.new(0,8,0,2)
    powerLbl.BackgroundTransparency=1
    powerLbl.Text="Bypass Power"
    powerLbl.TextColor3=C.rowLabel
    powerLbl.Font=Enum.Font.GothamBold
    powerLbl.TextSize=11
    powerLbl.TextXAlignment=Enum.TextXAlignment.Left
    
    local powerValLbl = Instance.new("TextLabel",powerRow)
    powerValLbl.Size=UDim2.new(0.3,0,0.4,0)
    powerValLbl.Position=UDim2.new(0.4,0,0,2)
    powerValLbl.BackgroundTransparency=1
    powerValLbl.Text=tostring(State.speedBypassPower)
    powerValLbl.TextColor3=Color3.fromRGB(100,200,255)
    powerValLbl.Font=Enum.Font.GothamBold
    powerValLbl.TextSize=11
    powerValLbl.TextXAlignment=Enum.TextXAlignment.Center
    
    local powerSliderBg = Instance.new("Frame",powerRow)
    powerSliderBg.Size=UDim2.new(0.5,0,0.3,0)
    powerSliderBg.Position=UDim2.new(0.25,0,0.6,0)
    powerSliderBg.BackgroundColor3=Color3.fromRGB(40,40,50)
    powerSliderBg.BorderSizePixel=0
    mkCorner(powerSliderBg,3)
    
    local pct = (State.speedBypassPower - 10000) / 490000
    local powerSliderFill = Instance.new("Frame",powerSliderBg)
    powerSliderFill.Size=UDim2.new(pct,0,1,0)
    powerSliderFill.BackgroundColor3=Color3.fromRGB(255,200,0)
    powerSliderFill.BorderSizePixel=0
    mkCorner(powerSliderFill,3)
    
    local powerHandle = Instance.new("Frame",powerSliderBg)
    powerHandle.Size=UDim2.new(0,10,0,14)
    powerHandle.Position=UDim2.new(pct,-5,0.5,-7)
    powerHandle.BackgroundColor3=Color3.fromRGB(255,255,255)
    powerHandle.BorderSizePixel=0
    mkCorner(powerHandle,5)
    
    local powerSliderBtn = Instance.new("TextButton",powerSliderBg)
    powerSliderBtn.Size=UDim2.new(1,0,1,12)
    powerSliderBtn.Position=UDim2.new(0,0,0.5,-6)
    powerSliderBtn.BackgroundTransparency=1
    powerSliderBtn.Text=""
    
    local powerDragging = false
    powerSliderBtn.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            powerDragging = true
            local abs = powerSliderBg.AbsolutePosition
            local sz = powerSliderBg.AbsoluteSize
            local pct2 = math.clamp((inp.Position.X - abs.X) / sz.X, 0, 1)
            local val = math.floor(10000 + pct2 * 490000)
            val = math.floor(val / 5000) * 5000
            val = math.clamp(val, 5000, 500000)
            State.speedBypassPower = val
            powerValLbl.Text = tostring(val)
            powerSliderFill.Size = UDim2.new(pct2,0,1,0)
            powerHandle.Position = UDim2.new(pct2,-5,0.5,-7)
            if State.speedBypassEnabled then
                restartSpeedBypass()
            end
            task.spawn(function() if saveConfig then pcall(saveConfig) end end)
        end
    end)
    
    powerSliderBtn.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            powerDragging = false
        end
    end)
    
    UIS.InputChanged:Connect(function(inp)
        if not powerDragging then return end
        if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
            local abs = powerSliderBg.AbsolutePosition
            local sz = powerSliderBg.AbsoluteSize
            local pct2 = math.clamp((inp.Position.X - abs.X) / sz.X, 0, 1)
            local val = math.floor(10000 + pct2 * 490000)
            val = math.floor(val / 5000) * 5000
            val = math.clamp(val, 5000, 500000)
            State.speedBypassPower = val
            powerValLbl.Text = tostring(val)
            powerSliderFill.Size = UDim2.new(pct2,0,1,0)
            powerHandle.Position = UDim2.new(pct2,-5,0.5,-7)
            if State.speedBypassEnabled then
                restartSpeedBypass()
            end
        end
    end)
    
    makeGap(2)
    local powerInfo = Instance.new("TextLabel",currentPage)
    powerInfo.Size=UDim2.new(1,0,0,20)
    powerInfo.BackgroundTransparency=1
    powerInfo.Text="Higher power = more lag (5,000 - 500,000)"
    powerInfo.TextColor3=C.rowSub
    powerInfo.Font=Enum.Font.Gotham
    powerInfo.TextSize=9
    powerInfo.TextXAlignment=Enum.TextXAlignment.Center
    powerInfo.LayoutOrder=LO()
    
    makeGap(8)
    local fw=Instance.new("Frame",currentPage); fw.Size=UDim2.new(1,0,0,22); fw.BackgroundTransparency=1; fw.BorderSizePixel=0; fw.LayoutOrder=LO()
    local fl=Instance.new("TextLabel",fw); fl.Size=UDim2.new(1,0,1,0); fl.BackgroundTransparency=1; fl.Text="axonic hub  Â·  v2.0"; fl.TextColor3=Color3.fromRGB(55,55,55); fl.Font=Enum.Font.Gotham; fl.TextSize=9; fl.TextXAlignment=Enum.TextXAlignment.Center
end)

-- STEAL BAR
local stealBarGui=Instance.new("ScreenGui",PG); stealBarGui.Name="AxonicStealBar"; stealBarGui.ResetOnSpawn=false; stealBarGui.IgnoreGuiInset=true; stealBarGui.DisplayOrder=9
local stealBar=Instance.new("Frame",stealBarGui); stealBar.Size=UDim2.new(0,220,0,8); stealBar.Position=UDim2.new(0.5,-110,1,-60); stealBar.BackgroundTransparency=1; stealBar.BorderSizePixel=0; stealBar.Active=true; makeDraggable(stealBar)
local sbTrack=Instance.new("Frame",stealBar); sbTrack.Size=UDim2.new(1,0,1,0); sbTrack.Position=UDim2.new(0,0,0,0); sbTrack.BackgroundColor3=C.sbTrack; sbTrack.BackgroundTransparency=0.3; sbTrack.BorderSizePixel=0; mkCorner(sbTrack,4)
progressFill=Instance.new("Frame",sbTrack); progressFill.Size=UDim2.new(0,0,1,0); progressFill.BackgroundColor3=C.sbFill; progressFill.BorderSizePixel=0; mkCorner(progressFill,4)
fillGlow=Instance.new("Frame",sbTrack); fillGlow.Size=UDim2.new(0,0,1,0); fillGlow.BackgroundColor3=C.sbGlow; fillGlow.BackgroundTransparency=0.55; fillGlow.BorderSizePixel=0; mkCorner(fillGlow,4)
stealPctLbl=Instance.new("TextLabel",stealBar); stealPctLbl.Size=UDim2.new(0,1,0,1); stealPctLbl.BackgroundTransparency=1; stealPctLbl.TextTransparency=1; stealPctLbl.Text="0%"
radLbl=Instance.new("TextLabel",stealBar); radLbl.Size=UDim2.new(0,1,0,1); radLbl.BackgroundTransparency=1; radLbl.TextTransparency=1; radLbl.Text="Radius: "..Steal.StealRadius
local radWrap=Instance.new("Frame",stealBar); radWrap.Size=UDim2.new(0,1,0,1); radWrap.BackgroundTransparency=1
radTB=Instance.new("TextBox",radWrap); radTB.Size=UDim2.new(1,0,1,0); radTB.BackgroundTransparency=1; radTB.TextTransparency=1; radTB.Text=tostring(Steal.StealRadius); radTB.Font=Enum.Font.GothamBlack; radTB.TextSize=9; radTB.ClearTextOnFocus=false; radTB.ZIndex=10; radTB.FocusLost:Connect(function() local n=tonumber(radTB.Text); if n and n>=5 and n<=300 then Steal.StealRadius=math.floor(n); Steal.cachedPrompts={}; Steal.promptCacheTime=0 end; radTB.Text=tostring(Steal.StealRadius); radLbl.Text="Radius: "..Steal.StealRadius; if stealRadBox and not stealRadBox:IsFocused() then stealRadBox.Text=tostring(Steal.StealRadius) end; task.spawn(function() if saveConfig then pcall(saveConfig) end end) end)
local stealStatusLbl=Instance.new("TextLabel",stealBarGui); stealStatusLbl.Size=UDim2.new(0,220,0,16); stealStatusLbl.AnchorPoint=Vector2.new(0.5,1); stealStatusLbl.Position=UDim2.new(0.5,0,1,-64); stealStatusLbl.BackgroundTransparency=1; stealStatusLbl.Text=""; stealStatusLbl.TextColor3=Color3.fromRGB(255,255,255); stealStatusLbl.Font=Enum.Font.GothamBold; stealStatusLbl.TextSize=11; stealStatusLbl.TextXAlignment=Enum.TextXAlignment.Center; stealStatusLbl.TextTransparency=1
task.spawn(function() local dotStep=0; local dotSteps={"STEAL.","STEAL..","STEAL..."}; while true do task.wait(0.35); if State.isStealing then dotStep=dotStep%3+1; stealStatusLbl.Text=dotSteps[dotStep]; stealStatusLbl.TextTransparency=0 else stealStatusLbl.Text=""; stealStatusLbl.TextTransparency=1; dotStep=0 end end end)

-- MOBILE BUTTON BOX with AXONIC HUB background
local stackDefs = {
    {key="autoLeft", label="AUTO\nLEFT"},
    {key="autoRight", label="AUTO\nRIGHT"},
    {key="aimbot", label="AIMBOT"},
    {key="lagger", label="LAGGER\nMODE"},
    {key="drop", label="DROP\nBR"},
    {key="tpDown", label="TP\nDOWN"},
    {key="carrySpeed", label="CARRY\nSPD"},
    {key="instaReset", label="RESET\nINSTANT"},
}
local MOB_BTN_SIZE=48; local MOB_PAD=4; local MOB_COLS=2; local MOB_ROWS=math.ceil(#stackDefs/MOB_COLS); local BOX_W=MOB_COLS*(MOB_BTN_SIZE+MOB_PAD)+MOB_PAD; local BOX_H=MOB_ROWS*(MOB_BTN_SIZE+MOB_PAD)+MOB_PAD
local mobBox=Instance.new("Frame",gui); mobBox.Name="AxonicMobBox"; mobBox.Size=UDim2.new(0,BOX_W,0,BOX_H); mobBox.Position=UDim2.new(1,-(BOX_W+10),0.5,-(BOX_H/2)); mobBox.BackgroundColor3=C.winBg; mobBox.BackgroundTransparency=0; mobBox.BorderSizePixel=0; mobBox.Active=true; mobBox.ZIndex=15; mkCorner(mobBox,12); mkStroke(mobBox,C.winBorder,2); makeDraggable(mobBox)

-- AXONIC HUB Background Image
local mobBgImage = Instance.new("ImageLabel",mobBox)
mobBgImage.Size=UDim2.new(1,0,1,0)
mobBgImage.BackgroundTransparency=1
mobBgImage.Image=LOGO_ID
mobBgImage.ScaleType=Enum.ScaleType.Crop
mobBgImage.ImageTransparency=0.25
mobBgImage.ZIndex=1
mkCorner(mobBgImage,12)

-- Background Overlay
local mobBoxOverlay=Instance.new("Frame",mobBox)
mobBoxOverlay.Size=UDim2.new(1,0,1,0)
mobBoxOverlay.BackgroundColor3=Color3.fromRGB(0,0,0)
mobBoxOverlay.BackgroundTransparency=0.55
mobBoxOverlay.BorderSizePixel=0
mobBoxOverlay.ZIndex=2
mkCorner(mobBoxOverlay,12)

stackWrappers={}; stackBtnRefs={}
for i,def in ipairs(stackDefs) do
    local col=(i-1)%MOB_COLS; local row=math.floor((i-1)/MOB_COLS); local xPos=MOB_PAD+col*(MOB_BTN_SIZE+MOB_PAD); local yPos=MOB_PAD+row*(MOB_BTN_SIZE+MOB_PAD)
    local btnFrame=Instance.new("TextButton",mobBox); btnFrame.Name="MobBtn_"..def.key; btnFrame.Size=UDim2.new(0,MOB_BTN_SIZE,0,MOB_BTN_SIZE); btnFrame.Position=UDim2.new(0,xPos,0,yPos); btnFrame.BackgroundColor3=C.mobOff; btnFrame.BorderSizePixel=0; btnFrame.Text=""; btnFrame.ZIndex=16; btnFrame.AutoButtonColor=false; mkCorner(btnFrame,10); local bStroke=mkStroke(btnFrame,C.mobStroke,1.5)
    local btnLbl=Instance.new("TextLabel",btnFrame); btnLbl.Size=UDim2.new(1,-4,1,0); btnLbl.Position=UDim2.new(0,2,0,0); btnLbl.BackgroundTransparency=1; btnLbl.Text=def.label; btnLbl.TextColor3=C.mobText; btnLbl.Font=Enum.Font.GothamBlack; btnLbl.TextSize=9; btnLbl.TextWrapped=true; btnLbl.TextXAlignment=Enum.TextXAlignment.Center; btnLbl.TextYAlignment=Enum.TextYAlignment.Center; btnLbl.ZIndex=18; btnLbl.TextStrokeTransparency=0.3; btnLbl.TextStrokeColor3=Color3.new(0,0,0)
    stackWrappers[def.key]=btnFrame
    local btnState=false; local function setOn(on) btnState=on; TS:Create(btnFrame,TweenInfo.new(0.15),{BackgroundColor3=on and C.mobOn or C.mobOff}):Play(); TS:Create(bStroke,TweenInfo.new(0.12),{Color=on and C.mobStrokeOn or C.mobStroke}):Play(); btnLbl.TextColor3=on and C.mobTextOn or C.mobText end
    stackBtnRefs[def.key]={setOn=setOn}
    btnFrame.MouseButton1Down:Connect(function() TS:Create(btnFrame,TweenInfo.new(0.05),{BackgroundColor3=Color3.fromRGB(180,180,180)}):Play() end)
    btnFrame.MouseButton1Up:Connect(function() task.delay(0.06,function() TS:Create(btnFrame,TweenInfo.new(0.1),{BackgroundColor3=btnState and C.mobOn or C.mobOff}):Play() end) end)
    btnFrame.MouseButton1Click:Connect(function()
        if _anyKeyListening then return end
        if def.key=="instaReset" then performInstantReset(); TS:Create(btnFrame,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(0,255,0)}):Play(); task.delay(0.15,function() TS:Create(btnFrame,TweenInfo.new(0.15),{BackgroundColor3=btnState and C.mobOn or C.mobOff}):Play() end); return end
        if def.key=="tpDown" then TS:Create(btnFrame,TweenInfo.new(0.05),{BackgroundColor3=C.mobOn}):Play(); task.delay(0.3,function() TS:Create(btnFrame,TweenInfo.new(0.1),{BackgroundColor3=C.mobOff}):Play() end); doTpDown(); return end
        if def.key=="carrySpeed" then State.speedToggled=not State.speedToggled; setOn(State.speedToggled); return end
        if def.key=="lagger" then 
            State.laggerEnabled=not State.laggerEnabled
            setOn(State.laggerEnabled)
            if State.laggerEnabled then
                State._prevCarry=State.carrySpeed
                State._prevSpeed=State.speedToggled
                State.speedToggled=false
                if stackBtnRefs.carrySpeed then stackBtnRefs.carrySpeed.setOn(false) end
                if carryBox then carryBox.Text=tostring(State.laggerSpeed) end
            else
                State.carrySpeed=State._prevCarry or 30
                State.speedToggled=State._prevSpeed or false
                if carryBox then carryBox.Text=tostring(State.carrySpeed) end
                if stackBtnRefs.carrySpeed then stackBtnRefs.carrySpeed.setOn(State.speedToggled) end
            end
            return
        end
        local ns=not btnState; setOn(ns)
        if def.key=="autoLeft" then State.autoLeftEnabled=ns; if ns and State.batAimbotToggled then State.batAimbotToggled=false; stopBatAimbot(); if stackBtnRefs.aimbot then stackBtnRefs.aimbot.setOn(false) end end; if ns then startAutoLeft() else stopAutoLeft() end
        elseif def.key=="autoRight" then State.autoRightEnabled=ns; if ns and State.batAimbotToggled then State.batAimbotToggled=false; stopBatAimbot(); if stackBtnRefs.aimbot then stackBtnRefs.aimbot.setOn(false) end end; if ns then startAutoRight() else stopAutoRight() end
        elseif def.key=="aimbot" then 
            if not ns then 
                pcall(stopBatAimbot)
            else
                if State.autoLeftEnabled then State.autoLeftEnabled=false; stopAutoLeft(); if stackBtnRefs.autoLeft then stackBtnRefs.autoLeft.setOn(false) end end
                if State.autoRightEnabled then State.autoRightEnabled=false; stopAutoRight(); if stackBtnRefs.autoRight then stackBtnRefs.autoRight.setOn(false) end end
                pcall(startBatAimbot)
            end
        elseif def.key=="drop" then if ns then runDropBrainrot() else stopDropBrainrot() end
        end
    end)
end

-- FEATURE FUNCTIONS
local function resetProgressBar() stealPctLbl.Text="0%"; TS:Create(progressFill,TweenInfo.new(0.2),{Size=UDim2.new(0,0,1,0)}):Play(); TS:Create(fillGlow,TweenInfo.new(0.2),{Size=UDim2.new(0,0,1,0)}):Play() end
doTpDown=function() pcall(function() local c=LP.Character; if not c then return end; local root=c:FindFirstChild("HumanoidRootPart"); if not root then return end; local rp=RaycastParams.new(); rp.FilterDescendantsInstances={c}; rp.FilterType=Enum.RaycastFilterType.Exclude; local res=workspace:Raycast(root.Position,Vector3.new(0,-1000,0),rp); if res then root.CFrame=CFrame.new(res.Position+Vector3.new(0,root.Size.Y/2+0.5,0)); root.AssemblyLinearVelocity=Vector3.zero end end) end

-- DROP BRAINROT
local _dropConns={}
runDropBrainrot=function() if State.dropEnabled then return end; State.dropEnabled=true; if stackBtnRefs.drop then stackBtnRefs.drop.setOn(true) end; task.spawn(function() local colConn=RunService.Stepped:Connect(function() if not State.dropEnabled then return end; for _,p in ipairs(Players:GetPlayers()) do if p~=LP and p.Character then for _,part in ipairs(p.Character:GetChildren()) do if part:IsA("BasePart") then part.CanCollide=false end end end end end); table.insert(_dropConns,colConn); task.spawn(function() while State.dropEnabled do RunService.Heartbeat:Wait(); local c=LP.Character; local root=c and c:FindFirstChild("HumanoidRootPart"); if not root then continue end; local vel=root.Velocity; root.Velocity=vel*10000+Vector3.new(0,10000,0); RunService.RenderStepped:Wait(); if root and root.Parent then root.Velocity=vel end; RunService.Stepped:Wait(); if root and root.Parent then root.Velocity=vel+Vector3.new(0,0.1,0) end end end); task.wait(DROP_AUTO_OFF_DELAY); stopDropBrainrot() end) end
stopDropBrainrot=function() State.dropEnabled=false; for _,cn in ipairs(_dropConns) do pcall(function() cn:Disconnect() end) end; _dropConns={}; if stackBtnRefs.drop then stackBtnRefs.drop.setOn(false) end end

-- BAT COUNTER
local BAT_SLAP_LIST={"Bat","Slap","Iron Slap","Gold Slap","Diamond Slap","Emerald Slap","Ruby Slap","Dark Matter Slap","Flame Slap","Nuclear Slap","Galaxy Slap","Glitched Slap"}
local function findBatForCounter() local c=LP.Character; if not c then return nil end; local bp=LP:FindFirstChildOfClass("Backpack"); for _,name in ipairs(BAT_SLAP_LIST) do local t=c:FindFirstChild(name) or (bp and bp:FindFirstChild(name)); if t then return t end end; return nil end
local function swingBatForCounter(bat,char) local hum2=char:FindFirstChildOfClass("Humanoid"); if bat.Parent~=char then if hum2 then pcall(function() hum2:EquipTool(bat) end) end; task.wait(0.05) end; local remote=bat:FindFirstChildOfClass("RemoteEvent") or bat:FindFirstChildOfClass("RemoteFunction"); if remote and remote:IsA("RemoteEvent") then pcall(function() remote:FireServer() end); task.wait(0.15); pcall(function() remote:FireServer() end) else pcall(function() bat:Activate() end); task.wait(0.15); pcall(function() bat:Activate() end) end end
startBatCounter=function() if Conns.batCounter then return end; Conns.batCounter=RunService.Heartbeat:Connect(function() if not State.batCounterEnabled then return end; if State.batCounterDebounce then return end; local char=LP.Character; if not char then return end; local hum2=char:FindFirstChildOfClass("Humanoid"); if not hum2 then return end; local st=hum2:GetState(); if st==Enum.HumanoidStateType.Physics or st==Enum.HumanoidStateType.Ragdoll or st==Enum.HumanoidStateType.FallingDown then State.batCounterDebounce=true; task.spawn(function() local bat=findBatForCounter(); if bat then swingBatForCounter(bat,char) end; task.wait(0.5); State.batCounterDebounce=false end) end end) end
stopBatCounter=function() if Conns.batCounter then Conns.batCounter:Disconnect(); Conns.batCounter=nil end; State.batCounterDebounce=false end

-- MEDUSA COUNTER
local function findMedusa() local c=LP.Character; if not c then return nil end; for _,t in ipairs(c:GetChildren()) do if t:IsA("Tool") then local n=t.Name:lower(); if n:find("medusa") or n:find("head") or n:find("stone") then return t end end end; local bp=LP:FindFirstChild("Backpack"); if bp then for _,t in ipairs(bp:GetChildren()) do if t:IsA("Tool") then local n=t.Name:lower(); if n:find("medusa") or n:find("head") or n:find("stone") then return t end end end end; return nil end
local function useMedusaCounter() if State.medusaDebounce then return end; if tick()-State.medusaLastUsed<MEDUSA_COOLDOWN then return end; local c=LP.Character; if not c then return end; State.medusaDebounce=true; local med=findMedusa(); if not med then State.medusaDebounce=false; return end; if med.Parent~=c then local hum2=c:FindFirstChildOfClass("Humanoid"); if hum2 then hum2:EquipTool(med) end end; pcall(function() med:Activate() end); State.medusaLastUsed=tick(); State.medusaDebounce=false end
local function onAnchorChanged(part) return part:GetPropertyChangedSignal("Anchored"):Connect(function() if part.Anchored and part.Transparency==1 then useMedusaCounter() end end) end
setupMedusaCounter=function(char) stopMedusaCounter(); if not char then return end; for _,part in ipairs(char:GetDescendants()) do if part:IsA("BasePart") then table.insert(Conns.anchor,onAnchorChanged(part)) end end; table.insert(Conns.anchor,char.DescendantAdded:Connect(function(part) if part:IsA("BasePart") then table.insert(Conns.anchor,onAnchorChanged(part)) end end)) end
stopMedusaCounter=function() for _,c2 in pairs(Conns.anchor) do pcall(function() c2:Disconnect() end) end; Conns.anchor={} end

-- AUTO LEFT / RIGHT
startAutoLeft=function() if Conns.autoLeft then Conns.autoLeft:Disconnect() end; State.autoLeftPhase=1; Conns.autoLeft=RunService.Heartbeat:Connect(function() if not State.autoLeftEnabled then return end; local c=LP.Character; if not c then return end; local root=c:FindFirstChild("HumanoidRootPart"); local hum2=c:FindFirstChildOfClass("Humanoid"); if not root or not hum2 then return end; local spd=State.normalSpeed; if State.autoLeftPhase==1 then local tgt=Vector3.new(POS.L1.X,root.Position.Y,POS.L1.Z); if (tgt-root.Position).Magnitude<1 then State.autoLeftPhase=2 end; local d=(POS.L1-root.Position); local mv=Vector3.new(d.X,0,d.Z).Unit; hum2:Move(mv,false); root.AssemblyLinearVelocity=Vector3.new(mv.X*spd,root.AssemblyLinearVelocity.Y,mv.Z*spd) elseif State.autoLeftPhase==2 then local tgt=Vector3.new(POS.L2.X,root.Position.Y,POS.L2.Z); if (tgt-root.Position).Magnitude<1 then hum2:Move(Vector3.zero,false); root.AssemblyLinearVelocity=Vector3.zero; State.autoLeftEnabled=false; if Conns.autoLeft then Conns.autoLeft:Disconnect(); Conns.autoLeft=nil end; State.autoLeftPhase=1; if stackBtnRefs.autoLeft then stackBtnRefs.autoLeft.setOn(false) end; return end; local d=(POS.L2-root.Position); local mv=Vector3.new(d.X,0,d.Z).Unit; hum2:Move(mv,false); root.AssemblyLinearVelocity=Vector3.new(mv.X*spd,root.AssemblyLinearVelocity.Y,mv.Z*spd) end end) end
stopAutoLeft=function() if Conns.autoLeft then Conns.autoLeft:Disconnect(); Conns.autoLeft=nil end; State.autoLeftPhase=1; local c=LP.Character; if c then local hum2=c:FindFirstChildOfClass("Humanoid"); if hum2 then hum2:Move(Vector3.zero,false) end end; if stackBtnRefs.autoLeft then stackBtnRefs.autoLeft.setOn(false) end end
startAutoRight=function() if Conns.autoRight then Conns.autoRight:Disconnect() end; State.autoRightPhase=1; Conns.autoRight=RunService.Heartbeat:Connect(function() if not State.autoRightEnabled then return end; local c=LP.Character; if not c then return end; local root=c:FindFirstChild("HumanoidRootPart"); local hum2=c:FindFirstChildOfClass("Humanoid"); if not root or not hum2 then return end; local spd=State.normalSpeed; if State.autoRightPhase==1 then local tgt=Vector3.new(POS.R1.X,root.Position.Y,POS.R1.Z); if (tgt-root.Position).Magnitude<1 then State.autoRightPhase=2 end; local d=(POS.R1-root.Position); local mv=Vector3.new(d.X,0,d.Z).Unit; hum2:Move(mv,false); root.AssemblyLinearVelocity=Vector3.new(mv.X*spd,root.AssemblyLinearVelocity.Y,mv.Z*spd) elseif State.autoRightPhase==2 then local tgt=Vector3.new(POS.R2.X,root.Position.Y,POS.R2.Z); if (tgt-root.Position).Magnitude<1 then hum2:Move(Vector3.zero,false); root.AssemblyLinearVelocity=Vector3.zero; State.autoRightEnabled=false; if Conns.autoRight then Conns.autoRight:Disconnect(); Conns.autoRight=nil end; State.autoRightPhase=1; if stackBtnRefs.autoRight then stackBtnRefs.autoRight.setOn(false) end; return end; local d=(POS.R2-root.Position); local mv=Vector3.new(d.X,0,d.Z).Unit; hum2:Move(mv,false); root.AssemblyLinearVelocity=Vector3.new(mv.X*spd,root.AssemblyLinearVelocity.Y,mv.Z*spd) end end) end
stopAutoRight=function() if Conns.autoRight then Conns.autoRight:Disconnect(); Conns.autoRight=nil end; State.autoRightPhase=1; local c=LP.Character; if c then local hum2=c:FindFirstChildOfClass("Humanoid"); if hum2 then hum2:Move(Vector3.zero,false) end end; if stackBtnRefs.autoRight then stackBtnRefs.autoRight.setOn(false) end end

-- UNWALK
local unwalkAnimateRef=nil
local function startUnwalk() local c=LP.Character; if not c then return end; local hum2=c:FindFirstChildOfClass("Humanoid"); if hum2 then pcall(function() for _,track in ipairs(hum2:GetPlayingAnimationTracks()) do track:Stop(0) end end) end; local anim=c:FindFirstChild("Animate"); if anim and anim:IsA("LocalScript") then anim.Disabled=true; unwalkAnimateRef=anim end; if Conns.unwalk then Conns.unwalk:Disconnect() end; Conns.unwalk=RunService.Heartbeat:Connect(function() if not State.unwalkEnabled then return end; local c2=LP.Character; if not c2 then return end; local hum3=c2:FindFirstChildOfClass("Humanoid"); if hum3 then pcall(function() for _,track in ipairs(hum3:GetPlayingAnimationTracks()) do track:Stop(0) end end) end end) end
local function stopUnwalk() if Conns.unwalk then Conns.unwalk:Disconnect(); Conns.unwalk=nil end; local c=LP.Character; if c and unwalkAnimateRef and unwalkAnimateRef.Parent==c then unwalkAnimateRef.Disabled=false end; unwalkAnimateRef=nil end

-- FPS BOOST
applyFPSBoost=function() pcall(function() setfpscap(999999999) end); local function pO(v) pcall(function() if v:IsA("MeshPart") then v.CastShadow=false; v.RenderFidelity=Enum.RenderFidelity.Performance elseif v:IsA("BasePart") then v.CastShadow=false; v.Material=Enum.Material.Plastic; v.Reflectance=0 elseif v:IsA("Decal") or v:IsA("Texture") then v.Transparency=1 elseif v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") or v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") then v.Enabled=false end end) end; for _,v in pairs(workspace:GetDescendants()) do pO(v) end; pcall(function() local L=game:GetService("Lighting"); for _,v in pairs(L:GetDescendants()) do pcall(function() if v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("ColorCorrectionEffect") then v.Enabled=false end end) end; L.GlobalShadows=false; L.FogEnd=9e9; L.Brightness=0 end); workspace.DescendantAdded:Connect(function(v) if State.fpsBoostEnabled then task.spawn(pO,v) end end) end

-- AUTO STEAL
local function isMyPlotByName(pn) local ct=tick(); if Steal.plotCache[pn] and (ct-(Steal.plotCacheTime[pn] or 0))<PLOT_CACHE_DURATION then return Steal.plotCache[pn] end; local plots=workspace:FindFirstChild("Plots"); if not plots then Steal.plotCache[pn]=false; Steal.plotCacheTime[pn]=ct; return false end; local plot=plots:FindFirstChild(pn); if not plot then Steal.plotCache[pn]=false; Steal.plotCacheTime[pn]=ct; return false end; local sign=plot:FindFirstChild("PlotSign"); if sign then local yb=sign:FindFirstChild("YourBase"); if yb and yb:IsA("BillboardGui") then local r=yb.Enabled==true; Steal.plotCache[pn]=r; Steal.plotCacheTime[pn]=ct; return r end end; Steal.plotCache[pn]=false; Steal.plotCacheTime[pn]=ct; return false end
local function findNearestPrompt() local c=LP.Character; if not c then return nil end; local root=c:FindFirstChild("HumanoidRootPart"); if not root then return nil end; local ct=tick(); if ct-Steal.promptCacheTime<PROMPT_CACHE_REFRESH and #Steal.cachedPrompts>0 then local np,nd=nil,math.huge; for _,data in ipairs(Steal.cachedPrompts) do if data.spawn then local dist=(data.spawn.Position-root.Position).Magnitude; if dist<=Steal.StealRadius and dist<nd then np=data.prompt; nd=dist end end end; if np then return np end end; Steal.cachedPrompts={}; Steal.promptCacheTime=ct; local plots=workspace:FindFirstChild("Plots"); if not plots then return nil end; local np,nd=nil,math.huge; for _,plot in ipairs(plots:GetChildren()) do if isMyPlotByName(plot.Name) then continue end; local pods=plot:FindFirstChild("AnimalPodiums"); if not pods then continue end; for _,pod in ipairs(pods:GetChildren()) do pcall(function() local base=pod:FindFirstChild("Base"); local sp=base and base:FindFirstChild("Spawn"); if sp then local att=sp:FindFirstChild("PromptAttachment"); if att then for _,child in ipairs(att:GetChildren()) do if child:IsA("ProximityPrompt") then local dist=(sp.Position-root.Position).Magnitude; table.insert(Steal.cachedPrompts,{prompt=child,spawn=sp}); if dist<=Steal.StealRadius and dist<nd then np=child; nd=dist end; break end end end end end) end end; return np end
local function executeSteal(prompt) local ct=tick(); if ct-State.lastStealTick<STEAL_COOLDOWN then return end; if State.isStealing then return end; if not Steal.Data[prompt] then Steal.Data[prompt]={hold={},trigger={},ready=true}; pcall(function() if getconnections then for _,c2 in ipairs(getconnections(prompt.PromptButtonHoldBegan)) do if c2.Function then table.insert(Steal.Data[prompt].hold,c2.Function) end end; for _,c2 in ipairs(getconnections(prompt.Triggered)) do if c2.Function then table.insert(Steal.Data[prompt].trigger,c2.Function) end end else Steal.Data[prompt].useFallback=true end end) end; local data=Steal.Data[prompt]; if not data.ready then return end; data.ready=false; State.isStealing=true; State.stealStartTime=ct; State.lastStealTick=ct; if Conns.progress then Conns.progress:Disconnect() end; Conns.progress=RunService.Heartbeat:Connect(function() if not State.isStealing then Conns.progress:Disconnect(); return end; local prog=math.clamp((tick()-State.stealStartTime)/Steal.StealDuration,0,1); TS:Create(progressFill,TweenInfo.new(0.05),{Size=UDim2.new(prog,0,1,0)}):Play(); TS:Create(fillGlow,TweenInfo.new(0.05),{Size=UDim2.new(prog,0,1,0)}):Play(); stealPctLbl.Text=math.floor(prog*100).."%" end); task.spawn(function() local ok=false; pcall(function() if not data.useFallback then for _,fn in ipairs(data.hold) do task.spawn(fn) end; task.wait(Steal.StealDuration); for _,fn in ipairs(data.trigger) do task.spawn(fn) end; ok=true end end); if not ok and fireproximityprompt then pcall(function() fireproximityprompt(prompt); ok=true end) end; if not ok then pcall(function() prompt:InputHoldBegin(); task.wait(Steal.StealDuration); prompt:InputHoldEnd() end) end; task.wait(Steal.StealDuration*0.3); if Conns.progress then Conns.progress:Disconnect() end; resetProgressBar(); task.wait(0.05); data.ready=true; State.isStealing=false end) end
startAutoSteal=function() if Conns.autoSteal then return end; Conns.autoSteal=RunService.Heartbeat:Connect(function() if not Steal.AutoStealEnabled or State.isStealing then return end; local p=findNearestPrompt(); if p then executeSteal(p) end end) end
stopAutoSteal=function() if Conns.autoSteal then Conns.autoSteal:Disconnect(); Conns.autoSteal=nil end; State.isStealing=false; State.lastStealTick=0; Steal.plotCache={}; Steal.plotCacheTime={}; Steal.cachedPrompts={}; resetProgressBar() end

-- SAVE / LOAD CONFIG
local CONFIG_FILE="AxonicHubConfig.json"
local _isfile=isfile or function() return false end
local _readfile=readfile or function() return nil end
local _writefile=writefile or function() end

saveConfig=function() 
    local cfg={
        normalSpeed=State.normalSpeed,
        carrySpeed=State.carrySpeed,
        laggerSpeed=State.laggerSpeed,
        stealRadius=Steal.StealRadius,
        stealDuration=Steal.StealDuration,
        uiScale=uiScaleObj_inst and uiScaleObj_inst.Scale or 1.0,
        stackButtonsHidden=State.stackButtonsHidden,
        infJump=State.infJumpEnabled,
        holdInfJump=State.holdInfJumpEnabled,
        antiRagdollEnabled=State.antiRagdollEnabled,
        fpsBoost=State.fpsBoostEnabled,
        medusaCounter=State.medusaCounterEnabled,
        batCounter=State.batCounterEnabled,
        autoStealEnabled=Steal.AutoStealEnabled,
        autoSwing=State.autoSwingEnabled,
        speedToggled=State.speedToggled,
        laggerEnabled=State.laggerEnabled,
        unwalkEnabled=State.unwalkEnabled,
        autoTPDownEnabled=State.autoTPDownEnabled,
        autoTPDownY=math.abs(State.autoTPDownY),
        tracersEnabled=State.tracersEnabled,
        instantResetOnMedusa=State.instantResetOnMedusa,
        batAimbotSpeed=State.batAimbotSpeed,
        fovOn=State.fovOn,
        galaxyOn=State.galaxyOn,
        antiBatOn=State.antiBatOn,
        simpleFovEnabled=State.simpleFovEnabled,
        simpleFovValue=State.simpleFovValue,
        currentSkyTheme=State.currentSkyTheme,
        speedBypassEnabled=State.speedBypassEnabled,
        speedBypassPower=State.speedBypassPower,
        antiBatBypassEnabled=State.antiBatBypassEnabled,
        batThreshold=State.batThreshold,
        capSpeed=State.capSpeed,
        introEnabled=State.introEnabled,
        selectedMusic=State.selectedMusic,
        ragdollTimerEnabled=State.ragdollTimerEnabled,
        autoExitDuelEnabled=State.autoExitDuelEnabled,
        keybinds={},
        controllerKeybinds={}
    }
    for k,v in pairs(State.keybinds) do cfg.keybinds[k]=tostring(v) end
    for k,v in pairs(State.controllerKeybinds) do cfg.controllerKeybinds[k]=tostring(v) end
    local ok,encoded=pcall(function() return HS:JSONEncode(cfg) end)
    if ok then pcall(function() _writefile(CONFIG_FILE,encoded) end) end
end

loadConfig=function() 
    local hasFile=false; pcall(function() hasFile=_isfile(CONFIG_FILE) end)
    if not hasFile then return end
    local raw; pcall(function() raw=_readfile(CONFIG_FILE) end)
    if not raw then return end
    local cfg; local ok2=pcall(function() cfg=HS:JSONDecode(raw) end)
    if not ok2 or not cfg then return end
    if cfg.normalSpeed then State.normalSpeed=cfg.normalSpeed; if normalBox then normalBox.Text=tostring(cfg.normalSpeed) end end
    if cfg.carrySpeed then State.carrySpeed=cfg.carrySpeed; if carryBox then carryBox.Text=tostring(cfg.carrySpeed) end end
    if cfg.laggerSpeed then State.laggerSpeed=cfg.laggerSpeed; if laggerBox then laggerBox.Text=tostring(cfg.laggerSpeed) end end
    if cfg.stealRadius then Steal.StealRadius=cfg.stealRadius end
    if cfg.stealDuration then Steal.StealDuration=cfg.stealDuration end
    if cfg.uiScale and uiScaleObj_inst then uiScaleObj_inst.Scale=cfg.uiScale end
    if cfg.stackButtonsHidden then 
        State.stackButtonsHidden=true
        for _,w in pairs(stackWrappers) do w.Visible=false end
        if mobBox then mobBox.Visible=false end
        if mobBoxOverlay then mobBoxOverlay.Visible=false end
        if mobBgImage then mobBgImage.Visible=false end
        if setHideButtonsToggle then setHideButtonsToggle(true) end
    end
    if cfg.autoTPDownEnabled then State.autoTPDownEnabled=true; if setAutoTPDownToggle then setAutoTPDownToggle(true) end; startAutoTPDown() end
    if cfg.autoTPDownY then State.autoTPDownY=-math.abs(cfg.autoTPDownY) end
    if cfg.autoStealEnabled then Steal.AutoStealEnabled=true; if setInstaGrab then setInstaGrab(true) end; pcall(startAutoSteal) end
    if cfg.infJump or cfg.holdInfJump then State.infJumpEnabled=true; State.holdInfJumpEnabled=true; if setInfJump then setInfJump(true) end; startHoldInfJump() end
    if cfg.antiRagdollEnabled then 
        State.antiRagdollEnabled=cfg.antiRagdollEnabled
        if State.antiRagdollEnabled then 
            EnableAntiRagdoll() 
        else 
            DisableAntiRagdoll() 
        end
    end
    if cfg.fpsBoost then State.fpsBoostEnabled=true; if setFps then setFps(true) end; applyFPSBoost() end
    if cfg.medusaCounter then State.medusaCounterEnabled=true; if setMedusaCounter then setMedusaCounter(true) end; setupMedusaCounter(LP.Character) end
    if cfg.batCounter then State.batCounterEnabled=true; if setBatCounter then setBatCounter(true) end; startBatCounter() end
    if cfg.autoSwing then State.autoSwingEnabled=true; if setAutoSwing then setAutoSwing(true) end end
    if cfg.unwalkEnabled then State.unwalkEnabled=true; if setUnwalkToggle then setUnwalkToggle(true) end; task.delay(0.5,startUnwalk) end
    if cfg.speedToggled~=nil then State.speedToggled=cfg.speedToggled; if stackBtnRefs.carrySpeed then stackBtnRefs.carrySpeed.setOn(cfg.speedToggled) end end
    if cfg.laggerEnabled~=nil then State.laggerEnabled=cfg.laggerEnabled end
    if cfg.tracersEnabled~=nil then State.tracersEnabled=cfg.tracersEnabled end
    if cfg.instantResetOnMedusa~=nil then State.instantResetOnMedusa=cfg.instantResetOnMedusa end
    if cfg.batAimbotSpeed then State.batAimbotSpeed=cfg.batAimbotSpeed end
    if cfg.fovOn~=nil then State.fovOn=cfg.fovOn; if State.fovOn then camera.FieldOfView=110 else camera.FieldOfView=70 end end
    if cfg.galaxyOn~=nil then State.galaxyOn=cfg.galaxyOn; updateGalaxy() end
    if cfg.antiBatOn~=nil then State.antiBatOn=cfg.antiBatOn end
    if cfg.simpleFovEnabled~=nil then State.simpleFovEnabled=cfg.simpleFovEnabled; if State.simpleFovEnabled then toggleSimpleFOV() end end
    if cfg.simpleFovValue then State.simpleFovValue=cfg.simpleFovValue; setSimpleFOV(State.simpleFovValue) end
    if cfg.currentSkyTheme then State.currentSkyTheme=cfg.currentSkyTheme; CandyApplyCustomSky(State.currentSkyTheme) end
    if cfg.speedBypassEnabled~=nil then 
        State.speedBypassEnabled=cfg.speedBypassEnabled
        if State.speedBypassEnabled then startSpeedBypass() end
    end
    if cfg.speedBypassPower then State.speedBypassPower=cfg.speedBypassPower end
    if cfg.antiBatBypassEnabled~=nil then
        State.antiBatBypassEnabled=cfg.antiBatBypassEnabled
        if State.antiBatBypassEnabled then startAntiBatBypass() end
    end
    if cfg.batThreshold then State.batThreshold=cfg.batThreshold end
    if cfg.capSpeed then State.capSpeed=cfg.capSpeed end
    if cfg.introEnabled~=nil then State.introEnabled=cfg.introEnabled end
    if cfg.selectedMusic then State.selectedMusic=cfg.selectedMusic end
    if cfg.ragdollTimerEnabled~=nil then
        State.ragdollTimerEnabled=cfg.ragdollTimerEnabled
        if State.ragdollTimerEnabled then
            startRagdollTimer()
        else
            stopRagdollTimer()
        end
    end
    if cfg.autoExitDuelEnabled~=nil then
        State.autoExitDuelEnabled=cfg.autoExitDuelEnabled
        if State.autoExitDuelEnabled then
            enableAutoExitDuel()
        end
    end
    if cfg.keybinds then 
        for k,v in pairs(cfg.keybinds) do 
            State.keybinds[k]=Enum.KeyCode[v] or Enum.KeyCode.Unknown 
        end
    end
    if cfg.controllerKeybinds then
        for k,v in pairs(cfg.controllerKeybinds) do
            State.controllerKeybinds[k]=Enum.KeyCode[v] or Enum.KeyCode.Unknown
        end
    end
    startKeybindListen()
end

-- CHARACTER SETUP
local function setupChar(char)
    task.wait(0.1)
    h=char:WaitForChild("Humanoid",5); hrp=char:WaitForChild("HumanoidRootPart",5)
    if not h or not hrp then return end
    local head=char:FindFirstChild("Head")
    if head then
        local oldBB=head:FindFirstChild("AxonicBB"); if oldBB then oldBB:Destroy() end
        local bb=Instance.new("BillboardGui",head); bb.Name="AxonicBB"; bb.Size=UDim2.new(0,180,0,56); bb.StudsOffset=Vector3.new(0,3.2,0); bb.AlwaysOnTop=true
        local speedBillLbl=Instance.new("TextLabel",bb); speedBillLbl.Name="SpeedBillLbl"; speedBillLbl.Size=UDim2.new(1,0,0,28); speedBillLbl.BackgroundTransparency=1; speedBillLbl.Text="0.0"; speedBillLbl.TextColor3=Color3.fromRGB(255,255,255); speedBillLbl.Font=Enum.Font.GothamBlack; speedBillLbl.TextScaled=true; speedBillLbl.TextStrokeTransparency=0.1; speedBillLbl.TextStrokeColor3=Color3.new(0,0,0)
        local lbl2=Instance.new("TextLabel",bb); lbl2.Size=UDim2.new(1,0,0,18); lbl2.Position=UDim2.new(0,0,0,32); lbl2.BackgroundTransparency=1; lbl2.Text="/axonic"; lbl2.TextColor3=Color3.fromRGB(200,200,200); lbl2.Font=Enum.Font.GothamBold; lbl2.TextScaled=true; lbl2.TextStrokeTransparency=0.1; lbl2.TextStrokeColor3=Color3.new(0,0,0)
    end
    if Conns.unwalk then Conns.unwalk:Disconnect(); Conns.unwalk=nil end; unwalkAnimateRef=nil
    if State.unwalkEnabled then task.wait(0.3); startUnwalk() end
    
    -- Handle V1 Anti-Ragdoll
    DisableAntiRagdoll()
    if State.antiRagdollEnabled then
        task.wait(0.5)
        EnableAntiRagdoll()
    end
    
    -- Handle Ragdoll Timer
    if State.ragdollTimerEnabled then
        task.wait(0.5)
        setupRagdollBillboard(char)
    end
    
    if State.medusaCounterEnabled then setupMedusaCounter(char) end
    if State.batAimbotToggled then 
        stopBatAimbot() 
        task.wait(0.2) 
        pcall(startBatAimbot) 
    end
    if State.batCounterEnabled then task.wait(0.3); startBatCounter() end
    if State.holdInfJumpEnabled then startHoldInfJump() end
    setupMedusaDetection(char)
    -- Restart speed bypass on respawn
    if State.speedBypassEnabled then
        task.wait(0.5)
        restartSpeedBypass()
    end
    -- Restart anti bat bypass on respawn
    if State.antiBatBypassEnabled then
        task.wait(0.5)
        restartAntiBatBypass()
    end
end

LP.CharacterAdded:Connect(setupChar)
if LP.Character then task.spawn(function() setupChar(LP.Character) end) end

-- RUNTIME LOOPS
RunService.Stepped:Connect(function() for _,p in ipairs(Players:GetPlayers()) do if p~=LP and p.Character then for _,part in ipairs(p.Character:GetChildren()) do if part:IsA("BasePart") then part.CanCollide=false end end end end end)

RunService.Heartbeat:Connect(updateTracers)

-- Anti Bat (Spin - deprecated but kept)
RunService.Heartbeat:Connect(function()
    local char = LP.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")
    if not root or not hum then return end

    -- Anti Bat (Spin - deprecated but kept)
    if State.antiBatOn then
        local currentTool = char:FindFirstChildOfClass("Tool")
        local holdingBat = currentTool and currentTool.Name:lower():find("bat")
        if not holdingBat then
            local threat = false
            for _, other in pairs(Players:GetPlayers()) do
                if other ~= LP and other.Character and other.Character:FindFirstChild("HumanoidRootPart") then
                    if (root.Position - other.Character.HumanoidRootPart.Position).Magnitude <= detectDistance then
                        threat = true break
                    end
                end
            end
            local spin = root:FindFirstChild("AxonicAntiBat")
            if threat then
                if not spin then
                    local bv = Instance.new("BodyAngularVelocity")
                    bv.Name = "AxonicAntiBat"
                    bv.MaxTorque = Vector3.new(0, math.huge, 0)
                    bv.AngularVelocity = Vector3.new(0, 50, 0)
                    bv.Parent = root
                    hum.AutoRotate = false
                end
            elseif spin then
                spin:Destroy()
                hum.AutoRotate = true
            end
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if not (h and hrp) then return end; if State._tpInProgress then return end
    -- Don't override Bat Aimbot movement when active
    if not State.batAimbotToggled and not State.autoLeftEnabled and not State.autoRightEnabled then
        local md=h.MoveDirection; local spd; if State.laggerEnabled then spd=State.laggerSpeed elseif State.speedToggled then spd=State.carrySpeed else spd=State.normalSpeed end
        if md.Magnitude>0 then State.lastMoveDir=md; hrp.Velocity=Vector3.new(md.X*spd,hrp.Velocity.Y,md.Z*spd)
        elseif State.antiRagdollEnabled and State.lastMoveDir.Magnitude>0 then local anyHeld=false; for key in pairs(MOVE_KEYS) do if UIS:IsKeyDown(key) then anyHeld=true; break end end; if anyHeld then hrp.Velocity=Vector3.new(State.lastMoveDir.X*spd,hrp.Velocity.Y,State.lastMoveDir.Z*spd) end end
    end
    pcall(function() local head2=LP.Character and LP.Character:FindFirstChild("Head"); if head2 then local bb2=head2:FindFirstChild("AxonicBB"); if bb2 then local sl=bb2:FindFirstChild("SpeedBillLbl"); if sl then local hspd=Vector3.new(hrp.Velocity.X,0,hrp.Velocity.Z).Magnitude; sl.Text=string.format("%.1f",hspd) end end end end)
end)

-- KEYBINDS (Keep existing keybinds but remove T since it's now in the Keybinds tab)
UIS.InputBegan:Connect(function(inp, gp)
    if gp then return end
    if inp.UserInputType ~= Enum.UserInputType.Keyboard then return end
    if inp.KeyCode == Enum.KeyCode.F then State.tracersEnabled = not State.tracersEnabled; if not State.tracersEnabled then clearTracers() end; print("Tracers:", State.tracersEnabled and "ON" or "OFF") end
    if inp.KeyCode == Enum.KeyCode.G then State.instantResetOnMedusa = not State.instantResetOnMedusa; print("Medusa Reset:", State.instantResetOnMedusa and "ON" or "OFF") end
end)

-- CHAT COMMAND
LP.Chatted:Connect(function(msg) local m=msg:lower():match("^%s*(.-)%s*$"); if m=="/axonic" then State.guiVisible=not State.guiVisible; mainOuter.Visible=State.guiVisible; if State.guiVisible then vBtnFrame.ImageTransparency=0.1; vBtnFrame.BackgroundTransparency=0.1 else vBtnFrame.ImageTransparency=0.6; vBtnFrame.BackgroundTransparency=0.5 end end end)

-- INIT
loadConfig()
startKeybindListen()
task.delay(1,function() pcall(saveConfig) end)

-- Pre-download all songs in background
task.spawn(function()
    for i = 1, #musicURLs do
        downloadSong(i)
        task.wait(0.5)
    end
end)

-- Auto-play intro when script loads
task.spawn(function()
    task.wait(1.5)
    if State.introEnabled then
        if not State.cachedSongs[State.selectedMusic] then
            downloadSong(State.selectedMusic)
        end
        playIntroAnimation()
    end
end)

-- Start Ragdoll Timer on load
task.spawn(function()
    task.wait(0.5)
    if State.ragdollTimerEnabled then
        startRagdollTimer()
    end
end)

-- Start Auto Exit Duel on load if enabled
task.spawn(function()
    task.wait(0.5)
    if State.autoExitDuelEnabled then
        enableAutoExitDuel()
    end
end)

print("â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•")
print("AXONIC HUB v2.0 - Loaded (All Features)")
print("â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•")
print("  Click AXONIC logo to toggle GUI")
print("  /axonic in chat to toggle GUI")
print("")
print("  KEYBINDS (Configurable in Keybinds tab):")
print("  Keyboard: Click keybind button then press a key")
print("  Controller: Click ðŸŽ® button then press controller button")
print("  [T] - Instant Reset (Default)")
print("  [F] - Toggle Tracers")
print("  [G] - Toggle Medusa Reset")
print("")
print("  ðŸŽ® CONTROLLER LAYOUT:")
print("  LT=LB / RT=RB")
print("  A=Right / B=Left / X=Down / Y=Up")
print("  LS=Stick / RS=Stick")
print("  DPAD=Directions")
print("")
print("  NEW FEATURES:")
print("  ðŸ›¡ï¸ V1 Anti-Ragdoll - 400 speed boost on ragdoll exit")
print("  ðŸŽµ Intro Music System - 9 songs with preview")
print("  ðŸŽ¬ AXONIC HUB Intro Animation - Shows on execute")
print("  â±ï¸ Ragdoll Timer - 3-2-1-GO! countdown when ragdolled")
print("  ðŸ’¾ Save Button - Save all settings to config")
print("  ðŸšª Auto Exit Duel - Auto sends GGS then leaves")
print("  ðŸŽ® Controller Support - Full controller keybinding")
print("")
print("  Candy Bat Aimbot Features:")
print("  âš”ï¸ Sticky targeting - locks onto closest enemy")
print("  âš”ï¸ Adaptive prediction - predicts enemy movement")
print("  âš”ï¸ Auto-swing - automatically swings when in range")
print("  âš”ï¸ Height tracking - jumps to match target height")
print("")
print("  Anti Bat Bypass (Mechanics Tab):")
print("  ðŸ›¡ï¸ Limits bat speed to prevent flinging")
print("  ðŸ›¡ï¸ Customizable threshold and cap speed")
print("")
print("  Speed Bypass (Settings Tab):")
print("  âš¡ Toggle on/off with slider")
print("  âš¡ Adjust power from 5,000 to 500,000")
print("")
print("  Mobile Buttons:")
print("  - AXONIC HUB logo in background")
print("  - Hide everything with Settings toggle")
print("â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•")