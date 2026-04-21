wait(15)
-- LocalScript
-- При запуске сразу создаются 2 KillPart
-- F1 = удалить всё навсегда

local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

local parts = {}
local connections = {}
local keyConnection

--==================================================
-- СОЗДАНИЕ КИЛЛПАРТА
--==================================================
local function createKillPart(points, yCenter, ySize, name)
	local minX = math.huge
	local maxX = -math.huge
	local minZ = math.huge
	local maxZ = -math.huge

	for _, v in pairs(points) do
		minX = math.min(minX, v.X)
		maxX = math.max(maxX, v.X)
		minZ = math.min(minZ, v.Z)
		maxZ = math.max(maxZ, v.Z)
	end

	local part = Instance.new("Part")
	part.Name = name
	part.Anchored = true
	part.CanCollide = true
	part.CanTouch = true
	part.CanQuery = true
	part.Transparency = 0.5
	part.BrickColor = BrickColor.new("Really red")

	part.Size = Vector3.new(
		maxX - minX,
		ySize,
		maxZ - minZ
	)

	part.Position = Vector3.new(
		(minX + maxX) / 2,
		yCenter,
		(minZ + maxZ) / 2
	)

	part.Parent = workspace

	local con = part.Touched:Connect(function(hit)
		local char = player.Character
		if char and hit:IsDescendantOf(char) then
			local hum = char:FindFirstChildOfClass("Humanoid")
			if hum then
				hum.Health = 0
			end
		end
	end)

	table.insert(parts, part)
	table.insert(connections, con)
end

--==================================================
-- ПЕРВЫЙ КУБ (НЕ ТРОГАЕМ)
--==================================================
createKillPart({
	Vector3.new(720, 62, 1101),
	Vector3.new(739, 62, 1093),
	Vector3.new(745, 62, 1107),
	Vector3.new(717, 62, 1121)
}, 62, 5, "KillBrick1")

--==================================================
-- ВТОРОЙ КУБ (+5 вверх и вниз = высота 10)
--==================================================
createKillPart({
	Vector3.new(-1144, 38, -1531),
	Vector3.new(-1211, 38, -1532),
	Vector3.new(-1204, 39, -1607),
	Vector3.new(-1143, 39, -1606)
}, 38.5, 10, "KillBrick2")

--==================================================
-- УДАЛЕНИЕ
--==================================================
local function destroyAll()
	for _, c in pairs(connections) do
		c:Disconnect()
	end

	for _, p in pairs(parts) do
		if p then
			p:Destroy()
		end
	end

	if keyConnection then
		keyConnection:Disconnect()
	end

	script:Destroy()
end

keyConnection = UIS.InputBegan:Connect(function(input, gp)
	if gp then return end

	if input.KeyCode == Enum.KeyCode.F1 then
		destroyAll()
	end
end)
