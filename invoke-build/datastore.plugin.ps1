#Requires -Version 5.1


# ################################ VARIABLES ###################################

$script:__InvokeBuild_DataStore = @{}


# ################################ FUNCTIONS ###################################

function __InvokeBuild_DataStorePlugin_MAKE {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]
        $Name,
        [Parameter()]
        [string[]]
        $JsonFile,
        [Parameter()]
        [hashtable[]]
        $Values
    )
    $ValueSources = if ($Values) {$Values} else {@{}}
    if ($JsonFile) {
        $ValueSources += $JsonFile | ForEach-Object {
            (Get-Content $_ -Raw | ConvertFrom-Json)
        }
    }

    $DataTable = @{}
    foreach ($Source in $ValueSources) {
        foreach ($Key in $Source.Keys) {
            $DataTable[$Key] = $Source[$Key]
        }
    }

    $DataStore = [PSCustomObject]$DataTable
    $DataStore | Add-Member `
        -MemberType NoteProperty `
        -Name "__DataStoreName" `
        -Value $Name

    $script:__InvokeBuild_DataStore[$Name] = $DataStore
}

Set-Alias DATASTORE __InvokeBuild_DataStorePlugin_MAKE

Set-Alias DATASTORE:MAKE __InvokeBuild_DataStorePlugin_MAKE
Set-Alias DS:MAKE __InvokeBuild_DataStorePlugin_MAKE

function __InvokeBuild_DataStorePlugin_OBJECT {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]
        $StoreName
    )
    if (-not $script:__InvokeBuild_DataStore.ContainsKey($StoreName)) {
        throw "Missing DATASTORE '$StoreName'. ($($Task.Name))"
    }
    return $script:__InvokeBuild_DataStore[$StoreName]
}

Set-Alias DATASTORE:OBJECT __InvokeBuild_DataStorePlugin_OBJECT
Set-Alias DS:OBJECT __InvokeBuild_DataStorePlugin_OBJECT

function __InvokeBuild_DataStorePlugin_VALUE {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]
        $StoreName,
        [Parameter(Position = 1, Mandatory = $true)]
        [string]
        $Name,
        [Parameter(Mandatory = $true)]
        [object]
        $Default
    )
    if (-not $script:__InvokeBuild_DataStore.ContainsKey($StoreName)) {
        throw "Missing DATASTORE '$StoreName'. ($($Task.Name))"
    }
    $DataStore = $script:__InvokeBuild_DataStore[$StoreName]

    if (($null -eq $DataStore.PSObject.Properties.Name) -or `
            -not $DataStore.PSObject.Properties.Name.Contains($Name)) {
        $DataStore | Add-Member `
            -MemberType NoteProperty `
            -Name $Name `
            -Value $Default
    }
}

Set-Alias DATASTORE:VALUE __InvokeBuild_DataStorePlugin_VALUE
Set-Alias DS:VALUE __InvokeBuild_DataStorePlugin_VALUE

function __InvokeBuild_DataStorePlugin_GET {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]
        $StoreName,
        [Parameter(Position = 1, Mandatory = $true)]
        [string]
        $Name
    )
    if (-not $script:__InvokeBuild_DataStore.ContainsKey($StoreName)) {
        throw "Missing DATASTORE '$StoreName'. ($($Task.Name))"
    }
    $DataStore = $script:__InvokeBuild_DataStore[$StoreName]

    if (-not $DataStore.PSObject.Properties.Name.Contains($Name)) {
        throw "Missing DATASTORE key '$StoreName::$Name'. ($($Task.Name))"
    }
    return $DataStore.$Name
}

Set-Alias DATASTORE:GET __InvokeBuild_DataStorePlugin_GET
Set-Alias DS:GET __InvokeBuild_DataStorePlugin_GET
