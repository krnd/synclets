#Requires -Version 5.1


# ################################ FUNCTIONS ###################################

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
        $Append = $False
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
