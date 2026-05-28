# Fix Gradle download timeout: clear broken cache, pre-fetch from mirror
$ErrorActionPreference = 'Stop'
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$AndroidDir = Join-Path $ProjectRoot 'android'

Write-Host 'Removing incomplete Gradle 8.14 cache...'
$distRoot = Join-Path $env:USERPROFILE '.gradle\wrapper\dists\gradle-8.14-all'
if (Test-Path $distRoot) {
    Remove-Item -Recurse -Force $distRoot
}

$zipUrl = 'https://mirrors.cloud.tencent.com/gradle/gradle-8.14-all.zip'
$tempZip = Join-Path $env:TEMP 'gradle-8.14-all.zip'

Write-Host "Downloading Gradle from mirror: $zipUrl"
Invoke-WebRequest -Uri $zipUrl -OutFile $tempZip -TimeoutSec 600

Set-Location $AndroidDir
$env:Path = "C:\flutter\bin;$env:Path"

Write-Host 'Running Gradle wrapper (will place distribution into ~/.gradle)...'
& .\gradlew.bat --version

Remove-Item $tempZip -Force -ErrorAction SilentlyContinue
Write-Host 'Done. Try: flutter run -d <device-id>'
