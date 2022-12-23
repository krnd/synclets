#Requires -Version 5.1


# ################################ VARIABLES ###################################

$script:__InvokeBuild::Config = @{}


# ################################ INVOKEBUILD #################################

INVOKEBUILD:SETUP {
    $ConfigFile = $null
    foreach ($SearchPath in @(
            ".config"
        ) + $script:__InvokeBuild::Paths) {
        foreach ($FileName in @(
                "invoke.json",
                "build.json",
                "invokebuild.json",
                "invoke-build.json"
            )) {
            $ConfigFile = (Join-Path $SearchPath $FileName)
            if (Test-Path $ConfigFile -PathType Leaf) {
                break
            } else {
                $ConfigFile = $null
            }
        }
        if ($ConfigFile) {
            break
        }
    }

    DATASTORE:MAKE config `
        -JsonFile $ConfigFile
}


# ################################ FUNCTIONS ###################################

function __InvokeBuild::Config::CONFIGURE {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]
        $Name,
        [Parameter()]
        [object]
        $Default = $null
    )
    DATASTORE:VALUE config `
        -Name $Name `
        -Default $Default
}

Set-Alias CONFIGURE __InvokeBuild::Config::CONFIGURE

function __InvokeBuild::Config::CONF {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]
        $Name
    )
    return (DATASTORE:GET config $Name)
}

Set-Alias CONF __InvokeBuild::Config::CONF
