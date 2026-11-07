# Registers the "School Calendar Sync" task in Windows Task Scheduler (current user, no admin needed).
# Runs scripts\run-calendar-sync.ps1 live at 07:00 and 17:30 daily. If the laptop was asleep or off at that time,
# it runs as soon as possible afterwards. Re-running this script replaces the task.
# Remove with:  Unregister-ScheduledTask -TaskName 'School Calendar Sync' -Confirm:$false
$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $PSScriptRoot
$Runner = Join-Path $Root 'scripts\run-calendar-sync.ps1'

$Action = New-ScheduledTaskAction -Execute 'powershell.exe' `
    -Argument "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$Runner`" -Mode live" `
    -WorkingDirectory $Root
$Triggers = @(
    New-ScheduledTaskTrigger -Daily -At '07:00'
    New-ScheduledTaskTrigger -Daily -At '17:30'
)
$Settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries `
    -RunOnlyIfNetworkAvailable -ExecutionTimeLimit (New-TimeSpan -Minutes 45) -MultipleInstances IgnoreNew
# Runs as you, only while you're logged on: Claude Code's sign-in lives in your user profile, and no password is stored.
$Principal = New-ScheduledTaskPrincipal -UserId "$env:USERDOMAIN\$env:USERNAME" -LogonType Interactive -RunLevel Limited

Register-ScheduledTask -TaskName 'School Calendar Sync' -Description 'Hands-off Trinity/YEC school calendar sync (Claude Code). See school/CALENDAR-SYNC.md.' `
    -Action $Action -Trigger $Triggers -Settings $Settings -Principal $Principal -Force | Out-Null
Get-ScheduledTask -TaskName 'School Calendar Sync' | Get-ScheduledTaskInfo | Select-Object TaskName, NextRunTime
