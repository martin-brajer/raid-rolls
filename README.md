# Raid Rolls

These are the sources for the [Raid Rolls WoW addon](https://www.curseforge.com/wow/addons/raid-rolls/).

Raid Rolls is a lightweight addon for World of Warcraft (both Retail and Classic).
Records `/roll`s of your raid/party members to simplify items distribution
(e.g. in [Vault of Archavon](https://www.wowhead.com/wotlk/vault-of-archavon) - VOA).

## Features

- Rollers are sorted in descending order by their rolls.
- Shows roller's class (can they equip the item) and raid group number (simplifies
  item distribution).
- Saying `pass` in group channels is treated as rolling zero.
- Right-mouse clicking on the addon window erases all rolls (the same as `/rr reset`).
- Cheese counters:
    - If the player rolled multiple times, the value si marked in red.
      It is not ignored in case you forgot to reset the previous roll session.
    - Only rolls from the default interval 1-100 are counted
      (e.g. `/roll 99-100` is ignored regardless of the rolled value).
- (pre Personal Loot) If you are a group leader and Master Looter is not selected, notification is shown.

## Installation

Copy `RaidRolls` folder into addons folder of your client (e.g. `\World of Warcraft\_retail_\Interface\AddOns\`).
Then click `AddOns` button in champion select where you can toggle the addon on or off.

## Slash Commands

Cmds start by `/raidrolls` or equivalently by `/rr`.

- `/rr` List commands.
- `/rr show` / `hide` / `toggle` UI visibility.
- `/rr help` Show all slash commands.
- `/rr reset` Erase all rolls (same as right-clicking the window).
- `/rr resize percentage` Change the width to `percentage` of default.
    - Minimal accepted value is 100 (default)
    - Omitting the `percentage` parameter resets the width.
- `/rr test fill` / `solo` / `plugin name` Fill in artificial rolls
  / allow use out of a group (until `/reload`)
  / run plugin's own testing.

## Licence & compliance

- This addon is licensed under the [MIT licence](LICENSE).
- The icon's [source and licence](https://www.iconspng.com/image/7894/pair-of-dice)
  (in-game edited).
- Versioning follows [Semantic Versioning 2.0.0](https://semver.org/).

Feel free to comment, share ideas or report bugs.
