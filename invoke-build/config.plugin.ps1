#Requires -Version 5.1


# ################################ VARIABLES ###################################

$script:__InvokeBuild::Plugin::Config = @{
    File      = $MyInvocation.MyCommand.Name
    Prefix    = "CONFIG"
    Paths     = @(
        ".config",
        "config"
    )
    FileNames = @(
        "invoke.json",
        "build.json",
        "invokebuild.json",
        "invoke-build.json"
    )
}


# ################################ INVOKEBUILD #################################

INVOKEBUILD:SETUP {
    $INVOKE = $script:__InvokeBuild
    $PLUGIN = $script:__InvokeBuild::Plugin::Config

    $FilePath = $null
    foreach ($SearchPath in ($INVOKE::Paths + $PLUGIN::Paths)) {
        foreach ($FileName in $PLUGIN::FileNames) {
            $FilePath = (Join-Path $SearchPath $FileName)
            if (Test-Path $FilePath -PathType Leaf) {
                break
            } else {
                $FilePath = $null
            }
        }
        if ($FilePath) {
            break
        }
    }

    DATASTORE:MAKE _config `
        -File $FilePath
}


# ################################ FUNCTIONS ###################################

function __InvokeBuild::Plugin::Config::*VALUE {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Mandatory, Position = 0)]
        [string]
        $Name,
        [Parameter()]
        [object]
        $Default = $null
    )
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "")]
    $PLUGIN = $script:__InvokeBuild::Plugin::Config

    DATASTORE:VALUE _config `
        -Name $Name `
        -Default $Default
}

Set-Alias CONFIG:VALUE __InvokeBuild::Plugin::Config::*VALUE
Set-Alias CONFIGURE __InvokeBuild::Plugin::Config::*VALUE

function __InvokeBuild::Plugin::Config::*GET {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Mandatory, Position = 0)]
        [string]
        $Name
    )
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "")]
    $PLUGIN = $script:__InvokeBuild::Plugin::Config

    return (DATASTORE:GET _config $Name)
}

Set-Alias CONFIG:GET __InvokeBuild::Plugin::Config::*GET
Set-Alias CONF __InvokeBuild::Plugin::Config::*GET
