-- Main file. Info and globals.
-- Globals: `RaidRolls_G`, `RaidRollsShown`, `RaidRolls_OnAddonCompartmentClick`

-- Global locals (this addon's global namespace).
RaidRolls_G = {}
-- `eventFunctions.lua` namespace.
RaidRolls_G.eventFunctions = {}
-- `eventFrames.lua` namespace.
RaidRolls_G.eventFrames = {}
-- `configuration.lua` namespace.
RaidRolls_G.configuration = {}
-- `gui.lua` namespace.
RaidRolls_G.gui = {}
-- `rollerCollection.lua` namespace.
RaidRolls_G.rollerCollection = {}
-- `roller.lua` namespace. Start by calling `New()`.
RaidRolls_G.roller = {}
-- `playerInfo.lua` namespace.
RaidRolls_G.playerInfo = {}
-- Container for plugin namespaces.
---@type Plugin[]
RaidRolls_G.plugins = {}

---
---@class Plugin Mandatory plugin interface.
---@field NAME string Plugin name. No spaces (will be used by slash commands).
---@field Initialize fun(self: Plugin, mainFrame: frame, relativePoint): any Return `relativePoint`.
---@field Draw fun(self: Plugin, relativePoint): integer, any Return `addRows, relativePoint` pair.
---@field SlashCmd fun(self: Plugin, args: string)

local cfg = RaidRolls_G.configuration

---@enum GroupTypeEnum addon user group status
RaidRolls_G.GroupType = {
    NOGROUP = "NOGROUP",
    PARTY = "PARTY",
    RAID = "RAID",
}

---Find what kind of group is the current player in.
---@return GroupTypeEnum
function RaidRolls_G.GetGroupType(self)
    if IsInRaid() then
        return self.GroupType.RAID
    elseif IsInGroup() then -- Any group type but raid => party.
        return self.GroupType.PARTY
    else
        return self.GroupType.NOGROUP
    end
end

-- Include in the minimap compartement. Needs to be global.
function RaidRolls_OnAddonCompartmentClick()
    RaidRolls_G.gui:SetVisibility(not RaidRollsShown)
end

-- Is any of the arguments secret?
-- Relevant since game version 12.0.0.
---@return boolean
function RaidRolls_G.IsSecret(...)
    if issecretvalue == nil then
        return false
    end
    for i = 1, select("#", ...) do
        arg = select(i, ...)
        if issecretvalue(arg) then
            return true
        end
    end
    return false
end

-- Initialize self, plugins, saved variables
function RaidRolls_G.Initialize(self)
    local relativePoint = self.gui:Initialize()
    -- Plugins initialize.
    for _, plugin in ipairs(self.plugins) do
        relativePoint = plugin:Initialize(self.gui.mainFrame, relativePoint)
    end

    -- Load saved variables.
    if RaidRollsShown == nil then -- Initialize when first loaded.
        RaidRollsShown = true;
    end
    self.gui:SetVisibility(RaidRollsShown)

    -- Starting in a group?
    if IsInGroup() then
        -- As if GROUP_JOINED was triggered.
        self.eventFunctions.OnGroupJoined(self)
    end

    -- Plugins might have sth to say.
    self:Draw()
end

--
---@return Plugin? plugin Namespace or nil if not found.
function RaidRolls_G.FindPlugin(self, name)
    for _, plugin in ipairs(self.plugins) do
        if name == plugin.NAME then
            return plugin
        end
    end
    return nil
end

--
---@return string
function RaidRolls_G.PluginsToString(self)
    if #self.plugins == 0 then
        return "No plugins"
    end
    local names = {}
    for _, plugin in ipairs(self.plugins) do
        names[#names + 1] = plugin.NAME
    end
    return "Plugins: " .. table.concat(names, ", ")
end

-- Main drawing function.
function RaidRolls_G.Draw(self)
    -- Start at 0 for header.
    local currentRow = 0

    -- Fetch data, fill, sort, write.
    local addRows, relativePoint = self.rollerCollection:Draw()
    currentRow = currentRow + addRows

    -- Plugins draw.
    for _, plugin in ipairs(self.plugins) do
        addRows, relativePoint = plugin:Draw(relativePoint)
        currentRow = currentRow + addRows
    end

    self.gui:SetHeight(cfg.size.EMPTY_HEIGHT + cfg.size.ROW_HEIGHT * currentRow)
end
