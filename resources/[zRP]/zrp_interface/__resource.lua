ui_page "Pages/index.html"

client_scripts {
    -- Main
    "@zrp/lib/utils.lua",
    "Backend/Main/client.lua",

    -- veh sealer
    "Backend/Pages/veh_sealer/client.lua"
}

server_scripts {
    "@zrp/lib/utils.lua",
    "Backend/Main/server.lua",

    -- veh sealer
    "Backend/Pages/veh_sealer/server.lua"
}

files {
    "Pages/index.html",
    -- Utils
    "Pages/Utils/JS/bootstrap.js",
    "Pages/Utils/JS/sweetalert2.js",
    "Pages/Utils/CSS/font-awesome.min.css",
    "Pages/Utils/CSS/bootstrap.css",
    "Pages/Utils/CSS/sweetalert2.css",

    -- veh sealer
    "Pages/veh_sealer/index.html",
    "Pages/veh_sealer/cars.html",
    "Pages/veh_sealer/JS/index.js",
    "Pages/veh_sealer/JS/cars.js",
    "Pages/veh_sealer/CSS/style.css",

}