# tes3mp-xp

# Features
* Fully re-implemented leveling system
* Extensive configs to customize derived stats, xp gain, and xp cost to level
* Experience gain on kill
* Experience gain on quest completion
  * quest xp is based on player level
* Experience gain on reading books
  * Only skill books
* Experience gain on discovering dialogue topics
* Configurable attribute/skill/level caps
  * Includes per-attribute and per-skill caps
* Ability to respec a players skills & attributes
* Gives player a "Training Journal" after chargen which they can use to access leveling/respec functions

# Install
* Place the json files from the `vanilla Data` folder in `server/data/custom/tes3mp-xp`
* Place everything else in `server/scripts/custom/tes3mp-xp`
* xpCalc.ods is a spreadsheet with formulas you can use to tune xp gain config values
* Add the following to customScripts.lua
```lua
xpLeveling = require("custom.tes3mp-xp.xpLeveling")
xpGain = require("custom.tes3mp-xp.xpGain")
```

# xp_override.json
* This json can be used to override level/xp values per:
  * creature/npc refid
  * quest
    * should be in the format of `<quest>_<index>`
  * skill book
  * dialogue topic
* The "xp" value will be prioritized
* Example entries are present by default

# Chat Commands
* Global commands
  * `/xpstatus` to show progress to next level
  * `/levelup` to open the levelup menu when ready to level up
  * `/respec` to open respec confirmation menu
* Admin commands (staff rank 2 by default)
  * `/xpoverride <type> <id> <level/xp> <value>` to add a record to the xp_override table
  * `/forcelevelup <pid>` to give a player a level (does not affect xp)
  * `/givexp <pid> <amount>` to give a player xp

# Known Issues
* Level xp cost formula has had very little testing and may result in strange leveling rates
* Skill books/Trainers will show messages indicating skills leveling up while not leveling skills
* Using with existing characters will likely cause issues
* Respecced levels may be tedious to re-levelup at very high levels depending on the value of your `xpConfig.skillLvlsPerSkill` setting