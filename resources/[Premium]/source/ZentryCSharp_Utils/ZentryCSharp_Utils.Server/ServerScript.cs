using System;
using System.Threading.Tasks;
using CitizenFX.Core;
using ZentryCSharp_Utils.Server.Events;

namespace ZentryCSharp_Utils.Server {
    public class ServerScript : BaseScript {
        public static string Motd = "Cake is a lie";

        public ServerScript() {
            //EventHandlers["zRP:UUID_GENERATOR"] += new Action(new GuidGenerator().UUID_Generator);
            EventHandlers["energy_tax_round"] += new Action<dynamic>(o => new EnergyTaxRound(o).convertUTF8());
            eaiFeio();
            Tick += OnTick;
        }

        public async Task OnTick() {
            //Debug.WriteLine("[C#] Executando");
            //TriggerEvent("zRP:runString","zRP.TesteFun()");
            //Debug.WriteLine("[C#] Finalizou");
            await Delay(10);
        }

        public void eaiFeio() {
            Debug.WriteLine("[C#]: EAI FEIO");
            TriggerEvent("zRP:runString", "zRP.EaiFeio()");
        }

        private void MyAction(string p1, int p2, int p3) {
            CitizenFX.Core.Debug.WriteLine($"String : {p1} ,{p2}, {p3}");
        }

        private void Teste12(string p1) {
            CitizenFX.Core.Debug.WriteLine($"String : {p1}");
        }
    }
}