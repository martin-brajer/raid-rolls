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
        RaidRolls_G.test()
    
    end
end

-- Show or hide UI.
function RaidRolls_G.show(bool)
    RaidRollsShown = bool
    if bool then
        RaidRolls_MainFrame:Show()
    else
        RaidRolls_MainFrame:Hide()
    end
end

-- Ingame help.
function RaidRolls_G.help()
    print(GetAddOnMetadata("RaidRolls", "Title") .. " v" .. GetAddOnMetadata("RaidRolls", "Version") .. ".");
    print("Slash Commands '/raidrolls' (or '/rr'):")
    print("  none - Commands list.")
    print("  'show' / 'hide' / 'toggle' - Show / hide / toggle GUI.")
    print("  'help' - Uroboros!")
    print("  'reset' - Erace all rolls.")
    print("  'resize <number>' - Extend frame width to <number> percent of default.")
    print("  'resize' - Reset frame width.")
    print("  'test' - Fill in test rolls.")
end

-- Erace previous rolls.
function RaidRolls_G.reset()
    RaidRolls_G.rollers = {}
    RaidRolls_G.update()
end

-- Main frame width change.
function RaidRolls_G.resize(percentage)
    percentage = tonumber(percentage)
    if ((percentage == nil) or (percentage < 100)) then
        percentage = 100
    end
    
    local offset = 200 * ((percentage / 100) - 1)  -- 200 == default frame width.
    RaidRolls_MainFrame:SetWidth(200 + offset)
    -- `RaidRolls_MainFrame_UnitHeader` stays where it is.
    RaidRolls_MainFrame_RollHeader:SetPoint("TOPLEFT", "$parent_UnitHeader", "TOPRIGHT", 35 + offset, 0)
end

-- Fill `rollers` by artificial values.
-- No need to be part of a group for this to work.
function RaidRolls_G.test()
    RaidRolls_G.rollers = {
        player1 = 20,
        player2 = 0,
        player3 = -99,
    }
    RaidRolls_G.update()
end
