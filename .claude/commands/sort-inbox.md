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
