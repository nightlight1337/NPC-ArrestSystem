util.AddNetworkString("ArrestNPC.Menu")
util.AddNetworkString("ArrestNPC.UnMenu")
ArrestNPC.ArrestPos = ArrestNPC.ArrestPos or {}
local function SaveArrestPos()
    file.Write("arrestnpc_pos.txt", util.TableToJSON(ArrestNPC.ArrestPos))
    print("[ArrestNPC] The position of the prison has been successfully maintained.")
end

local function UpdatePrisonPos()
    if file.Exists("arrestnpc_pos.txt", "DATA") then ArrestNPC.ArrestPos = util.JSONToTable(file.Read("arrestnpc_pos.txt", "DATA")) end
end

UpdatePrisonPos()
concommand.Add("arrestnpc", function(pl, _, args)
    if not pl:IsSuperAdmin() then
        pl:ChatPrint("You are not a superadmin.")
        return
    end

    if not args[1] then pl:ChatPrint("You forgot to specify what is required. (add, remove, list, reset)") end
    if args[1] == "add" then
        table.insert(ArrestNPC.ArrestPos, pl:GetPos())
        SaveArrestPos()
        pl:ChatPrint("Position added.")
    end

    if args[1] == "remove" then
        local posid = tonumber(args[2])
        if not posid or not isnumber(posid) then
            pl:ChatPrint("You forgot to specify the position ID.")
            return
        end

        table.remove(ArrestNPC.ArrestPos, posid)
        SaveArrestPos()
        pl:ChatPrint("Position deleted.")
    end

    if args[1] == "reset" then
        ArrestNPC.ArrestPos = {}
        SaveArrestPos()
        pl:ChatPrint("Positions reset.")
    end

    if args[1] == "list" then
        if table.Count(ArrestNPC.ArrestPos) <= 0 then
            pl:ChatPrint("No prison positions.")
            return
        end
        pl:ChatPrint("---------")
        pl:ChatPrint("ID -- Pos (Vector)")
        for id, v in ipairs(ArrestNPC.ArrestPos) do
            pl:ChatPrint(tostring(id) .. " - " .. tostring(v))
        end

        pl:ChatPrint("---------")
    end
end)

function ArrestNPC.GetHandcuffPlayer(pl)
    local pls = {}
    for _, c in pairs(ents.FindByClass("weapon_handcuffed")) do
        if c:GetRopeLength() > 0 and c:GetKidnapper() == pl then table.insert(pls, c) end
    end

    if #pls <= 0 then return nil end
    return pls[1]:GetOwner()
end

ArrestNPC.ArrestNow = ArrestNPC.ArrestNow or {}
function ArrestNPC.Arrest(admin, pl, arrestrsn, time)
    if IsValid(admin) then
        local getent = admin:GetEyeTrace().Entity
        if not IsValid(getent) or getent:GetClass() ~= "arrestnpc" then
            admin:ChatPrint("You can't do that. (You need to look at the NPC)")
            return
        end
    end

    time = time or 300
    timer.Create("ArrestNPC_Arrest_" .. pl:EntIndex(), time, 1, function() if IsValid(pl) then ArrestNPC.UnArrest(pl) end end)
    if pl:InVehicle() then pl:ExitVehicle() end
    pl:SetPos(table.Random(ArrestNPC.ArrestPos))
    pl:StripWeapons()
    ArrestNPC.ArrestNow[pl:EntIndex()] = true
    BroadcastLua([[notification.AddLegacy("Player ]] .. admin:Nick() .. [[ arrested ]] .. pl:Nick() .. [[ for ]] .. time .. [[ sec. (Reason: ]] .. arrestrsn .. [[)", 0, 10)]])
end

function ArrestNPC.UnArrest(pl)
    ArrestNPC.ArrestNow[pl:EntIndex()] = nil
    pl:KillSilent()
    timer.Simple(0, function() pl:Spawn() end)
    BroadcastLua([[notification.AddLegacy("The arrest of player ]] .. pl:Nick() .. [[ has expired.", 0, 10)]])
end

net.Receive("ArrestNPC.Menu", function(len, pl)
    local getarrestrsn = net.ReadString()
    local getarrestpl = net.ReadEntity()
    local arrestpl = ArrestNPC.GetHandcuffPlayer(pl)
    if not IsValid(arrestpl) or not IsValid(getarrestpl) or not getarrestrsn then
        pl:ChatPrint("You can't do that. (You forgot to specify something)")
        return
    end

    if arrestpl ~= getarrestpl then
        pl:ChatPrint("You can't do that. (You're trying to arrest another player)")
        return
    end

    ArrestNPC.Arrest(pl, getarrestpl, getarrestrsn)
end)

net.Receive("ArrestNPC.UnMenu", function(len, admin)
    local getarrestrsn = net.ReadEntity()
    if not IsValid(getarrestrsn) then
        pl:ChatPrint("You can't do that. (You forgot to specify something)")
        return
    end

    if IsValid(admin) then
        local getent = admin:GetEyeTrace().Entity
        if not IsValid(getent) or getent:GetClass() ~= "unarrestnpc" then
            admin:ChatPrint("You can't do that. (You need to look at the NPC)")
            return
        end
    end

    ArrestNPC.UnArrest(getarrestrsn)
end)