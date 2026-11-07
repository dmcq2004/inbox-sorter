---
description: Sort recent unsorted inbox mail into labels (dry run unless "live")
argument-hint: "[live] [days=2]"
---

Run the general inbox sorter as defined in `CLAUDE.md`.

Arguments: $ARGUMENTS
- If they contain `live`, apply changes. Otherwise this is a **dry run**: change nothing in Gmail.
- `days=N` sets the lookback (default 2).

Steps:
1. Read `config/labels.md`, `config/sender-rules.yaml`, `config/priority-rules.md` and `school/senders.md`.
2. Call `list_labels` to map label names to IDs. If a label the rules need doesn't exist, stop and report it. Do not create it.
3. Search with the unsorted query from `CLAUDE.md` (using `newer_than:<N>d`), paging until done.
4. Classify each thread using the classification order in `CLAUDE.md`. For school threads, apply `school/CLAUDE.md` labelling (but no digest; that's `/school`).
5. Print a table: `sender | subject | folder | priority | archive | rule (or "judgement")`. Then give counts per priority.
6. If live: apply labels with `label_thread`, archive with `unlabel_thread` (INBOX), and append rows to `logs/runs/<today>.md`.
7. End with a list of the `judgement` rows Dom might want to turn into sender rules.

## Scheduled (headless) runs
The laptop task / Pi cron runs `claude -p "/sort-inbox live"` via `scripts/run-sort-inbox.{ps1,sh}`, straight after
the school calendar sync, at 07:00 and 17:30. Nobody is watching, so:
- Never ask a question or wait for input. Where no rule decides, use `config/priority-rules.md`; if still unsure, `Triage/NeedsDom` and don't archive.
- Never create, rename or delete a label. If a label the rules need is missing, apply the priority label only, skip the folder, and list it in the report.
- At most **100 threads** per run (newest first). If there are more, sort 100 and say so in the report; the next run picks up the rest.
- Live runs only (dry runs write nothing): write a report to `logs/sort-inbox/<YYYY-MM-DD_HHMM>.md`, even when nothing needed sorting. It contains the step 5 table, counts per priority, threads left in the inbox
  (Action and NeedsDom, one line each), missing labels, errors, and the step 7 judgement list.
- If a Gmail call fails, retry it once; if it fails again, note the thread in the report and carry on.
- The **last line** of output must be exactly `SORT live OK` or `SORT dry-run OK` (if the run finished, even with some
  per-thread errors), or `SORT FAILED: <reason>` if it couldn't run at all. The runner checks for this.
