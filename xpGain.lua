local xpGain = {}

require("custom.tes3mp-xp.xpConfig")

--Vanilla data tables
local creaturesTable = jsonInterface.load("custom/tes3mp-xp/creature_levels.json")
local npcTable = jsonInterface.load("custom/tes3mp-xp/npc_levels.json")

--Function to give player xp
function xpGain.GiveKillXp(pid,experience)
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

--Function to get the killed npc/creature's level
function xpGain.GetTargetLevel(refid)
    local level = 1
    local npcStore = RecordStores["npc"]
    local creatureStore = RecordStores["creature"]
    if npcStore.data.generatedRecords[refid] ~= nil then
        level = npcStore.data.generatedRecords[refid].level
    elseif creatureStore.data.generatedRecords[refid] ~= nil then
        level = creatureStore.data.generatedRecords[refid].level
    elseif npcStore.data.permanentRecords[refid] ~= nil then
        level = npcStore.data.permanentRecords[refid].level
    elseif creatureStore.data.permanentRecords[refid] ~= nil then
        level = creatureStore.data.permanentRecords[refid].level
    elseif npcTable[refid] ~= nil then
        level = npcTable[refid].level
    elseif creaturesTable[refid] ~= nil then
        level = creaturesTable[refid].level
    end
    return level
end

--Check if the player has enough xp to level up
function xpGain.CheckLevelUp(pid)
    if Players[pid].data.customVariables.xpTotal >= Players[pid].data.customVariables.xpLevelCost then
        return true
    end
end

--Function to hook into OnWorldKillCount handler
function xpGain.OnKill(eventStatus,pid)
    if eventStatus.validDefaultHandler then
        for i=0, tes3mp.GetKillChangesSize(pid) - 1 do
            refid = tes3mp.GetKillRefId(pid, i)
            local experience = xpGain.GetKillXp(refid)
            xpGain.GiveKillXp(pid,experience)
        end
    end
end

--Function called whenever a player gains xp to check if the player can level up
function xpGain.OnXpGain(pid,experience)
    tes3mp.MessageBox(pid, -1, xpConfig.killXpMessage .. ": " .. color.White .. experience)
    if xpGain.CheckLevelUp(pid) then
        xpLeveling.LevelUpPlayer(pid)
        Players[pid].data.customVariables.xpTotal = Players[pid].data.customVariables.xpTotal-Players[pid].data.customVariables.xpLevelCost
        Players[pid].data.customVariables.xpLevelCost = xpGain.GetLevelCost(xpGain.GetPlayerLevel(pid))
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

customEventHooks.registerHandler("OnWorldKillCount",xpGain.OnKill)
--customEventHooks.registerHandler("OnPlayerAuthentified",xpLeveling.Initialize)
customEventHooks.registerHandler("OnPlayerEndCharGen",xpGain.Initialize)