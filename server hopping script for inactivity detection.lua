local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local PlaceId, JobId = game.PlaceId, game.JobId
local httprequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request

local player = Players.LocalPlayer
local lastPosition = nil
local checkInterval = 60

local function serverHop()
	print("ищу новый сервер...")
	if httprequest then
		local servers = {}
		local success, req = pcall(function()
			return httprequest({Url = string.format("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Desc&limit=100", PlaceId)})
		end)
		
		if success and req.Body then
			local body = HttpService:JSONDecode(req.Body)
			if body and body.data then
				for i, v in next, body.data do
					if type(v) == "table" and v.playing and v.maxPlayers and v.playing < v.maxPlayers and v.id ~= JobId then
						table.insert(servers, v.id)
					end
				end
			end
		end

		if #servers > 0 then
			local randomServer = servers[math.random(1, #servers)]
			print("сервер найден, телепортация...")
			TeleportService:TeleportToPlaceInstance(PlaceId, randomServer, player)
		else
			warn("не нашел серверов")
		end
	end
end

task.spawn(function()
	print("мониторинг запущен")
	
	if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		lastPosition = player.Character.HumanoidRootPart.Position
	end

	while true do
		local moved = false
		
		for i = checkInterval, 1, -1 do
			print("до проверки: " .. i .. " сек")
			task.wait(1)
			
			local character = player.Character
			if character and character:FindFirstChild("HumanoidRootPart") then
				if not lastPosition then lastPosition = character.HumanoidRootPart.Position end
				
				local currentPosition = character.HumanoidRootPart.Position
				local distance = (currentPosition - lastPosition).Magnitude
				
				if distance >= 10 then
					print(string.format("прошел %.2f студов, сброс таймера", distance))
					lastPosition = currentPosition
					moved = true
					break
				end
			end
		end
		
		if not moved then
			warn("время вышло, движения нет")
			serverHop()
			task.wait(2) -- небольшая пауза перед повторной попыткой если не кикнуло
		end
	end
end)
