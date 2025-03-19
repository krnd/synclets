# flutter.build.ps1 1.0
#Requires -Version 5.1


# ################################ CONFIGURATION ###############################

CONFIGURE flutter.platform `
    -Default "windows"


# ################################ TASKS #######################################

TASK flutter:setup {
    EXEC { flutter pub get }
    EXEC { flutter pub upgrade }
}

TASK flutter:build {
    $Platform = (CONF flutter.platform)
    EXEC {
        flutter build `
            -d $Platform `
            --verbose
    }
}

TASK flutter:run {
    $Platform = (CONF flutter.platform)
    EXEC {
        flutter run `
            -d $Platform
    }
}

TASK flutter:clean {
    EXEC { flutter clean }
}

TASK flutter:purge {
    EXEC { flutter clean }
}
