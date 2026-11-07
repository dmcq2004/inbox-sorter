---
description: Label Trinity school and Young Explorers Club mail and produce a digest (dry run unless "live")
argument-hint: "[live] [days=7]"
---

Run the school module as defined in `school/CLAUDE.md`.

Arguments: $ARGUMENTS
- If they contain `live`, apply labels and archive. Otherwise it's a **dry run** (the digest is still written).
- `days=N` sets the lookback (default 7).

Steps:
1. Read `school/CLAUDE.md`, `school/senders.md` and `school/context.md`.
2. Build a query from every row of senders.md, matching from, to and cc, e.g.
   `newer_than:<N>d {from:15511@bromcomcloud.com from:trinity.lewisham.sch.uk from:mychildatschool.com from:impactfood.co.uk from:tyec@hotmail.com to:trinity.lewisham.sch.uk cc:trinity.lewisham.sch.uk to:tyec@hotmail.com cc:tyec@hotmail.com}`.
3. Use `get_thread` on each result and extract actions, dates and FYIs. Read attachments from Drive per `school/CLAUDE.md`.
4. Write the digest to `school/digests/<today>.md` and print it.
5. If live: apply `School/Trinity` + priority, archive FYI, and log to `logs/runs/<today>.md`.
6. List any facts that should go into `context.md` (new teacher names, term dates) and ask Dom before adding them.
