-- Global locals.
RaidRolls_G = {}

-- Table of rolling players.
RaidRolls_G.rollers = {}
-- Was the main frame shown at the end of the last session?
RaidRollsShown = true
-- List of {L, R} each being a FontString.
RaidRolls_G.rowPool = {}
-- Was the player in group last time groupTypeChanged() was called?
RaidRolls_G._wasInGroup = nil
-- All the events (channels) searched for saying "pass".
local CHAT_MSG_EVENTS = {
    "CHAT_MSG_PARTY_LEADER",
    "CHAT_MSG_PARTY",
    "CHAT_MSG_RAID_LEADER",
    "CHAT_MSG_RAID",
    "CHAT_MSG_WHISPER",
    }

-- OnLoad called by main.xml.
function RaidRolls_G.onload(self)
    print(GetAddOnMetadata("RaidRolls", "Title") .. " v" .. GetAddOnMetadata("RaidRolls", "Version") .. " loaded. Type '/raidrolls help' for help.")
    
    RaidRolls_MainFrame:SetScript("OnMouseDown",
        function(self, event)
            if event == "LeftButton" then
                RaidRolls_MainFrame:StartMoving();
            elseif event == "RightButton" then
                RaidRolls_G.reset()
            end
    end)
    
    RaidRolls_MainFrame:SetScript("OnMouseUp",
        function(self, event)
            RaidRolls_MainFrame:StopMovingOrSizing()
    end)
    
    local row = RaidRolls_MainFrame:CreateFontString(
        "$parent_LOOT", "RaidRolls_MainFrame", "GameTooltipText")
    row:SetHeight(20)
    row:SetPoint("TOPLEFT", "$parent_UnitHeader", "BOTTOMLEFT")
    row:SetText("Set " .. RaidRolls_G.textColours.MASTERLOOTER .. "MASTER LOOTER|r!!!")
    row:Hide()
    
    hooksecurefunc('ChatEdit_ParseText', RaidRolls_G.ParseText);
    
    RaidRolls_G.groupTypeChanged()
    RaidRolls_G.update()
    RaidRolls_G.ChatGroup_EventFrame_RegisterEvents()
end

-- Look for the addon user's passing. Not possible by CHAT_MSG_EVENTS.
function RaidRolls_G.ParseText(chatEntry, send)
     -- This function actually gets called every time the user hits a key. But the
     -- send flag will only be set when he hits return to send the message.
     if send == 1 then
        -- Player "pass" only in group.
        if RaidRolls_G.groupType() == nil then return end
        
        local msg = chatEntry:GetText(); -- Here's how you get the original text
        if string.lower(msg) == "pass" then
            RaidRolls_G.rollers[UnitName("player")] = 0
            RaidRolls_G.update()
        end
     end
end

-- Handle FontStrings needed for listing rolling players.
-- Try to use as few rows as possible (recycle the old ones).
-- Return i-th row (create if necessary).
local function getRow(i)
    local row = RaidRolls_G.rowPool[i]
    if row then
        row.L:Show()
        row.R:Show()
    else
        l = RaidRolls_MainFrame:CreateFontString("$parent_UnitRow" .. tostring(i), "RaidRolls_MainFrame", "GameTooltipText")
        l:SetHeight(20)
        r = RaidRolls_MainFrame:CreateFontString("$parent_RollRow" .. tostring(i), "RaidRolls_MainFrame", "GameTooltipText")
        r:SetHeight(20)
        
        row = { L = l, R = r}
        tinsert(RaidRolls_G.rowPool, row)
    end
    return row
end

-- Try to find a player by their name in the raid group.
-- Return nil if not found.
local function name2raidIndex(target_name)
    for i = 1, GetNumGroupMembers() do
        local candidate_name = GetRaidRosterInfo(i)  -- name, rank, subgroup, ...
        if candidate_name == target_name then
            return i
        end
    end
    return nil
end

-- Table length (sort of).
local function table_count(t)
    local count = 0
    for _ in pairs(t) do count = count + 1 end
    return count
end

-- Find what kind of group player is in (nil if none).
function RaidRolls_G.groupType()
    local groupType = nil
    if IsInRaid() then
        groupType = "RAID"
    elseif IsInGroup() then
        groupType = "PARTY"
    end
    return groupType
end

-- Was group joined/leaved since the last call?
-- @return Group: joined (true), leaved(false), neither (nil).
function RaidRolls_G.groupTypeChanged()
    local outcome = nil
    local groupType = RaidRolls_G.groupType()
    
    if RaidRolls_G._wasInGroup ~= nil then  -- Not init.
        if groupType == nil then  -- No group.
            if RaidRolls_G._wasInGroup then
                outcome = true
            else
                outcome = false
            end
        else  -- Group.
            if RaidRolls_G._wasInGroup then
                outcome = false
            else
                outcome = true
            end
        end
    end
    
    -- New value. Init.
    if groupType == nil then
        RaidRolls_G._wasInGroup = false
    else
        RaidRolls_G._wasInGroup = true
    end
    return outcome
end

-- Main drawing function. No processing there.
-- Any param (other than nil) make the function work even out of group.
-- Used for rolls reset and testing.
function RaidRolls_G.update(param)
    local groupType = RaidRolls_G.groupType()
    if groupType == nil and param == nil then return end
    if groupType == nil then
        groupType = "UNKNOWN"
    end
    
    local lootWarning = UnitIsGroupLeader("player") and GetLootMethod() ~= "master"
    -- 30 = (5 + 15 + 10); 20 for every input plus one for Master Looter warning.
    RaidRolls_MainFrame:SetHeight(30 + 20 * (table_count(RaidRolls_G.rollers) + (lootWarning and 1 or 0)))
    
    -- Python notation: From dict(<name>: <roll>, ...) to sorted list(dict(name: <name>, roll: <roll>), ...)
    local sortedRollers = {}
    for name, roll in pairs(RaidRolls_G.rollers) do
        table.insert(sortedRollers, { name = name, roll = roll })
    end
    table.sort(sortedRollers, function(lhs, rhs)
        return math.abs(lhs.roll) > math.abs(rhs.roll)
    end)
    
    -- Default Frame (i == 1) is defined here so it does not need to be rewritten or checked each cycle.
    local parentL = "$parent_UnitHeader"
    local parentR = "$parent_RollHeader"
    local i = 1  -- Defined outside the for loop, so the index `i` is kept for future use.
    for _, roller in ipairs(sortedRollers) do
        name = roller.name
        roll = roller.roll

        -- defaults; `class` is localized, `fileName` is a token
        local subgroup, class, fileName = "?", "unknown", "UNKNOWN"
        if groupType == "RAID" then
            local index = name2raidIndex(name)
            if index ~= nil then
                _, _, subgroup, _, class, fileName = GetRaidRosterInfo(index)
            end
        elseif groupType == "PARTY" then
            if UnitInParty(name) then
                subgroup = "P"
                class, fileName = UnitClass(name)
            end
        end
        
        if roll == 0 then
            roll = RaidRolls_G.textColours.PASS .. "pass|r"
        elseif roll < 0 then
            roll = RaidRolls_G.textColours.MULTIROLL .. math.abs(roll) .. "|r"
        end
        
        if i > 1 then
            parentL = "$parent_UnitRow" .. tostring(i - 1)
            parentR = "$parent_RollRow" .. tostring(i - 1)
        end

        local row = getRow(i)
        class = RaidRolls_G.classColours[fileName] .. class
        subgroup = RaidRolls_G.channelColours[groupType] .. subgroup
        row.L:SetText(name .. " (" .. class .. "|r)[" .. subgroup .. "|r]")
        row.R:SetText(roll)
        row.L:SetPoint("TOPLEFT", parentL, "BOTTOMLEFT")
        row.R:SetPoint("TOPLEFT", parentR, "BOTTOMLEFT")
        
        i = i + 1
    end
    -- Here `i` is set to the line following the last one used.
        
    if lootWarning then
        if i > 1 then
            parentL = "$parent_UnitRow" .. tostring(i - 1)
        end
        RaidRolls_MainFrame_LOOT:SetPoint("TOPLEFT", parentL, "BOTTOMLEFT")
        RaidRolls_MainFrame_LOOT:Show()
    else
        RaidRolls_MainFrame_LOOT:Hide()
    end
    
    -- Iterate over the rest of rows.
    while i <= table_count(RaidRolls_G.rowPool) do
        row = getRow(i)
        row.L:Hide()
        row.R:Hide()
        i = i + 1
    end
end


-- Register / unregister events when joining / leaving a group.
local GroupJoin_EventFrame = CreateFrame("Frame")
GroupJoin_EventFrame:RegisterEvent("PARTY_MEMBERS_CHANGED")
GroupJoin_EventFrame:SetScript("OnEvent",
    function(self, event)
        
        if RaidRolls_G.groupTypeChanged() then  -- Join or leave party/raid.
            
            if RaidRolls_G.groupType() == nil then  -- Just left.
                RaidRolls_G.ChatGroup_EventFrame_UnregisterEvents()
            
            else  -- Just joined.
                RaidRolls_G.ChatGroup_EventFrame_RegisterEvents()
            
            end
        end
    end)


-- Invoke update after ML-relevant events are raised.
local Loot_EventFrame = CreateFrame("Frame")
Loot_EventFrame:RegisterEvent("PARTY_LOOT_METHOD_CHANGED")
Loot_EventFrame:RegisterEvent("PARTY_LEADER_CHANGED")
Loot_EventFrame:SetScript("OnEvent",
    function(self, event)
        RaidRolls_G.update()
    end)


-- Listen to the system messages and catch some of them.
-- Those being: rolling, leaving raid or party.
local ChatSystem_EventFrame = CreateFrame("Frame")
ChatSystem_EventFrame:SetScript("OnEvent",
    function(self, event, msg)
        if RaidRolls_G.groupType() == nil then return end
        
        if msg then
            
            -- Roll message.
            if string.find(msg, "rolls") ~= nil then
                local name, roll, minRoll, maxRoll = msg:match("^(.+) rolls (%d+) %((%d+)%-(%d+)%)$")
                local minRoll = tonumber(minRoll)
                local maxRoll = tonumber(maxRoll)
                
                if not(name and minRoll == 1 and maxRoll == 100) then return end
                
                if RaidRolls_G.rollers[name] == nil then
                    RaidRolls_G.rollers[name] = tonumber(roll)
                else
                    --~ rollers[name] = -math.max(math.abs(rollers[name]), roll)
                    -- Not max, but last. Minus to mark multiroll.
                    RaidRolls_G.rollers[name] = -roll
                end
            
            -- Leave raid msg.
            elseif string.find(msg, "has left the raid group.") ~= nil then
                local name = msg:match("^(.+) has left the raid group.$")
                if name then
                    RaidRolls_G.rollers[name] = nil
                end
            
            -- Leave party msg.
            elseif string.find(msg, "leaves the party.") ~= nil then
                local name = msg:match("^(.+) leaves the party.$")
                if name then
                    RaidRolls_G.rollers[name] = nil
                end
            
            else
                return
            end
            
            -- I.e. if any of the above was true.
            RaidRolls_G.update()
        end
    end)

-- Listen to the CHAT_MSG_EVENTS for passing.
local ChatGroup_EventFrame = CreateFrame("Frame")
ChatGroup_EventFrame:SetScript("OnEvent",
    function(self, event, msg, name)
        
        if RaidRolls_G.groupType() == nil then return end
        
        -- If the player name contains a hyphen, return the text up to the hyphen.
        -- strsplit?
        name =  string.gmatch(name, "[^-]+")()
        
        if string.lower(msg) == "pass" then
            RaidRolls_G.rollers[name] = 0
            RaidRolls_G.update()
        end
    end)


-- On Load 2. Saved variables (RaidRollsShown) are loaded after OnLoad is run.
local Load_EventFrame = CreateFrame("Frame")
Load_EventFrame:RegisterEvent("ADDON_LOADED")
Load_EventFrame:SetScript("OnEvent",
    function(self, event, addOnName)
        if addOnName  == "RaidRolls" then
            
            if RaidRollsShown == nil then
                -- This is the first time this addon is loaded. Initialize to true.
                RaidRollsShown = true;
            end
            
            -- Load the saved stuff.
            RaidRolls_G.show(RaidRollsShown)
        end
    end)


-- Register events.
function RaidRolls_G.ChatGroup_EventFrame_RegisterEvents()
    for i, event in ipairs(CHAT_MSG_EVENTS) do
        ChatGroup_EventFrame:RegisterEvent(event)
    end
    ChatSystem_EventFrame:RegisterEvent("CHAT_MSG_SYSTEM")
end


-- Unregister events.
function RaidRolls_G.ChatGroup_EventFrame_UnregisterEvents()
    for i, event in ipairs(CHAT_MSG_EVENTS) do
        ChatGroup_EventFrame:UnregisterEvent(event)
    end
    ChatSystem_EventFrame:UnregisterEvent("CHAT_MSG_SYSTEM")
end
