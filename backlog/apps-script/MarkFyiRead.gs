/**
 * One-off clean-up (Dom, 2026-11-20): mark every unread Triage/FYI email as read.
 *
 * It only clears the "unread" flag. It doesn't archive, move, label, delete or send anything.
 * Gmail can mark 100 threads read in one call, so ~6,800 threads take a few minutes.
 *
 * How to run it:
 *   1. Go to https://script.google.com, click "New project" and paste this whole file over the sample code.
 *   2. Choose markFyiRead in the function menu at the top and click Run.
 *   3. The first time, Google asks you to allow access to Gmail. Allow it.
 *   4. Look at View > Logs (or the Execution log panel). It says how many it marked and whether any are left.
 *      Apps Script stops a run after 6 minutes, so this stops itself at about 5. If the log says some are left, click Run again.
 *   5. When the log says "Done", you can delete the project.
 *
 * Undo: there's no list of which emails were unread, so this can't be reversed email by email.
 */
const QUERY = 'label:triage-fyi is:unread';
const BATCH = 100;               // most threads GmailApp.markThreadsRead takes in one call
const TIME_LIMIT_MS = 5 * 60 * 1000;

function markFyiRead() {
  const start = Date.now();
  let marked = 0;
  while (Date.now() - start < TIME_LIMIT_MS) {
    const threads = GmailApp.search(QUERY, 0, BATCH);
    if (threads.length === 0) break;
    GmailApp.markThreadsRead(threads);
    marked += threads.length;
  }
  const left = GmailApp.search(QUERY, 0, 1).length > 0;
  Logger.log('Marked %s threads as read. %s', marked, left ? 'Some are left: click Run again.' : 'Done: no unread FYI emails left.');
}
