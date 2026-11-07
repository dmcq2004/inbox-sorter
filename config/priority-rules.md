# Priority rules (Triage/*)

Use these when no sender rule decides the priority.

| Label | Meaning | Examples | Archive? |
|---|---|---|---|
| `Triage/Action` | Dom must do something soon (≤7 days): pay, sign, reply, book, attend | bill due, form deadline, a person asking Dom a direct question | No |
| `Triage/NeedsDom` | A real person or important account wants his attention, with no hard deadline yet | personal email, family threads, account or security changes, tax, data-breach notices | No |
| `Triage/FYI` | Worth knowing but needs nothing from him | order and delivery updates, statements ready, receipts, app notifications | Yes |
| `Triage/Bulk` | Marketing, newsletters, promotions, surveys, "rate us" | retail promos, Christie's marketing, Latent Space, LinkedIn group digests | Yes |

## Tie-breakers
- A real person writing to Dom directly (not a no-reply sender): at least `NeedsDom`.
- Rosemarie (`rosemarie.little.rl@gmail.com`): at least `NeedsDom`. If it's about school, the school module handles it.
- Security alerts, unexpected sign-ins, data breaches: `NeedsDom`. Routine sign-ins Dom triggered himself (e.g. "You allowed Claude access"): `FYI`.
- Money leaving an account or a payment due: `Action`.
- Gmail's `CATEGORY_PROMOTIONS` is a strong hint for `Bulk`, but it is not decisive.
- If unsure, pick the higher priority and don't archive.
