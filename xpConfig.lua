local xpConfig = {}


--Caps
xpConfig.skillCap = 100
xpConfig.attributeCap = 100
xpConfig.levelCap = 100

--Options
xpConfig.retroactiveEndurance = true

--Leveling settings

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

--Defines Threshold by which skill cost is increased by the step (at 25 a base of 5 costs 6, at 50 7, etc
xpConfig.skillCostGroups = {25,50,75}
xpConfig.skillCostGroupStep = 1

--Attributes

--Attribute points given per level
xpConfig.attributePtsPerLevel = 12
--Max attribute levels per Attribute
xpConfig.attributeLvlsPerAttr = 5