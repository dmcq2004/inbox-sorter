/**
 * Save School Attachments: Google Apps Script
 *
 * Copies attachments from Trinity school and Young Explorers Club emails into
 * Google Drive, so Claude (via the Drive connector) can read them.
 * It runs on Google's servers on a timer, and nothing is needed on Dom's phone.
 *
 * It only reads Gmail and writes to Drive. It never sends, deletes, labels or
 * changes any email.
 *
 * Setup (one time): see school/apps-script/README.md
 */

// ---- Config ---------------------------------------------------------------

/** Drive folder "Trinity" (already exists in Dom's Drive). */
const TRINITY_FOLDER_ID = '1V2DXQlkLruOc-h65prEXejYYB-BI446H';

/** Each source gets a subfolder inside the Trinity folder (created if missing). */
const SOURCES = [
  {
    name: 'Trinity',
    subfolder: 'Email attachments',
    query: '{from:15511@bromcomcloud.com from:trinity.lewisham.sch.uk from:mychildatschool.com ' +
           'to:trinity.lewisham.sch.uk cc:trinity.lewisham.sch.uk}',
  },
  {
    name: 'Young Explorers Club',
    subfolder: 'Young Explorers Club',
    query: '{from:tyec@hotmail.com to:tyec@hotmail.com cc:tyec@hotmail.com}',
  },
];

/** How far back the timed run looks. Use backfill() for older mail. */
const LOOKBACK = 'newer_than:3d';

/** Skip images smaller than this (email-signature logos, spacer gifs). */
const MIN_IMAGE_BYTES = 30 * 1024;

/** Forget processed message IDs after this many days (keeps storage small). */
const MEMORY_DAYS = 45;

// ---- Entry points ---------------------------------------------------------

/** Timed run: last few days only. */
function saveRecent() {
  run_(LOOKBACK);
}

/** One-off: grab everything from the last year. Run manually once after setup. */
function backfill() {
  run_('newer_than:365d');
}

/** Creates the 15-minute timer. Run once. It's safe to run again (no duplicates). */
function installTrigger() {
  ScriptApp.getProjectTriggers()
    .filter(t => t.getHandlerFunction() === 'saveRecent')
    .forEach(t => ScriptApp.deleteTrigger(t));
  ScriptApp.newTrigger('saveRecent').timeBased().everyMinutes(15).create();
  Logger.log('Trigger installed: saveRecent every 15 minutes.');
}

/** Removes the timer, if you ever want to switch this off. */
function uninstallTrigger() {
  ScriptApp.getProjectTriggers()
    .filter(t => t.getHandlerFunction() === 'saveRecent')
    .forEach(t => ScriptApp.deleteTrigger(t));
  Logger.log('Trigger removed.');
}

// ---- Implementation -------------------------------------------------------

function run_(window) {
  const lock = LockService.getScriptLock();
  if (!lock.tryLock(10 * 1000)) return; // a previous run is still going
  try {
    const props = PropertiesService.getScriptProperties();
    const root = DriveApp.getFolderById(TRINITY_FOLDER_ID);
    let saved = 0;

    SOURCES.forEach(src => {
      const folder = getOrCreateSubfolder_(root, src.subfolder);
      const query = `${src.query} has:attachment ${window}`;
      let start = 0;
      while (true) {
        const threads = GmailApp.search(query, start, 50);
        if (threads.length === 0) break;
        threads.forEach(thread => {
          thread.getMessages().forEach(msg => {
            const key = 'm_' + msg.getId();
            if (props.getProperty(key)) return; // already done
            saved += saveMessageAttachments_(msg, folder);
            props.setProperty(key, String(Date.now()));
          });
        });
        if (threads.length < 50) break;
        start += 50;
      }
    });

    pruneMemory_(props);
    Logger.log(`Done. Saved ${saved} attachment(s).`);
  } finally {
    lock.releaseLock();
  }
}

function saveMessageAttachments_(msg, folder) {
  const atts = msg.getAttachments({ includeInlineImages: false, includeAttachments: true });
  const date = Utilities.formatDate(msg.getDate(), 'Europe/London', 'yyyy-MM-dd');
  const subject = clean_(msg.getSubject() || 'no subject').slice(0, 60);
  let count = 0;

  atts.forEach(att => {
    const type = att.getContentType() || '';
    if (type.startsWith('image/') && att.getSize() < MIN_IMAGE_BYTES) return;

    const name = `${date} - ${subject} - ${clean_(att.getName())}`;
    if (folder.getFilesByName(name).hasNext()) return; // same file already saved

    const file = folder.createFile(att.copyBlob().setName(name));
    file.setDescription(
      `From: ${msg.getFrom()}\nSubject: ${msg.getSubject()}\nDate: ${msg.getDate()}\n` +
      `Gmail message id: ${msg.getId()}`
    );
    count++;
  });
  return count;
}

function getOrCreateSubfolder_(parent, name) {
  const it = parent.getFoldersByName(name);
  return it.hasNext() ? it.next() : parent.createFolder(name);
}

function clean_(s) {
  return String(s).replace(/[\\/:*?"<>|\r\n]+/g, ' ').replace(/\s+/g, ' ').trim();
}

function pruneMemory_(props) {
  const cutoff = Date.now() - MEMORY_DAYS * 24 * 3600 * 1000;
  const all = props.getProperties();
  Object.keys(all).forEach(k => {
    if (k.startsWith('m_') && Number(all[k]) < cutoff) props.deleteProperty(k);
  });
}
