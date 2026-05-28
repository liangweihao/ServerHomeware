# Run Flutter dev build using config/env.local.json
# Usage: .\scripts\run_dev.ps1 [-Device windows] [-Platform windows]

param(
    [string]$Device = 'windows',
    [ValidateSet('windows', 'android', 'device')]
    [string]$Platform = 'windows'
)

$ErrorActionPreference = 'Stop'
$ProjectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $ProjectRoot

$envFile = Join-Path $ProjectRoot 'config\env.local.json'
if (-not (Test-Path $envFile)) {
    Write-Host "config/env.local.json missing, running setup..."
    & (Join-Path $PSScriptRoot 'setup_env.ps1') -Platform $Platform
}

$config = Get-Content $envFile -Raw | ConvertFrom-Json
$apiBaseUrl = $config.API_BASE_URL

$flutterCandidates = @(
    "$env:LOCALAPPDATA\flutter\bin\flutter.bat",
    'C:\flutter\bin\flutter.bat',
    "$env:USERPROFILE\flutter\bin\flutter.bat",
    "$env:USERPROFILE\fvm\default\bin\flutter.bat"
)
$flutter = $flutterCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $flutter) {
    throw 'Flutter not found. Install Flutter or run scripts/setup_env.ps1'
}

Write-Host "API_BASE_URL = $apiBaseUrl"
Write-Host "Device = $Device"
Write-Host ""

& $flutter run -d $Device --dart-define=API_BASE_URL=$apiBaseUrl
