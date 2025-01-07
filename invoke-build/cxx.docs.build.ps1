#Requires -Version 5.1


# ################################ CONFIGURATION ###############################

CONFIGURE cxx.docs.config `
    -Default ""
CONFIGURE cxx.docs.output `
    -Default "docs"

CONFIGURE cxx.docs.show `
    -Default "html"


# ################################ TASKS #######################################

TASK cxx:docs:build {
    $ConfigFile = (CONF cxx.docs.config)
    if ($ConfigFile) {
        EXEC { doxygen "$ConfigFile" }
    } else {
        EXEC { doxygen }
    }
}

TASK cxx:docs:show {
    $BasePath = (CONF cxx.docs.output)
    ($Backend, $ItemPath) = (CONF cxx.docs.show) -split ":"

    if ($Backend -eq "html") {
        if (-not $ItemPath) {
            $ItemPath = "html"
        }
        $ItemPath = (Join-Path $ItemPath "index.html")
    } else {
        throw "[cxx:docs] " `
            + "Invalid backend specifier '$Backend'."
    }

    Start-Process (Join-Path $BasePath $ItemPath)
}

TASK cxx:docs:clean {
    REMOVE (CONF cxx.docs.output)
}
