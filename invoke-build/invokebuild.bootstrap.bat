@ECHO OFF

REM Write the PowerShell script file skipping this leading script section.
MORE +23 "%~f0" > "%~f0.ps1"

REM Run the constructed PowerShell script using execution policy overwrite.
PowerShell ^
    -ExecutionPolicy RemoteSigned ^
    -File "%~f0.ps1"

REM Remove the PowerShell script file.
DEL /F /Q "%~f0.ps1"

REM Report that the execution of the PowerShell script completed.
REM Use `SLEEP` to enforce an external confirmation otherwise use `TIMEOUT`.
ECHO.
ECHO.
TIMEOUT 10

REM Remove this script file itself.
(GOTO) 2> NUL & DEL /F /Q "%~f0"

REM =============================< PowerShell >=================================
#Requires -Version 5.1

Write-Host "==========[ Invoke-Build Bootstrapper ]=========="
Write-Host

$Paths = @(
    ".",
    ".invoke",
    ".invokebuild",
    "invoke",
    "invokebuild",
    "invoke-build"
)

$Paths | ForEach-Object {
    Get-ChildItem $_ `
        -Filter "*.build.ps1" `
        -ErrorAction Continue `
        2> $null
    Get-ChildItem $_ `
        -Filter "*.plugin.ps1" `
        -ErrorAction Continue `
        2> $null
    Get-ChildItem $_ `
        -Filter "*.extension.ps1" `
        -ErrorAction Continue `
        2> $null
    Get-ChildItem $_ `
        -Filter "*.helpers.ps1" `
        -ErrorAction Continue `
        2> $null
} | ForEach-Object {

    $RelativePath = $(Resolve-Path -Relative $_.FullName) `
        -replace "\\", "/"
    if ($RelativePath.StartsWith(".\")) {
        $RelativePath = $RelativePath.Substring(2)
    }

    Write-Host -NoNewline "Unblocking '$RelativePath' ... "

    try {
        Unblock-File $_.FullName
        Write-Host "OK"
    } catch {
        Write-Host "FAILED"
        Write-Warning "Failed to unblock '$RelativePath'."
    }

}
