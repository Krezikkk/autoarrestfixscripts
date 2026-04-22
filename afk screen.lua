local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local limit = 1000000

-- Number formatting function (k, m)
local function format(val)
    if val >= 1000000 then
        return string.format("%d (%.1fm)", val, val / 1000000)
    elseif val >= 1000 then
        return string.format("%d (%.1fk)", val, val / 1000)
    end
    return tostring(val)
end

-- Create Main GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RenderShield"
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 999999
screenGui.Parent = game:GetService("CoreGui")

-- Main Background
local blackBackground = Instance.new("Frame")
blackBackground.Size = UDim2.new(1, 0, 1, 0)
blackBackground.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
blackBackground.BorderSizePixel = 0
blackBackground.Parent = screenGui

-- Dark Premium Gradient Background
local bgGradient = Instance.new("UIGradient")
bgGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 25)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(5, 5, 5))
})
bgGradient.Rotation = 90
bgGradient.Parent = blackBackground

-- Particle Container
local particleContainer = Instance.new("Frame")
particleContainer.Size = UDim2.new(1, 0, 1, 0)
particleContainer.BackgroundTransparency = 1
particleContainer.ZIndex = 1
particleContainer.Parent = blackBackground

-- Center Container for UI elements
local mainContainer = Instance.new("Frame")
mainContainer.Size = UDim2.new(0, 460, 0, 140)
mainContainer.Position = UDim2.new(0.5, -230, 0.5, -70)
mainContainer.BackgroundTransparency = 1
mainContainer.ZIndex = 2
mainContainer.Parent = blackBackground

-- Stats Panel (Left)
local statsText = Instance.new("TextLabel")
statsText.Size = UDim2.new(0.5, -10, 1, 0)
statsText.BackgroundColor3 = Color3.fromRGB(28, 27, 31)
statsText.TextColor3 = Color3.fromRGB(230, 225, 229)
statsText.Font = Enum.Font.GothamMedium
statsText.TextSize = 15
statsText.TextXAlignment = Enum.TextXAlignment.Left
statsText.TextYAlignment = Enum.TextYAlignment.Top
statsText.Text = "Loading data..."
statsText.ZIndex = 2
statsText.Parent = mainContainer
Instance.new("UICorner", statsText).CornerRadius = UDim.new(0, 12)

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 15)
padding.PaddingLeft = UDim.new(0, 15)
padding.PaddingRight = UDim.new(0, 15)
padding.PaddingBottom = UDim.new(0, 15)
padding.Parent = statsText

-- Buttons Panel (Right)
local buttonsFrame = Instance.new("Frame")
buttonsFrame.Size = UDim2.new(0.5, -10, 1, 0)
buttonsFrame.Position = UDim2.new(0.5, 10, 0, 0)
buttonsFrame.BackgroundTransparency = 1
buttonsFrame.ZIndex = 2
buttonsFrame.Parent = mainContainer

local holdBtn = Instance.new("TextButton")
holdBtn.Size = UDim2.new(1, 0, 0.45, 0)
holdBtn.Text = "HOLD (E) - RENDER"
holdBtn.Font = Enum.Font.GothamBold
holdBtn.TextSize = 14
holdBtn.BackgroundColor3 = Color3.fromRGB(73, 69, 79)
holdBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
holdBtn.ZIndex = 2
holdBtn.Parent = buttonsFrame
Instance.new("UICorner", holdBtn).CornerRadius = UDim.new(0, 8)

local exitBtn = Instance.new("TextButton")
exitBtn.Size = UDim2.new(1, 0, 0.45, 0)
exitBtn.Position = UDim2.new(0, 0, 0.55, 0)
exitBtn.Text = "EXIT"
exitBtn.Font = Enum.Font.GothamBold
exitBtn.TextSize = 14
exitBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
exitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
exitBtn.ZIndex = 2
exitBtn.Parent = buttonsFrame
Instance.new("UICorner", exitBtn).CornerRadius = UDim.new(0, 8)

-- ==========================================
-- Facts Panel (Bottom)
-- ==========================================
local factsText = Instance.new("TextLabel")
factsText.Size = UDim2.new(0, 460, 0, 80)
factsText.Position = UDim2.new(0.5, -230, 0.5, 80)
factsText.BackgroundColor3 = Color3.fromRGB(28, 27, 31)
factsText.TextColor3 = Color3.fromRGB(230, 225, 229)
factsText.Font = Enum.Font.GothamMedium
factsText.TextSize = 14
factsText.TextWrapped = true
factsText.TextXAlignment = Enum.TextXAlignment.Center
factsText.TextYAlignment = Enum.TextYAlignment.Center
factsText.Text = "Loading interesting facts..."
factsText.ZIndex = 2
factsText.Parent = blackBackground
Instance.new("UICorner", factsText).CornerRadius = UDim.new(0, 12)

local factsPadding = Instance.new("UIPadding")
factsPadding.PaddingTop = UDim.new(0, 15)
factsPadding.PaddingLeft = UDim.new(0, 15)
factsPadding.PaddingRight = UDim.new(0, 15)
factsPadding.PaddingBottom = UDim.new(0, 15)
factsPadding.Parent = factsText

-- Variables for Event Connections (to prevent memory leaks)
local inputBeganConn
local inputEndedConn
local isExiting = false
local timerTask

-- Exit Button Logic
exitBtn.MouseButton1Click:Connect(function()
    if isExiting then
        -- 1. Restore Render
        RunService:Set3dRenderingEnabled(true)
        
        -- 2. Disconnect key events to fix the bug
        if inputBeganConn then inputBeganConn:Disconnect() end
        if inputEndedConn then inputEndedConn:Disconnect() end
        
        -- 3. Destroy GUI
        screenGui:Destroy()
    else
        isExiting = true
        exitBtn.BackgroundColor3 = Color3.fromRGB(255, 180, 0)
        
        local timeLeft = 3
        exitBtn.Text = "CONFIRM (" .. timeLeft .. "s)"
        
        if timerTask then task.cancel(timerTask) end
        timerTask = task.spawn(function()
            while timeLeft > 0 do
                task.wait(1)
                timeLeft -= 1
                if exitBtn and exitBtn.Parent then
                    exitBtn.Text = "CONFIRM (" .. timeLeft .. "s)"
                end
            end
            isExiting = false
            if exitBtn and exitBtn.Parent then
                exitBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
                exitBtn.Text = "EXIT"
            end
        end)
    end
end)

-- Render Control Logic (Saved to variables)
inputBeganConn = UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.E then
        RunService:Set3dRenderingEnabled(true)
        blackBackground.Visible = false
    end
end)

inputEndedConn = UIS.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.E then
        RunService:Set3dRenderingEnabled(false)
        blackBackground.Visible = true
    end
end)

-- Particle Generator System
task.spawn(function()
    while screenGui.Parent do
        local size = math.random(8, 25)
        local particle = Instance.new("Frame")
        particle.Size = UDim2.new(0, size, 0, size)
        
        particle.Position = UDim2.new(math.random(0, 1000) / 1000, 0, 1.1, 0)
        
        particle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        particle.BackgroundTransparency = math.random(85, 95) / 100
        particle.BorderSizePixel = 0
        particle.ZIndex = 1
        
        Instance.new("UICorner", particle).CornerRadius = UDim.new(1, 0)
        particle.Parent = particleContainer
        
        local duration = math.random(15, 30)
        local targetPos = UDim2.new(math.random(0, 1000) / 1000, 0, -0.2, 0)
        
        local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
        local tween = TweenService:Create(particle, tweenInfo, {
            Position = targetPos,
            BackgroundTransparency = 1
        })
        
        tween:Play()
        
        tween.Completed:Connect(function()
            particle:Destroy()
        end)
        
        task.wait(math.random(2, 6) / 10)
    end
end)

-- Disable render initially
RunService:Set3dRenderingEnabled(false)

-- Stats Update Loop
task.spawn(function()
    while screenGui.Parent do
        local stats = player:FindFirstChild("leaderstats")
        local money = stats and stats:FindFirstChild("Money")
        
        if money then
            local current = money.Value
            local remaining = limit - current
            if remaining < 0 then remaining = 0 end
            
            statsText.Text = string.format(
                "CURRENT:\n%s\n\nREMAINING:\n%s\n\nGOAL:\n%s",
                format(current), 
                format(remaining),
                format(limit)
            )
        else
            statsText.Text = "Money data not found"
        end
        task.wait(1)
    end
end)

-- ==========================================
-- Facts Logic System
-- ==========================================
local interestingFacts = {
    "i have no idea what type here",
    "Companies don’t care about you.",
    "krezalone da best shop",
    "Asti wasnt do anything wrong",
    "doxxing is bad.",
    "Putin killed Alexei Navalny.",
    "Astolfo>Felix",
    "synapse x, they betrayed us",
    "bypass.tools underrated gem"
}

task.spawn(function()
    while screenGui.Parent do
        local randomFact = interestingFacts[math.random(1, #interestingFacts)]
        factsText.Text = "Did you know?\n\n" .. randomFact
        
        task.wait(15)
    end
end)
