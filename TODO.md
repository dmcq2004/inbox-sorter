# Project to-do

The single to-do list for the whole project. School detail lives in `school/ROADMAP.md`.
Update this file whenever something is done, decided or blocked, and date the change.
Last updated: 2026-11-23.

## Waiting on Dom
- [ ] **Give the Pi write access to GitHub** (asked 2026-11-23; Dom will do it later): at https://github.com/dmcq2004/inbox-sorter/settings/keys delete "Raspberry Pi (read-only)", then add the same key (`~/.ssh/inbox_sorter_deploy.pub` on the Pi) as "Raspberry Pi" with **Allow write access** ticked. Until then, changes made in a session on the Pi can't be pushed. Afterwards: rename the key's comment on the Pi and update `school/CALENDAR-SYNC.md`.
- [ ] **Decide on the rules suggested by the Pi's dry run** (2026-11-23): Optiver (`optiver.com`, `optiver.uk`) → NeedsDom; `rosemarie_little@hotmail.com` → NeedsDom; `noreply@github.com` → FYI, NeedsDom for "public key"/"new sign-in"; `services.nuffieldhealth.com` → FYI; `cybex-online.com`, `boxt.co.uk`, `discover@airbnb.com` → Bulk.
- [x] **Ran `backlog/apps-script/MarkFyiRead.gs`** (Dom, 2026-11-20; checked: no unread FYI left): marked all ~6,800 unread `*Triage/FYI` emails as read. Paste it into a new project at script.google.com, run `markFyiRead`, and run it again until the log says "Done". It can't be undone email by email. From 20 Nov the sort and the school sync mark FYI and Bulk read as they archive them.
- [x] **Nativity** (2026-11-20): going to both (Tue 1 Dec 10:00 and Wed 2 Dec 14:15). Both events kept, renamed and set to busy.
- [x] **Attachment saver installed** (2026-11-07): Apps Script project "Save School Attachments", backfill saved 26 files, runs every 15 min.
- [x] **Labels reviewed** (2026-11-07): 4 new labels created; 15 to delete (see `config/labels.md`).
- [x] **15 approved labels deleted** (2026-11-07, through Chrome).
- [x] **Sender rules reviewed** (2026-11-07): family rules, payment-problem override, Admiral, 9 rules for active senders (70 rules after the dry-run fixes).
- [x] **Switched off the old claude.ai `school-comms-triage` daily job** (Dom, 2026-11-07). The laptop sync has taken over.
- [x] **Repo pushed to GitHub** (2026-11-07): private, https://github.com/dmcq2004/inbox-sorter, branch `main`. Pushes need Dom (`! git push`); Claude Code's permission check blocks Claude from pushing.

## Phases
- [x] **1. Audit the mailbox:** labels, inbox sample, draft rules (2026-11-07)
- [x] **2. Set up the project:** CLAUDE.md files, config, commands, git (2026-11-07)
- [ ] **3. General sorter:** `/sort-inbox` dry run on 7 days → Dom reviews → live → scheduled routine (several runs a day)
  - [x] Dry run on 7 days, rules tuned (71 rules), first live run: 138 threads sorted, 123 archived (2026-11-07, `logs/runs/2026-11-07.md`)
  - [x] Scheduled routine set up (2026-11-07): the "Inbox Sorter" task runs the school sync, then `/sort-inbox live` (last 2 days), at 07:00 and 17:30. It replaced the "School Calendar Sync" task. Headless dry run tested OK.
  - [ ] Check the first few reports in `logs/sort-inbox/` and tune the rules; Dom flags anything misfiled on his phone.
  - [x] Unattended fixes (2026-11-19): the sort now starts from the last successful run (`state/sort-inbox.json`), so mail isn't missed after the laptop is off (44 threads from 7–16 Nov were stranded); the runner saves every live report itself (7 of 12 were missing); HL rule fixed (`.hl.co.uk`), LinkedIn InMail rule and 9 sender rules added (81 rules); the sync no longer edits the git-tracked `school/newsletters.md`, so the Pi's `git pull` can't get blocked.
  - [x] Catch-up run (2026-11-20, started by hand at 09:30 after the laptop slept through 3 runs, 19 Nov 07:00 to 20 Nov 07:00): 83 threads from 6 Nov sorted, 74 archived, 9 left as NeedsDom; state now 20 Nov. Report `logs/sort-inbox/2026-11-20_0930.md`. Fixed garbled characters in saved reports (the runner now reads Claude's output as UTF-8).
  - [x] Decided (Dom, 2026-11-20): don't wake the laptop from sleep; wait for the Pi (the catch-up window means nothing is lost).
  - [x] Reviewed all 7 sort reports, 7–20 Nov (2026-11-20): no errors, no missing labels. Dom agreed: Van Cols added to the school senders (School/Trinity, also in both school search queries); new rules for noushold.com (FYI), Fidelity `email.wi@` marketing, Goodreads and NOW TV (Bulk), Gemini notices (Google, FYI); Bright Horizons direct messages now NeedsDom; Admiral marketing now Bulk (86 rules). Dom declined: LinkedIn "Message replied:" recruiter replies → NeedsDom (they stay Bulk), and HMRC advice mailings → FYI (they stay NeedsDom).
  - [x] School threads are now filed by the calendar sync (Dom, 2026-11-19), which reads attachments first, so a loose end (e.g. an unreadable attachment) stays in the inbox as NeedsDom instead of being archived as FYI. The sort only files school threads the sync missed.
  - [ ] Failure alerts: Dom passed for now (2026-11-19). The recommendation is healthchecks.io, which also catches a dead Pi. More useful now the runs are on the Pi, where logs are out of sight.
- [ ] **4. School module:** see `school/ROADMAP.md`
  - [x] Context, term dates, YEC moved in, attachment saver written, newsletter reader, all 8 newsletters read (2026-11-07)
  - [x] Calendar backfill to Christmas, 10 changes (2026-11-07, `logs/runs/2026-11-07.md`)
  - [x] Hands-off calendar sync built and scheduled on the laptop: 07:00 and 17:30 daily (2026-11-07). See `school/CALENDAR-SYNC.md`.
  - [x] Moved the sync and the sort to the Raspberry Pi (2026-11-23): `dmcquade@raspberrypi.local`, repo cloned with a read-only deploy key, Claude Code re-signed in (the old login had expired), both dry runs passed, cron at 07:00 and 17:30, laptop task disabled (not deleted). Details in `school/CALENDAR-SYNC.md`.
  - [ ] **Claude sign-ins end on a fixed date** (found 2026-11-23): the laptop's ends 29 Nov to 2 Dec, and renewing doesn't move it. The Pi signed in on 23 Nov, so expect its end about a month later. Before then, run `claude` → `/login` at the Pi, or test whether `claude setup-token` (made for unattended jobs) keeps the Gmail, Calendar and Drive connectors.
  - [ ] Check the Pi's first live runs (23 Nov 17:30, 24 Nov 07:00): `ssh dmcquade@raspberrypi.local 'ls -t ~/Emails/logs/sort-inbox ~/Emails/logs/calendar-sync | head'`.
  - [ ] Check the first week of reports in `logs/calendar-sync/` and tune the rules.
- [ ] **5. Backlog clean-up** (19.5k old inbox threads). See `backlog/CLAUDE.md`.
  - [x] 2026-11-23: Apps Script `backlog/apps-script/SortBacklog.gs` run through Chrome: dry run, then 6,272 old FYI/Bulk and 6-month-old Action/NeedsDom archived, and 6,432 threads labelled by the 86 rules. Inbox ~19,500 → ~8,090. Undo log in the Drive sheet "Backlog sort".
  - [ ] **Resume tomorrow (2026-11-24):** finish `tallySenders` in the "Sort Backlog" project (read-only; lists the ~7,900 unruled threads by sender in the "Unruled senders" tab). Paused on 23 Nov after Apps Script's daily Gmail quota ran out. The current version uses the Gmail API and resumes from its saved place, at ~500 threads a run; once the quota has reset, the GmailApp version (commit 6ec61fb plus `tallySenders`) does ~1,700 a run.
  - [ ] Then: agree rules for the biggest senders with Dom, add them to `config/sender-rules.yaml`, rebuild with `build_rules.py`, paste, and rerun `runLive`.

- [ ] **6. Inbox chief of staff** (designed with Dom, 2026-11-23). See `inbox/CLAUDE.md`.
  - [x] Built (2026-11-23): `/inbox` (brief, drafts written automatically, ✎ on every draft, acts only on Dom's word; sends only when he says, with Claude Code confirming), `/morning-brief` (Pi, 07:00, emails the brief to Dom only), `.claude/hooks/send_guard.py` (scheduled jobs can't send; the brief can only go to Dom). The sort and sync runners now block send, reply and forward.
  - [ ] **Dom: apply the `.claude/settings.json` change** (Claude's auto-mode check blocked Claude from editing the blocked-tools list): move `send_message`, `reply`, `forward` and `delete_draft` from `deny` to a new `ask` list, allow `list_drafts` and `get_draft`, and add the `send_guard.py` hook. Until then `/inbox` can draft but not send, and the brief can't email.
  - [ ] Then: brief dry run on the Pi, one live brief to check it arrives with a phone notification, add it to the 07:00 cron line.
  - [ ] Next version: a shared list of open items (waiting on others, Dom's promises) that both machines can see, and chasing when a thread goes quiet. It needs somewhere both can write: not git (the Pi's runs never commit) and not a Drive file (the connector can't change a file once created). Options: a Gmail label, a Notion page, or a Google Sheet.

## Housekeeping
- [ ] Keep the summary page (https://claude.ai/artifact/SLJ2edFMQSi5hLRydW3nKj) in step with this file and `school/ROADMAP.md`.
- [ ] Notion School & Childcare database: fix `Child` = "Both" on Trinity items (should be "Seb"), plus stale statuses. Part of the action-tracker work.
- [ ] Tell the Trinity office that some staff email signatures link to `trinitylewisham.org` (a spam site) instead of `trinitylewisham.org.uk` (optional; Dom's call).

- [ ] **After 20 Jul 2027:** purge the 2026–27 school attachments from Drive (see Decisions in `school/ROADMAP.md`).

## Done log
- 2026-11-07: project started; plan approved; school calendar backfilled; newsletters readable without a browser.
- 2026-11-19: made the scheduled runs safe to leave unattended (catch-up window, reports always saved, rule fixes).
- 2026-11-20: "Inbox Actions" dashboard (https://claude.ai/artifact/P42emKptwWME3UtYG8NFKJ): live Gmail view of Action (since 1 Sep) and NeedsDom (last 30 days) still in the inbox, split School / Everything else. The school split uses the School/* labels plus the school senders (incl. De Zeven Eiken); keep it in step with `school/senders.md`.
- 2026-11-23: Sync and sort moved to the Raspberry Pi.
- 2026-11-23: Renamed the Triage labels to `*Triage` (Dom asked). Label IDs are unchanged, so all threads kept their labels. Searches must now quote the name (`label:"*Triage/FYI"`); updated CLAUDE.md, the rule files, the commands, `MarkFyiRead.gs` and the Inbox Actions dashboard queries.
