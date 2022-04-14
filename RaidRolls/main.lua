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
    RAID = "FFFF7D00",
    PARTY = "FFAAA7FF",
    NOGROUP = "FFFFFF00",  -- System message colour
    -- GUI
    PASS = "FF00ccff",
    MULTIROLL = "FFFF0000",
    MASTERLOOTER = "FFFF0000",
    -- Misc.
    UNKNOWN = "FFFFFF00",  -- System message colour
}
-- All the events (channels) searched for saying "pass".
local CHAT_MSG_EVENTS = {
    "CHAT_MSG_PARTY_LEADER",
    "CHAT_MSG_PARTY",
    "CHAT_MSG_RAID_LEADER",
    "CHAT_MSG_RAID",
    "CHAT_MSG_WHISPER",
}

-- Saved variables (RaidRollsShown) are loaded here.
-- The first time saved variables are accessible (they are not while onLoad is run).
local LoadSavedVariables_EventFrame = CreateFrame("Frame", "LoadSavedVariables_EventFrame")
LoadSavedVariables_EventFrame:RegisterEvent("ADDON_LOADED")
LoadSavedVariables_EventFrame:SetScript("OnEvent",
    function(self, event, addOnName)
        if addOnName  == "RaidRolls" then
            -- Initialize when first loaded.
            if RaidRollsShown == nil then
                RaidRollsShown = true;
            end
            
            -- Load the saved stuff.
            RaidRolls_G.show(RaidRollsShown)
        end
    end
)

-- Invoke update after Master Looter relevant events are raised.
local MasterLooter_EventFrame = CreateFrame("Frame", "MasterLooter_EventFrame")
MasterLooter_EventFrame:RegisterEvent("PARTY_LOOT_METHOD_CHANGED")
MasterLooter_EventFrame:RegisterEvent("PARTY_LEADER_CHANGED")
MasterLooter_EventFrame:SetScript("OnEvent",
    function(self, event)
        RaidRolls_G.update()
    end
)

-- Register / unregister events when the addon user joins or leaves a group.
local GroupUpdate_EventFrame = CreateFrame("Frame", "GroupUpdate_EventFrame")
GroupUpdate_EventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
GroupUpdate_EventFrame:SetScript("OnEvent",
    function(self, event)
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
    end
)

-- Listen to CHAT_MSG_EVENTS for passing.
local GroupChannels_EventFrame = CreateFrame("Frame", "GroupChannels_EventFrame")
GroupChannels_EventFrame:SetScript("OnEvent",
    function(self, event, text, name)
        -- If the player name contains a hyphen, return the text up to the hyphen.
        name = string.split("-", name)
        
        if string.lower(text) == "pass" then
            RaidRolls_G.rollers[name] = 0
            RaidRolls_G.update()
        end
    end
)

-- Listen to CHAT_MSG_SYSTEM event and catch /rolling.
local SystemMsg_EventFrame = CreateFrame("Frame", "SystemMsg_EventFrame")
SystemMsg_EventFrame:SetScript("OnEvent",
    function(self, event, text)
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
    end
)
    
-- OnLoad called by main.xml.
function RaidRolls_G.onLoad(self)
    local title = GetAddOnMetadata("RaidRolls", "Title")
    local version = GetAddOnMetadata("RaidRolls", "Version")
    print(title .. " v" .. version .. " loaded. Type '/raidrolls help' for help.")
    
    RaidRolls_MainFrame:SetScript("OnMouseDown",
        function(self, event)
            if event == "LeftButton" then
                RaidRolls_MainFrame:StartMoving();
            elseif event == "RightButton" then
                RaidRolls_G.reset()
            end
        end
    )
    
    RaidRolls_MainFrame:SetScript("OnMouseUp",
        function(self, event)
            RaidRolls_MainFrame:StopMovingOrSizing()
        end
    )
    
    local row = RaidRolls_MainFrame:CreateFontString("$parent_lootWarning", "RaidRolls_MainFrame", "GameTooltipText")
    row:SetHeight(20)
    row:SetPoint("TOPLEFT", RaidRolls_G.getRow(0).unit, "BOTTOMLEFT")
    row:SetText("Set |c" .. RaidRolls_G.colours.MASTERLOOTER .. "MASTER LOOTER|r!!!")
    row:Hide()
    
    RaidRolls_G.wasInGroup = IsInGroup()
    if IsInGroup() then
        RaidRolls_G.RegisterChatEvents()
    end
    RaidRolls_G.update()
end

-- Handle FontStrings needed for listing rolling players.
-- Uses as few rows as possible (recycles the old ones).
-- Return i-th row (create if necessary). Zero gives headers.
function RaidRolls_G.getRow(i)
    if i == 0 then
        return { unit = "$parent_UnitHeader", roll = "$parent_RollHeader" }
    end

    local row = RaidRolls_G.rowPool[i]
    if row then
        row.unit:Show()
        row.roll:Show()
    else
        local unit = RaidRolls_MainFrame:CreateFontString("$parent_UnitRow" .. tostring(i), "RaidRolls_MainFrame", "GameTooltipText")
        local roll = RaidRolls_MainFrame:CreateFontString("$parent_RollRow" .. tostring(i), "RaidRolls_MainFrame", "GameTooltipText")
        
        local parents = RaidRolls_G.getRow(i - 1)
        unit:SetPoint("TOPLEFT", parents.unit, "BOTTOMLEFT")
        roll:SetPoint("TOPLEFT", parents.roll, "BOTTOMLEFT")
        
        unit:SetHeight(20)
        roll:SetHeight(20)

        row = { unit = unit, roll = roll }
        tinsert(RaidRolls_G.rowPool, row)
    end

    return row
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
    end
    
    -- `class` is localized, `fileName` is a token.
    return name, subgroup, class, fileName, groupTypeUnit
end

-- Main drawing function.
function RaidRolls_G.update()
    local groupType = groupType()
    local lootWarning = UnitIsGroupLeader("player") and GetLootMethod() ~= "master"
    
    -- 30 = (5 + 15 + 10); 20 for every input plus one for Master Looter warning.
    RaidRolls_MainFrame:SetHeight(30 + 20 * (tableCount(RaidRolls_G.rollers) + (lootWarning and 1 or 0)))
    
    -- Python notation: From dict(<name>: <roll>, ...) to sorted list(dict(name: <name>, roll: <roll>), ...)
    local sortedRollers = {}
    for name, roll in pairs(RaidRolls_G.rollers) do
        table.insert(sortedRollers, { name = name, roll = roll })
    end
    table.sort(sortedRollers, function(lhs, rhs)
        return math.abs(lhs.roll) > math.abs(rhs.roll)
    end)
    
    local i = 1  -- Defined outside the for loop, so the index `i` is kept for future use.
    local row
    for _, roller in ipairs(sortedRollers) do
        local name, subgroup, class, fileName, groupTypeUnit = getGroupMemberInfo(roller.name, groupType)
        
        local classColour = RAID_CLASS_COLORS[fileName]
        if classColour == nil then
            classColour = RaidRolls_G.colours.UNKNOWN
        else
            classColour = classColour.colorStr
        end
        class = "|c" .. classColour .. class .. "|r"
        subgroup = "|c" .. RaidRolls_G.colours[groupTypeUnit] .. subgroup .. "|r"
        
        local roll = roller.roll
        if roll == 0 then
            roll = "|c" .. RaidRolls_G.colours.PASS .. "pass|r"
        elseif roll < 0 then
            roll = "|c" .. RaidRolls_G.colours.MULTIROLL .. math.abs(roll) .. "|r"
        end
        
        row = RaidRolls_G.getRow(i)
        row.unit:SetText(name .. " (" .. class .. ")[" .. subgroup .. "]")
        row.roll:SetText(roll)

        i = i + 1
    end
    -- Here `i` is set to the line following the last one used.
        
    if lootWarning then
        RaidRolls_MainFrame_lootWarning:SetPoint("TOPLEFT", RaidRolls_G.getRow(i - 1).unit, "BOTTOMLEFT")
        RaidRolls_MainFrame_lootWarning:Show()
    else
        RaidRolls_MainFrame_lootWarning:Hide()
    end
    
    -- Iterate over the rest of rows. Including the one (maybe) overlaid by lootWarning.
    while i <= tableCount(RaidRolls_G.rowPool) do
        row = RaidRolls_G.getRow(i)
        row.unit:Hide()
        row.roll:Hide()
        i = i + 1
    end
end

-- Register events.
-- Must be defined after EventFrames are defined (otherwise onLoad call will try to access global variants).
function RaidRolls_G.RegisterChatEvents()
    for _, event in ipairs(CHAT_MSG_EVENTS) do
        GroupChannels_EventFrame:RegisterEvent(event)
    end
    SystemMsg_EventFrame:RegisterEvent("CHAT_MSG_SYSTEM")
end

-- Unregister events.
function RaidRolls_G.UnregisterChatEvents()
    for _, event in ipairs(CHAT_MSG_EVENTS) do
        GroupChannels_EventFrame:UnregisterEvent(event)
    end
    SystemMsg_EventFrame:UnregisterEvent("CHAT_MSG_SYSTEM")
end
