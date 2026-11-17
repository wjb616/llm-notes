#Requires -Version 5.1
<#
.SYNOPSIS
    刷新 README 目录 → 提交 → 推送到 GitHub。一条命令发一篇。

.DESCRIPTION
    推送失败不会丢东西：提交仍然留在本地，修好网络后重跑一次即可。

.EXAMPLE
    .\publish.ps1

.EXAMPLE
    .\publish.ps1 -Message "notes: 补两篇 attention"
#>
[CmdletBinding()]
param(
    [string]$Message = ''
)

# 原生 git 命令失败时会往 stderr 写内容，ErrorActionPreference=Stop 会把它变成
# 终止异常、盖掉真正的错误信息。所以这里统一用 Continue，逐个检查 $LASTEXITCODE。
$ErrorActionPreference = 'Continue'

$repoRoot = Split-Path -Parent $PSScriptRoot

function Fail {
    param([string]$Text)
    Write-Host ''
    Write-Host "x $Text" -ForegroundColor Red
    exit 1
}

Push-Location $repoRoot
try {
    if (-not (Test-Path (Join-Path $repoRoot '.git'))) {
        Fail "这里还不是 git 仓库：$repoRoot"
    }

    $changes = @(git status --porcelain)
    if ($changes.Count -eq 0) {
        Write-Host '没有需要提交的改动，今天已经同步过了。' -ForegroundColor Yellow
        return
    }

    # 1) 先刷新 README 里的笔记目录
    & (Join-Path $PSScriptRoot 'build-index.ps1')
    if (-not $?) { Fail '刷新 README 目录失败' }

    # 2) 提交
    git add -A
    if ($LASTEXITCODE -ne 0) { Fail 'git add 失败' }

    if (-not $Message) {
        $Message = "notes: $(Get-Date -Format 'yyyy-MM-dd')"
    }
    git commit -m $Message
    if ($LASTEXITCODE -ne 0) { Fail 'git commit 失败（检查 git config user.name / user.email）' }

    # 3) 推送；没有上游分支时第一次要 -u 建立跟踪
    $branch = (git rev-parse --abbrev-ref HEAD).Trim()
    git config --get "branch.$branch.remote" 2>$null | Out-Null
    if ($LASTEXITCODE -eq 0) {
        git push
    }
    else {
        git push -u origin $branch
    }

    if ($LASTEXITCODE -ne 0) {
        Write-Host ''
        Write-Host '已提交到本地，但没有推送到 GitHub。' -ForegroundColor Yellow
        Write-Host '修好网络 / 代理 / 登录后，重新运行 .\publish.cmd 即可，笔记不会丢。' -ForegroundColor Yellow
        exit 1
    }

    Write-Host ''
    Write-Host "OK 已发布：$Message" -ForegroundColor Green
}
finally {
    Pop-Location
}
