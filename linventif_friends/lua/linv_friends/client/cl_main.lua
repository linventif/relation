// Player Metatable
local meta = FindMetaTable("Player")

function meta:LFSIsFriend(steamid64)
    if LinvFriends.Config.AdminCanSeeAll && LocalPlayer():IsLinvLibAdmin() then return true end
    return LocalPlayer().LFSFriends[steamid] || false
end

function meta:LFSGetFriendName(ply)
    if LinvFriends.Config.AdminCanSeeAll && LocalPlayer():IsLinvLibAdmin() then return ply:Nick() end
    return LocalPlayer().LFSFriends[ply:SteamID64()] && ply:Nick() || "Inconnue"
end

-- // Hooks
-- local waiting_time = 2
-- hook.Add("KeyPress", "LinvFriends:UsePress", function(pPlayer, intKey)
--     if intKey == IN_USE then
--         local entEye = LocalPlayer():GetEyeTrace().Entity

--         if !IsValid(entEye) then return end
--         if !entEye:IsPlayer() then return end

--         if LocalPlayer():GetPos():DistToSqr(entEye:GetPos()) > 100 ^ 2 then return end

--         if timer.Exists("LinvFriends:Use") then return end

--         LocalPlayer().EMenuLooking = entEye

--         timer.Create("LinvFriends:Use", waiting_time, 1, function()
--             net.Start("LinvFriends")
--                 net.WriteUInt(1, 8)
--                 net.WriteEntity(entEye)
--             net.SendToServer()
--             timer.Destroy("LinvFriends:Use")
--         end)
--     end
-- end)

-- hook.Add("KeyRelease", "LinvFriends:UseRelease", function(pPlayer, intKey)
--     if intKey == IN_USE then
--         if timer.Exists("LinvFriends:Use") then
--             timer.Remove("LinvFriends:Use")
--         end
--     end
-- end)

-- hook.Add("HUDPaint", "LinvFriends:HUDPaint", function()
--     if LinvFriends.Config.UseEMenu then
--         if !timer.Exists("LinvFriends:Use") then return end

--         if !LocalPlayer().EMenuLooking ||
--             !IsValid(LocalPlayer().EMenuLooking) ||
--             LocalPlayer():GetEyeTrace().Entity != LocalPlayer().EMenuLooking  ||
--             LocalPlayer():GetPos():DistToSqr(LocalPlayer().EMenuLooking:GetPos()) > 100 ^ 2 then
--             timer.Destroy("LinvFriends:Use")
--             return
--         end

--         draw.RoundedBox(0, ScrW() / 2 - 100, ScrH() / 2 - 10, 200, 30, LinvLib:GetColorTheme("background"))
--         draw.RoundedBox(0, ScrW() / 2 - 100 + 4, ScrH() / 2 - 10 + 4, 200 - 8, 30 - 8, LinvLib:GetColorTheme("accent"))
--         draw.RoundedBox(0, ScrW() / 2 - 100 + 4, ScrH() / 2 - 10 + 4, math.Clamp(200 - 8 - timer.TimeLeft("LinvFriends:Use") * (200 / waiting_time), 0, 200), 30 - 8, LinvLib:GetColorTheme("hover"))
--         draw.SimpleText("Ajouter " .. LocalPlayer().EMenuLooking:Nick() .. " à vos amis", "LinvFontRobo20", ScrW() / 2, ScrH() / 2 - 30, LinvLib:GetColorTheme("text"), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
--     end

--     if !LinvFriends.Config.NameOvHead then
--         for _, ply in pairs(player.GetAll()) do
--             if ply == LocalPlayer() then continue end

--             local steamid = ply:SteamID()
--             if !LinvFriends.Friends[steamid] || LinvFriends.Config.BlackListTeams[team.GetName(ply:Team())] then continue end

--             local distance = LocalPlayer():GetPos():DistToSqr(ply:GetPos())
--             local max_dist = LinvFriends.Config.NameOvHeadDist ^ 2
--             if (distance > max_dist && max_dist != -1) || max_dist == 0 then continue end

--             local pos = ply:GetPos() + Vector(0, 0, 80 * ply:GetModelScale())
--             local pos2d = pos:ToScreen()
--             if pos2d.visible then
--                 draw.SimpleText(ply:Nick(), "LinvFontRobo30", pos2d.x, pos2d.y, LinvLib:GetColorTheme("text"), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
--             end
--         end
--     end
-- end)

// Hook
hook.Add("InitPostEntity", "LinvFriends:InitPostEntity", function()
    net.Start("LinvFriends")
        net.WriteUInt(1, 8)
    net.SendToServer()
end)

// Net
local netfunc = {
    [1] = function()
        local data = util.JSONToTable(net.ReadString())
        LocalPlayer().LFSFriends = {}
        LocalPlayer().LFSBlocked = {}
        LocalPlayer().LFSIntroduced = {}
        for k, v in pairs(data) do
            if v.relation_type == "friend" then
                LocalPlayer().LFSFriends[v.player_2_steamid64] = true
            elseif v.relation_type == "blocked" then
                LocalPlayer().LFSBlocked[v.player_2_steamid64] = true
            elseif v.relation_type == "introduced" then
                LocalPlayer().LFSIntroduced[v.player_2_steamid64] = true
            end
        end
    end,
}

net.Receive("LinvFriends", function(len)
    local id = net.ReadUInt(8)
    if netfunc[id] then
        netfunc[id]()
    end
end)