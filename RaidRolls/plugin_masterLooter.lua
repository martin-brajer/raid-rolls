-- Adds a warning showing if masterlooter should be on and isn't.
-- This plugin is used by adding it low in the required toc file.
-- Populate `masterLooter` as numbered part of `RaidRolls_G.plugins`.

-- `masterLooter` plugin namespace.
local masterLooter = {
    NAME = 'masterLooter',
}
table.insert(RaidRolls_G.plugins, masterLooter)

local cfg = RaidRolls_G.configuration
local SET_MASTER_LOOTER = "Master looter not set!"

-- Should be the warning shown in the next draw?
masterLooter.showWarning = false

--
---@return boolean hasChanged has the warning state changed during this call?
function masterLooter._updateShowWarning(self)
    local lootMethod = GetLootMethod()
    local newShowWarning = (
        UnitIsGroupLeader("player")
        and lootMethod ~= "master"
        and lootMethod ~= "personalloot")

    local hasChanged = newShowWarning ~= self.showWarning
    self.showWarning = newShowWarning
    return hasChanged
end

-- PARTY_LOOT_METHOD_CHANGED PARTY_LEADER_CHANGED
local function OnMasterLooterMayHaveChanged(self, event) -- `self` is not this module!
    local hasChanged = masterLooter:_updateShowWarning()
    if hasChanged then
        RaidRolls_G:Draw()
    end
end

-- Invoke update after Master Looter relevant events are raised.
local masterLooter_EventFrame = CreateFrame("Frame")
masterLooter_EventFrame:RegisterEvent("PARTY_LOOT_METHOD_CHANGED")
masterLooter_EventFrame:RegisterEvent("PARTY_LEADER_CHANGED")
masterLooter_EventFrame:SetScript("OnEvent", OnMasterLooterMayHaveChanged)

--
function masterLooter.Initialize(self, mainFrame, relativePoint)
    local lootWarning = mainFrame:CreateFontString(nil, "OVERLAY", "GameTooltipText")
    lootWarning:SetHeight(cfg.size.ROW_HEIGHT)
    lootWarning:SetPoint("TOPLEFT", relativePoint, "BOTTOMLEFT")
    lootWarning:SetText(WrapTextInColorCode(SET_MASTER_LOOTER, cfg.colors.MASTERLOOTER))
    lootWarning:Hide()
    self.lootWarning = lootWarning

    -- Is the warning shown on load?
    self:_updateShowWarning()

    return lootWarning -- relativePoint
end

-- Return `addRows, relativePoint`.
function masterLooter.Draw(self, relativePoint)
    if self.showWarning then
        self.lootWarning:SetPoint("TOPLEFT", relativePoint, "BOTTOMLEFT")
        self.lootWarning:Show()
        return 1, self.lootWarning
    else
        self.lootWarning:Hide()
        return 0, relativePoint
    end
end

-- Testing
function masterLooter.Test(self, args)
    self.showWarning = not self.showWarning
    RaidRolls_G:Draw()
end
