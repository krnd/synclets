#Requires -Version 5.1


# ################################ CONFIGURATION ###############################

CONFIGURE python.venv.path `
    -Default ".venv"

CONFIGURE python.venv.requirements `
    -Default "requirements.txt"
CONFIGURE python.venv.requirements.sources `
    -Default @()


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
    if (-not (Test-Path $VirtualEnvironmentPath -PathType Container)) {
        py -m venv $VirtualEnvironmentPath
    }
}, python:venv:activate, {
    python -m pip install --upgrade pip
    pip install pip-tools
}, python:venv:compile, {
    $RequirementsFile = (CONF python.venv.requirements)
    if (Test-Path $RequirementsFile -PathType Leaf) {
        pip-sync $RequirementsFile
    }
    pip install pip-tools
}

TASK python:venv:compile python:venv:activate, {
    $RequirementsSources = (CONF python.venv.requirements.sources)
    if (-not $RequirementsSources) {
        $RequirementsFile = (CONF python.venv.requirements)
        $RequirementsSources += [IO.Path]::ChangeExtension(
            $RequirementsFile, "in")
    }
    $RequirementsSources | ForEach-Object {
        if (Test-Path $_ -PathType Leaf) {
            pip-compile --quiet $_
        }
    }
}

TASK python:venv:clean python:venv:deactivate, {
    REMOVE (CONF python.venv.path)
}
