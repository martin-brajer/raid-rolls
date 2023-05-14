-- GUI elements and manipulation.
-- Populate `RaidRolls_G.gui` namespace.

local cfg = RaidRolls_G.configuration

-- Collection of {unit, roll} to be used to show data rows.
RaidRolls_G.gui.rowPool = {}


-- Needs `RaidRollsShown` (saved variable) initialized.
function RaidRolls_G.gui.Initialize(self)
    -- MAIN_FRAME
    -- frame = CreateFrame(frameType [, name, parent, template, id])
    local mainFrame = CreateFrame("Frame", "RaidRolls_MainFrame", UIParent, BackdropTemplateMixin and "BackdropTemplate")
    mainFrame:SetSize(cfg.FRAME_WIDTH, 30)
    mainFrame:SetPoint("CENTER", UIParent, 0, 0)
    -- Mouse
    mainFrame:SetMovable(true)
    mainFrame:EnableMouse(true)
    mainFrame:SetScript("OnMouseDown", function(self_mainFrame, event)
        if event == "LeftButton" then
            self_mainFrame:StartMoving();
        elseif event == "RightButton" then
            RaidRolls_G.Reset()
        end
    end)
    mainFrame:SetScript("OnMouseUp", function(self_mainFrame)
        self_mainFrame:StopMovingOrSizing()
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

-- Write character name and their roll to the given row index.
function RaidRolls_G.gui.WriteRow(self, i, unitText, rollText)
    local row = self:GetRow(i)
    row.unit:SetText(unitText)
    row.roll:SetText(rollText)
end

-- Hide all rows with index equal or greater than the parameter.
function RaidRolls_G.gui.HideRowsTail(self, i)
    local max_i = RaidRolls_G.TableCount(self.rowPool)
    while i <= max_i do
        local row = self:GetRow(i)
        row.unit:Hide()
        row.roll:Hide()
        i = i + 1
    end
end

-- Show or hide the GUI.
function RaidRolls_G.gui.SetVisibility(self, bool)
    RaidRollsShown = bool
    self.mainFrame:SetShown(bool)
end

function RaidRolls_G.gui.SetWidth(self, width)
    self.mainFrame:SetWidth(width)
end

function RaidRolls_G.gui.SetHeight(self, height)
    self.mainFrame:SetHeight(height)
end
