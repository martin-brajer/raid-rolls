-- Adds a warning showing if masterlooter should be on and isn't.
-- This plugin is used by adding it in the required toc file.

-- `plugin_MasterLooter.lua` namespace.
RaidRolls_G.plugins.masterLooter = {}

local this_module = RaidRolls_G.plugins.masterlooter

local cfg = RaidRolls_G.configuration

-- Should be the warning shown in the next draw?
this_module.showWarning = false

--
function this_module.UpdateShowWarning(self)
    local lootMethod = GetLootMethod()
    self.showWarning = (
        UnitIsGroupLeader("player")
        and lootMethod ~= "master"
        and lootMethod ~= "personalloot")
end

-- PARTY_LOOT_METHOD_CHANGED PARTY_LEADER_CHANGED
local function OnMasterLooterMayHaveChanged(self, event) -- `self` is not this module!
    this_module:UpdateShowWarning()
    RaidRolls_G:Draw()
end

-- Invoke update after Master Looter relevant events are raised.
local masterLooter_EventFrame = CreateFrame("Frame")
masterLooter_EventFrame:RegisterEvent("PARTY_LOOT_METHOD_CHANGED")
masterLooter_EventFrame:RegisterEvent("PARTY_LEADER_CHANGED")
masterLooter_EventFrame:SetScript("OnEvent", OnMasterLooterMayHaveChanged)

--
function this_module.Initialize(self, mainFrame)
    local lootWarning = mainFrame:CreateFontString(nil, "OVERLAY", "GameTooltipText")
    lootWarning:SetHeight(cfg.size.ROW_HEIGHT)
    lootWarning:SetPoint("TOPLEFT", RaidRolls_G.gui:GetRow(0).unit, "BOTTOMLEFT")
    lootWarning:SetText(WrapTextInColor(cfg.texts.SET_MASTER_LOOTER, cfg.colors.MASTERLOOTER))
    lootWarning:Hide()
    self.lootWarning = lootWarning

    -- Is the warning shown on load?
    self:UpdateShowWarning()
end

-- Accept the last used row to be used as parent. Use the row directly (less coupling)?
-- Return how many additional rows (for addon window size) do this needs.
function this_module.Draw(self, rowsUsed)
    if self.showWarning then
        self.lootWarning:SetPoint("TOPLEFT", RaidRolls_G.gui:GetRow(rowsUsed).unit, "BOTTOMLEFT")
        self.lootWarning:Show()
        return 1
    else
        self.lootWarning:Hide()
        return 0
    end
end

-- Testing
function this_module.Test(self, args)
    self.showWarning = not self.showWarning
    RaidRolls_G:Draw()
end
