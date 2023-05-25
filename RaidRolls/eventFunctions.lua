-- Functions called on events defined in `RaidRolls_G.eventFrames`.
-- Do not use `self` (`self ~= RaidRolls_G.eventFunctions`)
-- Populate `RaidRolls_G.eventFunctions`.

local cfg = RaidRolls_G.configuration

-- ADDON_LOADED
function RaidRolls_G.eventFunctions.OnLoad(self, event, addOnName)
    if addOnName == cfg.ADDON_NAME then
        RaidRolls_G:Initialize()
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
    RaidRolls_G.rollerCollection:UpdateGroup()
    RaidRolls_G:Draw()
end

-- CHAT_MSG_EVENTS
-- Look for "pass" in the group channels.
function RaidRolls_G.eventFunctions.OnChatMsg(self, event, text, playerName)
    local name, server = strsplit("-", playerName)

    if text:lower() == "pass" then
        RaidRolls_G.rollerCollection:Save(name, 0)
        RaidRolls_G:Draw()
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
            RaidRolls_G.rollerCollection:Save(name, tonumber(roll))
            RaidRolls_G:Draw()
        end
    end
end
