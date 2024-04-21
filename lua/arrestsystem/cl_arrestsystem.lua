surface.CreateFont("ArrestNPC.Main", {
    font = "Roboto",
    weight = 700,
    size = 25,
})

net.Receive("ArrestNPC.Menu", function()
    local pl = net.ReadEntity()
    if not IsValid(pl) then return end
    Derma_StringRequest("Arrest player " .. pl:Nick(), "Enter the reason for the arrest.", "", function(text)
        net.Start("ArrestNPC.Menu")
        net.WriteString(text)
        net.WriteEntity(pl)
        net.SendToServer()
    end, function(text) end, "Arrest")
end)

local white = Color(255, 255, 255)
net.Receive("ArrestNPC.UnMenu", function()
    local arrpls = net.ReadTable()
    if table.Count(arrpls) <= 0 then
        notification.AddLegacy("No players are currently arrested.", NOTIFY_ERROR, 10)
        return
    end

    local m = vgui.Create("DFrame")
    m:SetSize(ScrW() * 0.4, ScrH() * 0.6)
    m:Center()
    m:SetTitle("Release from prison.")
    m:MakePopup()
    for id, v in pairs(arrpls) do
        local pl = player.GetByID(id)
        if not IsValid(pl) then continue end
        local unarrbtn = m:Add("DButton")
        unarrbtn:SetSize(0, 40)
        unarrbtn:Dock(TOP)
        unarrbtn.Paint = function(s, w, h)
            if not IsValid(pl) then
                unarrbtn:Remove()
                return
            end

            if s:IsHovered() then
                draw.RoundedBox(0, 0, 0, w, h, Color(55, 55, 55))
            else
                draw.RoundedBox(0, 0, 0, w, h, Color(45, 45, 45))
            end

            draw.SimpleText(pl:Nick(), "ArrestNPC.Main", 45, h * 0.5, white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            return true
        end

        unarrbtn.DoClick = function()
            Derma_Query("Are you sure you want to release player " .. pl:Nick() .. " from prison?", "Confirmation:", "Yes", function(text)
                net.Start("ArrestNPC.UnMenu")
                net.WriteEntity(pl)
                net.SendToServer()
                m:Remove()
            end, "No")
        end

        local avatar = unarrbtn:Add("AvatarImage")
        avatar:SetPlayer(pl, 84)
        avatar:SetSize(40, 0)
        avatar:Dock(LEFT)
    end
end)