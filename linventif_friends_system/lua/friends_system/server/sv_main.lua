util.AddNetworkString("FriendsSys")

sql.Query("DROP TABLE friends_system")
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
            Notif(ply, "Vous êtes déjà amis avec cette personne !")
        elseif IsRequest(ply, target) then
            Notif(ply, "Vous avez déjà envoyé une demande d'amis à cette personne !")
        else
            local data = GetData(target:SteamID64())
            data.requests = util.JSONToTable(data.requests)
            table.insert(data.requests, ply:SteamID64())
            EditData(target:SteamID64(), "requests", util.TableToJSON(data.requests))
            Notif(ply, "Vous avez envoyé une demande d'amis à " .. target:Nick() .. " !")
            Notif(target, ply:Nick() .. " vous a envoyé une demande d'amis !")
            net.Start("FriendsSys")
                net.WriteString("request")
                net.WriteString(util.TableToJSON(data.requests))
                PrintTable(data.requests)
            net.Send(target)
        end
    elseif id == "accept" then
        local target = net.ReadEntity()
        if IsFriend(ply, target) then
            Notif(ply, "Vous êtes déjà amis avec cette personne !")
        elseif !IsRequest(target, ply) then
            Notif(ply, "Vous n'avez pas reçu de demande d'amis de cette personne !")
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
            Notif(ply, "Vous avez accepté la demande d'amis de " .. target:Nick() .. " !")
            local data = GetData(target:SteamID64())
            data.requests = util.JSONToTable(data.requests)
            data.friends = util.JSONToTable(data.friends)
            data.in_admin = ply_in_admin
            table.insert(data.friends, ply:SteamID64())
            EditData(target:SteamID64(), "friends", util.TableToJSON(data.friends))
            Notif(target, ply:Nick() .. " a accepté votre demande d'amis !")
            net.Start("FriendsSys")
                net.WriteString("refresh")
                net.WriteString(util.TableToJSON(data))
            net.Send(target)
        end
    elseif id == "decline" then
        local target = net.ReadEntity()
        if IsFriend(ply, target) then
            Notif(ply, "Vous êtes déjà amis avec cette personne !")
        elseif !IsRequest(target, ply) then
            Notif(ply, "Vous n'avez pas reçu de demande d'amis de cette personne !")
        else
            local data = GetData(ply:SteamID64())
            data.requests = util.JSONToTable(data.requests)
            for k, v in pairs(data.requests) do
                if v == target:SteamID64() then
                    table.remove(data.requests, k)
                end
            end
            EditData(ply:SteamID64(), "requests", util.TableToJSON(data.requests))
            Notif(ply, "Vous avez refusé la demande d'amis de " .. target:Nick() .. " !")
            Notif(target, ply:Nick() .. " a refusé votre demande d'amis !")
        end
    elseif id == "remove" then
        local target = net.ReadEntity()
        if !IsFriend(ply, target) then
            Notif(ply, "Vous n'êtes pas amis avec cette personne !")
        else
            local data = GetData(ply:SteamID64())
            data.friends = util.JSONToTable(data.friends)
            for k, v in pairs(data.friends) do
                if v == target:SteamID64() then
                    table.remove(data.friends, k)
                end
            end
            EditData(ply:SteamID64(), "friends", util.TableToJSON(data.friends))
            Notif(ply, "Vous avez supprimé " .. target:Nick() .. " de votre liste d'amis !")
            Notif(target, ply:Nick() .. " vous a supprimé de sa liste d'amis !")
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

// TEST

concommand.Add("test_friends", function(ply, cmd, args)
    for _, ply in pairs(player.GetAll()) do
        local data = GetData(ply:SteamID64())
        PrintTable(data)
    end
end)

for _, ply in pairs(player.GetAll()) do
    InitData(ply)
end