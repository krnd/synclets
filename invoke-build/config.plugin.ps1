#Requires -Version 5.1

# cspell:ignore invokebuild


# ################################ INVOKEBUILD #################################

INVOKEBUILD:SETUP {
    $ConfigFile = $null
    foreach ($SearchPath in @(
        ".config"
    ) + $script:InvokeBuildPaths) {
        foreach ($FileName in @(
            "invoke.json",
            "build.json",
            "invoke-build.json",
            "invokebuild.json"
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
        [Parameter(Position = 1, Mandatory = $true)]
        [object]
        $Default
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
