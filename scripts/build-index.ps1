#Requires -Version 5.1
<#
.SYNOPSIS
    扫描 notes/*.md，把「日期 + 标题」表格写回 README.md 的 INDEX 标记之间。

.DESCRIPTION
    一般不需要手动运行，publish.ps1 会自动调用它。
#>
$ErrorActionPreference = 'Stop'

$repoRoot   = Split-Path -Parent $PSScriptRoot
$notesDir   = Join-Path $repoRoot 'notes'
$readmePath = Join-Path $repoRoot 'README.md'
$startMark  = '<!-- INDEX:START -->'
$endMark    = '<!-- INDEX:END -->'

if (-not (Test-Path $notesDir)) { Write-Host "还没有 notes 目录"; return }
if (-not (Test-Path $readmePath)) { throw "找不到 README.md：$readmePath" }

$entries = New-Object System.Collections.Generic.List[object]

foreach ($file in @(Get-ChildItem -Path $notesDir -Filter *.md -File)) {
    $text  = [System.IO.File]::ReadAllText($file.FullName, [System.Text.Encoding]::UTF8)
    $title = ''
    $date  = ''

    if ($text -match '(?m)^date:\s*(\d{4}-\d{2}-\d{2})') { $date = $matches[1] }
    if ($text -match '(?m)^#\s+(.+?)\s*$')                { $title = $matches[1].Trim() }
    if (-not $date  -and $file.BaseName -match '^(\d{4}-\d{2}-\d{2})') { $date = $matches[1] }
    if (-not $title) { $title = $file.BaseName }

    $entries.Add([pscustomobject]@{
        Date  = $date
        Title = $title
        Name  = $file.Name
    })
}

$sorted = @($entries | Sort-Object -Property Date, Name -Descending)

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add('| 日期 | 标题 |')
$lines.Add('| --- | --- |')

if ($sorted.Count -eq 0) {
    $lines.Add('| — | 还没有笔记，运行 `.\scripts\new-note.ps1` 开个头 |')
}
else {
    foreach ($e in $sorted) {
        $link  = 'notes/' + ($e.Name -replace ' ', '%20')
        $label = $e.Title -replace '\|', '\|'
        $lines.Add("| $($e.Date) | [$label]($link) |")
    }
}

$block  = ($lines -join "`n")
$readme = [System.IO.File]::ReadAllText($readmePath, [System.Text.Encoding]::UTF8)

if (-not ($readme.Contains($startMark) -and $readme.Contains($endMark))) {
    throw "README.md 里缺少 $startMark / $endMark 标记，无法写入目录。"
}

$pattern     = [regex]::Escape($startMark) + '(?s).*?' + [regex]::Escape($endMark)
$replacement = $startMark + "`n" + $block + "`n" + $endMark
$readme = [regex]::Replace($readme, $pattern, { param($m) $replacement })

[System.IO.File]::WriteAllText($readmePath, $readme, (New-Object System.Text.UTF8Encoding($false)))
Write-Host "目录已刷新：$($sorted.Count) 篇笔记" -ForegroundColor Green
