#Requires -Version 5.1


# ################################ CONFIGURATION ###############################

CONFIGURE python.venv.path `
    -Default ".venv"

CONFIGURE python.venv.requirements `
    -Default "requirements.txt"

CONFIGURE python.venv.compilants `
    -Default @()


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
    if (Test-Path $Requirements -PathType Leaf) {
        EXEC {
            pip-sync $Requirements `
                --quiet `
                --force
        }
    }
    EXEC { pip install pip-tools }
}

TASK python:venv:compile python:venv:activate, {
    $Compilants = (CONF python.venv.compilants)
    $Compilants += @((CONF python.venv.requirements))
    $Compilants | ForEach-Object {
        $File = [IO.Path]::ChangeExtension($_, "in")
        if (Test-Path $File -PathType Leaf) {
            EXEC {
                pip-compile $File `
                    --quiet
            }
        }
    }
}

TASK python:venv:clean python:venv:deactivate, {
    REMOVE (CONF python.venv.path)
}
