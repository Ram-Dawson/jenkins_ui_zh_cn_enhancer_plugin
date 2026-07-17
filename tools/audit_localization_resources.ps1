param(
    [string]$ReferencePlugin,
    [string]$LocalizationPlugin,
    [string]$ReferenceResources,
    [string]$LocalizationResources,
    [Parameter(Mandatory = $true)]
    [string]$OutputPath
)

if ([string]::IsNullOrWhiteSpace($ReferenceResources)) {
    if ([string]::IsNullOrWhiteSpace($ReferencePlugin)) {
        throw "Specify ReferencePlugin or ReferenceResources."
    }
    $ReferenceResources = Join-Path $ReferencePlugin "src/main/resources"
}
if ([string]::IsNullOrWhiteSpace($LocalizationResources)) {
    if ([string]::IsNullOrWhiteSpace($LocalizationPlugin)) {
        throw "Specify LocalizationPlugin or LocalizationResources."
    }
    $LocalizationResources = Join-Path $LocalizationPlugin "src/main/resources"
}

$referenceResources = $ReferenceResources
$localizationResources = $LocalizationResources
if (-not (Test-Path $referenceResources)) {
    throw "Reference resources not found: $referenceResources"
}
if (-not (Test-Path $localizationResources)) {
    throw "Localization resources not found: $localizationResources"
}

function Get-LocalizedPath([System.IO.FileInfo]$file, [string]$root) {
    $relative = [System.IO.Path]::GetRelativePath($root, $file.FullName)
    $directory = [System.IO.Path]::GetDirectoryName($relative)
    $name = [System.IO.Path]::GetFileNameWithoutExtension($relative)
    $extension = [System.IO.Path]::GetExtension($relative)
    return [System.IO.Path]::Combine($directory, "${name}_zh_CN${extension}")
}

function Get-PropertyKeys([string]$path) {
    $keys = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    $logicalLine = ""
    foreach ($line in Get-Content -LiteralPath $path) {
        if ($logicalLine.Length -gt 0) {
            $logicalLine += $line.TrimStart()
        } else {
            $logicalLine = $line
        }

        # An odd number of trailing backslashes continues a Java properties value.
        $trailingSlashes = ([regex]::Match($logicalLine, '(\\+)$')).Groups[1].Value.Length
        if (($trailingSlashes % 2) -eq 1) {
            $logicalLine = $logicalLine.Substring(0, $logicalLine.Length - 1)
            continue
        }

        if ($logicalLine -notmatch '^\s*[#!]' -and $logicalLine -match '^\s*(?<key>(?:\\.|[^\\:=\s])+)(?:\s*[:=]|\s+)') {
            [void]$keys.Add($Matches['key'])
        }
        $logicalLine = ""
    }
    return $keys
}

function Convert-PropertyKey([string]$key) {
    return [regex]::Replace($key, '\\(.)', '$1')
}

$resourceCandidates = Get-ChildItem -Path $referenceResources -Recurse -File |
    Where-Object {
        $_.FullName -notmatch '[\\/](test|target)[\\/]' -and
        $_.Extension -in '.properties', '.html' -and
        $_.BaseName -notmatch '_[a-z]{2}(_[A-Z]{2})?$'
    }

$missingResources = foreach ($file in $resourceCandidates) {
    $localizedRelative = Get-LocalizedPath $file $referenceResources
    $localizedPath = Join-Path $localizationResources $localizedRelative
    if (-not (Test-Path $localizedPath)) {
        [pscustomobject]@{
            source = [System.IO.Path]::GetRelativePath($referenceResources, $file.FullName)
            expected = $localizedRelative
            kind = $file.Extension.TrimStart('.')
        }
    }
}

$missingPropertyKeys = foreach ($file in $resourceCandidates | Where-Object Extension -eq '.properties') {
    $localizedRelative = Get-LocalizedPath $file $referenceResources
    $localizedPath = Join-Path $localizationResources $localizedRelative
    if (-not (Test-Path $localizedPath)) { continue }

    $localizedKeys = Get-PropertyKeys $localizedPath
    foreach ($key in Get-PropertyKeys $file.FullName) {
        if (-not $localizedKeys.Contains($key)) {
            [pscustomobject]@{
                source = [System.IO.Path]::GetRelativePath($referenceResources, $file.FullName)
                expected = $localizedRelative
                key = $key
            }
        }
    }
}

$missingGroovyMessageKeys = foreach ($file in Get-ChildItem -Path $referenceResources -Recurse -File -Filter '*.groovy') {
    if ($file.FullName -match '[\\/](test|target)[\\/]') { continue }

    $localizedGroovyRelative = Get-LocalizedPath $file $referenceResources
    if (Test-Path (Join-Path $localizationResources $localizedGroovyRelative)) { continue }
    $localizedRelative = $localizedGroovyRelative -replace '_zh_CN\.groovy$', '_zh_CN.properties'
    $localizedPath = Join-Path $localizationResources $localizedRelative
    if (-not (Test-Path $localizedPath)) { continue }

    $localizedKeys = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    foreach ($key in Get-PropertyKeys $localizedPath) {
        [void]$localizedKeys.Add((Convert-PropertyKey $key))
    }

    $lineNumber = 0
    foreach ($line in Get-Content -LiteralPath $file.FullName) {
        $lineNumber++
        foreach ($match in [regex]::Matches($line, '_\(\s*(?:"(?<key>[^"]+)"|''(?<key>[^'']+)'')')) {
            $key = $match.Groups['key'].Value
            if ($key.Contains('$')) { continue }
            if (-not $localizedKeys.Contains($key)) {
                [pscustomobject]@{
                    source = [System.IO.Path]::GetRelativePath($referenceResources, $file.FullName)
                    expected = $localizedRelative
                    key = $key
                    line = $lineNumber
                }
            }
        }
    }
}

$literalPattern = '(?:title|addCaption|description)\s*(?:=|:)\s*["'']([^$"'']*[A-Za-z][^"'']*)["'']|_\(["'']([^"'']*[A-Za-z][^"'']*)["'']\)'
$directTextCandidates = foreach ($file in Get-ChildItem -Path $referenceResources -Recurse -File -Include *.jelly,*.groovy) {
    if ($file.FullName -match '[\\/](test|target)[\\/]') { continue }
    $relativeSource = [System.IO.Path]::GetRelativePath($referenceResources, $file.FullName)
    if (Test-Path (Join-Path $localizationResources $relativeSource)) { continue }
    $lineNumber = 0
    foreach ($line in Get-Content $file.FullName) {
        $lineNumber++
        $match = [regex]::Match($line, $literalPattern)
        if ($match.Success) {
            [pscustomobject]@{
                source = $relativeSource
                line = $lineNumber
                text = if ($match.Groups[1].Success) { $match.Groups[1].Value } else { $match.Groups[2].Value }
            }
        }
    }
}

$report = [ordered]@{
    generatedAt = (Get-Date).ToString('o')
    referenceResources = (Resolve-Path $referenceResources).Path
    localizationResources = (Resolve-Path $localizationResources).Path
    missingResources = @($missingResources)
    missingPropertyKeys = @($missingPropertyKeys)
    missingGroovyMessageKeys = @($missingGroovyMessageKeys)
    directTextCandidates = @($directTextCandidates)
}

$outputDirectory = Split-Path -Parent $OutputPath
New-Item -ItemType Directory -Force -Path $outputDirectory | Out-Null
$report | ConvertTo-Json -Depth 5 | Set-Content -Encoding utf8 $OutputPath
Write-Output "Missing resources: $($report.missingResources.Count)"
Write-Output "Missing property keys: $($report.missingPropertyKeys.Count)"
Write-Output "Missing Groovy message keys: $($report.missingGroovyMessageKeys.Count)"
Write-Output "Direct-text candidates: $($report.directTextCandidates.Count)"
Write-Output "Report: $OutputPath"
