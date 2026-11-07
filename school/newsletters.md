# Trinity newsletters (Sway)

Trinity sends a weekly primary newsletter as a Microsoft Sway link, usually from `15511@bromcomcloud.com` (11 Sep came
from `F.Lourdjane@trinity.lewisham.sch.uk`). The link is in the email body (the HTML body if the plain text lacks it).

**How to read one (no browser needed):**
```
python -I school/tools/read_sway.py --dates <sway url or id>         # just the "Important Dates" list
python -I school/tools/read_sway.py --save school/newsletters <url>  # full text → school/newsletters/<title>.txt
```
The script calls Sway's public content endpoint (`POST /s/<id>/get`), which needs no login. Full texts live in
`school/newsletters/` (git-ignored). Every newsletter ends with a rolling **Important Dates** list; the newest
newsletter's list supersedes older ones. Still read the body for Reception items, things to bring or wear, and payments.

| Newsletter | Sent | Sway id | Status |
|---|---|---|---|
| Trinity Bulletin 06 11 26 | 2026-11-06 | O4rCA5oayOOKXzi1 | read 2026-11-07 |
| Trinity Bulletin 23 10 26 | 2026-10-23 | VOAVILEGZAYWnkUW | read 2026-11-07 |
| Trinity Bulletin 16 10 26 | 2026-10-16 | gJRA4GgTHp7wu5gt | read 2026-11-07 |
| Trinity Bulletin 09 10 26 | 2026-10-09 | bDevUdovQfLwWClA | read 2026-11-07 |
| Trinity Bulletin 02 10 26 | 2026-10-02 | qsOO3h2AD6zdR8qY | read 2026-11-07 |
| Trinity Bulletin 24 09 26 | 2026-09-25 | o4zd8NinPPflcX2Y | read 2026-11-07 |
| Trinity Bulletin 18 09 26 | 2026-09-18 | RVrqJnC6BvZSd8nq | read 2026-11-07 |
| Trinity Bulletin 11 09 26 | 2026-09-11 | Cdd2YDjkOVIJjNlW | read 2026-11-07 |

## Still-relevant findings (as of 2026-11-07)

**Dates for Seb (from the 06 11 list, consistent across all newsletters):**
- Tue 17 Nov: individual & sibling photos (QR codes sent home, orders online)
- **Fri 20 Nov: PAFT own-clothes day** (uniform-free, donation for the Christmas Fair). In every list since 11 Sep, but **not in the calendar**
- Wed 25 Nov: Reception & Y6 height and weight
- Fri 27 Nov: INSET
- Tue 1 / Wed 2 Dec: EYFS & KS1 nativities (Reception: Tue 10:00, Wed 14:15, from the Parent Curriculum)
- Fri 4 Dec: PAFT Christmas Fair (from 14:30, from the Parent Curriculum)
- Thu 10 Dec: Cinderella, Broadway Theatre. Ms Harvey will ask parents to **help** before the end of November
- Wed 16 Dec: Christmas jumper & Christmas dinner day
- **Thu 17 Dec: class Christmas parties** (06 11 body text only, not in the dates list)
- Fri 18 Dec: finish at **12:15**
- Tue 5 Jan: back to school

**Standing expectations:**
- Uniform is checked and parents are told when it's wrong. **PE kit: white polo, blue bottoms**, also checked. **Seb's PE day is Friday** (Dom, 7 Nov).
- **Coats every day, with names in them.** Lost property is in the office, staffroom and under the shelter.
- No toys brought into school.
- **Reception home learning started after October half term** (Little Wandle phonics; reading books matched to sounds learned).
- Allergy safety: new statutory rules ("Benedict's Law") from Sept 2026. The school said it would write to parents; no action needed.

**Optional or community:** PAFT Christmas trees (pick-up from Trinity Secondary, date TBC); Play Street, Wisteria Road, Sun 8 Nov 12:30–15:30.

**Past items for the accuracy test set:** RR library trip Mon 19 Oct; Reception Maths Workshop Wed 14 Oct;
Harvest at St Swithuns Tue 13 Oct (Reception 13:30–14:20); Show Racism the Red Card, wear red, Fri 16 Oct;
harvest food drive (week of 5 Oct); International Food Night Thu 1 Oct 16:00; Book Fair 17–23 Sep; flu vaccines 23 Sep.
