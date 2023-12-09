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

-- If player not found, return default values. E.g. when the player has already left the group.
---@param groupType GroupTypeEnum addon user group status
---@return PlayerInfo
function RaidRolls_G.playerInfo.Get(self, name, groupType)
    if groupType == GroupType.RAID then
        for i = 1, MAX_RAID_MEMBERS do
            local nameServerIter, _, subgroup, _, class, classFilename = GetRaidRosterInfo(i)
            if nameServerIter ~= nil then
                local nameIter, server = strsplit("-", nameServerIter)
                if nameIter == name then
                    return self.New(class, classFilename, tostring(subgroup), GroupType.RAID)
                end
            end
        end
    --
    elseif groupType == GroupType.PARTY then
        if UnitInParty(name) then
            local class, classFilename = UnitClass(name)
            return self.New(class, classFilename, cfg.texts.PARTY_LABEL, GroupType.PARTY)
        end
    --
    elseif name == UnitName("player") then -- This means testing
        -- Also `groupType == GroupType.NOGROUP`.
        local class, classFilename = UnitClass(name)
        return self.New(class, classFilename, cfg.texts.NOGROUP_LABEL, GroupType.NOGROUP)
    end

    -- defaults
    return self.New("unknown", "UNKNOWN", cfg.texts.NOGROUP_LABEL, GroupType.NOGROUP)
end
