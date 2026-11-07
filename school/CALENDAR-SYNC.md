# School calendar sync (hands-off)

Keeps Google Calendar in step with Trinity and Young Explorers Club mail, newsletters and attachments, with no
input from Dom. It replaces the old claude.ai `school-comms-triage` scheduled task (Dom switches that off once this has run live).

## How it works
```
Task Scheduler (laptop) / cron (Pi)
  └─ scripts/run-calendar-sync.{ps1,sh}       lock, timeout, log
       └─ claude -p "/school-calendar-sync live"   headless Claude Code, same account and connectors
            ├─ Gmail (read only): new school threads since the last run
            ├─ school/tools/read_sway.py: newsletters, no browser
            ├─ Drive (read only): attachments saved by the Apps Script
            └─ Calendar: create/update school events only, never delete, max 12 writes per run
```
- **Instructions:** `.claude/commands/school-calendar-sync.md` (rules, steps, event conventions).
- **Permissions:** `.claude/settings.json` (read tools allowed; send, trash and delete tools denied). The runner adds calendar
  create/update and writes to the job's own files for the job only.
- **Schedule:** 07:00 and 17:30 daily.
- **Each run produces:**
  - `logs/calendar-sync/<time>.md`: the report (changes made, **Needs Dom**, skipped)
  - `logs/runs/<date>.md`: the undo log for live changes
  - `logs/scheduler/<time>-<mode>.log`: raw output
  - `school/state/calendar-sync.json`: what has already been processed

All of these are machine-local (git-ignored).

## Laptop (Windows), current host
1. One-off: `powershell -ExecutionPolicy Bypass -File scripts\install-windows-task.ps1`
2. Test any time: `powershell -ExecutionPolicy Bypass -File scripts\run-calendar-sync.ps1 -Mode dry-run -Days 14`
3. Runs only while Dom is logged in. If the laptop was asleep at 07:00 or 17:30, the task runs when it wakes.
4. Remove: `Unregister-ScheduledTask -TaskName 'School Calendar Sync' -Confirm:$false`

## Moving to the Raspberry Pi
Needs a **64-bit** Raspberry Pi OS (Claude Code supports Linux arm64; it doesn't support 32-bit).
1. Push this repo to GitHub (private). On the Pi: `git clone <repo> ~/Emails`
2. Install Claude Code: `curl -fsSL https://claude.ai/install.sh | bash`. Python 3 is already on Raspberry Pi OS (the script needs only the standard library).
3. Sign in once, interactively: run `claude` in `~/Emails` and log in with the **same claude.ai account** (dmcq2004@gmail.com),
   so the Gmail, Calendar and Drive connectors come with it. Check with `claude mcp list` (all three should show "Connected").
4. Copy the state from the laptop so it doesn't reprocess: `school/state/calendar-sync.json` (optional; without it the first run looks back 14 days).
5. `chmod +x scripts/run-calendar-sync.sh`, then test: `scripts/run-calendar-sync.sh dry-run 14`
6. `crontab -e`, then add (with `PULL=1` the Pi picks up rule changes pushed from the laptop):
   ```
   0 7 * * *   PULL=1 /home/pi/Emails/scripts/run-calendar-sync.sh live
   30 17 * * * PULL=1 /home/pi/Emails/scripts/run-calendar-sync.sh live
   ```
7. **Then remove the laptop task**, so the two don't both run (the dedupe tags would prevent duplicates, but it wastes runs).
8. Check the Pi's timezone is Europe/London: `timedatectl`.

## Checking on it
- Latest report: newest file in `logs/calendar-sync/`. Look at **Needs Dom** first.
- A failed run ends with `SYNC FAILED: …` in `logs/scheduler/`, and the scheduler records a non-zero exit code.
- To undo a change: find it in `logs/runs/<date>.md` and delete or revert that event id.
