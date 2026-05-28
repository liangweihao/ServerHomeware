# Install MSVC ATL headers required by flutter_local_notifications_windows
# Run in PowerShell (Admin recommended if modify fails)

$setup = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio\Installer\setup.exe'
$ip = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio\2022\BuildTools'

if (-not (Test-Path $setup)) {
    Write-Error 'Visual Studio Installer not found. Install Build Tools 2022 first.'
}

Write-Host 'Adding C++ ATL (MSVC 14.44)...'
$p = Start-Process -FilePath $setup -ArgumentList @(
    'modify',
    '--installPath', $ip,
    '--add', 'Microsoft.VisualStudio.Component.VC.14.44.17.14.ATL',
    '--passive',
    '--norestart'
) -PassThru -Wait

Write-Host "Installer exit: $($p.ExitCode)"
$atl = Join-Path $ip 'VC\Tools\MSVC\14.44.35207\atlmfc\include\atlbase.h'
if (Test-Path $atl) {
    Write-Host 'OK: atlbase.h is available.'
} else {
    Write-Host 'ATL not ready yet. Wait for Visual Studio Installer to finish, then re-run this script.'
    Write-Host 'Or open Visual Studio Installer -> Modify -> Individual components ->'
    Write-Host '  C++ v14.44 ATL for v143 build tools (x86 & x64)'
}
