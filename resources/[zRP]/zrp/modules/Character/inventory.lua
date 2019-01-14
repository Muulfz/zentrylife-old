local lang = zRP.lang
local cfg = module("cfg/Modules/inventory")

-- this module define the player inventory (lost after respawn, as wallet)

zRP.items = {}

-- define an inventory item (call this at server start) (parametric or plain text data)
-- idname: unique item name
-- name: display name or genfunction
-- description: item description (html) or genfunction
-- choices: menudata choices (see gui api) only as genfunction or nil
-- weight: weight or genfunction
--
-- genfunction are functions returning a correct value as: function(args) return value end
-- where args is a list of {base_idname,arg,arg,arg,...}
function zRP.defInventoryItem(idname,name,description,choices,weight)
  if weight == nil then
    weight = 0
  end

  local item = {name=name,description=description,choices=choices,weight=weight}
  zRP.items[idname] = item
end

-- give action
function ch_give(idname, player, choice)
  local user_id = zRP.getUserId(player)
  if user_id then
    -- get nearest player
    local nplayer = zRPclient.getNearestPlayer(player,10)
    if nplayer then
      local nuser_id = zRP.getUserId(nplayer)
      if nuser_id then
        -- prompt number
        local amount = zRP.prompt(player,lang.inventory.give.prompt({zRP.getInventoryItemAmount(user_id,idname)}),"")
        local amount = parseInt(amount)
        -- weight check
        local new_weight = zRP.getInventoryWeight(nuser_id)+zRP.getItemWeight(idname)*amount
        if new_weight <= zRP.getInventoryMaxWeight(nuser_id) then
          if zRP.tryGetInventoryItem(user_id,idname,amount,true) then
            zRP.giveInventoryItem(nuser_id,idname,amount,true)

            zRPclient._playAnim(player,true,{{"mp_common","givetake1_a",1}},false)
            zRPclient._playAnim(nplayer,true,{{"mp_common","givetake2_a",1}},false)
          else
            zRPclient._notify(player,lang.common.invalid_value())
          end
        else
          zRPclient._notify(player,lang.inventory.full())
        end
      else
        zRPclient._notify(player,lang.common.no_player_near())
      end
    else
      zRPclient._notify(player,lang.common.no_player_near())
    end
  end
end

-- trash action
function ch_trash(idname, player, choice)
  local user_id = zRP.getUserId(player)
  if user_id then
    -- prompt number
    local amount = zRP.prompt(player,lang.inventory.trash.prompt({zRP.getInventoryItemAmount(user_id,idname)}),"")
    local amount = parseInt(amount)
    if zRP.tryGetInventoryItem(user_id,idname,amount,false) then
      zRPclient._notify(player,lang.inventory.trash.done({zRP.getItemName(idname),amount}))
      zRPclient._playAnim(player,true,{{"pickup_object","pickup_low",1}},false)
      TriggerEvent("zrp_itemdrop:createBag", player, idname, amount)
    else
      zRPclient._notify(player,lang.common.invalid_value())
    end
  end
end

function zRP.computeItemName(item,args)
  if type(item.name) == "string" then return item.name
  else return item.name(args) end
end

function zRP.computeItemDescription(item,args)
  if type(item.description) == "string" then return item.description
  else return item.description(args) end
end

function zRP.computeItemChoices(item,args)
  if item.choices ~= nil then
    return item.choices(args)
  else
    return {}
  end
end

function zRP.computeItemWeight(item,args)
  if type(item.weight) == "number" then return item.weight
  else return item.weight(args) end
end


function zRP.parseItem(idname)
  return splitString(idname,"|")
end

-- return name, description, weight
function zRP.getItemDefinition(idname)
  local args = zRP.parseItem(idname)
  local item = zRP.items[args[1]]
  if item then
    return zRP.computeItemName(item,args), zRP.computeItemDescription(item,args), zRP.computeItemWeight(item,args)
  end

  return nil,nil,nil
end

function zRP.getItemName(idname)
  local args = zRP.parseItem(idname)
  local item = zRP.items[args[1]]
  if item then return zRP.computeItemName(item,args) end
  return args[1]
end

function zRP.getItemDescription(idname)
  local args = zRP.parseItem(idname)
  local item = zRP.items[args[1]]
  if item then return zRP.computeItemDescription(item,args) end
  return ""
end

function zRP.getItemChoices(idname)
  local args = zRP.parseItem(idname)
  local item = zRP.items[args[1]]
  local choices = {}
  if item then
    -- compute choices
    local cchoices = zRP.computeItemChoices(item,args)
    if cchoices then -- copy computed choices
      for k,v in pairs(cchoices) do
        choices[k] = v
      end
    end

    -- add give/trash choices
    choices[lang.inventory.give.title()] = {function(player,choice) ch_give(idname, player, choice) end, lang.inventory.give.description()}
    choices[lang.inventory.trash.title()] = {function(player, choice) ch_trash(idname, player, choice) end, lang.inventory.trash.description()}
  end

  return choices
end

function zRP.getItemWeight(idname)
  local args = zRP.parseItem(idname)
  local item = zRP.items[args[1]]
  if item then return zRP.computeItemWeight(item,args) end
  return 0
end

-- compute weight of a list of items (in inventory/chest format)
function zRP.computeItemsWeight(items)
  local weight = 0

  for k,v in pairs(items) do
    local iweight = zRP.getItemWeight(k)
    weight = weight+iweight*v.amount
  end

  return weight
end

-- add item to a connected user inventory
function zRP.giveInventoryItem(user_id,idname,amount,notify)
  if notify == nil then notify = true end -- notify by default

  local data = zRP.getUserDataTable(user_id)
  if data and amount > 0 then
    local entry = data.inventory[idname]
    if entry then -- add to entry
      entry.amount = entry.amount+amount
    else -- new entry
      data.inventory[idname] = {amount=amount}
    end

    -- notify
    if notify then
      local player = zRP.getUserSource(user_id)
      if player then
        zRPclient._notify(player,lang.inventory.give.received({zRP.getItemName(idname),amount}))
      end
    end
  end
end

-- try to get item from a connected user inventory
function zRP.tryGetInventoryItem(user_id,idname,amount,notify)
  if notify == nil then notify = true end -- notify by default

  local data = zRP.getUserDataTable(user_id)
  if data and amount > 0 then
    local entry = data.inventory[idname]
    if entry and entry.amount >= amount then -- add to entry
      entry.amount = entry.amount-amount

      -- remove entry if <= 0
      if entry.amount <= 0 then
        data.inventory[idname] = nil 
      end

      -- notify
      if notify then
        local player = zRP.getUserSource(user_id)
        if player then
          zRPclient._notify(player,lang.inventory.give.given({zRP.getItemName(idname),amount}))
        end
      end

      return true
    else
      -- notify
      if notify then
        local player = zRP.getUserSource(user_id)
        if player then
          local entry_amount = 0
          if entry then entry_amount = entry.amount end
          zRPclient._notify(player,lang.inventory.missing({zRP.getItemName(idname),amount-entry_amount}))
        end
      end
    end
  end

  return false
end

-- get item amount from a connected user inventory
function zRP.getInventoryItemAmount(user_id,idname)
  local data = zRP.getUserDataTable(user_id)
  if data and data.inventory then
    local entry = data.inventory[idname]
    if entry then
      return entry.amount
    end
  end

  return 0
end

-- get connected user inventory
-- return map of full idname => amount or nil 
function zRP.getInventory(user_id)
  local data = zRP.getUserDataTable(user_id)
  if data then
    return data.inventory
  end
end

-- return user inventory total weight
function zRP.getInventoryWeight(user_id)
  local data = zRP.getUserDataTable(user_id)
  if data and data.inventory then
    return zRP.computeItemsWeight(data.inventory)
  end

  return 0
end

-- return maximum weight of the user inventory
function zRP.getInventoryMaxWeight(user_id)
  return math.floor(zRP.expToLevel(zRP.getExp(user_id, "physical", "strength")))*cfg.inventory_weight_per_strength
end

-- clear connected user inventory
function zRP.clearInventory(user_id)
  local data = zRP.getUserDataTable(user_id)
  if data then
    data.inventory = {}
  end
end

-- INVENTORY MENU

-- open player inventory
function zRP.openInventory(source)
  local user_id = zRP.getUserId(source)

  if user_id then
    local data = zRP.getUserDataTable(user_id)
    if data then
      -- build inventory menu
      local menudata = {name=lang.inventory.title(),css={top="75px",header_color="rgba(0,125,255,0.75)"}}
      -- add inventory info
      local weight = zRP.getInventoryWeight(user_id)
      local max_weight = zRP.getInventoryMaxWeight(user_id)
      local hue = math.floor(math.max(125*(1-weight/max_weight), 0))
      menudata["<div class=\"dprogressbar\" data-value=\""..string.format("%.2f",weight/max_weight).."\" data-color=\"hsl("..hue..",100%,50%)\" data-bgcolor=\"hsl("..hue..",100%,25%)\" style=\"height: 12px; border: 3px solid black;\"></div>"] = {function()end, lang.inventory.info_weight({string.format("%.2f",weight),max_weight})}
      local kitems = {}

      -- choose callback, nested menu, create the item menu
      local choose = function(player,choice)
        if string.sub(choice,1,1) ~= "@" then -- ignore info choices
        local choices = zRP.getItemChoices(kitems[choice])
          -- build item menu
          local submenudata = {name=choice,css={top="75px",header_color="rgba(0,125,255,0.75)"}}

          -- add computed choices
          for k,v in pairs(choices) do
          submenudata[k] = v
        end

          -- nest menu
          submenudata.onclose = function()
            zRP.openInventory(source) -- reopen inventory when submenu closed
          end

          -- open menu
          zRP.openMenu(source,submenudata)
        end
      end

      -- add each item to the menu
      for k,v in pairs(data.inventory) do 
        local name,description,weight = zRP.getItemDefinition(k)
        if name ~= nil then
          kitems[name] = k -- reference item by display name
          menudata[name] = {choose,lang.inventory.iteminfo({v.amount,description,string.format("%.2f",weight)})}
        end
      end

      -- open menu
      zRP.openMenu(source,menudata)
    end
  end
end

-- init inventory
AddEventHandler("zRP:playerJoin", function(user_id,source,name,last_login)
  local data = zRP.getUserDataTable(user_id)
  if not data.inventory then
    data.inventory = {}
  end
end)



zRP.registerMenuBuilder("quick_menu", function(add, data)
  local player = data.player
  local user_id = zRP.getUserId(player)
  local is_block = zRPclient.isPlayerBlockFull(player)
  if user_id then
    local choices = {}
    if not is_block then
      print("DESBLOQUEADO")
      choices[lang.inventory.title()] = {function(player, choice) zRP.openInventory(player) end, lang.inventory.description()}
    else
      print("BLOQUEADO")
    end
    add(choices)
  end
end)

-- CHEST SYSTEM

local chests = {}

-- build a menu from a list of items and bind a callback(idname)
local function build_itemlist_menu(name, items, cb)
  local menu = {name=name, css={top="75px",header_color="rgba(0,255,125,0.75)"}}

  local kitems = {}

  -- choice callback
  local choose = function(player,choice)
    local idname = kitems[choice]
    if idname then
      cb(idname)
    end
  end

  -- add each item to the menu
  for k,v in pairs(items) do 
    local name,description,weight = zRP.getItemDefinition(k)
    if name then
      kitems[name] = k -- reference item by display name
      menu[name] = {choose,lang.inventory.iteminfo({v.amount,description,string.format("%.2f", weight)})}
    end
  end

  return menu
end

-- open a chest by name
-- cb_close(): called when the chest is closed (optional)
-- cb_in(idname, amount): called when an item is added (optional)
-- cb_out(idname, amount): called when an item is taken (optional)
function zRP.openChest(source, name, max_weight, cb_close, cb_in, cb_out)
  local user_id = zRP.getUserId(source)
  if user_id then
    local data = zRP.getUserDataTable(user_id)
    if data.inventory then
      if not chests[name] then
        local close_count = 0 -- used to know when the chest is closed (unlocked)

        -- load chest
        local chest = {max_weight = max_weight}
        chests[name] = chest 
        local cdata = zRP.getSData("chest:"..name)
        chest.items = json.decode(cdata) or {} -- load items

        -- open menu
        local menu = {name=lang.inventory.chest.title(), css={top="75px",header_color="rgba(0,255,125,0.75)"}}
        -- take
        local cb_take = function(idname)
          local citem = chest.items[idname]
          local amount = zRP.prompt(source, lang.inventory.chest.take.prompt({citem.amount}), "")
          amount = parseInt(amount)
          if amount >= 0 and amount <= citem.amount then
            -- take item

            -- weight check
            local new_weight = zRP.getInventoryWeight(user_id)+zRP.getItemWeight(idname)*amount
            if new_weight <= zRP.getInventoryMaxWeight(user_id) then
              zRP.giveInventoryItem(user_id, idname, amount, true)
              citem.amount = citem.amount-amount

              if citem.amount <= 0 then
                chest.items[idname] = nil -- remove item entry
              end

              if cb_out then cb_out(idname,amount) end

              -- actualize by closing
              zRP.closeMenu(source)
            else
              zRPclient._notify(source,lang.inventory.full())
            end
          else
            zRPclient._notify(source,lang.common.invalid_value())
          end
        end

        local ch_take = function(player, choice)
          local submenu = build_itemlist_menu(lang.inventory.chest.take.title(), chest.items, cb_take)
          -- add weight info
          local weight = zRP.computeItemsWeight(chest.items)
          local hue = math.floor(math.max(125*(1-weight/max_weight), 0))
          submenu["<div class=\"dprogressbar\" data-value=\""..string.format("%.2f",weight/max_weight).."\" data-color=\"hsl("..hue..",100%,50%)\" data-bgcolor=\"hsl("..hue..",100%,25%)\" style=\"height: 12px; border: 3px solid black;\"></div>"] = {function()end, lang.inventory.info_weight({string.format("%.2f",weight),max_weight})}


          submenu.onclose = function()
            close_count = close_count-1
            zRP.openMenu(player, menu)
          end
          close_count = close_count+1
          zRP.openMenu(player, submenu)
        end


        -- put
        local cb_put = function(idname)
          local amount = zRP.prompt(source, lang.inventory.chest.put.prompt({zRP.getInventoryItemAmount(user_id, idname)}), "")
          amount = parseInt(amount)

          -- weight check
          local new_weight = zRP.computeItemsWeight(chest.items)+zRP.getItemWeight(idname)*amount
          if new_weight <= max_weight then
            if amount >= 0 and zRP.tryGetInventoryItem(user_id, idname, amount, true) then
              local citem = chest.items[idname]

              if citem ~= nil then
                citem.amount = citem.amount+amount
              else -- create item entry
                chest.items[idname] = {amount=amount}
              end

              -- callback
              if cb_in then cb_in(idname,amount) end

              -- actualize by closing
              zRP.closeMenu(source)
            end
          else
            zRPclient._notify(source,lang.inventory.chest.full())
          end
        end

        local ch_put = function(player, choice)
          local submenu = build_itemlist_menu(lang.inventory.chest.put.title(), data.inventory, cb_put)
          -- add weight info
          local weight = zRP.computeItemsWeight(data.inventory)
          local max_weight = zRP.getInventoryMaxWeight(user_id)
          local hue = math.floor(math.max(125*(1-weight/max_weight), 0))
          submenu["<div class=\"dprogressbar\" data-value=\""..string.format("%.2f",weight/max_weight).."\" data-color=\"hsl("..hue..",100%,50%)\" data-bgcolor=\"hsl("..hue..",100%,25%)\" style=\"height: 12px; border: 3px solid black;\"></div>"] = {function()end, lang.inventory.info_weight({string.format("%.2f",weight),max_weight})}

          submenu.onclose = function() 
            close_count = close_count-1
            zRP.openMenu(player, menu)
          end
          close_count = close_count+1
          zRP.openMenu(player, submenu)
        end


        -- choices
        menu[lang.inventory.chest.take.title()] = {ch_take}
        menu[lang.inventory.chest.put.title()] = {ch_put}

        menu.onclose = function()
          if close_count == 0 then -- close chest
            -- save chest items
            zRP.setSData("chest:"..name, json.encode(chest.items))
            chests[name] = nil
            if cb_close then cb_close() end -- close callback
          end
        end

        -- open menu
        zRP.openMenu(source, menu)
      else
        zRPclient._notify(source,lang.inventory.chest.already_opened())
      end
    end
  end
end

-- STATIC CHESTS

local function build_client_static_chests(source)
  local user_id = zRP.getUserId(source)
  if user_id then
    for k,v in pairs(cfg.static_chests) do
      local mtype,x,y,z = table.unpack(v)
      local schest = cfg.static_chest_types[mtype]

      if schest then
        local function schest_enter(source)
          local user_id = zRP.getUserId(source)
          if user_id ~= nil and zRP.hasPermissions(user_id,schest.permissions or {}) then
            -- open chest
            zRP.openChest(source, "static:"..k, schest.weight or 0)
          end
        end

        local function schest_leave(source)
          zRP.closeMenu(source)
        end

        zRPclient._addBlip(source,x,y,z,schest.blipid,schest.blipcolor,schest.title)
        zRPclient._addMarker(source,x,y,z-1,0.7,0.7,0.5,255,226,0,125,150)

        zRP.setArea(source,"zRP:static_chest:"..k,x,y,z,1,1.5,schest_enter,schest_leave)
      end
    end
  end
end

AddEventHandler("zRP:playerSpawn",function(user_id, source, first_spawn)
  if first_spawn then
    -- load static chests
    build_client_static_chests(source)
  end
end)


