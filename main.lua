local experience = {}

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
            { caption = "Attributes (".. Players[pid].data.customVariables.xpAttrPts ..")", 
                destinations = { 
                    menuHelper.destinations.setDefault("xpAttr" .. pid) 
                } 
            },
            { caption = "Skills (".. Players[pid].data.customVariables.xpSkillPts ..")", 
                destinations = { 
                    menuHelper.destinations.setDefault("xpSpec" .. pid) 
                } 
            },
            { caption = "Exit",
                destinations = {
                    menuHelper.destinations.setDefault(nil)
                }
            }
        }
    }
    experience.GenerateSpecMenu(pid)
    experience.GenerateAttrsMenu(pid)
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
        text = "Specialization (".. Players[pid].data.customVariables.xpSkillPts ..")",
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
        text = spec .. " Skills(".. Players[pid].data.customVariables.xpSkillPts ..")",
        buttons = {}
    }
    for _,skill in pairs(skills) do
        button = experience.GenerateMenuButton(pid,menuName,"xp"..skill..pid,skill)
        table.insert(Menus[menuName].buttons,button)
    end
    experience.AddMenuNavigation(pid,menuName,"xpSpec" .. pid)
end

--Generate Attribute selection menu
function experience.GenerateAttrsMenu(pid)
    local menuName = "xpAttr" .. pid
    Menus[menuName] = {
        text = "Attributes (".. Players[pid].data.customVariables.xpAttrPts .. ")",
        buttons = {}
    }
    for _,attr in pairs(attributes) do
        button = experience.GenerateMenuButton(pid,menuName,"xp"..attr..pid,attr)
        table.insert(Menus[menuName].buttons,button)
    end
    experience.AddMenuNavigation(pid,menuName,"xpLevel"..pid)
end

--Calculate skill point cost for a specific skill
function experience.GetSkillPtCost(pid,skill)
    local baseCost = xpConfig.skillCost
    if experience.GetIsSpecializationSkill(pid,skill)
        baseCost = baseCost - xpConfig.skillCostSpecReduction
    end
    
    if experience.GetIsMajorSkill(pid,skill)
        baseCost = baseCost - xpConfig.skillCostMajReduction
    elseif experience.GetIsMinorSkill(pid,skill)
        baseCost = baseCost - xpConfig.skillCostMinReduction
    end
    baseCost = baseCost + experience.GetSkillThresholdCount(pid,skill)*xpConfig.skillCostGroupStep
    return baseCost
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
    if tableHelper.containsValue(specs[spec],skill)
        return true
    else
        return false
    end
end

--Retrieve player's major skills
function experience.GetMajorSkills(pid)
    if experience.GetIsCustomClass then
        return split(Players[pid].data.customClass.majorSkills,",")
    else
        return vanillaClasses[Players[pid].data.character.class].Majorskills
    end
end

--Retrieve player's minor skills
function experience.GetMinorSkills(pid)
    if experience.GetIsCustomClass then
        return split(Players[pid].data.customClass.minorSkills,",")
    else
        return vanillaClasses[Players[pid].data.character.class].Minorskills
    end
end

--Retrieve player's specialization
function experience.GetSpecialization(pid)
    if experience.GetIsCustomClass then
        return specializations[Players[pid].data.customClass.specialization]
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
            Players[pid].data.customVariables.experienceStatus = 1
        end
    end
end

customCommandHooks.registerCommand("testlevelup",experience.LevelUpMenu)

customEventHooks.registerValidator("OnPlayerAttribute",experience.AttributeBlocker)
customEventHooks.registerValidator("OnPlayerSkill",experience.SkillBlocker)
customEventHooks.registerValidator("OnPlayerLevel",experience.LevelBlocker)

customEventHooks.registerHandler("OnPlayerAuthentified",experience.ActivateBlocker)

return experience