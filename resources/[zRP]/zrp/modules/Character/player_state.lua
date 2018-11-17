local cfg = module("cfg/Modules/player_state")
local lang = zRP.lang

-- client -> server events
AddEventHandler("zRP:playerSpawn", function(user_id, source, first_spawn)
  local player = source
  local data = zRP.getUserDataTable(user_id)
  local tmpdata = zRP.getUserTmpTable(user_id)

  if first_spawn then -- first spawn
    -- cascade load customization then weapons
    if data.customization == nil then
      data.customization = cfg.default_customization
    end

    if not data.position and cfg.spawn_enabled then
      local x = cfg.spawn_position[1]+math.random()*cfg.spawn_radius*2-cfg.spawn_radius
      local y = cfg.spawn_position[2]+math.random()*cfg.spawn_radius*2-cfg.spawn_radius
      local z = cfg.spawn_position[3]+math.random()*cfg.spawn_radius*2-cfg.spawn_radius
      data.position = {x=x,y=y,z=z}
    end

    if data.position then -- teleport to saved pos
      zRPclient.teleport(source,data.position.x,data.position.y,data.position.z)
    end

    if data.customization then
      zRPclient.setCustomization(source,data.customization)
      if data.weapons then -- load saved weapons
        zRPclient.giveWeapons(source,data.weapons,true)

        if data.health then -- set health
          zRPclient.setHealth(source,data.health)
          SetTimeout(5000, function() -- check coma, kill if in coma
            if zRPclient.isInComa(player) then
              zRPclient.killComa(player)
            end
          end)
        end
      end
    else
      if data.weapons then -- load saved weapons
        zRPclient.giveWeapons(source,data.weapons,true)
      end

      if data.health then
        zRPclient.setHealth(source,data.health)
      end
    end


    -- notify last login
    SetTimeout(15000,function()
      zRPclient._notify(player,lang.common.welcome({tmpdata.last_login}))
    end)
  else -- not first spawn (player died), don't load weapons, empty wallet, empty inventory
    zRP.setHunger(user_id,0)
    zRP.setThirst(user_id,0)
    zRP.clearInventory(user_id)

    if cfg.clear_phone_directory_on_death then
      data.phone_directory = {} -- clear phone directory after death
    end

    if cfg.lose_aptitudes_on_death then
      data.gaptitudes = {} -- clear aptitudes after death
    end

    zRP.setMoney(user_id,0)

    -- disable handcuff
    zRPclient._setHandcuffed(player,false)

    if cfg.spawn_enabled then -- respawn
      local x = cfg.spawn_position[1]+math.random()*cfg.spawn_radius*2-cfg.spawn_radius
      local y = cfg.spawn_position[2]+math.random()*cfg.spawn_radius*2-cfg.spawn_radius
      local z = cfg.spawn_position[3]+math.random()*cfg.spawn_radius*2-cfg.spawn_radius
      data.position = {x=x,y=y,z=z}
      zRPclient._teleport(source,x,y,z)
    end

    -- load character customization
    if data.customization then
      zRPclient._setCustomization(source,data.customization)
    end
  end

  zRPclient._playerStateReady(source, true)
end)

-- updates

function tzRP.updatePos(x,y,z)
  local user_id = zRP.getUserId(source)
  if user_id then
    local data = zRP.getUserDataTable(user_id)
    local tmp = zRP.getUserTmpTable(user_id)
    if data and (not tmp or not tmp.home_stype) then -- don't save position if inside home slot
      data.position = {x = tonumber(x), y = tonumber(y), z = tonumber(z)}
    end
  end
end

function tzRP.updateWeapons(weapons)
  local user_id = zRP.getUserId(source)
  if user_id then
    local data = zRP.getUserDataTable(user_id)
    if data then
      data.weapons = weapons
    end
  end
end

function tzRP.updateCustomization(customization)
  local user_id = zRP.getUserId(source)
  if user_id then
    local data = zRP.getUserDataTable(user_id)
    if data then
      data.customization = customization
    end
  end
end

function tzRP.updateHealth(health)
  local user_id = zRP.getUserId(source)
  if user_id then
    local data = zRP.getUserDataTable(user_id)
    if data then
      data.health = health
    end
  end
end
