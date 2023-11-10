local NPCList ={}
local nearNPCIndex = nil
local blipList = {}
local lastCreatedNPCIndex = 0
local exportedNpcCreated = {}

DecorRegister(Config.NPCDecor, 2)

RemoveBlipFromNPCIndex = function(npcIndex)
    for blipIndex, blipData in ipairs(blipList) do
        if blipData.npcIndex == npcIndex then
            if DoesBlipExist(blipData.blip) then
                RemoveBlip(blipData.blip)
                table.remove(blipList, blipIndex)
                break
            end
        end
    end
end

DeleteNPC = function(npcIndex)
    local entity = NPCList[npcIndex].entity

    RemoveBlipFromNPCIndex(npcIndex)

    if DoesEntityExist(entity) then
        SetEntityAsMissionEntity(entity, false, false)
        DeleteEntity(entity)

        NPCList[npcIndex].entity = nil
        NPCList[npcIndex].notified = false
        OutCustomInteractionNotification()
    end
end

DestroyZoneId = function(npcIndex)
    if NPCList[npcIndex] and NPCList[npcIndex].zone then
        NPCList[npcIndex].zone:remove()
    end
end

DeletePreoviousNPC = function()
    for npcIndex, _ in pairs(NPCList) do
        DestroyZoneId(npcIndex)
        DeleteNPC(npcIndex)
    end

    NPCList = {}
end

CreateBlip = function(position, blipData, npcIndex)
    local blip = AddBlipForCoord(position)
    SetBlipSprite(blip, blipData.model)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, blipData.scale or 0.7)
    SetBlipColour(blip, blipData.colour)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(blipData.title)
    EndTextCommandSetBlipName(blip)

    table.insert(blipList, {
        blip = blip,
        npcIndex = npcIndex
    })
end

CreateNPC = function(npcIndex, npcData)
    local pedModel = GetHashKey(npcData.model)
    local distance = math.floor(#(GetEntityCoords(PlayerPedId()) - vector3(npcData.position.x, npcData.position.y, npcData.position.z)))
    local ped = false

    if distance <= npcData.distanceCheck then
        RequestModel(pedModel)
        while not HasModelLoaded(pedModel) do
            RequestModel(pedModel)
            Wait(10)
        end

        ped = CreatePed(4, pedModel, npcData.position.x, npcData.position.y, npcData.position.z, npcData.heading, false, false)
        nearNPCIndex = npcIndex
        npcData.pedOptions(ped)

        DecorSetBool(ped, Config.NPCDecor, true)

        if npcData.options then
            if npcData.options.freeze then
                FreezeEntityPosition(ped, npcData.options.freeze)
            end

            if npcData.options.invincible then
                SetEntityInvincible(ped, npcData.options.invincible)
            end

            if npcData.options.blockTemporaryEvents then
                SetBlockingOfNonTemporaryEvents(ped, npcData.options.blockTemporaryEvents)
            end
        end

        SetModelAsNoLongerNeeded(pedModel)
    end

    local createdZone = false

    if Config.Algorithm == 'zone' then 

        local onEnter = function(self)
            if not NPCList[self.npcIndex].entity then
                CreateNPC(self.npcIndex, self.npcData)
            end
            
            CreateThread(function() 
                while DoesEntityExist(NPCList[self.npcIndex].entity) do
                    local npcData = NPCList[self.npcIndex]
                    ThreadNPCInteraction(npcData)
                    Wait(5)
                end
            end)
        end
        
        local onExit = function(self)
            if NPCList[self.npcIndex].entity then
                DeleteNPC(self.npcIndex)
            end
        end

        if not NPCList[npcIndex] then
            createdZone = lib.zones.sphere({
                coords = npcData.position,
                radius = npcData.distanceCheck,
                debug = Config.Algorithm_Zone_Debug,
                onEnter = onEnter,
                onExit = onExit,
                npcIndex = npcIndex,
                npcData = npcData
            })
        end

    end

    NPCList[npcIndex] = {
        pedData = npcData,
        entity = ped,
        zone = createdZone,
        notified = false
    }

    return npcIndex
end

ThreadNPCInteraction = function(npcData)
    if DoesEntityExist(npcData.entity) then
        local npc = npcData.pedData
        local pedPosition = npc.position

        local distanceFromPed = math.floor(#(pedPosition - GetEntityCoords(PlayerPedId())))
        if distanceFromPed < 6 then
            local position = npc.position + vec3(0, 0, 1.9)

            ShowFloatingHelpNotification(npc.name, position)

            if distanceFromPed < 2 then
                if Config.UseCustomInteractionNotification then
                    if not npcData.notified then
                        npcData.notified = true
                        InCustomInteractionNotification(locale("INTERACT"))
                    end
                else
                    ShowHelpNotification(locale("INTERACT"), false, true, 5)
                end
                
                if IsControlJustPressed(0, Config.InteractKey) then
                    npc.onInteract(npcData.entity)
                    Wait(100)
                end
            else
                if npcData.notified then
                    npcData.notified = false
                end
            end
        end
    end
end

LoadNPCList = function()
    lastCreatedNPCIndex = 0
    for npcIndex, npcData in pairs(Config.NPC) do
        LoadNPC(npcIndex, npcData)
        lastCreatedNPCIndex = lastCreatedNPCIndex + 1
    end
end

LoadNPC = function(npcIndex, npcData)
    if type(npcData.position == 'vector3') then
        if npcData.blip then
            CreateBlip(npcData.position, npcData.blip, npcIndex)
        end

        CreateNPC(npcIndex, npcData)
    else
        for _, position in ipairs(npcData.position) do
            if npcData.blip then
                CreateBlip(position, npcData.blip, npcIndex)
            end
    
            npcData.position = position
            CreateNPC(npcIndex, npcData)
        end
    end
end

exports('AddNPC', function(npcData)
    local npcIndex = lastCreatedNPCIndex + 1
    lastCreatedNPCIndex = npcIndex
    local invokingResource = GetInvokingResource()

    if not exportedNpcCreated[invokingResource] then
        exportedNpcCreated[invokingResource] = { npcIndex }
    else
        if TableContains(exportedNpcCreated[invokingResource], npcIndex) then
            return
        end
        table.insert(exportedNpcCreated[invokingResource], npcIndex)
    end

    LoadNPC(npcIndex, npcData)
    
end)

CreateNPCThreads = function()

    -- Load NPC
    CreateThread(function() 
        LoadNPCList()
    end)

    --- Native Algorithm 
    if Config.Algorithm == "native" then
        
        CreateThread(function() 
            while true do

                for npcIndex, npcData in pairs(NPCList) do
                    local npc = npcData.pedData
                    local pedPosition = npc.position
                    local distanceFromPed = math.floor(#(pedPosition - GetEntityCoords(PlayerPedId())))
        
                    if not npcData.entity then
                        if distanceFromPed < npc.distanceCheck then
                            CreateNPC(npcIndex, npc)
                            nearNPCIndex = npcIndex
                        end
                    else
                        if distanceFromPed > npc.distanceCheck then
                            DeleteNPC(npcIndex, npc)
                            nearNPCIndex = nil
                        end
                    end
                end
                
                
                Wait(Config.Algorithm_Native_SyncTime * 1000)
            end
        end)

        CreateThread(function() 
            while true do
                if nearNPCIndex then
                    local npcData = NPCList[nearNPCIndex] 
                    ThreadNPCInteraction(npcData)
                end
                
                Wait(5)
            end
        end)
    end
end

CreateNPCThreads()


AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        DeletePreoviousNPC()
    elseif exportedNpcCreated[resource] then
        
        for _, npcIndex in pairs(exportedNpcCreated[resource]) do
            DestroyZoneId(npcIndex)
            DeleteNPC(npcIndex)
        end
    end
end)