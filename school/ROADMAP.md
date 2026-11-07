# School module roadmap

The backlog of school capabilities, agreed with Dom on 2026-11-07. Work on one at a time. Move items
to **Done** with a date, and keep any design notes in the item.

## In progress
- [ ] **1. Calendar sync.** Term dates, INSET days, early pick-ups, school and club events in Google Calendar.
  No duplicates, and each event links back to its source email or document. See "Calendar design" below.
  - [x] 2026-11-07: Autumn-term backfill, 10 changes approved and made (see `logs/runs/2026-11-07.md`).
  - [ ] Build the repeatable sync into `/school`: newsletter `--dates` + emails + Drive attachments → proposed changes → Dom approves → apply.
  - [ ] Once `/school` runs on a schedule, Dom switches off the old claude.ai `school-comms-triage` job.
  - [ ] Open: whether YEC runs on early-finish days; nativity session choice (delete the other one).
    (Resolved 7 Nov: PE day is Friday; Cinderella form done.)

## Up next (not prioritised)
- [ ] **2. Action tracker.** One list of forms, payments and things to bring/wear, with due dates. Candidate home:
  the Notion "School & Childcare" database (tidy its duplicates first: MCAS ×3, Young Explorers ×2).
  Close items automatically when a receipt, confirmation or reply appears.
- [ ] **3. Weekly school brief.** Sunday evening: this week's events, what to bring or wear, pick-up times,
  club bookings, open actions. Check against Dom's `weekly-family-brief` skill so the two don't overlap.
- [x] **4. Read Sway newsletters.** Done 2026-11-07: `school/tools/read_sway.py` reads them via Sway's public
  JSON endpoint, with no browser. All 8 newsletters (11 Sep–6 Nov) have been read; findings are in `newsletters.md`.
- [ ] **5. Coordinate with Rosie.** Spot when Rosie has already handled something (her replies to the school or YEC),
  so it isn't done twice or missed by both.
- [ ] **6. Holiday cover planning.** Compare half terms and INSET days with Dom's calendar, and flag when YEC
  holiday club needs booking and by when.
- [ ] **7. Ask anything.** Answer questions like "when's the nativity?" or "what's PE kit?" from `context.md`,
  and keep `context.md` up to date automatically from new mail and attachments.
- [ ] **8. Drafts in Dom's voice.** Absence notes, replies to the teacher, club bookings. Drafts only, using the
  `email-reply-editor` style.

## Accuracy test set
Before trusting any capability, run it over **Sep–Nov 2026** and compare with what actually happened:
induction days (3 and 7 Sep), Meet the Teacher, the Reception library trip on 19 Oct (Dom volunteered),
International Food Night on 1 Oct, the absences (21 Sep, 13 Nov), and the NHS measurement on 25 Nov.

## Calendar design

### What already exists (audit 2026-11-07, primary calendar `dmcq2004@gmail.com`)
| Layer | Created by | What it covers | Convention |
|---|---|---|---|
| Term structure | Earlier Claude session, 3 Sep | All of 2026–27: last days, half terms, holidays, INSET days | All-day, **free/transparent**, colour 10 (green), title ends "(Seb)", e.g. `Trinity INSET — school closed (Seb)` |
| Autumn events | Earlier session, 10 Sep, from the "Upcoming dates" slide | Book Fair, workshops, Harvest, Coffee with Mr Cotton… to 22 Oct | `Trinity: <event>`. Times often "assumed 1 hour" |
| Email-driven events | **A daily ~06:00 job → Notion "School & Childcare" → Calendar** (`[notion-sync:<page id>]` in the description) | Only some rows get events: Food Night, MHST, TYEC invoice, NHS, Cinderella | All-day on the Notion "Deadline" date, popup reminders 2 days before and on the day |
| Dutch school | Earlier session, 3 Sep | De Zeven Eiken: weekly Monday 16:45–19:00 + special days | Colour 6 |
| TYEC | Earlier session, 30 Aug | Drop-off/pick-up for the first week only (10–18 Sep) | Timed, with location |

### Problems found
- **Two event models are mixed.** Notion-sync events sit on the *deadline* date as all-day items. "Cinderella Trip – Permission & Payment" is on the trip day (10 Dec), so the real permission deadline is invisible.
- **Gaps (Autumn term, all from the Parent Curriculum PDF):** photo day 17 Nov, Reception nativity 1/2 Dec, PAFT Christmas Fair 4 Dec, pantomime trip 10 Dec (exists only as a payment item), Christmas dinner + jumper day 16 Dec.
- **Early-finish times are "not confirmed"** on 18 Dec, 25 Mar and 20 Jul. The Parent Curriculum says 18 Dec pick-up is **12:15**.
- **The Notion `Child` field is often wrong:** Trinity items are tagged "Both" though Flo isn't at Trinity (e.g. NHS measurement, Poppy Appeal).
- **Statuses go stale:** past events are still "Not started". Nothing closes them.
- Nothing yet covers spring and summer events; they'll arrive by email and newsletter.

### Proposed design (pending Dom's answers)
- **One owner.** Either this project replaces the daily Notion→Calendar job, or that job keeps intake and this project only reconciles. Two writers means duplicates.
- **Keep the existing conventions** so old and new events look the same: closures are all-day/free/green "(Seb)"; events use `Trinity: …` or `TYEC: …`.
- **Event kinds:**
  1. *Closure* (INSET, holidays): all-day, free, green.
  2. *Early pick-up*: a **timed** event at the pick-up time (e.g. 12:15–12:30, "Pick up Seb — early finish"), busy, so it blocks your day.
  3. *School event a parent attends* (nativity, workshops): timed if the time is known, with the location, busy.
  4. *In-school day* (photo day, jumper day, measurement): all-day, free, with what to bring or wear in the title.
  5. *Deadline* (form, payment): all-day on the deadline, reminders 2 days before and on the day. These are the action tracker's job (item 2), so calendar entries only exist when there's a real date.
- **Dedupe key:** `[school-sync:<gmail message id or drive file id>#<slug>]` in the description. Before creating, match on that key, on any `notion-sync` key, and on same date plus a similar title (this covers the hand-made events).
- **Every event links to its source:** Gmail thread or Drive file URL plus one line of quoted source text.
- **Changes:** if a later email changes a date or time, update the existing event, never add a second. Cancellations become "CANCELLED — …" and are flagged for Dom, never deleted silently.

## Done
- 2026-11-07: school context (`context.md`), attachment saver (`apps-script/`), YEC moved into the module.
