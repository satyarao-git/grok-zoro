$ErrorActionPreference = 'Stop'

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
Set-Location $repoRoot

& powershell -ExecutionPolicy Bypass -File .\tools\build_firebase_hosting.ps1

Write-Host ''
Write-Host 'Installing Firebase Function dependencies...'
npm.cmd install --prefix .\functions

if (Get-Command firebase.cmd -ErrorAction SilentlyContinue) {
  firebase.cmd deploy --only functions,hosting
} else {
  firebase deploy --only functions,hosting
}
