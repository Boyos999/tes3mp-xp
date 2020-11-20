xpConfig = {}

---------------------------------------------------------------------------------------------------------------
--Kill XP Gain Options-----------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------

--XP Gained = baseKillXp + (creatureLevel^lvlKillXpFactor)*lvlKillXp
xpConfig.baseKillXp = 20
xpConfig.lvlKillXp = 10
xpConfig.lvlKillXpFactor = 1.2

--range of random variance calculated: {below,above}
xpConfig.killVarianceEnable = false
xpConfig.killVariance = {20,20} -- {20,20} will result in experience = experience +/- (1,20)

--Message given on kill
xpConfig.killXpMessage = "You gained XP"

---------------------------------------------------------------------------------------------------------------
--Level Xp Requirements----------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------

--Level XP Cost = baseLvlCost + (playerLevel^lvlCostFactor)*lvlCostMult
xpConfig.baseLvlCost = 200
xpConfig.lvlCostMult = 20
xpConfig.lvlCostFactor = 1.6

--Limits on min, max cost of levelup. Use: {0,-1} for no limits
xpConfig.lvlCostLimitEnable = false
xpConfig.lvlCostLimit = {0,35} --Player levels: {5,35} levels will max in cost at 35, with a min cost at level 5

---------------------------------------------------------------------------------------------------------------
--Admin/moderation---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------

--Minimum rank require to use forcelevelup <pid> chat command
xpConfig.minForceLevelRank = 2

---------------------------------------------------------------------------------------------------------------
--Caps---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------

xpConfig.skillCap = 100
xpConfig.attributeCap = 100
xpConfig.levelCap = 100

---------------------------------------------------------------------------------------------------------------
--Leveling settings--------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------

xpConfig.levelUpMessage = "Level Up!"
xpConfig.noLevelUpMessage = color.Red .. "You can't level up yet"

---------------------------------------------------------------------------------------------------------------
--Skills-------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------

--Skill points given per level
xpConfig.skillPtsPerLevel = 43
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

---------------------------------------------------------------------------------------------------------------
--Attributes---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------

--Attribute points given per level
xpConfig.attributePtsPerLevel = 12
--Max attribute levels per Attribute
xpConfig.attributeLvlsPerAttr = 5

---------------------------------------------------------------------------------------------------------------
--Derived stats settings, SET TO VANILLA BY DEFAULT :)---------------------------------------------------------
---------------------------------------------------------------------------------------------------------------

--Use vanilla magicka & fatigue calculations (setting to false will cause weird issues)
xpConfig.vanillaLeveling = true

--Magicka
--Re-calculate magicka based on attribute values & level each level
xpConfig.magickaRetroactive = true
--Attributes used to calculate base magicka
xpConfig.magickaAttrs = {Intelligence = 1}
--Attributes used to calculate magicka gain per level
xpConfig.magickaPerLevelMult = {}
--Additional magicka
xpConfig.magickaStartAdd = 0

--Health
--Re-calculate hp based on attribute values & level each level
xpConfig.healthRetroactive = false
--Attributes used to calculate base health
xpConfig.healthAttrs = {}
--Attributes used to calculate base starting health
xpConfig.healthBaseStartAttrs = {Strength = 0.5, Endurance = 0.5}
--Attributes used to calculate health gain per level
xpConfig.healthPerLevelMult = {Endurance = 0.1}
--Additional health
xpConfig.healthBaseStartAdd = 0

--Fatigue
--Re-calculate fatigue based on attribute values & level each level
xpConfig.fatigueRetroactive = true
--Attributes used to calculate base fatigue
xpConfig.fatigueAttrs = {Strength = 1, Willpower = 1, Agility = 1, Endurance = 1}
--Attributes used to calculate fatigue gain per level
xpConfig.fatiguePerLevelMult = {}
--AdditionalFatigue
xpConfig.fatigueStartAdd = 0