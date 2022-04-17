-- The first time saved variables are accessible (they are not while onLoad is run).
local addonLoaded_EventFrame = CreateFrame("Frame", "addonLoaded_EventFrame")
addonLoaded_EventFrame:RegisterEvent("ADDON_LOADED")
addonLoaded_EventFrame:SetScript("OnEvent", function(self, event, addOnName)
    if addOnName  == "RaidRolls" then
        print(GetAddOnMetadata("RaidRolls", "Title") .. " v" .. GetAddOnMetadata("RaidRolls", "Version") .. " loaded. Type '/raidrolls help' for help.")
        RaidRolls_G.initializeUI()

        RaidRolls_G.wasInGroup = IsInGroup()
        if IsInGroup() then
            RaidRolls_G.RegisterChatEvents()
        end
        RaidRolls_G.update()  -- To do lootWarning check.
        
        -- Load saved variables.
        if RaidRollsShown == nil then  -- Initialize when first loaded.
            RaidRollsShown = true;
        end
        RaidRolls_G.show(RaidRollsShown)
    end
end)

-- Register / unregister events when the addon user joins or leaves a group.
local groupUpdate_EventFrame = CreateFrame("Frame", "groupUpdate_EventFrame")
groupUpdate_EventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
groupUpdate_EventFrame:SetScript("OnEvent", function(self, event)
    -- The addon user (!!) just joined or left the group. Do not update here. Freeze the addon
    -- info shown on leave. On join the event will be invoked twice anyway (so it updates).
    if IsInGroup() ~= RaidRolls_G.wasInGroup then  -- Player's group status changed.
        RaidRolls_G.wasInGroup = IsInGroup()
        if IsInGroup() then  -- Just joined.
            RaidRolls_G.RegisterChatEvents()
        else  -- Just left.
            RaidRolls_G.UnregisterChatEvents()
        end
        -- Other changes like other ppl joining or leaving.
    elseif IsInGroup() then
        RaidRolls_G.update()
    end
end)

-- Invoke update after Master Looter relevant events are raised.
local masterLooter_EventFrame = CreateFrame("Frame", "masterLooter_EventFrame")
masterLooter_EventFrame:RegisterEvent("PARTY_LOOT_METHOD_CHANGED")
masterLooter_EventFrame:RegisterEvent("PARTY_LEADER_CHANGED")
masterLooter_EventFrame:SetScript("OnEvent", function(self, event)
    RaidRolls_G.update()
end)

-- Listen to CHAT_MSG_EVENTS for passing.
local passing_EventFrame = CreateFrame("Frame", "passing_EventFrame")
passing_EventFrame:SetScript("OnEvent", function(self, event, text, name)
    -- If the player name contains a hyphen, return the text up to the hyphen.
    name = string.split("-", name)
    
    if string.lower(text) == "pass" then
        RaidRolls_G.rollers[name] = 0
        RaidRolls_G.update()
    end
end)

-- Listen to CHAT_MSG_SYSTEM event and catch /rolling.
local rolling_EventFrame = CreateFrame("Frame", "rolling_EventFrame")
rolling_EventFrame:SetScript("OnEvent", function(self, event, text)
    if string.find(text, "rolls") ~= nil then
        local name, roll, minRoll, maxRoll = text:match("^(.+) rolls (%d+) %((%d+)%-(%d+)%)$")
        
        minRoll = tonumber(minRoll)
        maxRoll = tonumber(maxRoll)
        if (minRoll ~= 1 or maxRoll ~= 100) then return end
        
        if RaidRolls_G.rollers[name] == nil then
            RaidRolls_G.rollers[name] = tonumber(roll)
        else
            RaidRolls_G.rollers[name] = -tonumber(roll)  -- Minus to mark multiroll.
        end
        RaidRolls_G.update()
    end
end)
