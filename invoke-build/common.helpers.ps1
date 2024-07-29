#Requires -Version 5.1


# ################################ FUNCTIONS ###################################

# ###################### Path ##############################

function Join-Paths {
    [CmdletBinding(PositionalBinding = $False)]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromRemainingArguments)]
        [string[]]
        $Paths
    )
    $Result = $Paths[0]
    foreach ($Item in $Paths[1..$Paths.Count]) {
        $Result = (Join-Path $Result $Item)
    }
    return $Result
}


# ###################### File ##############################

function Out-FileUTF8NoBOM {
    [CmdletBinding(PositionalBinding = $False)]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string[]]
        $FilePath,
        [Parameter(Mandatory, Position = 1, ValueFromPipeline)]
        [string[]]
        $Text,
        [Parameter()]
        [switch]
        $Append
    )
    begin {
        $UTF8NoBomEncoding = New-Object System.Text.UTF8Encoding $False
        if (-not $Append) {
            [System.IO.File]::WriteAllText(
                $FilePath, [System.String]::Empty,
                $UTF8NoBomEncoding)
        }
    }
    process {
        [System.IO.File]::AppendAllLines(
            $FilePath, $Text,
            $UTF8NoBomEncoding)
    }
}


# ###################### JSON ##############################

function Test-JsonObject {
    [CmdletBinding(PositionalBinding = $False)]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [object]
        $Object,
        [Parameter(Mandatory, Position = 0)]
        [switch]
        $Key
    )
    process {
        $Object | Get-Member -MemberType NoteProperty | ForEach-Object {
            if ($_.Name -eq $Key) {
                return $true
            }
        }
        return $false
    }
}

function Select-JsonObject {
    [CmdletBinding(PositionalBinding = $False)]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [object]
        $Object,
        [Parameter(Mandatory, Position = 0)]
        [string]
        $Key
    )
    process {
        return ($Object."$Key")
    }
}

function Set-JsonObject {
    [CmdletBinding(PositionalBinding = $False)]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [object]
        $Object,
        [Parameter(Mandatory, Position = 0)]
        [string]
        $Key,
        [Parameter(Mandatory, Position = 1)]
        [object]
        $Value
    )
    process {
        $Object."$Key" = $Value
    }
}

function Expand-JsonObject {
    [CmdletBinding(PositionalBinding = $False, DefaultParameterSetName = "Items")]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [object]
        $Object,
        [Parameter(ParameterSetName = "Keys")]
        [switch]
        $Keys,
        [Parameter(ParameterSetName = "Values")]
        [switch]
        $Values
    )
    process {
        if ($Keys) {
            return $Object | Get-Member -MemberType NoteProperty `
            | ForEach-Object { $_.Name }
        } elseif ($Values) {
            return $Object | Get-Member -MemberType NoteProperty `
            | ForEach-Object { $Object."$($_.Name)" }
        } else {
            return $Object | Get-Member -MemberType NoteProperty `
            | ForEach-Object {
                return [PSCustomObject]@{
                    Key   = $_.Name
                    Value = $Object."$($_.Name)"
                }
            }
        }
    }
}
