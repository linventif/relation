// If you want to add a official default theme, contact me on discord: https://linventif.fr/discord

local theme = {
    ["sentro"] = {
        ["border"] = Color(115, 115, 115),
        ["background"] = Color(55, 55, 55),
        ["text"] = Color(255, 255, 255),
        ["inter"] = Color(115, 115, 115),
        ["active"] = Color(150, 104, 24),
        ["Button"] = {
            ["background"] = Color(55, 55, 55),
            ["border"] = Color(115, 115, 115),
            ["text"] = Color(255, 255, 255),
            ["hover"] = Color(85, 85, 85),
            ["hover_border"] = Color(115, 115, 115),
        },
        ["ButtonRed"] = {
            ["background"] = Color(200, 67, 67),
            ["border"] = Color(200, 67, 67),
            ["text"] = Color(255, 255, 255),
            ["hover"] = Color(153, 42, 42),
            ["hover_border"] = Color(153, 42, 42),
        },
        ["ButtonGreen"] = {
            ["background"] = Color(70, 160, 70),
            ["border"] = Color(70, 160, 70),
            ["text"] = Color(255, 255, 255),
            ["hover"] = Color(37, 112, 37),
            ["hover_border"] = Color(37, 112, 37),
        },
    },
    ["new-gen"] = {
        ["border"] = Color(10, 70, 80),
        ["background"] = Color(10, 70, 80),
        ["text"] = Color(255, 255, 255),
        ["inter"] = Color(40, 45, 55),
        ["active"] = Color(150, 104, 24),
        ["Button"] = {
            ["background"] = Color(40, 45, 55),
            ["border"] = Color(40, 45, 55),
            ["text"] = Color(255, 255, 255),
            ["hover"] = Color(150, 104, 24),
            ["hover_border"] = Color(150, 104, 24),
        },
        ["ButtonRed"] = {
            ["background"] = Color(200, 67, 67),
            ["border"] = Color(200, 67, 67),
            ["text"] = Color(255, 255, 255),
            ["hover"] = Color(153, 42, 42),
            ["hover_border"] = Color(153, 42, 42),
        },
        ["ButtonGreen"] = {
            ["background"] = Color(70, 160, 70),
            ["border"] = Color(70, 160, 70),
            ["text"] = Color(255, 255, 255),
            ["hover"] = Color(37, 112, 37),
            ["hover_border"] = Color(37, 112, 37),
        },
    }
}

// Do not edit below this line !!
FriendsSys.Config.Color = theme[FriendsSys.Config.Theme] || theme["dark"]