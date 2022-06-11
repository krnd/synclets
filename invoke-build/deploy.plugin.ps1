#Requires -Version 5.1


# ################################ FUNCTIONS ###################################

function __InvokeBuild_DeployPlugin_DEPLOY {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [hashtable]
        $Parameter,
        [Parameter(Position = 1, Mandatory = $true)]
        [scriptblock]
        $Script
    )
    PIPELINE deploy @{
        Item = $null
        SetupArgs = @{}
    }, $Parameter

    PIPELINE:INVOKE $Script
}

Set-Alias DEPLOY __InvokeBuild_DeployPlugin_DEPLOY

function __InvokeBuild_DeployPlugin_TARGET {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]
        $Name,
        [Parameter(Position = 1, Mandatory = $true)]
        [hashtable]
        $Parameter,
        [Parameter()]
        [string[]]
        $Tag,
        [Parameter()]
        [scriptblock]
        $Setup
    )
    $DeployerName = "__InvokeBuild_DeployPlugin_Deployer_$Name"
    $Deployer = (Get-Variable $DeployerName -ErrorAction SilentlyContinue)

    if (-not $Deployer) {
        throw "Missing DEPLOY:DEPLOYER '$Name'. ($($Task.Name))"
    }

    if ($Setup) {
        $SetupArgs = $Pipeline.SetupArgs
        & $Setup @SetupArgs
    }

    & $Deployer.Value @Parameter
}

Set-Alias TARGET __InvokeBuild_DeployPlugin_TARGET


# ################################ DEPLOYER ####################################

function __InvokeBuild_DeployPlugin_Deployer {
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
        -Name "__InvokeBuild_DeployPlugin_Deployer_$Name" `
        -Value $Script
}

Set-Alias DEPLOY:DEPLOYER __InvokeBuild_DeployPlugin_Deployer

Get-ChildItem $SearchPath -Filter "deploy.*.ps1" | ForEach-Object {
    if ($_.FullName -eq $MyInvocation.MyCommand.Definition) {
        return
    }
    . $_.FullName
}
