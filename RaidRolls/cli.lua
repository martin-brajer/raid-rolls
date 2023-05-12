-- Slash commands.
SLASH_RAIDROLLS1 = '/raidrolls';
SLASH_RAIDROLLS2 = '/rr';
SlashCmdList["RAIDROLLS"] = function(msg, editbox)
    local command, arg1 = strsplit(" ", msg)

    if command == "" then
        print("Cmds: show, hide, toggle, help, reset, resize, test.")
    elseif command == "show" then
        RaidRolls_G.show(true)
    elseif command == "hide" then
        RaidRolls_G.show(false)
    elseif command == "toggle" then
        RaidRolls_G.show(not RaidRollsShown)
    elseif command == "help" then
        RaidRolls_G.help()
    elseif command == "reset" then
        RaidRolls_G.reset()
    elseif command == "resize" then
        RaidRolls_G.resize(arg1)
    elseif command == "test" then
        RaidRolls_G.test(arg1)
    end
end

-- Show or hide UI.
function RaidRolls_G.show(bool)
    RaidRollsShown = bool
    RaidRolls_G.regions.mainFrame:SetShown(bool)
end

-- Ingame help.
function RaidRolls_G.help()
    print(GetAddOnMetadata("RaidRolls", "Title") .. " v" .. GetAddOnMetadata("RaidRolls", "Version") .. ".");
    print("Slash Commands '/raidrolls' (or '/rr'):")
    print("  none - Commands list.")
    print("  'show' / 'hide' / 'toggle' - UI visibility.")
    print("  'help' - Uroboros!")
    print("  'reset' - Erase all rolls (or right-click the window).")
    print("  'resize <percentage>' - Change the width to <percentage> of default.")
    print("  'test <tool>' - Choose: <fill> fills in test rolls, <solo> allows out of group use.")
end

-- Erace previous rolls.
function RaidRolls_G.reset()
    RaidRolls_G.rollers = {}
    RaidRolls_G.update()
end

-- Main frame width change.
function RaidRolls_G.resize(percentage)
    percentage = tonumber(percentage)
    if percentage == nil then
        percentage = 100
    elseif percentage < 100 then
        print("|c" .. RaidRolls_G.colours.SYSTEMMSG .. "RaidRolls: Cannot resize below 100%.")
        return
    end

    RaidRolls_G.regions.mainFrame:SetWidth(RaidRolls_G.FRAME_WIDTH * (percentage / 100))
end

-- Fill `rollers` by artificial values.
-- No need to be part of a group for this to work.
function RaidRolls_G.test(tool)
    if tool == "fill" then
        RaidRolls_G.rollers = {
            player1 = 20,
            player2 = 0,
            player3 = -99,
        }
        RaidRolls_G.update()
    elseif tool == "solo" then
        RaidRolls_G.eventFrames.RegisterSoloChatEvents()
    else
        print("|c" .. RaidRolls_G.colours.SYSTEMMSG .. "RaidRolls: Append either 'fill' or 'solo' parameter.")
    end
end

-- Return RGBA values between 0 and 1.
local function hex2table(colorHexString)
    local color_table = {}
    for hexString in colorHexString:gmatch("..") do
        table.insert(color_table, tonumber(hexString, 16) / 255)
    end
    return color_table[2], color_table[3], color_table[4], color_table[1]
end

function RaidRolls_G.initializeUI()
    -- MAIN_FRAME
    -- frame = CreateFrame(frameType [, name, parent, template, id])
    local mainFrame = CreateFrame("Frame", "RaidRolls_MainFrame", UIParent, BackdropTemplateMixin and "BackdropTemplate")
    mainFrame:SetSize(RaidRolls_G.FRAME_WIDTH, 30)
    mainFrame:SetPoint("TOPLEFT", UIParent, 0, 0)
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
    mainFrame:SetBackdropColor(hex2table(RaidRolls_G.colours.BACKGROUND))
    RaidRolls_G.regions.mainFrame = mainFrame
    -- UNIT
    local unitHeader = mainFrame:CreateFontString(nil, "OVERLAY", "SystemFont_Small")
    unitHeader:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 5, -5) -- Offset right and down.
    unitHeader:SetHeight(RaidRolls_G.ROW_HEIGHT)
    unitHeader:SetJustifyH("LEFT")
    unitHeader:SetJustifyV("TOP")
    unitHeader:SetText("Player (class)[subgroup]")
    unitHeader:SetTextColor(hex2table(RaidRolls_G.colours.HEADER))
    RaidRolls_G.regions.unitHeader = unitHeader
    -- ROLL
    local rollHeader = mainFrame:CreateFontString(nil, "OVERLAY", "SystemFont_Small")
    rollHeader:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT", -16, -5)
    rollHeader:SetHeight(RaidRolls_G.ROW_HEIGHT)
    rollHeader:SetJustifyH("LEFT")
    rollHeader:SetJustifyV("TOP")
    rollHeader:SetTextColor(hex2table(RaidRolls_G.colours.HEADER))
    rollHeader:SetText("Roll")
    RaidRolls_G.regions.rollHeader = rollHeader
    -- LOOT
    local lootWarning = mainFrame:CreateFontString(nil, "OVERLAY", "GameTooltipText")
    lootWarning:SetHeight(RaidRolls_G.ROW_HEIGHT)
    lootWarning:SetPoint("TOPLEFT", RaidRolls_G.getRow(0).unit, "BOTTOMLEFT")
    lootWarning:SetText("Set |c" .. RaidRolls_G.colours.MASTERLOOTER .. "MASTER LOOTER|r!!!")
    lootWarning:Hide()
    RaidRolls_G.regions.lootWarning = lootWarning
end

-- Handle FontStrings needed for listing rolling players.
-- Uses as few rows as possible (recycles the old ones).
-- Return i-th row (create if necessary). Zero gives headers.
function RaidRolls_G.getRow(i)
    if i == 0 then
        return { unit = RaidRolls_G.regions.unitHeader, roll = RaidRolls_G.regions.rollHeader }
    end

    local row = RaidRolls_G.regions.rowPool[i]
    if row then
        row.unit:Show()
        row.roll:Show()
    else
        local unit = RaidRolls_G.regions.mainFrame:CreateFontString(nil, "OVERLAY", "GameTooltipText")
        local roll = RaidRolls_G.regions.mainFrame:CreateFontString(nil, "OVERLAY", "GameTooltipText")

        local parents = RaidRolls_G.getRow(i - 1)
        unit:SetPoint("TOPLEFT", parents.unit, "BOTTOMLEFT")
        roll:SetPoint("TOPLEFT", parents.roll, "BOTTOMLEFT")

        unit:SetHeight(RaidRolls_G.ROW_HEIGHT)
        roll:SetHeight(RaidRolls_G.ROW_HEIGHT)

        row = { unit = unit, roll = roll }
        tinsert(RaidRolls_G.regions.rowPool, row)
    end

    return row
end
