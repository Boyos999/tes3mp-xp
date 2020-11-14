local experience = {}

require("custom.tes3mp-xp.xpConfig")

--Initialize vanilla data tables
local specs = jsonInterface.load("custom/tes3mp-xp/specializations.json")
local specializations = {"Combat","Magic","Stealth"}
local vanillaClasses = jsonInterface.load("custom/tes3mp-xp/vanilla_classes.json")
local attributes = {"Strength","Intelligence","Willpower","Agility","Speed","Endurance","Personality","Luck"}

--Generate Root Level menu per player
function experience.GenerateLevelMenu(pid)
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
    tes3mp.LogMessage(enumerations.log.ERROR, "Generating Level Menu")
    experience.GenerateSpecMenu(pid)
    experience.GenerateAttrsMenu(pid)
    experience.GenerateCommitMenu(pid)
    tes3mp.LogMessage(enumerations.log.ERROR, "Sub Menus Generated")
end

--General function to generate a generic menu button
function experience.GenerateMenuButton(pid,menuName,dest,element,action,args)
    if action ~= nil then
        button = {
            caption = element,
            destinations = {
                menuHelper.destinations.setDefault(dest,
                {
                    menuHelper.effects.runGlobalFunction("experience",action,args)
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
function experience.GenerateSpecMenu(pid)
    local menuName = "xpSpec" .. pid
    Menus[menuName] = {
        text = "Specialization (".. Players[pid].data.customVariables.xpSkillPts-Players[pid].data.customVariables.xpSkillPtHold ..")",
        buttons = {}
    }
    for _,spec in pairs(specializations) do
        button = experience.GenerateMenuButton(pid,menuName,"xp"..spec..pid,spec)
        table.insert(Menus[menuName].buttons,button)
        experience.GenerateSkillsMenu(pid,spec)
    end
    experience.AddMenuNavigation(pid,menuName,"xpLevel" .. pid)
end

--Generate skill selection menu
function experience.GenerateSkillsMenu(pid,spec)
    local skills = specs[spec]
    local menuName = "xp" .. spec .. pid
    Menus[menuName] = {
        text = spec .. " Skills(".. Players[pid].data.customVariables.xpSkillPts-Players[pid].data.customVariables.xpSkillPtHold ..")",
        buttons = {}
    }
    for _,skill in pairs(skills) do
        button = experience.GenerateMenuButton(pid,menuName,"xp"..skill..pid,skill)
        table.insert(Menus[menuName].buttons,button)
        experience.GenerateValueSelect(pid,"skills",skill,menuName)
    end
    experience.AddMenuNavigation(pid,menuName,"xpSpec" .. pid)
end

--Generate Attribute selection menu
function experience.GenerateAttrsMenu(pid)
    local menuName = "xpAttr" .. pid
    Menus[menuName] = {
        text = "Attributes (".. Players[pid].data.customVariables.xpAttrPts-Players[pid].data.customVariables.xpAttrPtHold .. ")",
        buttons = {}
    }
    for _,attr in pairs(attributes) do
        button = experience.GenerateMenuButton(pid,menuName,"xp"..attr..pid,attr)
        table.insert(Menus[menuName].buttons,button)
        experience.GenerateValueSelect(pid,"attrs",attr,menuName)
    end
    experience.AddMenuNavigation(pid,menuName,"xpLevel"..pid)
end

--Generate value select menus for attributes/skills
function experience.GenerateValueSelect(pid,statType,statName,previousMenu)
    local menuName = "xp" .. statName .. pid
    local statMax
    local statCostPer
    tes3mp.LogMessage(enumerations.log.ERROR,"Generating value select for: " .. menuName .. statType)
    if statType == "attrs" then
        statMax = experience.GetMaxAttrUps(pid,statName)
        statCostPer = 1
    elseif statType == "skills" then
        statMax = experience.GetMaxSkillUps(pid,statName)
        statCostPer = experience.GetSkillPtCost(pid,statName)
    end
    Menus[menuName] = {
        text = statName .. " (" .. statCostPer .. ")",
        buttons = {}
    }
    for val=1,statMax do
        button = experience.GenerateMenuButton(pid,menuName,nil,val.." ("..(val*statCostPer)..")","SaveLevelUpChange",{pid,statType,statName,val,val*statCostPer})
        table.insert(Menus[menuName].buttons,button)
    end
    experience.AddMenuNavigation(pid,menuName,previousMenu)
end

--Generate Commit menu with level up summary
function experience.GenerateCommitMenu(pid)
    local levelUpChanges = Players[pid].data.customVariables.xpLevelUpChanges
    local changeString = ""
    if levelUpChanges == nil then
        levelUpChanges = {}
    end
    if levelUpChanges["attrs"] ~= nil then
        changeString = changeString .. experience.GetLevelUpChangeString(pid,levelUpChanges["attrs"])
    end
    if levelUpChanges["skills"] ~= nil then
        changeString = changeString .. experience.GetLevelUpChangeString(pid,levelUpChanges["skills"])
    end
    Menus["xpCommit" .. pid] = {
        text = changeString,
        buttons = {
            { caption = "Commit Level Up",
                destinations = {
                    menuHelper.destinations.setDefault(nil,
                    {
                        menuHelper.effects.runGlobalFunction("experience","CommitLevelUp",{menuHelper.variables.currentPid()})
                    })
                }
            },
            { caption = "Revert Level Up",
                destinations = {
                    menuHelper.destinations.setDefault(nil,
                    {
                        menuHelper.effects.runGlobalFunction("experience","RevertLevelUpChanges",{menuHelper.variables.currentPid()})
                    })
                }
            }
        }
    }
    experience.AddMenuNavigation(pid,"xpCommit" .. pid,"xpLevel" .. pid)
end

--Revert pending level up changes
function experience.RevertLevelUpChanges(pid)
    Players[pid].data.customVariables.xpLevelUpChanges.skills = {}
    Players[pid].data.customVariables.xpLevelUpChanges.attrs = {}
    Players[pid].data.customVariables.xpAttrPtHold = 0
    Players[pid].data.customVariables.xpSkillPtHold = 0
end

--Format change table as a string for use in the menu
function experience.GetLevelUpChangeString(pid,changeTable)
    local outputString = ""
    for stat,val in pairs(changeTable) do
        outputString = outputString .. stat .. ": " .. val .. "\n"
    end
    return outputString
end

--Save level up change before committing
function experience.SaveLevelUpChange(pid,statType,statName,value,ptCost)
    tes3mp.LogMessage(enumerations.log.ERROR,"Save Change: statType: " .. statType .. ", statName: " .. statName)
    pid = tonumber(pid)
    Players[pid].data.customVariables.xpLevelUpChanges[statType][statName] = value
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
    
    --Re-open menu with new values
    experience.GenerateLevelMenu(pid)
    Players[pid].currentCustomMenu = "xpLevel" .. pid
    menuHelper.DisplayMenu(pid, Players[pid].currentCustomMenu)
    tes3mp.LogMessage(enumerations.log.ERROR, "New menu loaded")
end

--Push level up stats to player
function experience.CommitLevelUp(pid)
    local savedChanges = Players[pid].data.customVariables.xpLevelUpChanges
    
    experience.LevelUpSkills(pid,savedChanges["skills"])
    Players[pid].data.customVariables.xpLevelUpChanges.skills = {}
    Players[pid].data.customVariables.xpSkillPts = (Players[pid].data.customVariables.xpSkillPts - Players[pid].data.customVariables.xpSkillPtHold)
    Players[pid].data.customVariables.xpSkillPtHold = 0
    
    experience.LevelUpAttrs(pid,savedChanges["attrs"])
    Players[pid].data.customVariables.xpLevelUpChanges.attrs = {}
    Players[pid].data.customVariables.xpAttrPts = (Players[pid].data.customVariables.xpAttrPts - Players[pid].data.customVariables.xpAttrPtHold)
    Players[pid].data.customVariables.xpAttrPtHold = 0
    
    Players[pid].data.stats.level = Players[pid].data.stats.level + 1
    Players[pid].data.customVariables.xpLevelUps = Players[pid].data.customVariables.xpLevelUps - 1
    
    --Send updated data to the player
    Players[pid]:LoadStatsDynamic()
    Players[pid]:LoadAttributes()
    Players[pid]:LoadSkills()
    Players[pid]:LoadLevel()
end

--Re-calculate stats
function experience.CalcLevelUpStats(pid)
    local tempFatigue = 0
    if xpConfig.healthRetroactiveEnd then
        --TODO
    else
        Players[pid].data.stats.healthBase = (Players[pid].data.stats.healthBase + (Players[pid].data.attributes.Endurance.base * xpConfig.healthEndLevelMult))
        Players[pid].data.stats.healthCurrent = Players[pid].data.stats.healthBase
    end
    Players[pid].data.stats.magickaBase = (Players[pid].data.attributes.Intelligence.base * xpConfig.magickaIntMult)
    Players[pid].data.stats.magickaCurrent = Players[pid].data.stats.magickaBase
    for attr,mult in pairs(xpConfig.fatigueAttrs) do
        tempFatigue = tempFatigue + (Players[pid].data.attributes[attr].base*mult)
    end
    Players[pid].data.stats.fatigueBase = tempFatigue
    Players[pid].data.stats.fatigueCurrent = tempFatigue
end

--Apply attr ups and re-calc stats
function experience.LevelUpAttrs(pid,attrs)
    for attr,value in pairs(attrs) do
        Players[pid].data.attributes[attr].base = Players[pid].data.attributes[attr].base + value
    end
    experience.CalcLevelUpStats(pid)
end

--Apply skill ups
function experience.LevelUpSkills(pid,skills)
    for skill,value in pairs(skills) do 
        Players[pid].data.skills[skill].base = Players[pid].data.skills[skill].base + value
    end
end

--Function to handle player level up
function experience.LevelUpPlayer(pid)
    local playerSkillPts = Players[pid].data.customVariables.xpSkillPts
    local playerAttrPts = Players[pid].data.customVariables.xpAttrPts
    local playerLevelUps = Players[pid].data.customVariables.xpLevelUps
    
    if Players[pid].data.stats.level >= xpConfig.levelCap then
        return
    end
    
    if playerSkillPts == nil then
        Players[pid].data.customVariables.xpSkillPts = xpConfig.skillPtsPerLevel
    else
        Players[pid].data.customVariables.xpSkillPts = (playerSkillPts + xpConfig.skillPtsPerLevel)
    end
    
    if playerAttrPts == nil then
        Players[pid].data.customVariables.xpAttrPts = xpConfig.attributePtsPerLevel
    else
        Players[pid].data.customVariables.xpAttrPts = (playerAttrPts + xpConfig.attributePtsPerLevel)
    end
    
    if playerLevelUps == nil then
        Players[pid].data.customVariables.xpLevelUps = 1
    else
        Players[pid].data.customVariables.xpLevelUps = (playerLevelUps + 1)
    end
    
    tes3mp.MessageBox(pid, -1, xpConfig.levelUpMessage)
end

--Calculate them maximum number of times a player can level an attribute
function experience.GetMaxAttrUps(pid,attr)
    local playerAttrPts = (Players[pid].data.customVariables.xpAttrPts - Players[pid].data.customVariables.xpAttrPtHold)
    local maxLevels = xpConfig.attributeLvlsPerAttr
    local playerAttrLevel = Players[pid].data.attributes[attr].base
    if Players[pid].data.customVariables.xpLevelUpChanges.attrs[attr] ~= nil then
        playerAttrLevel = playerAttrLevel+Players[pid].data.customVariables.xpLevelUpChanges.attrs[attr]
    end
    
    if maxLevels > playerAttrPts then
        maxLevels = playerAttrPts
    end
    
    if (maxLevels + playerAttrLevel) > xpConfig.attributeCap then
        maxLevels = (xpConfig.attributeCap - playerAttrLevel)
    end
    
    return maxLevels
end

--Calculate the maximum number of times a player can level a skill
function experience.GetMaxSkillUps(pid,skill)
    local playerSkillPts = (Players[pid].data.customVariables.xpSkillPts - Players[pid].data.customVariables.xpSkillPtHold)
    local skillCost = experience.GetSkillPtCost(pid,skill)
    local maxLevels = math.floor(playerSkillPts/skillCost)
    local playerSkillLevel = Players[pid].data.skills[skill].base
    
    if Players[pid].data.customVariables.xpLevelUpChanges.skills[skill] ~= nil then
        playerSkillLevel = playerSkillLevel+Players[pid].data.customVariables.xpLevelUpChanges.skills[skill]
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
      
    --Check if we're hitting skill cap
    if (playerSkillLevel + maxLevels) > xpConfig.skillCap then
        maxLevels = (xpConfig.skillCap - playerSkillLevel)
    end
    return maxLevels
end

--Calculate skill point cost for a specific skill
function experience.GetSkillPtCost(pid,skill)
    local skillCost = xpConfig.skillCost

    if experience.GetIsSpecializationSkill(pid,skill) then
        skillCost = skillCost - xpConfig.skillCostSpecReduction
    end

    if experience.GetIsMajorSkill(pid,skill) then
        skillCost = skillCost - xpConfig.skillCostMajReduction
    elseif experience.GetIsMinorSkill(pid,skill) then
        skillCost = skillCost - xpConfig.skillCostMinReduction
    end

    skillCost = skillCost + experience.GetSkillThresholdCount(pid,skill)*xpConfig.skillCostGroupStep

    return skillCost
end

--Get the number of skill thresholds passed per skill
function experience.GetSkillThresholdCount(pid,skill)
    local skillLevel = Players[pid].data.skills[skill].base
    local thresholds = 0
    for _, val in pairs(xpConfig.skillCostGroups) do
        if skillLevel >= val then
            thresholds = thresholds + 1
        end
    end
    return thresholds
end

--Check if a skill is a player's major skill
function experience.GetIsMajorSkill(pid,skill)
    local majorSkills = experience.GetMajorSkills(pid)
    if tableHelper.containsValue(majorSkills,skill) then
        return true
    else
        return false
    end
end

--Check if a skill is a player's minor skill
function experience.GetIsMinorSkill(pid,skill)
    local minorSkills = experience.GetMinorSkills(pid)
    if tableHelper.containsValue(minorSkills,skill) then
        return true
    else
        return false
    end
end

--Check if a skill falls under a player's specialization
function experience.GetIsSpecializationSkill(pid,skill)
    local spec = experience.GetSpecialization(pid)
    if tableHelper.containsValue(specs[spec],skill) then
        return true
    else
        return false
    end
end

--Retrieve player's major skills
function experience.GetMajorSkills(pid)
    if experience.GetIsCustomClass then
        return experience.SkillsStringToList(Players[pid].data.customClass.majorSkills)
    else
        return vanillaClasses[Players[pid].data.character.class].Majorskills
    end
end

--Retrieve player's minor skills
function experience.GetMinorSkills(pid)
    if experience.GetIsCustomClass then
        return experience.SkillsStringToList(Players[pid].data.customClass.minorSkills)
    else
        return vanillaClasses[Players[pid].data.character.class].Minorskills
    end
end

function experience.SkillsStringToList(inputString)
    local outputTable = {}
    for word in string.gmatch(inputString, '([^, ]+)') do
        table.insert(outputTable,word)
    end
    return outputTable
end

--Retrieve player's specialization
function experience.GetSpecialization(pid)
    if experience.GetIsCustomClass then
        return specializations[Players[pid].data.customClass.specialization+1]
    else
        return vanillaClasses[Players[pid].data.character.class].Specialization
    end

end

--Check if player is a custom class
function experience.GetIsCustomClass(pid)
    if Players[pid].data.character.class == "custom" then
        return true
    else
        return false
    end
end

--Append some generally helpful menu navigation functions
function experience.AddMenuNavigation(pid,menu,previousMenu)
    helpfulbuttons = {
        { caption = "Back",
            destinations = {
                menuHelper.destinations.setDefault(previousMenu)
            }
        },
        { caption = "Root",
            destinations = {
                menuHelper.destinations.setDefault("xpLevel" .. pid)
            }
        },
        { caption = "Exit",
            destinations = {
                menuHelper.destinations.setDefault(nil)
            }
        }
    }
    for _,button in pairs(helpfulbuttons) do
        table.insert(Menus[menu].buttons,button)
    end
end

--Open level up menu command
function experience.LevelUpMenu(pid,cmd)
    experience.GenerateLevelMenu(pid)
    Players[pid].currentCustomMenu = "xpLevel" .. pid
    menuHelper.DisplayMenu(pid, Players[pid].currentCustomMenu)
end

function experience.ForceLevel(pid,cmd)
    experience.LevelUpPlayer(pid)
end

--Don't let players level
function experience.SkillBlocker(eventStatus,pid) 
    if Players[pid].data.customVariables.experienceStatus == 1 then
        Players[pid]:LoadSkills()
        return customEventHooks.makeEventStatus(false,false)
    else
        return customEventHooks.makeEventStatus(nil,nil)
    end
end

--Don't let players level
function experience.AttributeBlocker(eventStatus,pid)
    if Players[pid].data.customVariables.experienceStatus == 1 then
        Players[pid]:LoadAttributes()
        return customEventHooks.makeEventStatus(false,false)
    else
        return customEventHooks.makeEventStatus(nil,nil)
    end
end

--Don't let players level
function experience.LevelBlocker(eventStatus,pid)
    if Players[pid].data.customVariables.experienceStatus == 1 then
        Players[pid]:LoadLevel()
        return customEventHooks.makeEventStatus(false,false)
    else
        return customEventHooks.makeEventStatus(nil,nil)
    end
end

--Only block leveling after character creation
function experience.ActivateBlocker(eventStatus, pid)
    if Players[pid] ~= nil then
        if Players[pid]:IsLoggedIn() then
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
    end
end

customCommandHooks.registerCommand("forcelevelup",experience.ForceLevel)
customCommandHooks.registerCommand("testlevelup",experience.LevelUpMenu)

customEventHooks.registerValidator("OnPlayerAttribute",experience.AttributeBlocker)
customEventHooks.registerValidator("OnPlayerSkill",experience.SkillBlocker)
customEventHooks.registerValidator("OnPlayerLevel",experience.LevelBlocker)

customEventHooks.registerHandler("OnPlayerAuthentified",experience.ActivateBlocker)

return experience