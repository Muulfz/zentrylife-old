---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Muulfz.
--- DateTime: 11/17/2018 2:52 PM
---

zRP.Autentication = {}
zRP.Autentication.SourceClient = {}
zRP.Autentication.ServerClient = {}

zRP.AutenticationMsgPack = {}

AddEventHandler("ServerAutenticationUUID",
        function(source, ClientUUID, ServerUUID)
            print(ClientUUID)
            print(source)
            print(ServerUUID)
            zRP.Autentication.ServerClient[ClientUUID] = ServerUUID
            zRP.Autentication.SourceClient[source] = ClientUUID
            local table = { [ServerUUID] = ClientUUID }
            zRPclient._setClientTableData("Autentication", msgpack.pack(table))
            zRP.AutenticationMsgPack = { [source] = msgpack.pack(table) }

        end)

function zRP.checkAutenticationCode(source, autentication_table)
    local clientTable = msgpack.unpack(zRPclient._getClientTableData(source, "Autentication"))
    local table = msgpack.unpack(autentication_table)
    if clientTable[1] == table[1] then
        return true
    end
    return false
end


