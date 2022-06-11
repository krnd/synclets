#Requires -Version 5.1

# cspell:ignore venv


# ################################ CONFIGURATION ###############################

CONFIGURE python.venv.path `
    -Default ".venv"

CONFIGURE python.venv.requirements `
    -Default "requirements.txt"


# ################################ TASKS #######################################

TASK python:venv:activate {
    & (Join-Path `
        (CONF python.venv.path) `
        (Join-Path "Scripts" "Activate.ps1")
    )
}

TASK python:venv:deactivate {
    try { deactivate } catch {}
}

TASK python:venv:setup python:venv:deactivate, {
    $VirtualEnvironmentPath = (CONF python.venv.path)
    if (-not (Test-Path $VirtualEnvironmentPath)) {
        py -m venv $VirtualEnvironmentPath
    }
}, python:venv:activate, {
    python -m pip install --upgrade pip

    pip install pip-tools

    $RequirementsFile = (CONF python.venv.requirements)
    if (Test-Path $RequirementsFile -PathType Leaf) {
        pip-sync $RequirementsFile
    }
}

TASK python:venv:clean python:venv:deactivate, {
    REMOVE (CONF python.venv.path)
}
