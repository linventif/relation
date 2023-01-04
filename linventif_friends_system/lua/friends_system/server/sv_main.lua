util.AddNetworkString("FriendsSys")

sql.Query("CREATE TABLE IF NOT EXISTS friends_system (id INTEGER PRIMARY KEY AUTOINCREMENT, steamid64 TEXT, friends TEXT DEFAULT '{}', requests TEXT DEFAULT '{}')")

local ply_in_admin = {}

local function CreateData(steamid64)
    sql.Query("INSERT INTO friends_system (steamid64) VALUES ('" .. steamid64 .. "')")
end

local function DeleteData(steamid64)
    sql.Query("DELETE FROM friends_system WHERE steamid64 = '" .. steamid64 .. "'")
end

local function EditData(steamid64, column, value)
    sql.Query("UPDATE friends_system SET " .. column .. " = '" .. value .. "' WHERE steamid64 = '" .. steamid64 .. "'")
end

local function GetData(steamid64)
    local data = sql.Query("SELECT * FROM friends_system WHERE steamid64 = '" .. steamid64 .. "'")
    if !data then
        CreateData(steamid64)
        return GetData(steamid64)
    else
        return data[1]
    end
end

local function Notif(ply, text)
    net.Start("FriendsSys")
        net.WriteString("notif")
        net.WriteString(text)
    net.Send(ply)
end

local function IsFriend(ply, target)
    local data = GetData(ply:SteamID64())
    data.friends = util.JSONToTable(data.friends)
    for k, v in pairs(data.friends) do
        if v == tostring(target:SteamID64()) then
            return true
        end
    end
    return false
end

local function InTable(tab, value)
    for k, v in pairs(tab) do
        if v == value then
            return true
        end
    end
    return false
end

local function IsRequest(ply, target)
    local data = GetData(target:SteamID64())
    data.requests = util.JSONToTable(data.requests)
    for k, v in pairs(data.requests) do
        if v == tostring(ply:SteamID64()) then
            return true
        end
    end
    return false
end

local function InitData(ply)
    print("InitData")
    local friends = GetData(ply:SteamID64())
    if !friends then
        CreateData(ply:SteamID64())
        InitData(ply)
    end
    local data = GetData(ply:SteamID64())
    data.friends = util.JSONToTable(data.friends)
    data.requests = util.JSONToTable(data.requests)
    data.in_admin = ply_in_admin
    net.Start("FriendsSys")
        net.WriteString("refresh")
        net.WriteString(util.TableToJSON(data))
    net.Send(ply)
end

net.Receive("FriendsSys", function(len, ply)
    local id = net.ReadString()
    if id == "request" then
        local target = net.ReadEntity()
        if IsFriend(ply, target) then
            Notif(ply, FriendsSys:GetTrad("already_friend"))
        elseif IsRequest(ply, target) then
            Notif(ply, FriendsSys:GetTrad("already_request"))
        else
            local data = GetData(target:SteamID64())
            data.requests = util.JSONToTable(data.requests)
            table.insert(data.requests, ply:SteamID64())
            EditData(target:SteamID64(), "requests", util.TableToJSON(data.requests))
            Notif(ply, FriendsSys:GetTrad("request_send") .. target:Nick() .. " !")
            Notif(target, ply:Nick() .. FriendsSys:GetTrad("request_receive")
            net.Start("FriendsSys")
                net.WriteString("request")
                net.WriteString(util.TableToJSON(data.requests))
                PrintTable(data.requests)
            net.Send(target)
        end
    elseif id == "accept" then
        local target = net.ReadEntity()
        if IsFriend(ply, target) then
            Notif(ply, FriendsSys:GetTrad("already_friend"))
        elseif !IsRequest(target, ply) then
            Notif(ply, FriendsSys:GetTrad("no_request"))
        else
            local data = GetData(ply:SteamID64())
            data.requests = util.JSONToTable(data.requests)
            data.friends = util.JSONToTable(data.friends)
            table.insert(data.friends, target:SteamID64())
            for k, v in pairs(data.requests) do
                if v == target:SteamID64() then
                    table.remove(data.requests, k)
                end
            end
            EditData(ply:SteamID64(), "requests", util.TableToJSON(data.requests))
            EditData(ply:SteamID64(), "friends", util.TableToJSON(data.friends))
            Notif(ply, FriendsSys:GetTrad("request_accept") .. target:Nick() .. " !")
            local data = GetData(target:SteamID64())
            data.requests = util.JSONToTable(data.requests)
            data.friends = util.JSONToTable(data.friends)
            data.in_admin = ply_in_admin
            table.insert(data.friends, ply:SteamID64())
            EditData(target:SteamID64(), "friends", util.TableToJSON(data.friends))
            Notif(target, ply:Nick() .. FriendsSys:GetTrad("accept_request"))
            net.Start("FriendsSys")
                net.WriteString("refresh")
                net.WriteString(util.TableToJSON(data))
            net.Send(target)
        end
    elseif id == "decline" then
        local target = net.ReadEntity()
        if IsFriend(ply, target) then
            Notif(ply, FriendsSys:GetTrad("already_friend"))
        elseif !IsRequest(target, ply) then
            Notif(ply, FriendsSys:GetTrad("no_request"))
        else
            local data = GetData(ply:SteamID64())
            data.requests = util.JSONToTable(data.requests)
            for k, v in pairs(data.requests) do
                if v == target:SteamID64() then
                    table.remove(data.requests, k)
                end
            end
            EditData(ply:SteamID64(), "requests", util.TableToJSON(data.requests))
            Notif(ply, FriendsSys:GetTrad("request_refused") .. target:Nick() .. " !")
            Notif(target, ply:Nick() .. FriendsSys:GetTrad("decline_request"))
        end
    elseif id == "remove" then
        local target = net.ReadEntity()
        if !IsFriend(ply, target) then
            Notif(ply, FriendsSys:GetTrad("not_friend"))
        else
            local data = GetData(ply:SteamID64())
            data.friends = util.JSONToTable(data.friends)
            for k, v in pairs(data.friends) do
                if v == target:SteamID64() then
                    table.remove(data.friends, k)
                end
            end
            EditData(ply:SteamID64(), "friends", util.TableToJSON(data.friends))
            Notif(ply, FriendsSys:GetTrad("remove_friend_you") .. target:Nick() .. FriendsSys:GetTrad("remove_friend_you_2"))
            Notif(target, ply:Nick() .. FriendsSys:GetTrad("remove_friend"))
            local data = GetData(target:SteamID64())
            data.requests = util.JSONToTable(data.requests)
            data.friends = util.JSONToTable(data.friends)
            data.in_admin = ply_in_admin
            for k, v in pairs(data.friends) do
                if v == ply:SteamID64() then
                    table.remove(data.friends, k)
                end
            end
            EditData(target:SteamID64(), "friends", util.TableToJSON(data.friends))
            net.Start("FriendsSys")
                net.WriteString("refresh")
                net.WriteString(util.TableToJSON(data))
            net.Send(target)
        end
    end
end)

hook.Add("FriendsSystem:PlayerInAdmin", "FriendsSystem:PlayerInAdmins", function(ply)
    if InTable(ply_in_admin, ply:SteamID64()) then
        table.remove(ply_in_admin, ply:SteamID64())
    else
        table.insert(ply_in_admin, ply:SteamID64())
    end
    net.Start("FriendsSys")
        net.WriteString("in_admin")
        net.WriteString(util.TableToJSON(ply_in_admin))
    net.Broadcast()
end)

hook.Add("PlayerInitialSpawn", "FriendsSys", function(ply)
    InitData(ply)
end)

concommand.Add("friends_system_drop_db", function(ply, cmd, args)
    sql.Query("DROP TABLE friends_system")
end)