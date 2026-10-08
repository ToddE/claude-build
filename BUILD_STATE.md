# Build state

This file is how the build resumes. A new session, or an unattended run, reads it first, does the next task, updates it, and commits. Keep the first six lines in this exact form: scripts read them without using a model.

STATUS: ready
NEXT: 0.1
MILESTONE: M0
BLOCKED_REASON:
LAST_RUN:
LAST_COMMIT:

STATUS is one of `ready`, `blocked`, `gate`, `done`. Set `blocked` with a reason when a stop condition in CLAUDE.md applies. Set `gate` at a milestone gate and wait for a person to set it back to `ready`. Unattended runs do nothing unless STATUS is `ready`.

## Rules for updating

1. After each task: set its row to `done`, put the commit id in the row, set NEXT to the next `todo` id, and commit with a message naming the task id.
2. Write one line of notes only if the next task needs to know something that is not in the planning files.
3. Never delete a row. A task that was redone keeps its row, with a note.
4. Decisions the plan did not answer go in section 7 of the decisions log, not here.

## Tasks

| Id | Milestone | Task | Model | Status | Commit | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| 0.1 | M0 | Scaffold the pnpm workspace, TypeScript, lint, format, scripts | Sonnet | todo | | |
| 0.2 | M0 | Wrangler configs for the site and API, D1, R2, service binding | Sonnet | todo | | |
| 0.3 | M0 | Load and validate environment variables | Haiku | todo | | |
| 0.4 | M0 | Apply migrations and load the email and settings seeds | Haiku | todo | | |
| 0.5 | M0 | Settings service (database, then environment, then default, with ranges) | Sonnet | todo | | |
| 0.6 | M0 | Audit log, id, time, and error helpers | Haiku | todo | | |
| 0.7 | M0 | Email provider interface, SMTP2GO adapter, console adapter | Sonnet | todo | | |
| 0.8 | M0 | Crypto service: AES-256-GCM, key ids, rotation, PBKDF2, token hashing | Opus | todo | | |
| 0.9 | M0 | `check-site-rules.mjs` | Sonnet | todo | | |
| 0.10 | M0 | Stub `global.css` with tokens and font faces | Haiku | todo | | |
| 1.1 | M1 | Fetch the IRS W-9, record its revision, list form fields | Haiku | todo | | |
| 1.2 | M1 | Fill, stamp requester and signature, add receipt block, flatten | Opus | todo | | |
| 1.3 | M1 | Encrypt, store in R2, read back, decrypt, compare hash | Opus | todo | | |
| 1.4 | M1 | Render to images, check positions, measure CPU and memory, write the report | Sonnet | todo | | |
| G1 | M1 | Report PDF spike results and wait for review | Opus | todo | | |
| 2.1 | M2 | Password hashing, session tokens, lockout, idle and absolute timeout | Opus | todo | | |
| 2.2 | M2 | Sign-up, verify, resend, sign-in, sign-out, forgot and reset endpoints | Sonnet | todo | | |
| 2.3 | M2 | Rate limits, Turnstile check, breached-password check | Sonnet | todo | | |
| 2.4 | M2 | Full `global.css` for the component inventory, light and dark | Sonnet | todo | | |
| 2.5 | M2 | Base layout, header, footer, notices, cookie notice | Sonnet | todo | | |
| 2.6 | M2 | Content collections, schemas, Screen and Form components | Sonnet | todo | | |
| 2.7 | M2 | Middleware guarding routes, session lookup through the service binding | Opus | todo | | |
| 2.8 | M2 | Copy catalogs and the auth screens | Sonnet | todo | | |
| 2.9 | M2 | Tests for TC-CreateAccount, TC-ResetPassword, TC-SignOut | Sonnet | todo | | |
| 2.10 | M2 | Cookie and header security tests | Sonnet | todo | | |
| 3.1 | M3 | Business and payee endpoints with plan limits | Sonnet | todo | | |
| 3.2 | M3 | Account-scoped data access layer | Opus | todo | | |
| 3.3 | M3 | Request create, resend, cancel, link tokens | Sonnet | todo | | |
| 3.4 | M3 | W-9 submit: validation, TIN checks, one PDF per business, store, complete | Opus | todo | | |
| 3.5 | M3 | Payee link screens: form, review, signature pad | Sonnet | todo | | |
| 3.6 | M3 | Decline, foreign payee, and link problem flows | Sonnet | todo | | |
| 3.7 | M3 | Owner screens: payee list, detail, forms | Sonnet | todo | | |
| 3.8 | M3 | Download with password confirmation and decrypt stream | Opus | todo | | |
| 3.9 | M3 | Owner notice emails and the SMTP2GO bounce webhook | Sonnet | todo | | |
| 3.10 | M3 | Copy for the M3 screens | Sonnet | todo | | |
| 3.11 | M3 | Tests for the M3 test case groups | Sonnet | todo | | |
| 3.12 | M3 | End-to-end flow test | Sonnet | todo | | |
| G3 | M3 | Milestone gate review | Opus | todo | | |
| 4.1 | M4 | Payee accounts, saved profile, reuse, update | Sonnet | todo | | |
| 4.2 | M4 | Reminder job: due, one per day, combine, caps, Reminders ended | Sonnet | todo | | |
| 4.3 | M4 | Reminder schedule API and screen | Sonnet | todo | | |
| 4.4 | M4 | CSV exports for QuickBooks Online, Xero, general | Sonnet | todo | | |
| 4.5 | M4 | Streaming ZIP with per-file decrypt | Opus | todo | | |
| 4.6 | M4 | Stripe checkout, webhook, plan changes, receipt | Opus | todo | | |
| 4.7 | M4 | Cancel account, retention and deletion jobs | Opus | todo | | |
| 4.8 | M4 | Communication preferences and consent log | Haiku | todo | | |
| 4.9 | M4 | Administrator sign-in with a second factor | Opus | todo | | |
| 4.10 | M4 | Configure Platform Settings screens and API | Sonnet | todo | | |
| 4.11 | M4 | Provider key storage and test actions | Opus | todo | | |
| 4.12 | M4 | Email message editing with placeholder checks | Sonnet | todo | | |
| 4.13 | M4 | D1 backups to R2 and a restore test | Sonnet | todo | | |
| 4.14 | M4 | Copy for the beta screens | Sonnet | todo | | |
| G4 | M4 | Milestone gate review | Opus | todo | | |
| 5.1 | M5 | Payee-sent endpoint, send caps, pause rules | Sonnet | todo | | |
| 5.2 | M5 | Share link one-time code, bearer token, download caps | Opus | todo | | |
| 5.3 | M5 | Opt-out and unsubscribe | Sonnet | todo | | |
| 5.4 | M5 | Save payee-sent W-9 to account, with a pending save for upgrades | Sonnet | todo | | |
| 5.5 | M5 | Review Abuse Flags API and screens | Sonnet | todo | | |
| 5.6 | M5 | View Sent W-9s | Sonnet | todo | | |
| 5.7 | M5 | Public pages, Umami, sitemap, robots rules | Sonnet | todo | | |
| 5.8 | M5 | Content Security Policy, headers, log scrubbing check | Opus | todo | | |
| 5.9 | M5 | Accessibility and performance pass | Sonnet | todo | | |
| 5.10 | M5 | Email client testing and fixes | Sonnet | todo | | |
| 5.11 | M5 | Runbook: deploy, rollback, rotation, restore | Sonnet | todo | | |
| 5.12 | M5 | Launch copy for the remaining screens | Sonnet | todo | | |
| G5 | M5 | Milestone gate review | Opus | todo | | |
