local player = game:GetService("Players").LocalPlayer
local limit = 1000000

-- создание интерфейса
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MoneyMonitorGui"
screenGui.Parent = game:GetService("CoreGui")

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 300, 0, 200)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
mainFrame.BackgroundColor3 = Color3.fromRGB(28, 27, 31) -- md3 dark surface
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

local titleBar = Instance.new("TextButton")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(73, 69, 79)
titleBar.Text = "  money monitor"
titleBar.TextColor3 = Color3.fromRGB(230, 225, 229)
titleBar.TextXAlignment = Enum.TextXAlignment.Left
titleBar.Font = Enum.Font.SourceSansSemibold
titleBar.TextSize = 18
titleBar.AutoButtonColor = false
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 5)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "×"
closeBtn.TextColor3 = Color3.fromRGB(230, 225, 229)
closeBtn.TextSize = 24
closeBtn.Parent = titleBar

local content = Instance.new("TextLabel")
content.Size = UDim2.new(1, -20, 1, -50)
content.Position = UDim2.new(0, 10, 0, 45)
content.BackgroundTransparency = 1
content.TextColor3 = Color3.fromRGB(230, 225, 229)
content.TextSize = 16
content.Font = Enum.Font.SourceSans
content.TextWrapped = true
content.TextYAlignment = Enum.TextYAlignment.Top
content.Text = "загрузка данных..."
content.Parent = mainFrame

-- функции
local function format(val)
    if val >= 1000000 then
        return string.format("%d (%.1fm)", val, val / 1000000)
    elseif val >= 1000 then
        return string.format("%d (%.1fk)", val, val / 1000)
    end
    return tostring(val)
end

-- перетаскивание
local dragging, dragInput, dragStart, startPos
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

titleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- цикл обновления
task.spawn(function()
    while screenGui.Parent do
        local stats = player:FindFirstChild("leaderstats")
        local money = stats and stats:FindFirstChild("Money")
        
        if money then
            local current = money.Value
            local diff = limit - current
            content.Text = string.format(
                "сейчас: %s\n\nосталось: %s\n\nцель: %s",
                format(current), format(diff), format(limit)
            )
            
            if current > limit then
                player:Kick("лимит превышен")
            end
        else
            content.Text = "ошибка: данные Money не найдены"
        end
        task.wait(1)
    end
end)
