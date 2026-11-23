---
description: Sort recent unsorted inbox mail into labels (dry run unless "live")
argument-hint: "[live] [days=2 | since=YYYY/MM/DD]"
---

Run the general inbox sorter as defined in `CLAUDE.md`.

Arguments: $ARGUMENTS
- If they contain `live`, apply changes. Otherwise this is a **dry run**: change nothing in Gmail.
- `since=YYYY/MM/DD` sets the start of the window (the scheduled runner passes this, worked out from the last successful run).
  Otherwise `days=N` sets the lookback (default 2).

Steps:
1. Read `config/labels.md`, `config/sender-rules.yaml`, `config/priority-rules.md` and `school/senders.md`.
2. Call `list_labels` to map label names to IDs. If a label the rules need doesn't exist, stop and report it. Do not create it.
3. Search with the unsorted query from `CLAUDE.md`, using `after:<since>` in place of `newer_than:2d` when `since` is given,
   or `newer_than:<N>d` otherwise. Page until done.
4. Classify each thread using the classification order in `CLAUDE.md`. For school threads, apply `school/CLAUDE.md` labelling (but no digest; that's `/school`).
   The calendar sync normally files school threads before this runs, so any that are still unsorted are a fallback. Read them with
   `get_thread` and check their attachments in Drive as `school/CLAUDE.md` says, so a loose end isn't archived as FYI.
5. Print a table: `sender | subject | folder | priority | archive | rule (or "judgement")`. Then give counts per priority.
6. If live: apply labels with `label_thread`, then archive FYI and Bulk threads with one `unlabel_thread` call that removes both
   `INBOX` and `UNREAD`. Archived mail is marked read so the Mail app's folder badges don't build up (Dom, 2026-11-20). Action and
   NeedsDom keep `INBOX` and their read or unread state. Append rows to `logs/runs/<today>.md`, writing "yes (INBOX, UNREAD removed)" in `archived`.
7. End with a list of the `judgement` rows Dom might want to turn into sender rules.

## Scheduled (headless) runs
The laptop task / Pi cron runs `claude -p "/sort-inbox live since=YYYY/MM/DD"` via `scripts/run-sort-inbox.{ps1,sh}`, straight after
the school calendar sync, at 07:00 and 17:30. The runner works out `since` from the last successful run, so gaps get caught up. Nobody is watching, so:
- Never ask a question or wait for input. Where no rule decides, use `config/priority-rules.md`; if still unsure, `*Triage/NeedsDom` and don't archive.
- Never create, rename or delete a label. If a label the rules need is missing, apply the priority label only, skip the folder, and list it in the report.
- At most **100 threads** per run (newest first). If there are more, sort 100 and say so; the next run picks up the rest.
- **Your output is the report.** The runner saves it to `logs/sort-inbox/` itself, so don't write a report file. Always include,
  even when nothing needed sorting: the step 5 table, counts per priority, threads left in the inbox (Action and NeedsDom,
  one line each), missing labels, errors, and the step 7 judgement list. Still append the undo rows to `logs/runs/<today>.md`.
- If a Gmail call fails, retry it once; if it fails again, note the thread in the report and carry on.
- The **last line** of output must be exactly one of:
  - `SORT live OK` or `SORT dry-run OK`: the run finished (even with some per-thread errors) and every unsorted thread in the window was handled.
  - `SORT live OK (more remaining)`: you stopped at the 100-thread cap. The runner then keeps the same window for the next run.
  - `SORT FAILED: <reason>`: it couldn't run at all.
