# School-module senders

Match on a substring of the sender, or of a to/cc address. Keep this in step with `SOURCES` in
`apps-script/SaveSchoolAttachments.gs`.

| Match | What it is | Folder label |
|---|---|---|
| `15511@bromcomcloud.com` | Trinity school-wide comms via Bromcom (newsletters, letters, receipts) | School/Trinity |
| `@trinity.lewisham.sch.uk` | Trinity staff and admin office | School/Trinity |
| `mychildatschool.com` | MCAS parent portal (passwords, payments) | School/Trinity |
| `impactfood.co.uk` | Innovate (Impact Food): Trinity school-lunch caterer. Ordering reminders are `Action` | School/Trinity |
| `tyec@hotmail.com` | The Young Explorers Club: breakfast/after-school and holiday club on the Trinity site | School/Young Explorers |
| `vancols.com` | Van Cols, the school photographer (added 2026-11-20). "Photos ready to order" is `NeedsDom`, or `Action` if it gives an order deadline | School/Trinity |

`impactfood.co.uk` and `vancols.com` are deliberately not in the Apps Script `SOURCES` (lunch reminders and photo notices have no attachments worth saving). Add them there too if that changes.
