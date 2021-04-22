local xpParty = {}

require("custom.tes3mp-xp.xpConfig")

--Return party name if pid is in one, otherwise false
function xpParty.GetParty(pid)
    if Players[pid] ~= nil then
        if Players[pid]:IsLoggedIn() then
            for name,party in pairs(WorldInstance.data.customVariables.xpParties) do
                if tableHelper.isEmpty(party) ~= true then
                    if tableHelper.containsValue(party.members, pid) then
                        return name
                    end
                end
            end
        end
    end
    return false
end

--Check if the given pid is the owner of the party
function xpParty.IsOwner(pid,partyName)
    if xpParty.GetOwner(partyName) == pid then
        return true
    end
    return false
end

--Add pid to a party
function xpParty.Add(partyName,pid)
    if WorldInstance.data.customVariables.xpParties[partyName] ~= nil then
        if Players[pid] ~= nil then
            table.insert(WorldInstance.data.customVariables.xpParties[partyName].members,pid)
            WorldInstance.data.customVariables.xpParties[partyName].size = WorldInstance.data.customVariables.xpParties[partyName].size+1
            tes3mp.LogMessage(enumerations.log.INFO, xpConfig.xpPartyLog .. "Player: " .. logicHandler.GetChatName(pid) .. " added to Party: " .. partyName)
            return true
        end
    end
    return false
end

--Create a new party
function xpParty.Create(pid,partyName)
    local tempParty = {}
    tempParty.members = {}
    tempParty.size = 1
    tempParty.owner = pid
    table.insert(tempParty.members,pid)
    WorldInstance.data.customVariables.xpParties[partyName] = tempParty
    tes3mp.LogMessage(enumerations.log.INFO, xpConfig.xpPartyLog .. "Player: " .. logicHandler.GetChatName(pid) .. " created Party: " .. partyName)
end

--Remove a pid from a party
function xpParty.Remove(partyName,pid)
    if WorldInstance.data.customVariables.xpParties[partyName] ~= nil then
        if Players[pid] ~= nil then
            if xpParty.GetParty(pid) == partyName then
                tableHelper.removeValue(WorldInstance.data.customVariables.xpParties[partyName].members,pid)
                WorldInstance.data.customVariables.xpParties[partyName].size = WorldInstance.data.customVariables.xpParties[partyName].size-1
                tes3mp.LogMessage(enumerations.log.INFO, xpConfig.xpPartyLog .. "Player: " .. logicHandler.GetChatName(pid) .. " removed from Party: " .. partyName)
                return true
            end
        end
    end
    return false
end

function xpParty.ChangeOwner(partyName,pid)
    if WorldInstance.data.customVariables.xpParties[partyName] ~= nil then
        if Players[pid] ~= nil then
            if xpParty.GetParty(pid) == partyName then
                WorldInstance.data.customVariables.xpParties[partyName].owner = pid
                tes3mp.LogMessage(enumerations.log.INFO, xpConfig.xpPartyLog .. "Party: " .. partyName .. " ownership transferred to Player: " .. logicHandler.GetChatName(pid))
            end
        end
    end
end

function xpParty.GetSize(partyName)
    if WorldInstance.data.customVariables.xpParties[partyName] ~= nil then
        return WorldInstance.data.customVariables.xpParties[partyName].size
    end
end

function xpParty.GetMembers(partyName)
    if WorldInstance.data.customVariables.xpParties[partyName] ~= nil then
        return WorldInstance.data.customVariables.xpParties[partyName].members
    end
end

function xpParty.GetOwner(partyName)
    if WorldInstance.data.customVariables.xpParties[partyName] ~= nil then
        return WorldInstance.data.customVariables.xpParties[partyName].owner
    end
end

--Delete a party
function xpParty.Delete(partyName)
    WorldInstance.data.customVariables.xpParties[partyName] = {}
    tes3mp.LogMessage(enumerations.log.INFO, xpConfig.xpPartyLog .. "Party: " .. partyName .. " deleted")
end

--Clear parties on server start
function xpParty.Initialize(eventStatus)
    WorldInstance.data.customVariables.xpParties = {}
end

--Remove players from parties when they disconnect
function xpParty.Disconnect(eventStatus,pid)
    partyName = xpParty.GetParty(pid)
    if partyName ~= false then
        if xpParty.GetSize(partyName) > 1 then
            if xpParty.IsOwner(pid,partyName) then
                for _,member in pairs(xpParty.GetMembers(partyName)) do
                    if member ~= pid then
                        xpParty.ChangeOwner(partyName,member)
                        break
                    end
                end
            end
            xpParty.Remove(partyName,pid)
        else
            xpParty.Delete(partyName)
        end
    end
end

function xpParty.PartyCommand(pid,cmd)
    if cmd[2] ~= nil then
        if cmd[2] == "help" then
            local helpMessage = color.Purple .. "xpparty Usage:\n"
            helpMessage = helpMessage .. color.Purple .. "xpparty create <string>\n" .. color.White .. "--Creates a new party with the given string as name\n"
            helpMessage = helpMessage .. color.Purple .. "xpparty add <pid>\n" .. color.White .. "--Adds the player at given pid to your party (only the party owner can add players)\n"
            helpMessage = helpMessage .. color.Purple .. "xpparty remove <pid>\n" .. color.White .. "--Removes the player at given pid from your party (only the party owner can remove players)\n"
            helpMessage = helpMessage .. color.Purple .. "xpparty leave\n" .. color.White .. "--Leave your current party\n"
            helpMessage = helpMessage .. color.Purple .. "xpparty members\n" .. color.White .. "--Show party members for your current party\n"
            helpMessage = helpMessage .. color.Purple .. "xpparty list\n" .. color.White .. "--List information on all active parties\n"
            tes3mp.SendMessage(pid,helpMessage)
        elseif cmd[2] == "create" then
            local callerParty = xpParty.GetParty(pid)
            if cmd[3] ~= nil then
                if WorldInstance.data.customVariables.xpParties[cmd[3]] == nil or tableHelper.isEmpty(WorldInstance.data.customVariables.xpParties[cmd[3]]) then
                    if callerParty ~= false then
                        if xpParty.IsOwner(pid,callerParty) then
                            WorldInstance.data.customVariables.xpParties[cmd[3]] = WorldInstance.data.customVariables.xpParties[callerParty]
                            xpParty.Delete(callerParty)
                            tes3mp.SendMessage(pid, color.Yellow .. "Renamed party: " .. callerParty .. " to: " .. cmd[3] .. "\n")
                        else
                            xpParty.Remove(callerParty,pid)
                            xpParty.Create(pid,cmd[3])
                            tes3mp.SendMessage(pid, color.Green .. "Left Party: " .. callerParty .. "\nCreated Party: " .. cmd[3] .. "\n")
                        end
                    else
                        xpParty.Create(pid,cmd[3])
                        tes3mp.SendMessage(pid, color.Green .. "Created Party: " .. cmd[3] .. "\n")
                    end
                else
                    tes3mp.SendMessage(pid, color.Red .. "Party: " .. cmd[3] .. " already exists\n")
                end
            else
                tes3mp.SendMessage(pid, color.Red .. "Use xpparty help for usage info\n")
            end
        elseif cmd[2] == "add" then
            local callerParty = xpParty.GetParty(pid)
            if callerParty ~= false then
                if xpParty.IsOwner(pid,callerParty) then
                    if cmd[3] ~= nil then
                        if xpParty.GetParty(tonumber(cmd[3])) == false then
                            local status = xpParty.Add(callerParty,tonumber(cmd[3]))
                            if status then
                                tes3mp.SendMessage(pid, color.Green .. logicHandler.GetChatName(tonumber(cmd[3])) .. " added to party\n")
                            else
                                tes3mp.SendMessage(pid, color.Red .. "Unable to add player at pid: " .. tonumber(cmd[3]) .. " to party \n")
                            end
                        else
                            tes3mp.SendMessage(pid, color.Red .. "Player: " .. logicHandler.GetChatName(tonumber(cmd[3])) .. " is already in a party.\n")
                        end
                    end
                else
                    tes3mp.SendMessage(pid, color.Red .. "You don't own the party: " .. callerParty .. "\n")
                end
            else
                tes3mp.SendMessage(pid, color.Red .. "You aren't in a party\n")
            end
        elseif cmd[2] == "remove" then
            local callerParty = xpParty.GetParty(pid)
            if callerParty ~= false then
                if xpParty.IsOwner(pid,callerParty) then
                    if cmd[3] ~= nil then
                        if xpParty.GetParty(tonumber(cmd[3])) == callerParty then
                            local status = xpParty.Remove(callerParty,tonumber(cmd[3]))
                            if status then
                                tes3mp.SendMessage(pid, color.Green .. logicHandler.GetChatName(tonumber(cmd[3])) .. " removed from party\n")
                            else
                                tes3mp.SendMessage(pid, color.Red .. "Unable to remove player at pid: " .. tonumber(cmd[3]) .. " from party \n")
                            end
                        else
                            tes3mp.SendMessage(pid, color.Red .. "Player: " .. logicHandler.GetChatName(tonumber(cmd[3])) .. " isn't in your party.\n")
                        end
                    end
                else
                    tes3mp.SendMessage(pid, color.Red .. "You don't own the party: " .. callerParty .. "\n")
                end
            else
                tes3mp.SendMessage(pid, color.Red .. "You aren't in a party\n")
            end
        elseif cmd[2] == "leave" then
            local callerParty = xpParty.GetParty(pid)
            if callerParty ~= false then
                if xpParty.IsOwner(pid,callerParty) then
                    if xpParty.GetSize(callerParty) > 1 then
                        for _,member in pairs(xpParty.GetMembers(callerParty)) do
                            if member ~= pid then
                                xpParty.ChangeOwner(callerParty,member)
                                break
                            end
                        end
                        local status = xpParty.Remove(callerParty,pid)
                        if status then
                            tes3mp.SendMessage(pid, color.Green ..  "You have left the party\n")
                        end
                    else
                        xpParty.Delete(callerParty)
                    end
                else
                    local status = xpParty.Remove(callerParty,pid)
                    if status then
                        tes3mp.SendMessage(pid, color.Green  .. "You have left the party\n")
                    end
                end
            else
                tes3mp.SendMessage(pid, color.Red .. "You aren't in a party\n")
            end
        elseif cmd[2] == "members" then
            local callerParty = xpParty.GetParty(pid)
            if callerParty ~= false then
                local partyMembers = color.Green .. "Party Members:\n"
                for _,member in pairs(xpParty.GetMembers(callerParty)) do
                    partyMembers = partyMembers .. logicHandler.GetChatName(member) .. "\n"
                end
                tes3mp.SendMessage(pid, partyMembers)
            else
                tes3mp.SendMessage(pid, color.Red .. "You aren't in a party\n")
            end 
        elseif cmd[2] == "list" then
            local parties = WorldInstance.data.customVariables.xpParties
            local partyList = color.Gold .. "All Parties:\n"
            for name,party in pairs(parties) do
                if tableHelper.isEmpty(party) ~= true then
                    partyList = partyList .. name .. ":\nowner: " .. logicHandler.GetChatName(party.owner) .."\n"
                    for _,member in pairs(party.members) do
                        partyList = partyList .. logicHandler.GetChatName(member) .. "\n"
                    end
                end
            end
            tes3mp.SendMessage(pid, partyList)
        else
            tes3mp.SendMessage(pid, color.Red .. "Use xpparty help for usage info\n")
        end
    else
        tes3mp.SendMessage(pid, color.Red .. "Use xpparty help for usage info\n")
    end
end

customCommandHooks.registerCommand("xpparty",xpParty.PartyCommand)

customEventHooks.registerHandler("OnServerPostInit",xpParty.Initialize)
customEventHooks.registerValidator("OnPlayerDisconnect",xpParty.Disconnect)

return xpParty