-- Adds Loot warning to show if masterlooter whould be on and isn't.
-- Populate `RaidRolls_G.plugins.gui_LootWarning` namespace.
-- This plugin is used by adding it in the required toc file.

local cfg = RaidRolls_G.configuration

RaidRolls_G.plugins.gui_LootWarning = {
    showWarning = false
}

-- EVENT FUNCTIONS

-- PARTY_LOOT_METHOD_CHANGED PARTY_LEADER_CHANGED
local function OnMasterLooterMayHaveChanged(self, event)
    local lootMethod = GetLootMethod()
    -- self.showWarning = UnitIsGroupLeader("player") and lootMethod ~= "master" and lootMethod ~= "personalloot"

    RaidRolls_G.plugins.gui_LootWarning:Draw()
end

-- EVENT FRAMES

-- Invoke update after Master Looter relevant events are raised.
local masterLooter_EventFrame = CreateFrame("Frame")
masterLooter_EventFrame:RegisterEvent("PARTY_LOOT_METHOD_CHANGED")
masterLooter_EventFrame:RegisterEvent("PARTY_LEADER_CHANGED")
masterLooter_EventFrame:SetScript("OnEvent", OnMasterLooterMayHaveChanged)

-- GUI

function RaidRolls_G.plugins.gui_LootWarning.Initialize(self, mainFrame)
    local lootWarning = mainFrame:CreateFontString(nil, "OVERLAY", "GameTooltipText")
    lootWarning:SetHeight(cfg.ROW_HEIGHT)
    lootWarning:SetPoint("TOPLEFT", RaidRolls_G.gui:GetRow(0).unit, "BOTTOMLEFT")
    lootWarning:SetText(WrapTextInColor(cfg.texts.SET_MASTER_LOOTER, cfg.colors.MASTERLOOTER))
    lootWarning:Hide()
    self.lootWarning = lootWarning

    -- Is the warning shown on load?
    OnMasterLooterMayHaveChanged()
end

-- MAIN

-- Accept the last used row to be used as parent. Use the row directly (less coupling)?
-- Parameter `rowsUsed` is optional (if nil, do not update parent, only visibility).
-- Return how many additional rows (for addon window size) do this needs.
function RaidRolls_G.plugins.gui_LootWarning.Draw(self, rowsUsed)
    if self.showWarning then
        if rowsUsed then
            self.lootWarning:SetPoint("TOPLEFT", RaidRolls_G.gui:GetRow(rowsUsed).unit, "BOTTOMLEFT")
        end
        self.lootWarning:Show()
        return 1
    else
        self.lootWarning:Hide()
        return 0
    end
end
