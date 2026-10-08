# inform9

First read `BUILD_STATE.md`. It says which task is next. After each task, update it and commit. Set `STATUS: blocked` with a reason at a stop condition, or `STATUS: gate` at a milestone gate. Details: `planning/unattended-build-*.md`.

Build inform9.com from the planning files. Start with `planning/engineering-prompt-overview.md` (reading order and first action), then `planning/build-plan-*.md`. Planning files describe the product; the code goes in `apps/` and `packages/` at this root.

## Rules

1. Use Web Standards APIs in Workers only. No Node.js core modules at runtime.
2. One account holds one or more businesses, and one email address has one account. Filter every Business Owner query by account.
3. Use `crypto.subtle` for AES-256-GCM and PBKDF2-SHA256. Never store a taxpayer ID, password, or token in plain text. Never log, return, or display one.
4. The platform sets one cookie, the sign-in session, after sign-in only. No local storage for sign-in.
5. No words and no styles in `.astro` files. Copy, links, and image paths live in `src/content/`. Styles live in `src/styles/global.css`.
6. Stream ZIP exports. Never build an archive in memory.
7. Settings come from the `settings` table, then the environment, then the default. Code holds no literal limit.
8. Requirements are edited only in `planning/functional-requirements.md`. Each test case in `planning/test-cases.md` becomes one automated test with the same id.
9. Do not ask about anything `planning/decisions-log-*.md` answers. For anything it does not, pick the safer and simpler option and add a row to section 7 of the log.
10. Write copy only as the copy instructions describe.

## Stop only for

- A credential or DNS record from `planning/credentials-checklist-*.md` (name it, then continue with a mock).
- Legal or security text assigned to a person (draft it with a `[CONFIRM]` or `[LEGAL REVIEW]` marker and continue).
- A test that still fails after three fix attempts.
- A change that would weaken a security rule in `planning/ArchitectureGuidelines.md`.
- A milestone gate in the build plan.

## Which model does what

See `planning/model-routing-*.md`. Choose the right model once; do not start low and redo on a higher one.
- Opus (`security`, `gate-reviewer`): security-critical code and all gate reviews.
- Sonnet (`builder`, `copywriter`): features, Astro screens, jobs, tests, copy, documents. The main session runs on Sonnet.
- Haiku (`mechanic`): scripted work that one command fully verifies.
- When two fit, take the higher model.
- Effort level follows the same rule: low for scripted work, medium for spec-built work, high for security and design, xhigh only for the overrides in the routing table.

## Token discipline

- Read only what the task needs. Search planning files by requirement id or heading. Do not open whole files.
- Run the narrowest check first. Run full suites at gates.
- Edit lines. Do not rewrite files.
- If a task fails twice, hand a short diagnosis to Opus. Do not restart the task on another model.
