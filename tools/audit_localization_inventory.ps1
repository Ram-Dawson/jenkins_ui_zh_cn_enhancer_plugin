param(
    [string]$ReferenceRoot = "..\\..\\reference",
    [string]$OutputDirectory = ".\\target\\audit"
)

$pluginRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$pomPath = Join-Path $pluginRoot "pom.xml"
$pomContent = Get-Content -Raw $pomPath
$resourceDirectories = [regex]::Matches($pomContent, '<directory>([^<]+/src/main/resources)</directory>') |
    ForEach-Object { $_.Groups[1].Value.Replace('/', [System.IO.Path]::DirectorySeparatorChar) } |
    Sort-Object -Unique

$resolvedReferenceRoot = (Resolve-Path $ReferenceRoot).Path
$referenceResourceOverrides = @{
    'configuration-as-code-plugin' = 'configuration-as-code-plugin/plugin/src/main/resources'
    'ssh-slaves-plugin' = 'ssh-agents-plugin/src/main/resources'
}
$summary = @()
foreach ($resourceDirectory in $resourceDirectories) {
    $localizationResources = Join-Path $pluginRoot $resourceDirectory
    $reportName = ($resourceDirectory -replace '[\\/]', '__' -replace '__src__main__resources$', '')
    $reportPath = Join-Path $OutputDirectory "$reportName.json"

    if ($resourceDirectory -eq (Join-Path 'core' 'src/main/resources')) {
        $referenceResources = Join-Path $resolvedReferenceRoot 'jenkins/core/src/main/resources'
        $component = 'core'
    } elseif ($resourceDirectory -match '^plugins[\\/]([^\\/]+)[\\/](.+)$') {
        $component = $Matches[1]
        if ($referenceResourceOverrides.ContainsKey($component)) {
            $referenceResources = Join-Path $resolvedReferenceRoot $referenceResourceOverrides[$component]
        } else {
            $referenceResources = Join-Path (Join-Path $resolvedReferenceRoot $component) $Matches[2]
        }
    } else {
        $summary += [pscustomobject]@{
            component = $resourceDirectory
            resourceDirectory = $resourceDirectory
            status = "unsupported_resource_directory"
            missingResources = $null
            missingPropertyKeys = $null
            missingGroovyMessageKeys = $null
            directTextCandidates = $null
            report = $null
        }
        continue
    }
    if (-not (Test-Path $referenceResources)) {
        $summary += [pscustomobject]@{
            component = $component
            resourceDirectory = $resourceDirectory
            status = "reference_resources_missing"
            missingResources = $null
            missingPropertyKeys = $null
            missingGroovyMessageKeys = $null
            directTextCandidates = $null
            report = $null
        }
        continue
    }
    if (-not (Test-Path $localizationResources)) {
        $summary += [pscustomobject]@{
            component = $component
            resourceDirectory = $resourceDirectory
            status = "localization_directory_missing"
            missingResources = $null
            missingPropertyKeys = $null
            missingGroovyMessageKeys = $null
            directTextCandidates = $null
            report = $null
        }
        continue
    }

    & (Join-Path $PSScriptRoot "audit_localization_resources.ps1") `
        -ReferenceResources $referenceResources `
        -LocalizationResources $localizationResources `
        -OutputPath $reportPath | Out-Null
    $report = Get-Content -Raw $reportPath | ConvertFrom-Json
    $summary += [pscustomobject]@{
        component = $component
        resourceDirectory = $resourceDirectory
        status = "audited"
        missingResources = @($report.missingResources).Count
        missingPropertyKeys = @($report.missingPropertyKeys).Count
        missingGroovyMessageKeys = @($report.missingGroovyMessageKeys).Count
        directTextCandidates = @($report.directTextCandidates).Count
        report = $reportPath
    }
}

$summaryPath = Join-Path $OutputDirectory "inventory-summary.json"
New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null
$summary | ConvertTo-Json -Depth 3 | Set-Content -Encoding utf8 $summaryPath
$summary | Sort-Object status, plugin | Format-Table -AutoSize
Write-Output "Summary: $summaryPath"
