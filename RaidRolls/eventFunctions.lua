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
        RaidRolls_G.wasInGroup = IsInGroup()
        if IsInGroup() then
            RaidRolls_G.eventFrames.RegisterChatEvents()
        end
        RaidRolls_G.Update() -- To do lootWarning check.
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
        RaidRolls_G.Update()
    end
end

-- CHAT_MSG_EVENTS
-- Look for "pass" in the group channels.
function RaidRolls_G.eventFunctions.OnChatMsg(self, event, text, playerName)
    -- If the player name contains a hyphen, return the text up to the hyphen.
    local characterName, server = strsplit("-", playerName)

    if string.lower(text) == "pass" then
        RaidRolls_G.rollers[characterName] = 0
        RaidRolls_G.Update()
    end
end

-- CHAT_MSG_SYSTEM
-- Look for "/roll" in system messages.
function RaidRolls_G.eventFunctions.OnSystemMsg(self, event, text)
    if string.find(text, "rolls") ~= nil then
        local name, roll, minRoll, maxRoll = text:match("^(.+) rolls (%d+) %((%d+)%-(%d+)%)$")

        if (tonumber(minRoll) ~= 1 or tonumber(maxRoll) ~= 100) then return end

        if RaidRolls_G.rollers[name] == nil then
            RaidRolls_G.rollers[name] = tonumber(roll)
        else
            RaidRolls_G.rollers[name] = -tonumber(roll) -- Minus to mark multiroll.
        end
        RaidRolls_G.Update()
    end
end
