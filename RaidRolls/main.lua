-- Global locals.
RaidRolls_G = {}
-- Saved variables
RaidRollsShown = true  -- Was the main frame shown at the end of the last session?

-- Table of rolling players.
RaidRolls_G.rollers = {}
-- Collection of {unit, roll} to be used to show data rows.
RaidRolls_G.rowPool = {}
-- Was the player in group last time GROUP_ROSTER_UPDATE was invoked?
RaidRolls_G.wasInGroup = nil
-- All colours used..
RaidRolls_G.colours = {
    -- Group type
    NOGROUP = "|cFFFFFF00",  -- System message colour
    PARTY = "|cFFAAA7FF",
    RAID = "|cFFFF7D00",
    -- GUI
    BACKGROUND = {0.2, 0.2, 0.2, 0.7},
    HEADER = {1, 1, 0, 1},
    MASTERLOOTER = "|cFFFF0000",
    MULTIROLL = "|cFFFF0000",
    PASS = "|cFF00ccff",
    -- Misc.
    UNKNOWN = "|cFFFFFF00",  -- System message colour
    SYSTEMMSG = "|cFFFFFF00",  -- System message colour
}
-- All the events (channels) searched for saying "pass".
local CHAT_MSG_EVENTS = {
    "CHAT_MSG_PARTY_LEADER",
    "CHAT_MSG_PARTY",
    "CHAT_MSG_RAID_LEADER",
    "CHAT_MSG_RAID",
    "CHAT_MSG_WHISPER",
}
RaidRolls_G.ROW_HEIGHT = 20


-- Register events.
-- Must be defined after EventFrames are defined (otherwise onLoad call will try to access global variants).
function RaidRolls_G.RegisterChatEvents()
    for _, event in ipairs(CHAT_MSG_EVENTS) do
        passing_EventFrame:RegisterEvent(event)
    end
    rolling_EventFrame:RegisterEvent("CHAT_MSG_SYSTEM")
end

-- Unregister events.
function RaidRolls_G.UnregisterChatEvents()
    for _, event in ipairs(CHAT_MSG_EVENTS) do
        passing_EventFrame:UnregisterEvent(event)
    end
    rolling_EventFrame:UnregisterEvent("CHAT_MSG_SYSTEM")
end

-- Table length (sort of).
local function tableCount(t)
    local count = 0
    for _ in pairs(t) do count = count + 1 end
    return count
end

-- Find what kind of group the player (addon user) is in.
local function groupType()
    if IsInRaid() then
        return "RAID"
    elseif IsInGroup() then  -- Any group type but raid == party.
        return "PARTY"
    end
    return "NOGROUP"
end

-- If player not found, return default values. E.g. when the player has already left the group.
local function getGroupMemberInfo(name, groupType)
    local subgroup, class, fileName, groupTypeUnit = "?", "unknown", "UNKNOWN", "NOGROUP"  -- defaults
    
    if groupType == "RAID" then
        local _name, _subgroup, _class, _fileName  -- Candidates.
        for i = 1, GetNumGroupMembers() do
            _name, _, _subgroup, _, _class, _fileName = GetRaidRosterInfo(i)
            if _name == name then
                subgroup, class, fileName = _subgroup, _class, _fileName
                groupTypeUnit = groupType
                break  -- If not break, name stays and others get default values.
            end
        end
    elseif groupType == "PARTY" then
        if UnitInParty(name) then
            subgroup = "P"
            class, fileName = UnitClass(name)
            groupTypeUnit = groupType
        end
    elseif name == UnitName("player") then  -- Also groupType == "NOGROUP".
        class, fileName = UnitClass(name)
    end
    
    -- `class` is localized, `fileName` is a token.
    return name, subgroup, class, fileName, groupTypeUnit
end

-- Main drawing function.
function RaidRolls_G.update(lootWarningOnly)
    lootWarningOnly = lootWarningOnly or false
    local lootWarning = UnitIsGroupLeader("player") and GetLootMethod() ~= "master"

    do
        local numberOfRows = tableCount(RaidRolls_G.rollers) + (lootWarning and 1 or 0)
        RaidRolls_MainFrame:SetHeight(30 + RaidRolls_G.ROW_HEIGHT * numberOfRows)  -- 30 = (5 + 15 + 10)
    end
    
    local i = 1  -- Defined outside the for loop, so the index `i` is kept for future use.
    if not lootWarningOnly then
        -- Python notation: From dict(<name>: <roll>, ...) to sorted list(dict(name: <name>, roll: <roll>), ...)
        local sortedRollers = {}
        for name, roll in pairs(RaidRolls_G.rollers) do
            table.insert(sortedRollers, { name = name, roll = roll })
        end
        table.sort(sortedRollers, function(lhs, rhs)
            return math.abs(lhs.roll) > math.abs(rhs.roll)
        end)
        
        local groupType = groupType()  -- Called here to avoid repetitively getting the same value.
        local colours = RaidRolls_G.colours
        local row
        for _, roller in ipairs(sortedRollers) do
            local name, subgroup, class, fileName, groupTypeUnit = getGroupMemberInfo(roller.name, groupType)
            
            local classColour = RAID_CLASS_COLORS[fileName]
            if classColour == nil then
                classColour = colours.UNKNOWN
            else
                classColour = "|c" .. classColour.colorStr
            end
            class = classColour .. class .. "|r"
            subgroup = colours[groupTypeUnit] .. subgroup .. "|r"
            
            local roll = roller.roll
            if roll == 0 then
                roll = colours.PASS .. "pass|r"
            elseif roll < 0 then
                roll = colours.MULTIROLL .. math.abs(roll) .. "|r"
            end
            
            row = RaidRolls_G.getRow(i)
            row.unit:SetText(name .. " (" .. class .. ")[" .. subgroup .. "]")
            row.roll:SetText(roll)

            i = i + 1
        end
        -- Here `i` is set to the line following the last one used.
    end
        
    if lootWarning then
        RaidRolls_MainFrame_LootWarning:SetPoint("TOPLEFT", RaidRolls_G.getRow(i - 1).unit, "BOTTOMLEFT")
        RaidRolls_MainFrame_LootWarning:Show()
    else
        RaidRolls_MainFrame_LootWarning:Hide()
    end
    
    -- Iterate over the rest of rows. Including the one (maybe) overlaid by lootWarning.
    while i <= tableCount(RaidRolls_G.rowPool) do
        row = RaidRolls_G.getRow(i)
        row.unit:Hide()
        row.roll:Hide()
        i = i + 1
    end
end
