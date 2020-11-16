local xpLeveling = {}

require("custom.tes3mp-xp.xpConfig")

--Initialize vanilla data tables
local specs = jsonInterface.load("custom/tes3mp-xp/specializations.json")
local specializations = {"Combat","Magic","Stealth"}
local vanillaClasses = jsonInterface.load("custom/tes3mp-xp/vanilla_classes.json")
local attributes = {"Strength","Intelligence","Willpower","Agility","Speed","Endurance","Personality","Luck"}

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
    tes3mp.LogMessage(enumerations.log.INFO, "Generating Level Menu for pid: " ..pid)
    xpLeveling.GenerateSpecMenu(pid)
    xpLeveling.GenerateAttrsMenu(pid)
    xpLeveling.GenerateCommitMenu(pid)
    tes3mp.LogMessage(enumerations.log.INFO, "Menu Generation Complete for pid: " ..pid)
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
    local skills = specs[spec]
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
    
    --Re-Generate Menu Values
    xpLeveling.GenerateLevelMenu(pid)
end

--Push level up stats to player
function xpLeveling.CommitLevelUp(pid)
    local savedChanges = Players[pid].data.customVariables.xpLevelUpChanges
    
    xpLeveling.LevelUpSkills(pid,savedChanges["skills"])
    Players[pid].data.customVariables.xpLevelUpChanges.skills = {}
    Players[pid].data.customVariables.xpSkillPts = (Players[pid].data.customVariables.xpSkillPts - Players[pid].data.customVariables.xpSkillPtHold)
    Players[pid].data.customVariables.xpSkillPtHold = 0
    
    xpLeveling.LevelUpAttrs(pid,savedChanges["attrs"])
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
    tes3mp.LogMessage(enumerations.log.INFO,"Player at pid("..pid..") leveled to Level: " .. Players[pid].data.stats.level)
end

--Re-calculate stats
function xpLeveling.CalcLevelUpStats(pid)
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
function xpLeveling.LevelUpAttrs(pid,attrs)
    for attr,value in pairs(attrs) do
        Players[pid].data.attributes[attr].base = Players[pid].data.attributes[attr].base + value
    end
    xpLeveling.CalcLevelUpStats(pid)
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
function xpLeveling.GetMaxAttrUps(pid,attr)
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
function xpLeveling.GetMaxSkillUps(pid,skill)
    local playerSkillPts = (Players[pid].data.customVariables.xpSkillPts - Players[pid].data.customVariables.xpSkillPtHold)
    local skillCost = xpLeveling.GetSkillPtCost(pid,skill)
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

--Get the number of skill thresholds passed per skill
function xpLeveling.GetSkillThresholdCount(pid,skill)
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
    if tableHelper.containsValue(specs[spec],skill) then
        return true
    else
        return false
    end
end

--Retrieve player's major skills
function xpLeveling.GetMajorSkills(pid)
    if xpLeveling.GetIsCustomClass then
        return xpLeveling.SkillsStringToList(Players[pid].data.customClass.majorSkills)
    else
        return vanillaClasses[Players[pid].data.character.class].Majorskills
    end
end

--Retrieve player's minor skills
function xpLeveling.GetMinorSkills(pid)
    if xpLeveling.GetIsCustomClass then
        return xpLeveling.SkillsStringToList(Players[pid].data.customClass.minorSkills)
    else
        return vanillaClasses[Players[pid].data.character.class].Minorskills
    end
end

function xpLeveling.SkillsStringToList(inputString)
    local outputTable = {}
    for word in string.gmatch(inputString, '([^, ]+)') do
        table.insert(outputTable,word)
    end
    return outputTable
end

--Retrieve player's specialization
function xpLeveling.GetSpecialization(pid)
    if xpLeveling.GetIsCustomClass then
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

--Open level up menu command
function xpLeveling.LevelUpMenu(pid)
    xpLeveling.GenerateLevelMenu(pid)
    Players[pid].currentCustomMenu = "xpLevel" .. pid
    menuHelper.DisplayMenu(pid, Players[pid].currentCustomMenu)
end

function xpLeveling.ForceLevel(pid,cmd)
    xpLeveling.LevelUpPlayer(pid)
end

--Don't let players level
function xpLeveling.SkillBlocker(eventStatus,pid) 
    if Players[pid].data.customVariables.xpLevelingStatus == 1 then
        Players[pid]:LoadSkills()
        return customEventHooks.makeEventStatus(false,false)
    else
        return customEventHooks.makeEventStatus(nil,nil)
    end
end

--Don't let players level
function xpLeveling.AttributeBlocker(eventStatus,pid)
    if Players[pid].data.customVariables.xpLevelingStatus == 1 then
        Players[pid]:LoadAttributes()
        return customEventHooks.makeEventStatus(false,false)
    else
        return customEventHooks.makeEventStatus(nil,nil)
    end
end

--Don't let players level
function xpLeveling.LevelBlocker(eventStatus,pid)
    if Players[pid].data.customVariables.xpLevelingStatus == 1 then
        Players[pid]:LoadLevel()
        return customEventHooks.makeEventStatus(false,false)
    else
        return customEventHooks.makeEventStatus(nil,nil)
    end
end

--Only block leveling after character creation
function xpLeveling.ActivateBlocker(eventStatus, pid)
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

customCommandHooks.registerCommand("forcelevelup",xpLeveling.ForceLevel)
customCommandHooks.registerCommand("testlevelup",xpLeveling.LevelUpMenu)

customEventHooks.registerValidator("OnPlayerAttribute",xpLeveling.AttributeBlocker)
customEventHooks.registerValidator("OnPlayerSkill",xpLeveling.SkillBlocker)
customEventHooks.registerValidator("OnPlayerLevel",xpLeveling.LevelBlocker)

customEventHooks.registerHandler("OnPlayerAuthentified",xpLeveling.ActivateBlocker)

return xpLeveling