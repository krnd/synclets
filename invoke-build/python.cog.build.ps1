# python.cog.build.ps1 1.0
#Requires -Version 5.1


# ################################ CONFIGURATION ###############################

CONFIGURE python.cog.quiet `
    -Default $false
CONFIGURE python.cog.verbose `
    -Default $false

CONFIGURE python.cog.markers `
    -Default "[[[cog ]]] [[[end]]]"

CONFIGURE python.cog.include `
    -Default @()
CONFIGURE python.cog.prologue `
    -Default ""

CONFIGURE python.cog.replace `
    -Default $true

CONFIGURE python.cog.paths `
    -Default @()
CONFIGURE python.cog.filter `
    -Default @()

CONFIGURE python.cog.presetmode `
    -Default $false


# ################################ TASKS #######################################

TASK python:cog:run python:venv:activate, {
    $INVOKE = $script:__InvokeBuild

    $Verbosity = `
        if (CONF python.cog.quiet) { 0 } `
        elseif (CONF python.cog.verbose) { 2 } `
        else { 1 }
    $Markers = (CONF python.cog.markers)
    $IncludePaths = (CONF python.cog.include) -join ";"
    $Prologue = (CONF python.cog.prologue) -join ";"
    $ReplaceOutput = if (CONF python.cog.replace) { "-r" } else { $null }

    if (CONF python.cog.presetmode) {
        $PrefixedIncludePaths = ".cog"
        $IncludePaths = if ($IncludePaths) {
            $PrefixedIncludePaths + ";" + $IncludePaths
        } else {
            $PrefixedIncludePaths
        }
        $PrefixedPrologue = @(
            "import __cog__",
            "__cog__.install(globals(), r'$($INVOKE::ConfigFile)')"
        ) -join ";"
        $Prologue = if ($Prologue) {
            $PrefixedPrologue + ";" + $Prologue
        } else {
            $PrefixedPrologue
        }
    }

    $Sources = @()
    foreach ($Path in (CONF python.cog.paths)) {
        $Sources += Get-ChildItem $Path -File `
            -Include (CONF python.cog.filter) `
            -Recurse
    }

    $Sources | ForEach-Object {
        EXEC {
            cog `
                --verbosity=$Verbosity `
                --markers=`"$Markers`" `
                -I `"$IncludePaths`" `
                -p `"$Prologue`" `
                $ReplaceOutput `
                $_.FullName
        }
    }
}
