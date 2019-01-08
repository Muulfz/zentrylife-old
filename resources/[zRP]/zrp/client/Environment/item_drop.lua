-- Credits Marmota#2533

local hash = GetHashKey("prop_paper_bag_small")

function tzRP.createBag ()
    local x, y, z = table.unpack(GetEntityCoords(GetPlayerPed(-1)))
    RequestModel(hash)
    while not HasModelLoaded(hash) do
        Citizen.Wait(1)
    end
    local object = CreateObject(hash, x, y, z - 2, true, true, true) -- x+1
    PlaceObjectOnGroundProperly(object)
    return NetworkGetNetworkIdFromEntity(object)
end

function scenrionahoi(text)
    SetTextComponentFormat('STRING')
    AddTextComponentString(text)
    DisplayHelpTextFromStringLabel(0, false, false, -1)
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local x, y, z = table.unpack(GetEntityCoords(GetPlayerPed(-1)))
        if DoesObjectOfTypeExistAtCoords(x, y, z, 20.0, hash, true) then
            local bag = GetClosestObjectOfType(x, y, z, 20.0, hash, false, false, false)
            if bag then
                local bx, by, bz = table.unpack(GetEntityCoords(bag))
                if GetDistanceBetweenCoords(x, y, z, bx, by, bz) <= 1.3 then
                    scenrionahoi("Pressione [~b~E~w~] para pegar o pacote!")
                    if IsControlJustPressed(1, 51) then
                        local id = NetworkGetNetworkIdFromEntity(bag)
                        if zRPserver.verifyBag(id) then
                            TriggerServerEvent("zrp_itemdrop:takeBag", id)
                            Citizen.Wait(500)
                        end
                    end
                end
                DrawMarker(22, bx, by, bz + 0.5, 0, 0, 0, 180.0, 0, 0, 0.4001, 0.4001, 0.4001, 255, 255, 255, 185, true, true, 0, 0)
            end
        end
    end
end)

RegisterNetEvent("zrp_itemdrop:deleteBag")
AddEventHandler("zrp_itemdrop:deleteBag", function(id)
    local bag = NetworkGetEntityFromNetworkId(id)
    SetEntityAsMissionEntity(bag, true, true)
    DeleteObject(bag)
end)
