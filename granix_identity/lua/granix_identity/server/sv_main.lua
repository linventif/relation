util.AddNetworkString("GranixIdentity")

function GranixIdentity:GetAllCharacters(ply)
    local data = sql.Query("SELECT * FROM arrayCharacter WHERE steamid64 = '" .. ply:SteamID64() .. "'")
    local name = {}
    for l, w in pairs(data) do
        name[w.firstName .. " " .. w.lastName] = l
    end
    return name
end

function GranixIdentity:GetCharacter(ply)
    local name = GranixIdentity:GetAllCharacters(ply)
    if name[ply:Nick()] then
        return name[ply:Nick()]
    else
        return 0
    end
end

local function notif(ply, msg, enum, time)
    net.Start("GranixIdentity")
        net.WriteString("notif")
        net.WriteString(util.TableToJSON({
            msg = msg,
            enum = enum,
            time = time
        }))
    net.Send(ply)
end

local function IsAdmin(ply)
    if GranixIdentity.Config["AdminGroup"][ply:GetUserGroup()] then
        return true
    else
        notif(ply, "Vous n'avez pas la permission d'utiliser cette commande !", "error", 5)
        return false
    end
end

local function refresh(ply)
    local data = util.JSONToTable(file.Read("granix_identity/" .. ply:SteamID64() .. ".json", "DATA"))
    net.Start("GranixIdentity")
        net.WriteString("get")
        net.WriteString(util.TableToJSON(data[GranixIdentity:GetCharacter(ply)]["friends"]))
    net.Send(ply)
end

hook.Add("PlayerInitialSpawn", "GranixIdentity", function(ply)
    if !file.Exists("granix_identity/" .. ply:SteamID64() .. ".json", "DATA") then
        local data = {
            [1] = {
                ["friends"] = {
                    [1] = ply:SteamID64()
                }
            },
            [2] = {
                ["friends"] = {
                    [1] = ply:SteamID64()
                }
            },
            [3] = {
                ["friends"] = {
                    [1] = ply:SteamID64()
                }
            }
        }
        file.Write("granix_identity/" .. ply:SteamID64() .. ".json", util.TableToJSON(data))
    end
end)

local function EditFriend(action, ply, target)
    local data = util.JSONToTable(file.Read("granix_identity/" .. ply:SteamID64() .. ".json", "DATA"))
    if action == "add" then
        table.insert(data[GranixIdentity:GetCharacter(ply)]["friends"], target:SteamID64())
        notif(ply, target:Nick() .. " a été ajouté à votre liste d'amis.", 0, 5)
    elseif action == "remove" then
        table.RemoveByValue(data[GranixIdentity:GetCharacter(ply)]["friends"], target:SteamID64())
        notif(ply, target:Nick() .. " a été retiré de votre liste d'amis.", 0, 5)
    end
    file.Write("granix_identity/" .. ply:SteamID64() .. ".json", util.TableToJSON(data))
    refresh(ply)
end

local WaitingRequest = WaitingRequest or {}

net.Receive("GranixIdentity", function(len, ply)
    local action = net.ReadString()
    local target = net.ReadEntity()
    local target2 = net.ReadEntity() or nil
    if action == "remove" then
        EditFriend("remove", ply, target)
        EditFriend("remove", target, ply)
    elseif action == "get" then
        refresh(ply)
    elseif action == "admin_add" then
        if !IsAdmin(ply) then return end
        EditFriend("add", target, target2)
    elseif action == "admin_remove" then
        if !IsAdmin(ply) then return end
        EditFriend("remove", target, target2)
    elseif action == "admin_reset" then
        if !IsAdmin(ply) then return end
        local data = util.JSONToTable(file.Read("granix_identity/" .. target:SteamID64() .. ".json", "DATA"))
        data[GranixIdentity:GetCharacter(target)]["friends"] = {target:SteamID64()}
        file.Write("granix_identity/" .. target:SteamID64() .. ".json", util.TableToJSON(data))
        refresh(target)
    elseif action == "admin_get" then
        if !IsAdmin(ply) then return end
        local data = util.JSONToTable(file.Read("granix_identity/" .. target:SteamID64() .. ".json", "DATA"))
        net.Start("GranixIdentity")
            net.WriteString("admin_get")
            net.WriteString(util.TableToJSON(data))
            net.WriteString(util.TableToJSON(GranixIdentity:GetAllCharacters(target)))
        net.Send(ply)
    elseif action == "request" then
        if !WaitingRequest[target:SteamID64()] then
            WaitingRequest[target:SteamID64()] = {}
        end
        if !table.HasValue(WaitingRequest[target:SteamID64()], ply:SteamID64()) then
            table.insert(WaitingRequest[target:SteamID64()], ply:SteamID64())
            net.Start("GranixIdentity")
                net.WriteString("request")
                net.WriteString(util.TableToJSON({["steamid64"] = ply:SteamID64(), ["name"] = ply:Nick()}))
            net.Send(target)
        else
            notif(ply, "Cette personne a déjà une demande en attente.", "error", 5)
        end
    elseif action == "accept" then
        if table.HasValue(WaitingRequest[ply:SteamID64()], target:SteamID64()) then
            EditFriend("add", ply, target)
            EditFriend("add", target, ply)
            table.RemoveByValue(WaitingRequest[ply:SteamID64()], target:SteamID64())
            notif(ply, "Vous avez accepté la demande d'amis de " .. target:Nick(), 0, 5)
            notif(target, ply:Nick() .. " a accepté votre demande d'amis.", 0, 5)
        end
    elseif action == "decline" then
        if table.HasValue(WaitingRequest[ply:SteamID64()], target:SteamID64()) then
            table.RemoveByValue(WaitingRequest[ply:SteamID64()], target:SteamID64())
            notif(ply, "Vous avez refusé la demande d'amis de " .. target:Nick(), 0, 5)
            notif(target, ply:Nick() .. " a refusé votre demande d'amis.", 0, 5)
        end
    end
end)

hook.Add("PlayerSay", "GranixIdentity", function(ply, text)
    if text == "/friends" then
        net.Start("GranixIdentity")
            net.WriteString("open")
        net.Send(ply)
        return false
    end
end)