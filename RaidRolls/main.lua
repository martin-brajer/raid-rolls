-- Main file. Info and globals.

-- Global locals (this addon's global namespace).
RaidRolls_G = {}
-- `eventFunctions.lua` namespace.
RaidRolls_G.eventFunctions = {}
-- `eventFrames.lua` namespace.
RaidRolls_G.eventFrames = {}
-- `configuration.lua` namespace.
RaidRolls_G.configuration = {}
-- `gui.lua` namespace.
RaidRolls_G.gui = {}
-- Container for plugin namespaces.
RaidRolls_G.plugins = {}

-- SAVED VARIABLES: `RaidRollsShown`
-- Was the main frame shown at the end of the last session?
-- Initialized in `RaidRolls_G.eventFunctions.OnLoad`.

-- Table of rolling players.
RaidRolls_G.rollers = {}
-- Was the player in group last time GROUP_ROSTER_UPDATE was invoked?
RaidRolls_G.wasInGroup = nil
local GroupType = {
    NOGROUP = "NOGROUP",
    PARTY = "PARTY",
    RAID = "RAID",
}
local cfg = RaidRolls_G.configuration


function RaidRolls_OnAddonCompartmentClick()
    RaidRolls_G.gui:SetVisibility(not RaidRollsShown)
end

-- Table length (no need to be a sequence).
function RaidRolls_G.TableCount(t)
    local count = 0
    for _ in pairs(t) do count = count + 1 end
    return count
end

-- Find what kind of group the player (addon user) is in.
local function GetGroupType()
    if IsInRaid() then
        return GroupType.RAID
    elseif IsInGroup() then -- Any group type but raid == party.
        return GroupType.PARTY
    end
    return GroupType.NOGROUP
end

-- If player not found, return default values. E.g. when the player has already left the group.
local function GetGroupMemberInfo(name, groupType)
    local subgroup, class, fileName, groupTypeUnit = "?", "unknown", "UNKNOWN", GroupType.NOGROUP -- defaults

    if groupType == GroupType.RAID then
        local _name, _subgroup, _class, _fileName -- Candidates.
        for i = 1, GetNumGroupMembers() do
            _name, _, _subgroup, _, _class, _fileName = GetRaidRosterInfo(i)
            if _name == name then
                subgroup, class, fileName = _subgroup, _class, _fileName
                groupTypeUnit = groupType
                break -- If not break, name stays and others get default values.
            end
        end
    elseif groupType == GroupType.PARTY then
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
function RaidRolls_G.RollersDraw()
    local currentRow = 0

    -- Python notation: From dict(<name>: <roll>, ...) to sorted list(dict(name: <name>, roll: <roll>), ...)
    local sortedRollers = {}
    for name, roll in pairs(RaidRolls_G.rollers) do
        table.insert(sortedRollers, { name = name, roll = roll })
    end
    table.sort(sortedRollers, function(lhs, rhs)
        return math.abs(lhs.roll) > math.abs(rhs.roll)
    end)

    local groupType = GetGroupType() -- Called here to avoid repetitively getting the same value.
    for rowIndex, roller in ipairs(sortedRollers) do
        local name, subgroup, class, fileName, groupTypeUnit = GetGroupMemberInfo(roller.name, groupType)

        -- class
        local classColour = RAID_CLASS_COLORS[fileName]
        if classColour == nil then
            classColour = cfg.colors.UNKNOWN
        end
        local classText = WrapTextInColor(class, classColour)
        -- subgroup
        local subgroupText = WrapTextInColor(subgroup, cfg.colors[groupTypeUnit])
        -- roller
        local roll = roller.roll
        local rollText
        if roll == 0 then
            rollText = WrapTextInColor(cfg.texts.PASS, cfg.colors.PASS)
        elseif roll < 0 then
            rollText = WrapTextInColor(math.abs(roll), cfg.colors.MULTIROLL)
        else
            rollText = roll
        end

        local unitText = name .. " (" .. classText .. ")[" .. subgroupText .. "]"
        RaidRolls_G.gui:WriteRow(rowIndex, unitText, rollText)

        currentRow = rowIndex
    end

    -- Hide the rest of the rows.
    RaidRolls_G.gui:HideRowsTail(currentRow + 1)

    -- Here `current_row` points to the line following the last one record.
    return currentRow
end

-- Now Draw AND Update -> split.
function RaidRolls_G.Update()
    RaidRolls_G.Draw()
end

-- Main drawing function.
function RaidRolls_G.Draw()
    -- Start at 0 for header.
    local currentRow = 0

    -- Fetch data, fill, sort, write.
    currentRow = currentRow + RaidRolls_G.RollersDraw()

    -- Plugins draw.
    for name, plugin in pairs(RaidRolls_G.plugins) do
        currentRow = currentRow + plugin:Draw(currentRow)
    end

    RaidRolls_G.gui:SetHeight(30 + cfg.ROW_HEIGHT * (currentRow)) -- 30 = (5 + 15 + 10)
end
