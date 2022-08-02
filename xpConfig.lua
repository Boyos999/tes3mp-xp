xpConfig = {}

---------------------------------------------------------------------------------------------------------------
--Logging------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------

--Begin logs with these strings
xpConfig.xpGainLog = "XP Gain: "
xpConfig.xpLevelLog = "XP Level: "
xpConfig.xpDeathLog = "XP Death: "

---------------------------------------------------------------------------------------------------------------
--Penalties----------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------

--XP lost on death = Level XP Cost * xpDeathMult
xpConfig.xpDeathMult = .1
--Amount of xp lost per day spent in jail
--In vanilla # of days in jail = bounty/100 (rounded up)
xpConfig.xpJailPenalty = 75

--If player xp can go negative
xpConfig.xpPenaltyAllowNegative = true

--Message shown when the player loses xp due to death or jail
xpConfig.xpPenaltyMessage = "You lost XP: " .. color.Red

---------------------------------------------------------------------------------------------------------------
--Party--------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------

--If set to true will share kill xp with allied players
xpConfig.alliedXp = true
--If set to false all allied players will get the full xp amount
xpConfig.splitPartyXp = true
--If set to true will only split allied xp to players in the same cell
xpConfig.enforcePartyLocation = false
--Party XP = experience/(partySize*partyMult)
--The lower this multiplier, the less difference party size makes when using
--splitPartyXp
--Do not set to 0, values lower than 0.5 will result in getting more xp in a party of 2 than 1
xpConfig.partyMult = 0.66
--[[
    Example: at 0.66 an enemy worth 30 xp will give the below amount of xp to each party member per party size
    Party Size  xp
    1           30
    2           22
    3           15
    4           11
    5           9
]]

---------------------------------------------------------------------------------------------------------------
--Kill XP Gain Options-----------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------

--Kill XP given to all online players (for if you're playing coop without any party script)
xpConfig.globalKillXp = false

--XP Gained = baseKillXp + (creatureLevel^lvlKillXpFactor)*lvlKillXp
xpConfig.baseKillXp = 20
xpConfig.lvlKillXp = 10
xpConfig.lvlKillXpFactor = 1.2

--Message receiving xp
xpConfig.xpMessage = "+ "

---------------------------------------------------------------------------------------------------------------
--Level Xp Requirements----------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------

--Level XP Cost = baseLvlCost + (playerLevel^lvlCostFactor)*lvlCostMult
xpConfig.baseLvlCost = 1500
xpConfig.lvlCostMult = 90
xpConfig.lvlCostFactor = 1.6

--Limits on min, max cost of levelup. Use: {0,-1} for no limits
xpConfig.lvlCostLimit = {0,-1} --Player levels: {5,35} levels will max in cost at 35, with a min cost at level 5

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

--Track any skill books not named "bookSkill_*" to overwrite with custom record
xpConfig.additionalSkillBooks = {"sc_fjellnote","sc_grandfatherfrost","sc_sjobalnote","sc_unclesweetshare"}

---------------------------------------------------------------------------------------------------------------
--Topic XP Gain Options----------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------

xpConfig.topicXpBase = 4
--Amount of xp given per previously discovered topics 
--(as a player discovers more topics, they're worth more xp)
xpConfig.topicXpPerTopics = 1
--xp gain increases by the above value every # of topics
xpConfig.topicXpPerTopicsStep = 16

---------------------------------------------------------------------------------------------------------------
--Reputation XP Gain Options-----------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------

--XP = repXpBase + repXpPerRep * Reputation 
xpConfig.repXpBase = 100
xpConfig.repXpPerRep = 5

---------------------------------------------------------------------------------------------------------------
--Admin/moderation---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------

--Minimum rank required to use forcelevelup <pid> chat command
xpConfig.minForceLevelRank = 2
--Minimum rank required to add an xp override
xpConfig.minAddOverrideRank = 2
--Minimum rank required to use give player xp command
xpConfig.minGiveXpRank = 2

---------------------------------------------------------------------------------------------------------------
--Caps---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------

xpConfig.skillCap = 100
xpConfig.attributeCap = 200
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

xpConfig.enableRespec = true

--Set to true to allow players to use training
--NOTE: I'd recommend using with my Training Limiter script
xpConfig.enableTraining = true

---------------------------------------------------------------------------------------------------------------
--Journal Item Settings----------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------

xpConfig.xpJournalEnable = true

--Vars to define journal record
xpConfig.xpJournalId = "xpleveling_journal"
xpConfig.xpJournalName = "Training Journal"
xpConfig.xpJournalIcon = "m\\Tx_book_04.tga"
xpConfig.xpJournalModel = "m\\Text_Octavo_05.nif"

--Contains variable names to display within the Journal menu
--Should be present in Players.data.customVariables
xpConfig.xpJournalDisplay = {
    { var = "xpAttrPts", name = "Attribute Points" },
    { var = "xpSkillPts", name = "Skill Points" },
    { var = "xpLevelUps", name = "Level Ups" },
    { var = "xpTotal", name = "Current XP" },
    { var = "xpLevelCost", name = "Level XP Cost" },
    { var = "xpLevelSound", name = "Level Up Sound"},
    { var = "xpLevelNotif", name = "Level Up Notification"},
    { var = "xpGainNotif", name = "XP Gain Notification"}
}

---------------------------------------------------------------------------------------------------------------
--Skills-------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------

--Skill points given per level
xpConfig.skillPtsPerLevel = 45
--Max times you can level an individual skill
xpConfig.skillLvlsPerSkill = 5
--Base point cost to level skill
xpConfig.skillCost = 3
--Cost reduction for specialization
xpConfig.skillCostSpecReduction = 0
--Cost reduction on minor skills
xpConfig.skillCostMinReduction = 1
--Cost reduction on Major skills
xpConfig.skillCostMajReduction = 1
--Defines Threshold by which skill cost is increased by the step (at 25 a base of 5 costs 6, at 50 7, etc)
xpConfig.skillCostGroups = {30,60,90}
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

--Birthsigns cause issues that require some stats (magicka) to be updated on a slight delay
xpConfig.statUpdateDelay = 50

--If set to false bonuses to attributes will not effect derived stats
xpConfig.statBonusAttrMod = true

--Health
--Attributes used to calculate base health
xpConfig.healthAttrs = {}
--Attributes used to calculate base starting health
xpConfig.healthBaseStartAttrs = {Strength = 0.5, Endurance = 0.5}
--Attributes used to calculate health gain per level
xpConfig.healthPerLevelMult = {Endurance = 0.07}
--Additional health
xpConfig.healthBaseStartAdd = 0

--Fatigue
--Attributes used to calculate base fatigue
xpConfig.fatigueAttrs = {Strength = 1, Willpower = 1, Agility = 1, Endurance = 1}
--Attributes used to calculate fatigue gain per level
xpConfig.fatiguePerLevelMult = {}
--AdditionalFatigue
xpConfig.fatigueStartAdd = 0

--Magicka
--Attributes used to calc base magicka
xpConfig.magickaAttrs = {Intelligence = 1}
--Attributes used to calc magicka gain per level
xpConfig.magickaPerLevelMult = {}
--Additional Magicka
xpConfig.magickaStartAdd = 0

--Set desired effect on magicka mults for these birthsigns
xpConfig.birthsignMagickaMults = {
    fay = {Intelligence = 0.5},
    elfborn = {Intelligence = 1.5},
    wombburned = {Intelligence = 2.0}
}

--Set desired effect on magicka mults for these races
xpConfig.racialMagickaMults = {
    breton = {Intelligence = 0.5}
}
xpConfig.racialMagickaMults["high elf"] = {Intelligence = 1.5}

xpConfig.equipmentMagickaMults = {}

xpConfig.equipmentMagickaMults["mantle of woe"] = {
    slot = enumerations.equipment.ROBE, 
    attributes = {Intelligence = 5.0}
}

return xpConfig
