using System;
using System.Linq;
using CitizenFX.Core;

namespace ZentryCSharp_Utils.Server.Handles {
    public class SessionAutentication {
        public Guid clientUUID { get; private set; }
        public Guid serverUUID { get; private set; }


        public SessionAutentication(int playerid, String clientUUID) {
            PlayerList pl = new PlayerList();
            
            Player player = ;
            Debug.WriteLine(playerid.ToString());
            Debug.WriteLine(player.Name);
            this.clientUUID = new Guid(clientUUID);
            this.serverUUID = new Guid();
            //BaseScript.TriggerEvent("zRP_Autentication_RSP", player,clientUUID, serverUUID);
            
        }
    }
}