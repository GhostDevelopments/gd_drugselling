local npc = {}
local isCooldown = false

local function playAnim(dict, anim, speed, time, flag)
    lib.requestAnimDict(dict)
    TaskPlayAnim(cache.ped, dict, anim, speed, speed, time, flag, 1, false, false, false)
end

local function playAnimOnPed(ped, dict, anim, speed, time, flag)
    lib.requestAnimDict(dict)
    TaskPlayAnim(ped, dict, anim, speed, speed, time, flag, 1, false, false, false)
end

local function makeEntityFaceEntity(entity1, entity2)
    local p1 = GetEntityCoords(entity1, true)
    local p2 = GetEntityCoords(entity2, true)
    local dx = p2.x - p1.x
    local dy = p2.y - p1.y
    local heading = GetHeadingFromVector_2d(dx, dy)
    SetEntityHeading(entity1, heading)
end

local function handlePedSelling(drugToSell)
    local canSell = true
    while npc.ped and DoesEntityExist(npc.ped) and not IsEntityDead(npc.ped) do
        local sleep = 500
        local playerCoords = GetEntityCoords(cache.ped)
        npc.coords = GetEntityCoords(npc.ped)
        local distanceSq = #(playerCoords - npc.coords)

        if distanceSq < 10.0 then
            sleep = 0
            if distanceSq < 2.0 then
                if not lib.isTextUIOpen() then
                    lib.showTextUI(Config.notify.press)
                end
                
                if IsControlJustPressed(0, 38) and canSell then
                    canSell = false
                    lib.hideTextUI()
                    
                    if cache.vehicle then
                        lib.notify({ title = Config.notify.title, description = Config.notify.vehicle, type = 'error' })
                        canSell = true
                    else
                        local reject = math.random(1, 10)
                        if reject <= 3 then
                            lib.notify({ title = Config.notify.title, description = Config.notify.reject, type = 'error' })
                            PlayAmbientSpeech1(npc.ped, "GENERIC_HI", "SPEECH_PARAMS_STANDARD")
                            drugToSell.coords = playerCoords
                            TriggerServerEvent("gd_drugselling:server:notifyPolice", drugToSell)
                            SetPedAsNoLongerNeeded(npc.ped)
                            if Config.npcFightOnReject then
                                TaskCombatPed(npc.ped, cache.ped, 0, 16)
                            end
                            npc = {}
                            return
                        end

                        makeEntityFaceEntity(cache.ped, npc.ped)
                        makeEntityFaceEntity(npc.ped, cache.ped)
                        SetPedTalk(npc.ped)
                        PlayAmbientSpeech1(npc.ped, "GENERIC_HI", "SPEECH_PARAMS_STANDARD")
                        
                        local drugProp = CreateObject(`prop_weed_bottle`, 0, 0, 0, true, true, true)
                        AttachEntityToEntity(drugProp, cache.ped, GetPedBoneIndex(cache.ped, 57005), 0.13, 0.02, 0.0, -90.0, 0, 0, 1, 1, 0, 1, 0, 1)
                        
                        local cashProp = CreateObject(`hei_prop_heist_cash_pile`, 0, 0, 0, true, true, true)
                        AttachEntityToEntity(cashProp, npc.ped, GetPedBoneIndex(npc.ped, 57005), 0.13, 0.02, 0.0, -90.0, 0, 0, 1, 1, 0, 1, 0, 1)
                        
                        playAnim("mp_common", "givetake1_a", 8.0, -1, 0)
                        playAnimOnPed(npc.ped, "mp_common", "givetake1_a", 8.0, -1, 0)
                        
                        Wait(1000)
                        AttachEntityToEntity(cashProp, cache.ped, GetPedBoneIndex(cache.ped, 57005), 0.13, 0.02, 0.0, -90.0, 0, 0, 1, 1, 0, 1, 0, 1)
                        AttachEntityToEntity(drugProp, npc.ped, GetPedBoneIndex(npc.ped, 57005), 0.13, 0.02, 0.0, -90.0, 0, 0, 1, 1, 0, 1, 0, 1)
                        
                        Wait(1000)
                        DeleteEntity(drugProp)
                        DeleteEntity(cashProp)
                        
                        PlayAmbientSpeech1(npc.ped, "GENERIC_THANKS", "SPEECH_PARAMS_STANDARD")
                        SetPedAsNoLongerNeeded(npc.ped)
                        TriggerServerEvent("gd_drugselling:server:pay", drugToSell)
                        lib.notify({ 
                            title = Config.notify.title, 
                            description = (Config.notify.sold):format(drugToSell.count, drugToSell.label, drugToSell.price), 
                            type = 'success' 
                        })
                        npc = {}
                        return
                    end
                end
            else
                lib.hideTextUI()
            end
        end
        Wait(sleep)
    end
end

local function next_ped(drugToSell)
    if isCooldown then
        lib.notify({ title = Config.notify.title, description = Config.notify.cooldown, type = 'error' })
        return
    end

    local playerCoords = GetEntityCoords(cache.ped)

    if Config.cityPoint and #(playerCoords - Config.cityPoint) > 1500.0 then
        lib.notify({ title = Config.notify.title, description = Config.notify.toofar, type = 'error' })
        return
    end

    if npc.ped and DoesEntityExist(npc.ped) then
        SetPedAsNoLongerNeeded(npc.ped)
    end

    local cops = lib.callback.await('gd_drugselling:server:getPoliceCount', false)
    if cops < Config.requiredCops then
        lib.notify({ title = Config.notify.title, description = Config.notify.cops, type = 'error' })
        return
    end

    isCooldown = true
    SetTimeout(20000, function() isCooldown = false end)

    local multipliers = { [3] = 1.10, [4] = 1.15, [5] = 1.20, [6] = 1.25 }
    local mult = multipliers[cops] or (cops >= 7 and 1.30 or 1.0)
    drugToSell.price = math.floor(drugToSell.price * mult + 0.5)

    TaskStartScenarioInPlace(cache.ped, "WORLD_HUMAN_STAND_MOBILE", 0, true)
    lib.notify({ title = Config.notify.title, description = Config.notify.searching .. drugToSell.label, type = 'inform' })
    
    Wait(math.random(5000, 10000))
    ClearPedTasks(cache.ped)

    local model = hash(Config.pedlist[math.random(1, #Config.pedlist)])
    lib.requestModel(model)

    local spawnCoords = GetOffsetFromEntityInWorldCoords(cache.ped, 0.0, 50.0, 0.0)
    local _, groundZ = GetGroundZFor_3dCoord(spawnCoords.x, spawnCoords.y, spawnCoords.z + 10.0, 0)
    
    npc.ped = CreatePed(5, model, spawnCoords.x, spawnCoords.y, groundZ, 0.0, true, true)
    SetEntityAsMissionEntity(npc.ped, true, true)
    PlaceObjectOnGroundProperly(npc.ped)

    if not DoesEntityExist(npc.ped) or IsEntityDead(npc.ped) then
        isCooldown = false
        lib.notify({ title = Config.notify.title, description = Config.notify.notfound, type = 'error' })
        return
    end

    local zoneName = GetLabelText(GetNameOfZone(spawnCoords))
    lib.notify({ title = Config.notify.approach, description = Config.notify.found .. zoneName, type = 'success' })
    
    TaskGoToEntity(npc.ped, cache.ped, 60000, 4.0, 2.0, 0, 0)
    handlePedSelling(drugToSell)
end

RegisterNetEvent("gd_drugselling:client:notifyPolice", function(coords)
    local streetHash = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
    local streetName = GetStreetNameFromHashKey(streetHash)
    
    exports['qbx_medical']:sendServiceNotification({
        title = Config.notify.police_notify_title,
        description = Config.notify.police_notify_subtitle .. " at " .. streetName,
        type = 'police',
        coords = coords
    })

    local blip = AddBlipForCoord(coords)
    SetBlipSprite(blip, 403)
    SetBlipColour(blip, 1)
    SetBlipAlpha(blip, 250)
    SetBlipScale(blip, 1.2)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("# Drug Sale")
    EndTextCommandSetBlipName(blip)
    
    SetTimeout(50000, function()
        if DoesBlipExist(blip) then
            RemoveBlip(blip)
        end
    end)
end)

RegisterCommand('selldrugs', function()
    if cache.vehicle then
        lib.notify({ title = Config.notify.title, description = Config.notify.vehicle, type = 'error' })
        return
    end

    local drugData = nil
    for drugName, price in pairs(Config.drugs) do
        local count = exports.ox_inventory:GetItemCount(drugName)
        if count > 0 then
            drugData = {
                name = drugName,
                label = drugName, -- Could be improved by getting item label
                price = price,
                count = math.random(1, 3)
            }
            if drugData.count > count then drugData.count = count end
            break
        end
    end

    if drugData then
        next_ped(drugData)
    else
        lib.notify({ title = Config.notify.title, description = Config.notify.nodrugs, type = 'error' })
    end
end)
