# HomeWareClient environment setup (Windows PowerShell)
# Usage: .\scripts\setup_env.ps1 [-Platform windows|android|device]

param(
    [ValidateSet('windows', 'android', 'device')]
    [string]$Platform = 'windows'
)

$ErrorActionPreference = 'Stop'
$ProjectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $ProjectRoot

function Get-LocalLanIp {
    $ips = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue |
        Where-Object {
            $_.IPAddress -notlike '127.*' -and
            $_.IPAddress -notlike '169.254.*' -and
            $_.PrefixOrigin -ne 'WellKnown'
        } |
        Select-Object -ExpandProperty IPAddress
    if (-not $ips) { return '127.0.0.1' }
    # Prefer common home LAN 192.168.1.x when multiple NICs exist
    $preferred = $ips | Where-Object { $_ -like '192.168.1.*' } | Select-Object -First 1
    if ($preferred) { return $preferred }
    return ($ips | Select-Object -First 1)
}

function Resolve-ApiBaseUrl {
    param([string]$TargetPlatform)
    switch ($TargetPlatform) {
        'android' { return 'http://10.0.2.2:8000/api/v1' }
        'device' {
            $lanIp = Get-LocalLanIp
            return "http://${lanIp}:8000/api/v1"
        }
        default { return 'http://127.0.0.1:8000/api/v1' }
    }
}

$apiBaseUrl = Resolve-ApiBaseUrl -TargetPlatform $Platform
$configDir = Join-Path $ProjectRoot 'config'
$envFile = Join-Path $configDir 'env.local.json'

if (-not (Test-Path $configDir)) {
    New-Item -ItemType Directory -Path $configDir | Out-Null
}

@{
    API_BASE_URL = $apiBaseUrl
    platform     = $Platform
    updated_at   = (Get-Date).ToString('o')
} | ConvertTo-Json | Set-Content -Path $envFile -Encoding UTF8

Write-Host "Created: $envFile"
Write-Host "API_BASE_URL = $apiBaseUrl"
Write-Host ""
Write-Host "Platform hints:"
Write-Host "  windows -> localhost (127.0.0.1)"
Write-Host "  android -> emulator (10.0.2.2)"
Write-Host "  device  -> LAN IP for physical phone"
Write-Host ""

$flutterCandidates = @(
    "$env:LOCALAPPDATA\flutter\bin\flutter.bat",
    'C:\flutter\bin\flutter.bat',
    "$env:USERPROFILE\flutter\bin\flutter.bat",
    "$env:USERPROFILE\fvm\default\bin\flutter.bat"
)
$flutter = $flutterCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1

if (-not $flutter) {
    Write-Host "Flutter SDK not found." -ForegroundColor Yellow
    Write-Host "Install Flutter (Dart 3.11+) then re-run this script."
    Write-Host "https://docs.flutter.dev/get-started/install/windows"
    exit 0
}

Write-Host "Using Flutter: $flutter"
& $flutter doctor
Write-Host ""
& $flutter pub get
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host ""
Write-Host "Running build_runner..."
& $flutter pub run build_runner build --delete-conflicting-outputs
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host ""
Write-Host "Done. Start app with: .\scripts\run_dev.ps1"
