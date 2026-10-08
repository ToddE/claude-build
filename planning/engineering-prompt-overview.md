*inform9 engineering prompt. Draft 3. Version 2026-10-08 15:46 ET. Replaces the earlier versions.*

Act as an expert staff engineer for Cloudflare Workers, Astro, TypeScript, and the secure handling of sensitive tax data.

Build inform9.com from the planning files in this folder. They are complete enough to build without further questions. Read [README.md](README.md) first, then work through the build plan.

## Order

1. [build-plan-2026-10-08-1546.md](build-plan-2026-10-08-1546.md): tools, structure, milestones M0 to M5, the checks for each, and when to stop.
2. [decisions-log-2026-10-08-1545.md](decisions-log-2026-10-08-1545.md): every decision, the adopted defaults, and every placeholder resolved to a setting.
3. [ArchitectureGuidelines.md](ArchitectureGuidelines.md): platform, security, cookies, email, scheduled work.
4. [schema-2026-10-08-1352.sql](schema-2026-10-08-1352.sql) and [data-model-2026-10-08-1352.md](data-model-2026-10-08-1352.md): tables, status rules, settings.
5. [api-spec-2026-10-08-1522.md](api-spec-2026-10-08-1522.md): endpoints, errors, rate limits.
6. [use-cases.md](use-cases.md), [functional-requirements.md](functional-requirements.md), [test-cases.md](test-cases.md): the behavior to build and the tests to pass. Edit requirements only in this file.
7. [site-content-and-style-rules-2026-10-08-1543.md](site-content-and-style-rules-2026-10-08-1543.md) and [copy-drafting-instructions-2026-10-08-1544.md](copy-drafting-instructions-2026-10-08-1544.md): all copy in Markdown, one global stylesheet.
8. [brand/](brand/) and [email/](email/): brand assets, tokens, and the email system.
9. [credentials-checklist-2026-10-08-1542.md](credentials-checklist-2026-10-08-1542.md) and `../.env.example`: what is needed from Todd and when.
10. [model-routing-2026-10-08-1555.md](model-routing-2026-10-08-1555.md): which model does each task.
11. [screen-inventory-2026-10-08-1254.md](screen-inventory-2026-10-08-1254.md) and [pr-faq.md](pr-faq.md): screens and product intent.

## Rules and stops

The rules, the stop conditions, and the model split are in [../CLAUDE.md](../CLAUDE.md), which Claude Code loads at the start of every session. They are kept in that one file so they cannot drift. Model assignments by task are in [model-routing-2026-10-08-1555.md](model-routing-2026-10-08-1555.md).

## First action

Read `../BUILD_STATE.md` and do the task it names as NEXT. On a fresh project that is task 0.1 in M0. Report at the M1 gate (the PDF spike) and at the M3 and M4 gates. Between gates, keep going.
