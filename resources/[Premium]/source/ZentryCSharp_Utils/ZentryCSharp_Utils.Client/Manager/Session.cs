using System;
using CitizenFX.Core;

namespace ZentryCSharp_Utils.Client.Manager {
       public class Session {
   
           public Guid sessionUUID { get; private set; }
   
           public Session([FromSource]Player player) {
               //Debug.WriteLine("teste");
               this.sessionUUID = Guid.NewGuid();
               //BaseScript.TriggerServerEvent("csharp_autentication_uuid",player, this.sessionUUID.ToString());
           }
       }
   }