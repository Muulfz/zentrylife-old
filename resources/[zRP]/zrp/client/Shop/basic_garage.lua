-- decorators
DecorRegister("zRP_owner", 3)
DecorRegister("zRP_vmodel", 3)

local veh_models = {}
local vehicles = {}

function tzRP.setVehicleModelsIndex(index)
  veh_models = index

  -- generate bidirectional keys
  for k,v in pairs(veh_models) do
    veh_models[v] = k
  end
end

-- veh: vehicle game id
-- return owner_user_id, vname (or nil if not managed by zRP)
function tzRP.getVehicleInfos(veh)
  if veh and DecorExistOn(veh, "zRP_owner") and DecorExistOn(veh, "zRP_vmodel") then
    local user_id = DecorGetInt(veh, "zRP_owner")
    local vmodel = DecorGetInt(veh, "zRP_vmodel")

    local vname = veh_models[vmodel]
    if vname then
      return user_id, vname
    end
  end
end

function tzRP.spawnGarageVehicle(name,pos) -- one vehicle per vname/model allowed at the same time

  local vehicle = vehicles[name]
  if vehicle == nil then
    -- load vehicle model
    local mhash = GetHashKey(name)

    local i = 0
    while not HasModelLoaded(mhash) and i < 10000 do
      RequestModel(mhash)
      Citizen.Wait(10)
      i = i+1
    end

    -- spawn car
    if HasModelLoaded(mhash) then
      local x,y,z = tzRP.getPosition()
      if pos then
        x,y,z = table.unpack(pos)
      end

      local nveh = CreateVehicle(mhash, x,y,z+0.5, 0.0, true, false)
      SetVehicleOnGroundProperly(nveh)
      SetEntityInvincible(nveh,false)
      SetPedIntoVehicle(GetPlayerPed(-1),nveh,-1) -- put player inside
      SetVehicleNumberPlateText(nveh, "P "..tzRP.getRegistrationNumber())
      Citizen.InvokeNative(0xAD738C3085FE7E11, nveh, true, true) -- set as mission entity
      SetVehicleHasBeenOwnedByPlayer(nveh,true)

      -- set decorators
      DecorSetInt(veh, "zRP_owner", tzRP.getUserId())   --TODO trocar para chacter
      DecorSetInt(veh, "zRP_vmodel", veh_models[name])

      vehicles[name] = {name,nveh} -- set current vehicule

      SetModelAsNoLongerNeeded(mhash)
    end
  else
    tzRP.notify("This vehicle is already out.")
  end
end

function tzRP.despawnGarageVehicle(name)
  local vehicle = vehicles[name]
  if vehicle then
    -- remove vehicle
    SetVehicleHasBeenOwnedByPlayer(vehicle[2],false)
    Citizen.InvokeNative(0xAD738C3085FE7E11, vehicle[2], false, true) -- set not as mission entity
    SetVehicleAsNoLongerNeeded(Citizen.PointerValueIntInitialized(vehicle[2]))
    Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(vehicle[2]))
    vehicles[name] = nil
    tzRP.notify("Vehicle stored.")
  end
end

-- check vehicles validity
--[[
Citizen.CreateThread(function()
  Citizen.Wait(30000)

  for k,v in pairs(vehicles) do
    if IsEntityAVehicle(v[3]) then -- valid, save position
      v.pos = {table.unpack(GetEntityCoords(vehicle[3],true))}
    elseif v.pos then -- not valid, respawn if with a valid position
      print("[zRP] invalid vehicle "..v[1]..", respawning...")
      tzRP.spawnGarageVehicle(v[1], v[2], v.pos)
    end
  end
end)
--]]

-- (experimental) this function return the nearest vehicle
-- (don't work with all vehicles, but aim to)
function tzRP.getNearestVehicle(radius)
  local x,y,z = tzRP.getPosition()
  local ped = GetPlayerPed(-1)
  if IsPedSittingInAnyVehicle(ped) then
    return GetVehiclePedIsIn(ped, true)
  else
    -- flags used:
    --- 8192: boat
    --- 4096: helicos
    --- 4,2,1: cars (with police)

    local veh = GetClosestVehicle(x+0.0001,y+0.0001,z+0.0001, radius+0.0001, 0, 8192+4096+4+2+1)  -- boats, helicos
    if not IsEntityAVehicle(veh) then veh = GetClosestVehicle(x+0.0001,y+0.0001,z+0.0001, radius+0.0001, 0, 4+2+1) end -- cars
    return veh
  end
end

-- try to re-own the nearest vehicle
function tzRP.tryOwnNearestVehicle(radius)
  local veh = tzRP.getNearestVehicle(radius)
  if veh then
    local user_id, vname = tzRP.getVehicleInfos(veh)
    if user_id and user_id == tzRP.getUserId() then
      if vehicles[vname] ~= veh then
        vehicles[vname] = veh
      end
    end
  end
end

function tzRP.fixeNearestVehicle(radius)
  local veh = tzRP.getNearestVehicle(radius)
  if IsEntityAVehicle(veh) then
    SetVehicleFixed(veh)
  end
end

function tzRP.replaceNearestVehicle(radius)
  local veh = tzRP.getNearestVehicle(radius)
  if IsEntityAVehicle(veh) then
    SetVehicleOnGroundProperly(veh)
  end
end

-- try to get a vehicle at a specific position (using raycast)
function tzRP.getVehicleAtPosition(x,y,z)
  x = x+0.0001
  y = y+0.0001
  z = z+0.0001

  local ray = CastRayPointToPoint(x,y,z,x,y,z+4,10,GetPlayerPed(-1),0)
  local a, b, c, d, ent = GetRaycastResult(ray)
  return ent
end

-- return ok,name
function tzRP.getNearestOwnedVehicle(radius)
  tzRP.tryOwnNearestVehicle(radius) -- get back network lost vehicles

  local px,py,pz = tzRP.getPosition()
  local min_dist
  local min_k
  for k,v in pairs(vehicles) do
    local x,y,z = table.unpack(GetEntityCoords(v[2],true))
    local dist = GetDistanceBetweenCoords(x,y,z,px,py,pz,true)

    if dist <= radius+0.0001 then
      if not min_dist or dist < min_dist then
        min_dist = dist
        min_k = k
      end
    end
  end

  if min_k then
    return true,min_k
  end

  return false,""
end

-- return ok,x,y,z
function tzRP.getAnyOwnedVehiclePosition()
  for k,v in pairs(vehicles) do
    if IsEntityAVehicle(v[2]) then
      local x,y,z = table.unpack(GetEntityCoords(v[2],true))
      return true,x,y,z
    end
  end

  return false,0,0,0
end

-- return x,y,z
function tzRP.getOwnedVehiclePosition(name)
  local vehicle = vehicles[name]
  local x,y,z = 0,0,0

  if vehicle then
    x,y,z = table.unpack(GetEntityCoords(vehicle[2],true))
  end

  return x,y,z
end

-- return owned vehicle handle or nil if not found
function tzRP.getOwnedVehicleHandle(name)
  local vehicle = vehicles[name]
  if vehicle then
    return vehicle[2]
  end
end

-- eject the ped from the vehicle
function tzRP.ejectVehicle()
  local ped = GetPlayerPed(-1)
  if IsPedSittingInAnyVehicle(ped) then
    local veh = GetVehiclePedIsIn(ped,false)
    TaskLeaveVehicle(ped, veh, 4160)
  end
end

function tzRP.isInVehicle()
  local ped = GetPlayerPed(-1)
  return IsPedSittingInAnyVehicle(ped) 
end

-- vehicle commands
function tzRP.vc_openDoor(name, door_index)
  local vehicle = vehicles[name]
  if vehicle then
    SetVehicleDoorOpen(vehicle[2],door_index,0,false)
  end
end

function tzRP.vc_closeDoor(name, door_index)
  local vehicle = vehicles[name]
  if vehicle then
    SetVehicleDoorShut(vehicle[2],door_index)
  end
end

function tzRP.vc_detachTrailer(name)
  local vehicle = vehicles[name]
  if vehicle then
    DetachVehicleFromTrailer(vehicle[2])
  end
end

function tzRP.vc_detachTowTruck(name)
  local vehicle = vehicles[name]
  if vehicle then
    local ent = GetEntityAttachedToTowTruck(vehicle[2])
    if IsEntityAVehicle(ent) then
      DetachVehicleFromTowTruck(vehicle[2],ent)
    end
  end
end

function tzRP.vc_detachCargobob(name)
  local vehicle = vehicles[name]
  if vehicle then
    local ent = GetVehicleAttachedToCargobob(vehicle[2])
    if IsEntityAVehicle(ent) then
      DetachVehicleFromCargobob(vehicle[2],ent)
    end
  end
end

function tzRP.vc_toggleEngine(name)
  local vehicle = vehicles[name]
  if vehicle then
    local running = Citizen.InvokeNative(0xAE31E7DF9B5B132E,vehicle[2]) -- GetIsVehicleEngineRunning
    SetVehicleEngineOn(vehicle[2],not running,true,true)
    if running then
      SetVehicleUndriveable(vehicle[2],true)
    else
      SetVehicleUndriveable(vehicle[2],false)
    end
  end
end

function tzRP.vc_toggleLock(name)
  local vehicle = vehicles[name]
  if vehicle then
    local veh = vehicle[2]
    local locked = GetVehicleDoorLockStatus(veh) >= 2
    if locked then -- unlock
      SetVehicleDoorsLockedForAllPlayers(veh, false)
      SetVehicleDoorsLocked(veh,1)
      SetVehicleDoorsLockedForPlayer(veh, PlayerId(), false)
      tzRP.notify("Vehicle unlocked.")
    else -- lock
      SetVehicleDoorsLocked(veh,2)
      SetVehicleDoorsLockedForAllPlayers(veh, true)
      tzRP.notify("Vehicle locked.")
    end
  end
end
