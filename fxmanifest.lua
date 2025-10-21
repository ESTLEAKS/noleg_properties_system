fx_version 'cerulean'
game 'gta5'

author 'Fivem Script Creator (GTA V)'
description 'NoLeg-style Property System (ESX) - full resource with shells and NUI editor'
version '1.0.0'

shared_scripts {
  'config.lua',
  'shells.lua'
}

client_scripts {
  'client.lua'
}

server_scripts {
  '@oxmysql/lib/MySQL.lua',
  'server.lua'
}

ui_page 'html/index.html'

files {
  'html/index.html',
  'html/style.css',
  'html/app.js',
  'html/img/*'
}
