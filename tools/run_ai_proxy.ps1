$ErrorActionPreference = 'Stop'

$repo = 'C:\Satya\codex-project\grok-zoro'
$puro = 'C:\Users\Satya\AppData\Local\Microsoft\WinGet\Packages\pingbird.Puro_Microsoft.Winget.Source_8wekyb3d8bbwe\puro.exe'
$proxyExe = Join-Path $repo 'build\tools\zoro_ai_proxy.exe'

$env:GIT_CONFIG_GLOBAL = Join-Path $repo '.codex-gitconfig'
$env:FLUTTER_SUPPRESS_ANALYTICS = 'true'
$env:DART_SUPPRESS_ANALYTICS = 'true'
$env:APPDATA = Join-Path $repo '.dart_tool\appdata'
New-Item -ItemType Directory -Force -Path $env:APPDATA | Out-Null

Set-Location $repo

if (-not (Test-Path $proxyExe)) {
  New-Item -ItemType Directory -Force -Path (Split-Path -Parent $proxyExe) | Out-Null
  & $puro dart compile exe tools\ai_proxy_dart\zoro_ai_proxy.dart -o $proxyExe
  if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
  }
}

& $proxyExe
