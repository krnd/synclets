#Requires -Version 5.1


# ################################ GATHERER ####################################

BUNDLE:GATHERER FileSystem {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Mandatory = $true)]
        [string[]]
        $Path,
        [Parameter()]
        [string]
        $Destination
    )
    $InputPath = $Pipeline.Input
    $OutputPath = $Pipeline.Working

    if ($Destination) {
        $OutputPath = (Join-Path $OutputPath $Destination)
    }

    New-Item `
        -Path $OutputPath `
        -ItemType Directory `
        -ErrorAction SilentlyContinue `
        -Force | Out-Null

    $ItemList = @()
    $Path | ForEach-Object {
        $ItemList += (
            Copy-Item `
                -Path (Join-Path $InputPath $_) `
                -Destination $OutputPath `
                -Recurse `
                -Force `
                -PassThru
        ) | Where-Object {
            # Filter for files only.
            -not $_.GetFileSystemInfos
        }
    }

    return $ItemList
}
