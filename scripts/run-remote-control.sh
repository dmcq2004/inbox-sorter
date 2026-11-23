#!/usr/bin/env bash
# Always-on Remote Control on the Pi, so Dom can use /inbox from the Claude app or claude.ai/code (2026-11-23).
# Started by scripts/inbox-remote.service inside tmux session "inbox-remote" (attach: tmux attach -t inbox-remote).
# Permission mode is forced to "default", so sends, replies and forwards still ask Dom in the app
# (settings.json "ask" rules), and the send guard treats these as interactive sessions (INBOX_SORTER_JOB unset).
set -euo pipefail
export PATH="$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin:$PATH"
unset INBOX_SORTER_JOB
cd "$HOME/Emails"
exec claude remote-control --name "Inbox (Pi)" --permission-mode default --spawn same-dir
