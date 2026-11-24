# School calendar sync (hands-off)

Keeps Google Calendar in step with Trinity and Young Explorers Club mail, newsletters and attachments, with no
input from Dom. It replaces the old claude.ai `school-comms-triage` scheduled task (Dom switched it off on 2026-11-07).

## How it works
```
cron (Pi) / Task Scheduler (laptop, disabled)
  └─ scripts/run-calendar-sync.{ps1,sh}       lock, timeout, log
       └─ claude -p "/school-calendar-sync live"   headless Claude Code, same account and connectors
            ├─ Gmail: reads new school threads since the last run, and files them (labels only; Dom, 2026-11-19)
            ├─ school/tools/read_sway.py: newsletters, no browser
            ├─ Drive (read only): attachments saved by the Apps Script
            └─ Calendar: create/update school events only, never delete, max 12 writes per run
```
- **Instructions:** `.claude/commands/school-calendar-sync.md` (rules, steps, event conventions).
- **Permissions:** `.claude/settings.json` (read tools allowed; send, trash and delete tools denied). The runner adds calendar
  create/update, adding/removing labels on threads, and writes to the job's own files for the job only.
- **Schedule:** 07:00 and 17:30 daily, in the Pi's crontab (the laptop's "Inbox Sorter" task until 2026-11-23). The general inbox sort (`scripts/run-sort-inbox.*`,
  `/sort-inbox live`) runs straight after the sync in the same task; see the root `CLAUDE.md`.
- **Each run produces:**
  - `logs/calendar-sync/<time>.md`: the report (changes made, **Needs Dom**, skipped)
  - `logs/runs/<date>.md`: the undo log for live changes
  - `logs/scheduler/<time>-<mode>.log`: raw output
  - `school/state/calendar-sync.json`: what has already been processed

All of these are machine-local (git-ignored).

## Raspberry Pi, current host (since 2026-11-23)
- **Machine:** Raspberry Pi 4 (4 GB), 64-bit Raspberry Pi OS (Bookworm), `dmcquade@raspberrypi.local` (192.168.1.31), timezone Europe/London.
  The laptop's SSH key (`~/.ssh/id_ed25519`) is in the Pi's `authorized_keys`, so Claude can log in from the laptop to check or fix it.
- **Repo:** `~/Emails`, cloned with a deploy key that can write since 2026-11-24 (`~/.ssh/inbox_sorter_deploy`, GitHub title "raspberrypi inbox-sorter deploy") through the
  SSH alias `github-inbox-sorter` in `~/.ssh/config`. `core.fileMode` is off there, so the scripts' executable bit never blocks `git pull`.
- **Claude Code:** `~/.local/bin/claude`, signed in to the claude.ai account (Pro), with Gmail, Calendar and Drive connected. The folder trust
  dialog for `~/Emails` was accepted, which is needed or the project's `.claude/settings.json` permissions are ignored.
- **Schedule (`crontab -l`):** the two lines below, next to Dom's own Binance (09:00) and Art (Fri 08:00) jobs. Backup of the old crontab:
  `~/crontab.backup-2026-11-23` (and `~/crontab.bak-2026-11-24`, from before the morning brief was added at 07:00 on 2026-11-24). With `PULL=1` the Pi picks up rule changes pushed from the laptop before each run.
  ```
  0 7 * * *   PULL=1 /home/dmcquade/Emails/scripts/run-calendar-sync.sh live >>/home/dmcquade/Emails/logs/scheduler/cron.log 2>&1; /home/dmcquade/Emails/scripts/run-sort-inbox.sh live >>/home/dmcquade/Emails/logs/scheduler/cron.log 2>&1; /home/dmcquade/Emails/scripts/run-morning-brief.sh live >>/home/dmcquade/Emails/logs/scheduler/cron.log 2>&1
  30 17 * * * (same, at 17:30)
  ```
- **Logs and state** are on the Pi (git-ignored), e.g. `ssh dmcquade@raspberrypi.local 'ls -t ~/Emails/logs/sort-inbox | head'`.
  The laptop's own copies stop at 20 Nov 2026.
- **Sign-in:** the Pi's claude.ai login had expired after a month unused (Oct to Nov 2026), which also hid the connectors. Twice-daily runs keep it
  fresh. If runs fail with "OAuth session expired" or "Failed to authenticate", Dom runs `claude` in `~/Emails` at the Pi and types `/login`.
- **Test any time:** `scripts/run-calendar-sync.sh dry-run 14` and `scripts/run-sort-inbox.sh dry-run` (both passed on 2026-11-23).
- **Update Claude Code:** `claude update` (2.1.330 on 2026-11-23).

## Laptop (Windows), fallback
The "Inbox Sorter" task was **disabled** on 2026-11-23 when the Pi took over (not deleted). To use the laptop again, copy the Pi's
`state/sort-inbox.json` and `school/state/calendar-sync.json` back first, comment out the Pi's cron lines, then
`Enable-ScheduledTask -TaskName 'Inbox Sorter'`.
1. Install: `powershell -ExecutionPolicy Bypass -File scripts\install-windows-task.ps1` (registers the "Inbox Sorter" task: sync, then sort)
2. Test: `powershell -ExecutionPolicy Bypass -File scripts
un-calendar-sync.ps1 -Mode dry-run -Days 14`
3. Runs only while Dom is logged in and the laptop is awake.
4. Remove: `Unregister-ScheduledTask -TaskName 'Inbox Sorter' -Confirm:$false`

## Checking on it
- Latest report: newest file in `logs/calendar-sync/`. Look at **Needs Dom** first.
- A failed run ends with `SYNC FAILED: …` in `logs/scheduler/`, and the scheduler records a non-zero exit code.
- To undo a change: find it in `logs/runs/<date>.md` and delete or revert that event id.

## Model
Pinned to **claude-opus-5-5** in both runners (`-Model` / `MODEL=`). On 2026-11-07, Sonnet 5.5 was compared with Opus on identical inputs: Sonnet was 3x faster but skimmed thread summaries and repeated an unverified claim from an earlier report, while Opus read everything and applied the rules fully. Reports from that comparison: `logs/calendar-sync/compare-*.md`.
