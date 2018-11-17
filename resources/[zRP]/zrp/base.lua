local Proxy = module("lib/Proxy")
local Tunnel = module("lib/Tunnel")
local Luang = module("lib/Luang")
Debug = module("lib/Debug")

local config = module("cfg/base")

zRP = {}
Proxy.addInterface("zRP",zRP)

tzRP = {}
Tunnel.bindInterface("zRP",tzRP) -- listening for client tunnel

-- load language 
local Lang = Luang()
Lang:loadLocale(config.lang, module("cfg/lang/"..config.lang) or {})
zRP.lang = Lang.lang[config.lang]

-- init
zRPclient = Tunnel.getInterface("zRP") -- server -> client tunnel

zRP.users = {} -- will store logged users (id) by first identifier
zRP.rusers = {} -- store the opposite of users
zRP.user_tables = {} -- user data tables (logger storage, saved to database)
zRP.user_tmp_tables = {} -- user tmp data tables (logger storage, not saved)
zRP.user_sources = {} -- user sources

-- db/SQL API
local db_drivers = {}
local db_driver
local cached_prepares = {}
local cached_queries = {}
local prepared_queries = {}
local db_initialized = false

-- register a DB driver
--- name: unique name for the driver
--- on_init(cfg): called when the driver is initialized (connection), should return true on success
---- cfg: db config
--- on_prepare(name, query): should prepare the query (@param notation)
--- on_query(name, params, mode): should execute the prepared query
---- params: map of parameters
---- mode: 
----- "query": should return rows, affected
----- "execute": should return affected
----- "scalar": should return a scalar
function zRP.registerDBDriver(name, on_init, on_prepare, on_query)
  if not db_drivers[name] then
    db_drivers[name] = {on_init, on_prepare, on_query}

    if name == config.db.driver then -- use/init driver
      db_driver = db_drivers[name] -- set driver

      local ok = on_init(config.db)
      if ok then
        print("[zRP] Connected to DB using driver \""..name.."\".")
        db_initialized = true
        -- execute cached prepares
        for _,prepare in pairs(cached_prepares) do
          on_prepare(table.unpack(prepare, 1, table.maxn(prepare)))
        end

        -- execute cached queries
        for _,query in pairs(cached_queries) do
          async(function()
            query[2](on_query(table.unpack(query[1], 1, table.maxn(query[1]))))
          end)
        end

        cached_prepares = nil
        cached_queries = nil
      else
        error("[zRP] Connection to DB failed using driver \""..name.."\".")
      end
    end
  else
    error("[zRP] DB driver \""..name.."\" already registered.")
  end
end

-- prepare a query
--- name: unique name for the query
--- query: SQL string with @params notation
function zRP.prepare(name, query)
  if Debug.active then
    Debug.log("prepare "..name.." = \""..query.."\"")
  end

  prepared_queries[name] = true

  if db_initialized then -- direct call
    db_driver[2](name, query)
  else
    table.insert(cached_prepares, {name, query})
  end
end

-- execute a query
--- name: unique name of the query
--- params: map of parameters
--- mode: default is "query"
---- "query": should return rows (list of map of parameter => value), affected
---- "execute": should return affected
---- "scalar": should return a scalar
function zRP.query(name, params, mode)
  if not prepared_queries[name] then
    error("[zRP] query "..name.." doesn't exist.")
  end

  if not mode then mode = "query" end

  if Debug.active then
    Debug.log("query "..name.." ("..mode..") params = "..json.encode(params or {}))
  end

  if db_initialized then -- direct call
    return db_driver[3](name, params or {}, mode)
  else -- async call, wait query result
    local r = async()
    table.insert(cached_queries, {{name, params or {}, mode}, r})
    return r:wait()
  end
end

-- shortcut for zRP.query with "execute"
function zRP.execute(name, params)
  return zRP.query(name, params, "execute")
end

-- shortcut for zRP.query with "scalar"
function zRP.scalar(name, params)
  return zRP.query(name, params, "scalar")
end

-- DB driver error/warning

if not config.db or not config.db.driver then
  error("[zRP] Missing DB config driver.")
end

Citizen.CreateThread(function()
  while not db_initialized do
    print("[zRP] DB driver \""..config.db.driver.."\" not initialized yet ("..#cached_prepares.." prepares cached, "..#cached_queries.." queries cached).")
    Citizen.Wait(5000)
  end
end)

-- queries
zRP.prepare("zRP/base_tables",[[
CREATE TABLE IF NOT EXISTS zrp_users(
  id INTEGER AUTO_INCREMENT,
  last_login VARCHAR(255),
  whitelisted BOOLEAN,
  banned BOOLEAN,
  CONSTRAINT pk_user PRIMARY KEY(id)
);

CREATE TABLE IF NOT EXISTS zrp_user_ids(
  identifier VARCHAR(100),
  user_id INTEGER,
  CONSTRAINT pk_user_ids PRIMARY KEY(identifier),
  CONSTRAINT fk_user_ids_users FOREIGN KEY(user_id) REFERENCES zrp_users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS zrp_user_data(
  user_id INTEGER,
  dkey VARCHAR(100),
  dvalue TEXT,
  CONSTRAINT pk_user_data PRIMARY KEY(user_id,dkey),
  CONSTRAINT fk_user_data_users FOREIGN KEY(user_id) REFERENCES zrp_users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS zrp_srv_data(
  dkey VARCHAR(100),
  dvalue TEXT,
  CONSTRAINT pk_srv_data PRIMARY KEY(dkey)
);
]])

zRP.prepare("zRP/create_user","INSERT INTO zrp_users(whitelisted,banned) VALUES(false,false); SELECT LAST_INSERT_ID() AS id")
zRP.prepare("zRP/add_identifier","INSERT INTO zrp_user_ids(identifier,user_id) VALUES(@identifier,@user_id)")
zRP.prepare("zRP/userid_byidentifier","SELECT user_id FROM zrp_user_ids WHERE identifier = @identifier")

zRP.prepare("zRP/set_userdata","REPLACE INTO zrp_user_data(user_id,dkey,dvalue) VALUES(@user_id,@key,@value)")
zRP.prepare("zRP/get_userdata","SELECT dvalue FROM zrp_user_data WHERE user_id = @user_id AND dkey = @key")

zRP.prepare("zRP/set_srvdata","REPLACE INTO zrp_srv_data(dkey,dvalue) VALUES(@key,@value)")
zRP.prepare("zRP/get_srvdata","SELECT dvalue FROM zrp_srv_data WHERE dkey = @key")

zRP.prepare("zRP/get_banned","SELECT banned FROM zrp_users WHERE id = @user_id")
zRP.prepare("zRP/set_banned","UPDATE zrp_users SET banned = @banned WHERE id = @user_id")
zRP.prepare("zRP/get_whitelisted","SELECT whitelisted FROM zrp_users WHERE id = @user_id")
zRP.prepare("zRP/set_whitelisted","UPDATE zrp_users SET whitelisted = @whitelisted WHERE id = @user_id")
zRP.prepare("zRP/set_last_login","UPDATE zrp_users SET last_login = @last_login WHERE id = @user_id")
zRP.prepare("zRP/get_last_login","SELECT last_login FROM zrp_users WHERE id = @user_id")

-- init tables
print("[zRP] init base tables")
async(function()
  zRP.execute("zRP/base_tables")
end)

-- identification system

--- sql.
-- return user id or nil in case of error (if not found, will create it)
function zRP.getUserIdByIdentifiers(ids)
  if ids and #ids then
    -- search identifiers
    for i=1,#ids do
      if not config.ignore_ip_identifier or (string.find(ids[i], "ip:") == nil) then  -- ignore ip identifier
        local rows = zRP.query("zRP/userid_byidentifier", {identifier = ids[i]})
        if #rows > 0 then  -- found
          return rows[1].user_id
        end
      end
    end

    -- no ids found, create user
    local rows, affected = zRP.query("zRP/create_user", {})

    if #rows > 0 then
      local user_id = rows[1].id
      -- add identifiers
      for l,w in pairs(ids) do
        if not config.ignore_ip_identifier or (string.find(w, "ip:") == nil) then  -- ignore ip identifier
          zRP.execute("zRP/add_identifier", {user_id = user_id, identifier = w})
        end
      end

      return user_id
    end
  end
end

-- return identification string for the source (used for non zRP identifications, for rejected players)
function zRP.getSourceIdKey(source)
  local ids = GetPlayerIdentifiers(source)
  local idk = "idk_"
  for k,v in pairs(ids) do
    idk = idk..v
  end

  return idk
end

function zRP.getPlayerEndpoint(player)
  return GetPlayerEP(player) or "0.0.0.0"
end

function zRP.getPlayerName(player)
  return GetPlayerName(player) or "unknown"
end

--- sql
function zRP.isBanned(user_id, cbr)
  local rows = zRP.query("zRP/get_banned", {user_id = user_id})
  if #rows > 0 then
    return rows[1].banned
  else
    return false
  end
end

--- sql
function zRP.setBanned(user_id,banned)
  zRP.execute("zRP/set_banned", {user_id = user_id, banned = banned})
end

--- sql
function zRP.isWhitelisted(user_id, cbr)
  local rows = zRP.query("zRP/get_whitelisted", {user_id = user_id})
  if #rows > 0 then
    return rows[1].whitelisted
  else
    return false
  end
end

--- sql
function zRP.setWhitelisted(user_id,whitelisted)
  zRP.execute("zRP/set_whitelisted", {user_id = user_id, whitelisted = whitelisted})
end

--- sql
function zRP.getLastLogin(user_id, cbr)
  local rows = zRP.query("zRP/get_last_login", {user_id = user_id})
  if #rows > 0 then
    return rows[1].last_login
  else
    return ""
  end
end

function zRP.setUData(user_id,key,value)
  zRP.execute("zRP/set_userdata", {user_id = user_id, key = key, value = value})
end

function zRP.getUData(user_id,key,cbr)
  local rows = zRP.query("zRP/get_userdata", {user_id = user_id, key = key})
  if #rows > 0 then
    return rows[1].dvalue
  else
    return ""
  end
end

function zRP.setSData(key,value)
  zRP.execute("zRP/set_srvdata", {key = key, value = value})
end

function zRP.getSData(key, cbr)
  local rows = zRP.query("zRP/get_srvdata", {key = key})
  if #rows > 0 then
    return rows[1].dvalue
  else
    return ""
  end
end

-- return user data table for zRP internal persistant connected user storage
function zRP.getUserDataTable(user_id)
  return zRP.user_tables[user_id]
end

function zRP.getUserTmpTable(user_id)
  return zRP.user_tmp_tables[user_id]
end

-- return the player spawn count (0 = not spawned, 1 = first spawn, ...)
function zRP.getSpawns(user_id)
  local tmp = zRP.getUserTmpTable(user_id)
  if tmp then
    return tmp.spawns or 0
  end

  return 0
end

function zRP.getUserId(source)
  if source ~= nil then
    local ids = GetPlayerIdentifiers(source)
    if ids ~= nil and #ids > 0 then
      return zRP.users[ids[1]]
    end
  end

  return nil
end

-- return map of user_id -> player source
function zRP.getUsers()
  local users = {}
  for k,v in pairs(zRP.user_sources) do
    users[k] = v
  end

  return users
end

-- return source or nil
function zRP.getUserSource(user_id)
  return zRP.user_sources[user_id]
end

function zRP.ban(source,reason)
  local user_id = zRP.getUserId(source)

  if user_id then
    zRP.setBanned(user_id,true)
    zRP.kick(source,"[Banned] "..reason)
  end
end

function zRP.kick(source,reason)
  DropPlayer(source,reason)
end

-- drop zRP player/user (internal usage)
function zRP.dropPlayer(source)
  local user_id = zRP.getUserId(source)
  local endpoint = zRP.getPlayerEndpoint(source)

  -- remove player from connected clients
  zRPclient._removePlayer(-1, source)

  if user_id then
    TriggerEvent("zRP:playerLeave", user_id, source)

    -- save user data table
    zRP.setUData(user_id,"zRP:datatable",json.encode(zRP.getUserDataTable(user_id)))

    print("[zRP] "..endpoint.." disconnected (user_id = "..user_id..")")
    zRP.users[zRP.rusers[user_id]] = nil
    zRP.rusers[user_id] = nil
    zRP.user_tables[user_id] = nil
    zRP.user_tmp_tables[user_id] = nil
    zRP.user_sources[user_id] = nil
  end
end

-- tasks

function task_save_datatables()
  SetTimeout(config.save_interval*1000, task_save_datatables)
  TriggerEvent("zRP:save")

  Debug.log("save datatables")
  for k,v in pairs(zRP.user_tables) do
    zRP.setUData(k,"zRP:datatable",json.encode(v))
  end
end

async(function()
  task_save_datatables()
end)

-- ping timeout
function task_timeout()
  local users = zRP.getUsers()
  for k,v in pairs(users) do
    if GetPlayerPing(v) <= 0 then
      zRP.kick(v,"[zRP] Ping timeout.")
      zRP.dropPlayer(v)
    end
  end

  SetTimeout(30000, task_timeout)
end
task_timeout()

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
          if zRP.rusers[user_id] == nil then -- not present on the server, init
            -- load user data table
            deferrals.update("[zRP] Loading datatable...")
            local sdata = zRP.getUData(user_id, "zRP:datatable")

            -- init entries
            zRP.users[ids[1]] = user_id
            zRP.rusers[user_id] = ids[1]
            zRP.user_tables[user_id] = {}
            zRP.user_tmp_tables[user_id] = {}
            zRP.user_sources[user_id] = source

            local data = json.decode(sdata)
            if type(data) == "table" then zRP.user_tables[user_id] = data end

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

            -- trigger join
            print("[zRP] "..name.." ("..zRP.getPlayerEndpoint(source)..") joined (user_id = "..user_id..")")
            TriggerEvent("zRP:playerJoin", user_id, source, name, tmpdata.last_login)
            deferrals.done()
          else -- already connected
            print("[zRP] "..name.." ("..zRP.getPlayerEndpoint(source)..") re-joined (user_id = "..user_id..")")
            -- reset first spawn
            local tmpdata = zRP.getUserTmpTable(user_id)
            tmpdata.spawns = 0

            TriggerEvent("zRP:playerRejoin", user_id, source, name)
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

AddEventHandler("playerDropped",function(reason)
  local source = source
  Debug.log("playerDropped "..source)

  zRP.dropPlayer(source)
end)

RegisterServerEvent("zRPcli:playerSpawned")
AddEventHandler("zRPcli:playerSpawned", function()
  Debug.log("playerSpawned "..source)
  -- register user sources and then set first spawn to false
  local user_id = zRP.getUserId(source)
  local player = source
  if user_id then
    zRP.user_sources[user_id] = source
    local tmp = zRP.getUserTmpTable(user_id)
    tmp.spawns = tmp.spawns+1
    local first_spawn = (tmp.spawns == 1)

    if first_spawn then
      -- first spawn, reference player
      -- send players to new player
      for k,v in pairs(zRP.user_sources) do
        zRPclient._addPlayer(source,v)
      end
      -- send new player to all players
      zRPclient._addPlayer(-1,source)

      -- set client tunnel delay at first spawn
      Tunnel.setDestDelay(player, config.load_delay)

      -- show loading
      zRPclient._setProgressBar(player, "zRP:loading", "botright", "Loading...", 0,0,0, 100)

      SetTimeout(2000, function() 
        SetTimeout(config.load_duration*1000, function() -- set client delay to normal delay
          Tunnel.setDestDelay(player, config.global_delay)
          zRPclient._removeProgressBar(player,"zRP:loading")
        end)
      end)
    end

    SetTimeout(2000, function() -- trigger spawn event
      TriggerEvent("zRP:playerSpawn",user_id,player,first_spawn)
    end)
  end
end)

RegisterServerEvent("zRP:playerDied")
