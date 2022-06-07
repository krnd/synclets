# cspell:ignore venv


# ################################ configuration ###############################

CONFVAL "python.venv.path" `
    -Default ".venv"

CONFVAL "python.venv.requirements" `
    -Default "requirements.txt"


# ################################ common ######################################

TASK python:venv:activate {
    & (Join-Path `
        (CONF "python.venv.path") `
        (Join-Path "Scripts" "Activate.ps1")
    )
}

TASK python:venv:deactivate {
    try { deactivate } catch {}
}


# ################################ setup #######################################

TASK setup:python:venv python:venv:deactivate, {
    $venvPath = (CONF "python.venv.path")
    if (-not (Test-Path $venvPath)) {
        py -m venv $venvPath
    }
}, python:venv:activate, {
    python -m pip install --upgrade pip
    pip install pip-tools
    $requirementsFile = (CONF "python.venv.requirements")
    if (Test-Path $requirementsFile) {
        pip-sync $requirementsFile
    }
}


# ################################ clean #######################################

TASK clean:python:venv python:venv:deactivate, {
    REMOVE (CONF "python.venv.path")
}
