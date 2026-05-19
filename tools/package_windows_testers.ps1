$ErrorActionPreference = 'Stop'

$repo = Split-Path -Parent $PSScriptRoot
$puro = 'C:\Users\Satya\AppData\Local\Microsoft\WinGet\Packages\pingbird.Puro_Microsoft.Winget.Source_8wekyb3d8bbwe\puro.exe'
$packageRoot = Join-Path $repo 'build\tester_package\Zoro-Windows-Tester'
$zipPath = Join-Path $repo 'build\tester_package\Zoro-Windows-Tester.zip'

$env:GIT_CONFIG_GLOBAL = Join-Path $repo '.codex-gitconfig'
$env:FLUTTER_SUPPRESS_ANALYTICS = 'true'
$env:DART_SUPPRESS_ANALYTICS = 'true'
$env:APPDATA = Join-Path $repo '.dart_tool\appdata'
New-Item -ItemType Directory -Force -Path $env:APPDATA | Out-Null

Set-Location $repo

Write-Host 'Building Windows app...'
& $puro flutter build windows --release
if ($LASTEXITCODE -ne 0) {
  exit $LASTEXITCODE
}

Write-Host 'Compiling provider-neutral AI proxy...'
New-Item -ItemType Directory -Force -Path (Join-Path $repo 'build\tools') | Out-Null
& $puro dart compile exe tools\ai_proxy_dart\zoro_ai_proxy.dart -o build\tools\zoro_ai_proxy.exe
if ($LASTEXITCODE -ne 0) {
  exit $LASTEXITCODE
}

Write-Host 'Assembling tester package...'
Remove-Item -Recurse -Force $packageRoot -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force -Path $packageRoot | Out-Null

$appSource = Join-Path $repo 'build\windows\x64\runner\Release'
$appTarget = Join-Path $packageRoot 'Zoro'
Copy-Item -Recurse -Force $appSource $appTarget

Copy-Item -Force (Join-Path $repo 'build\tools\zoro_ai_proxy.exe') (Join-Path $packageRoot 'zoro_ai_proxy.exe')
Copy-Item -Force (Join-Path $repo '.env.example') (Join-Path $packageRoot '.env.example')
Copy-Item -Force (Join-Path $repo 'tools\tester_package\run_ai_proxy.bat') (Join-Path $packageRoot 'run_ai_proxy.bat')
Copy-Item -Force (Join-Path $repo 'tools\tester_package\zoro.bat') (Join-Path $packageRoot 'zoro.bat')
Copy-Item -Force (Join-Path $repo 'tools\tester_package\README_TESTERS.md') (Join-Path $packageRoot 'README_TESTERS.md')

Remove-Item -Force $zipPath -ErrorAction SilentlyContinue
Compress-Archive -Path (Join-Path $packageRoot '*') -DestinationPath $zipPath

Write-Host ''
Write-Host "Tester package folder: $packageRoot"
Write-Host "Tester package zip:    $zipPath"
