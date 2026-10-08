# inform9 planning folder

Start with [engineering-prompt-overview.md](engineering-prompt-overview.md). Files marked "source" are the ones to edit. Dated files are the latest version of their kind.

| Group | File | What it is |
| --- | --- | --- |
| Product | [pr-faq.md](pr-faq.md) | Press release, external and internal FAQ. Source of product claims |
| Behavior | [use-cases.md](use-cases.md) | 30 use cases (source) |
| | [functional-requirements.md](functional-requirements.md) | 355 requirements (source) |
| | [test-cases.md](test-cases.md) | 151 test cases (source) |
| | `tools/requirements_md_to_csv.py` | Writes a Jira-import CSV from the requirements file when one is needed. The CSV is not kept |
| Decisions | [decisions-log-2026-10-08-1545.md](decisions-log-2026-10-08-1545.md) | Every decision, adopted defaults, placeholders resolved to settings |
| Technical | [ArchitectureGuidelines.md](ArchitectureGuidelines.md) | Platform, security, cookies, email, jobs |
| | [schema-2026-10-08-1352.sql](schema-2026-10-08-1352.sql) | D1 schema (31 tables) |
| | [data-model-2026-10-08-1352.md](data-model-2026-10-08-1352.md) | Status rules, enforced rules, settings, email templates |
| | [api-spec-2026-10-08-1522.md](api-spec-2026-10-08-1522.md) | Endpoints, errors, rate limits, jobs |
| Build | [build-plan-2026-10-08-1546.md](build-plan-2026-10-08-1546.md) | Structure, milestones, checks, stop rules |
| | [model-routing-2026-10-08-1555.md](model-routing-2026-10-08-1555.md) | Which model does each task, and the agents in `../.claude/agents/` |
| | [unattended-build-2026-10-08-1603.md](unattended-build-2026-10-08-1603.md) | How the build resumes without you, the runner script, and its limits |
| | [credentials-checklist-2026-10-08-1542.md](credentials-checklist-2026-10-08-1542.md) | Accounts, keys, DNS, and who does what |
| | `../.env.example`, `../.env.local` | Environment variables (the second is private and ignored by git) |
| Site | [site-content-and-style-rules-2026-10-08-1543.md](site-content-and-style-rules-2026-10-08-1543.md) | Content in Markdown, one global stylesheet, enforcement checks |
| | [copy-drafting-instructions-2026-10-08-1544.md](copy-drafting-instructions-2026-10-08-1544.md) | How Claude drafts all screen copy |
| | [screen-inventory-2026-10-08-1254.md](screen-inventory-2026-10-08-1254.md) | 54 screens and 20 emails, mapped to use cases |
| Brand | [brand/](brand/) | Logo, mark, favicon (SVG), tokens.css, brand guide |
| Email | [email/](email/) | Layout, stylesheet, 22 messages, renderer, checks |
| History | `../archive/` | Superseded files: the first architecture, the first planning review, and the settings questionnaire |
