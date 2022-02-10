local xpDeath = {}

require("custom.tes3mp-xp.xpConfig")

function xpDeath.ResurrectPenalty(eventStatus,pid)
    if eventStatus.validDefaultHandler then
        local xpPenalty = 0
        local levelCost = Players[pid].data.customVariables.xpLevelCost
        local playerXp = Players[pid].data.customVariables.xpTotal

        xpPenalty = math.floor(levelCost*xpConfig.xpDeathMult)
        playerXp = playerXp-xpPenalty

        if playerXp >= 0 then
            Players[pid].data.customVariables.xpTotal = playerXp
        elseif playerXp < 0 and xpConfig.xpDeathAllowNegative then
            Players[pid].data.customVariables.xpTotal = playerXp
        else
            xpPenalty = Players[pid].data.customVariables.xpTotal
            Players[pid].data.customVariables.xpTotal = 0
        end
        
        if xpPenalty > 0 then
            tes3mp.MessageBox(pid, -1, xpConfig.xpPenaltyMessage .. xpPenalty)
        end
        tes3mp.LogMessage(enumerations.log.INFO, xpConfig.xpDeathLog .. "Player: "..logicHandler.GetChatName(pid).." lost: "..xpPenalty.." XP for dying")

    end
end

customEventHooks.registerHandler("OnPlayerDeath",xpDeath.ResurrectPenalty)

return xpDeath