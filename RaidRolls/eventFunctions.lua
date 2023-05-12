-- Functions called on events defined in `eventFrames.lua`.

-- ADDON_LOADED
function RaidRolls_G.eventFunctions.OnLoad(self, event, addOnName)
    if addOnName == "RaidRolls" then
        print(GetAddOnMetadata("RaidRolls", "Title") ..
            " v" .. GetAddOnMetadata("RaidRolls", "Version") .. " loaded. Type '/raidrolls help' for help.")
        RaidRolls_G.initializeUI()

        RaidRolls_G.wasInGroup = IsInGroup()
        if IsInGroup() then
            RaidRolls_G.eventFrames.RegisterChatEvents()
        end
        RaidRolls_G.update() -- To do lootWarning check.

        -- Load saved variables.
        if RaidRollsShown == nil then -- Initialize when first loaded.
            RaidRollsShown = true;
        end
        RaidRolls_G.show(RaidRollsShown)
    end
end

-- GROUP_ROSTER_UPDATE
function RaidRolls_G.eventFunctions.OnGroupUpdate(self, event)
    -- The addon user (!!) just joined or left the group. Do not update here. Freeze the addon
    -- info shown on leave. On join the event will be invoked twice anyway (so it updates).
    if IsInGroup() ~= RaidRolls_G.wasInGroup then -- Player's group status changed.
        RaidRolls_G.wasInGroup = IsInGroup()
        if IsInGroup() then                       -- Just joined.
            RaidRolls_G.eventFrames.RegisterChatEvents()
        else                                      -- Just left.
            RaidRolls_G.eventFrames.UnregisterChatEvents()
        end
        -- Other changes like other ppl joining or leaving.
    elseif IsInGroup() then
        RaidRolls_G.update()
    end
end

-- CHAT_MSG_EVENTS
-- Look for "pass" in the group channels.
function RaidRolls_G.eventFunctions.OnChatMsg(self, event, text, playerName)
    -- If the player name contains a hyphen, return the text up to the hyphen.
    local character_name, server = strsplit("-", playerName)

    if string.lower(text) == "pass" then
        RaidRolls_G.rollers[character_name] = 0
        RaidRolls_G.update()
    end
end

-- CHAT_MSG_SYSTEM
-- Look for "/roll" in system messages.
function RaidRolls_G.eventFunctions.OnSystemMsg(self, event, text)
    if string.find(text, "rolls") ~= nil then
        local name, roll, minRoll, maxRoll = text:match("^(.+) rolls (%d+) %((%d+)%-(%d+)%)$")

        minRoll = tonumber(minRoll)
        maxRoll = tonumber(maxRoll)
        if (minRoll ~= 1 or maxRoll ~= 100) then return end

        if RaidRolls_G.rollers[name] == nil then
            RaidRolls_G.rollers[name] = tonumber(roll)
        else
            RaidRolls_G.rollers[name] = -tonumber(roll) -- Minus to mark multiroll.
        end
        RaidRolls_G.update()
    end
end

-- PARTY_LOOT_METHOD_CHANGED PARTY_LEADER_CHANGED
function RaidRolls_G.eventFunctions.OnMasterLooterMayHaveChanged(self, event)
    RaidRolls_G.update()
end
