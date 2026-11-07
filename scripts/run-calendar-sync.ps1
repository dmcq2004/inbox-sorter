# Runs the hands-off school calendar sync headlessly with Claude Code (Windows).
# Usage:  powershell -NoProfile -ExecutionPolicy Bypass -File scripts\run-calendar-sync.ps1 [-Mode live|dry-run] [-Days N]
# Scheduled by Windows Task Scheduler (see scripts\install-windows-task.ps1). The Pi equivalent is scripts/run-calendar-sync.sh.
param(
    [ValidateSet('live', 'dry-run')] [string]$Mode = 'live',
    [int]$Days = 0,
    [int]$TimeoutMinutes = 30,
    [string]$Model = 'claude-opus-5-5'   # pinned after the Sonnet/Opus comparison on 2026-11-07
)
$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $PSScriptRoot
Set-Location $Root

$LogDir = Join-Path $Root 'logs\scheduler'
New-Item -ItemType Directory -Force $LogDir | Out-Null
New-Item -ItemType Directory -Force (Join-Path $Root 'logs\calendar-sync') | Out-Null
New-Item -ItemType Directory -Force (Join-Path $Root 'school\state') | Out-Null
$Stamp = Get-Date -Format 'yyyy-MM-dd_HHmmss'
$Log = Join-Path $LogDir "$Stamp-$Mode.log"

# Single-run lock (stale after 60 min)
$Lock = Join-Path $LogDir '.lock'
if ((Test-Path $Lock) -and ((Get-Item $Lock).LastWriteTime -gt (Get-Date).AddMinutes(-60))) {
    "$(Get-Date -Format s) Skipped: another sync is running (lock $Lock)" | Out-File -Append -Encoding utf8 (Join-Path $LogDir 'skipped.log')
    exit 0
}
Set-Content -Path $Lock -Value $PID

try {
    $Claude = (Get-Command claude -ErrorAction SilentlyContinue).Source
    if (-not $Claude) { $Claude = Join-Path $env:USERPROFILE '.local\bin\claude.exe' }

    $ArgsText = $Mode
    if ($Days -gt 0) { $ArgsText += " days=$Days" }

    # Tools on top of .claude/settings.json, for this job only: calendar writes and the job's own files.
    $Allowed = @(
        'mcp__claude_ai_Google_Calendar__create_event',
        'mcp__claude_ai_Google_Calendar__update_event',
        'Edit(school/state/**)',
        'Edit(school/newsletters/**)', 'Edit(school/newsletters.md)',
        'Edit(logs/**)'
    ) -join ','

    $p = Start-Process -FilePath $Claude -NoNewWindow -PassThru `
        -RedirectStandardOutput $Log -RedirectStandardError "$Log.err" `
        -ArgumentList (@('-p', "`"/school-calendar-sync $ArgsText`"", '--allowedTools', "`"$Allowed`"", '--max-turns', '120') + $(if ($Model) { @('--model', $Model) } else { @() }))
    if (-not $p.WaitForExit($TimeoutMinutes * 60 * 1000)) {
        $p.Kill()
        "SYNC FAILED: timed out after $TimeoutMinutes minutes" | Out-File -Append -Encoding utf8 $Log
        exit 2
    }
    $out = Get-Content $Log -Raw -ErrorAction SilentlyContinue
    if ($out -match 'SYNC (live|dry-run) OK') { exit 0 } else { exit 1 }
}
finally {
    Remove-Item $Lock -ErrorAction SilentlyContinue
}
