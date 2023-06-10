-- Inject roller values for scrn purposes.
-- This plugin is used by adding it low in the required toc file.
-- Populate `scrnFill` as numbered part of `RaidRolls_G.plugins`.

-- `scrnFill` plugin namespace.
---@type Plugin
local scrnFill = {
    NAME = 'scrnFill',
}
table.insert(RaidRolls_G.plugins, scrnFill)

local cfg = RaidRolls_G.configuration
local GroupType = RaidRolls_G.GroupType
local playerInfoNew = RaidRolls_G.playerInfo.New

---Generic player roll data to be filled.
---@class RollData
---@field name string Batch name
---@field roll integer
---@field repeated boolean
---@field playerInfo PlayerInfo

---@type { [string]: RollData[] }
local rollDataDatabase = {
    -- Same as `/rr test fill`.
    defaultFill = {
        { "player3", 99, true,  playerInfoNew("unknown", "UNKNOWN", "S", GroupType.NOGROUP) },
        { "player1", 20, false, playerInfoNew("unknown", "UNKNOWN", "S", GroupType.NOGROUP) },
        { "player2", 0,  false, playerInfoNew("unknown", "UNKNOWN", "S", GroupType.NOGROUP) },
    },
    -- Random nonsense.
    test = {
        { "player1", 0,  false, playerInfoNew("wizard", "MAGE", "4", GroupType.PARTY) },
        { "player2", 20, true,  playerInfoNew("jlksgsgv", "BARD", "P", GroupType.RAID) },
        { "player3", 90, false, playerInfoNew("Ukam", "HUNTER", "S", GroupType.NOGROUP) },
    },
    -- Default behaviour for scrn.
    small = {
        { "Liùsaidh", 49, false, playerInfoNew("Warlock", "WARLOCK", "1", GroupType.RAID) },
        { "Thadeus",   34, true,  playerInfoNew("Druid", "DRUID", "S", GroupType.NOGROUP) },
        { "Feishue",   0,  false, playerInfoNew("Warrior", "WARRIOR", "2", GroupType.RAID) },
    },
    -- Simulating the real raid chaos. Can add master looter warning.
    raid = {
        { "Angwa",       99, true,  playerInfoNew("Hunter", "HUNTER", "3", GroupType.RAID) },
        { "Enaid",       95, false, playerInfoNew("Priest", "PRIEST", "5", GroupType.RAID) },
        { "Monaëraëh", 88, false, playerInfoNew("Paladin", "PALADIN", "1", GroupType.RAID) },
        { "Haliastur",   58, true,  playerInfoNew("Monk", "MONK", "7", GroupType.RAID) },
        { "Mandorallen", 42, false, playerInfoNew("Paladin", "PALADIN", "5", GroupType.RAID) },
        { "Thadeus",     34, false, playerInfoNew("Druid", "DRUID", "S", GroupType.NOGROUP) },
        { "Malephar",    13, false, playerInfoNew("Demon Hunter", "DEMONHUNTER", "4", GroupType.RAID) },
        { "Tesni",       7,  false, playerInfoNew("Mage", "MAGE", "5", GroupType.RAID) },
        { "Tarneil",     0,  false, playerInfoNew("Hunter", "HUNTER", "4", GroupType.RAID) },
        { "Gwyrddlass",  0,  true,  playerInfoNew("Evoker", "EVOKER", "S", GroupType.NOGROUP) },
    },
}

--
function scrnFill.Initialize(self, mainFrame, relativePoint)
    return relativePoint
end

--
function scrnFill.Draw(self, relativePoint)
    return 0, relativePoint
end

-- Circumvent `rollerCollection:Save` and fill more generic data.
---@param rollDataBatch RollData[]
local function FillRollers(rollDataBatch)
    for _, rollData in ipairs(rollDataBatch) do
        local name, roll, repeated, playerInfo = unpack(rollData)
        local roller = RaidRolls_G.roller.New(name, roll, playerInfo)
        if repeated then
            roller:UpdateRoll(roll)
        end
        table.insert(RaidRolls_G.rollerCollection.values, roller)
    end
end

--
function scrnFill.SlashCmd(self, args)
    local rollDataBatch = rollDataDatabase[args] or rollDataDatabase.test -- default
    FillRollers(rollDataBatch)
    RaidRolls_G:Draw()
end
