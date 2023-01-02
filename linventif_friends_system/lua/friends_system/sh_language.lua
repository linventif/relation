local languages = {
    ["french"] = {
        ["close"] = "Fermer"
    }
}

function FriendsSys.GetTrad(id)
    return languages[FriendsSys.Config.Language][id] || languages["english"][id] || id
end