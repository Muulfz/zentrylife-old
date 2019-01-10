--local Tunnel = module("zrp","lib/Tunnel")

--local server = Tunnel.getInterface("teste", "teste")

local menuEnabled = false

function toggleMenu()
    menuEnabled = not menuEnabled
    SetNuiFocus(menuEnabled,menuEnabled)
    SendNUIMessage({
        show = menuEnabled
    })
end


SetTimeout(1000, function ()
    SendNUIMessage({
        func = 'create',
        cars = {
            {model = "akuma", price = 1000, description = "Akuma", image = "http://media.gtanet.com/images/7803-9f.jpg"},
            {model = "akuma", price = 1000, description = "Akuma", image = "http://media.gtanet.com/images/7803-9f.jpg"},
            {model = "akuma", price = 1000, description = "Akuma", image = "http://media.gtanet.com/images/7803-9f.jpg"},
            {model = "akuma", price = 1000, description = "Akuma", image = "http://media.gtanet.com/images/7803-9f.jpg"}
        }
    })
end)
Citizen.CreateThread(function ()
    while true do
        Wait(0)
        if not menuEnabled then
            SetNuiFocus(false, false)
        end
        if IsControlJustReleased(1--[[input group]],  51--[[control index]]) then
            toggleMenu()
        end
    end
end)

RegisterNUICallback('close', function(data, cb)
    toggleMenu()
    cb('ok')
end)

RegisterNUICallback('buy', function(data, cb)
    cb('ok')
end)