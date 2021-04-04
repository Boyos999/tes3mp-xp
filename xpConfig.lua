xpConfig = {}

---------------------------------------------------------------------------------------------------------------
--Logging------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------

--Begin logs with these strings
xpConfig.xpGainLog = "XP Gain: "
xpConfig.xpLevelLog = "XP Level: "

---------------------------------------------------------------------------------------------------------------
--Kill XP Gain Options-----------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------

--Kill XP given to all online players (for if you're playing coop without any party script)
xpConfig.globalKillXp = false

--XP Gained = baseKillXp + (creatureLevel^lvlKillXpFactor)*lvlKillXp
xpConfig.baseKillXp = 20
xpConfig.lvlKillXp = 10
xpConfig.lvlKillXpFactor = 1.2

--range of random variance calculated: {below,above}
xpConfig.killVarianceEnable = false
xpConfig.killVariance = {20,20} -- {20,20} will result in experience = experience +/- (1,20)

--Message receiving xp
xpConfig.xpMessage = "You gained XP: "

---------------------------------------------------------------------------------------------------------------
--Level Xp Requirements----------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------

--Level XP Cost = baseLvlCost + (playerLevel^lvlCostFactor)*lvlCostMult
xpConfig.baseLvlCost = 500
xpConfig.lvlCostMult = 30
xpConfig.lvlCostFactor = 1.6

--Limits on min, max cost of levelup. Use: {0,-1} for no limits
xpConfig.lvlCostLimit = {0,35} --Player levels: {5,35} levels will max in cost at 35, with a min cost at level 5

---------------------------------------------------------------------------------------------------------------
--Quest XP Gain Options----------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------

xpConfig.baseQuestXp = 100
xpConfig.questXpPerPlayerLvl = 25

---------------------------------------------------------------------------------------------------------------
--Book XP Gain Options-----------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------

xpConfig.bookXpBase = 5
xpConfig.bookXpPerValue = 0.25

---------------------------------------------------------------------------------------------------------------
--Admin/moderation---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------

--Minimum rank require to use forcelevelup <pid> chat command
xpConfig.minForceLevelRank = 2
xpConfig.minAddOverrideRank = 2
xpConfig.minGiveXpRank = 2

---------------------------------------------------------------------------------------------------------------
--Caps---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------

xpConfig.skillCap = 100
xpConfig.attributeCap = 100
xpConfig.levelCap = 100

xpConfig.perSkillCaps = {}
xpConfig.perAttrCaps = {}

--[[ Example Usage
xpConfig.perSkillCaps = {
    mercantile = 50,
    enchant = 75
}
xpConfig.perAttrCaps = {
    endurance = 50
}
]]--

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

--Health
--Attributes used to calculate base health
xpConfig.healthAttrs = {}
--Attributes used to calculate base starting health
xpConfig.healthBaseStartAttrs = {Strength = 0.5, Endurance = 0.5}
--Attributes used to calculate health gain per level
xpConfig.healthPerLevelMult = {Endurance = 0.1}
--Additional health
xpConfig.healthBaseStartAdd = 0

--%%%%%% DO NOT CHANGE %%%%%%
--Fatigue
--Attributes used to calculate base fatigue
xpConfig.fatigueAttrs = {Strength = 1, Willpower = 1, Agility = 1, Endurance = 1}
--Attributes used to calculate fatigue gain per level
xpConfig.fatiguePerLevelMult = {}
--AdditionalFatigue
xpConfig.fatigueStartAdd = 0

return xpConfig