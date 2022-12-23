#Requires -Version 5.1


# ################################ VARIABLES ###################################

$script:__InvokeBuild = @{}

$script:__InvokeBuild::Paths = @(
    ".",
    ".invoke",
    ".invokebuild",
    "invoke",
    "invokebuild",
    "invoke-build"
)

$script:__InvokeBuild::SetupScripts = @()


# ################################ FUNCTIONS ###################################

function __InvokeBuild::SETUP {
    [CmdletBinding(PositionalBinding = $false, DefaultParameterSetName = "script")]
    param (
        [Parameter(Position = 0, Mandatory = $true, ParameterSetName = "script")]
        [scriptblock]
        $Script,
        [Parameter(Mandatory = $true, ParameterSetName = "execute")]
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

foreach ($SearchPath in $script:__InvokeBuild::Paths) {
    if (Test-Path $SearchPath -PathType Container) {
        Get-ChildItem $SearchPath -Filter "*.plugin.ps1" | ForEach-Object {
            . $_.FullName
        }
    }
}

INVOKEBUILD:SETUP -ExecuteAll


# ################################ BUILDSCRIPTS ################################

foreach ($SearchPath in $script:__InvokeBuild::Paths) {
    if (Test-Path $SearchPath -PathType Container) {
        Get-ChildItem $SearchPath -Filter "*.ps1" | ForEach-Object {
            if ($_.FullName -eq $MyInvocation.MyCommand.Definition) {
                return
            } elseif ($_.Name.EndsWith(".plugin.ps1")) {
                return
            }
            . $_.FullName
        }
    }
}

INVOKEBUILD:SETUP -ExecuteAll
