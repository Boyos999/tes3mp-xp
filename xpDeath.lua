local xpDeath = {}

require("custom.tes3mp-xp.xpConfig")

function xpDeath.ResurrectPenalty(eventStatus,pid)
    if eventStatus.validDefaultHandler then
        local xpPenalty = 0
        local levelCost = Players[pid].data.customVariables.xpLevelCost

        xpPenalty = math.floor(levelCost*xpConfig.xpDeathMult)
        xpDeath.applyXpPenalty(pid,xpPenalty)

        tes3mp.LogMessage(enumerations.log.INFO, xpConfig.xpDeathLog ..logicHandler.GetChatName(pid).." lost: "..xpPenalty.." XP for dying")

    end
end

function xpDeath.jailPenalty(pid,daysJailed)
    local xpPenalty = daysJailed*xpConfig.xpJailPenalty
    xpDeath.applyXpPenalty(pid,xpPenalty)
    tes3mp.LogMessage(enumerations.log.INFO, xpConfig.xpDeathLog ..logicHandler.GetChatName(pid).." lost: "..xpPenalty.." XP due to being jailed for "..daysJailed.." days")
end

function xpDeath.applyXpPenalty(pid,xpPenalty)

    local playerXp = Players[pid].data.customVariables.xpTotal
    playerXp = playerXp-xpPenalty

    if playerXp >= 0 then
        Players[pid].data.customVariables.xpTotal = playerXp
    elseif playerXp < 0 and xpConfig.xpPenaltyAllowNegative then
        Players[pid].data.customVariables.xpTotal = playerXp
    else
        xpPenalty = Players[pid].data.customVariables.xpTotal
        Players[pid].data.customVariables.xpTotal = 0
    end
    
    if xpPenalty > 0 then
        tes3mp.MessageBox(pid, -1, xpConfig.xpPenaltyMessage .. xpPenalty)
    end

end

customEventHooks.registerHandler("OnPlayerDeath",xpDeath.ResurrectPenalty)

return xpDeath