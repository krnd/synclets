#Requires -Version 5.1


# ################################ CONFIGURATION ###############################

CONFIGURE python.hatch.output `
    -Default "dist"


# ################################ TASKS #######################################

TASK python:hatch:build python:venv:activate, {
    EXEC {
        hatch build
    }
}

TASK python:hatch:install python:venv:activate, {
    $Wheel = "$(hatch project metadata name)-$(hatch version)-py2.py3-none-any.whl"
    EXEC {
        pip install `
            --no-cache-dir (Join-Path (CONF python.hatch.output) $Wheel) `
            --force
    }
}

TASK python:hatch:uninstall python:venv:activate, {
    $Package = "$(hatch project metadata name)"
    EXEC {
        pip uninstall $Package
    }
}
