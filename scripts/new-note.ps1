#Requires -Version 5.1
<#
.SYNOPSIS
    在 notes/ 下创建今天的笔记；已存在则直接打开，不覆盖已有内容。

.DESCRIPTION
    文件名格式：notes/yyyy-MM-dd-标题.md；不传 -Title 时就是 notes/yyyy-MM-dd.md。

.EXAMPLE
    .\new-note.ps1

.EXAMPLE
    .\new-note.ps1 -Title "Transformer 的注意力机制"

.EXAMPLE
    .\new-note.ps1 -Date 2026-11-16 -Title "补记 Softmax"
#>
[CmdletBinding()]
param(
    [string]$Title = '',
    [string]$Date = (Get-Date -Format 'yyyy-MM-dd'),
    [switch]$NoOpen
)

$ErrorActionPreference = 'Stop'

$repoRoot     = Split-Path -Parent $PSScriptRoot
$notesDir     = Join-Path $repoRoot 'notes'
$templatePath = Join-Path $repoRoot 'templates\daily-template.md'

if (-not (Test-Path $notesDir)) {
    New-Item -ItemType Directory -Path $notesDir -Force | Out-Null
}

function Get-Slug {
    param([string]$Text)
    if ([string]::IsNullOrWhiteSpace($Text)) { return '' }
    $s = $Text.Trim().ToLowerInvariant()
    $s = $s -replace '\s+', '-'
    $s = $s -replace '[^\w\u4e00-\u9fa5.-]', ''
    $s = $s -replace '-{2,}', '-'
    return $s.Trim('-', '.')
}

$slug     = Get-Slug $Title
$fileName = if ($slug) { "$Date-$slug.md" } else { "$Date.md" }
$notePath = Join-Path $notesDir $fileName

if (Test-Path $notePath) {
    Write-Host "已存在，直接打开：$notePath" -ForegroundColor Yellow
}
else {
    if (-not (Test-Path $templatePath)) { throw "找不到模板：$templatePath" }
    $text = [System.IO.File]::ReadAllText($templatePath, [System.Text.Encoding]::UTF8)
    $displayTitle = if ($Title) { $Title.Trim() } else { "$Date 学习笔记" }
    $text = $text.Replace('{{DATE}}', $Date).Replace('{{TITLE}}', $displayTitle)
    [System.IO.File]::WriteAllText($notePath, $text, (New-Object System.Text.UTF8Encoding($false)))
    Write-Host "已创建：$notePath" -ForegroundColor Green
}

if (-not $NoOpen) {
    if (Get-Command code -ErrorAction SilentlyContinue) { & code $notePath }
    else { Start-Process $notePath }
}

Write-Host "写完后运行：.\scripts\publish.ps1" -ForegroundColor DarkGray
