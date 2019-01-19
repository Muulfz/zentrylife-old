using System;
using CitizenFX.Core;

namespace ZentryCSharp_Utils.Server.Events {
    public class EnergyTaxRound : BaseScript{
        private dynamic EnergyList { get; set; }

        public EnergyTaxRound() { }
        public EnergyTaxRound(dynamic energyList) {
            EnergyList = energyList;
        }

        public void convertUTF8() {
             foreach (var t in EnergyList) {
                string text = t.nomClasseConsumo;

                if (t.nomClasseConsumo == "Comercial e Servi�os e Outras" || t.nomClasseConsumo == "Comercial, Servi�os e Outras" || t.nomClasseConsumo ==
                    "Comercial e  Servi�os e Outras") {
                    t.nomClasseConsumo = "Comercial e Servicos e Outras";
                }
                else if (t.nomClasseConsumo == "Servi�o P�blico") {
                    t.nomClasseConsumo = "Servico Publico";
                    
                }
                else if (t.nomClasseConsumo == "Servi�o P�blico (tra��o el�trica)") {
                    t.nomClasseConsumo = "Servico Publico (tracao eletrica)";

                }
                else if (t.nomClasseConsumo == "Servi�o P�blico (�gua, esgoto e saneamento)"|| t.nomClasseConsumo == "Servi�o P�blico (�gua e  esgoto e saneament" || t.nomClasseConsumo == "Servi�o P�blico (�gua e esgoto e saneamento)" || t.nomClasseConsumo == "Servi�o P�blico (�gua e  esgoto e saneamento)") {
                    t.nomClasseConsumo = "Servico Publico (Agua, esgoto e saneamento)";

                }
                else if (t.nomClasseConsumo == "Totais por Regi�o"|| t.nomClasseConsumo == "Total por Regi�o") {
                    t.nomClasseConsumo = "Total por Regiao";

                }
                else if (t.nomClasseConsumo == "Consumo Pr�prio"|| t.nomClasseConsumo == "Total por Regi�o") {
                    t.nomClasseConsumo = "Consumo Proprio";

                }
                else if (t.nomClasseConsumo == "Ilumina��o P�blica") {
                    t.nomClasseConsumo = "Iluminacao Publica";
                    
                }
                else if (t.nomClasseConsumo == "Poder P�blico"){
                    t.nomClasseConsumo = "Poder Publico";
                }
                else if (t.nomClasseConsumo == "Servi�o P�blico (tra��o el�trica)"){
                    t.nomClasseConsumo = "Servico Publico (tracao eletrica)";
                }
            }

             TriggerEvent("energy_tax_round_cb",EnergyList);
        }

    }
}