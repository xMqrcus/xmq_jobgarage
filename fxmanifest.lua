fx_version 'cerulean'
game 'gta5'

dependency "vrp"


server_scripts {
  '@mysql-async/lib/MySQL.lua',
  "@vrp/lib/utils.lua",
  --"lib/callback/server.lua",
  "sCallback.lua",
  "server.lua"
}

client_scripts { 
  "lib/Proxy.lua",
  "lib/Tunnel.lua",
  "cCallback.lua",
  --"lib/callback/client.lua",
  "client.lua",
  "config.lua"
}


