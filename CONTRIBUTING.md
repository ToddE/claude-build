# Contributing to claude-build

Thank you for helping. Bug reports, fixes, documentation, and ideas are all welcome. The open work is listed in [TODO.md](TODO.md). macOS support is the largest item.

## Before you start

For anything larger than a small fix, open an issue first and describe what you want to change. That avoids work on a change that does not fit.

## What the project is

claude-build is one bash script (`claude-build.sh`) plus an installer (`install.sh`), a manual (`README.md`), and examples. The script supervises Claude Code. It has no dependencies beyond standard tools, and that is a design goal. Please do not add a runtime dependency without discussing it.

## Testing without spending tokens

Do not test with a real `claude` session. Point `CLAUDE_BIN` at a stand-in script that edits the state file the way a run would. README section 11 explains how. A minimal setup:

```bash
mkdir /tmp/cb-test && cd /tmp/cb-test && git init
cp /path/to/claude-build/examples/BUILD_STATE.md .
printf 'CLAUDE_BIN="/path/to/fake-claude.sh"\nPROJECT_DIR="/tmp/cb-test"\n' > test.conf
chmod 600 test.conf
/path/to/claude-build.sh -c test.conf          # preview, starts nothing
/path/to/claude-build.sh -c test.conf -o       # one cycle with the stand-in
```

Before you send a change:

- `bash -n claude-build.sh` and `bash -n install.sh` pass. Run `shellcheck` too if you have it.
- A preview (no `-r`) still starts nothing.
- Say how you tested. If you could only test on one operating system, say which.

## Code style

- Match the surrounding code: naming, comment density, and layout.
- Keep the safety rules: nothing starts without `-r`, `-b`, or `-o`, and a run may only use the tools on `ALLOWED_TOOLS`.
- The script must not use the network, except in `--check-update` and `--update`.
- Add or update the help text (`-h`) and the README when you change a flag.

## Documentation style

Write plainly and directly. Define terms the first time you use them. Avoid hype and filler.

## Pull requests

- One change per pull request, with a short description of what changed and why.
- Keep the copyright notices in the source files.
- By sending a pull request you agree that your contribution is licensed under the Apache License 2.0, the same as the project (Apache-2.0, section 5). There is no separate agreement to sign.

## Reporting a bug

Include the output of `claude-build --version`, your operating system, `bash --version`, the command you ran, and the output of the preview (the same command without `-r`). Remove anything private first. The log can contain project details, so check it before you paste it.

## Security

If you find a problem that could let someone run commands or leak secrets, do not open a public issue. Use "Report a vulnerability" on the repository's Security tab (GitHub private vulnerability reporting). Turn that on in the repository settings before the first release.
