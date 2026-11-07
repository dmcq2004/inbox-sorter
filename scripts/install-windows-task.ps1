# Registers the "Inbox Sorter" task in Windows Task Scheduler (current user, no admin needed).
# At 07:00 and 17:30 daily it runs, in order:
#   1. scripts\run-calendar-sync.ps1 -Mode live   (school calendar sync)
#   2. scripts\run-sort-inbox.ps1 -Mode live      (general inbox sort, last 2 days of unsorted mail)
# Task Scheduler runs a task's actions one after the other, so the two never overlap (they also share a lock file).
# If the laptop was asleep or off at that time, it runs as soon as possible afterwards. Re-running this script replaces the task.
# It also removes the older single-job "School Calendar Sync" task, which this replaces.
# Remove with:  Unregister-ScheduledTask -TaskName 'Inbox Sorter' -Confirm:$false
$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $PSScriptRoot
$TaskName = 'Inbox Sorter'

function New-RunnerAction($Script) {
    $Path = Join-Path $Root "scripts\$Script"
    New-ScheduledTaskAction -Execute 'powershell.exe' `
        -Argument "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$Path`" -Mode live" `
        -WorkingDirectory $Root
}
$Actions = @(
    New-RunnerAction 'run-calendar-sync.ps1'
    New-RunnerAction 'run-sort-inbox.ps1'
)
$Triggers = @(
    New-ScheduledTaskTrigger -Daily -At '07:00'
    New-ScheduledTaskTrigger -Daily -At '17:30'
)
# 90 minutes covers both jobs (each runner has its own 30-minute timeout).
$Settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries `
    -RunOnlyIfNetworkAvailable -ExecutionTimeLimit (New-TimeSpan -Minutes 90) -MultipleInstances IgnoreNew
# Runs as you, only while you're logged on: Claude Code's sign-in lives in your user profile, and no password is stored.
$Principal = New-ScheduledTaskPrincipal -UserId "$env:USERDOMAIN\$env:USERNAME" -LogonType Interactive -RunLevel Limited

Register-ScheduledTask -TaskName $TaskName `
    -Description 'School calendar sync, then inbox sort (Claude Code). See school/CALENDAR-SYNC.md and CLAUDE.md.' `
    -Action $Actions -Trigger $Triggers -Settings $Settings -Principal $Principal -Force | Out-Null

if (Get-ScheduledTask -TaskName 'School Calendar Sync' -ErrorAction SilentlyContinue) {
    Unregister-ScheduledTask -TaskName 'School Calendar Sync' -Confirm:$false
    Write-Output "Removed the old 'School Calendar Sync' task."
}
Get-ScheduledTask -TaskName $TaskName | Get-ScheduledTaskInfo | Select-Object TaskName, NextRunTime
