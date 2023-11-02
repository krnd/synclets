#Requires -Version 5.1


# ################################ VARIABLES ###################################

$script:__InvokeBuild::Plugin::Config = @{
    File      = $MyInvocation.MyCommand.Name
    Prefix    = "CONFIG"
    Storage   = @{}
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

    if ($FilePath) {
        CONFIG:LOAD `
            -File $FilePath `
            -Immediate
    }
}


# ################################ FUNCTIONS ###################################

function __InvokeBuild::Plugin::Config::Load {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Mandatory, Position = 0)]
        [string]
        $Source,
        [Parameter(Mandatory)]
        [AllowNull()]
        [hashtable]
        $Values,
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string]
        $File
    )
    $PLUGIN = $script:__InvokeBuild::Plugin::Config
    $STORAGE = $PLUGIN::Storage

    switch ($Source) {
        "Values" {
            foreach ($Key in $Values.Keys) {
                $STORAGE[$Key] = $Values[$Key]
            }
            break
        }
        "File" {
            $Json = (Get-Content $File -Raw | ConvertFrom-Json)
            $Json.PSObject.Properties | ForEach-Object {
                $STORAGE[$_.Name] = $_.Value
            }
            break
        }
    }
}

function __InvokeBuild::Plugin::Config::*LOAD {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Mandatory, Position = 0, ParameterSetName = "Values")]
        [hashtable]
        $Values,
        [Parameter(Mandatory, Position = 0, ParameterSetName = "File")]
        [string]
        $File,
        [Parameter()]
        [switch]
        $Immediate
    )
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "")]
    $PLUGIN = $script:__InvokeBuild::Plugin::Config

    $ParameterSetName = $PSCmdlet.ParameterSetName
    if ($Immediate) {
        __InvokeBuild::Plugin::Config::Load `
            $ParameterSetName `
            -Values:$Values `
            -File:$File
    } else {
        $LoadFunction = (Get-Item function:__InvokeBuild::Plugin::Config::Load)
        INVOKEBUILD:SETUP {
            & $LoadFunction `
                $ParameterSetName `
                -Values:$Values `
                -File:$File
        }.GetNewClosure()
    }
}

Set-Alias CONFIG:LOAD __InvokeBuild::Plugin::Config::*LOAD

function __InvokeBuild::Plugin::Config::*VALUE {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Mandatory, Position = 0)]
        [string]
        $Name,
        [Parameter(Mandatory)]
        [AllowNull()]
        [object]
        $Default
    )
    $PLUGIN = $script:__InvokeBuild::Plugin::Config
    $STORAGE = $PLUGIN::Storage

    if (-not $STORAGE.ContainsKey($Name)) {
        $STORAGE[$Name] = $Default
    } elseif ($null -eq $STORAGE[$Name]) {
        $STORAGE[$Name] = $Default
    }
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
    $PLUGIN = $script:__InvokeBuild::Plugin::Config
    $STORAGE = $PLUGIN::Storage

    if (-not $STORAGE.ContainsKey($Name)) {
        throw "[$($PLUGIN::Prefix):GET] " `
            + "Configuration value '$Name' not found."
    }
    $Value = $STORAGE[$Name]

    if ($null -eq $Value) {
        if ($null -ne $Default) { return $Default }
        throw "[$($PLUGIN::Prefix):GET] " `
            + "Configuration value '$Name' not specified."
    }

    return $Value
}

Set-Alias CONFIG:GET __InvokeBuild::Plugin::Config::*GET
Set-Alias CONF __InvokeBuild::Plugin::Config::*GET
