#Requires -Version 5.1


# ################################ VARIABLES ###################################

$script:__InvokeBuild::DataStore = @{}


# ################################ FUNCTIONS ###################################

function __InvokeBuild::DataStore::MAKE {
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
    $DataTable = @{}

    if ($JsonFile) {
        $JsonFile | ForEach-Object {
            $JsonData = (Get-Content $_ -Raw | ConvertFrom-Json)
            $JsonData | Get-Member -MemberType NoteProperty | ForEach-Object {
                $DataTable[$_.Name] = $JsonData.$($_.Name)
            }
        }
    }

    if ($Values) {
        $Values | ForEach-Object {
            foreach ($Key in $_.Keys) {
                $DataTable[$Key] = $_[$Key]
            }
        }
    }

    $DataStore = [PSCustomObject]$DataTable
    $DataStore | Add-Member `
        -MemberType NoteProperty `
        -Name "__DataStoreName" `
        -Value $Name

    $script:__InvokeBuild::DataStore[$Name] = $DataStore
}

Set-Alias DATASTORE __InvokeBuild::DataStore::MAKE

Set-Alias DATASTORE:MAKE __InvokeBuild::DataStore::MAKE
Set-Alias DS:MAKE __InvokeBuild::DataStore::MAKE

function __InvokeBuild::DataStore::OBJECT {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]
        $StoreName
    )
    if (-not $script:__InvokeBuild::DataStore.ContainsKey($StoreName)) {
        throw "Missing DATASTORE '$StoreName'. ($($Task.Name))"
    }
    return $script:__InvokeBuild::DataStore[$StoreName]
}

Set-Alias DATASTORE:OBJECT __InvokeBuild::DataStore::OBJECT
Set-Alias DS:OBJECT __InvokeBuild::DataStore::OBJECT

function __InvokeBuild::DataStore::VALUE {
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
    if (-not $script:__InvokeBuild::DataStore.ContainsKey($StoreName)) {
        throw "Missing DATASTORE '$StoreName'. ($($Task.Name))"
    }
    $DataStore = $script:__InvokeBuild::DataStore[$StoreName]

    if (($null -eq $DataStore.PSObject.Properties.Name) -or `
            -not $DataStore.PSObject.Properties.Name.Contains($Name)) {
        $DataStore | Add-Member `
            -MemberType NoteProperty `
            -Name $Name `
            -Value $Default
    }
}

Set-Alias DATASTORE:VALUE __InvokeBuild::DataStore::VALUE
Set-Alias DS:VALUE __InvokeBuild::DataStore::VALUE

function __InvokeBuild::DataStore::GET {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]
        $StoreName,
        [Parameter(Position = 1, Mandatory = $true)]
        [string]
        $Name
    )
    if (-not $script:__InvokeBuild::DataStore.ContainsKey($StoreName)) {
        throw "Missing DATASTORE '$StoreName'. ($($Task.Name))"
    }
    $DataStore = $script:__InvokeBuild::DataStore[$StoreName]

    if (-not $DataStore.PSObject.Properties.Name.Contains($Name)) {
        throw "Missing DATASTORE key '$StoreName::$Name'. ($($Task.Name))"
    }
    return $DataStore.$Name
}

Set-Alias DATASTORE:GET __InvokeBuild::DataStore::GET
Set-Alias DS:GET __InvokeBuild::DataStore::GET
