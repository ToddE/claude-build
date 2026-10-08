# Plan: linkcheck

Example plan for claude-build. It describes a small command-line link checker. The matching task table is BUILD_STATE.md in this folder. Run `claude-build --init PLAN.md` to have a model draft a table like it, then review the result.

What makes this plan easy to turn into a table:
- Each task names what to read and a check that proves it is done.
- Difficulty (mechanical, standard, hard) maps to a model: haiku, sonnet, opus.
- Each milestone ends with a review gate that says what a person should look at.
- Open decisions are listed in section 5, so the model does not have to guess.

## 1. Goal and scope

`linkcheck` reads Markdown files and reports links that do not resolve. It runs from the command line and in CI.

In scope: inline, reference, and autolinks; HTTP and HTTPS; relative links to files; a text and a JSON report; exit code 1 when a link is broken.
Out of scope: crawling a site, checking anchors inside pages, authentication.

Done when `npm test` passes and `linkcheck docs/` reports the links in this repository correctly.

## 2. Conventions

- Node 20, no runtime dependencies beyond `undici` for HTTP.
- Layout: `src/` code, `test/` tests, `docs/` documents.
- Commands: `npm test` (all tests), `npm run lint` (lint and format check), `npm run build` (compile).
- Every change keeps `npm test` and `npm run lint` passing.
- Style rules are in `docs/style.md`.

## 3. Document map

| Path | Covers |
| --- | --- |
| docs/style.md | Code style and naming |
| docs/design.md | Module interfaces and the concurrency model. Written in task 1.4 |
| docs/use-cases.md | Use cases UC-1 to UC-4, with the behavior each CLI option must have |
| docs/test-cases.md | Test cases TC-1 to TC-12, each tied to a use case |

## 4. Milestones

### M1 Scaffold

Outcome: an empty project that installs, lints, tests, and runs in CI.

| Task | Read | Done when | Difficulty |
| --- | --- | --- | --- |
| Create the package layout from section 2 | section 2 | `npm test` runs and reports zero tests | mechanical |
| Add lint and format config | docs/style.md | `npm run lint` passes | mechanical |
| Add a CI workflow that runs lint and test | section 2 | `.github/workflows/ci.yml` exists and runs both commands | standard |

Review gate: none.

### M2 Core

Outcome: the checker works as a library, with tests, covering UC-1 and UC-2.

| Task | Read | Done when | Difficulty |
| --- | --- | --- | --- |
| Design the link-checker module interface | docs/use-cases.md UC-1, UC-2 | `docs/design.md` exists and lists every exported function with its types | hard |
| Implement URL extraction from Markdown | docs/design.md, TC-1 to TC-4 | tests for inline, reference, and autolinks pass | standard |
| Implement the HTTP checker with retries and a per-host rate limit | docs/design.md, TC-5 to TC-8 | tests against a local test server pass | standard |
| Fix the race when the same host is checked concurrently | test/race.test.js | that test passes 20 times in a row | hard |

Review gate: a person reads `docs/design.md` and the core module and confirms the interfaces match the use cases.

### M3 CLI and documentation

Outcome: the command-line interface exists and is documented, covering UC-3 and UC-4.

| Task | Read | Done when | Difficulty |
| --- | --- | --- | --- |
| Add the command-line interface | docs/use-cases.md UC-3, UC-4, TC-9 to TC-12 | `linkcheck --help` text matches UC-3 and the CLI tests pass | standard |
| Write README usage examples | the CLI | each example was run and its real output pasted | mechanical |
| Fix typos and wording in README.md and docs/ | README.md, docs/ | no code changed; `npm test` still passes | mechanical |

Review gate: none. The build is done when this milestone is.

## 5. Risks and open decisions

- Some sites block automated requests. Decision: treat HTTP 403 and 429 as "unverified", not broken, and report them separately.
- Retries and rate limits can hide a real outage. Decision: three retries, then report broken.
- The JSON report format is not final. A person decides it at the M2 review gate, before M3 starts.
