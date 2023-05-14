-- Array of player who /rolled.
-- Populate `RaidRolls_G.rollers` namespace.

local cfg = RaidRolls_G.configuration

-- Array of player rolls { name = { name, roll, repeated, subgroup, unitText, rollText } }
RaidRolls_G.rollers.values = {}

-- function RaidRolls_G.rollers.save(self, name, value)
--     if value == "pass" then
--         value = 0
--     end
--     if self.values[name] == nil then
--         local playerRoll = { name, value, false }
--     else
--         --
--     end
-- end

local GroupType = {
    NOGROUP = "NOGROUP",
    PARTY = "PARTY",
    RAID = "RAID",
}

-- Find what kind of group the current player is in.
local function GetGroupType()
    if IsInRaid() then
        return GroupType.RAID
    elseif IsInGroup() then -- Any group type but raid => party.
        return GroupType.PARTY
    else
        return GroupType.NOGROUP
    end
end

-- Name to data.
-- If player not found, return default values. E.g. when the player has already left the group.
local function GetPlayerInfo(name, groupType)
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

-- Data to string.
local function MakeText(name, subgroup, class, fileName, groupTypeUnit, roll)
    -- class
    local classColour = RAID_CLASS_COLORS[fileName]
    if classColour == nil then
        classColour = cfg.colors.UNKNOWN
    end
    local classText = WrapTextInColor(class, classColour)
    -- subgroup
    local subgroupText = WrapTextInColor(subgroup, cfg.colors[groupTypeUnit])
    -- roller
    local rollText
    if roll == 0 then
        rollText = WrapTextInColor(cfg.texts.PASS, cfg.colors.PASS)
    elseif roll < 0 then
        rollText = WrapTextInColor(math.abs(roll), cfg.colors.MULTIROLL)
    else
        rollText = roll
    end

    local unitText = name .. " (" .. classText .. ")[" .. subgroupText .. "]"
    return unitText, rollText
end

-- Python notation: From dict(<name>: <roll>, ...) to sorted list(dict(name: <name>, roll: <roll>), ...)
local function GetSortedRollers(values)
    local sortedRollers = {}
    for name, roll in pairs(values) do
        table.insert(sortedRollers, { name = name, roll = roll })
    end
    table.sort(sortedRollers, function(lhs, rhs)
        return math.abs(lhs.roll) > math.abs(rhs.roll)
    end)
    return sortedRollers
end

--
function RaidRolls_G.rollers.Draw(self)
    local currentRow = 0
    local sortedRollers = GetSortedRollers(self.values)
    local groupType = GetGroupType() -- Called here to avoid repetitively getting the same value.

    for rowIndex, roller in ipairs(sortedRollers) do
        local name, subgroup, class, fileName, groupTypeUnit = GetPlayerInfo(roller.name, groupType)

        local unitText, rollText = MakeText(name, subgroup, class, fileName, groupTypeUnit, roller.roll)
        RaidRolls_G.gui:WriteRow(rowIndex, unitText, rollText)

        currentRow = rowIndex
    end

    -- Hide the rest of the rows.
    RaidRolls_G.gui:HideRowsTail(currentRow + 1)

    -- Here `current_row` points to the line following the last one record.
    return currentRow
end

function RaidRolls_G.rollers.Save(self, name, value)
    if (self.values[name] ~= nil) and (value ~= 0) then
        value = -value -- Minus to mark multiroll.
    end

    self.values[name] = value
end

function RaidRolls_G.rollers.Fill(self)
    self.values = {
        player1 = 20,
        player2 = 0,
        player3 = -99,
    }
end

function RaidRolls_G.rollers.Clear(self)
    self.values = {}
end
