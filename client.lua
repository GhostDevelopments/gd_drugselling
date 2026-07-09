# gd_drugselling
This is a complete rewrite to stasiek_selldrugsv2 a more optimized and persistent logic to drug selling on the esx platform

# esx error?
if you've issues with ESX try adding these two functions to your es_extended/client/functions.lua
```
ESX.PlayAnim = function(dict, anim, speed, time, flag)
    ESX.Streaming.RequestAnimDict(dict, function()
        TaskPlayAnim(PlayerPedId(), dict, anim, speed, speed, time, flag, 1, false, false, false)
    end)
end

ESX.PlayAnimOnPed = function(ped, dict, anim, speed, time, flag)
    ESX.Streaming.RequestAnimDict(dict, function()
        TaskPlayAnim(ped, dict, anim, speed, speed, time, flag, 1, false, false, false)
    end)
end

ESX.Game.MakeEntityFaceEntity = function(entity1, entity2)
    local p1 = GetEntityCoords(entity1, true)
    local p2 = GetEntityCoords(entity2, true)

    local dx = p2.x - p1.x
    local dy = p2.y - p1.y

    local heading = GetHeadingFromVector_2d(dx, dy)
    SetEntityHeading( entity1, heading )
end
```
# stasiek_selldrugsv1
https://github.com/xxxstasiek/stasiek_selldrugs
