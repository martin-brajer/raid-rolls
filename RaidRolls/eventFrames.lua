-- Define EventFrames and connect them with OnEvent functions from `RaidRolls_G.eventFunctions`.
-- Define register helper functions.

local this_module = RaidRolls_G.eventFrames

-- CREATE EVENT FRAMES

-- The first time saved variables are accessible (they are not while built-in onLoad is run).
local addonLoaded_EventFrame = CreateFrame("Frame")
addonLoaded_EventFrame:RegisterEvent("ADDON_LOADED")
addonLoaded_EventFrame:SetScript("OnEvent", RaidRolls_G.eventFunctions.OnLoad)

-- The current player joins a group.
local groupJoin_EventFrame = CreateFrame("Frame")
groupJoin_EventFrame:RegisterEvent("GROUP_JOINED")
groupJoin_EventFrame:SetScript("OnEvent", RaidRolls_G.eventFunctions.OnGroupJoined)

-- The current player left a group.
local groupJoin_EventFrame = CreateFrame("Frame")
groupJoin_EventFrame:RegisterEvent("GROUP_LEFT")
groupJoin_EventFrame:SetScript("OnEvent", RaidRolls_G.eventFunctions.OnGroupLeft)

-- Group type changed, a player changed subgroup.
local groupUpdate_EventFrame = CreateFrame("Frame")
groupUpdate_EventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
groupUpdate_EventFrame:SetScript("OnEvent", RaidRolls_G.eventFunctions.OnGroupUpdate)

-- Listen to CHAT_MSG_EVENTS for passing.
local passing_EventFrame = CreateFrame("Frame")
passing_EventFrame:SetScript("OnEvent", RaidRolls_G.eventFunctions.OnChatMsg)

-- Listen to CHAT_MSG_SYSTEM event and catch /rolling.
local rolling_EventFrame = CreateFrame("Frame")
rolling_EventFrame:SetScript("OnEvent", RaidRolls_G.eventFunctions.OnSystemMsg)

-- REGISTERING AND UNREGISTERING EVENTS - HELPER FUNCTIONS.

-- All the events (channels) searched for saying "pass".
local CHAT_MSG_EVENTS = {
    "CHAT_MSG_INSTANCE_CHAT",
    "CHAT_MSG_INSTANCE_CHAT_LEADER",
    "CHAT_MSG_PARTY",
    "CHAT_MSG_PARTY_LEADER",
    "CHAT_MSG_RAID",
    "CHAT_MSG_RAID_LEADER",
    "CHAT_MSG_WHISPER",
}

function this_module.RegisterChatEvents()
    for _, event in ipairs(CHAT_MSG_EVENTS) do
        passing_EventFrame:RegisterEvent(event)
    end
    rolling_EventFrame:RegisterEvent("CHAT_MSG_SYSTEM")
end

-- Unregister events.
function this_module.UnregisterChatEvents()
    for _, event in ipairs(CHAT_MSG_EVENTS) do
        passing_EventFrame:UnregisterEvent(event)
    end
    rolling_EventFrame:UnregisterEvent("CHAT_MSG_SYSTEM")
end

-- Register solo channels for testing.
function this_module.RegisterSoloChatEvents()
    passing_EventFrame:RegisterEvent("CHAT_MSG_SAY")
    rolling_EventFrame:RegisterEvent("CHAT_MSG_SYSTEM")
end
