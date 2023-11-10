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

-- If it is set to 'true' it will be sent only once, which means that you will be able to use notifications that can be activated/deactivated.
Config.UseCustomInteractionNotification = true

-- Use this decor to set the NPC's is a Script Creation.
-- This maybe helps with other npc scripts.
-- When NPC using this decor you can make checks that helps if npc can be 'used' for other prorpuses.
Config.NPCDecor = 'server_npc'

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

        options = {
            freeze = true,
            invincible = true,
            blockTemporaryEvents = true
        },

        pedOptions = function(ped)
            SetPedDiesWhenInjured(ped, false)
            SetPedCanPlayAmbientAnims(ped, true)
            SetPedCanRagdollFromPlayerImpact(ped, false)
        end,

        onInteract = function(pedHandler)
            lib.notify({
                description = "This is a NPC Interaction!",
                type = "success"
            })
        end,
    }
}