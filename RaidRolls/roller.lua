-- Store info about individual rollers.
-- `roller = { name, classText, subgroup, unitChanged, roll, repeated, rollChanged }`.
-- Populate `RaidRolls_G.rollerCollection`.

local cfg = RaidRolls_G.configuration

---Info about an individual roller. Create by `RaidRolls_G.roller:New()`.
---@class Roller
---@field name string full name (will include server)
---@field classText string
---@field subgroup string
---@field groupTypeUnit string
---@field unitChanged boolean has unit info changed since the last draw?
---@field roll number
---@field repeated boolean has the player rolled multiple times?
---@field rollChanged boolean has the roll changed since the last draw?
---@field UpdateRoll function
---@field UpdateGroup function

---Create new "instance" of the Roller.
---@param self table
---@param name string
---@param classText string
---@param subgroup string
---@param groupTypeUnit string
---@param roll number
---@return Roller
function RaidRolls_G.roller.New(self, name, classText, subgroup, groupTypeUnit, roll)
    local roller = {
        name = name,
        classText = classText,
        subgroup = subgroup,
        groupTypeUnit = groupTypeUnit,
        unitChanged = true,
        roll = roll,
        repeated = false,
        rollChanged = true,
    }
    roller.UpdateRoll = self.UpdateRoll
    roller.UpdateGroup = self.UpdateGroup
    return roller
end

---Update roll and set connected flags.
---@param self Roller
---@param roll number
function RaidRolls_G.roller.UpdateRoll(self, roll)
    self.repeated = true
    self.roll = roll
    self.rollChanged = true
end

---Update raid subgroup or group state.
---@param self Roller
---@param subgroup string
---@param groupTypeUnit string
function RaidRolls_G.roller.UpdateGroup(self, subgroup, groupTypeUnit)
    self.subgroup = subgroup
    self.groupTypeUnit = groupTypeUnit
    self.unitChanged = true
end
