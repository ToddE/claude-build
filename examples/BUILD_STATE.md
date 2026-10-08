# Build state

<!--
Example state file for claude-build. It is the task table for the plan in PLAN.md in this
folder. Copy it into your project as BUILD_STATE.md and replace the rows with your own tasks. The script reads STATUS, NEXT, and the task table.
Everything else, including this comment, is for people.

How to read the table
  Id      Unique. Tasks run in table order, starting at NEXT.
  Task    What to do and what "done" looks like. The model gets only this row, the files
          listed in CONTEXT_FILES (or -i), and the repository. Say which file to read
          (for example "see PLAN.md, section 4") and how to check the result
          (for example "npm test passes").
  Model   sonnet, opus, or haiku. The script starts the run with this model. Leave it
          empty to use MODEL from the config.
  Effort  low, medium, high, xhigh, or max. Leave it empty to use the model's default
          from EFFORT_DEFAULTS (opus=high, sonnet=medium, haiku=low).
  Status  todo, doing, or done.
  Notes   Written by a run. A run that fails a task twice writes a diagnosis here, sets
          Model to Opus and Effort to high, and leaves the task todo.

Why the Model column is useful
  Rows 1.1 to 1.3 all name sonnet, so one run does all three. Row 1.4 names opus, so the
  run stops after 1.3 and the script starts a new run on opus. Group same-model tasks
  together to keep the number of start-ups low.

Gates
  Row 1.8 is a review point. When a run reaches a task that says GATE, it marks the row
  done, sets STATUS to gate, and stops. The build waits until you read the work and set
  STATUS back to ready. See "A gate in practice" in the README.
-->

STATUS: ready
NEXT: 1.1
BLOCKED_REASON:

| Id | Milestone | Task | Model | Effort | Status | Commit | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1.1 | M1 Scaffold | Create the package layout from PLAN.md section 2. `npm test` runs and reports zero tests | haiku | | todo | | |
| 1.2 | M1 Scaffold | Add lint and format config from docs/style.md (PLAN.md section 2). `npm run lint` passes | haiku | | todo | | |
| 1.3 | M1 Scaffold | Add a CI workflow that runs lint and test (PLAN.md section 2, M1). Done when .github/workflows/ci.yml exists and runs both | sonnet | | todo | | |
| 1.4 | M2 Core | Design the link-checker module interface from docs/use-cases.md UC-1 and UC-2. Write the types and a design note in docs/design.md that lists every exported function. No implementation yet | opus | high | todo | | |
| 1.5 | M2 Core | Implement URL extraction from Markdown to match docs/design.md. Unit tests for inline, reference, and autolinks | sonnet | | todo | | |
| 1.6 | M2 Core | Implement the HTTP checker with retries and a per-host rate limit. Unit tests use a local test server | sonnet | medium | todo | | |
| 1.7 | M2 Core | Find and fix the race in concurrent checks of the same host (see the failing test in test/race.test.js) | opus | xhigh | todo | | |
| 1.8 | Review | GATE. Stop after 1.7 for a human review of docs/design.md and the core module | | | todo | | |
| 2.1 | M3 CLI | Add the command-line interface (PLAN.md M3; docs/use-cases.md UC-3, UC-4). `--help` text matches UC-3 and the CLI tests pass | sonnet | | todo | | |
| 2.2 | M3 CLI | Write README usage examples. Run each example and paste the real output | sonnet | low | todo | | |
| 2.3 | M3 CLI | Fix typos and wording in README.md and docs/. Do not change code | haiku | | todo | | |
