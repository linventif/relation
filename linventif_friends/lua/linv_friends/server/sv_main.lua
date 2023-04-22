util.AddNetworkString("LinvFriends")

// Player Meta
// player 1 = self
// player 2 = target
local meta = FindMetaTable("Player")

function meta:LFGetCharacterID()
    return 1 // temporary until I made the character system done
end

function meta:LFGetRelations(relation, charid, func)
    LinvLib.SQL.Query("SELECT * FROM linv_friends_relations WHERE player_1_steamid64 = '" .. self:SteamID64() .. "' AND relation_type = '" .. relation .. "' AND player_1_charid = " .. charid, function(data)
        func(data)
    end)
end

function meta:LFIsFriend(target)
    local isFriend = false
    self:LFGetRelations("friend", self:LFGetCharacterID(), function(data)
        if data then
            for k, v in pairs(data) do
                if v.player_2_steamid64 == target:SteamID64() then
                    isFriend = true
                end
            end
        end
    end)
    return isFriend
end

function meta:LFGetSettings(func)
    LinvLib.SQL.Query("SELECT * FROM linv_friends_player WHERE steamid64 = '" .. self:SteamID64() .. "'", function(data)
        if data then
            func(data[1])
        end
    end)
end

function meta:LFGetFriendlyFire(func)
    self:LFGetSettings(function(data)
        func(data.friendly_fire)
    end)
end

function meta:LFRefreshRelations()
    self:LFGetRelations("friend", self:LFGetCharacterID(), function(data)
        net.Start("LinvFriends")
            net.WriteUInt(1, 8)
            net.WriteString(util.TableToJSON(data))
        net.Send(self)
    end)
end

function meta:LFRefreshIntroducers()
    self:LFGetRelations("introduced", self:LFGetCharacterID(), function(data)
        LinvLib.SQL.Query([[
            DELETE FROM linv_friends_relations
            WHERE relation_type = 'introduced' AND player_2_steamid64 = ']] .. self:SteamID64() .. [[' AND player_2_charid = ]] .. self:LFGetCharacterID() .. [[
        ]])
        if table.IsEmpty(data) then return end
        for _, ply in pairs(player.GetAll()) do
            for k, v in pairs(data) do
                if v.player_2_steamid64 == ply:SteamID64() && v.player_2_charid == ply:LFGetCharacterID() then
                    ply:LFRefreshRelations()
                end
            end
        end
    end)
end

function meta:LFAddRelation(target, relation)
    LinvLib.SQL.Query("INSERT INTO linv_friends_relations (player_1_steamid64, player_1_charid, player_2_steamid64, player_2_charid, relation_type) VALUES ('" .. self:SteamID64() .. "', " .. self:LFGetCharacterID() .. ", '" .. target:SteamID64() .. "', " .. target:LFGetCharacterID() .. ", '" .. relation .. "')")
    self:LFRefreshRelations()
    target:LFRefreshRelations()
end

// Hooks
hook.Add("PlayerInitialSpawn", "LinvFriends:PlayerInitialSpawn", function(ply)
    LinvLib.SQL.Query("SELECT * FROM linv_friends_player WHERE steamid64 = '" .. ply:SteamID64() .. "'", function(data)
        if table.IsEmpty(data) then
            LinvLib.SQL.Query("INSERT INTO linv_friends_player (steamid64, streamer_mode, friendly_fire) VALUES ('" .. ply:SteamID64() .. "', 0, 0)")
        end
    end)
end)

hook.Add("Initialize", "LinvFriends:Initialize", function()
    LinvLib.SQL.Query([[
        CREATE TABLE IF NOT EXISTS linv_friends_player (
        steamid64 CHAR(17) PRIMARY KEY,
        streamer_mode BOOL,
        friendly_fire BOOL
        );
    ]])
    LinvLib.SQL.Query([[
        CREATE TABLE IF NOT EXISTS linv_friends_relations (
        player_1_steamid64 TEXT,
        player_1_charid INT,
        player_2_steamid64 TEXT,
        player_2_charid INT,
        relation_type TEXT
        );
    ]])
    if !LinvFriends.Config.IntroducePermament then
        sql.Query([[
            DELETE FROM linv_friends_relations
            WHERE relation_type = 'introduced'
        ]])
    end
end)

hook.Add("EntityTakeDamage", "LinvFriends:FriendlyFire", function(target, dmginfo)
    local attacker = dmginfo:GetAttacker()
    if !target:IsPlayer() || !attacker:IsPlayer() || !LinvFriends.Config.FriendlyFire then return end
    if LinvFriends.Config.BlackListTeams[team.GetName(attacker:Team())] then return end

    attacker:LFGetFriendlyFire(function(activate)
        if !activate then return end
        attacker:LFIsFriend(target, function(isFriend)
            if !isFriend then return end
            dmginfo:ScaleDamage(0)
            attacker:ChatPrint("Friendly fire is disabled !")
        end)
    end)
end)

hook.Add("PlayerChangedTeam", "LinvFriends:PlayerChangedTeam:RefreshIntroduce", function(ply, oldTeam, newTeam)
    if !LinvFriends.Config.IntroducePermament then ply:LFRefreshIntroducers() end
end)

hook.Add("PlayerDisconnected", "LinvFriends:PlayerDisconnected:RefreshIntroduce", function(ply)
    if !LinvFriends.Config.IntroducePermament then ply:LFRefreshIntroducers() end
end)

// Net

/*
Net Receive
    1 = Player Ready
Net Send
    1 = Refresh Relations
*/

local netfunc = {
    [1] = function(ply)
        ply:LFRefreshRelations()
    end
}

net.Receive("LinvFriends", function(len, ply)
    local action = net.ReadUInt(8)
    if netfunc[action] then
        netfunc[action](ply)
    end
end)