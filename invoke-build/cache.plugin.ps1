#Requires -Version 5.1


# ################################ VARIABLES ###################################

$script:__InvokeBuild::Plugin::Cache = @{
    File    = $MyInvocation.MyCommand.Name
    Prefix  = "CACHE"
    Storage = @{}
}


# ################################ FUNCTIONS ###################################

function __InvokeBuild::Plugin::Cache::*STORE {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Mandatory, Position = 0)]
        [string]
        $Name,
        [Parameter(Mandatory, Position = 1)]
        [AllowNull()]
        [object]
        $Value
    )
    $INVOKE = $script:__InvokeBuild
    $PLUGIN = $INVOKE::Plugin::Cache
    $STORAGE = $PLUGIN::Storage

    $STORAGE[$Name] = $Value

    return $Value
}

Set-Alias CACHE:STORE __InvokeBuild::Plugin::Cache::*STORE

function __InvokeBuild::Plugin::Cache::*GET {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Mandatory, Position = 0)]
        [string]
        $Name,
        [Parameter()]
        [AllowNull()]
        [object]
        $Default
    )
    $INVOKE = $script:__InvokeBuild
    $PLUGIN = $INVOKE::Plugin::Cache
    $STORAGE = $PLUGIN::Storage

    if (-not $STORAGE.ContainsKey($Name)) {
        return $Default
    } else {
        return $STORAGE[$Name]
    }
}

Set-Alias CACHE:GET __InvokeBuild::Plugin::Cache::*GET
Set-Alias CACHE __InvokeBuild::Plugin::Cache::*GET
