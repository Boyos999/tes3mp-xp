local experience = {}

function experience.SkillBlocker(eventStatus,pid) 
    if Players[pid].data.customVariables.experienceStatus == 1 then
        Players[pid]:LoadSkills()
        return customEventHooks.makeEventStatus(false,false)
    else
        return customEventHooks.makeEventStatus(nil,nil)
    end
end

function experience.AttributeBlocker(eventStatus,pid)
    if Players[pid].data.customVariables.experienceStatus == 1 then
        Players[pid]:LoadAttributes()
        return customEventHooks.makeEventStatus(false,false)
    else
        return customEventHooks.makeEventStatus(nil,nil)
    end
end

function experience.LevelBlocker(eventStatus,pid)
    if Players[pid].data.customVariables.experienceStatus == 1 then
        Players[pid]:LoadLevel()
        return customEventHooks.makeEventStatus(false,false)
    else
        return customEventHooks.makeEventStatus(nil,nil)
    end
end

function experience.ActivateBlocker(eventStatus, pid)
    if Players[pid] ~= nil then
        if Players[pid]:IsLoggedIn() then
            Players[pid].data.customVariables.experienceStatus = 1
        end
    end
end

customEventHooks.registerValidator("OnPlayerAttribute",experience.AttributeBlocker)
customEventHooks.registerValidator("OnPlayerSkill",experience.SkillBlocker)
customEventHooks.registerValidator("OnPlayerLevel",experience.LevelBlocker)

customEventHooks.registerHandler("OnPlayerAuthentified",experience.ActivateBlocker)

return experience