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
-- Container for plugin namespaces.
---@type Plugin[]
RaidRolls_G.plugins = {}

--- Mandatory plugin
---@class Plugin
---@field NAME string Plugin name. No spaces (will be used by slash commands).
---@field Initialize fun(self, mainFrame: frame, relativePoint): any Return `relativePoint`.
---@field Draw fun(self, relativePoint): integer, any Return `addRows, relativePoint` pair.
---@field Test fun(self, args: string[])


local cfg = RaidRolls_G.configuration

---@enum GroupTypeEnum addon user group status
RaidRolls_G.GroupType = {
    NOGROUP = "NOGROUP",
    PARTY = "PARTY",
    RAID = "RAID",
}

-- Include in the minimap compartement. Needs to be global.
function RaidRolls_OnAddonCompartmentClick()
    RaidRolls_G.gui:SetVisibility(not RaidRollsShown)
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
