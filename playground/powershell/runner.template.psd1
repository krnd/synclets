@{
    # [bool]
    BaseConfig = $true
    # [string] | [string[]]
    # => if specified config is considered base config
    Paths = @("runner")

    # config set: <module>
    # => required if <module>
    # => if specified config is considered <module>
    Module = MISSING
    # config set: <module> or <command>
    # => required if <module> or <command>
    # => if specified and $Module is not specified config is considered <command>
    Command = MISSING
    # config set: <file>
    # => required if <file>
    # => if neither $Module nor $Command are specified config is considered <file>
    File = MISSING

    # [string]
    Title = ($Module -or $Command -or $File.NameWithoutExtension)
    # [string[]]
    # => if prefixed with '!' module is imported with -Force
    Imports = @()
    # [object[]] | [hashtable]
    Parameters = @{}
    # [string]
    Output = $null

    # [scriptblock] | $null
    # => if explicitly set to $null then no output
    # => if not specified then defaults to '{ $Input | Format-Table }'
    # applied to results
    Formatter = $null
}