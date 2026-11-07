# Project to-do

The single to-do list for the whole project. School detail lives in `school/ROADMAP.md`.
Update this file whenever something is done, decided or blocked, and date the change.
Last updated: 2026-11-07.

## Waiting on Dom
- [ ] **Nativity:** pick Tue 1 Dec 10:00 or Wed 2 Dec 14:15, then delete the other calendar event.
- [x] **Attachment saver installed** (2026-11-07): Apps Script project "Save School Attachments", backfill saved 26 files, runs every 15 min.
- [ ] **Review `config/labels.md`** (4 new labels, ~25 to prune) and **`config/sender-rules.yaml`** (~55 rules).
- [x] **Switched off the old claude.ai `school-comms-triage` daily job** (Dom, 2026-11-07). The laptop sync has taken over.
- [ ] **Push the repo to GitHub** (private) when you're ready to move the sync to the Pi (steps in `school/CALENDAR-SYNC.md`).

## Phases
- [x] **1. Audit the mailbox:** labels, inbox sample, draft rules (2026-11-07)
- [x] **2. Set up the project:** CLAUDE.md files, config, commands, git (2026-11-07)
- [ ] **3. General sorter:** `/sort-inbox` dry run on 7 days → Dom reviews → live → scheduled routine (several runs a day)
  - Blocked on: Dom's review of labels and sender rules; creating the new labels (needs Dom's OK)
- [ ] **4. School module:** see `school/ROADMAP.md`
  - [x] Context, term dates, YEC moved in, attachment saver written, newsletter reader, all 8 newsletters read (2026-11-07)
  - [x] Calendar backfill to Christmas, 10 changes (2026-11-07, `logs/runs/2026-11-07.md`)
  - [x] Hands-off calendar sync built and scheduled on the laptop: 07:00 and 17:30 daily (2026-11-07). See `school/CALENDAR-SYNC.md`.
  - [ ] Move the sync to the Raspberry Pi (64-bit OS, Claude Code signed in, cron), then remove the laptop task.
  - [ ] Check the first week of reports in `logs/calendar-sync/` and tune the rules.
- [ ] **5. Backlog clean-up** (19.5k old inbox threads). Starts after ~2 weeks of clean live sorting.

## Housekeeping
- [ ] Keep the summary page (https://claude.ai/artifact/SLJ2edFMQSi5hLRydW3nKj) in step with this file and `school/ROADMAP.md`.
- [ ] Notion School & Childcare database: fix `Child` = "Both" on Trinity items (should be "Seb"), plus stale statuses. Part of the action-tracker work.
- [ ] Tell the Trinity office that some staff email signatures link to `trinitylewisham.org` (a spam site) instead of `trinitylewisham.org.uk` (optional; Dom's call).

## Done log
- 2026-11-07: project started; plan approved; school calendar backfilled; newsletters readable without a browser.
