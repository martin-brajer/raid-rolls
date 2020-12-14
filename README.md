# Raid Rolls

These are the sources for the [Raid Rolls WoW addon](https://www.curseforge.com/wow/addons/raid-rolls/).

Raid Rolls is a free and open-source addon for World of Warcraft - client version 4.3.4 (Cataclysm). Records /rolls of your raid/party members. Meant for rolling for items in masterlooter mode, therefore players are sorted in descending order by their rolls.

## Features

* Shows roller's class (self explanatory), raid group (usefull for item distribution) and whether the player rolled multiple times (roll marked in red). Only rolls from the default interval 1-100 are counted (e.g. `/roll 99-100` is ignored regardless of the rolled value).
* Saying `pass` (in group channels) is treated as rolling zero.
* Right-mouse clicking on the addon window erases all rolls (the same as `/rr reset`).
* Addon window height is changed automatically while its width can be changed by a slash command.
* Leaving your group freezes information shown.
* If you are a group leader and master-looter is not selected, notification is shown.

## Instalation

Copy `RaidRolls` folder into your client: `\World of Warcraft\Interface\AddOns`. Then in champion select, click `AddOns`, where you can toggle on or off your addons.

## Slash Commands

Cmds start by `/raidrolls` or equivalently by `/rr`.
* `/rr` List commands.
* `/rr show` `hide` `toggle` GUI visibility.
* `/rr help` Show all slash commands.
* `/rr reset` Erase all rolls.
* `/rr resize` Reset addon window width.
* `/rr resize <number>` Extend the width to <number> percents of default.
* `/rr test` Fill in artificial rolls.

## License

Raid Rolls addon is licensed under the [MIT license](LICENSE).

Feel free to comment, share ideas or report bugs.
