#Requires -Version 5.1


# ################################ VARIABLES ###################################

$script:__InvokeBuild = @{
    Plugin    = @{}
    Setup     = @()
    LateSetup = @()
    Paths     = @(
        ".",
        ".invoke",
        ".invokebuild",
        "invoke",
        "invokebuild",
        "invoke-build"
    )
}


# ################################ FUNCTIONS ###################################

function __InvokeBuild::*SETUP {
    [CmdletBinding(PositionalBinding = $false, DefaultParameterSetName = "script")]
    param (
        [Parameter(Mandatory, Position = 0, ParameterSetName = "script")]
        [scriptblock]
        $Script,
        [Parameter(ParameterSetName = "script")]
        [switch]
        $Late,
        [Parameter(Mandatory, ParameterSetName = "execute")]
        [switch]
        $ExecuteAll

    )
    $INVOKE = $script:__InvokeBuild

    if ($ExecuteAll) {
        foreach ($Script in ($INVOKE::Setup + $INVOKE::LateSetup)) {
            & $Script
        }
        $INVOKE::Setup = @()
        $INVOKE::LateSetup = @()
    } else {
        if ($Late) {
            $INVOKE::LateSetup += $Script
        } else {
            $INVOKE::Setup += $Script
        }
    }
}

Set-Alias INVOKEBUILD:SETUP __InvokeBuild::*SETUP


# ################################ PLUGINS #####################################

foreach ($SearchPath in $script:__InvokeBuild::Paths) {
    if (Test-Path $SearchPath -PathType Container) {
        Get-ChildItem $SearchPath -Filter "*.plugin.ps1" | ForEach-Object {
            $WritePath = if ($SearchPath -eq ".") { "." } `
                else { Resolve-Path $_.Directory -Relative }
            Write-Verbose "Plugin $_ ($WritePath)"
            . $_.FullName
        }
    }
}

INVOKEBUILD:SETUP -ExecuteAll


# ################################ BUILDSCRIPTS ################################

foreach ($SearchPath in $script:__InvokeBuild::Paths) {
    if (Test-Path $SearchPath -PathType Container) {
        Get-ChildItem $SearchPath -Filter "*.build.ps1" | ForEach-Object {
            if ($_.FullName -eq $MyInvocation.MyCommand.Definition) {
                return
            }
            $WritePath = if ($SearchPath -eq ".") { "." } `
                else { Resolve-Path $_.Directory -Relative }
            Write-Verbose "Tasks $_ ($WritePath)"
            . $_.FullName
        }
    }
}

INVOKEBUILD:SETUP -ExecuteAll
