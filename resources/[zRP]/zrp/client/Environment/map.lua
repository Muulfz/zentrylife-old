-- BLIPS: see https://wiki.gtanet.work/index.php?title=Blips for blip id/color

local Tools = module("zrp", "lib/Tools")
-- TUNNEL CLIENT API

-- BLIP

-- create new blip, return native id
function tzRP.addBlip(x,y,z,idtype,idcolor,text)
  local blip = AddBlipForCoord(x+0.001,y+0.001,z+0.001) -- solve strange gta5 madness with integer -> double
  SetBlipSprite(blip, idtype)
  SetBlipAsShortRange(blip, true)
  SetBlipColour(blip,idcolor)

  if text ~= nil then
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(text)
    EndTextCommandSetBlipName(blip)
  end

  return blip
end

-- remove blip by native id
function tzRP.removeBlip(id)
  RemoveBlip(id)
end


local named_blips = {}

-- set a named blip (same as addBlip but for a unique name, add or update)
-- return native id
function tzRP.setNamedBlip(name,x,y,z,idtype,idcolor,text)
  tzRP.removeNamedBlip(name) -- remove old one

  named_blips[name] = tzRP.addBlip(x,y,z,idtype,idcolor,text)
  return named_blips[name]
end

-- remove a named blip
function tzRP.removeNamedBlip(name)
  if named_blips[name] ~= nil then
    tzRP.removeBlip(named_blips[name])
    named_blips[name] = nil
  end
end

-- GPS

-- set the GPS destination marker coordinates
function tzRP.setGPS(x,y)
  SetNewWaypoint(x+0.0001,y+0.0001)
end

-- set route to native blip id
function tzRP.setBlipRoute(id)
  SetBlipRoute(id,true)
end

-- MARKER

local markers = {}
local marker_ids = Tools.newIDGenerator()
local named_markers = {}

-- add a circular marker to the game map
-- return marker id
function tzRP.addMarker(x,y,z,sx,sy,sz,r,g,b,a,visible_distance)
  local marker = {x=x,y=y,z=z,sx=sx,sy=sy,sz=sz,r=r,g=g,b=b,a=a,visible_distance=visible_distance}


  -- default values
  if marker.sx == nil then marker.sx = 2.0 end
  if marker.sy == nil then marker.sy = 2.0 end
  if marker.sz == nil then marker.sz = 0.7 end

  if marker.r == nil then marker.r = 0 end
  if marker.g == nil then marker.g = 155 end
  if marker.b == nil then marker.b = 255 end
  if marker.a == nil then marker.a = 200 end

  -- fix gta5 integer -> double issue
  marker.x = marker.x+0.001
  marker.y = marker.y+0.001
  marker.z = marker.z+0.001
  marker.sx = marker.sx+0.001
  marker.sy = marker.sy+0.001
  marker.sz = marker.sz+0.001

  if marker.visible_distance == nil then marker.visible_distance = 150 end

  local id = marker_ids:gen()
  markers[id] = marker

  return id
end

-- remove marker
function tzRP.removeMarker(id)
  if markers[id] then
    markers[id] = nil
    marker_ids:free(id)
  end
end

-- set a named marker (same as addMarker but for a unique name, add or update)
-- return id
function tzRP.setNamedMarker(name,x,y,z,sx,sy,sz,r,g,b,a,visible_distance)
  tzRP.removeNamedMarker(name) -- remove old marker

  named_markers[name] = tzRP.addMarker(x,y,z,sx,sy,sz,r,g,b,a,visible_distance)
  return named_markers[name]
end

function tzRP.removeNamedMarker(name)
  if named_markers[name] then
    tzRP.removeMarker(named_markers[name])
    named_markers[name] = nil
  end
end

-- markers draw loop
Citizen.CreateThread(function()
  --DISPATCH
  for i = 1, 12 do
    Citizen.InvokeNative(0xDC0F817884CDD856, i, false)
  end
  while true do
    Citizen.Wait(0)

    local px,py,pz = tzRP.getPosition()

    for k,v in pairs(markers) do
      -- check visibility
      if GetDistanceBetweenCoords(v.x,v.y,v.z,px,py,pz,true) <= v.visible_distance then
        DrawMarker(1,v.x,v.y,v.z,0,0,0,0,0,0,v.sx,v.sy,v.sz,v.r,v.g,v.b,v.a,0,0,0,0)
      end
    end
  end
end)

-- AREA

local areas = {}

-- create/update a cylinder area
function tzRP.setArea(name,x,y,z,radius,height)
  local area = {x=x+0.001,y=y+0.001,z=z+0.001,radius=radius,height=height}

  -- default values
  if area.height == nil then area.height = 6 end

  areas[name] = area
end

-- remove area
function tzRP.removeArea(name)
  if areas[name] then
    areas[name] = nil
  end
end

-- areas triggers detections
Citizen.CreateThread(function()
  while true do
    Citizen.Wait(250)

    local px,py,pz = tzRP.getPosition()

    for k,v in pairs(areas) do
      -- detect enter/leave

      local player_in = (GetDistanceBetweenCoords(v.x,v.y,v.z,px,py,pz,true) <= v.radius and math.abs(pz-v.z) <= v.height)

      if v.player_in and not player_in then -- was in: leave
        zRPserver._leaveArea(k)
      elseif not v.player_in and player_in then -- wasn't in: enter
        zRPserver._enterArea(k)
      end

      v.player_in = player_in -- update area player_in
    end
  end
end)

-- DOOR

-- set the closest door state
-- doordef: .model or .modelhash
-- locked: boolean
-- doorswing: -1 to 1
function tzRP.setStateOfClosestDoor(doordef, locked, doorswing)
  local x,y,z = tzRP.getPosition()
  local hash = doordef.modelhash
  if hash == nil then
    hash = GetHashKey(doordef.model)
  end

  SetStateOfClosestDoorOfType(hash,x,y,z,locked,doorswing+0.0001)
end

function tzRP.openClosestDoor(doordef)
  tzRP.setStateOfClosestDoor(doordef, false, 0)
end

function tzRP.closeClosestDoor(doordef)
  tzRP.setStateOfClosestDoor(doordef, true, 0)
end
-------------------------------------
--[[
Citizen.CreateThread(function()
  while true do
    Citizen.Wait(1)

    for ped in EnumeratePeds() do
      if DoesEntityExist(ped) then
        for i,model in pairs(cfg.peds_control.peds) do
          if (GetEntityModel(ped) == GetHashKey(model)) then
            veh = GetVehiclePedIsIn(ped, false)
            SetEntityAsNoLongerNeeded(ped)
            SetEntityCoords(ped,10000,10000,10000,1,0,0,1)
            if veh ~= nil then
              SetEntityAsNoLongerNeeded(veh)
              SetEntityCoords(veh,10000,10000,10000,1,0,0,1)
            end
          end
        end
        for i,model in pairs(cfg.peds_control.noguns) do
          if (GetEntityModel(ped) == GetHashKey(model)) then
            RemoveAllPedWeapons(ped, true)
          end
        end
        for i,model in pairs(cfg.peds_control.nodrops) do
          if (GetEntityModel(ped) == GetHashKey(model)) then
            SetPedDropsWeaponsWhenDead(ped,false)
          end
        end
      end
    end
  end
end)

Citizen.CreateThread(function()
  while true
  do
    -- These natives has to be called every frame.
    SetPedDensityMultiplierThisFrame(cfg.peds_control.density.peds)
    SetScenarioPedDensityMultiplierThisFrame(cfg.peds_control.density.peds, cfg.peds_control.density.peds)
    SetVehicleDensityMultiplierThisFrame(cfg.peds_control.density.vehicles)
    SetRandomVehicleDensityMultiplierThisFrame(cfg.peds_control.density.vehicles)
    SetParkedVehicleDensityMultiplierThisFrame(cfg.peds_control.density.vehicles)
    Citizen.Wait(0)
  end
end)
-]]


local frozen_finish = false
local frozen = false

function tzRP.isFrozen()
  return frozen
end
function tzRP.loadFreeze()
  while not frozen_finish do
    SetEntityInvincible(GetPlayerPed(-1),true)
    SetEntityVisible(GetPlayerPed(-1),false)
    FreezeEntityPosition(GetPlayerPed(-1),true)
    frozen = true
    Citizen.Wait(1)
  end
  Citizen.Wait(30000)
  print("DESFREZANDO FINALIZANDO")
  SetEntityInvincible(GetPlayerPed(-1),false)
  SetEntityVisible(GetPlayerPed(-1),true)
  FreezeEntityPosition(GetPlayerPed(-1),false)
  frozen = false
end

RegisterNetEvent("zRP:Unfreeze")
AddEventHandler("zRP:Unfreeze", function()
  print("DESFREZANDO")
  frozen_finish = true
end)
