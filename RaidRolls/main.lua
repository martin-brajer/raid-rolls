-- Global locals.
RaidRolls_G = {}
-- Table of event functions (namespace of `eventFunctions.lua`).
RaidRolls_G.eventFunctions = {}
-- Table of event frames and register functions(namespace of `eventFrames.lua`).
RaidRolls_G.eventFrames = {}
-- Configuration.
RaidRolls_G.config = {}

-- SAVED VARIABLES
RaidRollsShown = true -- Was the main frame shown at the end of the last session?

-- Table of rolling players.
RaidRolls_G.rollers = {}
-- Table of Frames and FontStrings.
RaidRolls_G.regions = {
    rowPool = {} -- Collection of {unit, roll} to be used to show data rows.
}
-- Was the player in group last time GROUP_ROSTER_UPDATE was invoked?
RaidRolls_G.wasInGroup = nil
local cfg = RaidRolls_G.config


function RaidRolls_OnAddonCompartmentClick()
    RaidRolls_G.show(not RaidRollsShown)
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
    elseif IsInGroup() then -- Any group type but raid == party.
        return "PARTY"
    end
    return "NOGROUP"
end

-- If player not found, return default values. E.g. when the player has already left the group.
local function getGroupMemberInfo(name, groupType)
    local subgroup, class, fileName, groupTypeUnit = "?", "unknown", "UNKNOWN", "NOGROUP" -- defaults

    if groupType == "RAID" then
        local _name, _subgroup, _class, _fileName -- Candidates.
        for i = 1, GetNumGroupMembers() do
            _name, _, _subgroup, _, _class, _fileName = GetRaidRosterInfo(i)
            if _name == name then
                subgroup, class, fileName = _subgroup, _class, _fileName
                groupTypeUnit = groupType
                break -- If not break, name stays and others get default values.
            end
        end
    elseif groupType == "PARTY" then
        if UnitInParty(name) then
            subgroup = cfg.texts.PARTY_LABEL
            class, fileName = UnitClass(name)
            groupTypeUnit = groupType
        end
    elseif name == UnitName("player") then -- Also groupType == "NOGROUP".
        class, fileName = UnitClass(name)
    end

    -- `class` is localized, `fileName` is a token.
    return name, subgroup, class, fileName, groupTypeUnit
end

--
function RaidRolls_G.updateRollers()
    local used_rows = 1
    -- Python notation: From dict(<name>: <roll>, ...) to sorted list(dict(name: <name>, roll: <roll>), ...)
    local sortedRollers = {}
    for name, roll in pairs(RaidRolls_G.rollers) do
        table.insert(sortedRollers, { name = name, roll = roll })
    end
    table.sort(sortedRollers, function(lhs, rhs)
        return math.abs(lhs.roll) > math.abs(rhs.roll)
    end)

    local groupType = groupType() -- Called here to avoid repetitively getting the same value.
    local row
    for _, roller in ipairs(sortedRollers) do
        local name, subgroup, class, fileName, groupTypeUnit = getGroupMemberInfo(roller.name, groupType)

        -- class
        local classColour = RAID_CLASS_COLORS[fileName]
        if classColour == nil then
            classColour = cfg.colors.UNKNOWN
        end
        local class_str = WrapTextInColor(class, classColour)
        -- subgroup
        local subgroup_str = WrapTextInColor(subgroup, cfg.colors[groupTypeUnit])
        -- roller
        local roller_roll = roller.roll
        local roll_str
        if roller_roll == 0 then
            roll_str = WrapTextInColor(cfg.texts.PASS, cfg.colors.PASS)
        elseif roller_roll < 0 then
            roll_str = WrapTextInColor(math.abs(roller_roll), cfg.colors.MULTIROLL)
        else
            roll_str = roller_roll
        end

        row = RaidRolls_G.getRow(used_rows)
        row.unit:SetText(name .. " (" .. class_str .. ")[" .. subgroup_str .. "]")
        row.roll:SetText(roll_str)

        used_rows = used_rows + 1
    end
    -- Here `used_rows` is set to the line following the last one used.
    return used_rows
end

-- Main drawing function.
function RaidRolls_G.update(lootWarningOnly)
    lootWarningOnly = lootWarningOnly or false

    local lootWarning
    do
        local lootMethod = GetLootMethod()
        lootWarning = UnitIsGroupLeader("player") and lootMethod ~= "master" and lootMethod ~= "personalloot"
    end

    do
        local numberOfRows = tableCount(RaidRolls_G.rollers) + (lootWarning and 1 or 0)
        RaidRolls_G.regions.mainFrame:SetHeight(30 + cfg.ROW_HEIGHT * numberOfRows) -- 30 = (5 + 15 + 10)
    end

    local i = 1 -- Defined outside the for loop, so the index `i` is kept for future use.
    if not lootWarningOnly then
        i = RaidRolls_G.updateRollers()
    end

    if lootWarning then
        RaidRolls_G.regions.lootWarning:SetPoint("TOPLEFT", RaidRolls_G.getRow(i - 1).unit, "BOTTOMLEFT")
        RaidRolls_G.regions.lootWarning:Show()
    else
        RaidRolls_G.regions.lootWarning:Hide()
    end

    -- Iterate over the rest of rows. Including the one (maybe) overlaid by lootWarning.
    while i <= tableCount(RaidRolls_G.regions.rowPool) do
        local row = RaidRolls_G.getRow(i)
        row.unit:Hide()
        row.roll:Hide()
        i = i + 1
    end
end
