local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UIS              = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local HttpService      = game:GetService("HttpService")
local CoreGui          = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local _isfile    = isfile   or (syn and syn.isfile)   or function() return false end
local _readfile  = readfile  or (syn and syn.readfile)  or function() return nil  end
local _writefile = writefile or (syn and syn.writefile) or function() end
local getconnections = getconnections or get_signal_cons or getconnects
                    or (syn and syn.get_signal_cons)

local function tween(obj, duration, props)
    TweenService:Create(obj, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

local CLR = {
    Background   = Color3.fromRGB(15,  15,  18),
    Topbar       = Color3.fromRGB(8,   8,   10),
    SideBar      = Color3.fromRGB(10,  10,  13),
    TabPanel     = Color3.fromRGB(15,  15,  18),
    TabBtn       = Color3.fromRGB(37,  37,  40),
    TabBtnActive = Color3.fromRGB(255, 255, 255),
    OptionRow    = Color3.fromRGB(22,  22,  26),
    OptionStroke = Color3.fromRGB(0,   0,   0),
    Bind         = Color3.fromRGB(42,  42,  47),
    ToggleOff    = Color3.fromRGB(24,  24,  28),
    ToggleOn     = Color3.fromRGB(255, 255, 255),
    KnobOff      = Color3.fromRGB(128, 128, 133),
    KnobOn       = Color3.fromRGB(0,   0,   0),
    White        = Color3.fromRGB(255, 255, 255),
    TextPrimary  = Color3.fromRGB(200, 200, 200), -- cambiado a gris
    TextSecondary= Color3.fromRGB(180, 180, 190),
    Black        = Color3.fromRGB(0,   0,   0),
}

local State = {
    NormalSpeed       = 60,
    CarrySpeed        = 30,
    LaggerSpeed       = 10.1,
    LaggerCarrySpeed  = 13,
    SpeedMode         = "Normal",
    LaggerEnabled     = false,
    LaggerCarryEnabled= false,
    InfJump           = false,
    AntiRagdoll       = false,
    FpsBoost          = false,
    MedusaCounter     = false,
    BatCounter        = false,
    BatAimbot         = false,
    AutoSwing         = false,
    AutoLeft          = false,
    AutoRight         = false,
    AutoLeftPhase     = 1,
    AutoRightPhase    = 1,
    DropEnabled       = false,
    Unwalk            = false,
    GuiVisible        = true,
    HittingCD         = false,
    MedusaLastUsed    = 0,
    MedusaDebounce    = false,
    BatCounterDB      = false,
    RemAcc            = false,
    JumpMode          = "Manual",
}

local Steal = {
    AutoSteal       = false,
    StealRadius     = 20,
    IsStealing      = false,
    LastStealTick   = 0,
    StealStart      = 0,
    Data            = {},
    plotCache       = {},
    plotCacheTime   = {},
    cachedPrompts   = {},
    promptCacheTime = 0,
}

local Conns = {
    autoLeft={}, autoRight={}, aimbot=nil, antiRag=nil,
    autoSteal=nil, batCounter=nil, medusa={}, unwalk=nil,
    progress=nil, drop={}
}

local POS = {
    L1 = Vector3.new(-476.48,-6.28, 92.73),
    L2 = Vector3.new(-483.12,-4.95, 94.80),
    R1 = Vector3.new(-476.16,-6.52, 25.62),
    R2 = Vector3.new(-483.04,-5.09, 23.14),
}

local STEAL_COOLDOWN    = 0.10
local PLOT_CACHE_DUR    = 2
local PROMPT_CACHE_REFR = 0.15
local DROP_AUTO_OFF     = 0.15
local MEDUSA_COOLDOWN   = 25
local VYSE_AIMBOT_SPEED = 56.5
local VYSE_HIT_DIST     = 5
local SWING_COOLDOWN    = 0.08

local MOVE_KEYS = {
    [Enum.KeyCode.W]=true,[Enum.KeyCode.A]=true,
    [Enum.KeyCode.S]=true,[Enum.KeyCode.D]=true,
    [Enum.KeyCode.Up]=true,[Enum.KeyCode.Left]=true,
    [Enum.KeyCode.Down]=true,[Enum.KeyCode.Right]=true,
}

local CONFIG_FILE = "forcevsConfig.json"
local h, hrp
local unwalkAnimateRef = nil
local lastMoveDir = Vector3.new(0,0,0)
local startAntiRagdoll, stopAntiRagdoll
local startAutoLeft,    stopAutoLeft
local startAutoRight,   stopAutoRight
local startBatAimbot,   stopBatAimbot
local startBatCounter,  stopBatCounter
local startAutoSteal,   stopAutoSteal
local setupMedusaCounter, stopMedusaCounter
local startUnwalk,      stopUnwalk
local applyFPSBoost
local runDropBrainrot,  stopDropBrainrot
local doTpDown
local saveConfig, loadConfig

local MobileButtons = {Visible = true, Locked = true, Containers = {}, Buttons = {}}

local function corner(parent, r)
    local c = Instance.new("UICorner", parent)
    c.CornerRadius = UDim.new(0, r or 8)
end

local function stroke(parent, col, thick)
    local s = Instance.new("UIStroke", parent)
    s.Color           = col or CLR.OptionStroke
    s.Thickness       = thick or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
end

local function listLayout(parent, spacing)
    local l = Instance.new("UIListLayout", parent)
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.Padding   = UDim.new(0, spacing or 8)
    return l
end

local function pad(parent, top, bottom, left, right)
    local p = Instance.new("UIPadding", parent)
    p.PaddingTop    = UDim.new(0, top    or 0)
    p.PaddingBottom = UDim.new(0, bottom or 0)
    p.PaddingLeft   = UDim.new(0, left   or 0)
    p.PaddingRight  = UDim.new(0, right  or 0)
end

local function safeDestroy(name)
    pcall(function() local g = CoreGui:FindFirstChild(name); if g then g:Destroy() end end)
    pcall(function()
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        if pg then local g = pg:FindFirstChild(name); if g then g:Destroy() end end
    end)
end

local function makeToggleRow(parent, label, defaultValue, callback, layoutOrder)
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1, 0, 0, 38)
    row.BackgroundColor3 = CLR.OptionRow
    row.BorderSizePixel = 0
    row.LayoutOrder = layoutOrder
    corner(row, 6)
    stroke(row, CLR.OptionStroke, 1)
    
    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(0.6, -12, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = CLR.TextPrimary
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    
    local toggleBtn = Instance.new("Frame", row)
    toggleBtn.Size = UDim2.new(0, 44, 0, 22)
    toggleBtn.Position = UDim2.new(1, -56, 0.5, -11)
    toggleBtn.BackgroundColor3 = defaultValue and CLR.ToggleOn or CLR.ToggleOff
    toggleBtn.BorderSizePixel = 0
    corner(toggleBtn, 11)
    
    local knob = Instance.new("Frame", toggleBtn)
    knob.Size = UDim2.new(0, 18, 0, 18)
    knob.Position = defaultValue and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
    knob.BackgroundColor3 = defaultValue and CLR.KnobOn or CLR.KnobOff
    knob.BorderSizePixel = 0
    corner(knob, 9)
    
    local clicker = Instance.new("TextButton", row)
    clicker.Size = UDim2.new(1, 0, 1, 0)
    clicker.BackgroundTransparency = 1
    clicker.Text = ""
    
    local isOn = defaultValue or false
    
    local function setValue(on)
        isOn = on
        tween(toggleBtn, 0.2, {BackgroundColor3 = on and CLR.ToggleOn or CLR.ToggleOff})
        tween(knob, 0.2, {
            Position = on and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9),
            BackgroundColor3 = on and CLR.KnobOn or CLR.KnobOff
        })
        if callback then callback(on) end
    end
    
    clicker.MouseButton1Click:Connect(function() setValue(not isOn) end)
    
    return setValue
end

local function makeInputRow(parent, label, defaultValue, callback, layoutOrder)
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1, 0, 0, 44)
    row.BackgroundColor3 = CLR.OptionRow
    row.BorderSizePixel = 0
    row.LayoutOrder = layoutOrder
    corner(row, 6)
    stroke(row, CLR.OptionStroke, 1)
    
    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(0.6, -12, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = CLR.TextPrimary
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    
    local box = Instance.new("TextBox", row)
    box.Size = UDim2.new(0, 80, 0, 32)
    box.Position = UDim2.new(1, -92, 0.5, -16)
    box.BackgroundColor3 = CLR.Bind
    box.BorderSizePixel = 0
    box.Text = tostring(defaultValue)
    box.TextColor3 = CLR.TextPrimary
    box.Font = Enum.Font.GothamBold
    box.TextSize = 14
    box.ClearTextOnFocus = true
    corner(box, 6)
    -- stroke eliminado (botón de la derecha)
    
    box.FocusLost:Connect(function()
        local num = tonumber(box.Text)
        if num then
            local finalVal = math.clamp(num, 5, 100)
            box.Text = tostring(finalVal)
            if callback then callback(finalVal) end
        else
            box.Text = tostring(defaultValue)
        end
    end)
    
    return box
end

local function makeSectionLabel(parent, text, layoutOrder)
    local lbl = Instance.new("TextLabel", parent)
    lbl.Size = UDim2.new(1, 0, 0, 28)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = CLR.TextSecondary
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.LayoutOrder = layoutOrder
    return lbl
end

local function createMobilePanel()
    local panel = Instance.new("ScreenGui")
    panel.Name = "forcevsMobileButtons"
    panel.Parent = LocalPlayer:WaitForChild("PlayerGui")
    panel.ResetOnSpawn = false
    panel.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    panel.IgnoreGuiInset = true
    
    local BTN_W = 58
    local BTN_H = 58
    local CORNER = 14
    local GAP = 12
    local COL1_X = -(BTN_W + GAP + BTN_W + 10)
    local COL2_X = -(BTN_W + 10)
    local BASE_Y = 0.45
    local ROW_Y  = {-((BTN_H*4+GAP*3)/2), -((BTN_H*4+GAP*3)/2)+(BTN_H+GAP),
                    -((BTN_H*4+GAP*3)/2)+(BTN_H+GAP)*2, -((BTN_H*4+GAP*3)/2)+(BTN_H+GAP)*3}
    
    local function makeMobileBtn(name, text, defaultPos, saveKey, callback, isToggle)
        local container = Instance.new("Frame")
        container.Name = name
        container.Parent = panel
        container.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        container.BackgroundTransparency = 0
        container.BorderSizePixel = 0
        container.Size = UDim2.new(0, BTN_W, 0, BTN_H)
        container.Position = defaultPos
        corner(container, CORNER)
        stroke(container, Color3.fromRGB(255,255,255), 1)
        
        local btn = Instance.new("TextButton", container)
        btn.Size = UDim2.new(1, 0, 1, 0)
        btn.BackgroundTransparency = 1
        btn.BorderSizePixel = 0
        btn.Font = Enum.Font.GothamBlack
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 10
        btn.TextWrapped = true
        btn.AutoButtonColor = false
        
        local active = false
        local function setActive(state)
            active = state
            if active then
                container.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                btn.TextColor3 = Color3.fromRGB(0, 0, 0)
            else
                container.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            end
        end
        
        btn.MouseButton1Down:Connect(function()
            if not isToggle then container.BackgroundColor3 = Color3.fromRGB(255,255,255); btn.TextColor3 = Color3.fromRGB(0,0,0) end
        end)
        btn.MouseButton1Up:Connect(function()
            if not isToggle then container.BackgroundColor3 = Color3.fromRGB(0,0,0); btn.TextColor3 = Color3.fromRGB(255,255,255) end
        end)
        btn.MouseButton1Click:Connect(function()
            if isToggle then setActive(not active) end
            if callback then callback(setActive, active) end
        end)
        
        local dragging = false
        local dragStart = nil
        local startPos = nil
        container.InputBegan:Connect(function(input)
            if MobileButtons.Locked then return end
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = container.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End or input.UserInputState == Enum.UserInputState.Cancelled then
                        dragging = false
                    end
                end)
            end
        end)
        UIS.InputChanged:Connect(function(input)
            if not dragging then return end
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                local delta = input.Position - dragStart
                container.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
        
        local savedPos = nil
        pcall(function() savedPos = _readfile(saveKey) end)
        if savedPos and savedPos ~= "" then
            local parts = {}
            for part in string.gmatch(savedPos, "[^,]+") do table.insert(parts, part) end
            if #parts >= 4 then
                container.Position = UDim2.new(tonumber(parts[1]), tonumber(parts[2]), tonumber(parts[3]), tonumber(parts[4]))
            end
        end
        local lastSave = 0
        container:GetPropertyChangedSignal("Position"):Connect(function()
            if tick() - lastSave > 0.5 then
                lastSave = tick()
                local pos = container.Position
                local str = string.format("%.3f,%.1f,%.3f,%.1f", pos.X.Scale, pos.X.Offset, pos.Y.Scale, pos.Y.Offset)
                pcall(function() _writefile(saveKey, str) end)
            end
        end)
        
        container.Visible = MobileButtons.Visible
        table.insert(MobileButtons.Containers, container)
        return setActive
    end
    
    local dropBRSetActive = makeMobileBtn("BtnDropBR", "DROP\nBR",
        UDim2.new(1, COL1_X, BASE_Y, ROW_Y[1]), "forcevsBtn_dropbr.txt",
        function(setActive, currentActive)
            runDropBrainrot()
            task.delay(0.5, function()
                setActive(false)
            end)
        end, true)
    
    local autoLeftSetActive = makeMobileBtn("BtnAutoLeft", "AUTO\nLEFT",
        UDim2.new(1, COL2_X, BASE_Y, ROW_Y[1]), "forcevsBtn_autoleft.txt",
        function(setActive)
            State.AutoLeft = not State.AutoLeft
            if State.AutoLeft then
                if State.BatAimbot then State.BatAimbot = false; stopBatAimbot() end
                if State.AutoRight then State.AutoRight = false; stopAutoRight() end
                startAutoLeft()
                setActive(true)
            else
                stopAutoLeft()
                setActive(false)
            end
            saveConfig()
        end, true)
    
    local autoBatSetActive = makeMobileBtn("BtnAutoBat", "BAT\nAIMBOT",
        UDim2.new(1, COL1_X, BASE_Y, ROW_Y[2]), "forcevsBtn_autobat.txt",
        function(setActive)
            State.BatAimbot = not State.BatAimbot
            if State.BatAimbot then
                if State.AutoLeft then State.AutoLeft = false; stopAutoLeft() end
                if State.AutoRight then State.AutoRight = false; stopAutoRight() end
                startBatAimbot()
                setActive(true)
            else
                stopBatAimbot()
                setActive(false)
            end
            saveConfig()
        end, true)
    
    local autoRightSetActive = makeMobileBtn("BtnAutoRight", "AUTO\nRIGHT",
        UDim2.new(1, COL2_X, BASE_Y, ROW_Y[2]), "forcevsBtn_autoright.txt",
        function(setActive)
            State.AutoRight = not State.AutoRight
            if State.AutoRight then
                if State.BatAimbot then State.BatAimbot = false; stopBatAimbot() end
                if State.AutoLeft then State.AutoLeft = false; stopAutoLeft() end
                startAutoRight()
                setActive(true)
            else
                stopAutoRight()
                setActive(false)
            end
            saveConfig()
        end, true)
    
    local tpDownSetActive = makeMobileBtn("BtnTpDown", "TP\nDOWN",
        UDim2.new(1, COL1_X, BASE_Y, ROW_Y[3]), "forcevsBtn_tpdown.txt",
        function(setActive, currentActive)
            doTpDown()
            task.delay(0.5, function()
                setActive(false)
            end)
        end, true)
    
    local carrySpeedSetActive = makeMobileBtn("BtnCarrySpd", "CARRY\nSPD",
        UDim2.new(1, COL2_X, BASE_Y, ROW_Y[3]), "forcevsBtn_carryspd.txt",
        function(setActive)
            if State.SpeedMode == "Carry" then
                State.SpeedMode = "Normal"
                setActive(false)
            else
                State.SpeedMode = "Carry"
                setActive(true)
            end
            saveConfig()
        end, true)
    
    local laggerSetActive = makeMobileBtn("BtnLaggerMode", "LAGGER\nNORM",
        UDim2.new(1, COL1_X, BASE_Y, ROW_Y[4]), "forcevsBtn_laggermode.txt",
        function(setActive)
            State.LaggerEnabled = not State.LaggerEnabled
            if State.LaggerEnabled then
                if State.LaggerCarryEnabled then 
                    State.LaggerCarryEnabled = false
                    if laggerCarrySetActive then laggerCarrySetActive(false) end
                end
                Steal.AutoSteal = true
                startAutoSteal()
                setActive(true)
            else
                if not State.LaggerCarryEnabled then
                    Steal.AutoSteal = false
                    stopAutoSteal()
                end
                setActive(false)
            end
            saveConfig()
        end, true)
    
    local laggerCarrySetActive = makeMobileBtn("BtnLaggerCarry", "LAGGER\nCARRY",
        UDim2.new(1, COL2_X, BASE_Y, ROW_Y[4]), "forcevsBtn_laggercarry.txt",
        function(setActive)
            State.LaggerCarryEnabled = not State.LaggerCarryEnabled
            if State.LaggerCarryEnabled then
                if State.LaggerEnabled then 
                    State.LaggerEnabled = false
                    if laggerSetActive then laggerSetActive(false) end
                end
                Steal.AutoSteal = true
                startAutoSteal()
                setActive(true)
            else
                if not State.LaggerEnabled then
                    Steal.AutoSteal = false
                    stopAutoSteal()
                end
                setActive(false)
            end
            saveConfig()
        end, true)
    
    MobileButtons.Buttons = {
        autoLeft = autoLeftSetActive,
        autoRight = autoRightSetActive,
        autoBat = autoBatSetActive,
        carrySpeed = carrySpeedSetActive,
        lagger = laggerSetActive,
        laggerCarry = laggerCarrySetActive,
        dropBR = dropBRSetActive,
        tpDown = tpDownSetActive,
    }
    
    task.spawn(function()
        task.wait(0.1)
        if MobileButtons.Buttons.autoLeft then MobileButtons.Buttons.autoLeft(State.AutoLeft) end
        if MobileButtons.Buttons.autoRight then MobileButtons.Buttons.autoRight(State.AutoRight) end
        if MobileButtons.Buttons.autoBat then MobileButtons.Buttons.autoBat(State.BatAimbot) end
        if MobileButtons.Buttons.carrySpeed then MobileButtons.Buttons.carrySpeed(State.SpeedMode == "Carry") end
        if MobileButtons.Buttons.lagger then MobileButtons.Buttons.lagger(State.LaggerEnabled) end
        if MobileButtons.Buttons.laggerCarry then MobileButtons.Buttons.laggerCarry(State.LaggerCarryEnabled) end
    end)
    
    return panel
end

doTpDown = function()
    pcall(function()
        local c = LocalPlayer.Character; if not c then return end
        local root = c:FindFirstChild("HumanoidRootPart"); if not root then return end
        local rp = RaycastParams.new()
        rp.FilterDescendantsInstances = {c}
        rp.FilterType = Enum.RaycastFilterType.Exclude
        local res = workspace:Raycast(root.Position, Vector3.new(0,-1000,0), rp)
        if res then
            root.CFrame = CFrame.new(res.Position + Vector3.new(0, root.Size.Y/2 + 0.5, 0))
            root.AssemblyLinearVelocity = Vector3.zero
        end
    end)
end

runDropBrainrot = function()
    if State.DropEnabled then return end
    State.DropEnabled = true
    task.spawn(function()
        local colConn = RunService.Stepped:Connect(function()
            if not State.DropEnabled then return end
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    for _, part in ipairs(p.Character:GetChildren()) do
                        if part:IsA("BasePart") then part.CanCollide = false end
                    end
                end
            end
        end)
        table.insert(Conns.drop, colConn)
        task.spawn(function()
            while State.DropEnabled do
                RunService.Heartbeat:Wait()
                local c = LocalPlayer.Character
                local root = c and c:FindFirstChild("HumanoidRootPart")
                if not root then continue end
                local vel = root.AssemblyLinearVelocity
                root.AssemblyLinearVelocity = vel * 10000 + Vector3.new(0, 10000, 0)
                RunService.RenderStepped:Wait()
                if root and root.Parent then root.AssemblyLinearVelocity = vel end
                RunService.Stepped:Wait()
                if root and root.Parent then root.AssemblyLinearVelocity = vel + Vector3.new(0, 0.1, 0) end
            end
        end)
        task.wait(DROP_AUTO_OFF)
        stopDropBrainrot()
    end)
end

stopDropBrainrot = function()
    State.DropEnabled = false
    for _, cn in ipairs(Conns.drop) do pcall(function() cn:Disconnect() end) end
    Conns.drop = {}
end

local function findAnyTool()
    local c = LocalPlayer.Character
    if c then for _, v in ipairs(c:GetChildren()) do if v:IsA("Tool") then return v end end end
    local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
    if bp then for _, v in ipairs(bp:GetChildren()) do if v:IsA("Tool") then return v end end end
end

local function getClosestPlayer()
    if not hrp then return nil, math.huge end
    local cp, cd = nil, math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local tr = p.Character:FindFirstChild("HumanoidRootPart")
            local ph = p.Character:FindFirstChildOfClass("Humanoid")
            if tr and ph and ph.Health > 0 then
                local d = (hrp.Position - tr.Position).Magnitude
                if d < cd then cd = d; cp = p end
            end
        end
    end
    return cp, cd
end

local function tryHitBat()
    if State.HittingCD then return end
    State.HittingCD = true
    pcall(function()
        local c = LocalPlayer.Character; if not c then return end
        local hum2 = c:FindFirstChildOfClass("Humanoid")
        local tool = findAnyTool()
        if tool then
            if tool.Parent ~= c and hum2 then pcall(function() hum2:EquipTool(tool) end) end
            local remote = tool:FindFirstChildOfClass("RemoteEvent")
            if remote then pcall(function() remote:FireServer() end)
            else pcall(function() tool:Activate() end) end
        end
    end)
    task.delay(SWING_COOLDOWN, function() State.HittingCD = false end)
end

startBatAimbot = function()
    if Conns.aimbot then return end
    Conns.aimbot = RunService.Heartbeat:Connect(function()
        if not State.BatAimbot then return end
        local c = LocalPlayer.Character; if not c then return end
        local root = c:FindFirstChild("HumanoidRootPart"); if not root then return end
        local target, dist = getClosestPlayer()
        if target and target.Character then
            local tr = target.Character:FindFirstChild("HumanoidRootPart")
            if tr then
                local fp  = tr.Position + tr.CFrame.LookVector * 1.5
                local dir = (fp - root.Position).Unit
                root.AssemblyLinearVelocity = dir * VYSE_AIMBOT_SPEED
                if dist <= VYSE_HIT_DIST and State.AutoSwing then tryHitBat() end
            end
        else
            root.AssemblyLinearVelocity = Vector3.zero
        end
    end)
end

stopBatAimbot = function()
    if Conns.aimbot then Conns.aimbot:Disconnect(); Conns.aimbot = nil end
    local c = LocalPlayer.Character
    local root = c and c:FindFirstChild("HumanoidRootPart")
    if root then root.AssemblyLinearVelocity = Vector3.zero end
    State.HittingCD = false
end

local BAT_NAMES = {
    "Bat","Slap","Iron Slap","Gold Slap","Diamond Slap","Emerald Slap",
    "Ruby Slap","Dark Matter Slap","Flame Slap","Nuclear Slap",
    "Galaxy Slap","Glitched Slap",
}

local function findBatForCounter()
    local c  = LocalPlayer.Character; if not c then return nil end
    local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
    for _, name in ipairs(BAT_NAMES) do
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
end

local function swingBatForCounter(bat, char)
    local hum2 = char:FindFirstChildOfClass("Humanoid")
    if bat.Parent ~= char then
        if hum2 then pcall(function() hum2:EquipTool(bat) end) end
        task.wait(0.05)
    end
    local remote = bat:FindFirstChildOfClass("RemoteEvent")
    if remote then
        pcall(function() remote:FireServer() end)
        task.wait(0.15)
        pcall(function() remote:FireServer() end)
    else
        pcall(function() bat:Activate() end)
        task.wait(0.15)
        pcall(function() bat:Activate() end)
    end
end

startBatCounter = function()
    if Conns.batCounter then return end
    Conns.batCounter = RunService.Heartbeat:Connect(function()
        if not State.BatCounter or State.BatCounterDB then return end
        local char = LocalPlayer.Character; if not char then return end
        local hum2 = char:FindFirstChildOfClass("Humanoid"); if not hum2 then return end
        local st = hum2:GetState()
        local isRag = st == Enum.HumanoidStateType.Physics
                   or st == Enum.HumanoidStateType.Ragdoll
                   or st == Enum.HumanoidStateType.FallingDown
        if isRag then
            State.BatCounterDB = true
            task.spawn(function()
                local bat = findBatForCounter()
                if bat then swingBatForCounter(bat, char) end
                task.wait(0.5)
                State.BatCounterDB = false
            end)
        end
    end)
end

stopBatCounter = function()
    if Conns.batCounter then Conns.batCounter:Disconnect(); Conns.batCounter = nil end
    State.BatCounterDB = false
end

local function findMedusa()
    local c = LocalPlayer.Character; if not c then return nil end
    for _, t in ipairs(c:GetChildren()) do
        if t:IsA("Tool") then
            local n = t.Name:lower()
            if n:find("medusa") or n:find("head") or n:find("stone") then return t end
        end
    end
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if bp then
        for _, t in ipairs(bp:GetChildren()) do
            if t:IsA("Tool") then
                local n = t.Name:lower()
                if n:find("medusa") or n:find("head") or n:find("stone") then return t end
            end
        end
    end
end

local function useMedusa()
    if State.MedusaDebounce then return end
    if tick() - State.MedusaLastUsed < MEDUSA_COOLDOWN then return end
    local c = LocalPlayer.Character; if not c then return end
    State.MedusaDebounce = true
    local med = findMedusa()
    if not med then State.MedusaDebounce = false; return end
    if med.Parent ~= c then
        local hum2 = c:FindFirstChildOfClass("Humanoid")
        if hum2 then hum2:EquipTool(med) end
    end
    pcall(function() med:Activate() end)
    State.MedusaLastUsed = tick()
    State.MedusaDebounce = false
end

local function onAnchorChanged(part)
    return part:GetPropertyChangedSignal("Anchored"):Connect(function()
        if part.Anchored and part.Transparency == 1 then useMedusa() end
    end)
end

setupMedusaCounter = function(char)
    stopMedusaCounter()
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then table.insert(Conns.medusa, onAnchorChanged(part)) end
    end
    table.insert(Conns.medusa, char.DescendantAdded:Connect(function(part)
        if part:IsA("BasePart") then table.insert(Conns.medusa, onAnchorChanged(part)) end
    end))
end

stopMedusaCounter = function()
    for _, c2 in pairs(Conns.medusa) do pcall(function() c2:Disconnect() end) end
    Conns.medusa = {}
end

startAntiRagdoll = function()
    if Conns.antiRag then return end
    Conns.antiRag = RunService.Heartbeat:Connect(function()
        if not State.AntiRagdoll then return end
        local c = LocalPlayer.Character; if not c then return end
        local hum2 = c:FindFirstChildOfClass("Humanoid")
        local root = c:FindFirstChild("HumanoidRootPart")
        if not hum2 or not root then return end
        if hum2.Health <= 0 then return end
        local st = hum2:GetState()
        if st == Enum.HumanoidStateType.Dead then return end
        if st == Enum.HumanoidStateType.Physics
        or st == Enum.HumanoidStateType.Ragdoll
        or st == Enum.HumanoidStateType.FallingDown then
            pcall(function() hum2:ChangeState(Enum.HumanoidStateType.GettingUp) end)
            pcall(function() workspace.CurrentCamera.CameraSubject = hum2 end)
            root.AssemblyLinearVelocity  = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
        end
        for _, obj in ipairs(c:GetDescendants()) do
            pcall(function()
                if obj:IsA("Motor6D") and not obj.Enabled then obj.Enabled = true end
            end)
        end
    end)
end

stopAntiRagdoll = function()
    if Conns.antiRag then Conns.antiRag:Disconnect(); Conns.antiRag = nil end
end

startUnwalk = function()
    local c = LocalPlayer.Character; if not c then return end
    local hum2 = c:FindFirstChildOfClass("Humanoid")
    if hum2 then
        pcall(function()
            for _, track in ipairs(hum2:GetPlayingAnimationTracks()) do track:Stop(0) end
        end)
    end
    local anim = c:FindFirstChild("Animate")
    if anim and anim:IsA("LocalScript") then
        anim.Disabled = true; unwalkAnimateRef = anim
    end
    if Conns.unwalk then Conns.unwalk:Disconnect() end
    Conns.unwalk = RunService.Heartbeat:Connect(function()
        if not State.Unwalk then return end
        local c2 = LocalPlayer.Character; if not c2 then return end
        local hum3 = c2:FindFirstChildOfClass("Humanoid")
        if hum3 then
            pcall(function()
                for _, track in ipairs(hum3:GetPlayingAnimationTracks()) do track:Stop(0) end
            end)
        end
    end)
end

stopUnwalk = function()
    if Conns.unwalk then Conns.unwalk:Disconnect(); Conns.unwalk = nil end
    local c = LocalPlayer.Character
    if c and unwalkAnimateRef and unwalkAnimateRef.Parent == c then
        unwalkAnimateRef.Disabled = false
    end
    unwalkAnimateRef = nil
end

applyFPSBoost = function()
    pcall(function() setfpscap(999999999) end)
    local function pO(v)
        pcall(function()
            if v:IsA("Model") then
                v.LevelOfDetail = Enum.ModelLevelOfDetail.Disabled
            elseif v:IsA("MeshPart") then
                v.CastShadow = false; v.RenderFidelity = Enum.RenderFidelity.Performance
            elseif v:IsA("BasePart") then
                v.CastShadow = false; v.Reflectance = 0
            elseif v:IsA("Decal") or v:IsA("Texture") then
                v.Transparency = 1
            elseif v:IsA("Fire") or v:IsA("SpotLight") or v:IsA("Smoke")
                or v:IsA("Sparkles") or v:IsA("ParticleEmitter")
                or v:IsA("Trail") or v:IsA("Beam") then
                v.Enabled = false
            elseif v:IsA("SurfaceAppearance") or v:IsA("MaterialVariant") then
                v:Destroy()
            end
        end)
    end
    for _, v in pairs(workspace:GetDescendants()) do pO(v) end
    pcall(function()
        local L = game:GetService("Lighting")
        for _, v in pairs(L:GetDescendants()) do
            pcall(function()
                if v:IsA("Sky") or v:IsA("Atmosphere") or v:IsA("BloomEffect")
                or v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("Clouds")
                or v:IsA("ColorCorrectionEffect") then v:Destroy() end
            end)
        end
        L.GlobalShadows = false; L.FogEnd = 9e9; L.Brightness = 0
    end)
    workspace.DescendantAdded:Connect(function(v)
        if State.FpsBoost then task.spawn(pO, v) end
    end)
end

local function faceSouth()
    pcall(function()
        local c = LocalPlayer.Character; if not c then return end
        local root = c:FindFirstChild("HumanoidRootPart")
        if root then root.CFrame = CFrame.new(root.Position) * CFrame.Angles(0,0,0) end
    end)
end

local function faceNorth()
    pcall(function()
        local c = LocalPlayer.Character; if not c then return end
        local root = c:FindFirstChild("HumanoidRootPart")
        if root then root.CFrame = CFrame.new(root.Position) * CFrame.Angles(0,math.rad(180),0) end
    end)
end

startAutoLeft = function()
    for _, cn in ipairs(Conns.autoLeft) do pcall(function() cn:Disconnect() end) end
    Conns.autoLeft = {}; State.AutoLeftPhase = 1
    local c2 = RunService.Heartbeat:Connect(function()
        if not State.AutoLeft then return end
        local c = LocalPlayer.Character; if not c then return end
        local root = c:FindFirstChild("HumanoidRootPart")
        local hum2 = c:FindFirstChildOfClass("Humanoid")
        if not root or not hum2 then return end
        local spd = State.NormalSpeed
        if State.AutoLeftPhase == 1 then
            local tgt = Vector3.new(POS.L1.X, root.Position.Y, POS.L1.Z)
            if (tgt - root.Position).Magnitude < 1 then
                State.AutoLeftPhase = 2
                local d = POS.L2 - root.Position
                local mv = Vector3.new(d.X,0,d.Z).Unit
                hum2:Move(mv, false)
                root.AssemblyLinearVelocity = Vector3.new(mv.X*spd, root.AssemblyLinearVelocity.Y, mv.Z*spd)
                return
            end
            local d = POS.L1 - root.Position
            local mv = Vector3.new(d.X,0,d.Z).Unit
            hum2:Move(mv, false)
            root.AssemblyLinearVelocity = Vector3.new(mv.X*spd, root.AssemblyLinearVelocity.Y, mv.Z*spd)
        elseif State.AutoLeftPhase == 2 then
            local tgt = Vector3.new(POS.L2.X, root.Position.Y, POS.L2.Z)
            if (tgt - root.Position).Magnitude < 1 then
                hum2:Move(Vector3.zero, false)
                root.AssemblyLinearVelocity = Vector3.zero
                State.AutoLeft = false; State.AutoLeftPhase = 1
                stopAutoLeft(); faceSouth(); return
            end
            local d = POS.L2 - root.Position
            local mv = Vector3.new(d.X,0,d.Z).Unit
            hum2:Move(mv, false)
            root.AssemblyLinearVelocity = Vector3.new(mv.X*spd, root.AssemblyLinearVelocity.Y, mv.Z*spd)
        end
    end)
    table.insert(Conns.autoLeft, c2)
end

stopAutoLeft = function()
    for _, cn in ipairs(Conns.autoLeft) do pcall(function() cn:Disconnect() end) end
    Conns.autoLeft = {}; State.AutoLeftPhase = 1
    local c = LocalPlayer.Character
    if c then local hum2 = c:FindFirstChildOfClass("Humanoid"); if hum2 then hum2:Move(Vector3.zero,false) end end
end

startAutoRight = function()
    for _, cn in ipairs(Conns.autoRight) do pcall(function() cn:Disconnect() end) end
    Conns.autoRight = {}; State.AutoRightPhase = 1
    local c2 = RunService.Heartbeat:Connect(function()
        if not State.AutoRight then return end
        local c = LocalPlayer.Character; if not c then return end
        local root = c:FindFirstChild("HumanoidRootPart")
        local hum2 = c:FindFirstChildOfClass("Humanoid")
        if not root or not hum2 then return end
        local spd = State.NormalSpeed
        if State.AutoRightPhase == 1 then
            local tgt = Vector3.new(POS.R1.X, root.Position.Y, POS.R1.Z)
            if (tgt - root.Position).Magnitude < 1 then
                State.AutoRightPhase = 2
                local d = POS.R2 - root.Position
                local mv = Vector3.new(d.X,0,d.Z).Unit
                hum2:Move(mv, false)
                root.AssemblyLinearVelocity = Vector3.new(mv.X*spd, root.AssemblyLinearVelocity.Y, mv.Z*spd)
                return
            end
            local d = POS.R1 - root.Position
            local mv = Vector3.new(d.X,0,d.Z).Unit
            hum2:Move(mv, false)
            root.AssemblyLinearVelocity = Vector3.new(mv.X*spd, root.AssemblyLinearVelocity.Y, mv.Z*spd)
        elseif State.AutoRightPhase == 2 then
            local tgt = Vector3.new(POS.R2.X, root.Position.Y, POS.R2.Z)
            if (tgt - root.Position).Magnitude < 1 then
                hum2:Move(Vector3.zero, false)
                root.AssemblyLinearVelocity = Vector3.zero
                State.AutoRight = false; State.AutoRightPhase = 1
                stopAutoRight(); faceNorth(); return
            end
            local d = POS.R2 - root.Position
            local mv = Vector3.new(d.X,0,d.Z).Unit
            hum2:Move(mv, false)
            root.AssemblyLinearVelocity = Vector3.new(mv.X*spd, root.AssemblyLinearVelocity.Y, mv.Z*spd)
        end
    end)
    table.insert(Conns.autoRight, c2)
end

stopAutoRight = function()
    for _, cn in ipairs(Conns.autoRight) do pcall(function() cn:Disconnect() end) end
    Conns.autoRight = {}; State.AutoRightPhase = 1
    local c = LocalPlayer.Character
    if c then local hum2 = c:FindFirstChildOfClass("Humanoid"); if hum2 then hum2:Move(Vector3.zero,false) end end
end

local function isMyPlot(pn)
    local ct = tick()
    if Steal.plotCache[pn] and (ct-(Steal.plotCacheTime[pn] or 0)) < PLOT_CACHE_DUR then
        return Steal.plotCache[pn]
    end
    local plots = workspace:FindFirstChild("Plots")
    if not plots then Steal.plotCache[pn]=false; Steal.plotCacheTime[pn]=ct; return false end
    local plot = plots:FindFirstChild(pn)
    if not plot then Steal.plotCache[pn]=false; Steal.plotCacheTime[pn]=ct; return false end
    local sign = plot:FindFirstChild("PlotSign")
    if sign then
        local yb = sign:FindFirstChild("YourBase")
        if yb and yb:IsA("BillboardGui") then
            local r = yb.Enabled==true
            Steal.plotCache[pn]=r; Steal.plotCacheTime[pn]=ct; return r
        end
    end
    Steal.plotCache[pn]=false; Steal.plotCacheTime[pn]=ct; return false
end

local function findNearestPrompt()
    local c = LocalPlayer.Character; if not c then return nil end
    local root = c:FindFirstChild("HumanoidRootPart"); if not root then return nil end
    local ct = tick()
    if ct-Steal.promptCacheTime < PROMPT_CACHE_REFR and #Steal.cachedPrompts>0 then
        local np,nd=nil,math.huge
        for _, data in ipairs(Steal.cachedPrompts) do
            if data.spawn then
                local dist=(data.spawn.Position-root.Position).Magnitude
                if dist<=Steal.StealRadius and dist<nd then np=data.prompt; nd=dist end
            end
        end
        if np then return np end
    end
    Steal.cachedPrompts={}; Steal.promptCacheTime=ct
    local plots=workspace:FindFirstChild("Plots"); if not plots then return nil end
    local np,nd=nil,math.huge
    for _, plot in ipairs(plots:GetChildren()) do
        if isMyPlot(plot.Name) then continue end
        local pods=plot:FindFirstChild("AnimalPodiums"); if not pods then continue end
        for _, pod in ipairs(pods:GetChildren()) do
            pcall(function()
                local base=pod:FindFirstChild("Base")
                local sp=base and base:FindFirstChild("Spawn")
                if sp then
                    local att=sp:FindFirstChild("PromptAttachment")
                    if att then
                        for _, child in ipairs(att:GetChildren()) do
                            if child:IsA("ProximityPrompt") then
                                local dist=(sp.Position-root.Position).Magnitude
                                table.insert(Steal.cachedPrompts,{prompt=child,spawn=sp})
                                if dist<=Steal.StealRadius and dist<nd then np=child; nd=dist end
                                break
                            end
                        end
                    end
                end
            end)
        end
    end
    return np
end

local function executeSteal(prompt)
    local ct=tick()
    if ct-Steal.LastStealTick<STEAL_COOLDOWN then return end
    if Steal.IsStealing then return end
    if not Steal.Data[prompt] then
        Steal.Data[prompt]={hold={},trigger={},ready=true}
        pcall(function()
            if getconnections then
                for _, c2 in ipairs(getconnections(prompt.PromptButtonHoldBegan)) do
                    if c2.Function then table.insert(Steal.Data[prompt].hold,c2.Function) end
                end
                for _, c2 in ipairs(getconnections(prompt.Triggered)) do
                    if c2.Function then table.insert(Steal.Data[prompt].trigger,c2.Function) end
                end
            else
                Steal.Data[prompt].useFallback=true
            end
        end)
    end
    local data=Steal.Data[prompt]
    if not data.ready then return end
    data.ready=false; Steal.IsStealing=true
    Steal.StealStart=ct; Steal.LastStealTick=ct

    task.spawn(function()
        local ok=false
        pcall(function()
            if not data.useFallback then
                for _, fn in ipairs(data.hold) do task.spawn(fn) end
                task.wait(0.25)
                for _, fn in ipairs(data.trigger) do task.spawn(fn) end
                ok=true
            end
        end)
        if not ok and fireproximityprompt then
            pcall(function() fireproximityprompt(prompt); ok=true end)
        end
        if not ok then
            pcall(function()
                prompt:InputHoldBegin()
                task.wait(0.25)
                prompt:InputHoldEnd()
            end)
        end
        task.wait(0.1)
        data.ready=true; Steal.IsStealing=false
    end)
end

startAutoSteal = function()
    if Conns.autoSteal then return end
    Conns.autoSteal=RunService.Heartbeat:Connect(function()
        if not Steal.AutoSteal or Steal.IsStealing then return end
        local p=findNearestPrompt(); if p then executeSteal(p) end
    end)
end

stopAutoSteal = function()
    if Conns.autoSteal then Conns.autoSteal:Disconnect(); Conns.autoSteal=nil end
    Steal.IsStealing=false; Steal.LastStealTick=0
    Steal.plotCache={}; Steal.plotCacheTime={}
    Steal.cachedPrompts={}
end

saveConfig = function()
    local cfg = {
        NormalSpeed=State.NormalSpeed, CarrySpeed=State.CarrySpeed, LaggerSpeed=State.LaggerSpeed, LaggerCarrySpeed=State.LaggerCarrySpeed,
        SpeedMode=State.SpeedMode, LaggerEnabled=State.LaggerEnabled, LaggerCarryEnabled=State.LaggerCarryEnabled,
        StealRadius=Steal.StealRadius, AutoSteal=Steal.AutoSteal,
        InfJump=State.InfJump, JumpMode=State.JumpMode,
        AntiRagdoll=State.AntiRagdoll, FpsBoost=State.FpsBoost,
        MedusaCounter=State.MedusaCounter, BatCounter=State.BatCounter,
        BatAimbot=State.BatAimbot, AutoSwing=State.AutoSwing,
        AutoLeft=State.AutoLeft, AutoRight=State.AutoRight,
        Unwalk=State.Unwalk,
    }
    local ok, enc = pcall(function() return HttpService:JSONEncode(cfg) end)
    if ok then pcall(function() _writefile(CONFIG_FILE, enc) end) end
end

loadConfig = function()
    local hasFile=false
    pcall(function() hasFile=_isfile(CONFIG_FILE) end)
    if not hasFile then return end
    local raw; pcall(function() raw=_readfile(CONFIG_FILE) end)
    if not raw then return end
    local cfg; local ok=pcall(function() cfg=HttpService:JSONDecode(raw) end)
    if not ok or not cfg then return end
    if cfg.NormalSpeed   then State.NormalSpeed=cfg.NormalSpeed end
    if cfg.CarrySpeed    then State.CarrySpeed=cfg.CarrySpeed end
    if cfg.LaggerSpeed   then State.LaggerSpeed=cfg.LaggerSpeed end
    if cfg.LaggerCarrySpeed then State.LaggerCarrySpeed=cfg.LaggerCarrySpeed end
    if cfg.SpeedMode     then State.SpeedMode=cfg.SpeedMode end
    if cfg.LaggerEnabled ~= nil then State.LaggerEnabled=cfg.LaggerEnabled end
    if cfg.LaggerCarryEnabled ~= nil then State.LaggerCarryEnabled=cfg.LaggerCarryEnabled end
    if cfg.StealRadius   then Steal.StealRadius=cfg.StealRadius end
    if cfg.AutoSteal ~= nil then Steal.AutoSteal=cfg.AutoSteal end
    if cfg.InfJump ~= nil then State.InfJump=cfg.InfJump end
    if cfg.JumpMode then State.JumpMode=cfg.JumpMode end
    if cfg.AntiRagdoll ~= nil then State.AntiRagdoll=cfg.AntiRagdoll; if State.AntiRagdoll then startAntiRagdoll() end end
    if cfg.FpsBoost ~= nil then State.FpsBoost=cfg.FpsBoost; if State.FpsBoost then pcall(applyFPSBoost) end end
    if cfg.MedusaCounter ~= nil then State.MedusaCounter=cfg.MedusaCounter; if State.MedusaCounter then setupMedusaCounter(LocalPlayer.Character) end end
    if cfg.BatCounter ~= nil then State.BatCounter=cfg.BatCounter; if State.BatCounter then startBatCounter() end end
    if cfg.BatAimbot ~= nil then State.BatAimbot=cfg.BatAimbot; if State.BatAimbot then pcall(startBatAimbot) end end
    if cfg.AutoSwing ~= nil then State.AutoSwing=cfg.AutoSwing end
    if cfg.AutoLeft ~= nil then State.AutoLeft=cfg.AutoLeft; if State.AutoLeft then pcall(startAutoLeft) end end
    if cfg.AutoRight ~= nil then State.AutoRight=cfg.AutoRight; if State.AutoRight then pcall(startAutoRight) end end
    if cfg.Unwalk ~= nil then State.Unwalk=cfg.Unwalk; if State.Unwalk then pcall(startUnwalk) end end
    if Steal.AutoSteal then pcall(startAutoSteal) end
end

-- CREATE GUI
safeDestroy("forcevs")
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name           = "forcevs"
ScreenGui.ResetOnSpawn   = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function()
    if syn and syn.protect_gui then syn.protect_gui(ScreenGui) end
    if gethui then ScreenGui.Parent = gethui()
    else            ScreenGui.Parent = CoreGui end
end)
if not ScreenGui.Parent then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Name             = "Main"
MainFrame.Size             = UDim2.fromOffset(720, 540)
MainFrame.Position         = UDim2.new(0.5, -360, 0.5, -270)
MainFrame.BackgroundColor3 = CLR.Background
MainFrame.BackgroundTransparency = 1
MainFrame.BorderSizePixel  = 0
MainFrame.Active           = true
MainFrame.Draggable        = true
corner(MainFrame, 12)
stroke(MainFrame, CLR.OptionStroke, 1)

-- ========== FONDO PERSONALIZADO ==========
local FondoTextura = Instance.new("ImageLabel", MainFrame)
FondoTextura.Name = "FondoTextura"
FondoTextura.Size = UDim2.new(1, 0, 1, 0)
FondoTextura.Position = UDim2.new(0, 0, 0, 0)
FondoTextura.BackgroundTransparency = 1
FondoTextura.Image = "rbxassetid://AQUI_TU_ID"
FondoTextura.ZIndex = 0
FondoTextura.ScaleType = Enum.ScaleType.Crop
FondoTextura.Visible = false

local TextoGoteo = Instance.new("TextLabel", MainFrame)
TextoGoteo.Name = "TextoGoteo"
TextoGoteo.Size = UDim2.new(1, 0, 1, 0)
TextoGoteo.Position = UDim2.new(0, 4, 0, 7)
TextoGoteo.BackgroundTransparency = 1
TextoGoteo.Text = "force.vs"
TextoGoteo.Font = Enum.Font.GothamBlack
TextoGoteo.TextColor3 = Color3.fromRGB(30, 30, 30)
TextoGoteo.TextSize = 82
TextoGoteo.TextScaled = true
TextoGoteo.TextTransparency = 0.4
TextoGoteo.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
TextoGoteo.TextStrokeTransparency = 0.5
TextoGoteo.ZIndex = 1
TextoGoteo.TextXAlignment = Enum.TextXAlignment.Center
TextoGoteo.TextYAlignment = Enum.TextYAlignment.Center

local TextoFondo = Instance.new("TextLabel", MainFrame)
TextoFondo.Name = "TextoFondo"
TextoFondo.Size = UDim2.new(1, 0, 1, 0)
TextoFondo.Position = UDim2.new(0, 0, 0, 0)
TextoFondo.BackgroundTransparency = 1
TextoFondo.Text = "force.vs"
TextoFondo.Font = Enum.Font.GothamBlack
TextoFondo.TextColor3 = CLR.TextPrimary
TextoFondo.TextSize = 84
TextoFondo.TextScaled = true
TextoFondo.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
TextoFondo.TextStrokeTransparency = 0.1
TextoFondo.ZIndex = 2
TextoFondo.TextXAlignment = Enum.TextXAlignment.Center
TextoFondo.TextYAlignment = Enum.TextYAlignment.Center

local TextoBrillo = Instance.new("TextLabel", MainFrame)
TextoBrillo.Name = "TextoBrillo"
TextoBrillo.Size = UDim2.new(1, 0, 1, 0)
TextoBrillo.Position = UDim2.new(0, -2, 0, -3)
TextoBrillo.BackgroundTransparency = 1
TextoBrillo.Text = "force.vs"
TextoBrillo.Font = Enum.Font.GothamBlack
TextoBrillo.TextColor3 = Color3.fromRGB(255, 255, 255)
TextoBrillo.TextSize = 84
TextoBrillo.TextScaled = true
TextoBrillo.TextTransparency = 0.65
TextoBrillo.TextStrokeTransparency = 1
TextoBrillo.ZIndex = 3
TextoBrillo.TextXAlignment = Enum.TextXAlignment.Center
TextoBrillo.TextYAlignment = Enum.TextYAlignment.Center

local UIScale = Instance.new("UIScale", MainFrame)
UIScale.Scale = 0.75

local Topbar = Instance.new("Frame", MainFrame)
Topbar.Name             = "Topbar"
Topbar.Size             = UDim2.new(1, 0, 0, 50)
Topbar.BackgroundColor3 = CLR.Topbar
Topbar.BorderSizePixel  = 0
Topbar.ZIndex = 2

-- Sombra del título superior
local titleShadow = Instance.new("TextLabel", Topbar)
titleShadow.Size               = UDim2.fromOffset(150, 30)
titleShadow.Position           = UDim2.fromOffset(20, 12)
titleShadow.BackgroundTransparency = 1
titleShadow.Text               = "force.vs"
titleShadow.Font               = Enum.Font.GothamBlack
titleShadow.TextSize           = 17
titleShadow.TextColor3         = Color3.fromRGB(20, 20, 20)
titleShadow.TextTransparency   = 0.4
titleShadow.TextStrokeTransparency = 1
titleShadow.ZIndex             = 2
titleShadow.TextXAlignment     = Enum.TextXAlignment.Left

local titleLbl = Instance.new("TextLabel", Topbar)
titleLbl.Size               = UDim2.fromOffset(150, 30)
titleLbl.Position           = UDim2.fromOffset(18, 10)
titleLbl.BackgroundTransparency = 1
titleLbl.Text               = "force.vs"
titleLbl.Font               = Enum.Font.GothamBlack
titleLbl.TextSize           = 17
titleLbl.TextColor3         = CLR.TextPrimary
titleLbl.TextStrokeColor3   = Color3.fromRGB(0, 0, 0)
titleLbl.TextStrokeTransparency = 0.15
titleLbl.ZIndex             = 3
titleLbl.TextXAlignment     = Enum.TextXAlignment.Left

local subLbl = Instance.new("TextLabel", Topbar)
subLbl.Size               = UDim2.fromOffset(200, 30)
subLbl.Position           = UDim2.fromOffset(170, 10)
subLbl.BackgroundTransparency = 1
subLbl.Text               = "discord.gg/forcevs"
subLbl.Font               = Enum.Font.Gotham
subLbl.TextSize           = 13
subLbl.TextColor3         = CLR.TextSecondary
subLbl.TextXAlignment     = Enum.TextXAlignment.Left

local minBtn = Instance.new("TextButton", Topbar)
minBtn.Size             = UDim2.fromOffset(36, 28)
minBtn.Position         = UDim2.new(1, -52, 0, 11)
minBtn.BackgroundColor3 = CLR.TabBtn
minBtn.Text             = "–"
minBtn.Font             = Enum.Font.GothamBold
minBtn.TextSize         = 18
minBtn.TextColor3       = CLR.TextPrimary
minBtn.AutoButtonColor  = false
minBtn.BorderSizePixel  = 0
corner(minBtn, 6)
stroke(minBtn, CLR.OptionStroke, 1)

local SideBar = Instance.new("Frame", MainFrame)
SideBar.Name             = "SideBar"
SideBar.Size             = UDim2.new(0, 220, 1, -50)
SideBar.Position         = UDim2.fromOffset(0, 50)
SideBar.BackgroundColor3 = CLR.SideBar
SideBar.BorderSizePixel  = 0
SideBar.ZIndex = 2

local sideArt = Instance.new("ImageLabel", SideBar)
sideArt.Size               = UDim2.new(1, 0, 1, 0)
sideArt.BackgroundTransparency = 1
sideArt.Image              = "rbxassetid://105044056375613"
sideArt.ScaleType          = Enum.ScaleType.Crop

local brandHolder = Instance.new("Frame", SideBar)
brandHolder.Size               = UDim2.new(1, -20, 0, 52)
brandHolder.Position           = UDim2.new(0, 10, 1, -62)
brandHolder.BackgroundTransparency = 1

-- Sombra del título lateral
local brandShadow = Instance.new("TextLabel", brandHolder)
brandShadow.Size               = UDim2.new(1, 0, 0, 24)
brandShadow.Position           = UDim2.fromOffset(2, 2)
brandShadow.BackgroundTransparency = 1
brandShadow.Text               = "force.vs"
brandShadow.Font               = Enum.Font.GothamBlack
brandShadow.TextSize           = 19
brandShadow.TextColor3         = Color3.fromRGB(20, 20, 20)
brandShadow.TextTransparency   = 0.4
brandShadow.TextStrokeTransparency = 1
brandShadow.ZIndex             = 2
brandShadow.TextXAlignment     = Enum.TextXAlignment.Left

local brandTitle = Instance.new("TextLabel", brandHolder)
brandTitle.Size               = UDim2.new(1, 0, 0, 24)
brandTitle.BackgroundTransparency = 1
brandTitle.Text               = "force.vs"
brandTitle.Font               = Enum.Font.GothamBlack
brandTitle.TextSize           = 19
brandTitle.TextColor3         = CLR.TextPrimary
brandTitle.TextStrokeColor3   = Color3.fromRGB(0, 0, 0)
brandTitle.TextStrokeTransparency = 0.1
brandTitle.ZIndex             = 3
brandTitle.TextXAlignment     = Enum.TextXAlignment.Left

local brandLine = Instance.new("Frame", brandHolder)
brandLine.Size             = UDim2.fromOffset(58, 2)
brandLine.Position         = UDim2.fromOffset(0, 27)
brandLine.BackgroundColor3 = CLR.White
brandLine.BorderSizePixel  = 0

local brandSub = Instance.new("TextLabel", brandHolder)
brandSub.Size               = UDim2.new(1, 0, 0, 16)
brandSub.Position           = UDim2.fromOffset(0, 33)
brandSub.BackgroundTransparency = 1
brandSub.Text               = "discord.gg/forcevs"
brandSub.Font               = Enum.Font.Gotham
brandSub.TextSize           = 12
brandSub.TextColor3         = CLR.TextSecondary
brandSub.TextXAlignment     = Enum.TextXAlignment.Left

local TabPanel = Instance.new("Frame", MainFrame)
TabPanel.Name             = "TabPanel"
TabPanel.Size             = UDim2.new(0, 150, 1, -50)
TabPanel.Position         = UDim2.fromOffset(220, 50)
TabPanel.BackgroundColor3 = CLR.TabPanel
TabPanel.BorderSizePixel  = 0
TabPanel.ZIndex = 2
pad(TabPanel, 10, 10, 10, 10)
local tabLayout = listLayout(TabPanel, 6)

local ContentArea = Instance.new("Frame", MainFrame)
ContentArea.Name             = "ContentArea"
ContentArea.Size             = UDim2.new(1, -370, 1, -50)
ContentArea.Position         = UDim2.fromOffset(370, 50)
ContentArea.BackgroundColor3 = CLR.Background
ContentArea.BorderSizePixel  = 0
ContentArea.ZIndex = 2
pad(ContentArea, 14, 14, 14, 14)

local MiniBtn = Instance.new("TextButton", ScreenGui)
MiniBtn.Name             = "forcevsMini"
MiniBtn.Size             = UDim2.fromOffset(140, 40)
MiniBtn.Position         = UDim2.fromOffset(20, 20)
MiniBtn.BackgroundColor3 = CLR.TabBtn
MiniBtn.AutoButtonColor  = false
MiniBtn.Text             = "force.vs"
MiniBtn.Font             = Enum.Font.GothamBlack
MiniBtn.TextSize         = 14
MiniBtn.TextColor3       = CLR.TextPrimary
MiniBtn.Visible          = false
MiniBtn.Active           = true
MiniBtn.Draggable        = true
corner(MiniBtn, 8)
stroke(MiniBtn, CLR.OptionStroke, 1)

minBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false; MiniBtn.Visible = true
end)

MiniBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = true; MiniBtn.Visible = false
end)

local TABS = {"Speed", "Mechanics", "Movement", "Bat Aimbot", "Performance", "Settings"}
local TabBtns  = {}
local TabPages = {}
local currentTab

for i, name in ipairs(TABS) do
    local btn = Instance.new("TextButton", TabPanel)
    btn.Name             = name .. "TabBtn"
    btn.Size             = UDim2.new(1, 0, 0, 44)
    btn.LayoutOrder      = i
    btn.BackgroundColor3 = CLR.TabBtn
    btn.AutoButtonColor  = false
    btn.Text             = name
    btn.Font             = Enum.Font.GothamBold
    btn.TextSize         = 14
    btn.TextColor3       = CLR.TextPrimary
    btn.BorderSizePixel  = 0
    corner(btn, 8)
    TabBtns[name] = btn
    
    local page = Instance.new("ScrollingFrame", ContentArea)
    page.Name                 = name .. "Page"
    page.Size                 = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel      = 0
    page.ScrollBarThickness   = 2
    page.ScrollBarImageColor3 = CLR.OptionStroke
    page.AutomaticCanvasSize  = Enum.AutomaticSize.Y
    page.CanvasSize           = UDim2.new(0, 0, 0, 0)
    page.Visible              = false
    local pageLayout = listLayout(page, 8)
    pad(page, 0, 14, 0, 0)
    TabPages[name] = page
end

local function showTab(name)
    currentTab = name
    for n, btn in pairs(TabBtns) do
        tween(btn, 0.15, { BackgroundColor3 = (n==name) and CLR.TabBtnActive or CLR.TabBtn })
    end
    for n, pg in pairs(TabPages) do
        if typeof(pg) == "Instance" then pg.Visible = (n==name) end
    end
end

for n, btn in pairs(TabBtns) do
    btn.MouseButton1Click:Connect(function() showTab(n) end)
end

showTab("Speed")

local order = 1
makeSectionLabel(TabPages.Speed, "SPEED CONFIGURATION", order); order = order + 1

local normalSpeedBox = makeInputRow(TabPages.Speed, "Normal Speed", State.NormalSpeed, function(val)
    State.NormalSpeed = val
    saveConfig()
end, order); order = order + 1

local carrySpeedBox = makeInputRow(TabPages.Speed, "Carry Speed", State.CarrySpeed, function(val)
    State.CarrySpeed = val
    saveConfig()
end, order); order = order + 1

local laggerSpeedBox = makeInputRow(TabPages.Speed, "Lagger Normal Speed", State.LaggerSpeed, function(val)
    State.LaggerSpeed = val
    saveConfig()
end, order); order = order + 1

local laggerCarrySpeedBox = makeInputRow(TabPages.Speed, "Lagger Carry Speed", State.LaggerCarrySpeed, function(val)
    State.LaggerCarrySpeed = val
    saveConfig()
end, order); order = order + 1

makeSectionLabel(TabPages.Speed, "SPEED MODES", order); order = order + 1

local speedModeRow = Instance.new("Frame", TabPages.Speed)
speedModeRow.Size = UDim2.new(1, 0, 0, 44)
speedModeRow.BackgroundColor3 = CLR.OptionRow
speedModeRow.BorderSizePixel = 0
speedModeRow.LayoutOrder = order; order = order + 1
corner(speedModeRow, 6)
stroke(speedModeRow, CLR.OptionStroke, 1)

local modeLbl = Instance.new("TextLabel", speedModeRow)
modeLbl.Size = UDim2.new(0.6, -12, 1, 0)
modeLbl.Position = UDim2.new(0, 12, 0, 0)
modeLbl.BackgroundTransparency = 1
modeLbl.Text = "Current Speed Mode"
modeLbl.TextColor3 = CLR.TextPrimary
modeLbl.Font = Enum.Font.GothamBold
modeLbl.TextSize = 13
modeLbl.TextXAlignment = Enum.TextXAlignment.Left

local modeValueLbl = Instance.new("TextLabel", speedModeRow)
modeValueLbl.Size = UDim2.new(0, 100, 0, 32)
modeValueLbl.Position = UDim2.new(1, -112, 0.5, -16)
modeValueLbl.BackgroundColor3 = CLR.Bind
modeValueLbl.BorderSizePixel = 0
modeValueLbl.Text = State.SpeedMode
modeValueLbl.TextColor3 = CLR.TextPrimary
modeValueLbl.Font = Enum.Font.GothamBold
modeValueLbl.TextSize = 12
corner(modeValueLbl, 6)
-- stroke eliminado (botón de la derecha)

local function updateModeDisplay()
    modeValueLbl.Text = State.SpeedMode
end

local function toggleSpeedMode()
    if State.SpeedMode == "Normal" then
        State.SpeedMode = "Carry"
    elseif State.SpeedMode == "Carry" then
        State.SpeedMode = "Lagger"
    else
        State.SpeedMode = "Normal"
    end
    updateModeDisplay()
    saveConfig()
end

modeValueLbl.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        toggleSpeedMode()
    end
end)

local laggerToggle = makeToggleRow(TabPages.Speed, "Lagger Mode (Auto Steal + Slow Speed)", State.LaggerEnabled, function(on)
    State.LaggerEnabled = on
    if on then
        if State.LaggerCarryEnabled then 
            State.LaggerCarryEnabled = false
            if laggerCarryToggle then laggerCarryToggle(false) end
        end
        Steal.AutoSteal = true
        startAutoSteal()
    else
        if not State.LaggerCarryEnabled then
            Steal.AutoSteal = false
            stopAutoSteal()
        end
    end
    saveConfig()
end, order); order = order + 1

local laggerCarryToggle = makeToggleRow(TabPages.Speed, "Lagger Carry Mode (Auto Steal + Carry Speed)", State.LaggerCarryEnabled, function(on)
    State.LaggerCarryEnabled = on
    if on then
        if State.LaggerEnabled then 
            State.LaggerEnabled = false
            if laggerToggle then laggerToggle(false) end
        end
        Steal.AutoSteal = true
        startAutoSteal()
    else
        if not State.LaggerEnabled then
            Steal.AutoSteal = false
            stopAutoSteal()
        end
    end
    saveConfig()
end, order); order = order + 1

order = 1
makeSectionLabel(TabPages.Mechanics, "AUTO STEAL", order); order = order + 1

local autoStealToggle = makeToggleRow(TabPages.Mechanics, "Auto Steal", Steal.AutoSteal, function(on)
    Steal.AutoSteal = on
    if on then startAutoSteal() else stopAutoSteal() end
    saveConfig()
end, order); order = order + 1

local radiusInputRow = Instance.new("Frame", TabPages.Mechanics)
radiusInputRow.Size = UDim2.new(1, 0, 0, 44)
radiusInputRow.BackgroundColor3 = CLR.OptionRow
radiusInputRow.BorderSizePixel = 0
radiusInputRow.LayoutOrder = order; order = order + 1
corner(radiusInputRow, 6)
stroke(radiusInputRow, CLR.OptionStroke, 1)

local radiusLbl = Instance.new("TextLabel", radiusInputRow)
radiusLbl.Size = UDim2.new(0.6, -12, 1, 0)
radiusLbl.Position = UDim2.new(0, 12, 0, 0)
radiusLbl.BackgroundTransparency = 1
radiusLbl.Text = "Steal Radius"
radiusLbl.TextColor3 = CLR.TextPrimary
radiusLbl.Font = Enum.Font.GothamBold
radiusLbl.TextSize = 13
radiusLbl.TextXAlignment = Enum.TextXAlignment.Left

local radiusBox = Instance.new("TextBox", radiusInputRow)
radiusBox.Size = UDim2.new(0, 80, 0, 32)
radiusBox.Position = UDim2.new(1, -92, 0.5, -16)
radiusBox.BackgroundColor3 = CLR.Bind
radiusBox.BorderSizePixel = 0
radiusBox.Text = tostring(Steal.StealRadius)
radiusBox.TextColor3 = CLR.TextPrimary
radiusBox.Font = Enum.Font.GothamBold
radiusBox.TextSize = 14
radiusBox.ClearTextOnFocus = true
corner(radiusBox, 6)
-- stroke eliminado (botón de la derecha)

radiusBox.FocusLost:Connect(function()
    local num = tonumber(radiusBox.Text)
    if num then
        local finalVal = math.clamp(num, 5, 100)
        radiusBox.Text = tostring(finalVal)
        Steal.StealRadius = finalVal
        saveConfig()
    else
        radiusBox.Text = tostring(Steal.StealRadius)
    end
end)

makeSectionLabel(TabPages.Mechanics, "COMBAT", order); order = order + 1

local antiRagdollToggle = makeToggleRow(TabPages.Mechanics, "Anti Ragdoll", State.AntiRagdoll, function(on)
    State.AntiRagdoll = on
    if on then startAntiRagdoll() else stopAntiRagdoll() end
    saveConfig()
end, order); order = order + 1

local medusaCounterToggle = makeToggleRow(TabPages.Mechanics, "Medusa Counter", State.MedusaCounter, function(on)
    State.MedusaCounter = on
    if on then setupMedusaCounter(LocalPlayer.Character) else stopMedusaCounter() end
    saveConfig()
end, order); order = order + 1

local batCounterToggle = makeToggleRow(TabPages.Mechanics, "Bat Counter (Anti-Ragdoll)", State.BatCounter, function(on)
    State.BatCounter = on
    if on then startBatCounter() else stopBatCounter() end
    saveConfig()
end, order); order = order + 1

local unwalkToggle = makeToggleRow(TabPages.Mechanics, "Unwalk (No Animations)", State.Unwalk, function(on)
    State.Unwalk = on
    if on then startUnwalk() else stopUnwalk() end
    saveConfig()
end, order); order = order + 1

order = 1
makeSectionLabel(TabPages.Movement, "INFINITE JUMP", order); order = order + 1

local infJumpToggle = makeToggleRow(TabPages.Movement, "Infinite Jump", State.InfJump, function(on)
    State.InfJump = on
    saveConfig()
end, order); order = order + 1

local jumpModeRow = Instance.new("Frame", TabPages.Movement)
jumpModeRow.Size = UDim2.new(1, 0, 0, 44)
jumpModeRow.BackgroundColor3 = CLR.OptionRow
jumpModeRow.BorderSizePixel = 0
jumpModeRow.LayoutOrder = order; order = order + 1
corner(jumpModeRow, 6)
stroke(jumpModeRow, CLR.OptionStroke, 1)

local jumpModeLbl = Instance.new("TextLabel", jumpModeRow)
jumpModeLbl.Size = UDim2.new(0.6, -12, 1, 0)
jumpModeLbl.Position = UDim2.new(0, 12, 0, 0)
jumpModeLbl.BackgroundTransparency = 1
jumpModeLbl.Text = "Jump Mode"
jumpModeLbl.TextColor3 = CLR.TextPrimary
jumpModeLbl.Font = Enum.Font.GothamBold
jumpModeLbl.TextSize = 13
jumpModeLbl.TextXAlignment = Enum.TextXAlignment.Left

local manualBtn = Instance.new("TextButton", jumpModeRow)
manualBtn.Size = UDim2.new(0, 70, 0, 32)
manualBtn.Position = UDim2.new(1, -152, 0.5, -16)
manualBtn.BackgroundColor3 = State.JumpMode == "Manual" and CLR.ToggleOn or CLR.Bind
manualBtn.BorderSizePixel = 0
manualBtn.Text = "Manual"
manualBtn.TextColor3 = CLR.TextPrimary
manualBtn.Font = Enum.Font.GothamBold
manualBtn.TextSize = 12
manualBtn.AutoButtonColor = false
corner(manualBtn, 6)
-- stroke eliminado (botón de la derecha)

local holdBtn = Instance.new("TextButton", jumpModeRow)
holdBtn.Size = UDim2.new(0, 70, 0, 32)
holdBtn.Position = UDim2.new(1, -74, 0.5, -16)
holdBtn.BackgroundColor3 = State.JumpMode == "Hold" and CLR.ToggleOn or CLR.Bind
holdBtn.BorderSizePixel = 0
holdBtn.Text = "Hold"
holdBtn.TextColor3 = CLR.TextPrimary
holdBtn.Font = Enum.Font.GothamBold
holdBtn.TextSize = 12
holdBtn.AutoButtonColor = false
corner(holdBtn, 6)
-- stroke eliminado (botón de la derecha)

local function updateJumpModeUI()
    manualBtn.BackgroundColor3 = State.JumpMode == "Manual" and CLR.ToggleOn or CLR.Bind
    holdBtn.BackgroundColor3 = State.JumpMode == "Hold" and CLR.ToggleOn or CLR.Bind
end

manualBtn.MouseButton1Click:Connect(function()
    State.JumpMode = "Manual"
    updateJumpModeUI()
    saveConfig()
end)

holdBtn.MouseButton1Click:Connect(function()
    State.JumpMode = "Hold"
    updateJumpModeUI()
    saveConfig()
end)

makeSectionLabel(TabPages.Movement, "AUTO MOVEMENT", order); order = order + 1

local autoLeftToggle = makeToggleRow(TabPages.Movement, "Auto Left (Path to left side)", State.AutoLeft, function(on)
    State.AutoLeft = on
    if on then
        if State.BatAimbot then State.BatAimbot = false; stopBatAimbot() end
        if State.AutoRight then State.AutoRight = false; stopAutoRight() end
        startAutoLeft()
    else
        stopAutoLeft()
    end
    saveConfig()
end, order); order = order + 1

local autoRightToggle = makeToggleRow(TabPages.Movement, "Auto Right (Path to right side)", State.AutoRight, function(on)
    State.AutoRight = on
    if on then
        if State.BatAimbot then State.BatAimbot = false; stopBatAimbot() end
        if State.AutoLeft then State.AutoLeft = false; stopAutoLeft() end
        startAutoRight()
    else
        stopAutoRight()
    end
    saveConfig()
end, order); order = order + 1

makeSectionLabel(TabPages.Movement, "UTILITY", order); order = order + 1

local dropBtn = Instance.new("TextButton", TabPages.Movement)
dropBtn.Size = UDim2.new(1, 0, 0, 38)
dropBtn.BackgroundColor3 = CLR.OptionRow
dropBtn.BorderSizePixel = 0
dropBtn.Text = "DROP BRAINROT (Ascend & Drop)"
dropBtn.TextColor3 = CLR.TextPrimary
dropBtn.Font = Enum.Font.GothamBold
dropBtn.TextSize = 13
dropBtn.LayoutOrder = order; order = order + 1
corner(dropBtn, 6)
stroke(dropBtn, CLR.OptionStroke, 1)

dropBtn.MouseButton1Click:Connect(function()
    runDropBrainrot()
    tween(dropBtn, 0.1, {BackgroundColor3 = CLR.TabBtnActive})
    task.delay(0.2, function() tween(dropBtn, 0.1, {BackgroundColor3 = CLR.OptionRow}) end)
end)

local tpDownBtn = Instance.new("TextButton", TabPages.Movement)
tpDownBtn.Size = UDim2.new(1, 0, 0, 38)
tpDownBtn.BackgroundColor3 = CLR.OptionRow
tpDownBtn.BorderSizePixel = 0
tpDownBtn.Text = "TELEPORT TO GROUND"
tpDownBtn.TextColor3 = CLR.TextPrimary
tpDownBtn.Font = Enum.Font.GothamBold
tpDownBtn.TextSize = 13
tpDownBtn.LayoutOrder = order; order = order + 1
corner(tpDownBtn, 6)
stroke(tpDownBtn, CLR.OptionStroke, 1)

tpDownBtn.MouseButton1Click:Connect(function()
    doTpDown()
    tween(tpDownBtn, 0.1, {BackgroundColor3 = CLR.TabBtnActive})
    task.delay(0.2, function() tween(tpDownBtn, 0.1, {BackgroundColor3 = CLR.OptionRow}) end)
end)

order = 1
makeSectionLabel(TabPages["Bat Aimbot"], "BAT AIMBOT CONFIGURATION", order); order = order + 1

local batAimbotToggle = makeToggleRow(TabPages["Bat Aimbot"], "Bat Aimbot (Auto Aim)", State.BatAimbot, function(on)
    State.BatAimbot = on
    if on then
        if State.AutoLeft then State.AutoLeft = false; stopAutoLeft() end
        if State.AutoRight then State.AutoRight = false; stopAutoRight() end
        startBatAimbot()
    else
        stopBatAimbot()
    end
    saveConfig()
end, order); order = order + 1

local autoSwingToggle = makeToggleRow(TabPages["Bat Aimbot"], "Auto Swing (Auto Hit)", State.AutoSwing, function(on)
    State.AutoSwing = on
    saveConfig()
end, order); order = order + 1

makeSectionLabel(TabPages["Bat Aimbot"], "STATUS", order); order = order + 1

local statusRow = Instance.new("Frame", TabPages["Bat Aimbot"])
statusRow.Size = UDim2.new(1, 0, 0, 38)
statusRow.BackgroundColor3 = CLR.OptionRow
statusRow.BorderSizePixel = 0
statusRow.LayoutOrder = order; order = order + 1
corner(statusRow, 6)
stroke(statusRow, CLR.OptionStroke, 1)

local statusLbl = Instance.new("TextLabel", statusRow)
statusLbl.Size = UDim2.new(1, -20, 1, 0)
statusLbl.Position = UDim2.new(0, 12, 0, 0)
statusLbl.BackgroundTransparency = 1
statusLbl.Text = "Aimbot will automatically track and hit nearby players"
statusLbl.TextColor3 = CLR.TextSecondary
statusLbl.Font = Enum.Font.Gotham
statusLbl.TextSize = 12
statusLbl.TextXAlignment = Enum.TextXAlignment.Left
statusLbl.TextWrapped = true

order = 1
makeSectionLabel(TabPages.Performance, "PERFORMANCE BOOSTS", order); order = order + 1

local fpsBoostToggle = makeToggleRow(TabPages.Performance, "FPS Boost (Disables visuals)", State.FpsBoost, function(on)
    State.FpsBoost = on
    if on then pcall(applyFPSBoost) end
    saveConfig()
end, order); order = order + 1

local infoRow = Instance.new("Frame", TabPages.Performance)
infoRow.Size = UDim2.new(1, 0, 0, 60)
infoRow.BackgroundColor3 = CLR.OptionRow
infoRow.BorderSizePixel = 0
infoRow.LayoutOrder = order; order = order + 1
corner(infoRow, 6)
stroke(infoRow, CLR.OptionStroke, 1)

local infoLbl = Instance.new("TextLabel", infoRow)
infoLbl.Size = UDim2.new(1, -20, 1, 0)
infoLbl.Position = UDim2.new(0, 12, 0, 0)
infoLbl.BackgroundTransparency = 1
infoLbl.Text = "FPS Boost removes shadows, effects, and particles to maximize performance. Rejoin to fully revert changes."
infoLbl.TextColor3 = CLR.TextSecondary
infoLbl.Font = Enum.Font.Gotham
infoLbl.TextSize = 11
infoLbl.TextXAlignment = Enum.TextXAlignment.Left
infoLbl.TextWrapped = true

order = 1
makeSectionLabel(TabPages.Settings, "CONFIGURATION", order); order = order + 1

local saveBtn = Instance.new("TextButton", TabPages.Settings)
saveBtn.Size = UDim2.new(1, 0, 0, 38)
saveBtn.BackgroundColor3 = CLR.OptionRow
saveBtn.BorderSizePixel = 0
saveBtn.Text = "SAVE CONFIGURATION"
saveBtn.TextColor3 = CLR.TextPrimary
saveBtn.Font = Enum.Font.GothamBold
saveBtn.TextSize = 13
saveBtn.LayoutOrder = order; order = order + 1
corner(saveBtn, 6)
stroke(saveBtn, CLR.OptionStroke, 1)

saveBtn.MouseButton1Click:Connect(function()
    saveConfig()
    tween(saveBtn, 0.1, {BackgroundColor3 = CLR.TabBtnActive})
    task.delay(0.2, function() tween(saveBtn, 0.1, {BackgroundColor3 = CLR.OptionRow}) end)
end)

local loadBtn = Instance.new("TextButton", TabPages.Settings)
loadBtn.Size = UDim2.new(1, 0, 0, 38)
loadBtn.BackgroundColor3 = CLR.OptionRow
loadBtn.BorderSizePixel = 0
loadBtn.Text = "LOAD CONFIGURATION"
loadBtn.TextColor3 = CLR.TextPrimary
loadBtn.Font = Enum.Font.GothamBold
loadBtn.TextSize = 13
loadBtn.LayoutOrder = order; order = order + 1
corner(loadBtn, 6)
stroke(loadBtn, CLR.OptionStroke, 1)

loadBtn.MouseButton1Click:Connect(function()
    loadConfig()
    normalSpeedBox.Text = tostring(State.NormalSpeed)
    carrySpeedBox.Text = tostring(State.CarrySpeed)
    laggerSpeedBox.Text = tostring(State.LaggerSpeed)
    laggerCarrySpeedBox.Text = tostring(State.LaggerCarrySpeed)
    radiusBox.Text = tostring(Steal.StealRadius)
    updateModeDisplay()
    if laggerToggle then laggerToggle(State.LaggerEnabled) end
    if laggerCarryToggle then laggerCarryToggle(State.LaggerCarryEnabled) end
    if autoStealToggle then autoStealToggle(Steal.AutoSteal) end
    if antiRagdollToggle then antiRagdollToggle(State.AntiRagdoll) end
    if medusaCounterToggle then medusaCounterToggle(State.MedusaCounter) end
    if batCounterToggle then batCounterToggle(State.BatCounter) end
    if unwalkToggle then unwalkToggle(State.Unwalk) end
    if infJumpToggle then infJumpToggle(State.InfJump) end
    updateJumpModeUI()
    if autoLeftToggle then autoLeftToggle(State.AutoLeft) end
    if autoRightToggle then autoRightToggle(State.AutoRight) end
    if batAimbotToggle then batAimbotToggle(State.BatAimbot) end
    if autoSwingToggle then autoSwingToggle(State.AutoSwing) end
    if fpsBoostToggle then fpsBoostToggle(State.FpsBoost) end
    tween(loadBtn, 0.1, {BackgroundColor3 = CLR.TabBtnActive})
    task.delay(0.2, function() tween(loadBtn, 0.1, {BackgroundColor3 = CLR.OptionRow}) end)
end)

makeSectionLabel(TabPages.Settings, "MOBILE BUTTONS", order); order = order + 1

local lockButtonsToggle = makeToggleRow(TabPages.Settings, "Lock Button Positions", MobileButtons.Locked, function(on)
    MobileButtons.Locked = on
    saveConfig()
end, order); order = order + 1

local showButtonsToggle = makeToggleRow(TabPages.Settings, "Show Mobile Buttons", MobileButtons.Visible, function(on)
    MobileButtons.Visible = on
    for _, container in ipairs(MobileButtons.Containers) do
        container.Visible = on
    end
    saveConfig()
end, order); order = order + 1

makeSectionLabel(TabPages.Settings, "KEYBINDS", order); order = order + 1

local keybindInfo = Instance.new("TextLabel", TabPages.Settings)
keybindInfo.Size = UDim2.new(1, -20, 0, 70)
keybindInfo.Position = UDim2.new(0, 12, 0, 0)
keybindInfo.BackgroundTransparency = 1
keybindInfo.Text = "Left Ctrl / Select: Toggle GUI\nQ / R3: Cycle Speed Modes\nL / D-Pad Left: Auto Left\nD-Pad Right: Auto Right\nH / Y: Drop Brainrot\nL3: Toggle Lagger Mode"
keybindInfo.TextColor3 = CLR.TextSecondary
keybindInfo.Font = Enum.Font.Gotham
keybindInfo.TextSize = 12
keybindInfo.TextXAlignment = Enum.TextXAlignment.Left
keybindInfo.TextYAlignment = Enum.TextYAlignment.Top
keybindInfo.LayoutOrder = order; order = order + 1

local function setupChar(char)
    task.wait(0.1)
    h   = char:WaitForChild("Humanoid", 5)
    hrp = char:WaitForChild("HumanoidRootPart", 5)
    if not h or not hrp then return end
    local head = char:FindFirstChild("Head")
    if head then
        local old = head:FindFirstChild("forcevsBB"); if old then old:Destroy() end
        local bb = Instance.new("BillboardGui", head)
        bb.Name="forcevsBB"; bb.Size=UDim2.new(0,130,0,36)
        bb.StudsOffset=Vector3.new(0,3,0); bb.AlwaysOnTop=true
        local sl = Instance.new("TextLabel", bb)
        sl.Name="SpeedLbl"; sl.Size=UDim2.new(1,0,1,0)
        sl.BackgroundTransparency=1; sl.Text="0.0"
        sl.TextColor3=Color3.fromRGB(210,210,210)
        sl.Font=Enum.Font.GothamBlack; sl.TextScaled=true
        sl.TextStrokeTransparency=0.1
    end
    stopAntiRagdoll()
    if State.AntiRagdoll then task.wait(0.5); startAntiRagdoll() end
    if Conns.unwalk then Conns.unwalk:Disconnect(); Conns.unwalk=nil end
    unwalkAnimateRef = nil
    if State.Unwalk then task.wait(0.3); startUnwalk() end
    if State.MedusaCounter then setupMedusaCounter(char) end
    if State.BatAimbot then stopBatAimbot(); task.wait(0.2); pcall(startBatAimbot) end
    if State.BatCounter then task.wait(0.3); startBatCounter() end
end

LocalPlayer.CharacterAdded:Connect(setupChar)
if LocalPlayer.Character then task.spawn(function() setupChar(LocalPlayer.Character) end) end

RunService.Stepped:Connect(function()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            for _, part in ipairs(p.Character:GetChildren()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end
end)

UIS.JumpRequest:Connect(function()
    if not State.InfJump then return end
    if State.JumpMode ~= "Manual" then return end
    local c = LocalPlayer.Character; if not c then return end
    local root = c:FindFirstChild("HumanoidRootPart"); if not root then return end
    root.Velocity = Vector3.new(root.Velocity.X, 55, root.Velocity.Z)
end)

RunService.Heartbeat:Connect(function()
    if not State.InfJump then return end
    if State.JumpMode ~= "Hold" then return end
    local c = LocalPlayer.Character; if not c then return end
    local root = c:FindFirstChild("HumanoidRootPart"); if not root then return end
    local hum = c:FindFirstChildOfClass("Humanoid")
    local jumpHeld = UIS:IsKeyDown(Enum.KeyCode.Space) or (hum and hum.Jump == true)
    if jumpHeld and root.Velocity.Y < 30 then
        root.Velocity = Vector3.new(root.Velocity.X, 55, root.Velocity.Z)
    end
    if root.Velocity.Y < -120 then
        root.Velocity = Vector3.new(root.Velocity.X, -120, root.Velocity.Z)
    end
end)

local function getCurrentSpeed()
    if State.LaggerCarryEnabled then
        return State.LaggerCarrySpeed
    elseif State.LaggerEnabled then
        return State.LaggerSpeed
    elseif State.SpeedMode == "Carry" then
        return State.CarrySpeed
    else
        return State.NormalSpeed
    end
end

RunService.RenderStepped:Connect(function()
    if not (h and hrp) then return end
    if not State.BatAimbot and not State.AutoLeft and not State.AutoRight then
        local md  = h.MoveDirection
        local spd = getCurrentSpeed()
        if md.Magnitude > 0 then
            lastMoveDir = md
            hrp.AssemblyLinearVelocity = Vector3.new(md.X*spd, hrp.AssemblyLinearVelocity.Y, md.Z*spd)
        elseif State.AntiRagdoll and lastMoveDir.Magnitude > 0 then
            local anyHeld = false
            for key in pairs(MOVE_KEYS) do
                if UIS:IsKeyDown(key) then anyHeld=true; break end
            end
            if anyHeld then
                hrp.AssemblyLinearVelocity = Vector3.new(lastMoveDir.X*spd, hrp.AssemblyLinearVelocity.Y, lastMoveDir.Z*spd)
            end
        end
    end
    pcall(function()
        local hd = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head")
        if hd then
            local bb = hd:FindFirstChild("forcevsBB")
            local sl = bb and bb:FindFirstChild("SpeedLbl")
            if sl then
                sl.Text = string.format("%.1f", Vector3.new(hrp.AssemblyLinearVelocity.X,0,hrp.AssemblyLinearVelocity.Z).Magnitude)
            end
        end
    end)
end)

UIS.InputBegan:Connect(function(inp, gp)
    local isKb = inp.UserInputType == Enum.UserInputType.Keyboard
    local isGp = inp.UserInputType == Enum.UserInputType.Gamepad1
              or inp.UserInputType == Enum.UserInputType.Gamepad2
    if not isKb and not isGp then return end
    if isKb and gp then return end
    local kc = inp.KeyCode; if kc == Enum.KeyCode.Unknown then return end
    if kc == Enum.KeyCode.LeftControl or kc == Enum.KeyCode.ButtonSelect then
        State.GuiVisible = not State.GuiVisible
        MainFrame.Visible = State.GuiVisible
        MiniBtn.Visible   = not State.GuiVisible
    elseif kc == Enum.KeyCode.Q or kc == Enum.KeyCode.ButtonR3 then
        toggleSpeedMode()
    elseif kc == Enum.KeyCode.L or kc == Enum.KeyCode.DPadLeft then
        State.AutoLeft = not State.AutoLeft
        if State.AutoLeft then
            if State.BatAimbot then State.BatAimbot=false; stopBatAimbot() end
            if State.AutoRight  then State.AutoRight=false; stopAutoRight()  end
            startAutoLeft()
            if autoLeftToggle then autoLeftToggle(true) end
        else
            stopAutoLeft()
            if autoLeftToggle then autoLeftToggle(false) end
        end
        saveConfig()
    elseif kc == Enum.KeyCode.DPadRight then
        State.AutoRight = not State.AutoRight
        if State.AutoRight then
            if State.BatAimbot then State.BatAimbot=false; stopBatAimbot() end
            if State.AutoLeft   then State.AutoLeft=false;  stopAutoLeft()  end
            startAutoRight()
            if autoRightToggle then autoRightToggle(true) end
        else
            stopAutoRight()
            if autoRightToggle then autoRightToggle(false) end
        end
        saveConfig()
    elseif kc == Enum.KeyCode.H or kc == Enum.KeyCode.ButtonY then
        if not State.DropEnabled then runDropBrainrot() end
    elseif kc == Enum.KeyCode.ButtonL3 then
        State.LaggerEnabled = not State.LaggerEnabled
        if laggerToggle then laggerToggle(State.LaggerEnabled) end
        if State.LaggerEnabled then
            if State.LaggerCarryEnabled then 
                State.LaggerCarryEnabled = false
                if laggerCarryToggle then laggerCarryToggle(false) end
            end
            Steal.AutoSteal = true
            startAutoSteal()
        else
            if not State.LaggerCarryEnabled then
                Steal.AutoSteal = false
                stopAutoSteal()
            end
        end
        saveConfig()
    end
end)

task.spawn(function()
    task.wait(0.5)
    createMobilePanel()
end)

if Steal.AutoSteal then task.spawn(startAutoSteal) end
if State.BatAimbot then task.spawn(startBatAimbot) end
if State.BatCounter then task.spawn(startBatCounter) end
if State.AntiRagdoll then task.spawn(startAntiRagdoll) end
if State.AutoLeft then task.spawn(startAutoLeft) end
if State.AutoRight then task.spawn(startAutoRight) end
if State.Unwalk then task.spawn(startUnwalk) end

loadConfig()
task.delay(1, function() pcall(saveConfig) end)

print("[force.vs] Cargado - Letras con sombra chorreada aplicadas.")