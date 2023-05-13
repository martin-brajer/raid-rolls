-- Slash commands and the called functions.
-- Populate no namespace.

local cfg = RaidRolls_G.configuration

-- Slash commands.
SLASH_RAIDROLLS1 = '/raidrolls';
SLASH_RAIDROLLS2 = '/rr';
SlashCmdList["RAIDROLLS"] = function(msg, editbox)
    local command, arg1 = strsplit(" ", msg)

    if command == "" then
        print(cfg.texts.LIST_CMDS)
    elseif command == "show" then
        RaidRolls_G.gui:SetVisibility(true)
    elseif command == "hide" then
        RaidRolls_G.gui:SetVisibility(false)
    elseif command == "toggle" then
        RaidRolls_G.gui:SetVisibility(not RaidRollsShown)
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

-- Ingame help.
function RaidRolls_G.help()
    print(GetAddOnMetadata("RaidRolls", "Title") .. " v" .. GetAddOnMetadata("RaidRolls", "Version") .. ".");
    for _, line in ipairs(cfg.texts.HELP_LINES) do
        print(line)
    end
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
        print(WrapTextInColor(cfg.texts.RESIZE_ERROR, cfg.colors.SYSTEMMSG))
        return
    end

    RaidRolls_G.gui.mainFrame:SetWidth(cfg.FRAME_WIDTH * (percentage / 100))
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
        print(WrapTextInColor(cfg.texts.TEST_PARAMETER_ERROR, cfg.colors.SYSTEMMSG))
    end
end
