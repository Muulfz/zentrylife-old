Proxy = module("zrp", "lib/Proxy")
Tunnel = module("zrp", "lib/Tunnel")

zRP = Proxy.getInterface("zRP", "zrp_inteface")
zRPIserver = Tunnel.getInterface("zrp_interface", "zrp_interface")

tzRPI = {}
Threads = {}

Tunnel.bindInterface("zrp_interface", tzRPI)

ped = GetPlayerPed(-1)

--local places = module("zrp_interface", "Config/Main/coords")

function createThread(thread)
    table.insert(Threads, thread)
end

Citizen.CreateThread(function ()
    while true do
        Citizen.Wait(0)
        if IsControlJustReleased(1--[[input group]],  51--[[control index]]) then
            changeFrameUrl("veh_sealer")
            SetNuiFocus(true, true)
        end
    end
end)

function changeFrameUrl(frame)
    SendNUIMessage({
        func = 'main',
        type = 'change',
        frame = frame
    })
end

RegisterNUICallback('close', function(data, cb)
    SetNuiFocus(false, false)
    SendNUIMessage({
        func = 'main',
    })
end)



