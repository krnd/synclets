#Requires -Version 5.1


# ################################ VARIABLES ###################################

$script:__InvokeBuild::Plugin::DataStore = @{
    File   = $MyInvocation.MyCommand.Name
    Prefix = "DATASTORE"
    Stores = @{}
}


# ################################ FUNCTIONS ###################################

function __InvokeBuild::Plugin::DataStore::*MAKE {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Mandatory, Position = 0)]
        [string]
        $Name,
        [Parameter()]
        [string]
        $File,
        [Parameter()]
        [hashtable]
        $Values
    )
    $PLUGIN = $script:__InvokeBuild::Plugin::DataStore

    if ($PLUGIN::Stores.ContainsKey($Name)) {
        throw "[$($PLUGIN::Prefix):MAKE] " `
            + "Data store '$Name' already exists."
    }
    $DataStore = @{}

    if (-not $File) {
        $Json = (Get-Content $File -Raw | ConvertFrom-Json)
        $Json.PSObject.Properties | ForEach-Object {
            $DataStore[$_.Name] = $_.Value
        }
    }

    if ($null -ne $Values) {
        foreach ($Key in $Values.Keys) {
            $DataStore[$Key] = $Values[$Key]
        }
    }

    $PLUGIN::Stores[$Name] = (
        $DataStore + @{
            __Name = $Name
        }
    )
}

Set-Alias DATASTORE:MAKE __InvokeBuild::Plugin::DataStore::*MAKE

function __InvokeBuild::Plugin::DataStore::*OBJECT {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Mandatory, Position = 0)]
        [string]
        $Name,
        [Parameter()]
        [ValidateSet("Empty", "Null", $null)]
        [string]
        $Default
    )
    $PLUGIN = $script:__InvokeBuild::Plugin::DataStore

    if (-not $PLUGIN::Stores.ContainsKey($Name)) {
        switch ($Default) {
            "Empty" { return @{} }
            "Null" { return $null }
        }
        throw "[$($PLUGIN::Prefix):OBJECT] " `
            + "Data store '$Name' not found."
    }
    $DataStore = $PLUGIN::Stores[$Name]

    return $DataStore
}

Set-Alias DATASTORE:OBJECT __InvokeBuild::Plugin::DataStore::*OBJECT

function __InvokeBuild::Plugin::DataStore::*VALUE {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Mandatory, Position = 0)]
        [string]
        $Store,
        [Parameter(Mandatory, Position = 1)]
        [string]
        $Name,
        [Parameter(Mandatory)]
        [AllowNull()]
        [object]
        $Default
    )
    $PLUGIN = $script:__InvokeBuild::Plugin::DataStore

    if (-not $PLUGIN::Stores.ContainsKey($Store)) {
        throw "[$($PLUGIN::Prefix):VALUE] " `
            + "Data store '$Store' not found."
    }
    $DataStore = $PLUGIN::Stores[$Store]

    if (-not $DataStore.ContainsKey($Name)) {
        $DataStore[$Name] = $Default
    } elseif ($null -eq $DataStore[$Name]) {
        $DataStore[$Name] = $Default
    }
}

Set-Alias DATASTORE:VALUE __InvokeBuild::Plugin::DataStore::*VALUE

function __InvokeBuild::Plugin::DataStore::*GET {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Mandatory, Position = 0)]
        [string]
        $Store,
        [Parameter(Mandatory, Position = 1)]
        [string]
        $Name,
        [Parameter()]
        [object]
        $Default
    )
    $PLUGIN = $script:__InvokeBuild::Plugin::DataStore

    if (-not $PLUGIN::Stores.ContainsKey($Store)) {
        throw "[$($PLUGIN::Prefix):GET] " `
            + "Data store '$Store' not found."
    }
    $DataStore = $PLUGIN::Stores[$Store]

    if (-not $DataStore.ContainsKey($Name)) {
        throw "[$($PLUGIN::Prefix):GET] " `
            + "Data store value '$Store[$Name]' not found."
    }
    $Value = $DataStore[$Name]

    if ($null -eq $Value) {
        if ($null -ne $Default) { return $Default }
        throw "[$($PLUGIN::Prefix):GET] " `
            + "Data store value '$Store[$Name]' not specified."
    }

    return $Value
}

Set-Alias DATASTORE:GET __InvokeBuild::Plugin::DataStore::*GET
