# tes3mp-xp

# Features
* Fully re-implemented leveling system
* Extensive configs to customize derived stats, xp gain, and xp cost to level
* Experience gain on kill
* Experience gain on quest completion
* `/xpstatus` to show progress to next level
* Use `xpLeveling.LevelUpPlayer(pid)` to level up a player `/forcelevelup <pid>`
* Use `xpLeveling.LevelUpMenu(pid)` to open the level up menu `/levelup`

# Install
* Place `vanilla Data` files in `server/data/custom/tes3mp-xp`
* Place everything else in `server/scripts/custom/tes3mp-xp`
* xpCalc.ods is a spreadsheet with formulas you can use to tune xp gain config values
* Add the following to customScripts.lua
```lua
xpLeveling = require("custom.tes3mp-xp.xpLeveling")
xpGain = require("custom.tes3mp-xp.xpGain")
```

# xp_override
* This json can be used to override level/xp values per creature/npc refid or quest
* Note: Quests should be in the format of <quest>_<index>

# Known Issues
* Using `xpConfig.vanillaLeveling = false` will cause several weird issues due to how morrowind works
  * `xpConfig.healthRetroactive = true` and other health settings are safe and can be used with vanillaLeveling = false
* level xp cost formula has had very little testing and may result in strange leveling rates
* Has not been balance tested
* Skill books/Trainers will show messages indicating skills leveling up while not leveling skills
* Using with existing characters will likely cause issues