-- Collection of players who /rolled.
-- Populate `RaidRolls_G.rollerCollection`.

local cfg = RaidRolls_G.configuration

-- Array of player rolls.
---@type Roller[]
RaidRolls_G.rollerCollection.values = {}
-- Are `self.values` rollers to be sorted during the next `Draw`?
RaidRolls_G.rollerCollection.isSorted = false


-- On GROUP_ROSTER_UPDATE through `RaidRolls_G.eventFunctions.OnGroupUpdate`.
function RaidRolls_G.rollerCollection.UpdateGroup(self)
    local groupType = RaidRolls_G:GetGroupType()

    for _, roller in ipairs(self.values) do
        local playerInfo = RaidRolls_G.playerInfo:Get(roller.name, groupType)
        if roller.subgroup ~= playerInfo.subgroup then -- Raid subgroup number or group type changed.
            roller:UpdateGroup(playerInfo.subgroup, playerInfo.groupTypeUnit)
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
---@return Roller? plugin Instance or nil if not found.
function RaidRolls_G.rollerCollection.FindRoller(self, name)
    for _, roller in ipairs(self.values) do
        if name == roller.name then
            return roller
        end
    end
    return nil
end

-- Update `roller` (if exists) or create a new one.
function RaidRolls_G.rollerCollection.Save(self, name, roll)
    local roller = self:FindRoller(name)
    if roller ~= nil then
        roller:UpdateRoll(roll)
    else
        local groupType = RaidRolls_G:GetGroupType()
        local playerInfo = RaidRolls_G.playerInfo:Get(name, groupType)
        roller = RaidRolls_G.roller.New(name, roll, playerInfo)
        table.insert(self.values, roller)
    end
    self.isSorted = false
end

-- Fill test values.
function RaidRolls_G.rollerCollection.Fill(self)
    for _, val in pairs(cfg.testFill) do
        self:Save(unpack(val))
    end
end

--
function RaidRolls_G.rollerCollection.Clear(self)
    self.values = {}
end
