local friends = friends or {}

surface.CreateFont( "GranixIdentity20", {
	font = "Open Sans",
	extended = false,
	size = 20,
})

surface.CreateFont( "GranixIdentity22", {
	font = "Open Sans",
	extended = false,
	size = 22,
})

surface.CreateFont( "GranixIdentity24", {
	font = "Open Sans",
	extended = false,
	size = 24,
})

surface.CreateFont( "GranixIdentity18", {
	font = "Open Sans",
	extended = false,
	size = 18,
})

surface.CreateFont( "GranixIdentity26", {
	font = "Open Sans",
	extended = false,
	size = 26,
})

local function notif(ply, msg, enum, time)
    local enums = {
        ["generic"] = 0,
        ["error"] = 1,
        ["refresh"] = 2,
        ["info"] = 3,
        ["cut"] = 4
    }
    notification.AddLegacy(msg, enums[enum], time)
    print("Granix Identity : " .. msg)
end

local function ValidSteamID64(steamid64)
    if !steamid64 || string.len(steamid64) != 17 || !tonumber(steamid64) then
        notif(ply, "SteamID64 invalide", "error", 5)
        return false
    end
    return true
end

local function ValidTarget(target, cmd)
    if !target:IsValid() || !target:IsPlayer() then
        notif(LocalPlayer(), "Ce joueur n'est pas n'existe pas ou n'est pas connecté !", "error", 5)
        return false
    elseif target:IsBot() then
        notif(LocalPlayer(), "Vous ne pouvez pas cibler un bot !", "error", 5)
        return false
    elseif target == LocalPlayer() && cmd != "friends_admin_friends_list" then
        notif(LocalPlayer(), "Vous ne pouvez pas vous cibler !", "error", 5)
        return false
    else
        return true
    end
end

local function NewResuest(target)
    local frame = vgui.Create("DPanel")
    frame:SetSize(300, 40)
    frame:SetPos(ScrW(), 30)
    frame:MoveTo(ScrW() - 290, 30, 0.5, 0, -1)
    frame.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(55, 55, 55, 255))
    end

    local label = vgui.Create("DLabel", frame)
    label:SetPos(5, 10)
    label:SetSize(280, 20)
    local nick = target:Nick()
    if string.len(nick) > 15 then
        nick = string.sub(nick, 1, 15) .. "..."
    end
    label:SetText("Nouvelle demande d'amis de : " .. nick)
    label:SetFont("Trebuchet18")
    label:SetTextColor(Color(255, 255, 255))
    label:SetContentAlignment(5)
    LocalPlayer():EmitSound("buttons/lightswitch2.wav")

    timer.Simple(4, function()
        frame:MoveTo(ScrW(), 30, 0.5, 0, -1, function()
            frame:Remove()
        end)
    end)
end

function GranixIdentity:AreFriend(target, ply)
    for k, v in pairs(friends) do
        if v == target:SteamID64() then
            return true
        end
    end
    return false
end

function GranixIdentity:GetName(target, ply)
    if GranixIdentity:AreFriend(target, ply) then
        return target:Nick()
    else
        return GranixIdentity.Lang["unknown"]
    end
end

concommand.Add("friends_list", function()
    print("Vous avez " .. #friends .. " amis !")
end)

concommand.Add("friends_add", function(ply, cmd, args)
    if !ValidSteamID64(args[1]) then return end
    local target = player.GetBySteamID64(args[1])
    if !ValidTarget(target, cmd) then return end
    if GranixIdentity:AreFriend(target, ply) then
        notif(ply, "Vous êtes déjà ami avec " .. target:Nick(), "error", 5)
    else
        net.Start("GranixIdentity")
            net.WriteString("add")
            net.WriteEntity(target)
        net.SendToServer()
    end
end)

local function Confirmation(msgsn, nbmsg, font)
    local HeightLine = 0
    if nbmsg == 1 then
        HeightLine = 50
    elseif nbmsg == 2 then
        HeightLine = 33
    elseif nbmsg == 3 then
        HeightLine = 25
    end

    local frame = vgui.Create("DFrame")
    frame:SetSize(340, 180)
    frame:Center()
    frame:SetTitle("")
    frame:SetDraggable(false)
    frame:ShowCloseButton(false)
    frame:MakePopup()
    frame.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(113, 113, 113, 255))
        draw.RoundedBox(4, 4, 4, w-8, h-8, Color(55, 55, 55, 255))
    end

    for i = 1, nbmsg do
        local space = HeightLine + HeightLine * (i - 1)
        local label = vgui.Create("DLabel", frame)
        label:SetPos(5, space)
        label:SetSize(330, 20)
        label:SetText(msgsn[i])
        label:SetFont(font)
        label:SetTextColor(Color(255, 255, 255))
        label:SetContentAlignment(5)
    end

    local ButAccepet = vgui.Create("DButton", frame)
    ButAccepet:SetSize(90, 32)
    ButAccepet:SetPos(30, 120)
    ButAccepet:SetText("Oui")
    ButAccepet:SetFont("Trebuchet24")
    ButAccepet:SetTextColor(Color(255, 255, 255))
    ButAccepet.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(114, 192, 112, 255))
    end
    ButAccepet.DoClick = function()
        frame:Close()
        return true
    end

    local ButRefuse = vgui.Create("DButton", frame)
    ButRefuse:SetSize(90, 32)
    ButRefuse:SetPos(220, 120)
    ButRefuse:SetText("Non")
    ButRefuse:SetFont("Trebuchet24")
    ButRefuse:SetTextColor(Color(255, 255, 255))
    ButRefuse.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(217, 98, 98, 255))
    end
    ButRefuse.DoClick = function()
        frame:Close()
        return false
    end
end


local function OpenPanel()
    local frame = vgui.Create("DFrame")
    frame:SetSize(460, 550)
    frame:Center()
    frame:SetTitle("")
    frame:SetDraggable(false)
    frame:ShowCloseButton(false)
    frame:MakePopup()
    frame.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(113, 113, 113, 255))
        draw.RoundedBox(4, 4, 4, w-8, h-8, Color(55, 55, 55, 255))
    end

    local LabTitle = vgui.Create("DLabel", frame)
    LabTitle:SetPos(5, 22)
    LabTitle:SetSize(450, 20)
    LabTitle:SetText("Liste des Amis")
    LabTitle:SetFont("Trebuchet24")
    LabTitle:SetTextColor(Color(255, 255, 255))
    LabTitle:SetContentAlignment(5)

    local frame_scroll = vgui.Create("DPanel", frame)
    frame_scroll:SetPos(25, 61)
    frame_scroll:SetSize(410, 404)
    frame_scroll.Paint = function(s, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(0,0,0, 0))
    end

    local wep_scroll = vgui.Create("DScrollPanel", frame_scroll)
    wep_scroll:Dock(FILL)

    local vbar = wep_scroll.VBar
	vbar:SetHideButtons( true )
	function vbar.btnUp:Paint( w, h ) end
	function vbar:Paint( w, h ) end
	function vbar.btnGrip:Paint( w, h ) end

    wep_scroll.VBar:SetHideButtons(true)
	wep_scroll.VBar.Paint = function() end

	wep_scroll.VBar:SetWide(0)
	wep_scroll.VBar.btnUp.Paint = wep_scroll.VBar.Paint
	wep_scroll.VBar.btnDown.Paint = wep_scroll.VBar.Paint
	wep_scroll.VBar.btnGrip.Paint = function(self, w, h) end

    for k, v in pairs(friends) do
        local target = player.GetBySteamID64(v)
        local name = ""
        if !target then
            name = v
        else
            name = target:Nick()
        end

        local wep_frame = wep_scroll:Add("DPanel")
        wep_frame:SetSize(410, 40)
        wep_frame:Dock(TOP)
        wep_frame:DockMargin(0, 0, 0, 15)
        wep_frame.Paint = function(s, w, h)
            draw.RoundedBox(6, 0, 0, w, h, Color(113, 113, 113, 255))
        end
        local ImgAvatar = vgui.Create("AvatarImage", wep_frame)
        ImgAvatar:SetSize(32, 32)
        ImgAvatar:SetPos(4, 4)
        ImgAvatar:SetPlayer(target or nil, 40)
        ImgAvatar.Paint = function(s, w, h)
            draw.RoundedBox(3, 0, 0, w, h, Color(0, 0, 0, 0))
        end
        local LabName = vgui.Create("DLabel", wep_frame)
        LabName:SetPos(50, 10)
        LabName:SetSize(300, 20)
        LabName:SetText(name)
        LabName:SetFont("GranixIdentity22")
        LabName:SetTextColor(Color(255, 255, 255))
        LabName:SetContentAlignment(5)
        local BtnRemove = vgui.Create("DButton", wep_frame)
        BtnRemove:SetPos(316, 4)
        BtnRemove:SetSize(90, 32)
        BtnRemove:SetText("Retirer")
        BtnRemove:SetFont("GranixIdentity22")
        BtnRemove:SetTextColor(Color(255, 255, 255))
        BtnRemove.Paint = function(self, w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(217, 98, 98, 255))
        end
        BtnRemove.DoClick = function()
            net.Start("GranixIdentity")
                net.WriteString("remove")
                net.WriteEntity(player.GetBySteamID64(v))
            net.SendToServer()
            wep_frame:Remove()
        end
    end

    local ButFriends = vgui.Create("DButton", frame)
    ButFriends:SetSize(90, 40)
    ButFriends:SetPos(26, 486)
    ButFriends:SetText("Amis")
    ButFriends:SetFont("Trebuchet24")
    ButFriends:SetTextColor(Color(255, 255, 255))
    ButFriends.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(113, 113, 113, 255))
        draw.RoundedBox(4, 4, 4, w-8, h-8, Color(55, 55, 55, 255))
    end
    ButFriends.DoClick = function()
        frame:Close()
    end
    ButFriends.OnCursorEntered = function()
        ButFriends.Paint = function(self, w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(197, 197, 197))
            draw.RoundedBox(4, 4, 4, w-8, h-8, Color(55, 55, 55, 255))
        end
    end
    ButFriends.OnCursorExited = function()
        ButFriends.Paint = function(self, w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(113, 113, 113, 255))
            draw.RoundedBox(4, 4, 4, w-8, h-8, Color(55, 55, 55, 255))
        end
    end

    local ButRequests = vgui.Create("DButton", frame)
    ButRequests:SetSize(127, 40)
    ButRequests:SetPos(157, 486)
    ButRequests:SetText("Demandes")
    ButRequests:SetFont("Trebuchet24")
    ButRequests:SetTextColor(Color(255, 255, 255))
    ButRequests.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(113, 113, 113, 255))
        draw.RoundedBox(4, 4, 4, w-8, h-8, Color(55, 55, 55, 255))
    end
    ButRequests.DoClick = function()
        frame:Close()
    end
    ButRequests.OnCursorEntered = function()
        ButRequests.Paint = function(self, w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(197, 197, 197))
            draw.RoundedBox(4, 4, 4, w-8, h-8, Color(55, 55, 55, 255))
        end
    end
    ButRequests.OnCursorExited = function()
        ButRequests.Paint = function(self, w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(113, 113, 113, 255))
            draw.RoundedBox(4, 4, 4, w-8, h-8, Color(55, 55, 55, 255))
        end
    end

    local ButClose = vgui.Create("DButton", frame)
    ButClose:SetSize(110, 40)
    ButClose:SetPos(324, 486)
    ButClose:SetText("Fermer")
    ButClose:SetFont("Trebuchet24")
    ButClose:SetTextColor(Color(255, 255, 255))
    ButClose.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(113, 113, 113, 255))
        draw.RoundedBox(4, 4, 4, w-8, h-8, Color(55, 55, 55, 255))
    end
    ButClose.DoClick = function()
        frame:Close()
    end
    ButClose.OnCursorEntered = function()
        ButClose.Paint = function(self, w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(197, 197, 197))
            draw.RoundedBox(4, 4, 4, w-8, h-8, Color(55, 55, 55, 255))
        end
    end
    ButClose.OnCursorExited = function()
        ButClose.Paint = function(self, w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(113, 113, 113, 255))
            draw.RoundedBox(4, 4, 4, w-8, h-8, Color(55, 55, 55, 255))
        end
    end
end

concommand.Add("friends_remove", function(ply, cmd, args)
    if !ValidSteamID64(args[1]) then return end
    local target = player.GetBySteamID64(args[1])
    if !ValidTarget(target, cmd) then return end
    if !GranixIdentity:AreFriend(target, ply) then
        notif(ply, "Vous n'êtes pas ami avec " .. target:Nick(), "error", 5)
    else
        net.Start("GranixIdentity")
            net.WriteString("remove")
            net.WriteEntity(target)
        net.SendToServer()
    end
end)

concommand.Add("friends_admin_friends_list", function(ply, cmd, args)
    if !ValidSteamID64(args[1]) then return end
    local target = player.GetBySteamID64(args[1])
    if !ValidTarget(target, cmd) then return end
    net.Start("GranixIdentity")
        net.WriteString("admin_get")
        net.WriteEntity(target)
    net.SendToServer()
end)

concommand.Add("friends_admin_add", function(ply, cmd, args)
    if !ValidSteamID64(args[1]) then return end
    local target = player.GetBySteamID64(args[1])
    if !ValidTarget(target, cmd) then return end
    net.Start("GranixIdentity")
        net.WriteString("admin_add")
        net.WriteEntity(target)
    net.SendToServer()
end)

concommand.Add("friends_admin_remove", function(ply, cmd, args)
    if !ValidSteamID64(args[1]) || !ValidSteamID64(args[2]) then return end
    local target_1 = player.GetBySteamID64(args[1])
    local target_2 = player.GetBySteamID64(args[2])
    if !ValidTarget(target_1) || !ValidTarget(target_2) then return end
    net.Start("GranixIdentity")
        net.WriteString("admin_remove")
        net.WriteEntity(target_1)
        net.WriteEntity(target_2)
    net.SendToServer()
end)


hook.Add("OnPlayerChat", "GranixIdentity", function(ply, text, team, dead)
    if text == "derma" then
        OpenPanel()
    elseif text == "conf" then
        local msgs = {
            "Etes vous sur de retirer",
            "L2",
            "de votre liste d'amis ?",
        }
        Confirmation(msgs, 3, "GranixIdentity20")
    end
end)

hook.Add("FriendsRefresh", "FriendsRefresh", function()
    net.Start("GranixIdentity")
        net.WriteString("get")
    net.SendToServer()
end)

/* Eden
/garrysmod/addons/aden_character_system/lua/aden_character_system/client/cl_selection.lua
L102 -> hook.Run("FriendsRefresh")
*/

net.Receive("GranixIdentity", function(len)
    local action = net.ReadString()
    local data = util.JSONToTable(net.ReadString())
    if action == "get" then
        friends = data
    elseif action == "notif" then
        notif(LocalPlayer(), data.msg, data.enum, data.time)
    elseif action == "admin_get" then
        local characters = util.JSONToTable(net.ReadString())
        PrintTable(characters)
        PrintTable(data)
    elseif action == "request" then
        local target = player.GetBySteamID64(data.steamid)
        NewResuest(target)
    end
end)

net.Start("GranixIdentity")
    net.WriteString("get")
net.SendToServer()