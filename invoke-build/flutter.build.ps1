#Requires -Version 5.1


# ################################ CONFIGURATION ###############################

CONFIGURE flutter.platform `
    -Default "windows"


# ################################ TASKS #######################################

TASK flutter:setup {
    flutter pub get
    flutter pub upgrade
}

TASK flutter:build {
    $Platform = (CONF flutter.platform)
    flutter run $Platform
}

TASK flutter:run {
    $Platform = (CONF flutter.platform)
    flutter run -d $Platform
}

TASK flutter:clean {
    flutter clean
}
