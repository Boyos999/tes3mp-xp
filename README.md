# tes3mp-xp

# Features
* Fully re-implemented leveling system
* Extensive configs to customize derived stats, xp gain, and xp cost to level
* Experience gain on kill
* Experience gain on quest completion
  * quest xp is based on player level
* Configurable attribute/skill/level caps
  * Includes per-attribute and per-skill caps

# Install
* Place `vanilla Data` files in `server/data/custom/tes3mp-xp`
* Place everything else in `server/scripts/custom/tes3mp-xp`
* xpCalc.ods is a spreadsheet with formulas you can use to tune xp gain config values
* Add the following to customScripts.lua
```lua
xpLeveling = require("custom.tes3mp-xp.xpLeveling")
xpGain = require("custom.tes3mp-xp.xpGain")
```

# xp_override.json
* This json can be used to override level/xp values per creature/npc refid or quest
* Quests entries should be in the format of `<quest>_<index>`
* The "xp" value will be prioritized over xp calucated from level
* Example entries are present by default

# Chat Commands
* Global commands
  * `/xpstatus` to show progress to next level
  * `/levelup` to open the levelup menu when ready to level up
* Admin commands (staff rank 2 by default)
  * `/xpoverride <type> <id> <level/xp> <value>` to add a record to the xp_override table
  * `/forcelevelup <pid>` to give a player a level (does not affect xp)
  * `/givexp <pid> <amount>` to give a player xp

# Known Issues
* Using `xpConfig.vanillaLeveling = false` will cause several weird issues due to how morrowind works
  * `xpConfig.healthRetroactive = true` and other health settings are safe and can be used with vanillaLeveling = false
* Level xp cost formula has had very little testing and may result in strange leveling rates
* Skill books/Trainers will show messages indicating skills leveling up while not leveling skills
* Using with existing characters will likely cause issues