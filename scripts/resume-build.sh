#!/usr/bin/env bash
# Unattended resume for the inform9 build. Uses no model unless there is work to do.
# Run it from cron or a systemd timer. See planning/unattended-build.md.
set -u
cd "$(dirname "$0")/.."
mkdir -p .build
LOG=.build/resume.log
LOCK=.build/resume.lock
BACKOFF=.build/backoff_until
now=$(date +%s)

# 1. Zero-token checks: state, lock, backoff
status=$(grep -m1 '^STATUS:' BUILD_STATE.md | sed 's/^STATUS: *//')
if [ "$status" != "ready" ]; then echo "$(date -Is) skip: STATUS=$status" >> "$LOG"; exit 0; fi
if [ -f "$BACKOFF" ] && [ "$now" -lt "$(cat "$BACKOFF")" ]; then echo "$(date -Is) skip: backing off" >> "$LOG"; exit 0; fi
if [ -f "$LOCK" ] && kill -0 "$(cat "$LOCK")" 2>/dev/null; then echo "$(date -Is) skip: already running" >> "$LOG"; exit 0; fi
echo $$ > "$LOCK"; trap 'rm -f "$LOCK"' EXIT
if [ ! -d .git ]; then echo "$(date -Is) stop: run git init first so each task is checkpointed" >> "$LOG"; exit 1; fi

# 2. One bounded run. Fresh context each time: it reads only CLAUDE.md and BUILD_STATE.md.
PROMPT='Read CLAUDE.md and BUILD_STATE.md. Continue the build at the NEXT task. Do up to 5 tasks, or stop earlier at a gate or a stop condition. After each task, update BUILD_STATE.md and commit. If a stop condition applies, set STATUS to blocked with the reason and stop. Do not deploy and do not push.'
timeout 3h claude -p "$PROMPT" \
  --model sonnet \
  --permission-mode acceptEdits \
  --allowedTools "Read" "Edit" "Write" "Glob" "Grep" "Agent" \
    "Bash(pnpm:*)" "Bash(node:*)" "Bash(python3:*)" "Bash(npx:*)" "Bash(ls:*)" "Bash(cat:*)" "Bash(mkdir:*)" \
    "Bash(git status:*)" "Bash(git diff:*)" "Bash(git add:*)" "Bash(git commit:*)" "Bash(git log:*)" \
    "Bash(wrangler dev:*)" "Bash(wrangler d1 execute:*)" \
  --output-format text >> "$LOG" 2>&1
code=$?

# 3. Back off after a failure, such as a usage limit: 1h, 2h, 4h, then 6h
if [ $code -ne 0 ]; then
  n=$(( $(cat .build/failures 2>/dev/null || echo 0) + 1 )); echo $n > .build/failures
  wait=$(( n==1 ? 3600 : n==2 ? 7200 : n==3 ? 14400 : 21600 ))
  echo $(( $(date +%s) + wait )) > "$BACKOFF"
  echo "$(date -Is) run failed (code $code), backing off ${wait}s" >> "$LOG"
else
  rm -f .build/failures "$BACKOFF"
  echo "$(date -Is) run finished" >> "$LOG"
fi
exit $code
