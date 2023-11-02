@echo off

MORE +17 "%~f0" > "%~f0.ps1"

PowerShell ^
-ExecutionPolicy RemoteSigned ^
-File "%~f0.ps1"

DEL /F /Q "%~f0.ps1"

echo.
echo.
PAUSE

(GOTO) 2> NUL & DEL /F /Q "%~f0"

REM =============================< PowerShell >=================================
#Requires -Version 5.1

write-Host "==========[ Invoke-Build Bootstrapper ]=========="
write-Host

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
} | ForEach-Object {

    $RelativePath = $(Resolve-Path -Relative $_.FullName)
    if ($RelativePath.StartsWith(".\")) {
        $RelativePath = $RelativePath.Substring(2)
    }

    Write-Host -NoNewline "Taking ownership of '$RelativePath' ... "
    TAKEOWN /F "$($_.FullName)" 2>&1> $null

    if ($LASTEXITCODE -ne 0) {
        Write-Host "FAILED"
        Write-Error "Failed to take ownership of '$($_.FullName)'."
    } else {
        Write-Host "OK"
    }

}
