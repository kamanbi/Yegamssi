param(
    [string]$OutputPath = "assets/data/activity/fishing_ports_20260811.json"
)

$ErrorActionPreference = "Stop"
$baseUrl = "https://fipa.or.kr/fipa/pgm/i-152/nat/front"
$expectedCount = 115

$listEntries = for ($pageIndex = 1; $pageIndex -le 12; $pageIndex++) {
    $listUrl = "$baseUrl/list.do?pageIndex=$pageIndex"
    $html = (Invoke-WebRequest -Uri $listUrl -UseBasicParsing).Content
    $matches = [regex]::Matches(
        $html,
        'data-harbr-sn="(?<id>\d+)">\s*(?<name>[^<]+)</a>'
    )
    foreach ($match in $matches) {
        [pscustomobject]@{
            id = $match.Groups['id'].Value
            listedName = $match.Groups['name'].Value.Trim()
        }
    }
}

if ($listEntries.Count -ne $expectedCount) {
    throw "Expected $expectedCount national fishing ports, got $($listEntries.Count)."
}
if (($listEntries.id | Sort-Object -Unique).Count -ne $expectedCount) {
    throw "FIPA harbor identifiers are not unique."
}

$workerCount = 12
$jobs = for ($workerIndex = 0; $workerIndex -lt $workerCount; $workerIndex++) {
    $chunk = @(
        for ($entryIndex = $workerIndex; $entryIndex -lt $listEntries.Count; $entryIndex += $workerCount) {
            $listEntries[$entryIndex]
        }
    )
    Start-Job -ArgumentList (, $chunk) -ScriptBlock {
        param($entries)
        foreach ($entry in $entries) {
            $detailUrl = "https://fipa.or.kr/fipa/pgm/i-152/nat/front/detail.do?harbr_sn=$($entry.id)"
            $response = Invoke-RestMethod -Uri $detailUrl
            if ($response.result -ne "SUCCESS" -or $null -eq $response.detail) {
                throw "Failed to load FIPA harbor $($entry.id)."
            }
            $detail = $response.detail
            [pscustomobject]@{
                officialHarborId = $entry.id
                officialName = [string]$detail.harbr_name
                address = [string]$detail.adres
                latitude = [double]$detail.next_map_lttd
                longitude = [double]$detail.next_map_lngtd
                managingAuthority = [string]$detail.locgov_name
                designatedAt = [string]$detail.appn_de_val
                sourceUpdatedAt = [DateTimeOffset]::FromUnixTimeMilliseconds(
                    [long]$detail.last_updt_dt
                ).ToLocalTime().ToString("yyyy-MM-dd")
            }
        }
    }
}

$items = @($jobs | Wait-Job | Receive-Job)
$jobs | Remove-Job -Force
if ($items.Count -ne $expectedCount) {
    throw "Expected $expectedCount harbor details, got $($items.Count)."
}

$legalOverrides = @{
    "2542" = @{
        officialName = "당포항"
        aliases = @("삼덕항")
        legalEffectiveDate = "2025-04-14"
        legalSourceUrl = "https://www.mof.go.kr/doc/ko/selectDoc.do?bbsSeq=9&docSeq=61248&menuSeq=375"
    }
}

$legacyAliases = @{
    "2524" = @("대보항")
    "2521" = @("대진항")
    "2519" = @("사동항")
}

$nameCounts = @{}
foreach ($item in $items) {
    $name = if ($legalOverrides.ContainsKey($item.officialHarborId)) {
        $legalOverrides[$item.officialHarborId].officialName
    } else {
        $item.officialName
    }
    $nameCounts[$name] = if ($nameCounts.ContainsKey($name)) {
        $nameCounts[$name] + 1
    } else {
        1
    }
}

$catalogItems = foreach ($item in $items) {
    $override = $legalOverrides[$item.officialHarborId]
    $officialName = if ($null -ne $override) {
        $override.officialName
    } else {
        $item.officialName
    }
    $aliases = @()
    if ($legacyAliases.ContainsKey($item.officialHarborId)) {
        $aliases += $legacyAliases[$item.officialHarborId]
    }
    if ($null -ne $override) {
        $aliases += $override.aliases
    }
    $province = ($item.address -split '\s+')[0]
    $shortProvince = switch -Regex ($province) {
        '^충청남도$' { '충남'; break }
        '^전라남도$' { '전남'; break }
        default { $province }
    }
    $displayName = if ($nameCounts[$officialName] -gt 1) {
        "$officialName($shortProvince)"
    } else {
        $officialName
    }
    if ($item.latitude -lt 32 -or $item.latitude -gt 39.5 -or
        $item.longitude -lt 123 -or $item.longitude -gt 132) {
        throw "Out-of-range coordinate for harbor $($item.officialHarborId)."
    }
    if ([string]::IsNullOrWhiteSpace($officialName) -or
        [string]::IsNullOrWhiteSpace($item.address)) {
        throw "Missing required field for harbor $($item.officialHarborId)."
    }

    [pscustomobject][ordered]@{
        id = "fipa-port:$($item.officialHarborId)"
        officialHarborId = $item.officialHarborId
        officialName = $officialName
        displayName = $displayName
        aliases = @($aliases | Sort-Object -Unique)
        address = $item.address
        latitude = $item.latitude
        longitude = $item.longitude
        managingAuthority = $item.managingAuthority
        designatedAt = $item.designatedAt
        sourceUpdatedAt = $item.sourceUpdatedAt
        legalEffectiveDate = if ($null -ne $override) {
            $override.legalEffectiveDate
        } else {
            $null
        }
        legalSourceUrl = if ($null -ne $override) {
            $override.legalSourceUrl
        } else {
            $null
        }
    }
}

$duplicateDisplayNames = $catalogItems |
    Group-Object displayName |
    Where-Object Count -gt 1
if ($duplicateDisplayNames) {
    throw "Display names are not unique: $($duplicateDisplayNames.Name -join ', ')."
}

$document = [ordered]@{
    schemaVersion = 2
    catalogVersion = "2026-08-11"
    generatedAt = "2026-08-11"
    legalEffectiveDate = "2025-04-14"
    source = "한국어촌어항공단 국가어항 현황·해양수산부 고시"
    sourceUrl = "$baseUrl/list.do"
    items = @($catalogItems | Sort-Object officialHarborId)
}

$resolvedOutput = if ([System.IO.Path]::IsPathRooted($OutputPath)) {
    $OutputPath
} else {
    Join-Path (Get-Location) $OutputPath
}
$outputDirectory = Split-Path -Parent $resolvedOutput
New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null
$document | ConvertTo-Json -Depth 8 -Compress |
    Set-Content -LiteralPath $resolvedOutput -Encoding utf8 -NoNewline

Write-Output "Wrote $($catalogItems.Count) national fishing ports to $resolvedOutput"
