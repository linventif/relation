local function RespW(x)
    return ScrW() / 1920 * x
end

local function RespH(y)
    return ScrH() / 1080 * y
end

local in_admin = {}
local friends = {}
local request = {}

function FriendsSys:IsFriend(steamid64)
    return friends[steamid64] || false
end

function FriendsSys:GetName(target)
    if FriendsSys:IsFriend(target:SteamID64()) then
        return target:Nick()
    else
        return FriendsSys:GetTrad("unknown")
    end
end

local function ConvertTable(tbl)
    local new_tbl = {}
    for k, v in pairs(tbl) do
        new_tbl[v] = true
    end
    return new_tbl
end

local function Notif(text)
    local frame = vgui.Create("DPanel")
    frame:SetSize(RespW(600), RespH(40))
    frame:SetPos(ScrW()/2-RespW(300), RespH(-100))
    frame.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, FriendsSys.Config.Color["background"])
        draw.SimpleText(text, "LinvFontRobo20", RespW(600)/2, RespH(20), FriendsSys.Config.Color["text"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    print(text)
    frame:MoveTo(ScrW()/2-RespW(300), RespH(10), 0.5, 0, 1)
    timer.Simple(4, function()
        frame:MoveTo(ScrW()/2-RespW(300), -RespH(100), 0.5, 0, 1)
        timer.Simple(0.5, function()
            frame:Remove()
        end)
    end)
end

local function OpenConfirm(msg, func)
    local frame = vgui.Create("DFrame")
    frame:SetSize(RespW(400), RespH(200))
    frame:Center()
    frame:SetTitle("")
    frame:MakePopup()
    frame:ShowCloseButton(false)
    frame:SetDraggable(false)
    frame.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, FriendsSys.Config.Color["border"])
        draw.RoundedBox(6, RespW(4), RespH(4), w-RespW(8), h-RespH(8), FriendsSys.Config.Color["background"])
        if #msg > 1 then
            draw.SimpleText(msg[1], "LinvFontRobo20", w/2, RespH(40), FriendsSys.Config.Color["text"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText(msg[2], "LinvFontRobo20", w/2, RespH(80), FriendsSys.Config.Color["text"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        else
            draw.SimpleText(msg[1], "LinvFontRobo20", w/2, RespH(60), FriendsSys.Config.Color["text"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end
    local but_cancel = vgui.Create("DButton", frame)
    but_cancel:SetSize(RespW(140), RespH(40))
    but_cancel:SetPos(RespW(40), RespH(130))
    but_cancel:SetText(FriendsSys:GetTrad("cancel"))
    but_cancel:SetFont("LinvFontRobo20")
    but_cancel:SetTextColor(FriendsSys.Config.Color["text"])
    but_cancel.DoClick = function()
        frame:Remove()
    end
    LinvLib.UIButton(but_cancel, FriendsSys.Config.Color.Button, 3, 8, 6)
    local but_confirm = vgui.Create("DButton", frame)
    but_confirm:SetSize(RespW(140), RespH(40))
    but_confirm:SetPos(RespW(220), RespH(130))
    but_confirm:SetText(FriendsSys:GetTrad("confirm"))
    but_confirm:SetFont("LinvFontRobo20")
    but_confirm.DoClick = function()
        func()
        frame:Remove()
    end
    LinvLib.UIButton(but_confirm, FriendsSys.Config.Color.Button, 3, 8, 6)
end

local function OpenMenu(section)
    local frame = vgui.Create("DFrame")
    frame:SetSize(RespW(470), RespH(555))
    frame:Center()
    frame:SetTitle("")
    frame:MakePopup()
    frame:ShowCloseButton(false)
    frame:SetDraggable(false)
    frame.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, FriendsSys.Config.Color["border"])
        draw.RoundedBox(6, RespW(4), RespH(4), w-RespW(8), h-RespH(8), FriendsSys.Config.Color["background"])
        if section == 1 then
            draw.SimpleText(FriendsSys:GetTrad("friends_list"), "LinvFontRobo30", w/2, RespH(36), FriendsSys.Config.Color["text"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        elseif section == 2 then
            draw.SimpleText(FriendsSys:GetTrad("friends_wait"), "LinvFontRobo30", w/2, RespH(36), FriendsSys.Config.Color["text"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end
    local scroll_content = vgui.Create("DScrollPanel", frame)
    scroll_content:SetSize(RespW(430), RespH(404))
    scroll_content:SetPos(RespW(20), RespH(72))
    LinvLib.HideVBar(scroll_content)
    local actual_friends = 0
    local actual_request = 0
    for _, ply in pairs(player.GetAll()) do
        if ply == LocalPlayer() then continue end
        if section == 1 && friends[ply:SteamID64()] then
            actual_friends = actual_friends + 1
            local content = vgui.Create("DPanel", scroll_content)
            content:SetSize(RespW(430), RespH(40))
            content:Dock(TOP)
            content:DockMargin(0, 0, 0, 0)
            content.Paint = function(self, w, h)
                draw.RoundedBox(6, 0, 0, w, h, FriendsSys.Config.Color["inter"])
                draw.RoundedBox(4, RespW(4), RespH(4), w-RespW(8), h-RespH(8), FriendsSys.Config.Color["inter"])
                draw.SimpleText(ply:Nick(), "LinvFontRobo20", RespW(186), h/2, FriendsSys.Config.Color["text"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
            local av_ply = vgui.Create("AvatarImage", content)
            av_ply:SetSize(RespW(32), RespH(32))
            av_ply:SetPos(RespW(4), RespH(4))
            av_ply:SetPlayer(ply || nil, RespW(32))
            av_ply.Paint = function(s, w, h)
                draw.RoundedBox(RespW(3), 0, 0, w, h, Color(0, 0, 0, 0))
            end
            local but_remove = vgui.Create("DButton", content)
            but_remove:SetSize(RespW(90), RespH(32))
            but_remove:SetPos(RespW(336), RespH(4))
            but_remove:SetText(FriendsSys:GetTrad("remove"))
            but_remove:SetFont("LinvFontRobo20")
            but_remove.DoClick = function()
                frame:Remove()
                OpenConfirm({FriendsSys:GetTrad("remove_confirm_1"), FriendsSys:GetTrad("remove_confirm_2")}, function()
                    net.Start("FriendsSys")
                        net.WriteString("remove")
                        net.WriteEntity(ply)
                    net.SendToServer()
                    friends[ply:SteamID64()] = nil
                end)
            end
            LinvLib.UIButton(but_remove, FriendsSys.Config.Color.ButtonRed, 3, 6, 4)
        elseif section == 2 && request[ply:SteamID64()] then
            actual_request = actual_request + 1
            local content = vgui.Create("DPanel", scroll_content)
            content:SetSize(RespW(430), RespH(40))
            content:Dock(TOP)
            content:DockMargin(0, 0, 0, 0)
            content.Paint = function(self, w, h)
                draw.RoundedBox(6, 0, 0, w, h, FriendsSys.Config.Color["inter"])
                draw.RoundedBox(4, RespW(4), RespH(4), w-RespW(8), h-RespH(8), FriendsSys.Config.Color["inter"])
                draw.SimpleText(ply:Nick(), "LinvFontRobo20", RespW(137), h/2, FriendsSys.Config.Color["text"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
            local av_ply = vgui.Create("AvatarImage", content)
            av_ply:SetSize(RespW(32), RespH(32))
            av_ply:SetPos(RespW(4), RespH(4))
            av_ply:SetPlayer(ply || nil, RespW(32))
            av_ply.Paint = function(s, w, h)
                draw.RoundedBox(RespW(3), 0, 0, w, h, Color(0, 0, 0, 0))
            end
            local but_accept = vgui.Create("DButton", content)
            but_accept:SetSize(RespW(90), RespH(32))
            but_accept:SetPos(RespW(242), RespH(4))
            but_accept:SetText(FriendsSys:GetTrad("accept"))
            but_accept:SetFont("LinvFontRobo20")
            but_accept.DoClick = function()
                frame:Remove()
                net.Start("FriendsSys")
                    net.WriteString("accept")
                    net.WriteEntity(ply)
                net.SendToServer()
                request[ply:SteamID64()] = nil
                friends[ply:SteamID64()] = true
            end
            LinvLib.UIButton(but_accept, FriendsSys.Config.Color.ButtonGreen, 3, 6, 4)
            local but_refuse = vgui.Create("DButton", content)
            but_refuse:SetSize(RespW(90), RespH(32))
            but_refuse:SetPos(RespW(336), RespH(4))
            but_refuse:SetText(FriendsSys:GetTrad("refuse"))
            but_refuse:SetFont("LinvFontRobo20")
            but_refuse.DoClick = function()
                frame:Remove()
                net.Start("FriendsSys")
                    net.WriteString("decline")
                    net.WriteEntity(ply)
                net.SendToServer()
                request[ply:SteamID64()] = nil
            end
            LinvLib.UIButton(but_refuse, FriendsSys.Config.Color.ButtonRed, 3, 6, 4)
        end
    end
    if actual_friends == 0 && section == 1 then
        local content = vgui.Create("DPanel", scroll_content)
        content:SetSize(RespW(430), RespH(40))
        content:Dock(TOP)
        content:DockMargin(0, 0, 0, 0)
        content.Paint = function(self, w, h)
            draw.RoundedBox(6, 0, 0, w, h, FriendsSys.Config.Color["inter"])
            draw.RoundedBox(4, RespW(4), RespH(4), w-RespW(8), h-RespH(8), FriendsSys.Config.Color["inter"])
            draw.SimpleText(FriendsSys:GetTrad("no_friends"), "LinvFontRobo20", w/2, h/2, FriendsSys.Config.Color["text"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end
    if actual_request == 0 && section == 2 then
        local content = vgui.Create("DPanel", scroll_content)
        content:SetSize(RespW(430), RespH(40))
        content:Dock(TOP)
        content:DockMargin(0, 0, 0, 0)
        content.Paint = function(self, w, h)
            draw.RoundedBox(6, 0, 0, w, h, FriendsSys.Config.Color["inter"])
            draw.RoundedBox(4, RespW(4), RespH(4), w-RespW(8), h-RespH(8), FriendsSys.Config.Color["inter"])
            draw.SimpleText(FriendsSys:GetTrad("no_request"), "LinvFontRobo20", w/2, h/2, FriendsSys.Config.Color["text"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end
    local but_setting = vgui.Create("DButton", frame)
    but_setting:SetSize(RespW(125), RespH(40))
    but_setting:SetPos(RespW(20), RespH(495))
    but_setting:SetText(FriendsSys:GetTrad("settings"))
    but_setting:SetFont("LinvFontRobo20")
    but_setting.DoClick = function()
        Notif(FriendsSys:GetTrad("in_dev"))
    end
    LinvLib.UIButton(but_setting, FriendsSys.Config.Color.Button, 3, 8, 6)
    local but_switch = vgui.Create("DButton", frame)
    but_switch:SetSize(RespW(125), RespH(40))
    but_switch:SetPos(RespW(173), RespH(495))
    if section == 1 then
        but_switch:SetText(FriendsSys:GetTrad("friends_list_short"))
    elseif section == 2 then
        but_switch:SetText(FriendsSys:GetTrad("friends_wait_short"))
    end
    but_switch:SetFont("LinvFontRobo20")
    but_switch.DoClick = function()
        frame:Remove()
        if section == 1 then
            OpenMenu(2)
        elseif section == 2 then
            OpenMenu(1)
        end
    end
    LinvLib.UIButton(but_switch, FriendsSys.Config.Color.Button, 3, 8, 6)
    local but_close = vgui.Create("DButton", frame)
    but_close:SetSize(RespW(125), RespH(40))
    but_close:SetPos(RespW(325), RespH(495))
    but_close:SetText(FriendsSys:GetTrad("cancel"))
    but_close:SetFont("LinvFontRobo20")
    but_close:SetTextColor(FriendsSys.Config.Color["text"])
    but_close.DoClick = function()
        frame:Remove()
    end
    LinvLib.UIButton(but_close, FriendsSys.Config.Color.Button, 3, 8, 6)
end

if FriendsSys.Config.NameOvHead then
    hook.Add("HUDPaint", "DrawPlayerNames", function()
        for _, ply in pairs(player.GetAll()) do
            if ply == LocalPlayer() then continue end
            if FriendsSys.Config.JobStaff[team.GetName(ply:Team())] then continue end
            local distance = LocalPlayer():GetPos():Distance(ply:GetPos())
            if distance > FriendsSys.Config.NameOvHeadDist then continue end
            local steamid = ply:SteamID64()
            if in_admin[steamid] then continue end
            if !friends[steamid] then continue end
            local pos = ply:GetPos() + Vector(0, 0, 80*ply:GetModelScale())
            local pos2d = pos:ToScreen()
            if pos2d.visible then
                draw.SimpleText(ply:Nick(), "LinvFontRobo30", pos2d.x, pos2d.y, FriendsSys.Config.Color["text"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        end
    end)
end

net.Receive("FriendsSys", function()
    local id = net.ReadString()
    if id == "in_admin" then
        local data = util.JSONToTable(net.ReadString())
        if !data then return end
        in_admin = data
    elseif id == "request" then
        local data = util.JSONToTable(net.ReadString())
        if !data then return end
        request = ConvertTable(data || {})
        Notif(FriendsSys:GetTrad("request_received"))
    elseif id == "refresh" then
        local data = util.JSONToTable(net.ReadString())
        if !data then return end
        friends = ConvertTable(data.friends || {})
        request = ConvertTable(data.request || {})
        in_admin = ConvertTable(data.in_admin || {})
    elseif id == "notif" then
        local text = net.ReadString()
        Notif(text)
    elseif id == "npc_use" then
        OpenMenu(1)
    end
end)

hook.Add("OnPlayerChat", "FriendsSys:OnPlayerChat", function(ply, text, team, dead)
    if FriendsSys.Config.Commands[string.lower(text)] && LocalPlayer() == ply then
        OpenMenu(1)
    end
end)

local waiting_time = 2
hook.Add("KeyPress", "FriendsSys:UsePress", function(pPlayer, intKey)
    if intKey == IN_USE then
        local entEye = LocalPlayer():GetEyeTrace().Entity

        if not IsValid(entEye) then return end
        if not entEye:IsPlayer() then return end

        if LocalPlayer():GetPos():DistToSqr(entEye:GetPos()) > 100 ^ 2 then return end

        if timer.Exists("FriendsSys:Use") then return end

        LocalPlayer().EMenuLooking = entEye

        timer.Create("FriendsSys:Use", waiting_time, 1, function()
            net.Start("FriendsSys")
                net.WriteString("request")
                net.WriteEntity(entEye)
            net.SendToServer()
            timer.Destroy("FriendsSys:Use")
        end)
    end
end)

hook.Add("KeyRelease", "FriendsSys:UseRelease", function(pPlayer, intKey)
    if intKey == IN_USE then
        if timer.Exists("FriendsSys:Use") then
            timer.Remove("FriendsSys:Use")
        end
    end
end)

hook.Add("HUDPaint", "FriendsSys:HUDPaint", function()
    if not timer.Exists("FriendsSys:Use") then return end

    if not LocalPlayer().EMenuLooking ||
        not IsValid(LocalPlayer().EMenuLooking) ||
        LocalPlayer():GetEyeTrace().Entity != LocalPlayer().EMenuLooking  ||
        LocalPlayer():GetPos():DistToSqr(LocalPlayer().EMenuLooking:GetPos()) > 100 ^ 2 then
        timer.Destroy("FriendsSys:Use")
        return
    end

    draw.RoundedBox(0, ScrW() / 2 - 100, ScrH() / 2 - 10, 200, 30, FriendsSys.Config.Color["background"])
    draw.RoundedBox(0, ScrW() / 2 - 100 + 4, ScrH() / 2 - 10 + 4, 200 - 8, 30 - 8, FriendsSys.Config.Color["inter"])
    draw.RoundedBox(0, ScrW() / 2 - 100 + 4, ScrH() / 2 - 10 + 4, math.Clamp(200 - 8 - timer.TimeLeft("FriendsSys:Use") * (200 / waiting_time), 0, 200), 30 - 8, FriendsSys.Config.Color["active"])
    draw.SimpleText(FriendsSys:GetTrad("add_friends"), "LinvFontRobo20", ScrW() / 2, ScrH() / 2 - 30, FriendsSys.Config.Color["text"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end)