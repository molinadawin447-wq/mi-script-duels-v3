-- LocalScript

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BotonesUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

-- ========================
-- CONTADOR DE FPS (esquina superior derecha)
-- ========================
local fpsFrame = Instance.new("Frame")
fpsFrame.Name = "FPS"
fpsFrame.Size = UDim2.new(0, 80, 0, 30)
fpsFrame.Position = UDim2.new(1, -90, 0, 10)
fpsFrame.AnchorPoint = Vector2.new(1, 0)
fpsFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
fpsFrame.BorderSizePixel = 0
local cornerFps = Instance.new("UICorner")
cornerFps.CornerRadius = UDim.new(0, 8)
cornerFps.Parent = fpsFrame

local fpsLabel = Instance.new("TextLabel")
fpsLabel.Name = "FPSLabel"
fpsLabel.Size = UDim2.new(1, 0, 1, 0)
fpsLabel.BackgroundTransparency = 1
fpsLabel.Text = "FPS: 0"
fpsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
fpsLabel.Font = Enum.Font.GothamBold
fpsLabel.TextSize = 16
fpsLabel.TextXAlignment = Enum.TextXAlignment.Center
fpsLabel.TextYAlignment = Enum.TextYAlignment.Center
fpsLabel.Parent = fpsFrame
fpsFrame.Parent = screenGui

-- Actualizar FPS
local frameCount = 0
local lastTime = os.clock()
RunService.RenderStepped:Connect(function()
    frameCount = frameCount + 1
    local currentTime = os.clock()
    if currentTime - lastTime >= 1 then
        fpsLabel.Text = "FPS: " .. frameCount
        frameCount = 0
        lastTime = currentTime
    end
end)

-- ========================
-- CONTENEDOR PRINCIPAL (botones derecha)
-- ========================
local frame = Instance.new("Frame")
frame.Name = "Botones"
frame.Size = UDim2.new(0, 276, 0, 260)
frame.AnchorPoint = Vector2.new(1, 0)
frame.Position = UDim2.new(1, -10, 0, 25)
frame.BackgroundTransparency = 1
frame.Parent = screenGui

local botonSize = 65
local separacionX = 4
local separacionY = 4
local columnas = {1, 2, 4, 4}

for columna = 1, 4 do
    local cantidad = columnas[columna]
    for fila = 1, cantidad do
        local boton = Instance.new("TextButton")
        boton.Name = "Boton_" .. columna .. "_" .. fila
        boton.Size = UDim2.new(0, botonSize, 0, botonSize)

        local yInicial
        if columna == 1 or columna == 2 then
            yInicial = 0
        else
            local altura = cantidad * botonSize + (cantidad - 1) * separacionY
            yInicial = (260 - altura) / 2
        end

        boton.Position = UDim2.new(
            0,
            (columna - 1) * (botonSize + separacionX),
            0,
            yInicial + (fila - 1) * (botonSize + separacionY)
        )

        if columna == 1 and fila == 1 then
            boton.Text = "RESET"
        elseif columna == 2 and fila == 1 then
            boton.Text = "BAT V2"
        elseif columna == 2 and fila == 2 then
            boton.Text = "ANTI DESYNC"
        elseif columna == 3 and fila == 1 then
            boton.Text = "DROP BR"
        elseif columna == 3 and fila == 2 then
            boton.Text = "BAT AIMBOT"
        elseif columna == 3 and fila == 3 then
            boton.Text = "TP DOWN"
        elseif columna == 3 and fila == 4 then
            boton.Text = "LAGGER 1"
        elseif columna == 4 and fila == 1 then
            boton.Text = "AUTO LEFT"
        elseif columna == 4 and fila == 2 then
            boton.Text = "AUTO RIGHT"
        elseif columna == 4 and fila == 3 then
            boton.Text = "CARRY SPD"
        elseif columna == 4 and fila == 4 then
            boton.Text = "LAGGER 2"
        else
            boton.Text = ""
        end

        boton.TextColor3 = Color3.fromRGB(200, 200, 200)
        boton.TextSize = 17
        boton.Font = Enum.Font.GothamBold
        boton.TextScaled = false
        boton.TextWrapped = true
        boton.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
        boton.BorderSizePixel = 0
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 15)
        corner.Parent = boton
        boton.Parent = frame
    end
end

-- ========================
-- FUNCIONALIDAD RESET
-- ========================
local resetButton = frame:FindFirstChild("Boton_1_1")
if resetButton then
    local isResetting = false
    resetButton.MouseButton1Click:Connect(function()
        if isResetting then return end
        isResetting = true
        resetButton.BackgroundColor3 = Color3.fromRGB(128, 128, 128)
        task.wait(2)
        player:LoadCharacter()
        resetButton.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
        isResetting = false
    end)
end

-- ========================
-- FUNCIONALIDAD TP DOWN
-- ========================
local tpDownButton = frame:FindFirstChild("Boton_3_3")
if tpDownButton then
    tpDownButton.MouseButton1Click:Connect(function()
        local char = player.Character
        if not char then return end
        local rootPart = char:FindFirstChild("HumanoidRootPart")
        if not rootPart then return end
        local startPos = rootPart.Position
        local raycastParams = RaycastParams.new()
        raycastParams.FilterDescendantsInstances = {char}
        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
        local result = workspace:Raycast(startPos, Vector3.new(0, -500, 0), raycastParams)
        if result then
            rootPart.CFrame = CFrame.new(result.Position + Vector3.new(0, 3, 0))
        end
    end)
end

-- ================================================================
-- CONTENEDOR DEL BOTÓN NUMÉRICO (arrastrable) con barra DENTRO
-- ================================================================
local contenedor = Instance.new("Frame")
contenedor.Name = "ContenedorNum"
contenedor.Size = UDim2.new(0, 350, 0, 80)   -- Más ancho (antes 230)
contenedor.Position = UDim2.new(0.5, -175, 0.85, -40)  -- Centrado
contenedor.AnchorPoint = Vector2.new(0.5, 0.5)
contenedor.BackgroundTransparency = 1
contenedor.Parent = screenGui

-- Botón negro (fondo)
local numButton = Instance.new("TextButton")
numButton.Name = "NumButton"
numButton.Size = UDim2.new(1, 0, 1, 0)   -- Ocupa todo el contenedor
numButton.Position = UDim2.new(0, 0, 0, 0)
numButton.Text = "0%"
numButton.TextXAlignment = Enum.TextXAlignment.Left
numButton.TextYAlignment = Enum.TextYAlignment.Top
numButton.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
numButton.TextColor3 = Color3.fromRGB(200, 200, 200)
numButton.Font = Enum.Font.GothamBold
numButton.TextSize = 28
numButton.BorderSizePixel = 0

local cornerNum = Instance.new("UICorner")
cornerNum.CornerRadius = UDim.new(0, 10)
cornerNum.Parent = numButton

-- Padding para que el texto no esté pegado al borde
local padding = Instance.new("UIPadding")
padding.PaddingLeft = UDim.new(0, 12)
padding.PaddingTop = UDim.new(0, 8)
padding.Parent = numButton

numButton.Parent = contenedor

-- Barra de progreso (fondo gris) dentro del botón, en la parte inferior
local barraFondo = Instance.new("Frame")
barraFondo.Name = "BarraFondo"
barraFondo.Size = UDim2.new(1, 0, 0, 18)   -- Ocupa todo el ancho, altura 18
barraFondo.Position = UDim2.new(0, 0, 1, -18)  -- Anclada abajo
barraFondo.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
barraFondo.BorderSizePixel = 0

local cornerBarra = Instance.new("UICorner")
cornerBarra.CornerRadius = UDim.new(0, 8)
cornerBarra.Parent = barraFondo
barraFondo.Parent = numButton   -- <--- DENTRO del botón

-- Barra de progreso (relleno blanco/gris claro)
local barraProgreso = Instance.new("Frame")
barraProgreso.Name = "BarraProgreso"
barraProgreso.Size = UDim2.new(0, 0, 1, 0)
barraProgreso.Position = UDim2.new(0, 0, 0, 0)
barraProgreso.BackgroundColor3 = Color3.fromRGB(180, 180, 180)
barraProgreso.BorderSizePixel = 0

local cornerProgreso = Instance.new("UICorner")
cornerProgreso.CornerRadius = UDim.new(0, 8)
cornerProgreso.Parent = barraProgreso
barraProgreso.Parent = barraFondo

-- ================================================================
-- ARRASTRE DEL CONTENEDOR (ratón y dedo)
-- ================================================================
local draggingCont = false
local dragStartCont = nil
local startPosCont = nil

local function onInputBeganCont(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingCont = true
        dragStartCont = input.Position
        startPosCont = contenedor.Position
    end
end

local function onInputEndedCont(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingCont = false
    end
end

local function onInputChangedCont(input)
    if draggingCont and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStartCont
        contenedor.Position = UDim2.new(0, startPosCont.X.Offset + delta.X, 0, startPosCont.Y.Offset + delta.Y)
    end
end

contenedor.InputBegan:Connect(onInputBeganCont)
contenedor.InputEnded:Connect(onInputEndedCont)
UserInputService.InputChanged:Connect(onInputChangedCont)

-- ================================================================
-- LÓGICA DE CARGA AUTOMÁTICA (0 → 100 en 2s, pausa 2s, repite)
-- ================================================================
local function iniciarCiclo()
    while true do
        local valor = 0
        local tiempoCarga = 2
        local inicio = os.clock()

        while valor < 100 do
            local elapsed = os.clock() - inicio
            local progreso = math.min(elapsed / tiempoCarga, 1)
            valor = math.floor(progreso * 100)
            
            numButton.Text = valor .. "%"
            barraProgreso.Size = UDim2.new(progreso, 0, 1, 0)
            
            task.wait(0.02)
        end

        numButton.Text = "100%"
        barraProgreso.Size = UDim2.new(1, 0, 1, 0)

        task.wait(2)
    end
end

task.spawn(iniciarCiclo)