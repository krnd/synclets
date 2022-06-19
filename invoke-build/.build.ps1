#Requires -Version 5.1

# cspell:ignore buildscripts, setupscripts
# cspell:ignore invokebuild


# ################################ VARIABLES ###################################

$script:InvokeBuildPaths = @(
    ".",
    ".invoke",
    ".invokebuild",
    "invoke",
    "invoke-build",
    "invokebuild"
)

$script:__InvokeBuild::SetupScripts = @()


# ################################ FUNCTIONS ###################################

function __InvokeBuild::SETUP {
    [CmdletBinding(PositionalBinding = $false, DefaultParameterSetName = "script")]
    param (
        [Parameter(Position = 0, Mandatory = $true, ParameterSetName = "script")]
        [scriptblock]
        $Script,
        [Parameter(Position = 0, Mandatory = $true, ParameterSetName = "execute")]
        [switch]
        $ExecuteAll

    )
    if ($ExecuteAll) {
        foreach ($Script in $script:__InvokeBuild::SetupScripts) {
            & $Script
        }
        $script:__InvokeBuild::SetupScripts = @()
    } else {
        $script:__InvokeBuild::SetupScripts += $Script
    }
}

Set-Alias INVOKEBUILD:SETUP __InvokeBuild::SETUP


# ################################ PLUGINS #####################################

foreach ($SearchPath in $script:InvokeBuildPaths) {
    if (Test-Path $SearchPath -PathType Container) {
        Get-ChildItem $SearchPath -Filter "*.plugin.ps1" | ForEach-Object {
            . $_.FullName
        }
    }
}

INVOKEBUILD:SETUP -ExecuteAll


# ################################ BUILDSCRIPTS ################################

foreach ($SearchPath in $script:InvokeBuildPaths) {
    if (Test-Path $SearchPath -PathType Container) {
        Get-ChildItem $SearchPath -Filter "*.build.ps1" | ForEach-Object {
            if ($_.FullName -eq $MyInvocation.MyCommand.Definition) {
                return
            }
            . $_.FullName
        }
    }
}

INVOKEBUILD:SETUP -ExecuteAll
