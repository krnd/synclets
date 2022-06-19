#Requires -Version 5.1


# ################################ FUNCTIONS ###################################

function __InvokeBuild::Pipeline::SETUP {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]
        $Name,
        [Parameter(Position = 1, Mandatory = $true)]
        [hashtable[]]
        $Parameter
    )
    DATASTORE:MAKE pipeline `
        -Values ($Parameter + @{
            Name = $Name
        })
}

Set-Alias PIPELINE __InvokeBuild::Pipeline::SETUP

Set-Alias PIPELINE:SETUP __InvokeBuild::Pipeline::SETUP

function __InvokeBuild::Pipeline::INVOKE {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [scriptblock]
        $Script
    )
    $Pipeline = (DATASTORE:OBJECT pipeline)
    $Script.Invoke($Pipeline)
}

Set-Alias PIPELINE:INVOKE __InvokeBuild::Pipeline::INVOKE

function __InvokeBuild::Pipeline::GET {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]
        $Name
    )
    return (DATASTORE:GET pipeline $Name)
}

Set-Alias PIPELINE:GET __InvokeBuild::Pipeline::GET
