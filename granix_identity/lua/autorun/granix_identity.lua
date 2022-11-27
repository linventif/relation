// -- // -- // -- // -- // -- // -- // -- // -- // -- //
// Linventif Library
// -- // -- // -- // -- // -- // -- // -- // -- // -- //
if !LinvLib then
    print(" ")
    print(" ")
    print(" - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ")
    print(" -                                                           - ")
    print(" -               Linventif Library is missing !              - ")
    print(" -                                                           - ")
    print(" - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ")
    print(" ")
    print("Linventif Library is missing ! Please install it !")
    print(" ")
    print("You can download the latest version here : https://linventif.fr/gmod-lib")
    print("Or you can download it directly from the github : https://github.com/linventif/gmod-lib")
    print("Or you can download it directly from the workshop : https://steamcommunity.com/sharedfiles/filedetails/?id=2882747990")
    print("If you don't know how to install it, please read the documentation : https://linventif.fr/gmod-lib-doc")
    print("If you have any questions, you can join my discord : https://linventif.fr/discord")
    print("If you don't download it, you won't be able to use Linventif's addons !")
    print(" ")
    print(" ")
    return
end

// -- // -- // -- // -- // -- // -- // -- // -- // -- //
// Load Variables
// -- // -- // -- // -- // -- // -- // -- // -- // -- //

local folder = "granix_identity"
local name = "Granix Identity"
local full_name = "Granix Identity"
local license = "Commercial License"
local version = 1.0
GranixIdentity = {}

// -- // -- // -- // -- // -- // -- // -- // -- // -- //
// Print Console Informations
// -- // -- // -- // -- // -- // -- // -- // -- // -- //

LinvLib.LoadStr(full_name, version, license)

// -- // -- // -- // -- // -- // -- // -- // -- // -- //
// Create Dir Data - Load Configurations & Language
// -- // -- // -- // -- // -- // -- // -- // -- // -- //

include(folder .. "/sh_config.lua")

if SERVER then
    AddCSLuaFile(folder .. "/sh_config.lua")
    if not file.Exists(folder, "DATA") then
        file.CreateDir(folder)
    end
end

print("| " .. name .. " | File Load | " .. folder .. "/sh_config.lua")

// -- // -- // -- // -- // -- // -- // -- // -- // -- //
// Load All Files
// -- // -- // -- // -- // -- // -- // -- // -- // -- //

LinvLib.Loader(folder .. "/server", name)
LinvLib.Loader(folder .. "/client", name)
LinvLib.Loader(folder .. "/shared", name)

print(" ")
print(" ")