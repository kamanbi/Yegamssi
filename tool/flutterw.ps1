param(
  [Parameter(ValueFromRemainingArguments = $true)]
  [string[]]$FlutterArgs
)

$flutterRoot = "C:\flutter"
$dart = Join-Path $flutterRoot "bin\cache\dart-sdk\bin\dart.exe"
$tool = Join-Path $flutterRoot "packages\flutter_tools\bin\flutter_tools.dart"

if (-not (Test-Path $dart)) {
  Write-Error "Dart SDK not found at $dart"
  exit 1
}

if (-not (Test-Path $tool)) {
  Write-Error "Flutter tool entrypoint not found at $tool"
  exit 1
}

& $dart $tool @FlutterArgs
exit $LASTEXITCODE
