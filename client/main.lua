local NPCList ={}
local nearNPCIndex = nil


DeleteNPC = function(npcIndex)
    local entity = NPCList[npcIndex].entity

    if DoesEntityExist(entity) then
        SetEntityAsMissionEntity(entity, false, false)
        DeleteEntity(entity)

        NPCList[npcIndex].entity = nil
        NPCList[npcIndex].notified = false
        OutCustomInteractionNotification()
    end
end

DeletePreoviousNPC = function()
    for npcIndex, _ in pairs(NPCList) do
        DeleteNPC(npcIndex)
    end

    NPCList = {}
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
                DeleteNPC(self.npcIndex, self.npcData)
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
    for npcIndex, npcData in pairs(Config.NPC) do
        CreateNPC(npcIndex, npcData)
    end
end

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
    end
end)