-- Global locals.
RaidRolls_G = {}


-- Table of rolling players.
RaidRolls_G.rollers = {}
-- Was the main frame shown at the end of the last session?
RaidRollsShown = true
-- List of {L, R} each being a FontString.
RaidRolls_G.FSPool = {}
-- Was the player in group last time groupTypeChanged() was called?
RaidRolls_G._wasInGroup = nil
-- All the events (channels) searched for saying "pass".
local CHAT_MSG_EVENTS = {
    "CHAT_MSG_BATTLEGROUND",
    "CHAT_MSG_BATTLEGROUND_LEADER",
    "CHAT_MSG_PARTY_LEADER",
    "CHAT_MSG_PARTY",
    "CHAT_MSG_RAID_LEADER",
    "CHAT_MSG_RAID",
    "CHAT_MSG_WHISPER",
    --~ "CHAT_MSG_BN_WHISPER",
    }


-- OnLoad called by main.xml.
function RaidRolls_G.onload(self)
    print(GetAddOnMetadata("RaidRolls", "Title") .. " v" .. GetAddOnMetadata("RaidRolls", "Version") .. " loaded. Type '/raidrolls help' for help.")
    
    RaidRolls_MainFrame:SetScript("OnMouseDown",
        function(self, event, ...)
            if (event == "LeftButton") then
                RaidRolls_MainFrame:StartMoving();
            elseif (event == "RightButton") then
                RaidRolls_G.reset()
            end
        end)
    
    local FS
    FS = RaidRolls_MainFrame:CreateFontString("$parent_LOOT", "RaidRolls_MainFrame", "GameTooltipText")
    FS:SetHeight(20)
    FS:SetPoint("TOPLEFT", "$parent_Player", "BOTTOMLEFT")
    FS:SetText("Set |cFFFF0000MASTER LOOTER|r!!!")
    FS:Hide()
    
    hooksecurefunc('ChatEdit_ParseText', RaidRolls_G.ParseText);
    
    RaidRolls_G.groupTypeChanged()
    
    RaidRolls_G.update()
    
    RaidRolls_G.ChatGroup_EventFrame_RegisterEvents()
end


-- Look for the addon user's passing. Not possible by CHAT_MSG_EVENTS.
function RaidRolls_G.ParseText(chatEntry, send)
     -- This function actually gets called every time the user hits a key. But the
     -- send flag will only be set when he hits return to send the message.
     if (send == 1) then
        -- Player "pass" only in group.
        if (RaidRolls_G.groupType() == nil) then return end
        
        local msg = chatEntry:GetText(); -- Here's how you get the original text
        if (string.lower(msg) == "pass") then
            RaidRolls_G.rollers[UnitName("player")] = 0
            RaidRolls_G.update()
        end
     end
end


-- Handle FontStrings needed for listing rolling players.
-- Try to use as few FSs as possible (recycle the old ones).
local function getFS(i)
    local f = RaidRolls_G.FSPool[i]
    if not f then
        f = {}
        l = RaidRolls_MainFrame:CreateFontString("$parent_FSL" .. tostring(i), "RaidRolls_MainFrame", "GameTooltipText")
        l:SetHeight(20)
        r = RaidRolls_MainFrame:CreateFontString("$parent_FSR" .. tostring(i), "RaidRolls_MainFrame", "GameTooltipText")
        r:SetHeight(20)
        
        f = { L = l, R = r}
        tinsert(RaidRolls_G.FSPool, f)
    else
        f.L:Show()
        f.R:Show()
    end
    return f
end



-- Try to find player by name in the raid group.
-- Return nil if not found.
local function name2raidIndex(target)
    for i = 1, GetNumGroupMembers() do
        local name = GetRaidRosterInfo(i)
        if (name == target) then
            return i
        end
    end
    
    return nil
end


-- Find length of the given table.
local function myLength(tab)
    local count = 0
    for k,v in pairs(tab) do
        count = count + 1
    end
    return count
end


-- Find what kind of group player is in (nil if none).
function RaidRolls_G.groupType()
    local _groupType = nil
    
    if (IsInRaid()) then
        _groupType = "RAID"
    elseif (IsInGroup()) then
        _groupType = "PARTY"
    end
    
    return _groupType
end


-- Was group joined/leaved since the last call?
-- @return Group: joined (true), leaved(false), neither (nil).
function RaidRolls_G.groupTypeChanged()
    local outcome = nil
    local _groupType = RaidRolls_G.groupType()
    
    if (RaidRolls_G._wasInGroup ~= nil) then  -- Not init.
        if (_groupType == nil) then  -- No group.
            if (RaidRolls_G._wasInGroup) then
                outcome = true
            else
                outcome = false
            end
        else  -- Group.
            if (RaidRolls_G._wasInGroup) then
                outcome = false
            else
                outcome = true
            end
        end
    end
    
    -- New value. Init.
    if (_groupType == nil) then
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
    local _groupType = RaidRolls_G.groupType()
    if (_groupType == nil and param == nil) then return end
    
    local lootWarning = false
    if (UnitIsGroupLeader("player") and GetLootMethod() ~= "master") then
        lootWarning = true
    end
    
    -- 30 = (5 + 15 + 10); 20 for every input plus one for ML warning.
    RaidRolls_MainFrame:SetHeight(30 + 20 * (myLength(RaidRolls_G.rollers) + (lootWarning and 1 or 0)))
    
    local sortedRollers = {}
    for k, v in pairs(RaidRolls_G.rollers) do
        -- k = name; v = roll
        table.insert(sortedRollers, { k = k, v = v })
    end
    table.sort(sortedRollers,
        function(lhs, rhs)
            return math.abs(lhs.v) > math.abs(rhs.v)
        end)
    
    local i = 1
    -- Default (i == 1).
    local parentL = "$parent_Player"
    local parentR = "$parent_Roll"
    for k, v in pairs(sortedRollers) do
        -- v.k = name; v.v = roll
        
        local Name, subgroup, class, fileName = v.k, "?", "unknown", "UNKNOWN"
        if (_groupType == "RAID") then
            local index = name2raidIndex(v.k)
            if (index ~= nil) then
                Name, _, subgroup, _, class, fileName = GetRaidRosterInfo(index)
            end
        
        elseif (_groupType == "PARTY") then
            if (UnitInParty(v.k)) then
                Name = v.k
                subgroup = "P"
                class, fileName = UnitClass(v.k)
            end
        end
        
        local roll
        if (v.v == 0) then
            roll = "|cFF00ccffpass|r"
        elseif (v.v > 0) then
            roll = v.v
        else
            roll = "|cFFFF0000" .. math.abs(v.v) .. "|r"
        end
        
        if (i > 1) then
            parentL = "$parent_FSL" .. tostring(i - 1)
            parentR = "$parent_FSR" .. tostring(i - 1)
        end
        local FS = getFS(i)
        FS.L:SetText(Name .. " (" .. RaidRolls_G.classColours[fileName] .. class .. "|r)[" .. RaidRolls_G.channelColours(_groupType) .. subgroup .. "|r]")
        FS.R:SetText(roll)
        FS.L:SetPoint("TOPLEFT", parentL, "BOTTOMLEFT")
        FS.R:SetPoint("TOPLEFT", parentR, "BOTTOMLEFT")
        
        i = i + 1
    end
    
    
    if (lootWarning) then
        if (i > 1) then parentL = "$parent_FSL" .. tostring(i - 1) end
        RaidRolls_MainFrame_LOOT:SetPoint("TOPLEFT", parentL, "BOTTOMLEFT")
        RaidRolls_MainFrame_LOOT:Show()
    else
        RaidRolls_MainFrame_LOOT:Hide()
    end
    
    
    local myLengthFSPool = myLength(RaidRolls_G.FSPool)
    while (i <= myLengthFSPool) do
        FS = getFS(i)
        FS.L:Hide()
        FS.R:Hide()
        i = i + 1
    end
end


-- Register / unregister events when joining / leaving a group.
local GroupJoin_EventFrame = CreateFrame("Frame")
GroupJoin_EventFrame:RegisterEvent("PARTY_MEMBERS_CHANGED")
GroupJoin_EventFrame:SetScript("OnEvent",
    function(self, event, ...)
        
        if (RaidRolls_G.groupTypeChanged()) then  -- Join or leave party/raid.
            
            if (RaidRolls_G.groupType() == nil) then  -- Just left.
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
    function(self, event, ...)
        RaidRolls_G.update()
    end)


-- Listen to the system messages and catch some of them.
-- Those being: rolling, leaving raid or party.
local ChatSystem_EventFrame = CreateFrame("Frame")
ChatSystem_EventFrame:SetScript("OnEvent",
    function(self, event, ...)
        if (RaidRolls_G.groupType() == nil) then return end
        
        local msg = select(1, ...)
        if msg then
            
            -- Roll message.
            if (string.find(msg, "rolls") ~= nil) then
                local name, roll, minRoll, maxRoll = msg:match("^(.+) rolls (%d+) %((%d+)%-(%d+)%)$")
                local minRoll = tonumber(minRoll)
                local maxRoll = tonumber(maxRoll)

                if not(name and minRoll == 1 and maxRoll == 100) then return end
                  
                if (RaidRolls_G.rollers[name] == nil) then
                    RaidRolls_G.rollers[name] = tonumber(roll)
                else
                    --~ rollers[name] = -math.max(math.abs(rollers[name]), roll)
                    RaidRolls_G.rollers[name] = -roll
                end
            
            -- Leave raid msg.
            elseif (string.find(msg, "has left the raid group.") ~= nil) then
                local name = msg:match("^(.+) has left the raid group.$")
                if name then
                    RaidRolls_G.rollers[name] = nil
                end
            
            -- Leave party msg.
            elseif (string.find(msg, "leaves the party.") ~= nil) then
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
    function(self, event, ...)
        
        if (RaidRolls_G.groupType() == nil) then return end
        
        local msg, name = ...
        if (string.lower(msg) == "pass") then
            RaidRolls_G.rollers[name] = 0
            RaidRolls_G.update()
        end
    end)


-- On Load 2. Saved variables (RaidRollsShown)
-- are loaded after OnLoad is run.
local Load_EventFrame = CreateFrame("Frame")
Load_EventFrame:RegisterEvent("ADDON_LOADED")
Load_EventFrame:SetScript("OnEvent",
    function(self, event, ...)
        if (event == "ADDON_LOADED" and ... == "RaidRolls") then
            
            if RaidRollsShown == nil then
                -- This is the first time this addon
                -- is loaded; initialize to true.
                RaidRollsShown = true;
            end
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
