# Notes

- addon's icon `pair-of-dice.png`
  - sourced from <https://www.iconspng.com/image/7894/pair-of-dice>
  - licence:

    > Licencing! Pair of dice PNG icons - The pictures are free for personal and even for commercial use. You can modify, copy and distribute the vectors on Pair of dice in iconspng.com. All without asking for permission or setting a link to the source. So, attribution is not required.
- do retail or classic updates?

## MOP update

## Bugs

- `GetNumRaidMembers` deprecated

    ```lua
        19x RaidRolls\main.lua:123: attempt to call global 'GetNumRaidMembers' (a nil value)
        RaidRolls\main.lua:123: in function `groupType'
        RaidRolls\main.lua:137: in function`groupTypeChanged'
        RaidRolls\main.lua:48: in function `onload'
        [string "*:OnLoad"]:1: in function <[string "*:OnLoad"]:1>

        Locals:
        outcome = nil
    ```

- `IsRaidLeader` deprecated

    ```lua
        3x RaidRolls\main.lua:173: attempt to call global 'IsRaidLeader' (a nil value)
        RaidRolls\main.lua:173: in function `update'
        RaidRolls\main.lua:279: in function <RaidRolls\main.lua:278>

        Locals:
        self = <unnamed> {
        0 = <userdata>
        }
        event = "PARTY_LEADER_CHANGED"
    ```

- msg event returns changed name (probably PTR database thing)
  - say "pass" in /raid adds a new "roller" with name `<name>-MoPPTR`
  - ok in /say
  - correct zero roll

### TODO

- CHAT_MSG_EVENTS add instance
- naming
- git
- script to push to wow folder
- master looter string and option
- get rid of `...` symbol
- `ChatSystem_EventFrame:SetScript("OnEvent",` to separate function
  - all event functions and register events at one location in code
- is separate self chat signalling necessary?

### Change_list

- GetNumRaidMembers() to GetNumGroupMembers()
- GetNumRaidMembers() > 0 to IsInRaid()
- GetNumPartyMembers() > 0 to IsInGroup()
- IsRaidLeader() to UnitIsGroupLeader("player")
