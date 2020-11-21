local xpGain = {}

require("custom.tes3mp-xp.xpConfig")

--Vanilla data tables
local creaturesTable = jsonInterface.load("custom/tes3mp-xp/creature_levels.json")
local npcTable = jsonInterface.load("custom/tes3mp-xp/npc_levels.json")
local questTable = jsonInterface.load("custom/tes3mp-xp/quest_ends.json")

--Function to give player xp
function xpGain.GiveXp(pid,experience)
    Players[pid].data.customVariables.xpTotal = Players[pid].data.customVariables.xpTotal+experience
    xpGain.OnXpGain(pid,experience)
end

--Function to get the ammount of xp a refid is worth
function xpGain.GetKillXp(refid)
    local refidLevel = xpGain.GetTargetLevel(refid)
    local experience =  xpConfig.baseKillXp + (refidLevel^xpConfig.lvlKillXpFactor)*xpConfig.lvlKillXp
    if xpConfig.killVarianceEnable then
        randVar = math.random(0,xpConfig.killVariance[1]+xpConfig.killVariance[2]) - xpConfig.killVariance[1]
        experience = experience + randVar
    end
    return math.floor(experience)
end

--Function to get the amount of xp a quest is worth
function xpGain.GetQuestXp(pid,quest)
    local questXp = xpConfig.baseQuestXp + xpGain.GetPlayerLevel(pid)*xpConfig.questXpPerPlayerLvl
    return questXp
end

--Function to get the killed npc/creature's level
function xpGain.GetTargetLevel(refid)
    local level = 1
    local records = { RecordStores["npc"].data.generatedRecords,
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
    if questTable[quest] ~= nil then
        if questTable[quest].index == index then
            return true
        end
    end
    return false
end

--Function to hook into OnWorldKillCount handler
function xpGain.OnKill(eventStatus,pid)
    if eventStatus.validDefaultHandler then
        for i=0, tes3mp.GetKillChangesSize(pid) - 1 do
            refid = tes3mp.GetKillRefId(pid, i)
            local experience = xpGain.GetKillXp(refid)
            xpGain.GiveXp(pid,experience)
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
                        local experience = xpGain.GetQuestXp(pid,quest)
                        xpGain.GiveXp(pid,experience)
                    end
                else
                    local experience = xpGain.GetQuestXp(pid,quest)
                    xpGain.GiveXp(pid,experience)
                end
            end
        end
    end
end

--Function to calculate level cost
function xpGain.GetLevelCost(level)
    local tempLevel = level
    if xpConfig.lvlCostLimitEnable then
        if tempLevel <= xpConfig.lvlCostLimit[1] then
            tempLevel = xpConfig.lvlCostLimit[1]
        elseif tempLevel >= xpConfig.lvlCostLimit[2] then
            tempLevel = xpConfig.lvlCostLimit[2]
        end
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

--Command to show level progress
function xpGain.ShowLevelStatus(pid,cmd)
    tes3mp.MessageBox(pid, -1, "Level Status: " .. color.White .. Players[pid].data.customVariables.xpTotal .. "/" .. Players[pid].data.customVariables.xpLevelCost)
end

customCommandHooks.registerCommand("xpstatus",xpGain.ShowLevelStatus)

customEventHooks.registerHandler("OnPlayerJournal",xpGain.OnJournal)
customEventHooks.registerHandler("OnWorldKillCount",xpGain.OnKill)
customEventHooks.registerHandler("OnPlayerEndCharGen",xpGain.Initialize)