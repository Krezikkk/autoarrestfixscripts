--[[
          _    _ _______ ____             _____  ______  _____ _______   _____     _______ _____ _    _ 
     /\  | |  | |__   __/ __ \      /\   |  __ \|  ____|/ ____|__   __| |  __ \ /\|__   __/ ____| |  | |
    /  \ | |  | |  | | | |  | |    /  \  | |__) | |__  | (___    | |    | |__) /  \  | | | |    | |__| |
   / /\ \| |  | |  | | | |  | |   / /\ \ |  _  /|  __|  \___ \   | |    |  ___/ /\ \ | | | |    |  __  |
  / ____ \ |__| |  | | | |__| |  / ____ \| | \ \| |____ ____) |  | |    | |  / ____ \| | | |____| |  | |
 /_/    \_\____/   |_|  \____/  /_/    \_\_|  \_\______|_____/   |_|    |_| /_/    \_\_|  \_____|_|  |_|
]]

-- Executor check
local executor = type(identifyexecutor) == "function" and identifyexecutor() or "Unknown"
if not string.find(string.lower(executor), "seliware") then
    print("Execution stopped: Seliware executor is required. Detected: " .. tostring(executor))
    
    -- Create Error GUI
    local ErrorGui = Instance.new("ScreenGui")
    ErrorGui.Name = "SeliwareErrorGui"
    
    -- Attempt to parent to CoreGui (to keep it hidden from the game), otherwise fallback to PlayerGui
    local success = pcall(function()
        ErrorGui.Parent = game:GetService("CoreGui")
    end)
    if not success then
        ErrorGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    end

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 350, 0, 100)
    Frame.Position = UDim2.new(0.5, -175, 0.5, -50) -- Center of the screen
    Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Frame.BorderSizePixel = 2
    Frame.BorderColor3 = Color3.fromRGB(255, 50, 50) -- Red border
    Frame.Parent = ErrorGui

    local TextLabel = Instance.new("TextLabel")
    TextLabel.Size = UDim2.new(1, 0, 1, 0)
    TextLabel.BackgroundTransparency = 1
    TextLabel.Text = "EXECUTION ERROR\n\nThis script only works on the Seliware executor!"
    TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextLabel.Font = Enum.Font.GothamBold
    TextLabel.TextSize = 16
    TextLabel.Parent = Frame

    -- Automatically destroy the GUI after 3 seconds
    task.delay(3, function()
        if ErrorGui then
            ErrorGui:Destroy()
        end
    end)

    return -- Abort further execution of the main script
end

-- Main script code (only runs on Seliware)
if not game:IsLoaded() then
    print("waiting for game to load...")
    game.Loaded:Wait()
end
print("game fully loaded, starting script execution")

task.wait(7)
print("7 seconds delay finished, starting to load external scripts")

local function load_script(url)
    print("attempting to load: " .. url)
    local success, err = pcall(function()
        loadstring(game:HttpGet(url))()
    end)
    
    if success then
        print("successfully loaded and executed: " .. url)
    else
        print("error while loading " .. url .. ": " .. tostring(err))
    end
end

load_script("https://raw.githubusercontent.com/Krezikkk/autoarrestfixscripts/refs/heads/main/afk%20screen.lua")
load_script("https://raw.githubusercontent.com/Krezikkk/autoarrestfixscripts/refs/heads/main/fpsboost.lua")
load_script('https://raw.githubusercontent.com/Krezikkk/autoarrestfixscripts/refs/heads/main/killparts%20on%20stuck%20places.lua')
load_script('https://raw.githubusercontent.com/Krezikkk/autoarrestfixscripts/refs/heads/main/server%20hopping%20script%20for%20inactivity%20detection.lua')
load_script('https://raw.githubusercontent.com/Krezikkk/autoarrestfixscripts/refs/heads/main/serverhop%20if%20detected%20roblox%20kick%20gui.lua')


print("all scripts processed, check f9 console for errors")
