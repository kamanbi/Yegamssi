param(
    [string]$ArtifactPath
)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$forbiddenPatterns = @(
    'postgres(?:ql)?://',
    'SUPABASE_DATABASE_URL\s*=\s*[^$\s]',
    'SERVICE_KEY\s*=\s*\(',
    'AppConfig\.(kmaApiKey|airkoreaApiKey|openWeatherApiKey|airnowApiKey)',
    'BuildConfig\.(KMA_API_KEY|AIRKOREA_API_KEY|OPENWEATHER_API_KEY|AIRNOW_API_KEY)'
)
$sourceTargets = @(
    (Join-Path $projectRoot 'lib'),
    (Join-Path $projectRoot 'android'),
    (Join-Path $projectRoot 'etc'),
    (Join-Path $projectRoot 'pubspec.yaml')
)

$violations = @()
foreach ($pattern in $forbiddenPatterns) {
    $matches = rg --hidden --glob '!.env' --glob '!build/**' --glob '!*.lock' -l --pcre2 $pattern $sourceTargets 2>$null
    if ($LASTEXITCODE -eq 0) {
        $violations += $matches | ForEach-Object { "source:${pattern}:$($_)" }
    }
}

if ($ArtifactPath) {
    if (-not (Test-Path $ArtifactPath)) {
        throw "Artifact not found: $ArtifactPath"
    }
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $archive = [System.IO.Compression.ZipFile]::OpenRead((Resolve-Path $ArtifactPath))
    try {
        $assetEntries = $archive.Entries | Where-Object {
            $_.FullName -match '(^|/)(\.env|.*\.env)$' -or $_.FullName -match 'flutter_assets/.env$'
        }
        foreach ($entry in $assetEntries) {
            $violations += "artifact:forbidden-env-asset:$($entry.FullName)"
        }
    } finally {
        $archive.Dispose()
    }
}

if ($violations.Count -gt 0) {
    $violations | Sort-Object | ForEach-Object { Write-Error $_ }
    throw "Security check failed with $($violations.Count) violation(s)."
}

Write-Host 'Security check passed: no forbidden privileged credential patterns found.'
