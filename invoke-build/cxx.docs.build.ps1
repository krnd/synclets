#Requires -Version 5.1


# ################################ CONFIGURATION ###############################

CONFIGURE cxx.docs.directory `
    -Default "docs"

CONFIGURE cxx.docs.generator `
    -Default "html"


# ################################ TASKS #######################################

TASK cxx:docs:build {
    EXEC {
        doxygen
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


# ################################ clean #######################################

TASK cxx:docs:clean {
    REMOVE (CONF cxx.docs.directory)
}
