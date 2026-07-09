lib.callback.register('gd_drugselling:server:getPoliceCount', function(source)
    local cops = 0
    local players = exports.qbx_core:GetQBPlayers()
    for _, v in pairs(players) do
        if v.PlayerData.job.name == 'police' and v.PlayerData.job.onduty then
            cops = cops + 1
        end
    end
    return cops
end)

RegisterNetEvent('gd_drugselling:server:pay', function(drugData)
    local src = source
    local player = exports.qbx_core:GetPlayer(src)
    if not player then return end

    local count = exports.ox_inventory:GetItemCount(src, drugData.name)
    if count < drugData.count then
        exports.qbx_core:Notify(src, 'You don\'t have enough drugs', 'error')
        return
    end

    exports.ox_inventory:RemoveItem(src, drugData.name, drugData.count)
    
    local moneyType = Config.account == 'black_money' and 'crypto' or 'cash'
    player.Functions.AddMoney(moneyType, drugData.price, "drug-sale")
end)

RegisterNetEvent('gd_drugselling:server:notifyPolice', function(drugData)
    local players = exports.qbx_core:GetQBPlayers()
    for _, v in pairs(players) do
        if v.PlayerData.job.name == 'police' and v.PlayerData.job.onduty then
            TriggerClientEvent('gd_drugselling:client:notifyPolice', v.PlayerData.source, drugData.coords)
        end
    end
end)
