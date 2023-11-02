#Requires -Version 5.1


# ################################ TASKS #######################################

# ###################### Defaults ##########################

TASK .
TASK ..


# ###################### File Manager ######################

TASK / {
    $Platform = $PSVersionTable.Platform
    if ($null -eq $Platform) {
        explorer .
    } elseif ($Platform -eq "Win32NT") {
        explorer .
    } else {
        Write-Warning "Task '/' not available for platform '$Platform'."
    }
}
