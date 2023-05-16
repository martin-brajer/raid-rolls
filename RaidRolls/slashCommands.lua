-- Slash commands and the called functions.
-- Populate no namespace.

local cfg = RaidRolls_G.configuration

-- Print ingame help.
local function Help()
    print(GetAddOnMetadata("RaidRolls", "Title") .. " v" .. GetAddOnMetadata("RaidRolls", "Version") .. ".");
    for _, line in ipairs(cfg.texts.HELP_LINES) do
        print(line)
    end
end

-- Main frame width change.
local function Resize(percentage)
    percentage = tonumber(percentage)
    if percentage == nil then
        percentage = 100
    elseif percentage < 100 then
        print(WrapTextInColor(cfg.texts.RESIZE_ERROR, cfg.colors.SYSTEMMSG))
        return
    end

    RaidRolls_G.gui:SetWidth(cfg.FRAME_WIDTH * (percentage / 100))
end

-- No need to be part of a group for this to work.
local function Test(msg)
    local tool, args = strsplit(" ", msg, 2)

    -- Fill `rollers` by artificial values.
    if tool == "fill" then
        RaidRolls_G.rollers:Fill()
        RaidRolls_G:Draw()

        -- No need to be part of a group for this to work.
    elseif tool == "solo" then
        RaidRolls_G.eventFrames.RegisterSoloChatEvents()

        -- is plugin test being called?
    else
        local pluginFound = false

        for name, plugin in pairs(RaidRolls_G.plugins) do
            if tool == name then
                plugin:Test(args)
                pluginFound = true
                break
            end
        end

        -- None, just wrong cmd.
        if not pluginFound then
            print(WrapTextInColor(cfg.texts.TEST_PARAMETER_ERROR, cfg.colors.SYSTEMMSG))
        end
    end
end

-- Slash commands.
SLASH_RAIDROLLS1 = '/raidrolls'
SLASH_RAIDROLLS2 = '/rr'
SlashCmdList["RAIDROLLS"] = function(msg, editbox)
    local command, args = strsplit(" ", msg, 2)

    if command == "" then
        print(cfg.texts.LIST_CMDS)
    elseif command == "show" then
        RaidRolls_G.gui:SetVisibility(true)
    elseif command == "hide" then
        RaidRolls_G.gui:SetVisibility(false)
    elseif command == "toggle" then
        RaidRolls_G.gui:SetVisibility(not RaidRollsShown)
    elseif command == "help" then
        Help()
    elseif command == "reset" then
        RaidRolls_G.Reset()
    elseif command == "resize" then
        Resize(args)
    elseif command == "test" then
        Test(args)
    else
        print(WrapTextInColor(cfg.texts.SLASH_PARAMETER_ERROR, cfg.colors.SYSTEMMSG))
    end
end
