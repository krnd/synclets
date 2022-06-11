#Requires -Version 5.1


# ################################ FUNCTIONS ###################################

function __InvokeBuild_PipelinePlugin_SETUP {
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

Set-Alias PIPELINE __InvokeBuild_PipelinePlugin_SETUP

Set-Alias PIPELINE:SETUP __InvokeBuild_PipelinePlugin_SETUP

function __InvokeBuild_PipelinePlugin_INVOKE {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [scriptblock]
        $Script
    )
    $Pipeline = (DATASTORE:OBJECT pipeline)
    $Script.Invoke($Pipeline)
}

Set-Alias PIPELINE:INVOKE __InvokeBuild_PipelinePlugin_INVOKE

function __InvokeBuild_PipelinePlugin_GET {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]
        $Name
    )
    return (DATASTORE:GET pipeline $Name)
}

Set-Alias PIPELINE:GET __InvokeBuild_PipelinePlugin_GET
