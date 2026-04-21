--[[
          _    _ _______ ____             _____  ______  _____ _______   _____     _______ _____ _    _ 
     /\  | |  | |__   __/ __ \      /\   |  __ \|  ____|/ ____|__   __| |  __ \ /\|__   __/ ____| |  | |
    /  \ | |  | |  | | | |  | |    /  \  | |__) | |__  | (___    | |    | |__) /  \  | | | |    | |__| |
   / /\ \| |  | |  | | | |  | |   / /\ \ |  _  /|  __|  \___ \   | |    |  ___/ /\ \ | | | |    |  __  |
  / ____ \ |__| |  | | | |__| |  / ____ \| | \ \| |____ ____) |  | |    | |  / ____ \| | | |____| |  | |
 /_/    \_\____/   |_|  \____/  /_/    \_\_|  \_\______|_____/   |_|    |_| /_/    \_\_|  \_____|_|  |_|
]]

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

load_script('https://raw.githubusercontent.com/Krezikkk/autoarrestfixscripts/refs/heads/main/killparts%20on%20stuck%20places.lua')
load_script('https://raw.githubusercontent.com/Krezikkk/autoarrestfixscripts/refs/heads/main/server%20hopping%20script%20for%20inactivity%20detection.lua')
load_script('https://raw.githubusercontent.com/Krezikkk/autoarrestfixscripts/refs/heads/main/serverhop%20if%20detected%20roblox%20kick%20gui.lua')

print("all scripts processed, check f9 console for errors")
