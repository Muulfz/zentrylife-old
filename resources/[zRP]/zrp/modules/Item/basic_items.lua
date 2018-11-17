-- load config items
local cfg = module("cfg/Modules/items")

for k,v in pairs(cfg.items) do
  zRP.defInventoryItem(k,v[1],v[2],v[3],v[4])
end
