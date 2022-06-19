#Requires -Version 5.1

# cspell:ignore psmodule, psrepository


# ################################ CONFIGURATION ###############################

CONFIGURE psmodule.module `
    -Default ""

CONFIGURE psmodule.repository `
    -Default "PSLocal"


# ################################ FUNCTIONS ###################################

function InvokeBuild::PSModule::Get-ModuleName {
    [System.Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs", "")]
    [CmdletBinding(PositionalBinding = $false)]
    param(
        [Parameter()]
        [switch]
        $NoConfig
    )

    if (-not $NoConfig) {
        $Name = (CONF psmodule.module)
        if ($Name) {
            return $Name
        }
    }

    foreach ($Directory in (Get-ChildItem . -Directory)) {
        $File = (Join-Path $Directory.FullName "$($Directory.Name).psd1")
        if (-not (Test-Path $File -PathType Leaf)) {
            continue
        }

        $Manifest = (Import-PowerShellDataFile $File)
        if ($null -eq $Manifest.RootModule) {
            continue
        }

        $RootModule = (Join-Path $Module.FullName $Manifest.RootModule)
        if ((Test-Path $RootModule -PathType Leaf) `
                -and ((Get-Item $RootModule).Extension -eq ".psm1")) {
            return $Directory.Name
        }
    }

    throw [System.Exception] "Unable to determine PowerShell module."
}


# ################################ TASKS #######################################

TASK psmodule:setup psmodule:setup:dependencies

TASK psmodule:setup:dependencies {
    $Dependencies = @()
    $PSModuleName = (InvokeBuild::PSModule::Get-ModuleName)

    $Manifest = (Join-Path $PSModuleName "$PSModuleName.psd1")
    if (Test-Path $Manifest -PathType Leaf) {
        $Object = (Import-PowerShellDataFile $Manifest)
        foreach ($Step in ("PrivateData.PSData.ExternalModuleDependencies" -split "\.")) {
            $Object = $Item.$Step
            if ($null -eq $Object) {
                break
            }
        }
        if ($null -ne $Object) {
            $Dependencies += $Object
        }
    }

    $Dependencies | ForEach-Object {
        Install-Module -Name $_ -Scope CurrentUser
        Update-Module -Name $_ -Force
    }
}

TASK psmodule:publish {
    $PSModuleName = (InvokeBuild::PSModule::Get-ModuleName)
    $PSRepository = (CONF psmodule.repository)
    Publish-Module `
        -Path $PSModuleName `
        -Repository $PSRepository `
        -Force
}

TASK psmodule:show:psrepository {
    $PSRepository = (CONF psmodule.repository)
    explorer (Get-PSRepository -Name $PSRepository).SourceLocation
}
