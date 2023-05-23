-- Collection of players who /rolled.
-- Populate `RaidRolls_G.rollerCollection`.

local cfg = RaidRolls_G.configuration
local GroupType = RaidRolls_G.GroupType

-- Array of player rolls `{ roller }` created by `RaidRolls_G.roller:New()`.
-- `roller = { name, classText, subgroup, unitChanged, roll, repeated, rollChanged }`.
RaidRolls_G.rollerCollection.values = {}
-- Are rollers `self.values` to be sorted during the next `Draw`?
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
-- Parameter `groupType` is addon user group status.
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

--
local function MakeClassText(class, classFilename)
    local classColour
    local classColourMixin = RAID_CLASS_COLORS[classFilename]
    if classColourMixin == nil then
        classColour = cfg.colors.UNKNOWN
    else
        classColour = classColourMixin.colorStr
    end
    return WrapTextInColorCode(class, classColour)
end

--
local function MakeUnitText(name, classText, subgroup, groupTypeUnit)
    local subgroupText = WrapTextInColorCode(subgroup, cfg.colors[groupTypeUnit])
    return ("%s (%s)[%s]"):format(name, classText, subgroupText)
end

--
local function MakeRollText(roll, repeated)
    if roll == 0 then
        return WrapTextInColorCode(cfg.texts.PASS, cfg.colors.PASS)
    elseif repeated then
        return WrapTextInColorCode(roll, cfg.colors.MULTIROLL)
    else
        return tostring(roll)
    end
end

-- On GROUP_ROSTER_UPDATE through `RaidRolls_G.eventFunctions.OnGroupUpdate`.
function RaidRolls_G.rollerCollection.OnGroupUpdate(self)
    local groupType = GetGroupType()

    for _, roller in ipairs(self.values) do
        local _, _, subgroup, groupTypeUnit = GetPlayerInfo(roller.name, groupType)
        -- Raid subgroup number or group type changed.
        if roller.subgroup ~= subgroup then
            roller.subgroup = subgroup
            roller.groupTypeUnit = groupTypeUnit
            roller.unitChanged = true
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
        local unitText = nil
        if orderChanged or roller.unitChanged then
            unitText = MakeUnitText(roller.name, roller.classText, roller.subgroup, roller.groupTypeUnit)
            roller.unitChanged = false
        end

        local rollText = nil
        if orderChanged or roller.rollChanged then
            rollText = MakeRollText(roller.roll, roller.repeated)
            roller.rollChanged = false
        end

        RaidRolls_G.gui:WriteRow(index, unitText, rollText)
        currentRow = index
    end

    -- Hide unused rows.
    RaidRolls_G.gui:HideTailRows(currentRow + 1)

    return currentRow, RaidRolls_G.gui:GetRow(currentRow).unit
end

function RaidRolls_G.rollerCollection.Save(self, name, roll)
    local playerFound = false
    for _, roller in ipairs(self.values) do
        if name == roller.name then
            playerFound = true

            -- Update exiting player.
            roller.repeated = true
            roller.roll = roll
            roller.rollChanged = true
            break
        end
    end
    if not playerFound then
        -- Add new roller.
        local class, classFilename, subgroup, groupTypeUnit = GetPlayerInfo(name, GetGroupType())
        local classText = MakeClassText(class, classFilename)
        table.insert(self.values, {
            name = name,
            classText = classText,
            subgroup = subgroup,
            groupTypeUnit = groupTypeUnit,
            unitChanged = true,
            roll = roll,
            repeated = false,
            rollChanged = true,
        })
    end

    self.isSorted = false
end

function RaidRolls_G.rollerCollection.Fill(self)
    self:Save("player1", 20)
    self:Save("player2", 0)
    self:Save("player3", 4)
    self:Save("player3", 99) -- repeated
end

function RaidRolls_G.rollerCollection.Clear(self)
    self.values = {}
end
