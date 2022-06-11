#Requires -Version 5.1


# ################################ TRANSFORMER #################################

BUNDLE:TRANSFORMER zip {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $Name,
        [Parameter(Mandatory = $true)]
        [string[]]
        $Path,
        [Parameter(Mandatory = $false)]
        [string]
        # [ValidateSet("Optimal", "NoCompression", "Fastest")]
        $Compression = "Optimal"
    )
    $ArchiveName = "$Name.zip"
    $InputPath = $Path | ForEach-Object { Join-Path $Pipeline.Input $_ }
    $OutputPath = $Pipeline.Working

    New-Item `
        -Path $OutputPath `
        -ItemType Directory `
        -ErrorAction SilentlyContinue `
        -Force | Out-Null

    Compress-Archive `
        -Path $InputPath `
        -DestinationPath (Join-Path $OutputPath $ArchiveName) `
        -CompressionLevel $Compression `
        -Force

    return (Get-Item (Join-Path $OutputPath $ArchiveName))
}
