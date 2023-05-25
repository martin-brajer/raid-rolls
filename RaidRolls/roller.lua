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
---@field MakeUnitText function
---@field MakeRollText function


-- Methods of the roller "instance".
local methods = {}

-- Update roll and set connected flags.
function methods.UpdateRoll(self, roll)
    self.repeated = true
    self.roll = roll
    self.rollChanged = true
end

-- Update raid subgroup or group state.
function methods.UpdateGroup(self, subgroup, groupTypeUnit)
    self.subgroup = subgroup
    self.groupTypeUnit = groupTypeUnit
    self.unitChanged = true
end

--
function methods.MakeUnitText(self)
    local subgroupText = WrapTextInColorCode(self.subgroup, cfg.colors[self.groupTypeUnit])
    return ("%s (%s)[%s]"):format(self.name, self.classText, subgroupText)
end

--
function methods.MakeRollText(self)
    if self.roll == 0 then
        return WrapTextInColorCode(cfg.texts.PASS, cfg.colors.PASS)
    elseif self.repeated then
        return WrapTextInColorCode(self.roll, cfg.colors.MULTIROLL)
    else
        return tostring(self.roll)
    end
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

---Create new "instance" of the Roller.
---@param name string
---@param roll number
---@param class string
---@param classFilename string
---@param subgroup string
---@param groupTypeUnit string
---@return Roller
function RaidRolls_G.roller.New(name, roll, class, classFilename, subgroup, groupTypeUnit)
    local classText = MakeClassText(class, classFilename)
    -- Add fields.
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
    -- Add methods.
    for funcName, func in pairs(methods) do
        roller[funcName] = func
    end

    return roller
end
