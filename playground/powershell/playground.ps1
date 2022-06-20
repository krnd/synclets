#Requires -Version 5.1


# ################################ CONSTANTS ###################################

[System.Diagnostics.CodeAnalysis.SuppressMessage("PSUseDeclaredVarsMoreThanAssignments", "")]
$ScriptRoot = $PSScriptRoot


# ################################ CONFIGURATION ###############################

$Config = @{ BaseConfig = $true }

foreach ($Search in @(
    (
        @(
            $PSScriptRoot
        ), @(
            "config",
            "runner"
        )
    ),
    (
        @(
            ".",
            ".config"
        ), @(
            "runner"
        )
    )
)) {
    foreach ($SearchPath in $Search[0]) {
        foreach ($FileName in $Search[1]) {
            $File = (Join-Path $SearchPath "$FileName.psd1")
            if (Test-Path $File -PathType Leaf) {
                $Config = (Invoke-Expression (Get-Content $File -Raw))
                break
            }
        }
    }
}

function :Config {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]
        $Key,
        [Parameter(Position = 1)]
        [object]
        $Default = $null,
        [Parameter()]
        [switch]
        $Exists
    )
    $KeyExists = $Config.ContainsKey($Key)
    if ($Exists) {
        return $KeyExists
    } else {
        if ($KeyExists) {
            $Value = $Config[$Key]
        } elseif ($null -eq $Default) {
            throw [System.ArgumentNullException]::new($Key)
        }
        if ($null -eq $Value) {
            return $Default
        } else {
            return $Value
        }
    }
}


# ################################ RUNNER ######################################

$IsBaseConfig = (:Config BaseConfig $false) -or (:Config Paths -Exists)

if ($IsBaseConfig) {
    $File = (:Config Paths @("runner")) | ForEach-Object {
        $Path = (Join-Path $PSScriptRoot $_)
        if (Test-Path $Path -PathType Container) {
            (Get-ChildItem $Path -Filter "*.ps1") `
                + (Get-ChildItem $Path -Filter "*.psd1")
        }
    } | Sort-Object LastWriteTime | Select-Object -Last 1

    if (-not $File) {
        throw [System.IO.FileNotFoundException]::new(
            "Unable to find runner."
        )
    }

    if ($File.Extension -eq ".psd1") {
        $Config += (Invoke-Expression (Get-Content $File.FullName -Raw))
    } else {
        $Config += @{
            File = $File.FullName
        }
    }
}

$Runner = if (:Config Module -Exists) {
    "module"
} elseif (:Config Command -Exists) {
    "command"
} else {
    "file"
}


# ################################ SETUP #######################################

if ($Runner -eq "module") {
    $ModuleName = (:Config Module)
    $Title = $ModuleName
} elseif ($Runner -eq "command") {
    $Command = (:Config Command)
    $Title = $Command
} else {
    $File = (Get-Item (:Config File))
    $Title = [System.IO.Path]::GetFileNameWithoutExtension($File.FullName)
}
$Title = (:Config Title $Title)


Write-Host ""
Write-Host ("[ ".PadLeft(35, "=") + "$Title ]").PadRight(80, "=")
Write-Host ""


$ProjectPath = (Resolve-Path .).Path

$OutputPath = $null
if (:Config Output -Exists) {
    $OutputPath = (Join-Path $ProjectPath (:Config Output))
    Remove-Item `
        -Path $OutputPath `
        -ErrorAction SilentlyContinue `
        -Recurse `
        -Force
    New-Item `
        -Path $OutputPath `
        -ItemType Directory `
        -ErrorAction SilentlyContinue `
        -Force | Out-Null
}


# ################################ IMPORTS #####################################

foreach ($Import in (:Config Imports @())) {
    if ($Import.StartsWith("!")) {
        Import-Module $Import.TrimStart("!") -Force
    } else {
        Import-Module $Import
    }
}

if ($Runner -eq "module") {
    Import-Module (Join-Path $ProjectPath $ModuleName) -Force
    $Module = (Get-Module $ModuleName)
}


# ################################ EXECUTION ###################################

$Parameters = (:Config Parameters @{})

if ($Runner -eq "module") {
    $Command = (:Config Command)
} elseif ($Runner -eq "command") {
    [void]$null
} else {
    $Command = $File.FullName
}

$Result = (& $Command @Parameters)


# ################################ RESULT ######################################

if (:Config Formatter -Exists) {
    $Formatter = (:Config Formatter $false)
    if ($false -eq $Formatter) {
        $Formatter = $null
    }
} else {
    $Formatter = { $Input | Format-Table }
}

if ($Formatter) {
    Invoke-Command $Formatter `
        -InputObject $Result
}


# ################################ TEARDOWN ####################################

Write-Host ""
Write-Host "".PadRight(80, "=")
if ($Runner -eq "module") {
    Write-Host "Module '$ModuleName' (v$($Module.Version)) finished."
} elseif ($Runner -eq "command") {
    Write-Host "Command '$Command' finished."
} else {
    Write-Host "Script '$($File.Name)' finished."
}
Write-Host ""
