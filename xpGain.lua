local xpGain = {}

require("custom.tes3mp-xp.xpConfig")

--Vanilla data tables
local creaturesTable = jsonInterface.load("custom/tes3mp-xp/creature_levels.json")
local npcTable = jsonInterface.load("custom/tes3mp-xp/npc_levels.json")
local questTable = jsonInterface.load("custom/tes3mp-xp/quest_ends.json")
local xpOverride = jsonInterface.load("custom/tes3mp-xp/xp_override.json")

--Function to give player xp
function xpGain.GiveXp(pid,experience)
    Players[pid].data.customVariables.xpTotal = Players[pid].data.customVariables.xpTotal+experience
    xpGain.OnXpGain(pid,experience)
end

--Function to get the amount of xp a refid is worth
function xpGain.GetKillXp(refid)
    local refidLevel = xpGain.GetTargetLevel(refid)
    local experience = 0
    if xpOverride.actor[refid] ~= nil then
        if xpOverride.actor[refid].xp ~= nil then
            experience = xpOverride.actor[refid].xp
        end
    else
        experience = xpConfig.baseKillXp + (refidLevel^xpConfig.lvlKillXpFactor)*xpConfig.lvlKillXp
    end
    if xpConfig.killVarianceEnable then
        randVar = math.random(0,xpConfig.killVariance[1]+xpConfig.killVariance[2]) - xpConfig.killVariance[1]
        experience = experience + randVar
    end
    return math.floor(experience)
end

--Function to get the amount of xp a quest is worth
function xpGain.GetQuestXp(pid,quest,index)
    local questXp = xpConfig.baseQuestXp
    local questLvl = xpGain.GetQuestLvl(pid,quest,index)
    
    if xpOverride.quest[quest.."_"..index] ~= nil then
        if xpOverride.quest[quest.."_"..index].xp ~= nil then
            questXp = xpOverride.quest[quest.."_"..index].xp
            return questXp
        end
    end
    
    questXp = xpConfig.baseQuestXp + questLvl*xpConfig.questXpPerPlayerLvl
    
    return questXp
end

--Function to get the level used in the quest xp calculation
function xpGain.GetQuestLvl(pid,quest,index)
    local questLvl = 1
    
    if xpOverride.quest[quest.."_"..index] ~= nil then
        if xpOverride.quest[quest.."_"..index].level ~= nil then
            return xpOverride.quest[quest.."_"..index].level
        end
    end
    
    return xpGain.GetPlayerLevel(pid) 
end

--Function to get the killed npc/creature's level
function xpGain.GetTargetLevel(refid)
    local level = 1
    local records = { xpOverride.actor,
                      RecordStores["npc"].data.generatedRecords,
                      RecordStores["creature"].data.generatedRecords,
                      RecordStores["npc"].data.permanentRecords,
                      RecordStores["creature"].data.permanentRecords,
                      npcTable,
                      creaturesTable }
                      
    for _,recordTable in pairs(records) do
        if recordTable[refid] ~= nil then
            if recordTable[refid].level ~= nil then
                level = recordTable[refid].level
                return level
            end
        end
    end
    
    return level
end

--Check if the player has enough xp to level up
function xpGain.CheckLevelUp(pid)
    if Players[pid].data.customVariables.xpTotal >= Players[pid].data.customVariables.xpLevelCost then
        return true
    end
end

--Function to determine if a given quest stage is the end of a quest
function xpGain.IsQuestEnd(quest,index)
    if questTable[quest.."_"..index] ~= nil then
        return true
    end
    return false
end

--Function to hook into OnActorDeath handler
function xpGain.OnKill(eventStatus,pid,cellDescription)
    if eventStatus.validDefaultHandler then 
        --tes3mp.ReadReceivedActorList()
        local actorListSize = tes3mp.GetActorListSize()

        if actorListSize == 0 then
            return
        end
    
        for i=0, actorListSize - 1 do
            local uniqueIndex = tes3mp.GetActorRefNum(i) .. "-" .. tes3mp.GetActorMpNum(i)
            local refid
            if LoadedCells[cellDescription].data.objectData[uniqueIndex] ~= nil then
                refid = LoadedCells[cellDescription].data.objectData[uniqueIndex].refId
            end
            local experience = xpGain.GetKillXp(refid)
            if tes3mp.DoesActorHavePlayerKiller(i) then
                local killerPid = tes3mp.GetActorKillerPid(i)
                if xpConfig.globalKillXp then
                    for pid,player in pairs(Players) do
                        tes3mp.LogMessage(enumerations.log.INFO, "Player: "..Players[pid].name.."(" ..killerPid..") received: "..experience.." XP for killing refid: "..refid.."("..i..")")
                        xpGain.GiveXp(pid,experience)
                    end
                else
                    tes3mp.LogMessage(enumerations.log.INFO, "Player: "..Players[pid].name.."(" ..killerPid..") received: "..experience.." XP for killing refid: "..refid.."("..i..")")
                    xpGain.GiveXp(killerPid,experience)
                end
            end
        end
    end
end

--Function called whenever a player gains xp to check if the player can level up
function xpGain.OnXpGain(pid,experience)
    tes3mp.MessageBox(pid, -1, xpConfig.xpMessage .. experience)
    if xpGain.CheckLevelUp(pid) then
        xpLeveling.LevelUpPlayer(pid)
        Players[pid].data.customVariables.xpTotal = Players[pid].data.customVariables.xpTotal-Players[pid].data.customVariables.xpLevelCost
        local level = xpGain.GetPlayerLevel(pid) + Players[pid].data.customVariables.xpLevelUps
        Players[pid].data.customVariables.xpLevelCost = xpGain.GetLevelCost(level)
    end
end

--Function to hook into OnPlayerJournal
function xpGain.OnJournal(eventStatus,pid)
    if eventStatus.validDefaultHandler then
        for i=0, tes3mp.GetJournalChangesSize(pid) - 1 do
            local index = tes3mp.GetJournalItemIndex(pid, i)
            local quest = tes3mp.GetJournalItemQuest(pid, i)
            if xpGain.IsQuestEnd(quest,index) then
                if config.shareJournal then
                    for pid,player in pairs(Players) do
                        local experience = xpGain.GetQuestXp(pid,quest,index)
                        tes3mp.LogMessage(enumerations.log.INFO, "Player: "..Players[pid].name.."(" ..pid..") received: "..experience.." XP for finishing quest: "..quest.."("..index..")")
                        xpGain.GiveXp(pid,experience)
                    end
                else
                    local experience = xpGain.GetQuestXp(pid,quest,index)
                    tes3mp.LogMessage(enumerations.log.INFO, "Player: "..Players[pid].name.."(" ..pid..") received: "..experience.." XP for finishing quest: "..quest.."("..index..")")
                    xpGain.GiveXp(pid,experience)
                end
            end
        end
    end
end

--Function to calculate level cost
function xpGain.GetLevelCost(level)
    local tempLevel = level
    if tempLevel <= xpConfig.lvlCostLimit[1] then
        tempLevel = xpConfig.lvlCostLimit[1]
    elseif tempLevel >= xpConfig.lvlCostLimit[2] and xpConfig.lvlCostLimit[2] ~= -1 then
        tempLevel = xpConfig.lvlCostLimit[2]
    end
    return math.floor((xpConfig.baseLvlCost+(tempLevel^xpConfig.lvlCostFactor)*xpConfig.lvlCostMult))
end

--Function to return player level
function xpGain.GetPlayerLevel(pid)
    return Players[pid].data.stats.level
end

--Initialize xpGain custom variables on chargen
function xpGain.Initialize(eventStatus,pid)
    if Players[pid].data.customVariables == nil then
        Players[pid].data.customVariables = {}
    end
    Players[pid].data.customVariables.xpTotal = 0
    Players[pid].data.customVariables.xpLevelCost = xpGain.GetLevelCost(1)
end

--Function to handle xpoverride chat command
function xpGain.AddOverride(pid,cmd)
    if Players[pid].data.settings.staffRank >= xpConfig.minAddOverrideRank then
        if cmd[2] ~= nil then
            if cmd[2] == "help" then
                tes3mp.SendMessage(pid, color.Purple .. "Usage: "..color.White.."/xpoverride <type> <id> <level/xp> <value>\n" ..
                                       color.Purple .. "type: "..color.White.."actor,a,quest,q\n" ..
                                       color.Purple .. "id: "..color.White.."actor refid, or quest in the format of quest_index\n" ..
                                       color.Purple .. "level/xp: "..color.White.."level,xp\n" ..
                                       color.Purple .. "value: "..color.White.."integer value\n")
                return
            elseif cmd[2] == "actor" or cmd[2] == "a" or cmd[2] == "quest" or cmd[2] == "q" then
                local recordType = cmd[2]
                if recordType == "a" then
                    recordType = "actor"
                elseif recordType == "q" then
                    recordType = "quest"
                end
                if cmd[3] ~= nil and (cmd[4] == "level" or cmd[4] == "xp") and cmd[5] ~= nil then
                    local id = cmd[3]
                    local stat = cmd[4]
                    local value = math.floor(tonumber(cmd[5]))
                    if xpOverride[recordType][id] == nil then
                        xpOverride[recordType][id] = {}
                    end
                    xpOverride[recordType][id][stat] = value
                    if xpOverride ~= nil then
                        jsonInterface.save("custom/tes3mp-xp/xp_override.json",xpOverride)
                    end
                    tes3mp.SendMessage(pid, color.Green .. "Override saved for: "..id .."\n")
                    tes3mp.LogMessage(enumerations.log.INFO, "XP Override saved for "..recordType.." "..id.." "..stat.." "..value.." by Player: "..Players[pid].name.."(" ..pid..")")
                    return
                end
            end
        end
        tes3mp.SendMessage(pid, color.Red .."Proper usage of xpoverride: "..color.White.."/xpoverride <type> <id> <level/xp> <value>\nUse /xpoverride help for more info\n")
    else
        tes3mp.LogMessage(enumerations.log.INFO, "Player: "..Players[pid].name.."(" ..pid..") attempted to use the xpoverride command without permission")
    end
end

--Command to show level progress
function xpGain.ShowLevelStatus(pid,cmd)
    tes3mp.MessageBox(pid, -1, "Level Status: " .. color.White .. Players[pid].data.customVariables.xpTotal .. "/" .. Players[pid].data.customVariables.xpLevelCost)
end

customCommandHooks.registerCommand("xpoverride",xpGain.AddOverride)
customCommandHooks.registerCommand("xpstatus",xpGain.ShowLevelStatus)

customEventHooks.registerHandler("OnPlayerJournal",xpGain.OnJournal)
customEventHooks.registerHandler("OnActorDeath",xpGain.OnKill)
customEventHooks.registerHandler("OnPlayerEndCharGen",xpGain.Initialize)