*inform9 unattended build. Draft 1. Version 2026-10-08 16:03 ET. How the build keeps going without you, and what it costs.*

# Unattended Build

## 1. Two different limits

| Limit | What happens | Resume |
| --- | --- | --- |
| **Context window** (the conversation gets long) | Claude Code summarizes older turns and keeps working. Nothing stops | Automatic |
| **Usage limit** (your plan's session or weekly allowance runs out) | The session stops until the limit resets. Nothing inside the chat can restart it | A new run, started later, from files |

I cannot see your plan's limit or its reset time from here, and I have not tested what a headless run prints when the limit is hit. The script treats any failed run the same way: wait, then try again.

## 2. The design: state on disk, not in the conversation

A conversation holds the history, and rereading it is expensive. The build avoids that.

- `BUILD_STATE.md` at the project root lists every task with its status, and starts with six machine-readable lines (`STATUS`, `NEXT`, and so on).
- Each task ends with an update to that file and a git commit. A new run needs only `CLAUDE.md` and `BUILD_STATE.md` to know where to continue. It reads no history.
- Each run does up to five tasks and exits. Every run starts with a small, fresh context, so a limit hit or a crash loses at most one task.

## 3. The unattended runner

`scripts/resume-build.sh` decides in plain shell, with no model, whether to do anything:

| Check | Result |
| --- | --- |
| `STATUS` is not `ready` (blocked, at a gate, or done) | Exits. Uses no tokens |
| A run is already going | Exits |
| A backoff is active after a failure | Exits |
| This folder is not a git repository | Stops with a message |
| None of the above | Starts one bounded run on Sonnet |

After a failed run, such as a usage limit, it waits 1 hour, then 2, 4, and 6 hours between tries. A good run clears the wait. The log is `.build/resume.log`.

### What an unattended run may do

It can read and edit files, run `pnpm`, `node`, `python3`, and `npx`, use local `wrangler dev` and local database commands, and make git commits. It cannot deploy, push, delete directories, or run any command outside that list. It stops for the reasons in `CLAUDE.md` by setting `STATUS: blocked` with a reason. It also stops at each milestone gate by setting `STATUS: gate`.

Deploys stay a person's action. The credentials in the real Cloudflare, Stripe, and SMTP2GO accounts are never needed by an unattended run, since local development uses mocks.

## 3a. Turning it on

You decide when. Nothing is installed yet.

1. In this folder, run `git init` and make a first commit, so each task is checkpointed. (I have not run `git init` for you.)
2. Add a schedule that runs the script, for example every 30 minutes through cron:
   ```
   */30 * * * * /home/emerson/Workspace/inform9/scripts/resume-build.sh
   ```
   Most runs will exit at once, using no tokens, when there is nothing to do or a backoff is active.
3. The computer must be on and logged in. If it is asleep, the schedule does not fire.

To stop: set `STATUS: gate` in `BUILD_STATE.md`, or remove the schedule line.

## 4. Energy

- A run that has nothing to do costs a few shell commands, and no model call.
- A run that has work reads two small files, not a long conversation.
- A failed run does not retry in a loop. It backs off.
- A task is not repeated on another model after a failure. See the [model routing](model-routing-2026-10-08-1555.md) failure rule.

## 5. Risks to know about

| Risk | Mitigation |
| --- | --- |
| An unattended run makes a wrong change | Every task is a commit, so any task can be reverted. Gates stop the run before the risky milestones. Security-critical tasks use Opus and review |
| It edits files while you are working in them | Set `STATUS: gate` before you start working |
| A usage limit is reached in the middle of a task | The task is unfinished and uncommitted. The next run sees the row still marked `todo` and repeats only that task |
| The permission list is too narrow for a command a task needs | The run fails and backs off. Check `.build/resume.log`, then add the command to the list in the script if it is safe |
| It spends your allowance while you need it | Use the `gate` status, or remove the schedule, when you want the allowance for other work |

## 6. If you prefer to stay in a session

Claude Code can schedule its own wakeups while a session is open, but those stop when the session ends, so the runner above is the one to rely on while you sleep.
