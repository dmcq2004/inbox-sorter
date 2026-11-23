#!/usr/bin/env bash
# Runs the general inbox sorter headlessly with Claude Code (Raspberry Pi / Linux).
# Usage:  scripts/run-sort-inbox.sh [live|dry-run] [days]
# Cron: run it straight after the calendar sync on the same line, e.g.
#   0 7 * * *   PULL=1 /home/dmcquade/Emails/scripts/run-calendar-sync.sh live; /home/dmcquade/Emails/scripts/run-sort-inbox.sh live
#
# Window: from the day before the last successful live run (state/sort-inbox.json), so a gap of any length (Pi down)
# is caught up. With no state it looks back 7 days; it never looks back more than 30. A days argument overrides this.
# The state only moves forward after a live run that finished and wasn't capped at 100 threads.
# The run's output is saved as the report in logs/sort-inbox/ (live runs), so a report always exists.
set -uo pipefail
MODE="${1:-live}"
DAYS="${2:-0}"
TIMEOUT_MIN="${TIMEOUT_MIN:-30}"
MODEL="${MODEL:-claude-opus-5-5}"

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT" || exit 1
mkdir -p logs/scheduler logs/sort-inbox state
RUN_START_UTC="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
STAMP="$(date +%Y-%m-%d_%H%M%S)"
LOG="logs/scheduler/${STAMP}-sort-${MODE}.log"
STATE="state/sort-inbox.json"

export PATH="$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

# Work out the start date (Gmail's after: is inclusive and works on whole days)
if [ "$DAYS" -gt 0 ]; then
  SINCE="$(date -d "-$DAYS days" +%Y/%m/%d)"
else
  SINCE="$(date -d '-7 days' +%Y/%m/%d)"
  if [ -f "$STATE" ]; then
    LAST="$(sed -n 's/.*"last_success_utc"[^"]*"\([^"]*\)".*/\1/p' "$STATE" | head -1)"
    if [ -n "$LAST" ] && LASTDAY="$(date -d "$LAST" +%Y-%m-%d 2>/dev/null)"; then
      SINCE="$(date -d "$LASTDAY -1 day" +%Y/%m/%d)"
    else
      echo "State file unreadable, using 7 days" >>"$LOG.err"
    fi
  fi
  FLOOR="$(date -d '-30 days' +%Y/%m/%d)"
  [[ "$SINCE" < "$FLOOR" ]] && SINCE="$FLOOR"
fi

ARGS="since=$SINCE"
[ "$MODE" = "live" ] && ARGS="live $ARGS"
# Add/remove labels on threads and write its own logs. No create/update/delete label, no send, no trash.
ALLOWED="mcp__claude_ai_Gmail__label_thread,mcp__claude_ai_Gmail__unlabel_thread,Edit(logs/**)"

# Lock shared with the calendar sync so the two never overlap
exec 9>logs/scheduler/.lock
if ! flock -n 9; then echo "$(date -Is) Skipped sort: another job is running" >> logs/scheduler/skipped.log; exit 0; fi

timeout "${TIMEOUT_MIN}m" claude -p "/sort-inbox $ARGS" --allowedTools "$ALLOWED" --max-turns 200 ${MODEL:+--model "$MODEL"} >"$LOG" 2>"$LOG.err"
RC=$?
[ $RC -eq 124 ] && echo "SORT FAILED: timed out after ${TIMEOUT_MIN} minutes" >>"$LOG"
[ -s "$LOG" ] || echo "SORT FAILED: no output (see $LOG.err)" >>"$LOG"

OK=0
[ $RC -ne 124 ] && grep -qE 'SORT (live|dry-run) OK' "$LOG" && OK=1

if [ "$MODE" = "live" ]; then
  # The report is the run's own output, saved here so it can't be skipped
  REPORT="logs/sort-inbox/$(date -d "$RUN_START_UTC" +%Y-%m-%d_%H%M).md"
  { printf '# Inbox sort, %s, live, since %s\n\n' "$(date -d "$RUN_START_UTC" '+%Y-%m-%d %H:%M')" "$SINCE"; cat "$LOG"; } >"$REPORT"
  # Move the window forward only when everything in it was sorted
  if [ $OK -eq 1 ] && ! grep -q 'more remaining' "$LOG"; then
    printf '{ "last_success_utc": "%s" }\n' "$RUN_START_UTC" >"$STATE"
  fi
fi
[ $RC -eq 124 ] && exit 2
[ $OK -eq 1 ] && exit 0 || exit 1
