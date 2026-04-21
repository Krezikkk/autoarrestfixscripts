wait(5)
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local PlaceId, JobId = game.PlaceId, game.JobId
local httprequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request

local function serverHop()
    while true do
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
                TeleportService:TeleportToPlaceInstance(PlaceId, servers[math.random(1, #servers)], Players.LocalPlayer)
            end
        end
        task.wait(1) -- пауза между попытками, чтобы не спамить запросами
    end
end

GuiService.ErrorMessageChanged:Connect(function()
    serverHop()
end)

-- на случай если окно уже висит при запуске скрипта
if GuiService:GetErrorMessage() ~= "" then
    serverHop()
end
