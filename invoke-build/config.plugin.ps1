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
            }
        }
        $ConfigFile = $null
    }

    DATASTORE:MAKE config `
        -JsonFile $ConfigFile
}


# ################################ FUNCTIONS ###################################

function __InvokeBuild_ConfigPlugin_CONFIGURE {
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

Set-Alias CONFIGURE __InvokeBuild_ConfigPlugin_CONFIGURE

function __InvokeBuild_ConfigPlugin_CONF {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]
        $Name
    )
    return (DATASTORE:GET config $Name)
}

Set-Alias CONF __InvokeBuild_ConfigPlugin_CONF
