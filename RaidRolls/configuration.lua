-- Configuration.
-- Populate `RaidRolls_G.configuration`.

local GroupType = RaidRolls_G.GroupType

--
RaidRolls_G.configuration.ADDON_NAME = "RaidRolls"

--
RaidRolls_G.configuration.size = {
    EMPTY_HEIGHT = 30, -- Header and border: 30 = (5 + 15 + 10)
    ROW_HEIGHT = 20,
    FRAME_WIDTH = 220, -- Default value.
}

-- All colors used as `ColorMixin`.
RaidRolls_G.configuration.colors = {}
local hexColors = {
    -- Group type
    [GroupType.NOGROUP] = "FFFFFF00", -- System message color
    [GroupType.PARTY] = "FFAAA7FF",
    [GroupType.RAID] = "FFFF7D00",
    -- GUI
    BACKGROUND = "B2333333", -- { 0.2, 0.2, 0.2, 0.7 } red, green, blue [, alpha]
    HEADER = "FFFFFF00",     -- { 1.0, 1.0, 0.0, 1.0 } red, green, blue [, alpha]
    MASTERLOOTER = "FFFF0000",
    MULTIROLL = "FFFF0000",
    PASS = "FF00CCFF",
    -- Misc.
    UNKNOWN = "FFFFFF00",   -- System message color
    SYSTEMMSG = "FFFFFF00", -- System message color
}
for k, v in pairs(hexColors) do
    RaidRolls_G.configuration.colors[k] = CreateColorFromHexString(v)
end

-- Texts
RaidRolls_G.configuration.texts = {
    -- General.

    LIST_CMDS = "Cmds: show, hide, toggle, help, reset, resize, test.",
    UNIT_HEADER = "Player (class)[subgroup]",
    ROLL_HEADER = "Roll",
    PASS = "pass",
    SET_MASTER_LOOTER = "Set MASTER LOOTER!!!",

    -- Labels belonging to `GroupType`s.

    NOGROUP_LABEL = "S",
    PARTY_LABEL = "P",
    -- RAID_LABEL = <subgroup number>,

    -- Errors. Used by `printError()`.

    RESIZE_SIZE_ERROR = "cannot resize below 100%.",
    RESIZE_PARAMETER_ERROR = "resize accepts either no argument or a number above 100.",
    TEST_PARAMETER_ERROR = "test accepts either 'fill', 'solo' or a plugin name.",
    SLASH_PARAMETER_ERROR = "unknown command. Run '/rr' for available commands.",

    -- Help lines.

    HELP_LINES = {
        "Slash Commands '/raidrolls' (or '/rr'):",
        "  none - Commands list.",
        "  'show' / 'hide' / 'toggle' - UI visibility.",
        "  'help' - Uroboros!",
        "  'reset' - Erase all rolls (same as right-clicking the window).",
        "  'resize <percentage>' - Change the width to <percentage> of default.",
        "  'test <tool>' - Tool can either be 'fill', 'solo' or <plugin name>.",
    },
}

-- Pairs of name and roll.
RaidRolls_G.configuration.testFill = {
    { "player1", 20 },
    { "player2", 0 },
    { "player3", 4 },
    { "player3", 99 }, -- repeated
}
