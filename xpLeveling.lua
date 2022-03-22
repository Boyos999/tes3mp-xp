local xpLeveling = {}

require("custom.tes3mp-xp.xpConfig")

--Initialize vanilla data tables
local specSkills = jsonInterface.load("custom/tes3mp-xp/specializations.json")
local specializations = {"Combat","Magic","Stealth"}
local vanillaClasses = jsonInterface.load("custom/tes3mp-xp/vanilla_classes.json")
local attributes = {"Strength","Intelligence","Willpower","Agility","Speed","Endurance","Personality","Luck"}
local attrIds = {Strength = 0, Intelligence = 1, Willpower = 2, Agility = 3, Speed = 4, Endurance = 5, Personality = 6, Luck = 7}

--Generate Root Level menu per player
function xpLeveling.GenerateLevelMenu(pid)
    Menus["xpLevel" .. pid] = { 
        text = "Level up menu",
        buttons = {
            { caption = "Attributes (".. Players[pid].data.customVariables.xpAttrPts-Players[pid].data.customVariables.xpAttrPtHold ..")", 
                destinations = { 
                    menuHelper.destinations.setDefault("xpAttr" .. pid) 
                } 
            },
            { caption = "Skills (".. Players[pid].data.customVariables.xpSkillPts-Players[pid].data.customVariables.xpSkillPtHold ..")", 
                destinations = { 
                    menuHelper.destinations.setDefault("xpSpec" .. pid)                       
                } 
            },
            { caption = "Level Up Summary",
                destinations = {
                    menuHelper.destinations.setDefault("xpCommit" .. pid)
                }
            },
            { caption = "Exit",
                destinations = {
                    menuHelper.destinations.setDefault(nil)
                }
            }
        }
    }
    tes3mp.LogMessage(enumerations.log.INFO, xpConfig.xpLevelLog .. "Generating Level Menu for pid: " ..pid)
    xpLeveling.GenerateSpecMenu(pid)
    xpLeveling.GenerateAttrsMenu(pid)
    xpLeveling.GenerateCommitMenu(pid)
    tes3mp.LogMessage(enumerations.log.INFO, xpConfig.xpLevelLog .. "Menu Generation Complete for pid: " ..pid)
end

--General function to generate a generic menu button
function xpLeveling.GenerateMenuButton(pid,menuName,dest,element,action,args)
    if action ~= nil then
        button = {
            caption = element,
            destinations = {
                menuHelper.destinations.setDefault(dest,
                {
                    menuHelper.effects.runGlobalFunction("xpLeveling",action,args)
                })
            }
        }
    else
        button = {
            caption = element,
            destinations = {
                menuHelper.destinations.setDefault(dest)
            }
        }
    end
    return button
end

--Generate specialization selection menu
function xpLeveling.GenerateSpecMenu(pid)
    local menuName = "xpSpec" .. pid
    Menus[menuName] = {
        text = "Specialization (".. Players[pid].data.customVariables.xpSkillPts-Players[pid].data.customVariables.xpSkillPtHold ..")",
        buttons = {}
    }
    for _,spec in pairs(specializations) do
        button = xpLeveling.GenerateMenuButton(pid,menuName,"xp"..spec..pid,spec)
        table.insert(Menus[menuName].buttons,button)
        xpLeveling.GenerateSkillsMenu(pid,spec)
    end
    xpLeveling.AddMenuNavigation(pid,menuName,"xpLevel"..pid)
end

--Generate skill selection menu
function xpLeveling.GenerateSkillsMenu(pid,spec)
    local skills = specSkills[spec]
    local menuName = "xp" .. spec .. pid
    Menus[menuName] = {
        text = spec .. " Skills(".. Players[pid].data.customVariables.xpSkillPts-Players[pid].data.customVariables.xpSkillPtHold ..")",
        buttons = {}
    }
    for _,skill in pairs(skills) do
        button = xpLeveling.GenerateMenuButton(pid,menuName,"xp"..skill..pid,skill.." ("..xpLeveling.GetSkillPtCost(pid,skill)..")")
        table.insert(Menus[menuName].buttons,button)
        xpLeveling.GenerateValueSelect(pid,"skills",skill,menuName)
    end
    xpLeveling.AddMenuNavigation(pid,menuName,"xpSpec"..pid)
end

--Generate Attribute selection menu
function xpLeveling.GenerateAttrsMenu(pid)
    local menuName = "xpAttr" .. pid
    Menus[menuName] = {
        text = "Attributes (".. Players[pid].data.customVariables.xpAttrPts-Players[pid].data.customVariables.xpAttrPtHold .. ")",
        buttons = {}
    }
    for _,attr in pairs(attributes) do
        button = xpLeveling.GenerateMenuButton(pid,menuName,"xp"..attr..pid,attr)
        table.insert(Menus[menuName].buttons,button)
        xpLeveling.GenerateValueSelect(pid,"attrs",attr,menuName)
    end
    xpLeveling.AddMenuNavigation(pid,menuName,"xpLevel"..pid)
end

--Generate value select menus for attributes/skills
function xpLeveling.GenerateValueSelect(pid,statType,statName,previousMenu)
    local menuName = "xp" .. statName .. pid
    local statMax
    local statCostPer
    
    if statType == "attrs" then
        statMax = xpLeveling.GetMaxAttrUps(pid,statName)
        statCostPer = 1
    elseif statType == "skills" then
        statMax = xpLeveling.GetMaxSkillUps(pid,statName)
        statCostPer = xpLeveling.GetSkillPtCost(pid,statName)
    end
    Menus[menuName] = {
        text = statName .. " (" .. statCostPer .. ")",
        buttons = {}
    }
    for val=1,statMax do
        button = xpLeveling.GenerateMenuButton(pid,menuName,"xpLevel"..pid,val.." ("..(val*statCostPer)..")","SaveLevelUpChange",{pid,statType,statName,val,val*statCostPer})
        table.insert(Menus[menuName].buttons,button)
    end
    xpLeveling.AddMenuNavigation(pid,menuName,previousMenu)
end

--Generate Commit menu with level up summary
function xpLeveling.GenerateCommitMenu(pid)
    local levelUpChanges = Players[pid].data.customVariables.xpLevelUpChanges
    local changeString = "Attributes\n----------\n"
    if levelUpChanges == nil then
        levelUpChanges = {}
    end
    if levelUpChanges["attrs"] ~= nil then
        changeString = changeString .. xpLeveling.GetLevelUpChangeString(pid,levelUpChanges["attrs"])
    end
    changeString = changeString .. "----------\nSkills\n----------\n"
    if levelUpChanges["skills"] ~= nil then
        changeString = changeString .. xpLeveling.GetLevelUpChangeString(pid,levelUpChanges["skills"])
    end
    Menus["xpCommit" .. pid] = {
        text = changeString,
        buttons = {
            { caption = "Commit Level Up",
                destinations = {
                    menuHelper.destinations.setDefault(nil,
                    {
                        menuHelper.effects.runGlobalFunction("xpLeveling","CommitLevelUp",{menuHelper.variables.currentPid()})
                    })
                }
            },
            { caption = "Revert Level Up",
                destinations = {
                    menuHelper.destinations.setDefault(nil,
                    {
                        menuHelper.effects.runGlobalFunction("xpLeveling","RevertLevelUpChanges",{menuHelper.variables.currentPid()})
                    })
                }
            }
        }
    }
    xpLeveling.AddMenuNavigation(pid,"xpCommit" .. pid)
end

--Append some generally helpful menu navigation functions
function xpLeveling.AddMenuNavigation(pid,menu,previousMenu)
    helpfulbuttons = {
        { caption = color.White .. "Back",
            destinations = {
                menuHelper.destinations.setDefault(previousMenu)
            }
        },
        { caption = color.Orange .. "Root",
            destinations = {
                menuHelper.destinations.setDefault("xpLevel" .. pid)
            }
        },
        { caption = color.Red .. "Exit",
            destinations = {
                menuHelper.destinations.setDefault(nil)
            }
        }
    }
    for _,button in pairs(helpfulbuttons) do
        table.insert(Menus[menu].buttons,button)
    end
end

--Respec Confirmation menu
function xpLeveling.GenerateRespecConfirmation(pid)
    local skillRefund = 0
    local attrRefund = 0
    local levelRefund = Players[pid].data.stats.level-1
    local skillPtsRefund = levelRefund*xpConfig.skillPtsPerLevel
    local startSkills = Players[pid].data.customVariables.startSkills
    local startAttrs = Players[pid].data.customVariables.startAttrs
    
    for name,skill in pairs(Players[pid].data.skills) do
        skillRefund = skillRefund + (skill.base - startSkills[name].base)
    end
    
    for name,attr in pairs(Players[pid].data.attributes) do
        attrRefund = attrRefund + (attr.base - startAttrs[name].base)
    end
    
    local menuTextString = "Skill increases to be undone: " .. skillRefund .. "\n"
    menuTextString = menuTextString .. "Attribute increases to be undone: " .. attrRefund .. "\n"
    menuTextString = menuTextString .. "Levels to be refunded: " .. levelRefund .. "\n"
    menuTextString = menuTextString .. "Skill Pts to be refunded: " .. skillPtsRefund .. "\n"
    menuTextString = color.Red .. "Are you sure you want to Re-Spec your character? \n" .. color.White .. menuTextString
    
    Menus["xpRespec"..pid] = {
        text = menuTextString,
        buttons = {
            { caption = color.Green .. "Refund", 
                destinations = { 
                    menuHelper.destinations.setDefault(nil,
                    {
                        menuHelper.effects.runGlobalFunction("xpLeveling","RespecRefund",{menuHelper.variables.currentPid()})
                    }) 
                } 
            },
            { caption = color.Red .. "Cancel",
                destinations = {
                    menuHelper.destinations.setDefault(nil)
                }
            }
        }
    }
    tes3mp.LogMessage(enumerations.log.INFO, xpConfig.xpLevelLog .. "Generated Respec Menu for pid: " ..pid)
end

--Create Journal menu for the player
function xpLeveling.GenerateJournalMenu(pid)
    local journalText = "Leveling Summary\n---------------\n"
    local canLevel = xpLeveling.canLevelUp(pid)
    local canRespec = xpLeveling.canRespec(pid)
    
    for _,entry in pairs(xpConfig.xpJournalDisplay) do
        journalText = journalText .. entry.name .. ": " .. Players[pid].data.customVariables[entry.var] .. "\n"
    end
    
    Menus["xpJournal"..pid] = {
        text = journalText,
        buttons = {}
    }
    if canLevel then
        local tempButton = xpLeveling.GenerateMenuButton(pid,"xpJournal"..pid,"xpLevel"..pid,"Level Up","GenerateLevelMenu",{menuHelper.variables.currentPid()})
        table.insert(Menus["xpJournal"..pid].buttons,tempButton)
    end
    
    if canRespec then
        local tempButton = xpLeveling.GenerateMenuButton(pid,"xpJournal"..pid,"xpRespec"..pid,"Respec","GenerateRespecConfirmation",{menuHelper.variables.currentPid()})
        table.insert(Menus["xpJournal"..pid].buttons,tempButton)
    end
    
    local exitButton = {
        caption = color.Red .. "Exit",
        destinations = {menuHelper.destinations.setDefault(nil)}
    }
    table.insert(Menus["xpJournal"..pid].buttons,exitButton)
    
end

--Perform Level Respec
function xpLeveling.RespecRefund(pid)
    local levelRefund = Players[pid].data.customVariables.xpLevelUps+Players[pid].data.stats.level-1
    local startSkills = tableHelper.deepCopy(Players[pid].data.customVariables.startSkills)
    local startAttrs = tableHelper.deepCopy(Players[pid].data.customVariables.startAttrs)

    --Reset xpLeveling related vars
    Players[pid].data.customVariables.xpSkillPtHold = 0
    Players[pid].data.customVariables.xpSkillPts = levelRefund*xpConfig.skillPtsPerLevel
    Players[pid].data.customVariables.xpAttrPtHold = 0
    Players[pid].data.customVariables.xpAttrPts = levelRefund*xpConfig.attributePtsPerLevel
    Players[pid].data.customVariables.xpLevelUpChanges.skills = {}
    Players[pid].data.customVariables.xpLevelUpChanges.attrs = {}
    Players[pid].data.customVariables.xpLevelUps = levelRefund
    
    --Reset Players skills/attrs/level
    Players[pid].data.stats.level = 1
    Players[pid].data.skills = startSkills
    Players[pid].data.attributes = startAttrs
    
    xpLeveling.UpdatePlayerStats(pid)
    tes3mp.LogMessage(enumerations.log.INFO, xpConfig.xpLevelLog .. "Player: " ..logicHandler.GetChatName(pid) .. " respecced")
end

--Revert pending level up changes
function xpLeveling.RevertLevelUpChanges(pid)
    Players[pid].data.customVariables.xpLevelUpChanges.skills = {}
    Players[pid].data.customVariables.xpLevelUpChanges.attrs = {}
    Players[pid].data.customVariables.xpAttrPtHold = 0
    Players[pid].data.customVariables.xpSkillPtHold = 0
end

--Format change table as a string for use in the menu
function xpLeveling.GetLevelUpChangeString(pid,changeTable)
    local outputString = ""
    for stat,val in pairs(changeTable) do
        outputString = outputString .. stat .. ": " .. val .. "\n"
    end
    return outputString
end

--Save level up change before committing
function xpLeveling.SaveLevelUpChange(pid,statType,statName,value,ptCost)
    tes3mp.LogMessage(enumerations.log.INFO,"Saving Change for pid("..pid.."): statType: " .. statType .. ", statName: " .. statName)
    --I don't know why pid keeps ending up as a string but I suspect menuHelper fuckery
    pid = tonumber(pid)
    --Save pending level up changes
    if Players[pid].data.customVariables.xpLevelUpChanges[statType][statName] ~= nil then
        Players[pid].data.customVariables.xpLevelUpChanges[statType][statName] = Players[pid].data.customVariables.xpLevelUpChanges[statType][statName] + value
    else
        Players[pid].data.customVariables.xpLevelUpChanges[statType][statName] = value
    end
    --Track pending skill/attr point cost
    if statType == "attrs" then
        if Players[pid].data.customVariables.xpAttrPtHold == nil then
            Players[pid].data.customVariables.xpAttrPtHold = ptCost
        else
            Players[pid].data.customVariables.xpAttrPtHold = Players[pid].data.customVariables.xpAttrPtHold+ptCost
        end
    elseif statType == "skills" then
        if Players[pid].data.customVariables.xpSkillPtHold == nil then
            Players[pid].data.customVariables.xpSkillPtHold = ptCost
        else
            Players[pid].data.customVariables.xpSkillPtHold = Players[pid].data.customVariables.xpSkillPtHold+ptCost
        end
    end
    
    --Re-Generate Menu Values
    xpLeveling.GenerateLevelMenu(pid)
end

--Push level up stats to player
function xpLeveling.CommitLevelUp(pid)
    local savedChanges = Players[pid].data.customVariables.xpLevelUpChanges
    
    --Increase player level
    Players[pid].data.stats.level = Players[pid].data.stats.level + 1
    Players[pid].data.customVariables.xpLevelUps = Players[pid].data.customVariables.xpLevelUps - 1
    
    --Commit skill changes
    xpLeveling.LevelUpSkills(pid,savedChanges["skills"])
    Players[pid].data.customVariables.xpLevelUpChanges.skills = {}
    Players[pid].data.customVariables.xpSkillPts = (Players[pid].data.customVariables.xpSkillPts - Players[pid].data.customVariables.xpSkillPtHold)
    Players[pid].data.customVariables.xpSkillPtHold = 0
    
    --Commit attribute changes
    xpLeveling.LevelUpAttrs(pid,savedChanges["attrs"])
    Players[pid].data.customVariables.xpLevelUpChanges.attrs = {}
    Players[pid].data.customVariables.xpAttrPts = (Players[pid].data.customVariables.xpAttrPts - Players[pid].data.customVariables.xpAttrPtHold)
    Players[pid].data.customVariables.xpAttrPtHold = 0
    
    xpLeveling.UpdatePlayerStats(pid)
    
    tes3mp.LogMessage(enumerations.log.INFO, xpConfig.xpLevelLog .. "Player at pid("..pid..") leveled to Level: " .. Players[pid].data.stats.level)
end

--Function to send updated data to the player
function xpLeveling.UpdatePlayerStats(pid)
    Players[pid]:LoadAttributes()
    Players[pid]:LoadSkills()
    Players[pid]:LoadLevel()
    xpLeveling.UpdatePlayerDynamicStats(pid)
end

function xpLeveling.UpdatePlayerDynamicStats(pid)
    --If start health is not set than the player has not finished chargen
    if Players[pid].data.customVariables.xpStartHealth ~= nil then
        xpLeveling.CalcLevelUpStats(pid)
        local timer = tes3mp.CreateTimerEx("updateStatsTimer",xpConfig.statUpdateDelay,"i", pid)
        tes3mp.StartTimer(timer)
    end
end

function updateStatsTimer(pid)
    local healthBase

    if tes3mp.IsWerewolf(pid) then
        healthBase = Players[pid].data.shapeshift.werewolfHealthBase
    else
        healthBase = Players[pid].data.stats.healthBase
    end

    tes3mp.SetHealthBase(pid, healthBase)
    tes3mp.SetMagickaBase(pid, Players[pid].data.stats.magickaBase)
    tes3mp.SetFatigueBase(pid, Players[pid].data.stats.fatigueBase)

    tes3mp.SendStatsDynamic(pid)

    tes3mp.LogMessage(enumerations.log.INFO, xpConfig.xpLevelLog .. "Player: "..logicHandler.GetChatName(pid).." dynamic stats were updated.")
end

function xpLeveling.CalcMaxFatigue(pid)
    local tempFatigue = xpLeveling.CalcRetroStat(pid,xpConfig.fatigueAttrs,xpConfig.fatiguePerLevelMult,xpConfig.fatigueStartAdd)
    Players[pid].data.stats.fatigueBase = tempFatigue
end

function xpLeveling.CalcMaxHealth(pid)
    local tempHealth = xpLeveling.CalcRetroStat(pid,xpConfig.healthAttrs,xpConfig.healthPerLevelMult,Players[pid].data.customVariables.xpStartHealth)
    Players[pid].data.stats.healthBase = tempHealth
end

function xpLeveling.CalcMaxMagicka(pid)
    local magickaAttrs = xpLeveling.handleMaxMagickaEffect(pid,xpConfig.magickaAttrs)
    local tempMagicka = xpLeveling.CalcRetroStat(pid,magickaAttrs,xpConfig.magickaPerLevelMult,xpConfig.magickaStartAdd)
    Players[pid].data.stats.magickaBase = tempMagicka
end

function xpLeveling.handleMaxMagickaEffect(pid,baseTable)
    local birthsign = Players[pid].data.character.birthsign
    local race = Players[pid].data.character.race
    local newTable = tableHelper.deepCopy(baseTable)
    if xpConfig.birthsignMagickaMults[birthsign] ~= nil then
        for attr,value in pairs(xpConfig.birthsignMagickaMults[birthsign]) do
            newTable[attr] = newTable[attr] + value
        end
    end

    if xpConfig.racialMagickaMults[race] ~= nil then
        for attr,value in pairs(xpConfig.racialMagickaMults[race]) do
            newTable[attr] = newTable[attr] + value
        end
    end

    return newTable
end

--Re-calculate stats
function xpLeveling.CalcLevelUpStats(pid)
    xpLeveling.CalcMaxFatigue(pid)
    xpLeveling.CalcMaxHealth(pid)
    xpLeveling.CalcMaxMagicka(pid)
end

--Function to calculate a Retroactive stat
function xpLeveling.CalcRetroStat(pid,baseTable,multTable,add)
    local tempStat = 0
    tempStat = (xpLeveling.CalcFlatStat(pid,baseTable)
    + xpLeveling.CalcLevelMultGainStat(pid,multTable)
    + add)
    return tempStat
end

--Function to calculate a per level stat
function xpLeveling.CalcLevelMultGainStat(pid,multTable)
    local tempGain = 0
    for attr,mult in pairs(multTable) do
        local attrValue = Players[pid].data.attributes[attr].base
        if xpConfig.statBonusAttrMod then
            attrValue = attrValue + tes3mp.GetAttributeModifier(pid,attrIds[attr])
        end
        tempGain = tempGain + attrValue*mult*(Players[pid].data.stats.level-1)
    end
    return tempGain
end

--Function to calculate a flat stat
function xpLeveling.CalcFlatStat(pid,multTable)
    local tempStat = 0
    for attr,mult in pairs(multTable) do
        local attrValue = Players[pid].data.attributes[attr].base
        if xpConfig.statBonusAttrMod then
            attrValue = attrValue + tes3mp.GetAttributeModifier(pid,attrIds[attr])
        end
        tempStat = tempStat + attrValue*mult
    end
    return tempStat
end

--Apply attr ups
function xpLeveling.LevelUpAttrs(pid,attrs)
    for attr,value in pairs(attrs) do
        Players[pid].data.attributes[attr].base = Players[pid].data.attributes[attr].base + value
    end
end

--Apply skill ups
function xpLeveling.LevelUpSkills(pid,skills)
    for skill,value in pairs(skills) do 
        Players[pid].data.skills[skill].base = Players[pid].data.skills[skill].base + value
    end
end

--Function to handle player level up
function xpLeveling.LevelUpPlayer(pid)
    local playerSkillPts = Players[pid].data.customVariables.xpSkillPts
    local playerAttrPts = Players[pid].data.customVariables.xpAttrPts
    local playerLevelUps = Players[pid].data.customVariables.xpLevelUps
    
    --Don't level above cap
    if Players[pid].data.stats.level >= xpConfig.levelCap then
        return
    end
    
    --Add skills points
    if playerSkillPts == nil then
        Players[pid].data.customVariables.xpSkillPts = xpConfig.skillPtsPerLevel
    else
        Players[pid].data.customVariables.xpSkillPts = (playerSkillPts + xpConfig.skillPtsPerLevel)
    end
    
    --Add attribute points
    if playerAttrPts == nil then
        Players[pid].data.customVariables.xpAttrPts = xpConfig.attributePtsPerLevel
    else
        Players[pid].data.customVariables.xpAttrPts = (playerAttrPts + xpConfig.attributePtsPerLevel)
    end
    
    --Add Level up point
    if playerLevelUps == nil then
        Players[pid].data.customVariables.xpLevelUps = 1
    else
        Players[pid].data.customVariables.xpLevelUps = (playerLevelUps + 1)
    end
    
    tes3mp.MessageBox(pid, -1, xpConfig.levelUpMessage)
end

--Calculate them maximum number of times a player can level an attribute
function xpLeveling.GetMaxAttrUps(pid,attr)
    --Remove pending points from the available pool
    local playerAttrPts = (Players[pid].data.customVariables.xpAttrPts - Players[pid].data.customVariables.xpAttrPtHold)
    local maxLevels = xpConfig.attributeLvlsPerAttr
    local playerAttrLevel = Players[pid].data.attributes[attr].base
    --Take pending changes into account for maxLevels
    if Players[pid].data.customVariables.xpLevelUpChanges.attrs[attr] ~= nil then
        playerAttrLevel = playerAttrLevel+Players[pid].data.customVariables.xpLevelUpChanges.attrs[attr]
        maxLevels = maxLevels - Players[pid].data.customVariables.xpLevelUpChanges.attrs[attr]
    end
    
    --Check how many points are available
    if maxLevels > playerAttrPts then
        maxLevels = playerAttrPts
    end
    
    --Check if we're hitting a per-attr cap
    if xpConfig.perAttrCaps[attr] ~= nil then
        if(maxLevels + playerAttrLevel) > xpConfig.perAttrCaps[attr] then
            maxLevels = (xpConfig.perAttrCaps[attr] - playerAttrLevel)
        end
    end
    
    --Check if we're hitting the attribute cap
    if (maxLevels + playerAttrLevel) > xpConfig.attributeCap then
        maxLevels = (xpConfig.attributeCap - playerAttrLevel)
    end
    
    return maxLevels
end

--Calculate the maximum number of times a player can level a skill
function xpLeveling.GetMaxSkillUps(pid,skill)
    --Remove pending points from the available pool
    local playerSkillPts = (Players[pid].data.customVariables.xpSkillPts - Players[pid].data.customVariables.xpSkillPtHold)
    local skillCost = xpLeveling.GetSkillPtCost(pid,skill)
    local maxLevels = math.floor(playerSkillPts/skillCost)
    local playerSkillLevel = Players[pid].data.skills[skill].base
    
    --Take pending changes into account for maxLevels
    if Players[pid].data.customVariables.xpLevelUpChanges.skills[skill] ~= nil then
        playerSkillLevel = playerSkillLevel+Players[pid].data.customVariables.xpLevelUpChanges.skills[skill]
        if maxLevels > (xpConfig.skillLvlsPerSkill-tonumber(Players[pid].data.customVariables.xpLevelUpChanges.skills[skill])) then
            maxLevels = (xpConfig.skillLvlsPerSkill-tonumber(Players[pid].data.customVariables.xpLevelUpChanges.skills[skill]))
        end
    end
    
    --Check max per skill in config
    if maxLevels > xpConfig.skillLvlsPerSkill then
        maxLevels = xpConfig.skillLvlsPerSkill
    end
    --Check if we're crossing any thresholds
    for _,val in pairs(xpConfig.skillCostGroups) do
        if (val-playerSkillLevel) > 0 then
            if maxLevels > (val-playerSkillLevel) then
                maxLevels = (val-playerSkillLevel)
            end
        end
    end
    
    --Check if we're hitting a per-skill cap
    if xpConfig.perSkillCaps[skill] ~= nil then
        if (playerSkillLevel + maxLevels) > xpConfig.perSkillCaps[skill] then
            maxLevels = (xpConfig.perSkillCaps[skill] - playerSkillLevel)
        end
    end
    
    --Check if we're hitting skill cap
    if (playerSkillLevel + maxLevels) > xpConfig.skillCap then
        maxLevels = (xpConfig.skillCap - playerSkillLevel)
    end
    
    return maxLevels
end

--Calculate skill point cost for a specific skill
function xpLeveling.GetSkillPtCost(pid,skill)
    local skillCost = xpConfig.skillCost

    if xpLeveling.GetIsSpecializationSkill(pid,skill) then
        skillCost = skillCost - xpConfig.skillCostSpecReduction
    end

    if xpLeveling.GetIsMajorSkill(pid,skill) then
        skillCost = skillCost - xpConfig.skillCostMajReduction
    elseif xpLeveling.GetIsMinorSkill(pid,skill) then
        skillCost = skillCost - xpConfig.skillCostMinReduction
    end

    skillCost = skillCost + xpLeveling.GetSkillThresholdCount(pid,skill)*xpConfig.skillCostGroupStep

    return skillCost
end

--Get the number of skill thresholds passed for a skill
function xpLeveling.GetSkillThresholdCount(pid,skill)
    local skillLevel = Players[pid].data.skills[skill].base
    local thresholds = 0
    if Players[pid].data.customVariables.xpLevelUpChanges.skills[skill] ~= nil then
        skillLevel = skillLevel + Players[pid].data.customVariables.xpLevelUpChanges.skills[skill]
    end
    for _, val in pairs(xpConfig.skillCostGroups) do
        if skillLevel >= val then
            thresholds = thresholds + 1
        end
    end
    return thresholds
end

--Check if a skill is a player's major skill
function xpLeveling.GetIsMajorSkill(pid,skill)
    local majorSkills = xpLeveling.GetMajorSkills(pid)
    if tableHelper.containsValue(majorSkills,skill) then
        return true
    else
        return false
    end
end

--Check if a skill is a player's minor skill
function xpLeveling.GetIsMinorSkill(pid,skill)
    local minorSkills = xpLeveling.GetMinorSkills(pid)
    if tableHelper.containsValue(minorSkills,skill) then
        return true
    else
        return false
    end
end

--Check if a skill falls under a player's specialization
function xpLeveling.GetIsSpecializationSkill(pid,skill)
    local spec = xpLeveling.GetSpecialization(pid)
    if tableHelper.containsValue(specSkills[spec],skill) then
        return true
    else
        return false
    end
end

--Retrieve player's major skills
function xpLeveling.GetMajorSkills(pid)
    if xpLeveling.GetIsCustomClass(pid) then
        return xpLeveling.SkillsStringToList(Players[pid].data.customClass.majorSkills)
    else
        return vanillaClasses[Players[pid].data.character.class].Majorskills
    end
end

--Retrieve player's minor skills
function xpLeveling.GetMinorSkills(pid)
    if xpLeveling.GetIsCustomClass(pid) then
        return xpLeveling.SkillsStringToList(Players[pid].data.customClass.minorSkills)
    else
        return vanillaClasses[Players[pid].data.character.class].Minorskills
    end
end

--In the player file major/minor skills are saved as a single string,
--this function will split them into a table :)
function xpLeveling.SkillsStringToList(inputString)
    local outputTable = {}
    for word in string.gmatch(inputString, '([^, ]+)') do
        table.insert(outputTable,word)
    end
    return outputTable
end

--Retrieve player's specialization
function xpLeveling.GetSpecialization(pid)
    if xpLeveling.GetIsCustomClass(pid) then
        return specializations[Players[pid].data.customClass.specialization+1]
    else
        return vanillaClasses[Players[pid].data.character.class].Specialization
    end

end

--Check if player is a custom class
function xpLeveling.GetIsCustomClass(pid)
    if Players[pid].data.character.class == "custom" then
        return true
    else
        return false
    end
end

function xpLeveling.canLevelUp(pid)
    if Players[pid].data.customVariables.xpLevelUps > 0 then
        return true
    else
        return false
    end
end

function xpLeveling.canRespec(pid)
    if Players[pid].data.stats.level > 1 and xpConfig.enableRespec then
        return true
    else
        return false
    end
end

--Function to stop a player from using a journal normally
function xpLeveling.UseJournalValidator(eventStatus,pid,refid)
    if refid == xpConfig.xpJournalId then
        return customEventHooks.makeEventStatus(false,true)
    else
        return customEventHooks.makeEventStatus(nil,nil)
    end
end

--Function called when a player uses their journal
function xpLeveling.UseJournalHandler(eventStatus, pid, refid)
    if refid == xpConfig.xpJournalId then
        tes3mp.LogMessage(enumerations.log.INFO, xpConfig.xpLevelLog .. "journal used")
        if eventStatus.validCustomHandler ~= false then
            xpLeveling.GenerateJournalMenu(pid)
            tes3mp.LogMessage(enumerations.log.INFO, xpConfig.xpLevelLog .. "journal menu generated")
            Players[pid].currentCustomMenu = "xpJournal" .. pid
            menuHelper.DisplayMenu(pid, Players[pid].currentCustomMenu)
        
        end
    end
end

--Function to give player a "journal" that can be used
--to perform leveling actions
function xpLeveling.AddLevelJournal(eventStatus, pid)
    if eventStatus.validDefaultHandler and xpConfig.xpJournalEnable then
        local bookRecords = RecordStores["book"]
        local bookId = xpConfig.xpJournalId
        
        if bookRecords.data.permanentRecords[bookId] == nil then
            local bookRecord = {}
            bookRecord["name"] = xpConfig.xpJournalName
            bookRecord["model"] = xpConfig.xpJournalModel
            bookRecord["icon"] = xpConfig.xpJournalIcon
            bookRecord["skillId"] = "-1"
            
            bookRecords.data.permanentRecords[bookId] = bookRecord
            bookRecords:QuicksaveToDrive()
            
            tes3mp.SetRecordType(enumerations.recordType[string.upper("book")])
            packetBuilder.AddBookRecord(bookId, bookRecord)
            tes3mp.SendRecordDynamic(pid, true, false)
            
        end
        
        inventoryHelper.addItem(Players[pid].data.inventory, bookId, 1)
        
        Players[pid]:LoadItemChanges({{refId = bookId, count = 1}},enumerations.inventory.ADD)
    end
end

--Save Player starting skills and attributes for re-spec
function xpLeveling.SaveStartSkills(pid)
    Players[pid].data.customVariables.startSkills = Players[pid].data.skills
end

function xpLeveling.SaveStartAttributes(pid)
    Players[pid].data.customVariables.startAttrs = Players[pid].data.attributes
end

--Function to open Respec menu
function xpLeveling.RespecMenu(pid)
    if xpLeveling.canRespec(pid) then
        xpLeveling.GenerateRespecConfirmation(pid)
        Players[pid].currentCustomMenu = "xpRespec" .. pid
        menuHelper.DisplayMenu(pid, Players[pid].currentCustomMenu)
    end
end

--Open level up menu command
function xpLeveling.LevelUpMenu(pid)
    if xpLeveling.canLevelUp(pid) then
        xpLeveling.GenerateLevelMenu(pid)
        Players[pid].currentCustomMenu = "xpLevel" .. pid
        menuHelper.DisplayMenu(pid, Players[pid].currentCustomMenu)
    else
        tes3mp.MessageBox(pid, -1, xpConfig.noLevelUpMessage)
    end
end

--Admin command to grant a level
function xpLeveling.ForceLevel(pid,cmd)
    if (Players[pid].data.settings.staffRank >= xpConfig.minForceLevelRank) and cmd[2] ~= nil then
        xpLeveling.LevelUpPlayer(tonumber(cmd[2]))
    elseif (Players[pid].data.settings.staffRank < xpConfig.minForceLevelRank) then
        tes3mp.LogMessage(enumerations.log.INFO, xpConfig.xpLevelLog .. "Player: "..logicHandler.GetChatName(pid).." attempted to use the forcelevelup command without permission")
    end
end

--Don't let players level
function xpLeveling.SkillBlocker(eventStatus,pid) 
    if Players[pid].data.customVariables.xpStatus == 1 then
        Players[pid]:LoadSkills()
        return customEventHooks.makeEventStatus(false,nil)
    else
        return customEventHooks.makeEventStatus(nil,nil)
    end
end

--Don't let players level
function xpLeveling.LevelBlocker(eventStatus,pid)
    if Players[pid].data.customVariables.xpStatus == 1 then
        Players[pid]:LoadLevel()
        return customEventHooks.makeEventStatus(false,false)
    else
        return customEventHooks.makeEventStatus(nil,nil)
    end
end

--Block leveling and update stats
function xpLeveling.OnPlayerAuthentified(eventStatus, pid)
    if Players[pid] ~= nil then
        if Players[pid]:IsLoggedIn() and eventStatus.validDefaultHandler and eventStatus.validCustomHandlers then
            if Players[pid].data.customVariables.xpStatus ~= 1 then
                Players[pid].data.customVariables.xpStatus = 1
                initializationVars = {"xpAttrPts","xpAttrPtHold","xpSkillPts","xpSkillPtHold","xpLevelUps"}
                for _,var in pairs(initializationVars) do
                    if Players[pid].data.customVariables[var] == nil then
                        Players[pid].data.customVariables[var] = 0
                    end
                end
                if Players[pid].data.customVariables.xpLevelUpChanges == nil then
                    Players[pid].data.customVariables.xpLevelUpChanges = {}
                end
                if Players[pid].data.customVariables.xpLevelUpChanges.attrs == nil then
                    Players[pid].data.customVariables.xpLevelUpChanges.attrs = {}
                end
                if Players[pid].data.customVariables.xpLevelUpChanges.skills == nil then
                    Players[pid].data.customVariables.xpLevelUpChanges.skills = {}
                end
            end
            xpLeveling.UpdatePlayerDynamicStats(pid)
        end
    end
end

--Save player's starting health
function xpLeveling.UpdateStartingStats(eventStatus,pid)
    if eventStatus.validDefaultHandler then
        xpLeveling.SaveStartSkills(pid)
        xpLeveling.SaveStartAttributes(pid)
        Players[pid].data.customVariables.xpStartHealth = xpLeveling.CalcFlatStat(pid,xpConfig.healthBaseStartAttrs) + xpConfig.healthBaseStartAdd
        xpLeveling.CalcLevelUpStats(pid)
        Players[pid]:LoadStatsDynamic()
    end
end

function xpLeveling.OnDynamicStatChange(eventStatus,pid)
    if eventStatus.validDefaultHandler and eventStatus.validCustomHandlers then
        xpLeveling.UpdatePlayerDynamicStats(pid)
    end
end

customCommandHooks.registerCommand("respec",xpLeveling.RespecMenu)
customCommandHooks.registerCommand("forcelevelup",xpLeveling.ForceLevel)
customCommandHooks.registerCommand("levelup",xpLeveling.LevelUpMenu)
--customCommandHooks.registerCommand("ustats",xpLeveling.UpdatePlayerStats)

customEventHooks.registerValidator("OnPlayerItemUse",xpLeveling.UseJournalValidator)
customEventHooks.registerValidator("OnPlayerSkill",xpLeveling.SkillBlocker)
customEventHooks.registerValidator("OnPlayerLevel",xpLeveling.LevelBlocker)

customEventHooks.registerHandler("OnPlayerItemUse",xpLeveling.UseJournalHandler)
customEventHooks.registerHandler("OnPlayerEndCharGen",xpLeveling.UpdateStartingStats)
customEventHooks.registerHandler("OnPlayerEndCharGen",xpLeveling.AddLevelJournal)
customEventHooks.registerHandler("OnPlayerAuthentified",xpLeveling.OnPlayerAuthentified)
customEventHooks.registerHandler("OnPlayerAttribute",xpLeveling.OnDynamicStatChange)

return xpLeveling