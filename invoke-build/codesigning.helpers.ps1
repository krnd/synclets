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

function Get-CodeSigningCertificate {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Mandatory, Position = 0)]
        [string]
        $Subject,
        [Parameter()]
        [switch]
        $Like
    )
    (Get-ChildItem "Cert:/CurrentUser/My" -CodeSigningCert) `
        | Where-Object {
            if ($Like) { $_.Subject -like "CN=*$Subject*" }
            else { $_.Subject -eq "CN=$Subject" }
        }
}

function Add-CodeSigningCertificate {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [string]
        $File,
        [Parameter(Mandatory)]
        [string]
        $Certificate,
        [Parameter()]
        [switch]
        $Like
    )
    process {
        Set-AuthenticodeSignature `
            -Certificate (Get-CodeSigningCertificate $Subject -Like:$Like) `
            -FilePath $File
    }
}

function Remove-CodeSigningCertificate {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [string]
        $File
    )
    process {
        $Content = (Get-Content $File -Raw)
        $SigLine = (($Content | Select-String "# SIG").LineNumber - 3)
        $Content[0..$SigLine] | Set-Content $File
    }
}
