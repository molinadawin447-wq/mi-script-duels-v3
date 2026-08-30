local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local player = Players.LocalPlayer
local InstaResetHub = Instance.new("ScreenGui")
InstaResetHub.Name = "InstaResetHub"
InstaResetHub.ResetOnSpawn = false
InstaResetHub.DisplayOrder = 999
InstaResetHub.Parent = CoreGui
InstaResetHub.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Active = true
MainFrame.ClipsDescendants = true
MainFrame.Position = UDim2.new(0, 30, 0, 137)
MainFrame.Size = UDim2.new(0, 210, 0, 162)
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MainFrame.BackgroundTransparency = 1
MainFrame.BorderSizePixel = 0
MainFrame.Parent = InstaResetHub
local UICorner = Instance.new("UICorner")
UICorner.Name = "UICorner"
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame
local UIStroke = Instance.new("UIStroke")
UIStroke.Name = "UIStroke"
UIStroke.Color = Color3.fromRGB(255, 255, 255)
UIStroke.Thickness = 3.5
UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
UIStroke.Parent = MainFrame
local ImageLabel = Instance.new("ImageLabel")
ImageLabel.Name = "ImageLabel"
ImageLabel.Position = UDim2.new(0, 12, 0, 10)
ImageLabel.Size = UDim2.new(0, 22, 0, 22)
ImageLabel.BackgroundTransparency = 1
ImageLabel.BorderSizePixel = 0
ImageLabel.Image = "rbxassetid://110054250696175"
ImageLabel.Parent = MainFrame
local TextLabel = Instance.new("TextLabel")
TextLabel.Name = "TextLabel"
TextLabel.Position = UDim2.new(0, 38, 0, 6)
TextLabel.Size = UDim2.new(1, -50, 0, 30)
TextLabel.BackgroundTransparency = 1
TextLabel.Text = "Insta Reset"
TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TextLabel.TextSize = 17
TextLabel.Font = Enum.Font.GothamBlack
TextLabel.TextXAlignment = Enum.TextXAlignment.Left
TextLabel.Parent = MainFrame
local TextButton = Instance.new("TextButton")
TextButton.Name = "TextButton"
TextButton.Position = UDim2.new(1, -36, 0, 6)
TextButton.Size = UDim2.new(0, 28, 0, 28)
TextButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
TextButton.BackgroundTransparency = 0.3
TextButton.BorderSizePixel = 0
TextButton.Text = "â–¼"
TextButton.TextColor3 = Color3.fromRGB(255, 255, 255)
TextButton.TextSize = 14
TextButton.Font = Enum.Font.GothamBlack
TextButton.AutoButtonColor = false
TextButton.Parent = MainFrame
local UICorner2 = Instance.new("UICorner")
UICorner2.Name = "UICorner"
UICorner2.CornerRadius = UDim.new(0, 7)
UICorner2.Parent = TextButton
local UIStroke2 = Instance.new("UIStroke")
UIStroke2.Name = "UIStroke"
UIStroke2.Color = Color3.fromRGB(255, 255, 255)
UIStroke2.Thickness = 2
UIStroke2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
UIStroke2.Parent = TextButton
local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Position = UDim2.new(0, 0, 0, 44)
Content.Size = UDim2.new(1, 0, 1, -44)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame
local TextButton2 = Instance.new("TextButton")
TextButton2.Name = "TextButton"
TextButton2.Position = UDim2.new(0, 10, 0, 4)
TextButton2.Size = UDim2.new(1, -20, 0, 38)
TextButton2.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
TextButton2.BackgroundTransparency = 0.3
TextButton2.BorderSizePixel = 0
TextButton2.Text = "INSTA RESPAWN"
TextButton2.TextColor3 = Color3.fromRGB(255, 255, 255)
TextButton2.TextSize = 14
TextButton2.Font = Enum.Font.GothamBlack
TextButton2.AutoButtonColor = false
TextButton2.Parent = Content
TextButton2.ZIndex = 2
local UICorner3 = Instance.new("UICorner")
UICorner3.Name = "UICorner"
UICorner3.CornerRadius = UDim.new(0, 9)
UICorner3.Parent = TextButton2
local UIStroke3 = Instance.new("UIStroke")
UIStroke3.Name = "UIStroke"
UIStroke3.Color = Color3.fromRGB(255, 255, 255)
UIStroke3.Thickness = 2
UIStroke3.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
UIStroke3.Transparency = 0.4
UIStroke3.Parent = TextButton2
local TextButton3 = Instance.new("TextButton")
TextButton3.Name = "TextButton"
TextButton3.Position = UDim2.new(0, 10, 0, 48)
TextButton3.Size = UDim2.new(1, -20, 0, 28)
TextButton3.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
TextButton3.BackgroundTransparency = 0.3
TextButton3.BorderSizePixel = 0
TextButton3.Text = "KeyBind: Q"
TextButton3.TextColor3 = Color3.fromRGB(255, 255, 255)
TextButton3.TextSize = 12
TextButton3.Font = Enum.Font.GothamBlack
TextButton3.AutoButtonColor = false
TextButton3.Parent = Content
local UICorner4 = Instance.new("UICorner")
UICorner4.Name = "UICorner"
UICorner4.CornerRadius = UDim.new(0, 9)
UICorner4.Parent = TextButton3
local UIStroke4 = Instance.new("UIStroke")
UIStroke4.Name = "UIStroke"
UIStroke4.Color = Color3.fromRGB(255, 255, 255)
UIStroke4.Thickness = 2
UIStroke4.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
UIStroke4.Transparency = 0.4
UIStroke4.Parent = TextButton3
local TextButton4 = Instance.new("TextButton")
TextButton4.Name = "TextButton"
TextButton4.Position = UDim2.new(0, 10, 0, 82)
TextButton4.Size = UDim2.new(1, -20, 0, 28)
TextButton4.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
TextButton4.BackgroundTransparency = 0.3
TextButton4.BorderSizePixel = 0
TextButton4.Text = "Auto Reset: OFF"
TextButton4.TextColor3 = Color3.fromRGB(160, 160, 160)
TextButton4.TextSize = 11
TextButton4.Font = Enum.Font.GothamBlack
TextButton4.AutoButtonColor = false
TextButton4.Parent = Content
local UICorner5 = Instance.new("UICorner")
UICorner5.Name = "UICorner"
UICorner5.CornerRadius = UDim.new(0, 9)
UICorner5.Parent = TextButton4
local UIStroke5 = Instance.new("UIStroke")
UIStroke5.Name = "UIStroke"
UIStroke5.Color = Color3.fromRGB(255, 255, 255)
UIStroke5.Thickness = 2
UIStroke5.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
UIStroke5.Transparency = 0.4
UIStroke5.Parent = TextButton4
local isOpen = true
local autoResetEnabled = false
local resetRemote = nil
local RESET_GUID = "f888ee6e-c86d-46e1-93d7-0639d6635d42"
pcall(function()
    if hookfunction and newcclosure then
        local oldFire
        oldFire = hookfunction(Instance.new("RemoteEvent").FireServer, newcclosure(function(self, ...)
            if not resetRemote and typeof(self) == "Instance" and self:IsA("RemoteEvent") and self.Name:sub(1,3) == "RE/" then 
                resetRemote = self 
            end
            return oldFire(self, ...)
        end))
    end
end)
task.spawn(function()
    task.wait(2)
    if resetRemote then return end
    for _, desc in ipairs(game:GetDescendants()) do
        if desc:IsA("RemoteEvent") and desc.Name:sub(1,3) == "RE/" then 
            resetRemote = desc
            break 
        end
    end
end)
local function instaReset()
    if not resetRemote then
        for _, desc in ipairs(game:GetDescendants()) do
            if desc:IsA("RemoteEvent") and desc.Name:sub(1,3) == "RE/" then 
                resetRemote = desc
                break 
            end
        end
    end
    if not resetRemote then 
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.Health = 0
            end
        end
        return 
    end
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.Health <= 0 then 
        pcall(function() 
            resetRemote:FireServer(RESET_GUID, player, "balloon") 
        end)
        return 
    end
    local resetDetected = false
    local conns = {}
    if humanoid then
        table.insert(conns, humanoid.Died:Connect(function() 
            resetDetected = true 
        end))
        table.insert(conns, humanoid:GetPropertyChangedSignal("Health"):Connect(function() 
            if humanoid.Health <= 0 then 
                resetDetected = true 
            end 
        end))
    end
    if character then 
        table.insert(conns, character.AncestryChanged:Connect(function(_, parent) 
            if not parent then 
                resetDetected = true 
            end 
        end)) 
    end
    task.spawn(function()
        for _ = 1, 50 do
            if resetDetected then break end
            pcall(function() 
                resetRemote:FireServer(RESET_GUID, player, "balloon") 
            end)
            task.wait()
        end
        for _, conn in ipairs(conns) do 
            pcall(function() 
                conn:Disconnect() 
            end) 
        end
    end)
end
pcall(function()
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
end)
player.CharacterAdded:Connect(function(character)
    pcall(function()
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
    end)
end)
TextButton.MouseButton1Click:Connect(function()
    isOpen = not isOpen
    Content.Visible = isOpen
    TextButton.Text = isOpen and "â–¼" or "â–²"
    local targetSize = isOpen and UDim2.new(0, 210, 0, 162) or UDim2.new(0, 210, 0, 44)
    local tween = TweenService:Create(MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = targetSize
    })
    tween:Play()
end)
local dragging = false
local dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)
TextButton2.MouseButton1Click:Connect(function()
    TextButton2.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    TextButton2.BackgroundTransparency = 0.3
    instaReset()
    task.wait(0.15)
    TextButton2.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    TextButton2.BackgroundTransparency = 0.3
end)
TextButton4.MouseButton1Click:Connect(function()
    autoResetEnabled = not autoResetEnabled
    TextButton4.Text = autoResetEnabled and "Auto Reset: ON" or "Auto Reset: OFF"
    TextButton4.TextColor3 = autoResetEnabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(160, 160, 160)
    UIStroke5.Transparency = autoResetEnabled and 0.15 or 0.4
end)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Q and input.UserInputType == Enum.UserInputType.Keyboard then
        instaReset()
    end
end)
RunService.Heartbeat:Connect(function()
    if autoResetEnabled then
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health <= 0 then
                instaReset()
            end
        end
    end
end)
print("[InstaResetHub] ChargÃ© avec succÃ¨s !")