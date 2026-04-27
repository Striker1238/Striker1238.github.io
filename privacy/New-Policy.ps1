<#
.SYNOPSIS
    Generate a privacy policy for a project from templates.

.DESCRIPTION
    Reads project.json from the project folder, fills templates with values,
    assembles SDK snippets and writes ru.md / en.md into the project folder.

.PARAMETER Project
    Project slug (folder name under privacy/). Required.

.EXAMPLE
    .\New-Policy.ps1 -Project cosmic-merger-orbital
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$Project
)

$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectDir = Join-Path $root $Project
$configPath = Join-Path $projectDir 'project.json'
$templatesDir = Join-Path $root 'templates'
$sdkDir = Join-Path $templatesDir 'sdk-snippets'
$kidsDir = Join-Path $templatesDir 'kids-snippets'

if (-not (Test-Path $configPath)) {
    throw "project.json not found at: $configPath"
}

$config = Get-Content $configPath -Raw -Encoding UTF8 | ConvertFrom-Json

function Get-Required($obj, $field) {
    if (-not $obj.PSObject.Properties.Name.Contains($field)) {
        throw "project.json: missing required field '$field'"
    }
    return $obj.$field
}

$appName = Get-Required $config 'appName'
$developer = Get-Required $config 'developer'
$email = Get-Required $config 'email'
$effectiveDate = Get-Required $config 'effectiveDate'
$lastUpdated = if ($config.lastUpdated) { $config.lastUpdated } else { (Get-Date -Format 'yyyy-MM-dd') }
$audience = if ($config.audience) { $config.audience } else { 'general' }
$sdks = @($config.sdks)
$slug = $Project

function Read-Snippet($dir, $name, $lang) {
    $path = Join-Path $dir "$name.$lang.md"
    if (-not (Test-Path $path)) {
        throw "Snippet not found: $path"
    }
    return (Get-Content $path -Raw -Encoding UTF8).TrimEnd()
}

function Build-SdksBlock($lang) {
    if ($sdks.Count -eq 0) {
        return Read-Snippet $sdkDir '_none' $lang
    }
    $parts = foreach ($sdk in $sdks) {
        Read-Snippet $sdkDir $sdk $lang
    }
    return ($parts -join "`n`n")
}

function Build-Policy($lang) {
    $template = Get-Content (Join-Path $templatesDir "policy.$lang.md") -Raw -Encoding UTF8
    $sdkBlock = Build-SdksBlock $lang
    $kidsBlock = Read-Snippet $kidsDir $audience $lang

    $output = $template
    $output = $output.Replace('{{APP_NAME}}', $appName)
    $output = $output.Replace('{{DEVELOPER}}', $developer)
    $output = $output.Replace('{{EMAIL}}', $email)
    $output = $output.Replace('{{EFFECTIVE_DATE}}', $effectiveDate)
    $output = $output.Replace('{{LAST_UPDATED}}', $lastUpdated)
    $output = $output.Replace('{{SLUG}}', $slug)
    $output = $output.Replace('{{SDKS}}', $sdkBlock)
    $output = $output.Replace('{{KIDS_BLOCK}}', $kidsBlock)
    return $output
}

if (-not (Test-Path $projectDir)) {
    New-Item -ItemType Directory -Path $projectDir | Out-Null
}

$ruPath = Join-Path $projectDir 'ru.md'
$enPath = Join-Path $projectDir 'en.md'

(Build-Policy 'ru') | Out-File -FilePath $ruPath -Encoding utf8 -NoNewline
(Build-Policy 'en') | Out-File -FilePath $enPath -Encoding utf8 -NoNewline

Write-Host "Generated:"
Write-Host "  $ruPath"
Write-Host "  $enPath"
Write-Host ""
Write-Host "URLs (after Pages publish):"
Write-Host "  https://striker1238.github.io/privacy/$slug/ru.html"
Write-Host "  https://striker1238.github.io/privacy/$slug/en.html"
