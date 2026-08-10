param(
    [ValidateSet('apk', 'appbundle')]
    [string]$Target = 'appbundle',
    [string]$BuildName,
    [int]$BuildNumber
)

$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$envFile = Join-Path $projectRoot '.env'
$flutter = if ($env:YEGRAMSSI_FLUTTER_BIN) {
    $env:YEGRAMSSI_FLUTTER_BIN
} else {
    'C:\dev\flutter\bin\flutter.bat'
}

if (-not (Test-Path $envFile)) {
    throw "Missing local build configuration: $envFile"
}
if (-not (Test-Path $flutter)) {
    throw "Flutter SDK not found: $flutter"
}

if (-not $env:JAVA_HOME -or -not (Test-Path (Join-Path $env:JAVA_HOME 'bin\java.exe'))) {
    $bundledJdk = Get-ChildItem 'C:\Program Files\Eclipse Adoptium\jdk-*' -Directory -ErrorAction SilentlyContinue |
        Sort-Object Name -Descending |
        Select-Object -First 1
    if (-not $bundledJdk) {
        throw 'JAVA_HOME is invalid and no supported JDK was found.'
    }
    $env:JAVA_HOME = $bundledJdk.FullName
}

$localValues = @{}
Get-Content $envFile | ForEach-Object {
    $line = $_.Trim()
    if (-not $line -or $line.StartsWith('#')) { return }
    $separator = $line.IndexOf('=')
    if ($separator -le 0) { return }
    $name = $line.Substring(0, $separator).Trim()
    $value = $line.Substring($separator + 1).Trim().Trim('"').Trim("'")
    $localValues[$name] = $value
}

function Get-RequiredLocalValue([string]$Name, [string[]]$Aliases = @()) {
    foreach ($candidate in @($Name) + $Aliases) {
        if ($localValues.ContainsKey($candidate) -and $localValues[$candidate]) {
            return $localValues[$candidate]
        }
    }
    throw "Missing required local configuration: $Name"
}

$publicConfigNames = @(
    'SUPABASE_URL',
    'SUPABASE_ANON_KEY'
)

$buildArguments = @(
    'build',
    $Target,
    '--release'
)
foreach ($name in $publicConfigNames) {
    $buildArguments += "--dart-define=$name=$(Get-RequiredLocalValue $name)"
}
if ($BuildName) {
    $buildArguments += "--build-name=$BuildName"
}
if ($BuildNumber -gt 0) {
    $buildArguments += "--build-number=$BuildNumber"
}

Push-Location $projectRoot
try {
    & $flutter @buildArguments
    if ($LASTEXITCODE -ne 0) {
        throw "Flutter $Target build failed with exit code $LASTEXITCODE"
    }
} finally {
    Pop-Location
}
