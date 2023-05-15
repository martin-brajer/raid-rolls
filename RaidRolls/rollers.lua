-- Array of player who /rolled.
-- Populate `RaidRolls_G.rollers` namespace.

local cfg = RaidRolls_G.configuration

-- Array of player rolls { playerRoll }
-- playerRoll = { name, classText, subgroup, unitText, roll, repeated, rollText, changed }
RaidRolls_G.rollers.values = {}

-- On GROUP_ROSTER_UPDATE may `subgroup` be changed. Ignore the rest.
function RaidRolls_G.rollers.Update(self)
    -- on subgroup changed
    -- update subgroup
    -- always for now
end

local GroupType = {
    NOGROUP = "NOGROUP",
    PARTY = "PARTY",
    RAID = "RAID",
}

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
local function MakeUnitText(name, subgroup, class, fileName, groupTypeUnit)
    -- class
    local classColour = RAID_CLASS_COLORS[fileName]
    if classColour == nil then
        classColour = cfg.colors.UNKNOWN
    end
    local classText = WrapTextInColor(class, classColour)

    -- subgroup
    local subgroupText = WrapTextInColor(subgroup, cfg.colors[groupTypeUnit])

    return name .. " (" .. classText .. ")[" .. subgroupText .. "]"
end

-- Data to string.
local function MakeRollText(roll, repeated)
    local rollText
    if roll == 0 then
        rollText = WrapTextInColor(cfg.texts.PASS, cfg.colors.PASS)
    elseif repeated then
        rollText = WrapTextInColor(roll, cfg.colors.MULTIROLL)
    else
        rollText = roll
    end

    return rollText
end

-- Redraw `unitText` of the roller who changed group (or left). Maybe all after group type change.
-- Redraw `RollText` of all rollers and reorder (new roller or new roll).
function RaidRolls_G.rollers.Draw(self)
    local currentRow = 0

    table.sort(self.values, function(lhs, rhs)
        return lhs.roll > rhs.roll
    end)
    local groupType = GetGroupType()

    for rowIndex, playerRoll in ipairs(self.values) do
        local name, subgroup, class, classFilename, groupTypeUnit = GetPlayerInfo(playerRoll.name, groupType)

        playerRoll.unitText = MakeUnitText(name, subgroup, class, classFilename, groupTypeUnit)
        playerRoll.rollText = MakeRollText(playerRoll.roll, playerRoll.repeated)

        RaidRolls_G.gui:WriteRow(rowIndex, playerRoll.unitText, playerRoll.rollText)

        currentRow = rowIndex
    end

    -- Hide the rest of the rows.
    RaidRolls_G.gui:HideRowsTail(currentRow + 1)

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
            -- update rollText
        end
    end
    if not playerFound then
        -- Add new playerRoll.
        local _, subgroup, class, classFilename, groupTypeUnit = GetPlayerInfo(name, GetGroupType())
        table.insert(self.values, {
            name = name,
            roll = roll,
            repeated = false,
            subgroup = subgroup,
            classText = "",
            unitText = "",
            rollText = "",
            changed = true,
        })
        -- update unitText
        -- update rollText
    end
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
