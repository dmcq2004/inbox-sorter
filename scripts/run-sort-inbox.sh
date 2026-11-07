#!/usr/bin/env bash
# Runs the general inbox sorter headlessly with Claude Code (Raspberry Pi / Linux).
# Usage:  scripts/run-sort-inbox.sh [live|dry-run] [days]
# Cron: run it straight after the calendar sync on the same line, e.g.
#   0 7 * * *   PULL=1 /home/pi/Emails/scripts/run-calendar-sync.sh live; /home/pi/Emails/scripts/run-sort-inbox.sh live
set -uo pipefail
MODE="${1:-live}"
DAYS="${2:-2}"
TIMEOUT_MIN="${TIMEOUT_MIN:-30}"
MODEL="${MODEL:-claude-opus-5-5}"

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT" || exit 1
mkdir -p logs/scheduler logs/sort-inbox
STAMP="$(date +%Y-%m-%d_%H%M%S)"
LOG="logs/scheduler/${STAMP}-sort-${MODE}.log"

export PATH="$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

ARGS="days=$DAYS"
[ "$MODE" = "live" ] && ARGS="live $ARGS"
# Add/remove labels on threads and write its own logs. No create/update/delete label, no send, no trash.
ALLOWED="mcp__claude_ai_Gmail__label_thread,mcp__claude_ai_Gmail__unlabel_thread,Edit(logs/**)"

# Lock shared with the calendar sync so the two never overlap
exec 9>logs/scheduler/.lock
if ! flock -n 9; then echo "$(date -Is) Skipped sort: another job is running" >> logs/scheduler/skipped.log; exit 0; fi

timeout "${TIMEOUT_MIN}m" claude -p "/sort-inbox $ARGS" --allowedTools "$ALLOWED" --max-turns 200 ${MODEL:+--model "$MODEL"} >"$LOG" 2>"$LOG.err"
RC=$?
[ $RC -eq 124 ] && echo "SORT FAILED: timed out after ${TIMEOUT_MIN} minutes" >>"$LOG"
grep -qE 'SORT (live|dry-run) OK' "$LOG" && exit 0 || exit 1
