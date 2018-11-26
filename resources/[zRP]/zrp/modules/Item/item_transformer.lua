
--TODO trocar para Character
-- this module define a generic system to transform (generate, process, convert) items and money to other items or money in a specific area
-- each transformer can take things to generate other things, using a unit of work
-- units are generated periodically at a specific rate
-- reagents => products (reagents can be nothing, as for an harvest transformer)

local cfg = module("cfg/Modules/item_transformers")
local lang = zRP.lang

-- api

local transformers = {}

local function tr_remove_player(tr,player) -- remove player from transforming
  local recipe = tr.players[player] or ""
  tr.players[player] = nil -- dereference player
  zRPclient._removeProgressBar(player,"zRP:tr:"..tr.name)
  zRP.closeMenu(player)

  -- onstop
  if tr.itemtr.onstop then tr.itemtr.onstop(player,recipe) end
end

local function tr_add_player(tr,player,recipe) -- add player to transforming
  tr.players[player] = recipe -- reference player as using transformer
  zRP.closeMenu(player)
  zRPclient._setProgressBar(player,"zRP:tr:"..tr.name,"center",recipe.."...",tr.itemtr.r,tr.itemtr.g,tr.itemtr.b,0)

  -- onstart
  if tr.itemtr.onstart then tr.itemtr.onstart(player,recipe) end
end

local function tr_tick(tr) -- do transformer tick
  for k,v in pairs(tr.players) do
    local user_id = zRP.getUserId(tonumber(k))
    if v and user_id then -- for each player transforming
      local recipe = tr.itemtr.recipes[v]
      if tr.units > 0 and recipe then -- check units
        -- check reagents
        local reagents_ok = true
        for l,w in pairs(recipe.reagents) do
          reagents_ok = reagents_ok and (zRP.getInventoryItemAmount(user_id,l) >= w)
        end

        -- check money
        local money_ok = (zRP.getMoney(user_id) >= recipe.in_money)

        -- weight check
        local out_witems = {}
        for k,v in pairs(recipe.products) do
          out_witems[k] = {amount=v}
        end
        local in_witems = {}
        for k,v in pairs(recipe.reagents) do
          in_witems[k] = {amount=v}
        end
        local new_weight = zRP.getInventoryWeight(user_id)+zRP.computeItemsWeight(out_witems)-zRP.computeItemsWeight(in_witems)

        local inventory_ok = true
        if new_weight > zRP.getInventoryMaxWeight(user_id) then
          inventory_ok = false
          zRPclient._notify(tonumber(k), lang.inventory.full())
        end

        if not money_ok then
          zRPclient._notify(tonumber(k), lang.money.not_enough())
        end

        if not reagents_ok then
          zRPclient._notify(tonumber(k), lang.itemtr.not_enough_reagents())
        end

        if money_ok and reagents_ok and inventory_ok then -- do transformation
          tr.units = tr.units-1 -- sub work unit

          -- consume reagents
          if recipe.in_money > 0 then zRP.tryPayment(user_id,recipe.in_money) end
          for l,w in pairs(recipe.reagents) do
            zRP.tryGetInventoryItem(user_id,l,w,true)
          end

          -- produce products
          if recipe.out_money > 0 then zRP.giveMoney(user_id,recipe.out_money) end
          for l,w in pairs(recipe.products) do
            zRP.giveInventoryItem(user_id,l,w,true)
          end

          -- give exp
          for l,w in pairs(recipe.aptitudes or {}) do
            local parts = splitString(l,".")
            if #parts == 2 then
              zRP.varyExp(user_id,parts[1],parts[2],w)
            end
          end

          -- onstep
          if tr.itemtr.onstep then tr.itemtr.onstep(tonumber(k),v) end
        end
      end
    end
  end

  -- display transformation state to all transforming players
  for k,v in pairs(tr.players) do
    zRPclient._setProgressBarValue(k,"zRP:tr:"..tr.name,math.floor(tr.units/tr.itemtr.max_units*100.0))
    
    if tr.units > 0 then -- display units left
      zRPclient._setProgressBarText(k,"zRP:tr:"..tr.name,v.."... "..tr.units.."/"..tr.itemtr.max_units)
    else
      zRPclient._setProgressBarText(k,"zRP:tr:"..tr.name,"empty")
    end
  end
end

local function bind_tr_area(player,tr) -- add tr area to client
  zRP.setArea(player,"zRP:tr:"..tr.name,tr.itemtr.x,tr.itemtr.y,tr.itemtr.z,tr.itemtr.radius,tr.itemtr.height,tr.enter,tr.leave)
end

local function unbind_tr_area(player,tr) -- remove tr area from client
  zRP.removeArea(player,"zRP:tr:"..tr.name)
end

-- add an item transformer
-- name: transformer id name
-- itemtr: item transformer definition table
--- name
--- max_units
--- units_per_minute
--- x,y,z,radius,height (area properties)
--- r,g,b (color)
--- action
--- description
--- in_money
--- out_money
--- reagents: items as idname => amount
--- products: items as idname => amount
function zRP.setItemTransformer(name,itemtr)
  zRP.removeItemTransformer(name) -- remove pre-existing transformer

  local tr = {itemtr=itemtr}
  tr.name = name
  transformers[name] = tr

  -- init transformer
  tr.units = 0
  tr.players = {}

  -- build menu
  tr.menu = {name=itemtr.name,css={top="75px",header_color="rgba("..itemtr.r..","..itemtr.g..","..itemtr.b..",0.75)"}}

  -- build recipes
  for action,recipe in pairs(tr.itemtr.recipes) do
    local info = "<br /><br />"
    if recipe.in_money > 0 then info = info.."- "..recipe.in_money end
    for k,v in pairs(recipe.reagents) do
      local item_name, item_desc, item_weight = zRP.getItemDefinition(k)
      if item_name then
        info = info.."<br />"..v.." "..item_name
      end
    end
    info = info.."<br /><span style=\"color: rgb(0,255,125)\">=></span>"
    if recipe.out_money > 0 then info = info.."<br />+ "..recipe.out_money end
    for k,v in pairs(recipe.products) do
      local item_name, item_desc, item_weight = zRP.getItemDefinition(k)
      if item_name then
        info = info.."<br />"..v.." "..item_name
      end
    end
    for k,v in pairs(recipe.aptitudes or {}) do
      local parts = splitString(k,".")
      if #parts == 2 then
        local def = zRP.getAptitudeDefinition(parts[1],parts[2])
        if def then
          info = info.."<br />[EXP] "..v.." "..zRP.getAptitudeGroupTitle(parts[1]).."/"..def[1]
        end
      end
    end

    tr.menu[action] = {function(player,choice)
      if zRP.inArea(player, "zRP:tr:"..tr.name) then
        tr_add_player(tr,player,action)
      end
    end, recipe.description..info}
  end

  -- build area
  tr.enter = function(player,area)
    local user_id = zRP.getUserId(player)
    if user_id and zRP.hasPermissions(user_id,itemtr.permissions or {}) then
      zRP.openMenu(player, tr.menu) -- open menu
    end
  end

  tr.leave = function(player,area)
    tr_remove_player(tr, player)
  end

  -- bind tr area to all already spawned players
  for k,v in pairs(zRP.rusers) do
    local source = zRP.getUserSource(k)
    if source then
      bind_tr_area(source,tr)
    end
  end
end

-- remove an item transformer
function zRP.removeItemTransformer(name)
  local tr = transformers[name]
  if tr then
    -- copy players (to remove while iterating)
    local players = {}
    for k,v in pairs(tr.players) do
      players[k] = v
    end

    for k,v in pairs(players) do -- remove players from transforming
      tr_remove_player(tr,k)
    end

    -- remove tr area from all already spawned players
    for k,v in pairs(zRP.rusers) do
      local source = zRP.getUserSource(k)
      if source then
        unbind_tr_area(source,tr)
      end
    end

    transformers[name] = nil
  end
end

-- task: transformers ticks (every 3 seconds)
local function transformers_tick()
  SetTimeout(0,function() -- error death protection for transformers_tick() 
    for k,tr in pairs(transformers) do
      tr_tick(tr)
    end
  end)

  SetTimeout(3000,transformers_tick)
end
transformers_tick()

-- task: transformers unit regeneration
local function transformers_regen()
  for k,tr in pairs(transformers) do
    tr.units = tr.units+tr.itemtr.units_per_minute
    if tr.units >= tr.itemtr.max_units then tr.units = tr.itemtr.max_units end
  end

  SetTimeout(60000,transformers_regen)
end
transformers_regen()

-- add transformers areas on player first spawn
AddEventHandler("zRP:playerSpawn",function(user_id, source, first_spawn)
  if first_spawn then
    for k,tr in pairs(transformers) do
      bind_tr_area(source,tr)
    end
  end
end)

-- STATIC TRANSFORMERS

SetTimeout(5000,function()
  -- delayed to wait items loading
  -- load item transformers from config file
  for k,v in pairs(cfg.item_transformers) do
    zRP.setItemTransformer("cfg:"..k,v)
  end
end)

-- HIDDEN TRANSFORMERS

-- generate a random position for the hidden transformer
local function gen_random_position(positions)
  local n = #positions
  if n > 0 then
    return positions[math.random(1,n)]
  else 
    return {0,0,0}
  end
end

local function hidden_placement_tick()
  local data = zRP.getSData("zRP:hidden_trs")
  local hidden_trs = json.decode(data) or {}

  for k,v in pairs(cfg.hidden_transformers) do
    -- init entry
    local htr = hidden_trs[k]
    if not htr then
      hidden_trs[k] = {timestamp=parseInt(os.time()), position=gen_random_position(v.positions)}
      htr = hidden_trs[k]
    end

    -- remove hidden transformer if needs respawn
    if tonumber(os.time())-htr.timestamp >= cfg.hidden_transformer_duration*60 then
      htr.timestamp = parseInt(os.time())
      zRP.removeItemTransformer("cfg:"..k)
      -- generate new position
      htr.position = gen_random_position(v.positions)
    end

    -- spawn if unspawned 
    if transformers["cfg:"..k] == nil then
      v.def.x = htr.position[1]
      v.def.y = htr.position[2]
      v.def.z = htr.position[3]

      zRP.setItemTransformer("cfg:"..k, v.def)
    end
  end

  zRP.setSData("zRP:hidden_trs",json.encode(hidden_trs)) -- save hidden transformers
  SetTimeout(300000, hidden_placement_tick)
end
SetTimeout(5000, hidden_placement_tick) -- delayed to wait items loading

-- INFORMER

-- build informer menu
local informer_menu = {name=lang.itemtr.informer.title(), css={top="75px",header_color="rgba(0,255,125,0.75)"}}

local function ch_informer_buy(player,choice)
  local user_id = zRP.getUserId(player)
  local tr = transformers["cfg:"..choice]
  local price = cfg.informer.infos[choice]

  if user_id and tr then
    if zRP.tryPayment(user_id, price) then
      zRPclient._setGPS(player, tr.itemtr.x,tr.itemtr.y) -- set gps marker
      zRPclient._notify(player, lang.money.paid({price}))
      zRPclient._notify(player, lang.itemtr.informer.bought())
    else
      zRPclient._notify(player, lang.money.not_enough())
    end
  end
end

for k,v in pairs(cfg.informer.infos) do
  informer_menu[k] = {ch_informer_buy, lang.itemtr.informer.description({v})}
end

local function informer_enter(source)
  local user_id = zRP.getUserId(source)
  if user_id then
    zRP.openMenu(source,informer_menu)
  end
end

local function informer_leave(source)
  zRP.closeMenu(source)
end

local function informer_placement_tick()
  local pos = gen_random_position(cfg.informer.positions)
  local x,y,z = table.unpack(pos)

  for k,v in pairs(zRP.rusers) do
    local player = zRP.getUserSource(tonumber(k))

    -- add informer blip/marker/area
    zRPclient._setNamedBlip(player,"zRP:informer",x,y,z,cfg.informer.blipid,cfg.informer.blipcolor,lang.itemtr.informer.title())
    zRPclient._setNamedMarker(player,"zRP:informer",x,y,z-1,0.7,0.7,0.5,0,255,125,125,150)
    zRP.setArea(player,"zRP:informer",x,y,z,1,1.5,informer_enter,informer_leave)
  end

  -- remove informer blip/marker/area after after a while
  SetTimeout(cfg.informer.duration*60000, function()
    for k,v in pairs(zRP.rusers) do
      local player = zRP.getUserSource(tonumber(k))
      zRPclient._removeNamedBlip(player,"zRP:informer")
      zRPclient._removeNamedMarker(player,"zRP:informer")
      zRP.removeArea(player,"zRP:informer")
    end
  end)

  SetTimeout(cfg.informer.interval*60000, informer_placement_tick)
end
SetTimeout(cfg.informer.interval*60000,informer_placement_tick)
