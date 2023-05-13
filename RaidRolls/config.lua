-- Configuration.

RaidRolls_G.config.ROW_HEIGHT = 20
RaidRolls_G.config.FRAME_WIDTH = 220 -- Default value.

-- All colors used..
local colors = {
    -- Group type
    NOGROUP = "FFFFFF00", -- System message color
    PARTY = "FFAAA7FF",
    RAID = "FFFF7D00",
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
local colorMixins = {}
for k, v in pairs(colors) do
    colorMixins[k] = CreateColorFromHexString(v)
end
RaidRolls_G.config.colors = colorMixins

-- Texts
RaidRolls_G.config.texts = {
    -- General.
    LIST_CMDS = "Cmds: show, hide, toggle, help, reset, resize, test.",
    UNIT_HEADER = "Player (class)[subgroup]",
    ROLL_HEADER = "Roll",
    PASS = "pass",
    SET_MASTER_LOOTER = "Set MASTER LOOTER!!!",
    -- RAID_LABEL = <subgroup number>,
    PARTY_LABEL = "P",
    NOGROUP_LABEL = "?",
    -- Errors.
    RESIZE_ERROR = "RaidRolls: Cannot resize below 100%.",
    TEST_PARAMETER_ERROR = "RaidRolls: Append either 'fill' or 'solo' parameter.",
    -- Help lines.
    HELP_LINES = {
        "Slash Commands '/raidrolls' (or '/rr'):",
        "  none - Commands list.",
        "  'show' / 'hide' / 'toggle' - UI visibility.",
        "  'help' - Uroboros!",
        "  'reset' - Erase all rolls (or right-click the window).",
        "  'resize <percentage>' - Change the width to <percentage> of default.",
        "  'test <tool>' - Choose: <fill> fills in test rolls, <solo> allows out of group use.",
    }
}
