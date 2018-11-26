local Proxy = module("lib/Proxy")
local Tunnel = module("lib/Tunnel")
Debug = module("lib/Debug")

zRPBase = {}
zRPBase.config = module("cfg/base")
local config = zRPBase.config

zRP = {}
Proxy.addInterface("zRP",zRP)

tzRP = {}
Tunnel.bindInterface("zRP",tzRP) -- listening for client tunnel


--LANG System
if pcall(function()
  local lang_system = module("zRP_base_extensions/Lang")
end) then
  print("[zRP] Lang System Module are loader")
else
  print("[zRP] Lang System are not found")
end

-- init
zRPclient = Tunnel.getInterface("zRP") -- server -> client tunnel

local user = module("zRP_base_extensions/User/Manager") --TODO PCALL

local character = module("zRP_base_extensions/Character/Character")

local db_manager = module("zRP_base_extensions/DB/Manager") --TODO PCALL


-- identification system

local player = module("zRP_base_extensions/Player/Manager") -- TODO PCALL

local server = module("zRP_base_extensions/Server/Manager") --TODO PCALL

-- handlers

AddEventHandler("playerConnecting",function(name,setMessage, deferrals)
  deferrals.defer()

  local source = source
  Debug.log("playerConnecting "..name)
  local ids = GetPlayerIdentifiers(source)

  if ids ~= nil and #ids > 0 then
    deferrals.update("[zRP] Checking identifiers...")
    local user_id = zRP.getUserIdByIdentifiers(ids)
    -- if user_id ~= nil and zRP.rusers[user_id] == nil then -- check user validity and if not already connected (old way, disabled until playerDropped is sure to be called)
    if user_id then -- check user validity
      deferrals.update("[zRP] Checking banned...")
      if not zRP.isBanned(user_id) then
        deferrals.update("[zRP] Checking whitelisted...")
        if not config.whitelist or zRP.isWhitelisted(user_id) then
          print("ROBERT")
          if zRP.rusers[user_id] == nil then -- not present on the server, init
            -- load user data table
            deferrals.update("[zRP] Loading datatable...")
            local sdata = zRP.getUData(user_id, "zRP:datatable")
            local cdatalist = zRP.getUData(user_id, "zRP:character_list")

            -- init entries
            zRP.users[ids[1]] = user_id
            zRP.rusers[user_id] = ids[1]
            zRP.user_tables[user_id] = {}
            zRP.user_tmp_tables[user_id] = {}
            zRP.user_sources[user_id] = source
            zRP.users_characters_list[user_id] = {}
            zRP.users_loader[user_id] = {user_data = true}

            local data = json.decode(sdata)
            if type(data) == "table" then zRP.user_tables[user_id] = data end

            local clist = json.decode(cdatalist)
            if type(clist) == "table" then
              zRP.users_characters_list[user_id] = clist end

            -- init user tmp table
            local tmpdata = zRP.getUserTmpTable(user_id)

            deferrals.update("[zRP] Getting last login...")
            local last_login = zRP.getLastLogin(user_id)
            tmpdata.last_login = last_login or ""
            tmpdata.spawns = 0

            -- set last login
            local ep = zRP.getPlayerEndpoint(source)
            local last_login_stamp = os.date("%H:%M:%S %d/%m/%Y")
            zRP.execute("zRP/set_last_login", {user_id = user_id, last_login = last_login_stamp})

            --Character Loading

            TriggerEvent("vRP:playerJoin", user_id, source, name, tmpdata.last_login)
           --TriggerEvent("zRP:characterLoad", user_id, source, name, tmpdata,ids, character_id, deferrals)
            deferrals.done()
          else -- already connected
            print("[vRP] "..name.." ("..vRP.getPlayerEndpoint(source)..") re-joined (user_id = "..user_id..")")
            -- reset first spawn
            local tmpdata = vRP.getUserTmpTable(user_id)
            tmpdata.spawns = 0

            TriggerEvent("vRP:playerRejoin", user_id, source, name)
            deferrals.done()
          end

        else
          print("[zRP] "..name.." ("..zRP.getPlayerEndpoint(source)..") rejected: not whitelisted (user_id = "..user_id..")")
          Citizen.Wait(1000)
          deferrals.done("[zRP] Not whitelisted (user_id = "..user_id..").")
        end
      else
        print("[zRP] "..name.." ("..zRP.getPlayerEndpoint(source)..") rejected: banned (user_id = "..user_id..")")
        Citizen.Wait(1000)
        deferrals.done("[zRP] Banned (user_id = "..user_id..").")
      end
    else
      print("[zRP] "..name.." ("..zRP.getPlayerEndpoint(source)..") rejected: identification error")
      Citizen.Wait(1000)
      deferrals.done("[zRP] Identification error.")
    end
  else
    print("[zRP] "..name.." ("..zRP.getPlayerEndpoint(source)..") rejected: missing identifiers")
    Citizen.Wait(1000)
    deferrals.done("[zRP] Missing identifiers.")
  end
end)
