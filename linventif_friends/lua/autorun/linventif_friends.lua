if !LinvLib || LinvLib.Info.version < "0.2.7" then
    print(" - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ")
    print(" -                                                                                         - ")
    print(" -                      Linventif Library is outdated or not installed.                    - ")
    print(" -            Informations and Download Links : https://linv.dev/docs/#library             - ")
    print(" -                                                                                         - ")
    print(" - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ")
    return
end

// -- // -- // -- // -- // -- // -- // -- // -- // -- //

local folder = "linv_friends"
local name = "Linventif Friends"
local license = "CC BY-NC-SA 4.0"
local version = "0.3.0"

LinvFriends = {
    ["Config"] = {},
    ["Info"] = {["name"] = name, ["version"] = version, ["folder"] = folder, ["license"] = license}
}

// -- // -- // -- // -- // -- // -- // -- // -- // -- //

LinvLib.Install[folder] = version
LinvLib.ShowAddonInfos(name, version, license)
LinvLib.LoadLocalizations(folder, name)
LinvLib.LoadAllFiles(folder, name)