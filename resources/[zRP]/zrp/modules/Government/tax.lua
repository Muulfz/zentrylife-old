---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Muulfz.
--- DateTime: 1/15/2019 7:02 PM
---
---
local cfg = module("cfg/Modules/Government/tax/energy")
zRPGovernment.tax = {}
zRPGovernment.tax.energy = cfg.table


function zRPGovernment.updateEnergyTaxs()
    local url = "http://www.aneel.gov.br/dados/relatorios?p_p_id=dadosabertos_WAR_dadosabertosportlet&p_p_lifecycle=2&p_p_state=normal&p_p_mode=view&p_p_resource_id=gerarTarifaMediaFornecimentoJSON&p_p_cacheability=cacheLevelPage&p_p_col_id=column-2&p_p_col_count=1"
    local method = "GET"
    PerformHttpRequest(url, function(code, result, headers)
        local number, tmp, table, table_n = 0, json.decode(result), {}, 1
        for i = 1, #tmp do
            local number_2 = (tmp[i].anoReferencia * 100) + tmp[i].mesReferencia
            if number_2 > number then
                number = number_2
            else
            end
        end
        for i = 1, #tmp do
            local n_ref = (tmp[i].anoReferencia * 100) + tmp[i].mesReferencia
            if n_ref == number then
                table[table_n] = tmp[i]
                table_n = table_n + 1
            end
        end
        local rows = zRP.query("zRP/get_srvapi", { key = "zRP:energy_uses" })
        if #rows > 0 then
            local datat = json.decode(rows[1].dvalue)
            local data = datat[1]
            local n_ref = (data.anoReferencia * 100) + data.mesReferencia
            if n_ref ~= number then
                TriggerEvent("energy_tax_round", table)
            else
                zRPGovernment.generateEnergyTax(datat)
            end
        else
            TriggerEvent("energy_tax_round", table)
        end
    end, method)

end

AddEventHandler("energy_tax_round_cb", function(result)
    zRPGovernment.generateEnergyTax(result)
    zRP.query("zRP/set_srvapi", { key = "zRP:energy_uses", value = json.encode(result), last_time_update = os.time(), extra = "" })
end)

Citizen.CreateThread(function()
    zRPGovernment.updateEnergyTaxs()
end)

function zRPGovernment.generateEnergyTax(data)
    for i = 1, #data do
        zRPGovernment.tax.energy[data[i].nomRegiao][data[i].nomClasseConsumo] = data[i].vlrConsumoMWh
    end
end

function zRPGovernment.getComercialEnergyTax(region)
    local tax = zRPGovernment.tax.energy[region]
    if tax then
        return zRPGovernment.tax.energy[region]["Comercial e Servicos e Outras"]
    end
    return 0
end


function zRPGovernment.getProperComsumEnergyTax(region)
    local tax = zRPGovernment.tax.energy[region]
    if tax then
        return zRPGovernment.tax.energy[region]["Consumo Proprio"]
    end
    return 0
end

function zRPGovernment.getPublicIluminationEnergyTax(region)
    local tax = zRPGovernment.tax.energy[region]
    if tax then
        return zRPGovernment.tax.energy[region]["Iluminacao Publica"]
    end
    return 0
end

function zRPGovernment.getIndustrialEnergyTax(region)
    local tax = zRPGovernment.tax.energy[region]
    if tax then
        return zRPGovernment.tax.energy[region]["Industrial"]
    end
    return 0
end

function zRPGovernment.getPublicParlamentEnergyTax(region)
    local tax = zRPGovernment.tax.energy[region]
    if tax then
        return zRPGovernment.tax.energy[region]["Poder Publico"]
    end
    return 0
end

function zRPGovernment.getResidentialEnergyTax(region)
    local tax = zRPGovernment.tax.energy[region]
    if tax then
        return zRPGovernment.tax.energy[region]["Residencial"]
    end
    return 0
end

function zRPGovernment.getRuralEnergyTax(region)
    local tax = zRPGovernment.tax.energy[region]
    if tax then
        return zRPGovernment.tax.energy[region]["Rural"]
    end
    return 0
end

function zRPGovernment.getRuralFarmerEnergyTax(region)
    local tax = zRPGovernment.tax.energy[region]
    if tax then
        return zRPGovernment.tax.energy[region]["Rural Aquicultor"]
    end
    return 0
end

function zRPGovernment.getRuralIrrigatorEnergyTax(region)
    local tax = zRPGovernment.tax.energy[region]
    if tax then
        return zRPGovernment.tax.energy[region]["Rural Irrigante"]
    end
    return 0
end

function zRPGovernment.getPublicServicesEnergyTax(region)
    local tax = zRPGovernment.tax.energy[region]
    if tax then
        return zRPGovernment.tax.energy[region]["Servico Publico (Agua, esgoto e saneamento)"]
    end
    return 0
end

function zRPGovernment.getPublicServicesTransportsEnergyTax(region)
    local tax = zRPGovernment.tax.energy[region]
    if tax then
        return zRPGovernment.tax.energy[region]["Servico Publico (tracao eletrica)"]
    end
    return 0
end

function zRPGovernment.getEnergyGeneralTax(region)
    local tax = zRPGovernment.tax.energy[region]
    if tax then
        return zRPGovernment.tax.energy[region]["Total por Regiao"]
    end
    return 0
end