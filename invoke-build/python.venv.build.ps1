#Requires -Version 5.1


# ################################ CONFIGURATION ###############################

CONFIGURE python.venv.shorthands `
    -Default $true

CONFIGURE python.venv.path `
    -Default ".venv"

CONFIGURE python.venv.requirements `
    -Default "requirements.txt"
CONFIGURE python.venv.configuration `
    -Default "develop"


# ################################ SHORTHANDS ##################################

INVOKEBUILD:SETUP {
    if (CONF python.venv.shorthands) {
        if (__InvokeBuild::IsTaskMissing "..") {
            TASK .. python:venv:activate
        }
    }
}


# ################################ TASKS #######################################

TASK python:venv:activate {
    EXEC {
        & (Join-Path `
            (CONF python.venv.path) `
            (Join-Path "Scripts" "Activate.ps1")
        )
    }
}

TASK python:venv:deactivate {
    try { deactivate } catch {}
}

TASK python:venv:setup python:venv:deactivate, {
    $Environment = (CONF python.venv.path)
    if (-not (Test-Path $Environment -PathType Container)) {
        EXEC { py -m venv $Environment }
    }
}, python:venv:activate, {
    EXEC { python -m pip install --upgrade pip }
    EXEC { pip install pip-tools }
}, python:venv:compile, {
    $Requirements = (CONF python.venv.requirements)
    if ($Requirements -is [PSCustomObject]) {
        $Configuration = (CONF python.venv.configuration)
        $Target = $Requirements.$Configuration

    } else {
        $Target = if ($Requirements -is [array]) {
            $Requirements[0]
        } else {
            $Requirements
        }
    }

    $Target = [IO.Path]::ChangeExtension($Target, "txt")
    if (Test-Path $Target -PathType Leaf) {
        EXEC {
            pip-sync $Target `
                --quiet `
                --force
        }
    }

    EXEC { pip install pip-tools }
}

TASK python:venv:compile python:venv:activate, {
    $Compilants = @{}

    $Requirements = (CONF python.venv.requirements)
    if ($Requirements -is [PSCustomObject]) {
        foreach ($Item in $Requirements.PSObject.Properties) {
            $Target = if ($Item.Value -is [array]) {
                $Item.Value[0]
            } else {
                $Item.Value
            }
            $Compilants[$Target] = @($Item.Value)
        }
    } else {
        $Target = if ($Requirements -is [array]) {
            $Requirements[0]
        } else {
            $Requirements
        }
        $Compilants[$Target] = @($Requirements)
    }

    $Compilants.GetEnumerator() | ForEach-Object {
        $Target = [IO.Path]::ChangeExtension($_.Key, "txt")
        EXEC {
            pip-compile $_.Value `
                --output-file $Target `
                --strip-extras `
                --quiet
        }
    }
}

TASK python:venv:clean python:venv:deactivate, {
    REMOVE (CONF python.venv.path)
}
