@REM invokebuild.update.bat 1.0
@ECHO OFF

REM Write the PowerShell script.
REM (Skip the leading command prompt script section.)
MORE +26 "%~f0" > "%~f0.ps1"

REM Run the generated PowerShell script.
REM (Use a less restrictive execution policy.)
PowerShell ^
    -ExecutionPolicy RemoteSigned ^
    -File "%~f0.ps1"

REM Remove the PowerShell script.
DEL /F /Q "%~f0.ps1"

REM Report that the execution of the PowerShell script completed.
REM Use `PAUSE` to enforce an explicit confirmation otherwise use `TIMEOUT`.
ECHO.
ECHO.
TIMEOUT 20

REM Remove the file itself.
(GOTO) 2> NUL & DEL /F /Q "%~f0"

REM =============================< PowerShell >=================================
#Requires -Version 5.1

Write-Host "==========[ Invoke-Build Updater ]=========="
Write-Host

$Paths = @(
    ".",
    ".invoke",
    ".invokebuild",
    "invoke",
    "invokebuild",
    "invoke-build"
)

$UrlTemplate = if ($null -ne $env:INVOKE_BUILD_UPDATER_URL_TEMPLATE) {
    $env:INVOKE_BUILD_UPDATER_URL_TEMPLATE
} else {
    "https://raw.githubusercontent.com/krnd/synclets/main/invoke-build/{}"
}

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

    Write-Host -NoNewline "Updating '$RelativePath' ... "

    $UpdateStep = $null
    try {

        $UpdateStep = "download"
        Invoke-WebRequest `
            -Uri ($UrlTemplate -replace "{}", $_.Name) `
            -OutFile $_.FullName

        $UpdateStep = "unblock"
        Unblock-File $_.FullName

        $UpdateStep = "convert"
        (Get-Content $_.FullName -Raw) `
            -replace "`n", "`r`n" `
        | Set-Content -Path $_.FullName

        Write-Host "OK"

    } catch {
        Write-Host "FAILED"
        Write-Warning "Failed to update '$RelativePath'. ($UpdateStep)"
    }

}
