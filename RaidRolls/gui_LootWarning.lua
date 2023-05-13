-- Adds Loot warning to show if masterlooter whould be on and isn't.
-- Populate `RaidRolls_G.plugins.gui_LootWarning` namespace.
-- This plugin is used by adding it in the required toc file.

RaidRolls_G.plugins.gui_LootWarning = {
    showWarning = false
}

-- Accept the last used row to be used as parent. Use the row directly (less coupling)?
-- Return how many additional rows (for addon window size) do this needs.
function RaidRolls_G.plugins.gui_LootWarning.Update(self, rowsUsed)
    local lootMethod = GetLootMethod()
    -- self.showWarning = UnitIsGroupLeader("player") and lootMethod ~= "master" and lootMethod ~= "personalloot"

    if self.showWarning then
        RaidRolls_G.gui.lootWarning:SetPoint("TOPLEFT", RaidRolls_G.gui:GetRow(rowsUsed).unit, "BOTTOMLEFT")
        RaidRolls_G.gui.lootWarning:Show()
        return 1
    else
        RaidRolls_G.gui.lootWarning:Hide()
        return 0
    end
end
