-- api

function tzRP.varyHealth(variation)
  local ped = GetPlayerPed(-1)

  local n = math.floor(GetEntityHealth(ped)+variation)
  SetEntityHealth(ped,n)
end

function tzRP.getHealth()
  return GetEntityHealth(GetPlayerPed(-1))
end

function tzRP.setHealth(health)
  local n = math.floor(health)
  SetEntityHealth(GetPlayerPed(-1),n)
end

function tzRP.setFriendlyFire(flag)
  NetworkSetFriendlyFireOption(flag)
  SetCanAttackFriendly(GetPlayerPed(-1), flag, flag)
end

function tzRP.setPolice(flag)
  local player = PlayerId()
  SetPoliceIgnorePlayer(player, not flag)
  SetDispatchCopsForPlayer(player, flag)
end

-- impact thirst and hunger when the player is running (every 5 seconds)
Citizen.CreateThread(function()
  while true do
    Citizen.Wait(5000)

    if IsPlayerPlaying(PlayerId()) then
      local ped = GetPlayerPed(-1)

      -- variations for one minute
      local vthirst = 0
      local vhunger = 0

      -- on foot, increase thirst/hunger in function of velocity
      if IsPedOnFoot(ped) and not tzRP.isNoclip() then
        local factor = math.min(tzRP.getSpeed(),10)

        vthirst = vthirst+1*factor
        vhunger = vhunger+0.5*factor
      end

      -- in melee combat, increase
      if IsPedInMeleeCombat(ped) then
        vthirst = vthirst+10
        vhunger = vhunger+5
      end

      -- injured, hurt, increase
      if IsPedHurt(ped) or IsPedInjured(ped) then
        vthirst = vthirst+2
        vhunger = vhunger+1
      end

      -- do variation
      if vthirst ~= 0 then
        zRPserver._varyThirst(vthirst/12.0)
      end

      if vhunger ~= 0 then
        zRPserver._varyHunger(vhunger/12.0)
      end
    end
  end
end)

-- COMA SYSTEM

local in_coma = false
local coma_left = cfg.coma_duration*60

Citizen.CreateThread(function() -- coma thread
  while true do
    Citizen.Wait(0)
    local ped = GetPlayerPed(-1)
    
    local health = GetEntityHealth(ped)
    if health <= cfg.coma_threshold and coma_left > 0 then
      if not in_coma then -- go to coma state
        if IsEntityDead(ped) then -- if dead, resurrect
          local x,y,z = tzRP.getPosition()
          NetworkResurrectLocalPlayer(x, y, z, true, true, false)
          Citizen.Wait(0)
        end

        -- coma state
        in_coma = true

        zRPserver._updateHealth(cfg.coma_threshold) -- force health update

        SetEntityHealth(ped, cfg.coma_threshold)
        SetEntityInvincible(ped,true)
        tzRP.playScreenEffect(cfg.coma_effect,-1)
        tzRP.ejectVehicle()
        tzRP.setRagdoll(true)
      else -- in coma
        -- maintain life
        if health < cfg.coma_threshold then 
          SetEntityHealth(ped, cfg.coma_threshold) 
        end
      end
    else
      if in_coma then -- get out of coma state
        in_coma = false
        SetEntityInvincible(ped,false)
        tzRP.setRagdoll(false)
        tzRP.stopScreenEffect(cfg.coma_effect)

        if coma_left <= 0 then -- get out of coma by death
          SetEntityHealth(ped, 0)
        end

        SetTimeout(5000, function()  -- able to be in coma again after coma death after 5 seconds
          coma_left = cfg.coma_duration*60
        end)
      end
    end
  end
end)

function tzRP.isInComa()
  return in_coma
end

-- kill the player if in coma
function tzRP.killComa()
  if in_coma then
    coma_left = 0
  end
end

Citizen.CreateThread(function() -- coma decrease thread
  while true do 
    Citizen.Wait(1000)
    if in_coma then
      coma_left = coma_left-1
    end
  end
end)

Citizen.CreateThread(function() -- disable health regen, conflicts with coma system
  while true do
    Citizen.Wait(100)
    -- prevent health regen
    SetPlayerHealthRechargeMultiplier(PlayerId(), 0)
  end
end)


