local xpGain = {}

require("custom.tes3mp-xp.xpConfig")

--Vanilla data tables
local creaturesTable = jsonInterface.load("custom/tes3mp-xp/creature_levels.json")
local npcTable = jsonInterface.load("custom/tes3mp-xp/npc_levels.json")
local questTable = jsonInterface.load("custom/tes3mp-xp/quest_ends.json")
local xpOverride = jsonInterface.load("custom/tes3mp-xp/xp_override.json")
local bookTable = jsonInterface.load("custom/tes3mp-xp/vanilla_books.json")

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

--Function to calculate how much xp a player is given for a topic
function xpGain.GetTopicXp(pid,topicId)
    local experience = 0
    
    if config.shareTopics == true then
        if WorldInstance.data.customVariables.xpTopics ~= nil then
            experience = math.floor(xpConfig.topicXpBase+xpConfig.topicXpPerTopics*math.floor(WorldInstance.data.customVariables.xpTopics/xpConfig.topicXpPerTopicsStep))
            WorldInstance.data.customVariables.xpTopics = WorldInstance.data.customVariables.xpTopics + 1
        else
            experience = xpConfig.topicXpBase
            WorldInstance.data.customVariables.xpTopics = 1
        end
    else
        if Players[pid].data.customVariables.xpTopics ~= nil then
            experience = math.floor(xpConfig.topicXpBase+xpConfig.topicXpPerTopics*math.floor(Players[pid].data.customVariables.xpTopics/xpConfig.topicXpPerTopicsStep))
            Players[pid].data.customVariables.xpTopics = Players[pid].data.customVariables.xpTopics+1
        else
            experience = xpConfig.topicXpBase
            Players[pid].data.customVariables.xpTopics = 1
        end
    end
    
    if xpOverride.topic[topicId] ~= nil then
        if xpOverride.topic[topicId].xp ~= nil then
            experience = xpOverride.topic[topicId].xp
        end
    end
    
    return experience
end

--Function to calculate how much xp a player gets from reading a book
function xpGain.GetBookXp(pid,bookId)
    local bookXp = math.floor(xpConfig.bookXpBase + xpConfig.bookXpPerValue*bookTable[bookId].value)
    if xpOverride.book[bookId] ~= nil then
        if xpOverride.book[bookId].xp ~= nil then
            bookXp = xpOverride.book[bookId].xp
        elseif xpOverride.book[bookId].value ~= nil then
            bookXp = math.floor(xpConfig.bookXpBase + xpConfig.bookXpPerValue*xpOverride.book[bookId].value)
        end
    end
    return bookXp
end

--Function to get the level used in the quest xp calculation
function xpGain.GetQuestLvl(pid,quest,index)
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
            elseif recordTable[refid].baseId ~= nil then
                if npcTable[baseId] ~= nil then
                    level = npcTable[baseId].level
                elseif creaturesTable[baseId] ~= nil then
                    level = creaturesTable[baseId].level
                end
                return level
            end
        end
    end
    tes3mp.LogMessage(enumerations.log.WARN, xpConfig.xpGainLog .. "Level Not found for refid: " .. refid)
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
            if refid ~= nil then
                local experience = xpGain.GetKillXp(refid)
                if tes3mp.DoesActorHavePlayerKiller(i) then
                    local killerPid = tes3mp.GetActorKillerPid(i)
                    if xpConfig.globalKillXp then
                        for pid,player in pairs(Players) do
                            tes3mp.LogMessage(enumerations.log.INFO, xpConfig.xpGainLog .. "Player: "..logicHandler.GetChatName(pid).." received: "..experience.." XP for Player: "..logicHandler.GetChatName(killerPid).. "killing refid: "..refid.."("..i..")")
                            xpGain.GiveXp(pid,experience)
                        end
                    elseif xpParty ~= nil and xpParty.GetParty(killerPid) ~= false then
                        local partyName = xpParty.GetParty(killerPid)
                        local partyMembers = xpParty.GetMembers(partyName)
                        local partySize = xpParty.GetSize(partyName)
                        if xpConfig.enforcePartyLocation then
                            local tempMembers = {}
                            local tempSize = 0
                            for _,member in pairs(partyMembers) do
                                if Players[member].data.location.cell == cellDescription then
                                    tempSize = tempSize + 1
                                    table.insert(tempMembers,member)
                                end
                            end
                            partyMembers = tempMembers
                            partySize = tempSize
                        end
                        if xpConfig.splitPartyXp then
                            experience = math.floor(experience/partySize)
                        end
                        for _,member in pairs(partyMembers) do
                            tes3mp.LogMessage(enumerations.log.INFO, xpConfig.xpGainLog .. "Player: "..logicHandler.GetChatName(member).." received: "..experience.." XP for Player: "..logicHandler.GetChatName(killerPid).." in Party: "..partyName.." killing refid: "..refid.."("..i..")")
                            xpGain.GiveXp(member,experience)
                        end
                    else
                        tes3mp.LogMessage(enumerations.log.INFO, xpConfig.xpGainLog .. "Player: "..logicHandler.GetChatName(killerPid).." received: "..experience.." XP for killing refid: "..refid.."("..i..")")
                        xpGain.GiveXp(killerPid,experience)
                    end
                end
            else
                tes3mp.LogMessage(enumerations.log.WARN, xpConfig.xpGainLog .. "Could not identify refid for uniqueIndex: " .. uniqueIndex)
            end
        end
    end
end

--Function to hook into OnPlayerTopic Validator
function xpGain.OnTopic(eventStatus,pid)
    for index = 0, tes3mp.GetTopicChangesSize(pid) - 1 do
        
        local topicId = tes3mp.GetTopicId(pid,index)
        
        if config.shareTopics == true then
            if not tableHelper.containsValue(WorldInstance.data.topics, topicId) then
                local experience = xpGain.GetTopicXp(pid,topicId)
                tes3mp.LogMessage(enumerations.log.INFO, xpConfig.xpGainLog .. "Player: "..Players[pid].name.."("..pid..") received: "..experience.." XP for unlocking topic: "..topicId)
                for i,player in pairs(Players) do
                    xpGain.GiveXp(i,experience)
                end
            end
        else
            if not tableHelper.containsValue(Players[pid].data.topics, topicId) then
                local experience = xpGain.GetTopicXp(pid,topicId)
                tes3mp.LogMessage(enumerations.log.INFO, xpConfig.xpGainLog .. "Player: "..Players[pid].name.."("..pid..") received: "..experience.." XP for unlocking topic: "..topicId)
                xpGain.GiveXp(pid,experience)
            end
        end
        
    end
end

--Function to hook into OnPlayerBook validator
function xpGain.OnBook(eventStatus,pid)
    for index = 0, tes3mp.GetBookChangesSize(pid) - 1 do
        local bookId = tes3mp.GetBookId(pid, index)

        -- Only give xp for books the player hasn't read
        if not tableHelper.containsValue(Players[pid].data.books, bookId, false) then
            if bookTable[bookId] ~= nil then
                local experience = xpGain.GetBookXp(pid,bookId)
                tes3mp.LogMessage(enumerations.log.INFO, xpConfig.xpGainLog .. "Player: "..Players[pid].name.."("..pid..") received: "..experience.." XP for reading: "..bookId)
                xpGain.GiveXp(pid,experience)
            end
        end
    end
end

--Function called whenever a player gains xp to check if the player can level up
function xpGain.OnXpGain(pid,experience)
    if experience > 0 then
        tes3mp.MessageBox(pid, -1, xpConfig.xpMessage .. experience)
        if xpGain.CheckLevelUp(pid) then
            xpGain.GiveLevelUp(pid)
        end
    end
end

--Function to handle giving the player a level up
function xpGain.GiveLevelUp(pid)
    xpLeveling.LevelUpPlayer(pid)
    
    Players[pid].data.customVariables.xpTotal = Players[pid].data.customVariables.xpTotal-Players[pid].data.customVariables.xpLevelCost
    local level = xpGain.GetPlayerLevel(pid) + Players[pid].data.customVariables.xpLevelUps
    Players[pid].data.customVariables.xpLevelCost = xpGain.GetLevelCost(level)
    
    if xpGain.CheckLevelUp(pid) then
        xpGain.GiveLevelUp(pid)
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
                        tes3mp.LogMessage(enumerations.log.INFO, xpConfig.xpGainLog .. "Player: "..Players[pid].name.."(" ..pid..") received: "..experience.." XP for finishing quest: "..quest.."("..index..")")
                        xpGain.GiveXp(pid,experience)
                    end
                else
                    local experience = xpGain.GetQuestXp(pid,quest,index)
                    tes3mp.LogMessage(enumerations.log.INFO, xpConfig.xpGainLog .. "Player: "..Players[pid].name.."(" ..pid..") received: "..experience.." XP for finishing quest: "..quest.."("..index..")")
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

--Function to handle givexp admin command
function xpGain.GiveXpCommand(pid,cmd)
    if Players[pid].data.settings.staffRank >= xpConfig.minGiveXpRank then
        if cmd[2] ~= nil and cmd[3] ~= nil then
            if Players[tonumber(cmd[2])] ~= nil then
                xpGain.GiveXp(tonumber(cmd[2]),math.floor(tonumber(cmd[3])))
                return
            end
        end
        tes3mp.SendMessage(pid, color.Red .."Proper usage of givexp: "..color.White.."/givexp <pid> <integer>\n")
    else
        tes3mp.LogMessage(enumerations.log.INFO, xpConfig.xpGainLog .. "Player: "..Players[pid].name.."(" ..pid..") attempted to use the givexp command without permission")
    end
end

--Function to handle xpoverride chat command
function xpGain.AddOverride(pid,cmd)
    if Players[pid].data.settings.staffRank >= xpConfig.minAddOverrideRank then
        if cmd[2] ~= nil then
            if cmd[2] == "help" then
                tes3mp.SendMessage(pid, color.Purple .. "Usage: "..color.White.."/xpoverride <type> <id> <level/xp> <value>\n" ..
                                       color.Purple .. "type: "..color.White.."actor,a,quest,q,book,b,topic,t\n" ..
                                       color.Purple .. "id: "..color.White.."actor refid, quest in the format of quest_index, book refid, or topicId\n" ..
                                       color.Purple .. "level/xp: "..color.White.."level,xp,value\n" ..
                                       color.Purple .. "value: "..color.White.."integer value\n")
                return
            elseif cmd[2] == "actor" or cmd[2] == "a" or cmd[2] == "quest" or cmd[2] == "q" or cmd[2] == "book" or cmd[2] == "b" or cmd[2] == "topic" or cmd[2] == "t" then
                local recordType = cmd[2]
                if recordType == "a" then
                    recordType = "actor"
                elseif recordType == "q" then
                    recordType = "quest"
                elseif recordType == "t" then
                    recordType = "topic"
                elseif recordType == "b" then
                    recordType = "book"
                end
                if cmd[3] ~= nil and (cmd[4] == "level" or cmd[4] == "xp" or cmd[4] == "value") and cmd[5] ~= nil then
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
                    tes3mp.LogMessage(enumerations.log.INFO, xpConfig.xpGainLog .. "XP Override saved for "..recordType.." "..id.." "..stat.." "..value.." by Player: "..Players[pid].name.."(" ..pid..")")
                    return
                end
            end
        end
        tes3mp.SendMessage(pid, color.Red .."Proper usage of xpoverride: "..color.White.."/xpoverride <type> <id> <level/xp> <value>\nUse /xpoverride help for more info\n")
    else
        tes3mp.LogMessage(enumerations.log.INFO, xpConfig.xpGainLog .. "Player: "..Players[pid].name.."(" ..pid..") attempted to use the xpoverride command without permission")
    end
end

--Command to show level progress
function xpGain.ShowLevelStatus(pid,cmd)
    tes3mp.MessageBox(pid, -1, "Level Status: " .. color.White .. Players[pid].data.customVariables.xpTotal .. "/" .. Players[pid].data.customVariables.xpLevelCost)
end

customCommandHooks.registerCommand("givexp",xpGain.GiveXpCommand)
customCommandHooks.registerCommand("xpoverride",xpGain.AddOverride)
customCommandHooks.registerCommand("xpstatus",xpGain.ShowLevelStatus)

customEventHooks.registerHandler("OnPlayerJournal",xpGain.OnJournal)
customEventHooks.registerHandler("OnActorDeath",xpGain.OnKill)
customEventHooks.registerHandler("OnPlayerEndCharGen",xpGain.Initialize)

customEventHooks.registerValidator("OnPlayerTopic",xpGain.OnTopic)
customEventHooks.registerValidator("OnPlayerBook",xpGain.OnBook)

return xpGain