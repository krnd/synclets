# python.setuptools.build.ps1 1.0
#Requires -Version 5.1


# ################################ VARIABLES ###################################

$script:__InvokeBuild::Builder["python.setuptools"] = @{}


# ################################ CONFIGURATION ###############################

CONFIGURE python.setuptools.dist `
    -Default "dist"


# ################################ TASKS #######################################

TASK python:setuptools:build python:venv:activate, {
    Get-ChildItem "*/setup.py" `
    | ForEach-Object {
        EXEC {
            python -m build `
                $_.DirectoryName `
                --outdir (CONF python.setuptools.dist) `
                --wheel
        }
        Remove-Item (Join-Path $_.Directory "build") `
            -ErrorAction SilentlyContinue `
            -Recurse -Force
    }
}

TASK python:setuptools:install python:venv:activate, {
    Get-ChildItem "*/setup.py" `
    | ForEach-Object {
        EXEC {
            pip install `
                --editable $_.Directory `
                --force
        }
    }
}

TASK python:setuptools:clean {
    Get-ChildItem "*/setup.py" `
    | ForEach-Object {
        Remove-Item (Join-Path $_.Directory "build") `
            -ErrorAction SilentlyContinue `
            -Recurse -Force
        Remove-Item (Join-Path $_.Directory "*.egg-info") `
            -ErrorAction SilentlyContinue `
            -Recurse -Force
    }
}
