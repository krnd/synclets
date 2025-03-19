# codesigning.build.ps1 1.0
#Requires -Version 5.1


# ################################ CONFIGURATION ###############################

CONFIGURE codesigning.certificate `
    -Default $null

CONFIGURE codesigning.paths `
    -Default @()


# ################################ TASKS #######################################

TASK codesigning:sign {
    $Filter = $null
    foreach ($Path in (CONF codesigning.paths)) {
        (Get-ChildItem (Get-ChildItem $Path -Recurse) -File -Filter $Filter) `
            | Add-CodeSigningCertificate -Like `
                -Certificate (CONF codesigning.certificate)
    }
}

TASK codesigning:remove {
    $Filter = $null
    foreach ($Path in (CONF codesigning.paths)) {
        (Get-ChildItem (Get-ChildItem $Path -Recurse) -File -Filter $Filter) `
            | Remove-CodeSigningCertificate
    }
}
