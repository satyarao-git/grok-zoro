$ErrorActionPreference = 'Stop'

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
Set-Location $repoRoot

$puro = 'C:\Users\Satya\AppData\Local\Microsoft\WinGet\Packages\pingbird.Puro_Microsoft.Winget.Source_8wekyb3d8bbwe\puro.exe'

$env:FLUTTER_SUPPRESS_ANALYTICS = 'true'
$env:DART_SUPPRESS_ANALYTICS = 'true'
$env:APPDATA = Join-Path $repoRoot '.dart_tool\appdata'
New-Item -ItemType Directory -Force -Path $env:APPDATA | Out-Null

if (Test-Path $puro) {
  & $puro flutter build web --release --no-wasm-dry-run --pwa-strategy=none
} else {
  flutter build web --release --no-wasm-dry-run --pwa-strategy=none
}

Write-Host ''
Write-Host 'Firebase Hosting output is ready in: build\web'
Write-Host 'Deploy app and server AI with: firebase.cmd deploy --only functions,hosting'
