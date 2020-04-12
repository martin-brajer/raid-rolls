local SystemMessageColour = "|cFFFFFF00"

-- From https://wow.gamepedia.com/Class_colors.
-- System message colour for unknown.
RaidRolls_G.classColours = {
["HUNTER"] = "|cFFABD473",
["WARLOCK"] = "|cFF8787ED",
["PRIEST"] = "|cFFFFFFFF",
["PALADIN"] = "|cFFF58CBA",
["MAGE"] = "|cFF40C7EB",
["ROGUE"] = "|cFFFFF569",
["DRUID"] = "|cFFFF7D0A",
["SHAMAN"] = "|cFF0070DE",
["WARRIOR"] = "|cFFC79C6E",
["DEATHKNIGHT"] = "|cFFC41F3B",
["MONK"] = "|cFF00FF96",
["DEMONHUNTER"] = "|cFFA330C9",
["UNKNOWN"] = SystemMessageColour,
};


-- Group channel colours.
local _channelColours = {
["RAID"] = "|cFFFF7D00",
["PARTY"] = "|cFFAAA7FF",
}
-- Function adds nil keyword.
function RaidRolls_G.channelColours(channel)
    -- System message colour (for unknown).
    if (channel == nil) then return SystemMessageColour end
    return _channelColours[channel]
end
