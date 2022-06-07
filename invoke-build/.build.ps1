#Requires -Version 5.1


# ################################ CONFIGURATION ###############################

$InvokeBuildConfig = $null
foreach ($FileName in @(
    "invoke.json",
    "build.json",
    "invoke-build.json"
)) {
    foreach ($SearchPath in @(
        ".",
        ".config",
        ".vscode"
    )) {
        $ConfigFile = (Join-Path $SearchPath $FileName)
        if (Test-Path $ConfigFile) {
            $InvokeBuildConfig = (Get-Content $ConfigFile -Raw | ConvertFrom-Json)
            break
        }
    }
}

if ($null -eq $InvokeBuildConfig) {
    $InvokeBuildConfig = [PSCustomObject]@{}
}


# ################################ FUNCTIONS ###################################

function Initialize-InvokeBuildConfigurationValue {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]
        $Name,
        [Parameter(Mandatory = $true)]
        [object]
        $Default,
        [Parameter()]
        [string]
        $Help
    )
    $InvokeBuildConfig |
    Add-Member `
        -MemberType NoteProperty `
        -Name $Name `
        -Value $Default
}

Set-Alias CONFVAL Initialize-InvokeBuildConfigurationValue

function Get-InvokeBuildConfigurationValue {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]
        $Name
    )
    return $InvokeBuildConfig | Select-Object -ExpandProperty $Name
}

Set-Alias CONF Get-InvokeBuildConfigurationValue


# ################################ BUILDSCRIPTS ################################

CONFVAL "paths" `
    -Default @(
        ".",
        ".invoke"
    )

foreach ($SearchPath in (CONF "paths")) {
    if (Test-Path $SearchPath) {
        Get-ChildItem $SearchPath -Filter "*.build.ps1" | ForEach-Object {
            if ($_.FullName -eq $MyInvocation.MyCommand.Definition) {
                return
            }
            . $_.FullName
        }
    }
}
