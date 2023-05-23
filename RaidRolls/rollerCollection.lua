-- Collection of players who /rolled.
-- Populate `RaidRolls_G.rollerCollection`.

local cfg = RaidRolls_G.configuration
local GroupType = RaidRolls_G.GroupType

-- Array of player rolls.
---@type Roller[]
RaidRolls_G.rollerCollection.values = {}
-- Are `self.values` rollers to be sorted during the next `Draw`?
RaidRolls_G.rollerCollection.isSorted = false


-- Find what kind of group is the current player in.
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
---@param groupType GroupTypeEnum addon user group status
local function GetPlayerInfo(name, groupType)
    -- defaults
    local class, classFilename = "unknown", "UNKNOWN"
    local subgroup, groupTypeUnit = cfg.texts.NOGROUP_LABEL, GroupType.NOGROUP

    if groupType == GroupType.RAID then
        for i = 1, MAX_RAID_MEMBERS do
            -- Raid member (RM) info.
            local nameRM, _, subgroupRM, _, classRM, classFilenameRM = GetRaidRosterInfo(i)
            if nameRM == name then
                class, classFilename = classRM, classFilenameRM
                subgroup = tostring(subgroupRM)
                groupTypeUnit = groupType
                break -- If not break, name stays and others get default values.
            end
        end
    elseif groupType == GroupType.PARTY then
        if UnitInParty(name) then
            class, classFilename = UnitClass(name)
            subgroup = cfg.texts.PARTY_LABEL
            groupTypeUnit = groupType
        end
    elseif name == UnitName("player") then -- This means testing
        -- Also `groupType == GroupType.NOGROUP`.
        class, classFilename = UnitClass(name)
    end

    -- `class` is localized, `classFilename` is a token.
    return class, classFilename, subgroup, groupTypeUnit
end

-- On GROUP_ROSTER_UPDATE through `RaidRolls_G.eventFunctions.OnGroupUpdate`.
function RaidRolls_G.rollerCollection.OnGroupUpdate(self)
    local groupType = GetGroupType()

    for _, roller in ipairs(self.values) do
        local _, _, subgroup, groupTypeUnit = GetPlayerInfo(roller.name, groupType)
        if roller.subgroup ~= subgroup then -- Raid subgroup number or group type changed.
            roller:UpdateGroup(subgroup, groupTypeUnit)
        end
    end
end

-- Redraw `unitText` of the roller who changed group (or left). Maybe all after group type change.
-- Redraw `RollText` of all rollers and reorder (new roller or new roll).
function RaidRolls_G.rollerCollection.Draw(self)
    local currentRow = 0
    local orderChanged = false

    if not self.isSorted then
        table.sort(self.values, function(lhs, rhs)
            return lhs.roll > rhs.roll
        end)

        orderChanged = true
        self.isSorted = true
    end

    for index, roller in ipairs(self.values) do
        -- unit
        local unitText = nil
        if orderChanged or roller.unitChanged then
            unitText = roller:MakeUnitText()
            roller.unitChanged = false
        end
        -- roll
        local rollText = nil
        if orderChanged or roller.rollChanged then
            rollText = roller:MakeRollText()
            roller.rollChanged = false
        end
        -- write
        RaidRolls_G.gui:WriteRow(index, unitText, rollText)
        currentRow = index
    end

    -- Hide unused rows.
    RaidRolls_G.gui:HideTailRows(currentRow + 1)

    return currentRow, RaidRolls_G.gui:GetRow(currentRow).unit
end

--
function RaidRolls_G.rollerCollection.Save(self, name, roll)
    local playerFound = false
    for _, roller in ipairs(self.values) do
        if name == roller.name then -- Update exiting player.
            playerFound = true
            roller:UpdateRoll(roll)
            break
        end
    end
    if not playerFound then -- Add new roller.
        local class, classFilename, subgroup, groupTypeUnit = GetPlayerInfo(name, GetGroupType())
        local roller = RaidRolls_G.roller.New(name, roll, class, classFilename, subgroup, groupTypeUnit)
        table.insert(self.values, roller)
    end

    self.isSorted = false
end

--
function RaidRolls_G.rollerCollection.Fill(self)
    for _, val in pairs(cfg.testFill) do
        self:Save(unpack(val))
    end
end

--
function RaidRolls_G.rollerCollection.Clear(self)
    self.values = {}
end
