# Notes


### [Avoid Write-Host](https://github.com/nightroman/Invoke-Build/wiki/Build-Scripts-Guidelines#avoid-write-host)

```powershell

##### DO #####

Write-Output "[Write-Output]"
Write-Build ColorName "[Write-Build]"

Write-Warning "[Write-Warning]"

Write-Verbose "[Write-Verbose]"

##### DONT #####

# Use `Write-Output` or `Write-Build` instead.
Write-Host "[Write-Host]"

# Use `throw` instead.
Write-Error "[Write-Error]"

```
