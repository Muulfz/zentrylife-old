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

local db_manager = module("zRP_base_extensions/DB/Manager") --TODO PCALL


-- identification system

local player = module("zRP_base_extensions/Player/Manager") -- TODO PCALL

local server = module("zRP_base_extensions/Server/Manager") --TODO PCALL

-- handlers

