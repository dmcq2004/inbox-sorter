# Project to-do

The single to-do list for the whole project. School detail lives in `school/ROADMAP.md`.
Update this file whenever something is done, decided or blocked, and date the change.
Last updated: 2026-11-07.

## Waiting on Dom
- [ ] **Nativity:** pick Tue 1 Dec 10:00 or Wed 2 Dec 14:15, then delete the other calendar event.
- [x] **Attachment saver installed** (2026-11-07): Apps Script project "Save School Attachments", backfill saved 26 files, runs every 15 min.
- [x] **Labels reviewed** (2026-11-07): 4 new labels created; 15 to delete (see `config/labels.md`).
- [x] **15 approved labels deleted** (2026-11-07, through Chrome).
- [x] **Sender rules reviewed** (2026-11-07): family rules, payment-problem override, Admiral, 9 rules for active senders (70 rules after the dry-run fixes).
- [x] **Switched off the old claude.ai `school-comms-triage` daily job** (Dom, 2026-11-07). The laptop sync has taken over.
- [ ] **Push the repo to GitHub** (private) when you're ready to move the sync to the Pi (steps in `school/CALENDAR-SYNC.md`).

## Phases
- [x] **1. Audit the mailbox:** labels, inbox sample, draft rules (2026-11-07)
- [x] **2. Set up the project:** CLAUDE.md files, config, commands, git (2026-11-07)
- [ ] **3. General sorter:** `/sort-inbox` dry run on 7 days → Dom reviews → live → scheduled routine (several runs a day)
  - [x] Dry run on 7 days, rules tuned (71 rules), first live run: 138 threads sorted, 123 archived (2026-11-07, `logs/runs/2026-11-07.md`)
  - [x] Scheduled routine set up (2026-11-07): the "Inbox Sorter" task runs the school sync, then `/sort-inbox live` (last 2 days), at 07:00 and 17:30. It replaced the "School Calendar Sync" task. Headless dry run tested OK.
  - [ ] Check the first few reports in `logs/sort-inbox/` and tune the rules; Dom flags anything misfiled on his phone.
- [ ] **4. School module:** see `school/ROADMAP.md`
  - [x] Context, term dates, YEC moved in, attachment saver written, newsletter reader, all 8 newsletters read (2026-11-07)
  - [x] Calendar backfill to Christmas, 10 changes (2026-11-07, `logs/runs/2026-11-07.md`)
  - [x] Hands-off calendar sync built and scheduled on the laptop: 07:00 and 17:30 daily (2026-11-07). See `school/CALENDAR-SYNC.md`.
  - [ ] Move the sync and the sort to the Raspberry Pi (64-bit OS, Claude Code signed in, cron; lines in `school/CALENDAR-SYNC.md`), then remove the laptop task.
  - [ ] Check the first week of reports in `logs/calendar-sync/` and tune the rules.
- [ ] **5. Backlog clean-up** (19.5k old inbox threads). Starts after ~2 weeks of clean live sorting.

## Housekeeping
- [ ] Keep the summary page (https://claude.ai/artifact/SLJ2edFMQSi5hLRydW3nKj) in step with this file and `school/ROADMAP.md`.
- [ ] Notion School & Childcare database: fix `Child` = "Both" on Trinity items (should be "Seb"), plus stale statuses. Part of the action-tracker work.
- [ ] Tell the Trinity office that some staff email signatures link to `trinitylewisham.org` (a spam site) instead of `trinitylewisham.org.uk` (optional; Dom's call).

- [ ] **After 20 Jul 2027:** purge the 2026–27 school attachments from Drive (see Decisions in `school/ROADMAP.md`).

## Done log
- 2026-11-07: project started; plan approved; school calendar backfilled; newsletters readable without a browser.
