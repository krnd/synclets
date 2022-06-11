#Requires -Version 5.1


# ################################ FUNCTIONS ###################################

function __InvokeBuild_BundlePlugin_BUNDLE {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [hashtable]
        $Parameter,
        [Parameter(Position = 1, Mandatory = $true)]
        [scriptblock]
        $Script,
        [Parameter()]
        [switch]
        $Cleanup
    )
    PIPELINE bundle @{
        Input   = "."
        Working = "build-bundle"
        Output  = "."
        Exports = @()
    }, $Parameter

    PIPELINE:INVOKE $Script

    New-Item `
        -Path (PIPELINE:GET Output) `
        -ItemType Directory `
        -ErrorAction SilentlyContinue `
        -Force | Out-Null
    (PIPELINE:GET Exports) | Copy-Item `
        -Destination (PIPELINE:GET Output) `
        -Recurse `
        -Force

    if ($Cleanup) {
        Remove-Item `
            -Path (PIPELINE:GET Working) `
            -ErrorAction SilentlyContinue `
            -Recurse `
            -Force
    }
}

Set-Alias BUNDLE __InvokeBuild_BundlePlugin_BUNDLE

function __InvokeBuild_BundlePlugin_GATHER {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]
        $Name,
        [Parameter(Position = 1, Mandatory = $true)]
        [hashtable]
        $Parameter,
        [Parameter()]
        [scriptblock]
        $Process
    )
    $GathererName = "__InvokeBuild_BundlePlugin_Gatherer_$Name"
    $Gatherer = (Get-Variable $GathererName -ErrorAction SilentlyContinue)

    if (-not $Gatherer) {
        throw "Missing BUNDLE:GATHERER '$Name'. ($($Task.Name))"
    }

    $ItemList = (& $Gatherer.Value @Parameter)

    if ($Process) {
        $ItemList | ForEach-Object $Process
    }
}

Set-Alias GATHER __InvokeBuild_BundlePlugin_GATHER

function __InvokeBuild_BundlePlugin_TRANSFORM {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]
        $Name,
        [Parameter(Position = 1, Mandatory = $true)]
        [hashtable]
        $Parameter,
        [Parameter(Position = 0, Mandatory = $true)]
        [switch]
        $Export
    )
    $TransformerName = "__InvokeBuild_BundlePlugin_Transformer_$Name"
    $Transformer = (Get-Variable $TransformerName -ErrorAction SilentlyContinue)

    if (-not $Transformer) {
        throw "Missing BUNDLE:TRANSFORMER '$Name'. ($($Task.Name))"
    }

    $ItemList = (& $Transformer.Value @Parameter)

    if ($Export) {
        $Pipeline.Exports += $ItemList
    }
}

Set-Alias TRANSFORM __InvokeBuild_BundlePlugin_TRANSFORM


# ################################ GATHERER ####################################

function __InvokeBuild_BundlePlugin_Gatherer {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]
        $Name,
        [Parameter(Position = 1, Mandatory = $true)]
        [scriptblock]
        $Script
    )
    Set-Variable `
        -Scope Script `
        -Name "__InvokeBuild_BundlePlugin_Gatherer_$Name" `
        -Value $Script
}

Set-Alias BUNDLE:GATHERER __InvokeBuild_BundlePlugin_Gatherer

Get-ChildItem $SearchPath -Filter "bundle.gather.*.ps1" | ForEach-Object {
    if ($_.FullName -eq $MyInvocation.MyCommand.Definition) {
        return
    }
    . $_.FullName
}


# ################################ TRANSFORMER #################################

function __InvokeBuild_BundlePlugin_Transformer {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]
        $Name,
        [Parameter(Position = 1, Mandatory = $true)]
        [scriptblock]
        $Script
    )
    Set-Variable `
        -Scope Script `
        -Name "__InvokeBuild_BundlePlugin_Transformer_$Name" `
        -Value $Script
}

Set-Alias BUNDLE:TRANSFORMER __InvokeBuild_BundlePlugin_Transformer

Get-ChildItem $SearchPath -Filter "bundle.transform.*.ps1" | ForEach-Object {
    . $_.FullName
}
