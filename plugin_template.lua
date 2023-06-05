-- comment
-- This plugin is used by adding it low in the required toc file.
-- Populate `namespace` as numbered part of `RaidRolls_G.plugins`.

-- `<namespace>` plugin namespace.
---@type Plugin
local namespace = {
    NAME = 'name',
}
table.insert(RaidRolls_G.plugins, namespace)

local cfg = RaidRolls_G.configuration


--
function namespace.Initialize(self, mainFrame, relativePoint)
    return relativePoint
end

--
function namespace.Draw(self, relativePoint)
    return 0, relativePoint
end

--
function namespace.SlashCmd(self, args)
end
