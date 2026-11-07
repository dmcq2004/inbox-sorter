# Backlog clean-up (phase 5, not started)

One-off job: apply the proven rules in `config/` to the ~19.5k older inbox threads.

Don't start until `/sort-inbox` has run live without corrections for about 2 weeks.

Approach, when started:
- Work sender by sender, starting with the highest-volume senders in `config/sender-rules.yaml`, using queries like `in:inbox older_than:2d from:<match>`.
- Dry run one batch of 50, show it to Dom, then run live for that sender.
- Log every batch to `logs/runs/`. Never trash anything; archiving only.
