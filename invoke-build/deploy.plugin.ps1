#Requires -Version 5.1


# ################################ FUNCTIONS ###################################

function __InvokeBuild::Deploy::DEPLOY {
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

Set-Alias DEPLOY __InvokeBuild::Deploy::DEPLOY

function __InvokeBuild::Deploy::TARGET {
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
    $DeployerName = "__InvokeBuild::Deploy::Deployer::$Name"
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

Set-Alias TARGET __InvokeBuild::Deploy::TARGET


# ################################ DEPLOYER ####################################

function __InvokeBuild::Deploy::Deployer {
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
        -Name "__InvokeBuild::Deploy::Deployer::$Name" `
        -Value $Script
}

Set-Alias DEPLOY:DEPLOYER __InvokeBuild::Deploy::Deployer

Get-ChildItem $SearchPath -Filter "deploy.*.ps1" | ForEach-Object {
    if ($_.FullName -eq $MyInvocation.MyCommand.Definition) {
        return
    }
    . $_.FullName
}
