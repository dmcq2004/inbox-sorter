# School module roadmap

The backlog of school capabilities, agreed with Dom on 2026-11-07. Work on one at a time. Move items
to **Done** with a date, and keep any design notes in the item.

## In progress
- [ ] **1. Calendar sync.** Term dates, INSET days, early pick-ups, school and club events in Google Calendar.
  No duplicates, and each event links back to its source email or document. See "Calendar design" below.
  - [x] 2026-11-07: Autumn-term backfill, 10 changes approved and made (see `logs/runs/2026-11-07.md`).
  - [x] 2026-11-07: **hands-off** sync built as `/school-calendar-sync` (Dom chose hands-off over approve-first), run headlessly
    by `scripts/run-calendar-sync.{ps1,sh}`, scheduled on the laptop at 07:00 and 17:30. Design and Pi steps are in `school/CALENDAR-SYNC.md`.
  - [x] Dom switched off the old claude.ai `school-comms-triage` job (2026-11-07).
  - [ ] Move to the Raspberry Pi.
  - [ ] Open: nativity session choice (delete the other one). (YEC bookings are the family's call, not tracked.)
    (Resolved 7 Nov: PE day is Friday; Cinderella form done.)

## Up next (not prioritised)
- [ ] **2. Action tracker + shared view for Dom and Rosie.** One list of forms, payments and things to bring/wear, with due dates,
  that **Rosie can see too** (a private claude.ai page is ruled out because she can't open it). Not urgent; design notes from 2026-11-07:
  - **Dom's main worry: duplicates.** The old Notion list got messy because there was one row per *email* (the panto appeared
    in 8 newsletters), no stable key, statuses that were never closed, and more than one writer. The rules for the new version:
    1. **One row per real-world thing,** keyed like the calendar: `[school-sync:<key>]` stored in a property. Always update in place, never insert twice.
    2. **One writer:** only the sync creates rows. People only tick status (and the sync respects their ticks).
    3. **Auto-close:** done when a receipt, confirmation or reply appears, or when the date has passed for no-action items.
    4. **Clean start:** archive the old database (or dedupe it) rather than layering new rows on top of the mess.
  - **Dom's second point: a good-looking view gets used more.** Separate sections: *Do this* · *Next 14 days* ·
    *What to bring or wear this week* · *Needs Dom* · *Last sync*.
  - **Where it could live (to decide):**
    - (a) A **Notion dashboard page** shared with Rosie, built from linked views of the action list plus a calendar view. Both have
      Notion on their phones, it works anywhere, and there's no hosting. Looks decent rather than bespoke.
    - (b) A **custom page on the Pi**, regenerated each sync. It can look exactly how we want, but only on home Wi-Fi (or with Tailscale on both phones).
    - Either way, the view only *reads* the calendar and the action list and stores nothing itself, so it can't create duplicates.
  - **Related:** a shared "Seb · School" Google Calendar with Rosie (Dom creates it and shares it on the web; then the events
    move across with his OK, and the sync writes only there). Rosie gets the events in her own calendar app.
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
