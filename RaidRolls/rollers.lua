-- Array of player who /rolled.
-- Populate `RaidRolls_G.rollers` namespace.

local cfg = RaidRolls_G.configuration
local GroupType = RaidRolls_G.GroupType

-- Array of player rolls { playerRoll }
-- playerRoll = { name, classText, subgroup, unitChanged, roll, repeated, rollChanged }
RaidRolls_G.rollers.values = {}
-- Is to be sorted during the next `Draw`?
RaidRolls_G.rollers.isSorted = false


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
        local _name, _subgroup, _class, _classFilename -- Candidates.
        for i = 1, GetNumGroupMembers() do
            _name, _, _subgroup, _, _class, _classFilename = GetRaidRosterInfo(i)
            if _name == name then
                class, classFilename = _class, _classFilename
                subgroup = tostring(_subgroup)
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
    elseif name == UnitName("player") then -- Also groupType == "NOGROUP".
        class, classFilename = UnitClass(name)
    end

    -- `class` is localized, `classFilename` is a token.
    return class, classFilename, subgroup, groupTypeUnit
end

--
local function MakeClassText(class, classFilename)
    local classColour = RAID_CLASS_COLORS[classFilename]
    if classColour == nil then
        classColour = cfg.colors.UNKNOWN
    end
    return WrapTextInColor(class, classColour)
end

--
local function MakeUnitText(name, classText, subgroup, groupTypeUnit)
    local subgroupText = WrapTextInColor(subgroup, cfg.colors[groupTypeUnit])
    return name .. " (" .. classText .. ")[" .. subgroupText .. "]"
end

--
local function MakeRollText(roll, repeated)
    if roll == 0 then
        return WrapTextInColor(cfg.texts.PASS, cfg.colors.PASS)
    elseif repeated then
        return WrapTextInColor(roll, cfg.colors.MULTIROLL)
    else
        return tostring(roll)
    end
end

-- On GROUP_ROSTER_UPDATE through `RaidRolls_G.eventFunctions.OnGroupUpdate`.
function RaidRolls_G.rollers.OnGroupUpdate(self)
    local groupType = GetGroupType()

    for _, playerRoll in ipairs(self.values) do
        local _, _, subgroup, groupTypeUnit = GetPlayerInfo(playerRoll.name, groupType)
        -- Raid subgroup number or group type changed.
        if playerRoll.subgroup ~= subgroup then
            playerRoll.subgroup = subgroup
            -- if `groupTypeUnit` changes, `subgroup` must change as well (no need to separate check).
            playerRoll.groupTypeUnit = groupTypeUnit
            playerRoll.unitChanged = true
        end
    end
end

-- Redraw `unitText` of the roller who changed group (or left). Maybe all after group type change.
-- Redraw `RollText` of all rollers and reorder (new roller or new roll).
function RaidRolls_G.rollers.Draw(self)
    local currentRow = 0
    local orderChanged = false

    if not self.isSorted then
        table.sort(self.values, function(lhs, rhs)
            return lhs.roll > rhs.roll
        end)

        orderChanged = true
        self.isSorted = true
    end

    for index, playerRoll in ipairs(self.values) do
        local unitText = nil
        if orderChanged or playerRoll.unitChanged then
            unitText = MakeUnitText(playerRoll.name, playerRoll.classText, playerRoll.subgroup, playerRoll.groupTypeUnit)
            playerRoll.unitChanged = false
        end

        local rollText = nil
        if orderChanged or playerRoll.rollChanged then
            rollText = MakeRollText(playerRoll.roll, playerRoll.repeated)
            playerRoll.rollChanged = false
        end

        RaidRolls_G.gui:WriteRow(index, unitText, rollText)

        currentRow = index
    end

    -- Hide the rest of the rows.
    RaidRolls_G.gui:HideTailRows(currentRow + 1)

    -- Here `current_row` points to the line following the last one record.
    return currentRow
end

function RaidRolls_G.rollers.Save(self, name, roll)
    local playerFound = false
    for _, playerRoll in ipairs(self.values) do
        if name == playerRoll.name then
            playerFound = true

            -- Update exiting player.
            playerRoll.repeated = true
            playerRoll.roll = roll
            playerRoll.rollChanged = true
            break
        end
    end
    if not playerFound then
        -- Add new playerRoll.
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

function RaidRolls_G.rollers.Fill(self)
    self:Save("player1", 20)
    self:Save("player2", 0)
    self:Save("player3", 4)
    self:Save("player3", 99) -- repeated
end

function RaidRolls_G.rollers.Clear(self)
    self.values = {}
end
