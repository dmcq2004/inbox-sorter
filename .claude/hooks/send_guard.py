"""PreToolUse guard for Gmail send, reply and forward (Dom approved sending on 2026-11-23).

Claude Code runs this before every mcp__claude_ai_Gmail__send_message / reply / forward call.
Exit 2 blocks the call, and Claude Code shows the message on stderr to Claude.

- Interactive sessions (INBOX_SORTER_JOB not set): the hook returns permissionDecision "ask", so Claude Code
  asks Dom to confirm every send, reply and forward, even in auto mode. This replaces the old `ask` rule for
  send_message in settings.json (2026-11-24). That rule also applied to headless runs, where nobody can answer,
  so it blocked the morning brief.
- The morning brief job (INBOX_SORTER_JOB=morning-brief): send_message only, to Dom's own address only,
  with no cc, bcc or attachments. Anything else is blocked. A send that passes the checks is allowed.
- Any other scheduled job (sort, calendar sync): always blocked.

It fails closed: the settings run it as `python3 ... || exit 2`, so a crash also blocks the send.
"""
import json
import os
import sys

OWN_ADDRESS = "dmcq2004@gmail.com"


def block(reason: str) -> None:
    print(f"Blocked by .claude/hooks/send_guard.py: {reason}", file=sys.stderr)
    sys.exit(2)


def addresses(value) -> list:
    if not value:
        return []
    if isinstance(value, str):
        value = [value]
    return [str(a).strip().lower() for a in value if str(a).strip()]


def decide(decision: str, reason: str) -> None:
    print(json.dumps({"hookSpecificOutput": {
        "hookEventName": "PreToolUse",
        "permissionDecision": decision,
        "permissionDecisionReason": reason,
    }}))
    sys.exit(0)


def main() -> None:
    event = json.load(sys.stdin)
    tool = event.get("tool_name", "")
    args = event.get("tool_input", {}) or {}
    job = os.environ.get("INBOX_SORTER_JOB", "").strip()

    if not job:
        decide("ask", "Sending email: Dom confirms every send, reply and forward (send_guard.py)")

    if job != "morning-brief":
        block(f"scheduled job '{job}' may never send, reply or forward")

    if not tool.endswith("__send_message"):
        block("the morning brief may only use send_message")
    # With draftId, send_message sends that draft as written and ignores `to`, so it could reach anyone.
    if args.get("draftId"):
        block("the morning brief may not send a draft")
    if args.get("replyThreadId") or args.get("replyToMessageId"):
        block("the morning brief must be a new email, not a reply in a thread")
    if addresses(args.get("to")) != [OWN_ADDRESS]:
        block(f"the morning brief may only be sent to {OWN_ADDRESS}")
    if addresses(args.get("cc")) or addresses(args.get("bcc")):
        block("the morning brief may not have cc or bcc")
    if args.get("attachments"):
        block("the morning brief may not have attachments")
    decide("allow", f"morning brief to {OWN_ADDRESS} only (send_guard.py)")


if __name__ == "__main__":
    main()
