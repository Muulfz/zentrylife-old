resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

--meu pau

dependency "zrp"

client_scripts {
	"@zrp/lib/utils.lua",
	"menu.lua",
	"lsconfig.lua",
	"lscustoms.lua",
	
}

server_script {
	"@zrp/lib/utils.lua",
	"lscustoms_server.lua"
}