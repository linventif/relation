// -- // -- // -- // -- // -- // -- // -- //
// This addon can't work without Linventif Library : https://linv.dev/docs/#library
// Some configuration are only editable in Linventif Monitor : https://linv.dev/docs/#monitor
// If you have any problem with this addon please contact me on discord : https://linv.dev/discord
// -- // -- // -- // -- // -- // -- // -- //

// General Settings
LinvFriends.Config.ForceLanguage = true // Force to use the sh_language.lua file

// Friends Settings
LinvFriends.Config.NameOvHeadDist = 400 // How much distance the name of the player is displayed (Default: 400 - 0 to disable)
LinvFriends.Config.UseEMenu = true // Use the E menu to add friends
LinvFriends.Config.AdminCanSeeAll = true // Admin can see all players informations
LinvFriends.Config.Commands = { // Chat Commands
    ["!friends"] = true,
    ["/friends"] = true,
}
LinvFriends.Config.BlackListTeams = { // Blacklisted teams
    ["Staff"] = true,
    ["Civil Protection"] = true
}

// 
LinvFriends.Config.FriendlyFire = true // Use friendly fire

// Introduce Settings
LinvFriends.Config.IntroducePermament = true // Introduce permamently or forget on disconnect / change team

// NPC Settings
LinvFriends.Config.NPC_Name = "Linventif Friends" // The name of the NPC
LinvFriends.Config.NPC_Model = "models/Humans/Group01/Female_01.mdl" // The model of the NPC
LinvFriends.Config.NPC_Height = 3000 // The position of the NPC name (Z Axis - Default: 3000)