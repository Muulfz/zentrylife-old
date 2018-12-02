local htmlEntities = module("lib/htmlEntities")
local Tools = module("lib/Tools")

-- this module define some admin menu functions

local player_lists = {}

local function ch_list(player,choice)
  local user_id = zRP.getUserId(player)
  if user_id and zRP.hasPermission(user_id,"player.list") then
    if player_lists[player] then -- hide
      player_lists[player] = nil
      zRPclient._removeDiv(player,{"user_list"})
    else -- show
      local content = ""
      for k,v in pairs(zRP.rusers) do
        local source = zRP.getUserSource(k)
        local identity = zRP.getUserIdentity(k)
        if source then
          content = content.."<br />"..k.." => <span class=\"pseudo\">"..zRP.getPlayerName(source).."</span> <span class=\"endpoint\">"..zRP.getPlayerEndpoint(source).."</span>"
          if identity then
            content = content.." <span class=\"name\">"..htmlEntities.encode(identity.firstname).." "..htmlEntities.encode(identity.name).."</span> <span class=\"reg\">"..identity.registration.."</span> <span class=\"phone\">"..identity.phone.."</span>"
          end
        end
      end

      player_lists[player] = true
      local css = [[
.div_user_list{ 
  margin: auto; 
  padding: 8px; 
  width: 650px; 
  margin-top: 80px; 
  background: black; 
  color: white; 
  font-weight: bold; 
  font-size: 1.1em;
} 

.div_user_list .pseudo{ 
  color: rgb(0,255,125);
}

.div_user_list .endpoint{ 
  color: rgb(255,0,0);
}

.div_user_list .name{ 
  color: #309eff;
}

.div_user_list .reg{ 
  color: rgb(0,125,255);
}
              
.div_user_list .phone{ 
  color: rgb(211, 0, 255);
}
            ]]
      zRPclient._setDiv(player, "user_list", css, content)
    end
  end
end

local function ch_whitelist(player,choice)
  local user_id = zRP.getUserId(player)
  if user_id and zRP.hasPermission(user_id,"player.whitelist") then
    local id = zRP.prompt(player,"User id to whitelist: ","")
    id = parseInt(id)
    zRP.setWhitelisted(id,true)
    zRPclient._notify(player, "whitelisted user "..id)
  end
end

local function ch_unwhitelist(player,choice)
  local user_id = zRP.getUserId(player)
  if user_id and zRP.hasPermission(user_id,"player.unwhitelist") then
    local id = zRP.prompt(player,"User id to un-whitelist: ","")
    id = parseInt(id)
    zRP.setWhitelisted(id,false)
    zRPclient._notify(player, "un-whitelisted user "..id)
  end
end

local function ch_addgroup(player,choice)
  local user_id = zRP.getUserId(player)
  if user_id ~= nil and zRP.hasPermission(user_id,"player.group.add") then
    local id = zRP.prompt(player,"User id: ","")
    id = parseInt(id)
    local group = zRP.prompt(player,"Group to add: ","")
    if group then
      zRP.addUserGroup(id,group)
      zRPclient._notify(player, group.." added to user "..id)
    end
  end
end

local function ch_removegroup(player,choice)
  local user_id = zRP.getUserId(player)
  if user_id and zRP.hasPermission(user_id,"player.group.remove") then
    local id = zRP.prompt(player,"User id: ","")
    id = parseInt(id)
    local group = zRP.prompt(player,"Group to remove: ","")
    if group then
      zRP.removeUserGroup(id,group)
      zRPclient._notify(player, group.." removed from user "..id)
    end
  end
end

local function ch_kick(player,choice)
  local user_id = zRP.getUserId(player)
  if user_id and zRP.hasPermission(user_id,"player.kick") then
    local id = zRP.prompt(player,"User id to kick: ","")
    id = parseInt(id)
    local reason = zRP.prompt(player,"Reason: ","")
    local source = zRP.getUserSource(id)
    if source then
      zRP.kick(source,reason)
      zRPclient._notify(player, "kicked user "..id)
    end
  end
end

local function ch_ban(player,choice)
  local user_id = zRP.getUserId(player)
  if user_id and zRP.hasPermission(user_id,"player.ban") then
    local id = zRP.prompt(player,"User id to ban: ","")
    id = parseInt(id)
    local reason = zRP.prompt(player,"Reason: ","")
    local source = zRP.getUserSource(id)
    if source then
      zRP.ban(source,reason)
      zRPclient._notify(player, "banned user "..id)
    end
  end
end

local function ch_unban(player,choice)
  local user_id = zRP.getUserId(player)
  if user_id and zRP.hasPermission(user_id,"player.unban") then
    local id = zRP.prompt(player,"User id to unban: ","")
    id = parseInt(id)
    zRP.setBanned(id,false)
    zRPclient._notify(player, "un-banned user "..id)
  end
end

local function ch_emote(player,choice)
  local user_id = zRP.getUserId(player)
  if user_id and zRP.hasPermission(user_id,"player.custom_emote") then
    local content = zRP.prompt(player,"Animation sequence ('dict anim optional_loops' per line): ","")
    local seq = {}
    for line in string.gmatch(content,"[^\n]+") do
      local args = {}
      for arg in string.gmatch(line,"[^%s]+") do
        table.insert(args,arg)
      end

      table.insert(seq,{args[1] or "", args[2] or "", args[3] or 1})
    end

    zRPclient._playAnim(player, true,seq,false)
  end
end

local function ch_sound(player,choice)
  local user_id = zRP.getUserId(player)
  if user_id and zRP.hasPermission(user_id,"player.custom_sound") then
    local content = zRP.prompt(player,"Sound 'dict name': ","")
      local args = {}
      for arg in string.gmatch(content,"[^%s]+") do
        table.insert(args,arg)
      end
      zRPclient._playSound(player, args[1] or "", args[2] or "")
  end
end

local function ch_coords(player,choice)
  local x,y,z = zRPclient.getPosition(player)
  zRP.prompt(player,"Copy the coordinates using Ctrl-A Ctrl-C",x..","..y..","..z)
end

local function ch_tptome(player,choice)
  local x,y,z = zRPclient.getPosition(player)
  local user_id = zRP.prompt(player,"User id:","")
  local tplayer = zRP.getUserSource(tonumber(user_id))
  if tplayer then
    zRPclient._teleport(tplayer,x,y,z)
  end
end

local function ch_tpto(player,choice)
  local user_id = zRP.prompt(player,"User id:","")
  local tplayer = zRP.getUserSource(tonumber(user_id))
  if tplayer then
    zRPclient._teleport(player, zRPclient.getPosition(tplayer))
  end
end

local function ch_tptocoords(player,choice)
  local fcoords = zRP.prompt(player,"Coords x,y,z:","")
  local coords = {}
  for coord in string.gmatch(fcoords or "0,0,0","[^,]+") do
    table.insert(coords,tonumber(coord))
  end

  zRPclient._teleport(player, coords[1] or 0, coords[2] or 0, coords[3] or 0)
end

local function ch_givemoney(player,choice)
  local user_id = zRP.getUserId(player)
  if user_id then
    local amount = zRP.prompt(player,"Amount:","")
    amount = parseInt(amount)
    zRP.giveMoney(user_id, amount)
  end
end

local function ch_giveitem(player,choice)
  local user_id = zRP.getUserId(player)
  if user_id then
    local idname = zRP.prompt(player,"Id name:","")
    idname = idname or ""
    local amount = zRP.prompt(player,"Amount:","")
    amount = parseInt(amount)
    zRP.giveInventoryItem(user_id, idname, amount,true)
  end
end

local function ch_calladmin(player,choice)
  local user_id = zRP.getUserId(player)
  if user_id then
    local desc = zRP.prompt(player,"Describe your problem:","") or ""
    local answered = false
    local players = {}
    for k,v in pairs(zRP.rusers) do
      local player = zRP.getUserSource(tonumber(k))
      -- check user
      if zRP.hasPermission(k,"admin.tickets") and player then
        table.insert(players,player)
      end
    end

    -- send notify and alert to all listening players
    for k,v in pairs(players) do
      async(function()
        local ok = zRP.request(v,"Admin ticket (user_id = "..user_id..") take/TP to ?: "..htmlEntities.encode(desc), 60)
        if ok then -- take the call
          if not answered then
            -- answer the call
            zRPclient._notify(player,"An admin took your ticket.")
            zRPclient._teleport(v, zRPclient.getPosition(player))
            answered = true
          else
            zRPclient._notify(v,"Ticket already taken.")
          end
        end
      end)
    end
  end
end

local player_customs = {}

local function ch_display_custom(player, choice)
  local custom = zRPclient.getCustomization(player)
  if player_customs[player] then -- hide
    player_customs[player] = nil
    zRPclient._removeDiv(player,"customization")
  else -- show
    local content = ""
    for k,v in pairs(custom) do
      content = content..k.." => "..json.encode(v).."<br />" 
    end

    player_customs[player] = true
    zRPclient._setDiv(player,"customization",".div_customization{ margin: auto; padding: 8px; width: 500px; margin-top: 80px; background: black; color: white; font-weight: bold; ", content)
  end
end

local function ch_noclip(player, choice)
  zRPclient._toggleNoclip(player)
end

local function ch_audiosource(player, choice)
  local infos = splitString(zRP.prompt(player, "Audio source: name=url, omit url to delete the named source.", ""), "=")
  local name = infos[1]
  local url = infos[2]

  if name and string.len(name) > 0 then
    if url and string.len(url) > 0 then
      local x,y,z = zRPclient.getPosition(player)
      zRPclient._setAudioSource(-1,"zRP:admin:"..name,url,0.5,x,y,z,125)
    else
      zRPclient._removeAudioSource(-1,"zRP:admin:"..name)
    end
  end
end

----------------------------------------------------------------------------------------

local function ch_tptowaypoint(player, choice)
  zRPclient._tpToWaypoint(player)
end

local function ch_blips(player, choice)
  zRPclient._showBlips(player)
end

local function ch_deleteveh(player, choice)
  zRPclient._deleteVehicleInFrontOrInside(player,5.0)
end

local function ch_crun(player,choice)
  local stringToRun = zRP.prompt(player, "Run a client string","") --lang.basic_menu.crun.prompt()
  stringToRun = stringToRun or ""
  zRPclient._runStringLocally(player, stringToRun)
end

local function ch_srun(player, choice)
  local stringToRun = zRP.prompt(player, "Run server string","")
  zRP.runStringRemotelly(stringToRun)
end

local player_gods = {}

local function ch_godmode(player, choice)
  local user_id = zRP.getUserId(player)
  if user_id ~= nil then
    if player_gods[player] then
      player_gods[player] = nil
      zRPclient._notify(player, "God Mode is off") --lang.godmode.off()
    else
      player_gods[player] = user_id
      zRPclient._notify(player, "God Mode is ON") -- lang.godmode.on()
    end
  end
end

local function ch_spawnveh(player, choice)
  local model = zRP.prompt(player, "Spawn veichle ","") -- lang.spawnveh.promt()
  if model ~= nil and model ~= "" then
    zRPclient._spawnVehicle(player,model)
  else
    zRPclient._notify(player, "Invalid value") --lang.common.invalid_value()
  end
end

local function ch_sprites(player, choice)
  zRPclient._showSprites(player)
end
----------------------------------------------------------------------------------------

zRP.registerMenuBuilder("main", function(add, data)
  local user_id = zRP.getUserId(data.player)
  if user_id then
    local choices = {}

    -- build admin menu
    choices["Admin"] = {function(player,choice)
      local menu  = zRP.buildMenu("admin", {player = player})
      menu.name = "Admin"
      menu.css={top="75px",header_color="rgba(200,0,0,0.75)"}
      menu.onclose = function(player) zRP.openMainMenu(player) end -- nest menu

      if zRP.hasPermission(user_id,"player.list") then
        menu["@User list"] = {ch_list,"Show/hide user list."}
      end
      if zRP.hasPermission(user_id,"player.whitelist") then
        menu["@Whitelist user"] = {ch_whitelist}
      end
      if zRP.hasPermission(user_id,"player.group.add") then
        menu["@Add group"] = {ch_addgroup}
      end
      if zRP.hasPermission(user_id,"player.group.remove") then
        menu["@Remove group"] = {ch_removegroup}
      end
      if zRP.hasPermission(user_id,"player.unwhitelist") then
        menu["@Un-whitelist user"] = {ch_unwhitelist}
      end
      if zRP.hasPermission(user_id,"player.kick") then
        menu["@Kick"] = {ch_kick}
      end
      if zRP.hasPermission(user_id,"player.ban") then
        menu["@Ban"] = {ch_ban}
      end
      if zRP.hasPermission(user_id,"player.unban") then
        menu["@Unban"] = {ch_unban}
      end
      if zRP.hasPermission(user_id,"player.noclip") then
        menu["@Noclip"] = {ch_noclip}
      end
      if zRP.hasPermission(user_id,"player.custom_emote") then
        menu["@Custom emote"] = {ch_emote}
      end
      if zRP.hasPermission(user_id,"player.custom_sound") then
        menu["@Custom sound"] = {ch_sound}
      end
      if zRP.hasPermission(user_id,"player.custom_sound") then
        menu["@Custom audiosource"] = {ch_audiosource}
      end
      if zRP.hasPermission(user_id,"player.coords") then
        menu["@Coords"] = {ch_coords}
      end
      if zRP.hasPermission(user_id,"player.tptome") then
        menu["@TpToMe"] = {ch_tptome}
      end
      if zRP.hasPermission(user_id,"player.tpto") then
        menu["@TpTo"] = {ch_tpto}
      end
      if zRP.hasPermission(user_id,"player.tpto") then
        menu["@TpToCoords"] = {ch_tptocoords}
      end
      if zRP.hasPermission(user_id,"player.givemoney") then
        menu["@Give money"] = {ch_givemoney}
      end
      if zRP.hasPermission(user_id,"player.giveitem") then
        menu["@Give item"] = {ch_giveitem}
      end
      if zRP.hasPermission(user_id,"player.display_custom") then
        menu["@Display customization"] = {ch_display_custom}
      end
      if zRP.hasPermission(user_id,"player.calladmin") then
        menu["@Call admin"] = {ch_calladmin}
      end
      if zRP.hasPermission(user_id,"player.kick") then -- lang.deleteveh.perm()
        menu["@Delete Vehicle"] = {ch_deleteveh, "Delete vehicle"} -- lang.deleteveh.button() -- lang.deleteveh.desc()
      end
      if zRP.hasPermission(user_id,"player.kick") then -- lang.spawnveh.perm()
        menu["@Spawn Vehicle"] = {ch_spawnveh, "Spawn Vehicle"} -- lang.spawnveh.button() -- lang.spawnveh.desc()
      end
      if zRP.hasPermission(user_id,"player.kick") then -- lang.godmode.perm()
        menu["@God mode"] = {ch_godmode, "God mode"} -- lang.godmode.button() -- lang.godmode.desc()
      end
      if zRP.hasPermission(user_id,"player.kick") then -- lang.blips.perm()
        menu["@Blips"] = {ch_blips, "Blips"} -- lang.blips.button() -- lang.blips.desc()
      end
      if zRP.hasPermission(user_id,"player.kick") then -- lang.sprites.perm()
        menu["@Sprites"] = {ch_sprites, "Sprites"} -- lang.sprites.button() -- lang.sprites.desc()
      end
      if zRP.hasPermission(user_id,"player.kick") then -- lang.crun.perm()
        menu["@Crun"] = {ch_crun, "Run client string"} -- lang.crun.button() -- lang.crun.desc()
      end
      if zRP.hasPermission(user_id,"player.kick") then -- lang.srun.perm()
        menu["@Srun"] = {ch_srun, "Run Server string"} -- lang.srun.button() -- lang.srun.desc()
      end
      if zRP.hasPermission(user_id,"player.kick") then -- lang.tptowaypoint.perm()
        menu["@Tp to WayPoint"] = {ch_tptowaypoint, "Tp to waypoint"} -- lang.tptowaypoint.button() -- lang.tptowaypoint.desc()
      end

      zRP.openMenu(player,menu)
    end}

    add(choices)
  end
end)

-- admin god mode
function task_god()
  SetTimeout(10000, task_god)

  for k,v in pairs(zRP.getUsersByPermission("admin.god")) do
    zRP.setHunger(v, 0)
    zRP.setThirst(v, 0)

    local player = zRP.getUserSource(v)
    if player ~= nil then
      zRPclient._setHealth(player, 200)
    end
  end
end

function task_god_adv()
  SetTimeout(10000, task_god_adv)

  for k,v in pairs(player_gods) do
    zRP.setHunger(v, 0)
    zRP.setThirst(v, 0)

    local player = zRP.getUserSource(v)
    if player ~= nil then
      zRPclient._setHealth(player, 200)
    end
  end
end

task_god_adv()
task_god()
