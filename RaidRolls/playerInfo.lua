-- Aquiring info about single player.
-- Populate `RaidRolls_G.playerInfo`.

local cfg = RaidRolls_G.configuration
local GroupType = RaidRolls_G.GroupType


---Info about an individual player.
---@class PlayerInfo
---@field class string localized
---@field classFilename string token
---@field subgroup string
---@field groupTypeUnit GroupTypeEnum

-- If player not found, return default values. E.g. when the player has already left the group.
---@param groupType GroupTypeEnum addon user group status
---@return PlayerInfo
function RaidRolls_G.playerInfo.Get(self, name, groupType)
    -- defaults
    local playerInfo = self.New("unknown", "UNKNOWN",
        cfg.texts.NOGROUP_LABEL, GroupType.NOGROUP)

    if groupType == GroupType.RAID then
        for i = 1, MAX_RAID_MEMBERS do
            -- Raid member (RM) info.
            local playerNameRM, _, subgroupRM, _, classRM, classFilenameRM = GetRaidRosterInfo(i)
            local nameRM, server = strsplit("-", playerNameRM)
            if nameRM == name then
                playerInfo.class, playerInfo.classFilename = classRM, classFilenameRM
                playerInfo.subgroup = tostring(subgroupRM)
                playerInfo.groupTypeUnit = groupType
                break -- If not break, name stays and others get default values.
            end
        end
    --
    elseif groupType == GroupType.PARTY then
        if UnitInParty(name) then
            playerInfo.class, playerInfo.classFilename = UnitClass(name)
            playerInfo.subgroup = cfg.texts.PARTY_LABEL
            playerInfo.groupTypeUnit = groupType
        end
    --
    elseif name == UnitName("player") then -- This means testing
        -- Also `groupType == GroupType.NOGROUP`.
        playerInfo.class, playerInfo.classFilename = UnitClass(name)
    end

    return playerInfo
end

--
---@return PlayerInfo
function RaidRolls_G.playerInfo.New(class, classFilename, subgroup, groupTypeUnit)
    return {
        class = class,
        classFilename = classFilename,
        subgroup = subgroup,
        groupTypeUnit = groupTypeUnit,
    }
end
