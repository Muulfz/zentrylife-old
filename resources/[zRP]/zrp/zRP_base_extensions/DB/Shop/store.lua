---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Muulfz.
--- DateTime: 12/11/2018 12:11 AM
---

zRP.prepare("zrp/store_tables",[[
CREATE TABLE IF NOT EXISTS zrp_stores(
    id VARCHAR(50) NOT NULL,
    data LONGTEXT,
    dbmanager BOOLEAN,
    CONSTRAINT Store_ID UNIQUE (id)
);]])

zRPBase.tables[8] = "zrp/store_tables"


zRP.prepare("zRP/create_store","INSERT INTO zrp_stores (id, data, dbmanager) VALUES(@id, @data, @dbmanager)")
zRP.prepare("zRP/get_store", "SELECT * FROM zrp_stores WHERE id = @id")
zRP.prepare("zRP/get_stores", "SELECT * FROM zrp_stores")
zRP.prepare("zRP/update_store", "UPDATE zrp_store SET data = @data WHERE id = @id")
zRP.prepare("zRP/get_stores_db","SELECT id, data FROM zrp_stores WHERE dbmanager = true")