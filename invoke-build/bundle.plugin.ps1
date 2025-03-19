# bundle.plugin.ps1 1.0
#Requires -Version 5.1


# ################################ VARIABLES ###################################

$script:__InvokeBuild::Plugin::Bundle = @{
    File     = $MyInvocation.MyCommand.Name
    Prefix   = "BUNDLE"
    Bundlers = @{}
    Configs  = @{}
    Tags     = @{}
}


# ################################ CONFIGURATION ###############################

CONFIGURE bundle.workdir `
    -Default "bundle"
CONFIGURE bundle.outputdir `
    -Default "dist"


# ################################ FUNCTIONS ###################################

function __InvokeBuild::Plugin::Bundle::*TAG {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Mandatory, Position = 0, ParameterSetName = "Hashtable")]
        [hashtable]
        $Values,
        [Parameter(Mandatory, Position = 0, ParameterSetName = "Single")]
        [string]
        $Name,
        [Parameter(Position = 1, ParameterSetName = "Single")]
        [string]
        [bool]
        $Value = $true
    )
    $INVOKE = $script:__InvokeBuild
    $PLUGIN = $INVOKE::Plugin::Bundle
    $TAGS = $PLUGIN::Tags
    if ($null -ne $Values) {
        foreach ($Name in $Values.Keys) {
            $Value = $Values[$Name]
            $TAGS[$Name] = `
                if ($Value -is [bool]) { $Value } `
                else { $Value -as [string] }
        }
    } else {
        $TAGS[$Name] = $Value
    }
}

Set-Alias BUNDLE:TAG __InvokeBuild::Plugin::Bundle::*TAG

function __InvokeBuild::Plugin::Bundle::*CONFIGURE {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Position = 0)]
        [string]
        $Tag,
        [Parameter()]
        [string]
        $SourceDir,
        [Parameter()]
        [string]
        $WorkDir,
        [Parameter()]
        [string]
        $OutputDir,
        [Parameter()]
        [switch]
        $Clean
    )
    $INVOKE = $script:__InvokeBuild
    $PLUGIN = $INVOKE::Plugin::Bundle
    $CONFIGS = $PLUGIN::Configs

    if (__InvokeBuild::Plugin::Bundle::IsTagSkipped $Tag) {
        return
    }

    $CONFIGS.SourceDir = if ($SourceDir) { $SourceDir } else { $null }
    $CONFIGS.WorkDir = if ($WorkDir) { $WorkDir } else { $null }
    $CONFIGS.OutputDir = if ($OutputDir) { $OutputDir } else { $null }

    $CONFIGS.Clean = $Clean

    return
}

Set-Alias BUNDLE:CONFIGURE __InvokeBuild::Plugin::Bundle::*CONFIGURE

function __InvokeBuild::Plugin::Bundle::*COLLECT {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter()]
        [string]
        $Tag,
        [Parameter(Mandatory, Position = 0)]
        [string[]]
        $Paths,
        [Parameter()]
        [string]
        $To,
        [Parameter()]
        [string]
        $Rename
    )
    $INVOKE = $script:__InvokeBuild
    $PLUGIN = $INVOKE::Plugin::Bundle
    $CONFIGS = $PLUGIN::Configs

    if (__InvokeBuild::Plugin::Bundle::IsTagSkipped $Tag) {
        return
    }

    if (-not ($SourceDir = $CONFIGS.SourceDir)) {
        $SourceDir = "."
    }
    if (-not ($WorkDir = $CONFIGS.WorkDir)) {
        $WorkDir = (CONF bundle.workdir)
    }

    $WorkPath = $WorkDir
    if ($To) {
        $WorkPath = (Join-Path $WorkPath $To)
    }

    if (Test-Path $WorkPath -PathType Container) {
        $WorkPath = Get-Item $WorkPath
    } else {
        $WorkPath = New-Item $WorkPath `
            -ItemType Directory `
            -Force
    }

    foreach ($Path in $Paths) {
        $Path = __InvokeBuild::Plugin::Bundle::InterpolatePath $Path

        $Sources = (Join-Path $SourceDir $Path)
        if (-not (Test-Path $Sources)) {
            continue
        } else {
            $Sources = Get-Item $Sources
        }

        $Destination = $WorkPath
        if ($Sources.Length -gt 1) {
            if ($Rename) {
                throw "[$($PLUGIN::Prefix):COLLECT] " `
                    + "Parameter 'Rename' is not allowed."
            }
        } else {
            if ($Rename) {
                $Destination = (Join-Path $Destination $Rename)
            }
        }

        Copy-Item $Sources.FullName `
            -Destination $Destination `
            -Recurse `
            -Force `
        | Out-Null
    }
}

Set-Alias BUNDLE:COLLECT __InvokeBuild::Plugin::Bundle::*COLLECT
Set-Alias BUNDLE __InvokeBuild::Plugin::Bundle::*COLLECT

function __InvokeBuild::Plugin::Bundle::*OUTPUT {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter()]
        [string]
        $Tag,
        [Parameter(Mandatory, Position = 0)]
        [string]
        $Artifact,
        [Parameter(Mandatory)]
        [string]
        $As,
        [Parameter(ValueFromRemainingArguments)]
        [string[]]
        $Passthrough = @()
    )
    $INVOKE = $script:__InvokeBuild
    $PLUGIN = $INVOKE::Plugin::Bundle
    $BUNDLERS = $PLUGIN::Bundlers
    $CONFIGS = $PLUGIN::Configs

    if (__InvokeBuild::Plugin::Bundle::IsTagSkipped $Tag) {
        return
    }

    if (-not ($WorkDir = $CONFIGS.WorkDir)) {
        $WorkDir = (CONF bundle.workdir)
    }
    if (-not ($OutputDir = $CONFIGS.OutputDir)) {
        $OutputDir = (CONF bundle.outputdir)
    }

    if (Test-Path $OutputDir -PathType Container) {
        $OutputPath = Get-Item $OutputDir
    } else {
        $OutputPath = New-Item $OutputDir `
            -ItemType Directory `
            -Force
    }

    $Bundler = $BUNDLERS[$As]

    $Artifact = __InvokeBuild::Plugin::Bundle::InterpolatePath $Artifact
    if (-not $Artifact.EndsWith($Bundler.Extension)) {
        $Artifact += $Bundler.Extension
    }

    & $Bundler.Script `
        -Artifact (Join-Path $OutputPath $Artifact) `
        -Source $WorkDir `
        @Passthrough

    if ($CONFIGS.Clean) {
        __InvokeBuild::Plugin::Bundle::*CLEAN
    }
}

Set-Alias BUNDLE:OUTPUT __InvokeBuild::Plugin::Bundle::*OUTPUT

function __InvokeBuild::Plugin::Bundle::*CLEAN {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter()]
        [switch]
        $Purge
    )
    $INVOKE = $script:__InvokeBuild
    $PLUGIN = $INVOKE::Plugin::Bundle
    $CONFIGS = $PLUGIN::Configs

    if (-not ($WorkDir = $CONFIGS.WorkDir)) {
        $WorkDir = (CONF bundle.workdir)
    }
    if ($WorkDir -ne ".") {
        REMOVE $WorkDir
    }

    if ($Purge) {
        if (-not ($OutputDir = $CONFIGS.OutputDir)) {
            $OutputDir = (CONF bundle.outputdir)
        }
        if ($OutputDir -ne ".") {
            REMOVE $OutputDir
        }
    }
}

Set-Alias BUNDLE:CLEAN __InvokeBuild::Plugin::Bundle::*CLEAN


# ################################ INTERNALS ###################################

function __InvokeBuild::Plugin::Bundle::MakeBundler {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Mandatory, Position = 0)]
        [string]
        $Name,
        [Parameter()]
        [string]
        $Extension,
        [Parameter(Mandatory, Position = 1)]
        [scriptblock]
        $Script
    )
    $INVOKE = $script:__InvokeBuild
    $PLUGIN = $INVOKE::Plugin::Bundle
    $BUNDLERS = $PLUGIN::Bundlers

    if (-not $Extension) {
        $Extension = ".$Name"
    } elseif ($Extension -eq ".") {
        $Extension = ""
    } elseif (-not $Extension.StartsWith(".")) {
        $Extension = ".$Extension"
    }

    $BUNDLERS[$Name] = @{
        Extension = $Extension
        Script    = $Script
    }
}

function __InvokeBuild::Plugin::Bundle::IsTagSkipped {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Position = 0)]
        [AllowEmptyString()]
        [string]
        $Tag
    )
    $INVOKE = $script:__InvokeBuild
    $PLUGIN = $INVOKE::Plugin::Bundle
    $TAGS = $PLUGIN::Tags
    if ($Tag) {
        $Name, $Value = `
            if ($Tag.Contains(":")) { $Tag -split ":", 2 } `
            else { $Tag, $null }

        $TagValue = $TAGS[$Name]
        if ($TagValue -is [bool]) {
            $Return = $Tagvalue
        } elseif ($null -ne $Value) {
            $Return = $true
        } else {
            $Return = ($TagValue -notlike $Value)
        }
        return -not $Return
    }
    return $false
}

function __InvokeBuild::Plugin::Bundle::InterpolatePath {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Position = 0)]
        [string]
        $Path
    )
    $INVOKE = $script:__InvokeBuild
    $PLUGIN = $INVOKE::Plugin::Bundle
    $TAGS = $PLUGIN::Tags

    foreach ($Tag in $TAGS.Keys) {
        $TagValue = $TAGS[$Tag]
        if ($TagValue -isnot [bool]) {
            $Path = $Path -replace "{{$Tag}}", $TagValue
        }
    }

    return $Path
}
