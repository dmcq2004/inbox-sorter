# Save School Attachments: setup

This copies attachments from Trinity and Young Explorers Club emails into
Drive › Trinity › `Email attachments` and `Young Explorers Club`, every 15 minutes.
The `/school` command then reads them with the Drive connector.

It only **reads** Gmail and **creates files** in Drive. It never sends, deletes or labels mail.

## One-time setup (about 5 minutes, on a computer)
1. Go to https://script.google.com and sign in as dmcq2004@gmail.com. Click **New project**.
2. Rename the project (top left) to **Save School Attachments**.
3. Delete the sample code, and paste in the whole of `SaveSchoolAttachments.gs`. Save (Ctrl+S).
4. In the function dropdown at the top, choose **`backfill`** and click **Run**.
   - Google will ask you to authorise it: *Review permissions → choose your account →
     "Google hasn't verified this app" → Advanced → Go to Save School Attachments (unsafe) → Allow.*
     The warning appears because the script is your own, not a published app. It asks for Gmail (read) and Drive access.
   - The run saves the last year of attachments. Check the Execution log for "Saved N attachment(s)".
5. Choose **`installTrigger`** in the dropdown and click **Run**. This starts the 15-minute timer.

## Checking it
- Drive › Trinity should now have the two new subfolders. Files are named `YYYY-MM-DD - subject - filename`.
- In script.google.com, **Executions** (left sidebar) shows each timed run.

## Changing or stopping it
- Add a sender: edit `SOURCES` in the script and keep `school/senders.md` in step.
- Stop it: run `uninstallTrigger`.

## Installed
2026-11-07, in Dom's account: project "Save School Attachments"
(https://script.google.com/home/projects/1sP6biVHtJsJleOMVABFynoLU-pfqkhB8LOsu_LS5dWCdBfTnQ9LaQ-eN/edit).
The backfill saved 26 attachments; the trigger `saveRecent` runs every 15 minutes.
Drive folders: Trinity › Email attachments (`1vNGqSBo51pa1Sen-JbV9Ic7LbnZQARj8`) and Trinity › Young Explorers Club (`1fzX218MYElQe_eIhdBOWIzCxocyGBuM8`).
If you change the script here, paste it into that project too, since the project doesn't sync with this repo.
