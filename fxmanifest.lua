fx_version 'cerulean'

author 'AlexBanPer'
version '1.2.0'
game 'gta5'

lua54 'yes'

name 'ABP_NCPInteract'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/*.lua',
}

client_scripts {
    'client/**/*.lua'
}

files {
    'locales/*.json'
}

dependencies {
    'oxmysql',
    'ox_lib'
}