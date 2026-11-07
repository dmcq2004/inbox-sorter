# Runs the general inbox sorter headlessly with Claude Code (Windows).
# Usage:  powershell -NoProfile -ExecutionPolicy Bypass -File scripts\run-sort-inbox.ps1 [-Mode live|dry-run] [-Days N]
# Scheduled by Windows Task Scheduler straight after the school calendar sync (see scripts\install-windows-task.ps1).
# The Pi equivalent is scripts/run-sort-inbox.sh.
param(
    [ValidateSet('live', 'dry-run')] [string]$Mode = 'live',
    [int]$Days = 2,
    [int]$TimeoutMinutes = 30,
    [string]$Model = 'claude-opus-5-5'
)
$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $PSScriptRoot
Set-Location $Root

$LogDir = Join-Path $Root 'logs\scheduler'
New-Item -ItemType Directory -Force $LogDir | Out-Null
New-Item -ItemType Directory -Force (Join-Path $Root 'logs\sort-inbox') | Out-Null
$Stamp = Get-Date -Format 'yyyy-MM-dd_HHmmss'
$Log = Join-Path $LogDir "$Stamp-sort-$Mode.log"

# Single-run lock, shared with the calendar sync so the two never overlap (stale after 60 min)
$Lock = Join-Path $LogDir '.lock'
if ((Test-Path $Lock) -and ((Get-Item $Lock).LastWriteTime -gt (Get-Date).AddMinutes(-60))) {
    "$(Get-Date -Format s) Skipped sort: another job is running (lock $Lock)" | Out-File -Append -Encoding utf8 (Join-Path $LogDir 'skipped.log')
    exit 0
}
Set-Content -Path $Lock -Value $PID

try {
    $Claude = (Get-Command claude -ErrorAction SilentlyContinue).Source
    if (-not $Claude) { $Claude = Join-Path $env:USERPROFILE '.local\bin\claude.exe' }

    $ArgsText = "days=$Days"
    if ($Mode -eq 'live') { $ArgsText = "live $ArgsText" }

    # Tools on top of .claude/settings.json, for this job only: add/remove labels on threads, and write its own logs.
    # No create/update/delete label, no send, no trash.
    $Allowed = @(
        'mcp__claude_ai_Gmail__label_thread',
        'mcp__claude_ai_Gmail__unlabel_thread',
        'Edit(logs/**)'
    ) -join ','

    $p = Start-Process -FilePath $Claude -NoNewWindow -PassThru `
        -RedirectStandardOutput $Log -RedirectStandardError "$Log.err" `
        -ArgumentList (@('-p', "`"/sort-inbox $ArgsText`"", '--allowedTools', "`"$Allowed`"", '--max-turns', '200') + $(if ($Model) { @('--model', $Model) } else { @() }))
    if (-not $p.WaitForExit($TimeoutMinutes * 60 * 1000)) {
        $p.Kill()
        "SORT FAILED: timed out after $TimeoutMinutes minutes" | Out-File -Append -Encoding utf8 $Log
        exit 2
    }
    $out = Get-Content $Log -Raw -ErrorAction SilentlyContinue
    if ($out -match 'SORT (live|dry-run) OK') { exit 0 } else { exit 1 }
}
finally {
    Remove-Item $Lock -ErrorAction SilentlyContinue
}
