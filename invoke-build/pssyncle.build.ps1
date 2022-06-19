#Requires -Version 5.1

# cspell:ignore pssyncle


# ################################ CONFIGURATION ###############################

CONFIGURE pssyncle.file `
    -Default ""


# ################################ TASKS #######################################

TASK pssyncle:sync {
    Invoke-Syncle `
        -File (CONF pssyncle.file)
}

TASK pssyncle:sync:verbose {
    (Invoke-Syncle `
        -File (CONF pssyncle.file) `
        -PassThru
    ).Items | Format-Table
}
