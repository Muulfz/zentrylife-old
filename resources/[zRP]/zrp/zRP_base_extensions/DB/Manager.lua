---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Muulfz.
--- DateTime: 11/17/2018 1:12 PM
---
local config = zRPBase.config
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


local mysql_tables = module("zRP_base_extensions/DB/tables")

