# School module: Trinity C of E School Lewisham + Young Explorers Club

Read the root `CLAUDE.md` first. Its safety rules apply here too. This file adds the school-specific rules.

## Scope
- In scope: mail from any sender in `senders.md`, or any thread that is to/cc a Trinity address
  (e.g. Rosemarie emailing `admin@trinity.lewisham.sch.uk` with Dom cc'd).
- Also in scope: **The Young Explorers Club** (`tyec@hotmail.com`), Sebastian's breakfast, after-school
  and holiday club on the Trinity site. Rosie usually handles the bookings, so YEC threads are often between Rosie and YEC with Dom cc'd.
- Out of scope: Bright Horizons / nursery. The general sorter handles it as `Nursery` + FYI.

## Labelling
Every in-scope thread gets its folder label from `senders.md` (`School/Trinity` or `School/Young Explorers`) plus one priority.
For Impact Food (school lunches), a reminder to order lunches is `Action` and anything else is `FYI`.
For YEC, booking forms, payments and session changes are `Action`; a thread where Rosie is already handling it and only cc's Dom is `FYI`, unless someone asks Dom something directly.
Priorities:
- `Triage/Action`: there's a deadline, payment, consent form, permission slip, reply needed, or something to bring or wear on a date.
- `Triage/NeedsDom`: about Sebastian specifically (absence, health, behaviour, teacher message) with no deadline.
- `Triage/FYI`: newsletters, general notices, fundraising, password resets, receipts. Archive these.
Never archive Action or NeedsDom.

## Reading
- Use `get_thread` for every in-scope thread. Subjects are vague ("Newsletter Primary 6 November").
- **Attachments:** the Gmail MCP lists attachments (filename, type) but can't download them.
  Look for the file in Google Drive (`search_files` with `title contains '<filename stem>'`, Trinity folder
  id `1V2DXQlkLruOc-h65prEXejYYB-BI446H`) and read it with `read_file_content` (PDF, docx and pptx all work).
  The `apps-script/` job saves new attachments every 15 minutes into Trinity › `Email attachments` and
  Trinity › `Young Explorers Club`, named `YYYY-MM-DD - subject - filename`. Search for the filename.
  If it isn't in Drive (the script may not have run yet), list it in the digest under "Unread attachments" with its subject and date.
- Newsletters arrive as Sway links. Read them with `python -I school/tools/read_sway.py` (no browser or login needed;
  usage in `newsletters.md`). Run `--dates` first, then `--save` for the full text and read the body for Reception items.
  Track each newsletter in `newsletters.md`.

## Calendar sync
The calendar is kept up to date **hands-off** by `/school-calendar-sync` on a schedule (see `CALENDAR-SYNC.md`). In interactive
sessions, don't hand-edit school events the sync owns (`[school-sync:…]`) without telling Dom. Check the newest
`logs/calendar-sync/` report for its "Needs Dom" items.

- When an attachment has new dates, propose updates to `context.md` (term dates, events).
- Pull out: dates, deadlines, costs, what to bring or wear, and who it applies to (whole school / year group / Reception / Year 6).
  Use `context.md` to judge whether a year-group notice applies to Sebastian.

## Ownership (decided 2026-11-07)
This module **replaced** the old daily claude.ai `school-comms-triage` job, which Dom **switched off on 2026-11-07**. That job
wrote to the Notion "School & Childcare" database and created `[notion-sync:…]` calendar events. Those events still
exist: match and reuse them, never duplicate them. Nothing new is written to that Notion database until the action
tracker (ROADMAP item 2) is built. In the Notion `Child` field, Trinity and YEC items are **Seb**, and only nursery items are Flo.

## Who may change the calendar
- **The scheduled sync** (`/school-calendar-sync`) changes school events **hands-off**, within the rules in its command file.
- **Interactive sessions** create or change calendar events only with Dom's OK in that session, then log the change to `logs/runs/`.

## Digest output
Write `school/digests/YYYY-MM-DD.md` and also print it:
```
## Needs action
- [deadline] what — thread link
## Coming up
- [date] event — applies to Sebastian? yes/no/unsure
## FYI
- one line each
```
Keep it short. Dom reads it on his phone.

## Never
- Reply to, or email, the school. Draft only if Dom asks, using the `email-reply-editor` voice.
- Track Young Explorers Club bookings (sessions added or cancelled). The family decides those; only club closures and club-wide events count.

## Related
The old claude.ai `school-comms-triage` skill is **retired** (switched off 2026-11-07). This module's rules win; don't follow that skill.
