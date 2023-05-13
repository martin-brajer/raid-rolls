-- GUI elements and manipulation.
-- Populate `RaidRolls_G.gui` namespace.

local cfg = RaidRolls_G.configuration

RaidRolls_G.gui = {
    rowPool = {} -- Collection of {unit, roll} to be used to show data rows.
}


-- Needs `RaidRollsShown` initialized.
function RaidRolls_G.gui.Initialize(self)
    -- MAIN_FRAME
    -- frame = CreateFrame(frameType [, name, parent, template, id])
    local mainFrame = CreateFrame("Frame", "RaidRolls_MainFrame", UIParent, BackdropTemplateMixin and "BackdropTemplate")
    mainFrame:SetSize(cfg.FRAME_WIDTH, 30)
    mainFrame:SetPoint("CENTER", UIParent, 0, 0)
    -- Mouse
    mainFrame:SetMovable(true)
    mainFrame:EnableMouse(true)
    mainFrame:SetScript("OnMouseDown", function(self, event)
        if event == "LeftButton" then
            self:StartMoving();
        elseif event == "RightButton" then
            RaidRolls_G.reset()
        end
    end)
    mainFrame:SetScript("OnMouseUp", function(self)
        self:StopMovingOrSizing()
    end)
    -- Background
    mainFrame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 4, right = 3, top = 4, bottom = 3 },
    })
    mainFrame:SetBackdropColor(cfg.colors.BACKGROUND:GetRGBA())
    self.mainFrame = mainFrame
    -- UNIT
    local unitHeader = mainFrame:CreateFontString(nil, "OVERLAY", "SystemFont_Small")
    unitHeader:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 5, -5) -- Offset right and down.
    unitHeader:SetHeight(cfg.ROW_HEIGHT)
    unitHeader:SetJustifyH("LEFT")
    unitHeader:SetJustifyV("TOP")
    unitHeader:SetText(cfg.texts.UNIT_HEADER)
    unitHeader:SetTextColor(cfg.colors.HEADER:GetRGBA())
    self.unitHeader = unitHeader
    -- ROLL
    local rollHeader = mainFrame:CreateFontString(nil, "OVERLAY", "SystemFont_Small")
    rollHeader:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT", -16, -5)
    rollHeader:SetHeight(cfg.ROW_HEIGHT)
    rollHeader:SetJustifyH("LEFT")
    rollHeader:SetJustifyV("TOP")
    rollHeader:SetTextColor(cfg.colors.HEADER:GetRGBA())
    rollHeader:SetText(cfg.texts.ROLL_HEADER)
    self.rollHeader = rollHeader
    -- LOOT
    local lootWarning = mainFrame:CreateFontString(nil, "OVERLAY", "GameTooltipText")
    lootWarning:SetHeight(cfg.ROW_HEIGHT)
    lootWarning:SetPoint("TOPLEFT", self:GetRow(0).unit, "BOTTOMLEFT")
    lootWarning:SetText(WrapTextInColor(cfg.texts.SET_MASTER_LOOTER, cfg.colors.MASTERLOOTER))
    lootWarning:Hide()
    self.lootWarning = lootWarning
end

-- Handle FontStrings needed for listing rolling players.
-- Uses as few rows as possible (recycles the old ones).
-- Return i-th row (create if necessary). Zero gives headers.
function RaidRolls_G.gui.GetRow(self, i)
    if i == 0 then
        return { unit = self.unitHeader, roll = self.rollHeader }
    end

    local row = self.rowPool[i]
    if row then
        row.unit:Show()
        row.roll:Show()
    else
        local unit = self.mainFrame:CreateFontString(nil, "OVERLAY", "GameTooltipText")
        local roll = self.mainFrame:CreateFontString(nil, "OVERLAY", "GameTooltipText")

        local parents = self:GetRow(i - 1)
        unit:SetPoint("TOPLEFT", parents.unit, "BOTTOMLEFT")
        roll:SetPoint("TOPLEFT", parents.roll, "BOTTOMLEFT")

        unit:SetHeight(cfg.ROW_HEIGHT)
        roll:SetHeight(cfg.ROW_HEIGHT)

        row = { unit = unit, roll = roll }
        tinsert(self.rowPool, row)
    end

    return row
end

-- Show or hide the GUI.
function RaidRolls_G.gui.SetVisibility(self, bool)
    RaidRollsShown = bool
    self.mainFrame:SetShown(bool)
end
