xpConfig = {}


--Caps
xpConfig.skillCap = 100
xpConfig.attributeCap = 100
xpConfig.levelCap = 100

--Leveling settings

xpConfig.levelUpMessage = "Level Up!"

--Skills

--Skill points given per level
xpConfig.skillPtsPerLevel = 15
--Max times you can level an individual skill
xpConfig.skillLvlsPerSkill = 5
--Base point cost to level skill
xpConfig.skillCost = 5
--Cost reduction for specialization
xpConfig.skillCostSpecReduction = 1
--Cost reduction on minor skills
xpConfig.skillCostMinReduction = 1
--Cost reduction on Major skills
xpConfig.skillCostMajReduction = 2
--Defines Threshold by which skill cost is increased by the step (at 25 a base of 5 costs 6, at 50 7, etc)
xpConfig.skillCostGroups = {25,50,75}
xpConfig.skillCostGroupStep = 1

--Attributes

--Attribute points given per level
xpConfig.attributePtsPerLevel = 12
--Max attribute levels per Attribute
xpConfig.attributeLvlsPerAttr = 5


--Derived stats settings

--Magicka = Int * this multiplier (default = 1)
xpConfig.magickaIntMult = 1
--Re-calculate hp based on endurance value & level each level
xpConfig.healthRetroactiveEnd = false
--Amount of hp gained per point of endurance per level (default = 0.1)
xpConfig.healthEndLevelMult = 0.1
--calculating base health
xpConfig.healthBaseStartAttrs = {Strength = 0.5, Endurance = 0.5}
--Used to give the player additional health on start (default = 0)
xpConfig.healthBaseStartAdd = 0
--Fatigue multipliers (default = 1)
xpConfig.fatigueAttrs = {Strength = 1, Willpower = 1, Agility = 1, Endurance = 1}
xpConfig.fatigueGlobalMult = 1