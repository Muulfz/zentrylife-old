local players = {}

RegisterNetEvent("zrp_id_display:setTable")
AddEventHandler("zrp_id_display:setTable", function(table)
    for k, v in pairs(table) do
        if GetPlayerFromServerId(v) ~= PlayerId() then
            players[k] = GetPlayerFromServerId(v)
        end
    end
end)

RegisterNetEvent("zrp_id_display:addPlayer")
AddEventHandler("zrp_id_display:addPlayer", function(user_id, source)
    if GetPlayerFromServerId(source) ~= PlayerId() then
        players[user_id] = GetPlayerFromServerId(source)
    end
end)

RegisterNetEvent("zrp_id_display:removePlayer")
AddEventHandler("zrp_id_display:removePlayer", function(user_id)
    players[user_id] = nil
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        for k, v in pairs(players) do
            local x, y, z = table.unpack(GetEntityCoords(GetPlayerPed(v)))
            if PlayerId() ~= v and v ~= -1 then
                if NetworkIsPlayerTalking(v) then
                    draw3DText(x, y, z + 1, k, 255, 255, 51, 20)
                else
                    draw3DText(x, y, z + 1, k, 255, 255, 255, 20)
                end
            end
        end
    end
end)

function draw3DText(x, y, z, text, r, g, b, maxDist)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())
    local dist = GetDistanceBetweenCoords(px, py, pz, x, y, z, 1)
    local scale = (1 / dist) * 1
    local fov = (1 / GetGameplayCamFov()) * 100
    local scale = scale * fov

    if onScreen and GetDistanceBetweenCoords(px, py, pz, x, y, z) < maxDist then
        SetTextScale(0.7 * scale, 1.2 * scale)
        SetTextFont(2)
        SetTextProportional(1)
        SetTextColour(r, g, b, 255)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        World3dToScreen2d(x, y, z, 0)
        DrawText(_x, _y)
    end
end