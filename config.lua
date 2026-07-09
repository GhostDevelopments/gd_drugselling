local ESX = exports["es_extended"]:getSharedObject()
local PlayerData = {}
local npc = {}
local isCooldown = false
local blips = {}

-- Cache frequently used functions
local PlayerPedId = PlayerPedId
local GetEntityCoords = GetEntityCoords
local Wait = Wait
local CreateThread = CreateThread
local SetEntityAsMissionEntity = SetEntityAsMissionEntity
local DeleteEntity = DeleteEntity

RegisterNetEvent("esx:playerLoaded")
AddEventHandler("esx:playerLoaded", function(xPlayer)
    PlayerData = xPlayer
end)

RegisterNetEvent("esx:setJob")
AddEventHandler("esx:setJob", function(job)
    PlayerData.job = job
end)

CreateThread(function()
    while not ESX.IsPlayerLoaded() do Wait(100) end
    PlayerData = ESX.GetPlayerData()
    ESX.Streaming.RequestStreamedTextureDict("DIA_CLIFFORD")
end)

local function playAnim(dict, anim, speed, time, flag)
    ESX.Streaming.RequestAnimDict(dict, function()
        TaskPlayAnim(PlayerPedId(), dict, anim, speed, speed, time, flag, 1, false, false, false)
    end)
end

local function playAnimOnPed(ped, dict, anim, speed, time, flag)
    ESX.Streaming.RequestAnimDict(dict, function()
        TaskPlayAnim(ped, dict, anim, speed, speed, time, flag, 1, false, false, false)
    end)
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
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        npc.coords = GetEntityCoords(npc.ped)
        local distanceSq = #(playerCoords - npc.coords)

        if distanceSq < 10.0 then
            sleep = 0
            ESX.Game.Utils.DrawText3D(npc.coords, (Config.notify.client):format(drugToSell.count, drugToSell.label), 0.5)
            
            if distanceSq < 2.0 then
                ESX.ShowHelpNotification(Config.notify.press)
                if IsControlJustPressed(0, 38) and canSell then
                    canSell = false
                    
                    if IsPedInAnyVehicle(playerPed, false) then
                        ESX.ShowAdvancedNotification(Config.notify.title, Config.notify.vehicle, "", "DIA_CLIFFORD", 1)
                        canSell = true
                    else
                        local reject = math.random(1, 10)
                        if reject <= 3 then
                            ESX.ShowAdvancedNotification(Config.notify.title, "", Config.notify.reject, "DIA_CLIFFORD", 1)
                            PlayAmbientSpeech1(npc.ped, "GENERIC_HI", "SPEECH_PARAMS_STANDARD")
                            drugToSell.coords = playerCoords
                            TriggerServerEvent("gd_drugselling:notifycops", drugToSell)
                            SetPedAsNoLongerNeeded(npc.ped)
                            if Config.npcFightOnReject then
                                TaskCombatPed(npc.ped, playerPed, 0, 16)
                            end
                            npc = {}
                            return
                        end

                        makeEntityFaceEntity(playerPed, npc.ped)
                        makeEntityFaceEntity(npc.ped, playerPed)
                        SetPedTalk(npc.ped)
                        PlayAmbientSpeech1(npc.ped, "GENERIC_HI", "SPEECH_PARAMS_STANDARD")
                        
                        local drugProp = CreateObject(GetHashKey("prop_weed_bottle"), 0, 0, 0, true, true, true)
                        AttachEntityToEntity(drugProp, playerPed, GetPedBoneIndex(playerPed, 57005), 0.13, 0.02, 0.0, -90.0, 0, 0, 1, 1, 0, 1, 0, 1)
                        
                        local cashProp = CreateObject(GetHashKey("hei_prop_heist_cash_pile"), 0, 0, 0, true, true, true)
                        AttachEntityToEntity(cashProp, npc.ped, GetPedBoneIndex(npc.ped, 57005), 0.13, 0.02, 0.0, -90.0, 0, 0, 1, 1, 0, 1, 0, 1)
                        
                        playAnim("mp_common", "givetake1_a", 8.0, -1, 0)
                        playAnimOnPed(npc.ped, "mp_common", "givetake1_a", 8.0, -1, 0)
                        
                        Wait(1000)
                        AttachEntityToEntity(cashProp, playerPed, GetPedBoneIndex(playerPed, 57005), 0.13, 0.02, 0.0, -90.0, 0, 0, 1, 1, 0, 1, 0, 1)
                        AttachEntityToEntity(drugProp, npc.ped, GetPedBoneIndex(npc.ped, 57005), 0.13, 0.02, 0.0, -90.0, 0, 0, 1, 1, 0, 1, 0, 1)
                        
                        Wait(1000)
                        DeleteEntity(drugProp)
                        DeleteEntity(cashProp)
                        
                        PlayAmbientSpeech1(npc.ped, "GENERIC_THANKS", "SPEECH_PARAMS_STANDARD")
                        SetPedAsNoLongerNeeded(npc.ped)
                        TriggerServerEvent("gd_drugselling:pay", drugToSell)
                        ESX.ShowAdvancedNotification(Config.notify.title, "", (Config.notify.sold):format(drugToSell.count, drugToSell.label, drugToSell.price), "DIA_CLIFFORD", 1)
                        npc = {}
                        return
                    end
                end
            end
        end
        Wait(sleep)
    end
end

local function next_ped(drugToSell)
    if isCooldown then
        ESX.ShowAdvancedNotification(Config.notify.title, "", Config.notify.cooldown, "DIA_CLIFFORD", 1)
        return
    end

    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    if Config.cityPoint and #(playerCoords - Config.cityPoint) > 1500.0 then
        ESX.ShowAdvancedNotification(Config.notify.title, "", Config.notify.toofar, "DIA_CLIFFORD", 1)
        return
    end

    if npc.ped and DoesEntityExist(npc.ped) then
        SetPedAsNoLongerNeeded(npc.ped)
    end

    ESX.TriggerServerCallback("gd_drugselling:getPoliceCount", function(cops)
        if cops < Config.requiredCops then
            ESX.ShowAdvancedNotification(Config.notify.title, "", Config.notify.cops, "DIA_CLIFFORD", 1)
            return
        end

        isCooldown = true
        SetTimeout(20000, function() isCooldown = false end)

        local multipliers = { [3] = 1.10, [4] = 1.15, [5] = 1.20, [6] = 1.25 }
        local mult = multipliers[cops] or (cops >= 7 and 1.30 or 1.0)
        drugToSell.price = math.floor(drugToSell.price * mult + 0.5)

        TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_STAND_MOBILE", 0, true)
        ESX.ShowAdvancedNotification(Config.notify.title, "", Config.notify.searching .. drugToSell.label, "DIA_CLIFFORD", 1)
        
        Wait(math.random(5000, 10000))
        ClearPedTasks(playerPed)

        local model = GetHashKey(Config.pedlist[math.random(1, #Config.pedlist)])
        ESX.Streaming.RequestModel(model)

        local spawnCoords = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 50.0, 0.0)
        local _, groundZ = GetGroundZFor_3dCoord(spawnCoords.x, spawnCoords.y, spawnCoords.z + 10.0, 0)
        
        npc.ped = CreatePed(5, model, spawnCoords.x, spawnCoords.y, groundZ, 0.0, true, true)
        SetEntityAsMissionEntity(npc.ped, true, true)
        PlaceObjectOnGroundProperly(npc.ped)

        if not DoesEntityExist(npc.ped) or IsEntityDead(npc.ped) then
            isCooldown = false
            ESX.ShowAdvancedNotification(Config.notify.title, "", Config.notify.notfound, "DIA_CLIFFORD", 1)
            return
        end

        local zoneName = GetLabelText(GetNameOfZone(spawnCoords))
        ESX.ShowAdvancedNotification(Config.notify.title, Config.notify.approach, Config.notify.found .. zoneName, "DIA_CLIFFORD", 1)
        
        TaskGoToEntity(npc.ped, playerPed, 60000, 4.0, 2.0, 0, 0)
        handlePedSelling(drugToSell)
    end)
end

RegisterNetEvent("gd_drugselling:findClient", next_ped)

RegisterNetEvent("gd_drugselling:notifyPolice", function(coords)
    if PlayerData.job and PlayerData.job.name == "police" then
        local streetHash = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
        local streetName = GetStreetNameFromHashKey(streetHash)
        
        ESX.ShowAdvancedNotification(Config.notify.police_notify_title, Config.notify.police_notify_subtitle, streetName, "CHAR_CALL911", 1)
        PlaySoundFrontend(-1, "Bomb_Disarmed", "GTAO_Speed_Convoy_Soundset", 0)

        local blip = AddBlipForCoord(coords)
        SetBlipSprite(blip, 403)
        SetBlipColour(blip, 1)
        SetBlipAlpha(blip, 250)
        SetBlipScale(blip, 1.2)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("# Sprzedaz narkotykow")
        EndTextCommandSetBlipName(blip)
        
        SetTimeout(50000, function()
            if DoesBlipExist(blip) then
                RemoveBlip(blip)
            end
        end)
    end
end)
