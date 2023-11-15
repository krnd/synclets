#Requires -Version 5.1


# ################################ FUNCTIONS ###################################

function __InvokeBuild::IsTaskDefined {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Mandatory, Position = 0)]
        [string]
        $Name
    )
    return ${*}.All.Contains($Name)
}

function __InvokeBuild::IsTaskMissing {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Mandatory, Position = 0)]
        [string]
        $Name
    )
    return -not ${*}.All.Contains($Name)
}


# ################################ TASKS #######################################

# ###################### Defaults ##########################

INVOKEBUILD:SETUP {
    if (__InvokeBuild::IsTaskMissing ".") {
        TASK .
    }
    if (__InvokeBuild::IsTaskMissing "..") {
        TASK ..
    }
}


# ###################### File Manager ######################

TASK / {
    $Platform = $PSVersionTable.Platform
    if ($null -eq $Platform) {
        EXEC { explorer . }
    } elseif ($Platform -eq "Win32NT") {
        EXEC { explorer . }
    } else {
        Write-Warning "Task '/' not available for platform '$Platform'."
    }
}
