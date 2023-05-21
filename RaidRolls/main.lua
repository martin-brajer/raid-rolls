-- Main file. Info and globals.
-- Globals: `RaidRolls_G`, `RaidRollsShown`, `RaidRolls_OnAddonCompartmentClick`

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

local this_module = RaidRolls_G

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
function this_module.Initialize(self)
    self.gui:Initialize()
    -- Plugins initialize.
    for _, plugin in pairs(self.plugins) do
        local relativePoint = RaidRolls_G.gui:GetRow(0).unit
        plugin:Initialize(self.gui.mainFrame, relativePoint)
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

-- Main drawing function.
function this_module.Draw(self)
    -- Start at 0 for header.
    local currentRow = 0

    -- Fetch data, fill, sort, write.
    currentRow = currentRow + self.rollers:Draw()

    -- Plugins draw.
    for _, plugin in pairs(self.plugins) do
        currentRow = currentRow + plugin:Draw(currentRow)
    end

    self.gui:SetHeight(cfg.size.EMPTY_HEIGHT + cfg.size.ROW_HEIGHT * currentRow)
end
