Config = {}
lib.locale()

--[[

           ____  _____        _____                 _                                  _       
     /\   |  _ \|  __ \      |  __ \               | |                                | |      
    /  \  | |_) | |__) |_____| |  | | _____   _____| | ___  _ __  _ __ ___   ___ _ __ | |_ ___ 
   / /\ \ |  _ <|  ___/______| |  | |/ _ \ \ / / _ \ |/ _ \| '_ \| '_ ` _ \ / _ \ '_ \| __/ __|
  / ____ \| |_) | |          | |__| |  __/\ V /  __/ | (_) | |_) | | | | | |  __/ | | | |_\__ \
 /_/    \_\____/|_|          |_____/ \___| \_/ \___|_|\___/| .__/|_| |_| |_|\___|_| |_|\__|___/
                                                           | |                                 
                                                           |_|                                 

    Supported version 2023
    Support Discord: https://discord.gg/GQA39ee3

]]

-----------------------
--- GENERAL SETTINGS ---
-----------------------

-- Note: The algorithm will be used to detect the player in the area, these can be:
-- - 'native' : Native functions will be used to check the distance from the NPC to the player. (May slightly affect performance)
-- - 'zone': The OX library will be used to generate a sphere with a radius and the integrated functions will be used to detect whether or not it is in the zone.
Config.Algorithm = 'zone'

-- If Algorithm is 'zone'
Config.Algorithm_Zone_Debug = true

-- If Algorithm is 'native'
Config.Algorithm_Native_SyncTime = 2 -- In seconds


Config.InteractKey = 38

-----------------------
--- NPC SETTINGS ---
-----------------------
Config.NPC = {
    {
        model = "ig_abigail",
        name = "Abigail | ~y~Worker",
        position = vector3(-74.79563, -817.7433, 325.1751),
        heading = 152.86,
        distanceCheck = 5,

        pedOptions = function(ped)
            SetBlockingOfNonTemporaryEvents(ped, true)
            SetPedDiesWhenInjured(ped, false)
            SetPedCanPlayAmbientAnims(ped, true)
            SetPedCanRagdollFromPlayerImpact(ped, false)
            SetEntityInvincible(ped, true)
            FreezeEntityPosition(ped, true)
        end,

        onInteract = function(pedHandler)
            lib.notify({
                description = "This is a NPC Interaction!",
                type = "success"
            })
        end,
    }
}