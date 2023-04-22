// -- // -- // -- // -- // -- // -- // -- //
// This file is only for debug / force language
// If you want to add a language, please use resource localization
// More info on the documentation : https://linv.dev/docs/#language
// -- // -- // -- // -- // -- // -- // -- //

local lang = {
    [""] = "",
}

// -- // -- // -- // -- // -- // -- // -- //
// Do not edit below this line
// -- // -- // -- // -- // -- // -- // -- //

function LinvFriends:GetTrad(id, args)
    return LinvLib:GetTranslation(LinvFriends.Config.ForceLanguage, LinvFriends.Info.folder, id, lang[id] || id, args)
end