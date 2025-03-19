# pyocd.helpers.ps1 1.0
#Requires -Version 5.1


# ################################ FUNCTIONS ###################################

function Install-PyOCDTarget {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Mandatory, Position = 0)]
        [string]
        $Name,
        [Parameter(Mandatory, Position = 1)]
        [string]
        $File,
        [Parameter()]
        [string]
        $Class
    )
    $PythonLocation = (CONF python.venv.path)
    $PyOCDLocation = (Join-Paths $PythonLocation "Lib" "site-packages" "pyocd")
    $TargetsLocation = (Join-Paths $PyOCDLocation "target" "builtin")

    $TargetName = $Name
    $ModuleName = (Get-Item $File).BaseName
    if ($Class) {
        $ClassName = $Class
    } else {
        $ClassName = $Name.ToUpper() `
            -replace "X", "x"
    }

    (Copy-Item `
        -Path $File `
        -Destination $TargetsLocation `
        -Force
    ) | Out-Null

    $IsImported = $false
    $IsRegistryFound = $false
    $IsRegistered = $false

    $InitFile = (Get-Item (Join-Path $TargetsLocation "__init__.py"))
    (Get-Content $InitFile) | Foreach-Object {
        if (-not $IsImported -and $_.StartsWith("from . import")) {
            if ($_.Contains("injected: $TargetName")) {
                $IsImported = $true
            } elseif ($_.Contains("injected:")) {
                # Move to end of injected targets.
            } else {
                "from . import $ModuleName" `
                    + "  # injected: $TargetName"
                $IsImported = $true
            }
        }
        if (-not $IsRegistryFound -and $_.StartsWith("BUILTIN_TARGETS")) {
            $IsRegistryFound = $true
        } elseif ($IsRegistryFound -and -not $IsRegistered) {
            if ($_.Contains("injected: $TargetName")) {
                $IsRegistered = $true
            } elseif ($_.Contains("injected:")) {
                # Move to end of injected targets.
            } else {
                "          '$TargetName': $ModuleName.$ClassName," `
                    + "  # injected: $TargetName"
                $IsRegistered = $true
            }
        }
        $_
    } | Set-Content $InitFile
}
