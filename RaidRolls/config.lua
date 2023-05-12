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
    PASS = "FF00ccff",
    -- Misc.
    UNKNOWN = "FFFFFF00",   -- System message color
    SYSTEMMSG = "FFFFFF00", -- System message color
}
local colorMixins = {}
for k, v in pairs(colors) do
    colorMixins[k] = CreateColorFromHexString(v)
end
RaidRolls_G.config.colors = colors -- to be changed to `colorMixins`
