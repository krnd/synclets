#Requires -Version 5.1


# ################################ FUNCTIONS ###################################

function Create-CodeSigningCertificate {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Mandatory, Position = 0)]
        [string]
        $Subject,
        [Parameter()]
        [string]
        $Name
    )
    $Name = if ($Name) { $Name } else { $Subject }
    New-SelfSignedCertificate `
        -Type CodeSigningCert `
        -CertStoreLocation "Cert:/CurrentUser/My" `
        -Subject "CN=$Subject" `
        -FriendlyName $Name
}

function Add-CodeSigningCertificate {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Mandatory, Position = 0)]
        [string]
        $File,
        [Parameter(Mandatory)]
        [string]
        $Certificate,
        [Parameter()]
        [switch]
        $Like
    )
    $Object = (Get-ChildItem "Cert:/CurrentUser/My" -CodeSigningCert) `
        | Where-Object {
            if ($Like) { $_.Subject -like "CN=*$Certificate*" }
            else { $_.Subject -eq "CN=$Certificate" }
        }
    Set-AuthenticodeSignature `
        -Certificate $Object `
        -FilePath $File
}

function Remove-CodeSigningCertificate {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Mandatory, Position = 0)]
        [string]
        $File
    )
    $Content = (Get-Content $File -Raw)
    $SigLine = (($Content | Select-String "# SIG").LineNumber - 3)
    $Content[0..$SigLine] | Set-Content $File
}
