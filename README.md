# tes3mp-xp

# Features
* Fully re-implemented leveling system
* Extensive configs to customize derived stats, xp gain on kill, and xp cost to level
* Experience gain on kill
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

# Known Issues
* Using `xpConfig.vanillaLeveling = false` will cause several weird issues due to how morrowind works
* level xp cost formula sucks
* Has not been balance tested