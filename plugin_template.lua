-- <comment>
-- This plugin is used by adding it low in the required toc file.
-- Populate `namespace` as numbered part of `RaidRolls_G.plugins`.


local cfg = RaidRolls_G.configuration


-- <docstring>
local function Initialize(self, mainFrame, relativePoint)
    return relativePoint
end

-- <docstring>
local function Draw(self, relativePoint)
    return 0, relativePoint
end

-- <docstring>
local function SlashCmd(self, args)
end

-- `<namespace>` plugin namespace.
---@type Plugin
local namespace = {
    NAME = 'name',
    Initialize = Initialize,
    Draw = Draw,
    SlashCmd = SlashCmd,
}
table.insert(RaidRolls_G.plugins, namespace)
