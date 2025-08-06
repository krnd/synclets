# python.setuptools.build.ps1 1.2
#Requires -Version 5.1


# ################################ CONFIGURATION ###############################

CONFIGURE python.setuptools.output `
    -Default "dist"


# ################################ TASKS #######################################

TASK python:setuptools:build python:venv:activate, {
    Get-ChildItem @("setup.py", "*/setup.py") `
    | ForEach-Object {
        EXEC {
            python -m build `
                $_.DirectoryName `
                --outdir (CONF python.setuptools.output) `
                --wheel
        }
        Remove-Item (Join-Path $_.Directory "build") `
            -ErrorAction SilentlyContinue `
            -Recurse -Force
    }
}

TASK python:setuptools:install python:venv:activate, {
    Get-ChildItem @("setup.py", "*/setup.py") `
    | ForEach-Object {
        EXEC {
            pip install `
                --editable $_.Directory `
                --force
        }
    }
}

TASK python:setuptools:clean {
    Get-ChildItem @("setup.py", "*/setup.py") `
    | ForEach-Object {
        Remove-Item (Join-Path $_.Directory "build") `
            -ErrorAction SilentlyContinue `
            -Recurse -Force
        Remove-Item (Join-Path $_.Directory "*.egg-info") `
            -ErrorAction SilentlyContinue `
            -Recurse -Force
    }
}
