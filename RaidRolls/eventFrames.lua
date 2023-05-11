-- The first time saved variables are accessible (they are not while onLoad is run).
local addonLoaded_EventFrame = CreateFrame("Frame")
addonLoaded_EventFrame:RegisterEvent("ADDON_LOADED")
addonLoaded_EventFrame:SetScript("OnEvent", RaidRolls_G.eventFunctions.OnLoad)

-- Register / unregister events when the addon user joins or leaves a group.
local groupUpdate_EventFrame = CreateFrame("Frame")
groupUpdate_EventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
groupUpdate_EventFrame:SetScript("OnEvent", RaidRolls_G.eventFunctions.OnGroupUpdate)

-- Listen to CHAT_MSG_EVENTS for passing.
RaidRolls_G.regions.passing_EventFrame = CreateFrame("Frame")
RaidRolls_G.regions.passing_EventFrame:SetScript("OnEvent", RaidRolls_G.eventFunctions.OnChatMsg)

-- Listen to CHAT_MSG_SYSTEM event and catch /rolling.
RaidRolls_G.regions.rolling_EventFrame = CreateFrame("Frame")
RaidRolls_G.regions.rolling_EventFrame:SetScript("OnEvent", RaidRolls_G.eventFunctions.OnSystemMsg)

-- Invoke update after Master Looter relevant events are raised.
local masterLooter_EventFrame = CreateFrame("Frame")
masterLooter_EventFrame:RegisterEvent("PARTY_LOOT_METHOD_CHANGED")
masterLooter_EventFrame:RegisterEvent("PARTY_LEADER_CHANGED")
masterLooter_EventFrame:SetScript("OnEvent", RaidRolls_G.eventFunctions.OnMasterLooterMayHaveChanged)
