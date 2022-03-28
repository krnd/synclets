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
        $FilePath = (Join-Path $SearchPath $FileName)
        if (-not (Test-Path $FilePath))
        { continue }
        $InvokeBuildConfig = (Get-Content $FilePath -Raw | ConvertFrom-Json)
        break
    }
}

if ($null -eq $InvokeBuildConfig)
{ $InvokeBuildConfig = [PSCustomObject]@{} }


# ################################ FUNCTIONS ###################################

function Get-InvokeBuildConfigurationValue {
    [CmdletBinding(PositionalBinding = $true)]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]
        $Key,
        [Parameter(Mandatory = $true, Position = 1)]
        [object]
        $Default
    )
    if (-not ($InvokeBuildConfig | Get-Member $Key))
    { return $Default }
    return $InvokeBuildConfig | Select-Object -ExpandProperty $Key
}

Set-Alias CONF Get-InvokeBuildConfigurationValue


# ################################ BUILDSCRIPTS ################################

foreach ($SearchPath in (
    CONF "paths" @(
        ".",
        ".invoke"
    )
)) {
    if (-not (Test-Path $SearchPath))
    { continue }
    Get-ChildItem $SearchPath -Filter *.build.ps1 | ForEach-Object {
        if ($_.FullName -eq $MyInvocation.MyCommand.Definition)
        { return }
        . $_.FullName
    }
}
