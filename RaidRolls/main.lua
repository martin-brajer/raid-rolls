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

function RaidRolls_OnAddonCompartmentClick()
    RaidRolls_G.gui:SetVisibility(not RaidRollsShown)
end

-- Initialize self, plugins, saved variables
function RaidRolls_G.Initialize(self)
    RaidRolls_G.gui:Initialize()
    -- Plugins initialize.
    for name, plugin in pairs(RaidRolls_G.plugins) do
        plugin:Initialize(RaidRolls_G.gui.mainFrame)
    end

    -- Load saved variables.
    if RaidRollsShown == nil then -- Initialize when first loaded.
        RaidRollsShown = true;
    end
    RaidRolls_G.gui:SetVisibility(RaidRollsShown)

    -- Initial state.
    if IsInGroup() then
        RaidRolls_G.eventFunctions.OnGroupJoined(self)
    end
    RaidRolls_G:Draw() -- Plugins might have sth to say.
end

-- Erace previous rolls.
function RaidRolls_G.Reset()
    RaidRolls_G.rollers:Clear()
    RaidRolls_G:Draw()
end

-- Table length (no need to be a sequence).
function RaidRolls_G.TableCount(t)
    local count = 0
    for _ in pairs(t) do count = count + 1 end
    return count
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

    self.gui:SetHeight(30 + cfg.ROW_HEIGHT * (currentRow)) -- 30 = (5 + 15 + 10)
end
