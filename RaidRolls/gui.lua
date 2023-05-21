-- GUI elements and manipulation.

local this_module = RaidRolls_G.gui

local cfg = RaidRolls_G.configuration

-- Collection of {unit, roll} to be used to show data rows.
this_module.rowPool = {}


-- Needs `RaidRollsShown` (saved variable) initialized.
function this_module.Initialize(self)
    -- MAIN_FRAME
    -- frame = CreateFrame(frameType [, name, parent, template, id])
    local mainFrame = CreateFrame("Frame", ("%s_MainFrame"):format(cfg.ADDON_NAME),
        UIParent, BackdropTemplateMixin and "BackdropTemplate")
    mainFrame:SetSize(cfg.size.FRAME_WIDTH, cfg.size.EMPTY_HEIGHT)
    mainFrame:SetPoint("CENTER", UIParent, 0, 0)
    -- Mouse
    mainFrame:SetMovable(true)
    mainFrame:EnableMouse(true)
    mainFrame:SetScript("OnMouseDown", function(self_mainFrame, event)
        if event == "LeftButton" then
            self_mainFrame:StartMoving();
        elseif event == "RightButton" then
            RaidRolls_G:Reset()
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
    unitHeader:SetHeight(cfg.size.ROW_HEIGHT)
    unitHeader:SetJustifyH("LEFT")
    unitHeader:SetJustifyV("TOP")
    unitHeader:SetText(cfg.texts.UNIT_HEADER)
    unitHeader:SetTextColor(cfg.colors.HEADER:GetRGBA())
    self.unitHeader = unitHeader
    -- ROLL
    local rollHeader = mainFrame:CreateFontString(nil, "OVERLAY", "SystemFont_Small")
    rollHeader:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT", -16, -5)
    rollHeader:SetHeight(cfg.size.ROW_HEIGHT)
    rollHeader:SetJustifyH("LEFT")
    rollHeader:SetJustifyV("TOP")
    rollHeader:SetTextColor(cfg.colors.HEADER:GetRGBA())
    rollHeader:SetText(cfg.texts.ROLL_HEADER)
    self.rollHeader = rollHeader
end

-- Handle FontStrings needed for listing rolling players.
-- Uses as few rows as possible (recycles the old ones).
-- Return i-th row (create if necessary). Zero gives headers.
function this_module.GetRow(self, i)
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

        unit:SetHeight(cfg.size.ROW_HEIGHT)
        roll:SetHeight(cfg.size.ROW_HEIGHT)

        row = { unit = unit, roll = roll }
        tinsert(self.rowPool, row)
    end

    return row
end

-- Write character name and their roll to the given row index. Skip `nil`.
function this_module.WriteRow(self, i, unitText, rollText)
    local row = self:GetRow(i)
    if unitText ~= nil then
        row.unit:SetText(unitText)
    end
    if rollText ~= nil then
        row.roll:SetText(rollText)
    end
end

-- Table length (no need to be a sequence).
local function TableCount(t)
    local count = 0
    for _ in pairs(t) do count = count + 1 end
    return count
end

-- Hide all rows with index equal or greater than the parameter.
function this_module.HideTailRows(self, fromIndex)
    local max_index = TableCount(self.rowPool)
    while fromIndex <= max_index do
        local row = self:GetRow(fromIndex)
        row.unit:Hide()
        row.roll:Hide()
        fromIndex = fromIndex + 1
    end
end

-- Show or hide the GUI.
function this_module.SetVisibility(self, bool)
    RaidRollsShown = bool
    self.mainFrame:SetShown(bool)
end

function this_module.SetWidth(self, width)
    self.mainFrame:SetWidth(width)
end

function this_module.SetHeight(self, height)
    self.mainFrame:SetHeight(height)
end
