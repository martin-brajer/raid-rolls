-- Main file. Info and globals.

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
-- `rollers.lua` namespace.
RaidRolls_G.rollers = {}
-- Container for plugin namespaces.
RaidRolls_G.plugins = {}

-- SAVED VARIABLES: `RaidRollsShown`
-- Was the main frame shown at the end of the last session?
-- Initialized in `RaidRolls_G.eventFunctions.OnLoad`.

local cfg = RaidRolls_G.configuration


function RaidRolls_OnAddonCompartmentClick()
    RaidRolls_G.gui:SetVisibility(not RaidRollsShown)
end

-- Erace previous rolls.
function RaidRolls_G.Reset()
    RaidRolls_G.rollers:Clear()
    RaidRolls_G.Update()
end

-- Table length (no need to be a sequence).
function RaidRolls_G.TableCount(t)
    local count = 0
    for _ in pairs(t) do count = count + 1 end
    return count
end

-- Now Draw AND Update -> split.
function RaidRolls_G.Update()
    RaidRolls_G.Draw()
end

-- Main drawing function.
function RaidRolls_G.Draw()
    -- Start at 0 for header.
    local currentRow = 0

    -- Fetch data, fill, sort, write.
    currentRow = currentRow + RaidRolls_G.rollers:Draw()

    -- Plugins draw.
    for name, plugin in pairs(RaidRolls_G.plugins) do
        currentRow = currentRow + plugin:Draw(currentRow)
    end

    RaidRolls_G.gui:SetHeight(30 + cfg.ROW_HEIGHT * (currentRow)) -- 30 = (5 + 15 + 10)
end
