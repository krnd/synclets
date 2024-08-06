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
TIMEOUT 20

REM Remove this script file itself.
(GOTO) 2> NUL & DEL /F /Q "%~f0"

REM =============================< PowerShell >=================================
#Requires -Version 5.1

write-Host "==========[ Invoke-Build Updater ]=========="
write-Host

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
