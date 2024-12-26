#Requires -Version 5.1


# ################################ CONFIGURATION ###############################

CONFIGURE cxx.docs.config `
    -Default ""
CONFIGURE cxx.docs.directory `
    -Default "docs"

CONFIGURE cxx.docs.generator `
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
    $Generator = (CONF cxx.docs.generator)
    if ($Generator -eq "html") {
        Start-Process (Join-Path (CONF cxx.docs.directory) "html/index.html")
    } else {
        Write-Warning "Unable to show docs for generator '$Generator'."
    }
}

TASK cxx:docs:clean {
    REMOVE (CONF cxx.docs.directory)
}
