# Runs the general inbox sorter headlessly with Claude Code (Windows).
# Usage:  powershell -NoProfile -ExecutionPolicy Bypass -File scripts\run-sort-inbox.ps1 [-Mode live|dry-run] [-Days N]
# Scheduled by Windows Task Scheduler straight after the school calendar sync (see scripts\install-windows-task.ps1).
# The Pi equivalent is scripts/run-sort-inbox.sh.
#
# Window: from the day before the last successful live run (state/sort-inbox.json), so a gap of any length (laptop off,
# Pi down) is caught up. With no state it looks back 7 days; it never looks back more than 30. -Days N overrides this.
# The state only moves forward after a live run that finished and wasn't capped at 100 threads.
# The run's output is saved as the report in logs/sort-inbox/ (live runs), so a report always exists.
param(
    [ValidateSet('live', 'dry-run')] [string]$Mode = 'live',
    [int]$Days = 0,
    [int]$TimeoutMinutes = 30,
    [string]$Model = 'claude-opus-5-5'
)
$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $PSScriptRoot
Set-Location $Root

$LogDir = Join-Path $Root 'logs\scheduler'
New-Item -ItemType Directory -Force $LogDir | Out-Null
New-Item -ItemType Directory -Force (Join-Path $Root 'logs\sort-inbox') | Out-Null
$RunStart = (Get-Date).ToUniversalTime()
$Stamp = Get-Date -Format 'yyyy-MM-dd_HHmmss'
$Log = Join-Path $LogDir "$Stamp-sort-$Mode.log"
$StateDir = Join-Path $Root 'state'
$StateFile = Join-Path $StateDir 'sort-inbox.json'
New-Item -ItemType Directory -Force $StateDir | Out-Null

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

    # Work out the start date (Gmail's after: is inclusive and works on whole days)
    $Today = (Get-Date).Date
    if ($Days -gt 0) {
        $Since = $Today.AddDays(-$Days)
    } else {
        $Since = $Today.AddDays(-7)
        if (Test-Path $StateFile) {
            try {
                $Last = [datetime]::Parse((Get-Content $StateFile -Raw | ConvertFrom-Json).last_success_utc).ToLocalTime().Date
                $Since = $Last.AddDays(-1)
            } catch { "State file unreadable, using 7 days: $_" | Out-File -Append -Encoding utf8 "$Log.err" }
        }
        if ($Since -lt $Today.AddDays(-30)) { $Since = $Today.AddDays(-30) }
    }
    $ArgsText = "since=$($Since.ToString('yyyy/MM/dd'))"
    if ($Mode -eq 'live') { $ArgsText = "live $ArgsText" }

    # Tools on top of .claude/settings.json, for this job only: add/remove labels on threads, and write its own logs.
    # No create/update/delete label, no send, no trash.
    $Allowed = @(
        'mcp__claude_ai_Gmail__label_thread',
        'mcp__claude_ai_Gmail__unlabel_thread',
        'Edit(logs/**)'
    ) -join ','

    # Scheduled jobs never send, reply or forward (also enforced by .claude/hooks/send_guard.py)
    $NoSend = 'mcp__claude_ai_Gmail__send_message,mcp__claude_ai_Gmail__reply,mcp__claude_ai_Gmail__forward'
    $env:INBOX_SORTER_JOB = 'sort'

    $p = Start-Process -FilePath $Claude -NoNewWindow -PassThru `
        -RedirectStandardOutput $Log -RedirectStandardError "$Log.err" `
        -ArgumentList (@('-p', "`"/sort-inbox $ArgsText`"", '--allowedTools', "`"$Allowed`"", '--disallowedTools', "`"$NoSend`"", '--max-turns', '200') + $(if ($Model) { @('--model', $Model) } else { @() }))
    $TimedOut = -not $p.WaitForExit($TimeoutMinutes * 60 * 1000)
    if ($TimedOut) {
        $p.Kill()
        "SORT FAILED: timed out after $TimeoutMinutes minutes" | Out-File -Append -Encoding utf8 $Log
    }
    # Claude writes UTF-8 with no BOM; Windows PowerShell would otherwise read it as ANSI and garble it
    $out = Get-Content $Log -Raw -Encoding UTF8 -ErrorAction SilentlyContinue
    if (-not $out) { $out = "SORT FAILED: no output (see $Log.err)" }
    $Ok = (-not $TimedOut) -and ($out -match 'SORT (live|dry-run) OK')

    if ($Mode -eq 'live') {
        # The report is the run's own output, saved here so it can't be skipped
        $Report = Join-Path $Root "logs\sort-inbox\$(Get-Date $RunStart.ToLocalTime() -Format 'yyyy-MM-dd_HHmm').md"
        "# Inbox sort, $(Get-Date $RunStart.ToLocalTime() -Format 'yyyy-MM-dd HH:mm'), live, since $($Since.ToString('yyyy-MM-dd'))`n`n$out" |
            Out-File -Encoding utf8 $Report
        # Move the window forward only when everything in it was sorted
        if ($Ok -and $out -notmatch 'more remaining') {
            @{ last_success_utc = $RunStart.ToString('o') } | ConvertTo-Json | Out-File -Encoding utf8 $StateFile
        }
    }
    if ($TimedOut) { exit 2 } elseif ($Ok) { exit 0 } else { exit 1 }
}
finally {
    Remove-Item $Lock -ErrorAction SilentlyContinue
}
