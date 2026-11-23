#!/usr/bin/env bash
# Runs the morning brief headlessly with Claude Code (Raspberry Pi / Linux). Dom approved this on 2026-11-23.
# Usage:  scripts/run-morning-brief.sh [live|dry-run]
# Cron: last on the 07:00 line, after the calendar sync and the sort, e.g.
#   0 7 * * *   PULL=1 .../run-calendar-sync.sh live; .../run-sort-inbox.sh live; .../run-morning-brief.sh live
#
# live:    writes reply drafts (never sends them) and emails the brief to Dom's own address only.
# dry-run: prints the brief and the drafts it would write; changes nothing.
# Sending is limited twice: --disallowedTools removes reply and forward, and .claude/hooks/send_guard.py
# (INBOX_SORTER_JOB=morning-brief) blocks any send_message that isn't to Dom alone.
set -uo pipefail
MODE="${1:-live}"
TIMEOUT_MIN="${TIMEOUT_MIN:-20}"
MODEL="${MODEL:-claude-opus-5-5}"

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT" || exit 1
mkdir -p logs/scheduler logs/morning-brief
STAMP="$(date +%Y-%m-%d_%H%M%S)"
LOG="logs/scheduler/${STAMP}-brief-${MODE}.log"

export PATH="$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin:$PATH"
export INBOX_SORTER_JOB=morning-brief

ARGS="$MODE"
if [ "$MODE" = "live" ]; then
  # Drafts and the one email to Dom, plus its own logs. No labels, no calendar writes, no reply or forward.
  ALLOWED="mcp__claude_ai_Gmail__create_draft,mcp__claude_ai_Gmail__send_message,Edit(logs/**)"
else
  ALLOWED="Edit(logs/**)"
fi
NO_SEND="mcp__claude_ai_Gmail__reply,mcp__claude_ai_Gmail__forward,mcp__claude_ai_Gmail__update_draft,mcp__claude_ai_Gmail__delete_draft"
[ "$MODE" = "live" ] || NO_SEND="$NO_SEND,mcp__claude_ai_Gmail__send_message,mcp__claude_ai_Gmail__create_draft"

exec 9>logs/scheduler/.lock
if ! flock -n 9; then echo "$(date -Is) Skipped brief: another job is running" >> logs/scheduler/skipped.log; exit 0; fi

timeout "${TIMEOUT_MIN}m" claude -p "/morning-brief $ARGS" --allowedTools "$ALLOWED" --disallowedTools "$NO_SEND" --max-turns 120 ${MODEL:+--model "$MODEL"} >"$LOG" 2>"$LOG.err"
RC=$?
[ $RC -eq 124 ] && echo "BRIEF FAILED: timed out after ${TIMEOUT_MIN} minutes" >>"$LOG"
[ -s "$LOG" ] || echo "BRIEF FAILED: no output (see $LOG.err)" >>"$LOG"
cp "$LOG" "logs/morning-brief/$(date +%Y-%m-%d_%H%M)-${MODE}.md"
[ $RC -eq 124 ] && exit 2
grep -qE 'BRIEF (live|dry-run) OK' "$LOG" && exit 0 || exit 1
