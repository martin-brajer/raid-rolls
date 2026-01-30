-- Adds a warning showing if masterlooter should be on and isn't.
-- This plugin is used by adding it low in the required toc file.
-- Populate `masterLooter` as numbered part of `RaidRolls_G.plugins`.

local cfg = RaidRolls_G.configuration
local SET_MASTER_LOOTER = "Master looter not set!"

-- Should be the warning shown in the next draw?
local showWarning = false

--
---@return boolean hasChanged has the warning state changed during this call?
local function UpdateShowWarning()
    local lootMethod = C_PartyInfo.GetLootMethod()
    local newShowWarning = UnitIsGroupLeader("player") and lootMethod ~= Enum.LootMethod.Masterlooter

    local hasChanged = newShowWarning ~= showWarning
    showWarning = newShowWarning
    return hasChanged
end

-- PARTY_LOOT_METHOD_CHANGED PARTY_LEADER_CHANGED
local function OnMasterLooterMayHaveChanged(self, event) -- `self` is not this module!
    local hasChanged = UpdateShowWarning()
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
local function Initialize(self, mainFrame, relativePoint)
    local lootWarning = mainFrame:CreateFontString(nil, "OVERLAY", "GameTooltipText")
    lootWarning:SetHeight(cfg.size.ROW_HEIGHT)
    lootWarning:SetPoint("TOPLEFT", relativePoint, "BOTTOMLEFT")
    lootWarning:SetText(WrapTextInColorCode(SET_MASTER_LOOTER, cfg.colors.MASTERLOOTER))
    lootWarning:Hide()
    self.lootWarning = lootWarning

    -- Is the warning shown on load?
    -- Calling `OnMasterLooterMayHaveChanged` would trigger `Draw`!
    UpdateShowWarning()

    return lootWarning -- relativePoint
end

-- Return `addRows, relativePoint`.
local function Draw(self, relativePoint)
    if showWarning then
        self.lootWarning:SetPoint("TOPLEFT", relativePoint, "BOTTOMLEFT")
        self.lootWarning:Show()
        return 1, self.lootWarning
    else
        self.lootWarning:Hide()
        return 0, relativePoint
    end
end

-- Testing
local function SlashCmd(self, args)
    showWarning = not showWarning
    RaidRolls_G:Draw()
end

-- `masterLooter` plugin namespace.
---@type Plugin
local masterLooter = {
    NAME = 'masterLooter',
    Initialize = Initialize,
    Draw = Draw,
    SlashCmd = SlashCmd,
    ---@type FontString
    lootWarning = nil, -- Set in `Initialize`.
}
table.insert(RaidRolls_G.plugins, masterLooter)
