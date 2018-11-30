
-- define some basic home components
local lang = zRP.lang
local sanitizes = module("cfg/Modules/sanitizes")

-- CHEST

local function chest_create(owner_id, stype, sid, cid, config, data, x, y, z, player)
  local chest_enter = function(player,area)
    local user_id = zRP.getUserId(player)
    if user_id and user_id == owner_id then
      zRP.openChest(player, "u"..owner_id.."home", config.weight or 200,nil,nil,nil)
    end
  end


  local chest_leave = function(player,area)
    zRP.closeMenu(player)
  end

  local nid = "zRP:home:slot"..stype..sid..":chest"
  zRPclient._setNamedMarker(player,nid,x,y,z-1,0.7,0.7,0.5,0,255,125,125,150)
  zRP.setArea(player,nid,x,y,z,1,1.5,chest_enter,chest_leave)
end

local function chest_destroy(owner_id, stype, sid, cid, config, data, x, y, z, player)
  local nid = "zRP:home:slot"..stype..sid..":chest"
  zRPclient._removeNamedMarker(player,nid)
  zRP.removeArea(player,nid)
end

zRP.defHomeComponent("chest", chest_create, chest_destroy)

-- WARDROBE

local function wardrobe_create(owner_id, stype, sid, cid, config, data, x, y, z, player)
  local wardrobe_enter = nil
  wardrobe_enter = function(player,area)
    local user_id = zRP.getUserId(player)
    if user_id and user_id == owner_id then
      -- notify player if wearing a uniform
      local udata = zRP.getUserDataTable(user_id)
      if udata.cloakroom_idle then
        zRPclient._notify(player,lang.common.wearing_uniform())
      end

      -- build menu
      local menu = {name=lang.home.wardrobe.title(),css={top = "75px", header_color="rgba(0,255,125,0.75)"}}

      -- load sets
      local udata = zRP.getUData(user_id, "zRP:home:wardrobe")
      local sets = json.decode(udata)
      if sets == nil then
        sets = {}
      end

      -- save
      menu[lang.home.wardrobe.save.title()] = {function(player, choice)
        local setname = zRP.prompt(player, lang.home.wardrobe.save.prompt(), "")
        setname = sanitizeString(setname, sanitizes.text[1], sanitizes.text[2])
        if string.len(setname) > 0 then
          -- save custom
          local custom =zRPclient.getCustomization(player)
          sets[setname] = custom
          -- save to db
          zRP.setUData(user_id,"zRP:home:wardrobe",json.encode(sets))

          -- actualize menu
          wardrobe_enter(player, area)
        else
          zRPclient._notify(player,lang.common.invalid_value())
        end
      end}

      local choose_set = function(player,choice)
        local custom = sets[choice]
        if custom then
          zRPclient._setCustomization(player,custom)
        end
      end

      -- sets
      for k,v in pairs(sets) do
        menu[k] = {choose_set}
      end

      -- open the menu
      zRP.openMenu(player,menu)
    end
  end

  local wardrobe_leave = function(player,area)
    zRP.closeMenu(player)
  end

  local nid = "zRP:home:slot"..stype..sid..":wardrobe"
  zRPclient._setNamedMarker(player,nid,x,y,z-1,0.7,0.7,0.5,0,255,125,125,150)
  zRP.setArea(player,nid,x,y,z,1,1.5,wardrobe_enter,wardrobe_leave)
end

local function wardrobe_destroy(owner_id, stype, sid, cid, config, data, x, y, z, player)
  local nid = "zRP:home:slot"..stype..sid..":wardrobe"
  zRPclient._removeNamedMarker(player,nid)
  zRP.removeArea(player,nid)
end

zRP.defHomeComponent("wardrobe", wardrobe_create, wardrobe_destroy)

-- GAMETABLE

local function gametable_create(owner_id, stype, sid, cid, config, data, x, y, z, player)
  local gametable_enter = function(player,area)
    local user_id = zRP.getUserId(player)
    if user_id and user_id == owner_id then
      -- build menu
      local menu = {name=lang.home.gametable.title(),css={top = "75px", header_color="rgba(0,255,125,0.75)"}}

      -- launch bet
      menu[lang.home.gametable.bet.title()] = {function(player, choice)
        local amount = zRP.prompt(player, lang.home.gametable.bet.prompt(), "")
          amount = parseInt(amount)
          if amount > 0 then
            if zRP.tryPayment(user_id,amount) then
              zRPclient._notify(player,lang.home.gametable.bet.started())
              -- init bet total and players (add by default the bet launcher)
              local bet_total = amount 
              local bet_players = {}
              local bet_opened = true
              table.insert(bet_players, player)

              local close_bet = function()
                if bet_opened then
                  bet_opened = false
                  -- select winner
                  local wplayer = bet_players[math.random(1,#bet_players)]
                  local wuser_id = zRP.getUserId(wplayer)
                  if wuser_id then
                    zRP.giveMoney(wuser_id, bet_total)
                    zRPclient._notify(wplayer,lang.money.received({bet_total}))
                    zRPclient._playAnim(wplayer,true,{{"mp_player_introck","mp_player_int_rock",1}},false)
                  end
                end
              end

              -- send bet request to all nearest players
              local players = zRPclient.getNearestPlayers(player,7)
                local pcount = 0
                for k,v in pairs(players) do
                  pcount = pcount+1
                  local nplayer = parseInt(k)
                  local nuser_id = zRP.getUserId(nplayer)
                  if nuser_id then -- request
                    Citizen.CreateThread(function() -- non blocking
                      if zRP.request(nplayer,lang.home.gametable.bet.request({amount}), 30) and bet_opened then
                        if zRP.tryPayment(nuser_id,amount) then -- register player bet
                          bet_total = bet_total+amount
                          table.insert(bet_players, nplayer)
                          zRPclient._notify(nplayer,lang.money.paid({amount}))
                        else
                          zRPclient._notify(nplayer,lang.money.not_enough())
                        end
                      end

                      pcount = pcount-1
                      if pcount == 0 then -- autoclose bet, everyone is ok
                        close_bet()
                      end
                    end)
                  end
                end

                -- bet timeout
                SetTimeout(32000, close_bet)
            else
              zRPclient._notify(player,lang.money.not_enough())
            end
          else
            zRPclient._notify(player,lang.common.invalid_value())
          end
      end,lang.home.gametable.bet.description()}

      -- open the menu
      zRP.openMenu(player,menu)
    end
  end

  local gametable_leave = function(player,area)
    zRP.closeMenu(player)
  end

  local nid = "zRP:home:slot"..stype..sid..":gametable"
  zRPclient._setNamedMarker(player,nid,x,y,z-1,0.7,0.7,0.5,0,255,125,125,150)
  zRP.setArea(player,nid,x,y,z,1,1.5,gametable_enter,gametable_leave)
end

local function gametable_destroy(owner_id, stype, sid, cid, config, data, x, y, z, player)
  local nid = "zRP:home:slot"..stype..sid..":gametable"
  zRPclient._removeNamedMarker(player,nid)
  zRP.removeArea(player,nid)
end

zRP.defHomeComponent("gametable", gametable_create, gametable_destroy)

-- ITEM TRANSFORMERS

-- item transformers are global to all players, so we need a counter to know when to create/destroy them
local itemtrs = {}

local function itemtr_create(owner_id, stype, sid, cid, config, data, x, y, z, player)
  local nid = "home:slot"..stype..sid..":itemtr"..cid
  if itemtrs[nid] == nil then
    itemtrs[nid] = 1

    -- simple copy
    local itemtr = {}
    for k,v in pairs(config) do
      itemtr[k] = v
    end

    itemtr.x = x
    itemtr.y = y
    itemtr.z = z

    zRP.setItemTransformer(nid, itemtr)
  else
    itemtrs[nid] = itemtrs[nid]+1
  end
end

local function itemtr_destroy(owner_id, stype, sid, cid, config, data, x, y, z, player)
  local nid = "home:slot"..stype..sid..":itemtr"..cid
  if itemtrs[nid] ~= nil then
    itemtrs[nid] = itemtrs[nid]-1
    if itemtrs[nid] == 0 then
      itemtrs[nid] = nil
      zRP.removeItemTransformer(nid)
    end
  end
end

zRP.defHomeComponent("itemtr", itemtr_create, itemtr_destroy)

-- RADIO

local function radio_create(owner_id, stype, sid, cid, config, data, x, y, z, player)
  local nid = "zRP:home:slot"..stype..sid..":radio"..cid
  -- build menu
  local menu = {name=lang.home.radio.title(),css={top = "75px", header_color="rgba(0,125,255,0.75)"}}

  -- audio position
  local rx,ry,rz = x,y,z+1
  if config.position then
    rx,ry,rz = table.unpack(config.position)
  end

  local function choose(player, choice)
    data.station = config.stations[choice]

    -- apply station change to players
    local players = zRP.getHomeSlotPlayers(stype, sid) or {}
    for k,v in pairs(players) do
      if data.station then
        zRPclient._setAudioSource(v, nid, data.station, 0.5, rx, ry, rz, 50)
      else
        zRPclient._removeAudioSource(v, nid)
      end
    end
  end
  
  for k,v in pairs(config.stations) do
    menu[k] = {choose}
  end

  menu[lang.home.radio.off.title()] = {choose} -- add off option

  local radio_enter = function(player,area)
    zRP.openMenu(player, menu)
  end

  local radio_leave = function(player,area)
    zRP.closeMenu(player)
  end

  zRPclient._setNamedMarker(player,nid,x,y,z-1,0.7,0.7,0.5,0,255,125,125,150)
  zRP.setArea(player,nid,x,y,z,1,1.5,radio_enter,radio_leave)

  if data.station then -- auto load station
    zRPclient._setAudioSource(player, nid, data.station, 0.5, rx, ry, rz, 50)
  end
end

local function radio_destroy(owner_id, stype, sid, cid, config, data, x, y, z, player)
  local nid = "zRP:home:slot"..stype..sid..":radio"..cid
  zRPclient._removeNamedMarker(player,nid)
  zRP.removeArea(player,nid)
  zRPclient._removeAudioSource(player, nid)
end

zRP.defHomeComponent("radio", radio_create, radio_destroy)
