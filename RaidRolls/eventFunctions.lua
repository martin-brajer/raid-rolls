-- Functions called on events defined in `RaidRolls_G.eventFrames`.
-- Populate `RaidRolls_G.eventFunctions` namespace.

-- ADDON_LOADED
function RaidRolls_G.eventFunctions.OnLoad(self, event, addOnName)
    if addOnName == "RaidRolls" then
        RaidRolls_G.gui:Initialize()
        -- Plugins initialize.
        for name, plugin in pairs(RaidRolls_G.plugins) do
            plugin:Initialize(RaidRolls_G.gui.mainFrame)
        end

        -- Load saved variables.
        if RaidRollsShown == nil then -- Initialize when first loaded.
            RaidRollsShown = true;
        end
        RaidRolls_G.gui:SetVisibility(RaidRollsShown)

        -- Initial state.
        if IsInGroup() then
            RaidRolls_G.eventFunctions.OnGroupJoined(self, event)
        end
        RaidRolls_G.Update() -- To do lootWarning check.
    end
end

-- GROUP_JOINED
function RaidRolls_G.eventFunctions.OnGroupJoined(self, event)
    RaidRolls_G.eventFrames.RegisterChatEvents()
end

-- GROUP_LEFT
function RaidRolls_G.eventFunctions.OnGroupLeft(self, event)
    RaidRolls_G.eventFrames.UnregisterChatEvents()
end

-- GROUP_ROSTER_UPDATE
function RaidRolls_G.eventFunctions.OnGroupUpdate(self, event)
    RaidRolls_G.Update()
end

-- CHAT_MSG_EVENTS
-- Look for "pass" in the group channels.
function RaidRolls_G.eventFunctions.OnChatMsg(self, event, text, playerName)
    -- If the player name contains a hyphen, return the text up to the hyphen.
    local name, server = strsplit("-", playerName)

    if string.lower(text) == "pass" then
        RaidRolls_G.rollers:Save(name, 0)
        RaidRolls_G.Update()
    end
end

-- CHAT_MSG_SYSTEM
-- Look for "/roll" in system messages.
function RaidRolls_G.eventFunctions.OnSystemMsg(self, event, text)
    if string.find(text, "rolls") ~= nil then
        local name, roll, minRoll, maxRoll = text:match("^(.+) rolls (%d+) %((%d+)%-(%d+)%)$")

        minRoll = tonumber(minRoll)
        maxRoll = tonumber(maxRoll)
        if (minRoll == 1 and maxRoll == 100) then
            RaidRolls_G.rollers:Save(name, tonumber(roll))
            RaidRolls_G.Update()
        end
    end
end
