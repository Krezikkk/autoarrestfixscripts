--[[
fpsboost that works with autoarrest
]]
local uis = game:GetService("UserInputService")
local rs = game:GetService("RunService")
local ws = workspace
local lgt = game:GetService("Lighting")

local hidden = true
local cache = {}
local setCache = {}
local conn

local function hide()
    local terr = ws:FindFirstChildOfClass('Terrain')
    if terr then
        pcall(function()
            setCache.terr = {
                WaterWaveSize = terr.WaterWaveSize,
                WaterWaveSpeed = terr.WaterWaveSpeed,
                WaterReflectance = terr.WaterReflectance,
                WaterTransparency = terr.WaterTransparency
            }
            terr.WaterWaveSize = 0; terr.WaterWaveSpeed = 0
            terr.WaterReflectance = 0; terr.WaterTransparency = 0
        end)
    end

    pcall(function()
        setCache.lgt = {GlobalShadows = lgt.GlobalShadows, FogEnd = lgt.FogEnd}
        lgt.GlobalShadows = false; lgt.FogEnd = 9e9
    end)

    local objs = {}
    for _, v in pairs(ws:GetDescendants()) do table.insert(objs, v) end
    for _, v in pairs(lgt:GetDescendants()) do table.insert(objs, v) end

    for _, v in pairs(objs) do
        if v:IsA("BasePart") or v:IsA("MeshPart") or v:IsA("UnionOperation") or v:IsA("CornerWedgePart") or v:IsA("TrussPart") then
            cache[v] = {Transparency = v.Transparency, Material = v.Material, Reflectance = v.Reflectance}
            v.Transparency = 1; v.Material = Enum.Material.Plastic; v.Reflectance = 0
        elseif v:IsA("Decal") or v:IsA("Texture") then
            cache[v] = {Transparency = v.Transparency}
            v.Transparency = 1
        elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
            cache[v] = {Lifetime = v.Lifetime, Enabled = v.Enabled}
            v.Lifetime = NumberRange.new(0); v.Enabled = false
        elseif v:IsA("Explosion") then
            cache[v] = {BlastPressure = v.BlastPressure, BlastRadius = v.BlastRadius}
            v.BlastPressure = 1; v.BlastRadius = 1
        elseif v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("BloomEffect") or v:IsA("DepthOfFieldEffect") then
            cache[v] = {Enabled = v.Enabled}
            v.Enabled = false
        end
    end

    conn = ws.DescendantAdded:Connect(function(c)
        task.spawn(function()
            if c:IsA('ForceField') or c:IsA('Sparkles') or c:IsA('Smoke') or c:IsA('Fire') then
                rs.Heartbeat:Wait()
                if c and c.Parent then c:Destroy() end
            end
        end)
    end)
end

local function revert()
    local terr = ws:FindFirstChildOfClass('Terrain')
    if terr and setCache.terr then
        for k, v in pairs(setCache.terr) do pcall(function() terr[k] = v end) end
    end
    
    if setCache.lgt then
        for k, v in pairs(setCache.lgt) do pcall(function() lgt[k] = v end) end
    end
    
    for obj, props in pairs(cache) do
        if obj and obj.Parent then 
            for k, v in pairs(props) do pcall(function() obj[k] = v end) end
        end
    end

    if conn then
        conn:Disconnect()
        conn = nil
    end
end

hide()
print("fps boost loaded. press f4 to revert.")

uis.InputBegan:Connect(function(inp, gp)
    if not gp and inp.KeyCode == Enum.KeyCode.F4 and hidden then
        revert()
        hidden = false
        cache = {}
        setCache = {}
    end
end)
