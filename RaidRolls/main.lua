-- Main file. Info and globals.

-- Global locals (this addon's global namespace).
RaidRolls_G = {}
-- `eventFunctions.lua` namespace.
-- Do not use `self` (`self ~= RaidRolls_G.eventFunctions`)
RaidRolls_G.eventFunctions = {}
-- `eventFrames.lua` namespace.
RaidRolls_G.eventFrames = {}
-- `configuration.lua` namespace.
RaidRolls_G.configuration = {}
-- `gui.lua` namespace.
RaidRolls_G.gui = {}
-- `rollers.lua` namespace.
RaidRolls_G.rollers = {}
-- Container for plugin namespaces.
RaidRolls_G.plugins = {}

-- SAVED VARIABLES: `RaidRollsShown`
-- Was the main frame shown at the end of the last session?
-- Initialized in `RaidRolls_G.eventFunctions.OnLoad`.

local cfg = RaidRolls_G.configuration


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
    self.gui:Initialize()
    -- Plugins initialize.
    for name, plugin in pairs(self.plugins) do
        plugin:Initialize(self.gui.mainFrame)
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

-- Erace previous rolls.
function RaidRolls_G.Reset(self)
    self.rollers:Clear()
    self:Draw()
end

-- Main drawing function.
function RaidRolls_G.Draw(self)
    -- Start at 0 for header.
    local currentRow = 0

    -- Fetch data, fill, sort, write.
    currentRow = currentRow + self.rollers:Draw()

    -- Plugins draw.
    for name, plugin in pairs(self.plugins) do
        currentRow = currentRow + plugin:Draw(currentRow)
    end

    self.gui:SetHeight(cfg.size.EMPTY_HEIGHT + cfg.size.ROW_HEIGHT * currentRow)
end
