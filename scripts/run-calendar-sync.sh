#!/usr/bin/env bash
# Runs the hands-off school calendar sync headlessly with Claude Code (Raspberry Pi / Linux).
# Usage:  scripts/run-calendar-sync.sh [live|dry-run] [days]
# Cron example (07:00 and 17:30 every day):
#   0 7 * * *   /home/pi/Emails/scripts/run-calendar-sync.sh live
#   30 17 * * * /home/pi/Emails/scripts/run-calendar-sync.sh live
set -uo pipefail
MODE="${1:-live}"
DAYS="${2:-0}"
TIMEOUT_MIN="${TIMEOUT_MIN:-30}"

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT" || exit 1
mkdir -p logs/scheduler logs/calendar-sync school/state
STAMP="$(date +%Y-%m-%d_%H%M)"
LOG="logs/scheduler/${STAMP}-${MODE}.log"

# cron has a minimal PATH; claude's native installer puts it in ~/.local/bin
export PATH="$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

# Optional: pull the latest rules from GitHub before running (set PULL=1 in the cron line)
if [ "${PULL:-0}" = "1" ]; then git pull --ff-only >>"$LOG" 2>&1 || echo "git pull failed, using local copy" >>"$LOG"; fi

ARGS="$MODE"
[ "$DAYS" != "0" ] && ARGS="$ARGS days=$DAYS"
ALLOWED="mcp__claude_ai_Google_Calendar__create_event,mcp__claude_ai_Google_Calendar__update_event,Edit(school/state/**),Edit(school/newsletters/**),Edit(school/newsletters.md),Edit(logs/**)"

exec 9>logs/scheduler/.lock
if ! flock -n 9; then echo "$(date -Is) Skipped: another sync is running" >> logs/scheduler/skipped.log; exit 0; fi

timeout "${TIMEOUT_MIN}m" claude -p "/school-calendar-sync $ARGS" --allowedTools "$ALLOWED" --max-turns 120 >"$LOG" 2>"$LOG.err"
RC=$?
[ $RC -eq 124 ] && echo "SYNC FAILED: timed out after ${TIMEOUT_MIN} minutes" >>"$LOG"
grep -qE 'SYNC (live|dry-run) OK' "$LOG" && exit 0 || exit 1
