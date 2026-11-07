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

`impactfood.co.uk` is deliberately not in the Apps Script `SOURCES` (lunch reminders have no attachments worth saving). Add it there too if that changes.
