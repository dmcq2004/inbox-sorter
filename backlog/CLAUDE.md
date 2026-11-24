# Backlog clean-up (phase 5, started 2026-11-23)

One-off job: apply the proven rules in `config/` to the old inbox threads.

How it runs: the Apps Script `apps-script/SortBacklog.gs`, in Dom's Apps Script project "Sort Backlog"
(script.google.com, Gmail API service switched on), driven by Claude in Chrome. It changes Gmail far faster than
the Gmail connector (up to 1,000 messages per call). Functions: `dryRun`, `runLive`, `archiveOldTriaged`, `undo`.
- `RULES` in the script is generated from `config/sender-rules.yaml` by `apps-script/build_rules.py`. Rerun it and
  paste the script again after any rule change.
- Every change goes to the "Undo log" tab of the Drive spreadsheet "Backlog sort"; the summary goes in `logs/runs/`.
- Only labels, archives and marks read. Never trashes, deletes or sends. Skips the last 2 days and school mail.

Decisions (Dom, 2026-11-23):
- Old threads already labelled FYI/Bulk are archived.
- For the backlog only, Action/NeedsDom whose newest message is over 6 months old are labelled and archived (labels kept).
- Archived threads are marked read, as in the daily sort.

Done 2026-11-23: ~12,700 threads labelled or archived; inbox ~19,500 → ~8,090. See `logs/runs/2026-11-23.md`.
Quotas: Apps Script's GmailApp has a daily limit (hit on 2026-11-23 after ~13k changes plus dry runs); the Gmail API
service has a per-minute limit, so `tallySenders` pauses between pages.

Done 2026-11-24: `tallySenders` (5,721 unruled threads, 1,027 domains), 41 new rules agreed with Dom, then `runLive`
(2,788 threads) and the new `sweepLive` (Dom's decisions: school threads over 1 month old filed under their School label and
archived; unruled threads with nothing newer than 1 year archived as FYI): 54 + 2,588 threads. Inbox about 609 threads after.
Pasting: copy `SortBacklog.gs` to the clipboard (PowerShell `Get-Content -Raw ... | Set-Clipboard`), then Ctrl+A, Ctrl+V, Ctrl+S in the editor.

Next (optional): the ~449 unsorted threads left are from the last year; tally them again if Dom wants another round.
