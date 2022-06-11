#Requires -Version 5.1


# ################################ DEPLOYER ####################################

DEPLOY:DEPLOYER FileSystem {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $Path
    )
    $InputPath = $Pipeline.Input
    $OutputPath = $Path

    New-Item `
        -Path $OutputPath `
        -ItemType Directory `
        -ErrorAction SilentlyContinue `
        -Force | Out-Null

    Copy-Item `
        -Path $InputPath `
        -Destination $OutputPath `
        -Recurse `
        -Force
}
