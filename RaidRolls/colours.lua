-- System message colour for unknown.
local SystemMessageColour = "|cFFFFFF00"

-- Colours from https://wow.gamepedia.com/Class_colors.
-- Keys are the system representation of the character's class:
-- always in english, always fully capitalized, usually called `fileName`.
RaidRolls_G.classColours = {
    HUNTER = "|cFFABD473",
    WARLOCK = "|cFF8787ED",
    PRIEST = "|cFFFFFFFF",
    PALADIN = "|cFFF58CBA",
    MAGE = "|cFF40C7EB",
    ROGUE = "|cFFFFF569",
    DRUID = "|cFFFF7D0A",
    SHAMAN = "|cFF0070DE",
    WARRIOR = "|cFFC79C6E",
    DEATHKNIGHT = "|cFFC41F3B",
    MONK = "|cFF00FF96",
    DEMONHUNTER = "|cFFA330C9",
    UNKNOWN = SystemMessageColour,
};

RaidRolls_G.channelColours = {
    RAID = "|cFFFF7D00",
    PARTY = "|cFFAAA7FF",
    NOGROUP = SystemMessageColour,
}

RaidRolls_G.textColours = {
    PASS = "|cFF00ccff",
    MULTIROLL = "|cFFFF0000",
    MASTERLOOTER = "|cFFFF0000",
}
