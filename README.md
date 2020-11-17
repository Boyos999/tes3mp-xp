# tes3mp-xp

# Features
* Fully re-implemented leveling system
* Extensive configs to customize derived stats
* Use `xpLeveling.LevelUpPlayer(pid)` to level up a player `/forcelevelup <pid>`
* Use `xpLeveling.LevelUpMenu(pid)` to open the level up menu `/levelup`

# Install
* Place `vanilla Data` files in `server/data/custom/tes3mp-xp`
* Place everything else in `server/scripts/custom/tes3mp-xp`
* Add `xpLeveling = require("custom.tes3mp-xp.xpLeveling")` to customScripts.lua

# Known Issues
* Using `xpConfig.vanillaLeveling = false` will cause several weird issues due to how morrowind works