$env:GIT_CONFIG_GLOBAL = 'C:\Satya\codex-project\grok-zoro\.codex-gitconfig'
$env:FLUTTER_SUPPRESS_ANALYTICS = 'true'
$env:DART_SUPPRESS_ANALYTICS = 'true'
$env:APPDATA = 'C:\Satya\codex-project\grok-zoro\.dart_tool\appdata'

New-Item -ItemType Directory -Force -Path $env:APPDATA | Out-Null

& 'C:\Users\Satya\.puro\envs\stable\flutter\bin\flutter.bat' build web --no-wasm-dry-run

if ($LASTEXITCODE -ne 0) {
  exit $LASTEXITCODE
}

& 'C:\new-install\node.exe' tools\static_web_server.mjs
