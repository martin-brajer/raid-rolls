# Raid Rolls

These are the sources for the [Raid Rolls WoW addon](https://www.curseforge.com/wow/addons/raid-rolls/).

Raid Rolls is a free and open-source addon for World of Warcraft - client version 5.4.8 (Mists of Pandaria). Records `/roll`s of your raid/party members. Meant for rolling for items in the Master Looter mode, therefore players are sorted in descending order by their rolls.

## Features

* Shows roller's class (can they equip the item) and raid group number
  (simplifies item distribution).
* Saying `pass` in group channels is treated as rolling zero.
* Right-mouse clicking on the addon window erases all rolls (the same as `/rr reset`).
* Cheese counters:
  * If the player rolled multiple times, the value si marked in red.
    It is not ignored in case you forgot to reset the previous roll session.
  * Only rolls from the default interval 1-100 are counted
    (e.g. `/roll 99-100` is ignored regardless of the rolled value).
* If you are a group leader and Master Looter is not selected, notification is shown.

## Installation

Copy `RaidRolls` folder into your client `\World of Warcraft\Interface\AddOns`.
Then click `AddOns` button in champion select where you can toggle the addon on or off.

## Slash Commands

Cmds start by `/raidrolls` or equivalently by `/rr`.

* `/rr` List commands.
* `/rr show` `hide` `toggle` GUI visibility.
* `/rr help` Show all slash commands.
* `/rr reset` Erase all rolls.
* `/rr resize number` Change the width to `number` percent of the default.
  * Minimal accepted value is 100 (default)
  * Omitting the `number` parameter resets the width.
* `/rr test` Fill in artificial rolls.

## Licence & compliance

* Raid Rolls addon is licensed under the [MIT licence](LICENSE).
* Icon `pair-of-dice.png` is sourced from
  [iconspng.com](https://www.iconspng.com/image/7894/pair-of-dice)
  under the following licence:
    > Licencing! Pair of dice PNG icons - The pictures are free for personal and even for commercial use. You can modify, copy and distribute the vectors on Pair of dice in iconspng.com. All without asking for permission or setting a link to the source. So, attribution is not required.
* Versioning follows [Semantic Versioning 2.0.0](https://semver.org/).

Feel free to comment, share ideas or report bugs.
