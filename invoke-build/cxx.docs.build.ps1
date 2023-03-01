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
        EXEC {
            $IndexFile = (Join-Path (CONF cxx.docs.directory) "html/index.html")
            Start-Process $IndexFile
        }
    }
}


# ################################ clean #######################################

TASK cxx:docs:clean {
    REMOVE (CONF cxx.docs.directory)
}
