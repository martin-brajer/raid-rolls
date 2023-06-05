-- Slash commands and the called functions.
-- Populate no namespace.

local cfg = RaidRolls_G.configuration

--
local function printError(msg)
    local text = ("%s: %s"):format(cfg.ADDON_NAME, msg)
    print(WrapTextInColorCode(text, cfg.colors.SYSTEMMSG))
end

-- Print ingame help.
local function Help()
    print(GetAddOnMetadata(cfg.ADDON_NAME, "Title") .. " v" .. GetAddOnMetadata(cfg.ADDON_NAME, "Version") .. ".");
    for _, line in ipairs(cfg.texts.HELP_LINES) do
        print(line)
    end
end

-- Main frame width change.
local function Resize(percentageStr)
    local percentage
    -- Parameter check.
    if percentageStr == nil then -- No parameter -> default.
        percentage = 100
    else
        percentage = tonumber(percentageStr)
        if percentage == nil then -- Not a number.
            printError(cfg.texts.RESIZE_PARAMETER_ERROR)
            return
        elseif percentage < 100 then
            printError(cfg.texts.RESIZE_SIZE_ERROR)
            return
        end
    end

    RaidRolls_G.gui:SetWidth(cfg.size.FRAME_WIDTH * (percentage / 100))
end

-- No need to be part of a group for this to work.
local function Test(msg)
    -- Parameter check.
    if not msg then
        printError(cfg.texts.TEST_PARAMETER_ERROR)
        return
    end
    local tool, args = strsplit(" ", msg, 2)

    -- Fill `rollerCollection` by artificial values.
    if tool == "fill" then
        RaidRolls_G.rollerCollection:Fill()
        RaidRolls_G:Draw()

    -- No need to be part of a group for this to work.
    elseif tool == "solo" then
        RaidRolls_G.eventFrames.RegisterSoloChatEvents()

    -- is plugin test being called?
    else
        local plugin = RaidRolls_G:FindPlugin(tool)
        if plugin ~= nil then
            plugin:SlashCmd(args)
        else
            printError(cfg.texts.TEST_PARAMETER_ERROR)
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
        RaidRolls_G.rollerCollection:Clear()
        RaidRolls_G:Draw()
    elseif command == "resize" then
        Resize(args)
    elseif command == "test" then
        Test(args)
    else
        printError(cfg.texts.SLASH_PARAMETER_ERROR)
    end
end
