using System;
using CitizenFX.Core;

namespace ZentryCSharp_Utils.Server.Events {
    public class GuidGenerator {
        public void UUID_Generator() {
            BaseScript.TriggerEvent("zRP:UUID_GENERATE", Guid.NewGuid().ToString());
        }
    }
}