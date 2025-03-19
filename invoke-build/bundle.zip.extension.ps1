# bundle.zip.extension.ps1 1.0
#Requires -Version 5.1


# ################################ FUNCTIONS ###################################

__InvokeBuild::Plugin::Bundle::MakeBundler zip {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Mandatory)]
        [string]
        $Artifact,
        [Parameter(Mandatory)]
        [string]
        $Source,
        [Parameter(ValueFromRemainingArguments)]
        [string[]]
        $Passthrough = @()
    )
    Compress-Archive $Source `
        -DestinationPath $Artifact `
        @Passthrough `
        -Force
}
