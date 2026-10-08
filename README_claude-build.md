# claude-build manual

`claude-build.sh` keeps a Claude Code build going until it is done, blocked, or at a gate. It reads a state file, and while the status is `ready` it starts one bounded `claude -p` session that does the next few tasks, updates the state file, and commits. Then it sleeps and checks again. Sleeping and checking use no model, so an idle or finished build costs almost nothing.

Copy this folder into any project, edit `claude-build.conf` (set `PROJECT_DIR`), and add a state file (section 4). Or keep one copy anywhere and point it at a project with `-c` and `-d`.

## Contents

1. [Quick start](#1-quick-start)
2. [How it works](#2-how-it-works)
3. [Flags, one by one](#3-flags-one-by-one)
4. [The state file](#4-the-state-file)
5. [The config file](#5-the-config-file)
6. [Checking progress](#6-checking-progress)
7. [Everyday tasks](#7-everyday-tasks)
8. [Running unattended](#8-running-unattended)
9. [Cost and energy](#9-cost-and-energy)
10. [Exit codes and files](#10-exit-codes-and-files)
11. [Testing without spending tokens](#11-testing-without-spending-tokens)
12. [Troubleshooting](#12-troubleshooting)
13. [Safety](#13-safety)

## 1. Quick start

Requirements: bash 4.4 or newer, `git` (the project must be a repository), and the `claude` command logged in.

```
./scripts/claude-build.sh                 show the full help. Nothing starts.
./scripts/claude-build.sh -t 5            any flags without -r or -o: a PREVIEW of settings and the prompt. Nothing starts.
./scripts/claude-build.sh -v              print the last state and the end of the log. Nothing starts.
./scripts/claude-build.sh -r              start the loop in this terminal. Progress is printed and logged.
./scripts/claude-build.sh -b              start the loop in the background and get your terminal back
./scripts/claude-build.sh -k              stop the background build
```

The script has these modes. Only `-r`, `-b`, and `-o` start work:

| You run | What happens |
| --- | --- |
| no arguments | Prints the full help and exits |
| flags, but not `-r`, `-o`, or `-v` | **Preview.** Shows the config in use, the project, the state counts, the settings, and the exact prompt, then exits. Starts nothing |
| `-v` | **View.** Prints the last state, the recent tasks, and the end of the log, then exits. Works while a build runs and after it has ended. Starts nothing |
| `-r` | **Run in this terminal.** Starts the loop and keeps going until the build ends or you press Ctrl+C |
| `-b` | **Run in the background.** The script starts itself again, detached from the terminal, and returns to you. No `&` or `nohup` needed |
| `-o` | **Run one cycle** and exit. For cron or a timer |
| `-k` | **Stop** the background build |

Because preview is the default, a stray command cannot spend tokens. Progress is printed to the terminal and appended to the log file (`.build/build.log`, and `.build/supervisor.log` for `-b`). Follow it with `tail -f`, or look at the state at any time with `-v`.

### Where it runs from

You can run `claude-build.sh` from any folder. It never assumes the folder you are in is the project.

| What | How it is found |
| --- | --- |
| The script's own folder | Where the real file lives. Symlinks are followed, so a link in `~/.local/bin` works |
| The config file | `-c FILE`, else `claude-build.conf` in the folder you are in, else the one beside the real script. The preview shows which was used |
| The project folder | `-d DIR`, else `PROJECT_DIR` in the config, else the folder above the script **only if** it is a git repository. Otherwise the script stops and asks. It never falls back to the current folder |
| State file, context paths, prompt file, log directory | Relative to the project folder, or absolute |
| `-c` and `-d` given on the command line | Relative to the folder where you typed the command, because they are needed before the project is known |
| A relative `PROJECT_DIR` inside a config | Relative to the folder holding that config |

```
cd /tmp && ~/Workspace/inform9/scripts/claude-build.sh -m opus        works from here (a preview): the config sets PROJECT_DIR
~/bin/claude-build -r -c ~/builds/blog.conf -d ~/Workspace/blog   works from anywhere
```

### Installing on your PATH

For one user, put a symlink in `~/.local/bin` (not `/usr/local/bin`, which would let every account on the machine start unattended builds with your login):

```
ln -s ~/Workspace/inform9/scripts/claude-build.sh ~/.local/bin/claude-build
claude-build               full help, from any folder
claude-build -m sonnet     preview
```

The link finds its config in the folder you run it from, or beside the real file. Use a symlink, not a copy: a copy has no config beside it, so it needs `-c` or a `claude-build.conf` in the folder you run it from. The help text and the hints it prints use the name you typed, so `claude-build` works as well as `claude-build.sh`. To use the same script for another project, give that project its own config and pass `-c` and `-d`, or set `PROJECT_DIR` in a copy of the config.

## 2. How it works

Each cycle, the script does this in plain shell, with no model:

| Step | Check | Result |
| --- | --- | --- |
| 1 | Is a stop file present? | Exit 0 |
| 2 | Read `STATUS` from the state file | `done` exits 0, `blocked` exits 2, `gate` exits 3, anything but `ready` exits 64 |
| 3 | Is a backoff active after a failed run? | Print "waiting until HH:MM" and sleep |
| 4 | Is the project a git repository? | If not, exit 1 |
| 5 | Start one run of `claude -p` with the prompt and the allowed commands | The run does its tasks and commits |
| 6 | Did the run finish a task? | If two runs in a row finish none, mark the state `blocked` and exit 2 |
| 7 | Sleep, then repeat | `AFTER_RUN` seconds after a good run, `INTERVAL` seconds otherwise |

Properties you can rely on:

- **Fresh context every run.** A run reads the state file and only the files it needs, not a conversation. A usage limit or crash costs at most the task in progress, which stays `todo` and repeats.
- **Backoff after a failure.** A failed run (for example a usage limit) waits 1 hour, then 2, 4, and 6 hours between tries. A good run clears the wait.
- **No endless empty runs.** A run that exits cleanly but completes nothing counts against a limit of two, then the build stops as blocked.
- **One copy at a time.** A lock keeps a terminal run and a cron run from overlapping.
- **Tasks per run is an instruction.** The prompt tells the model to do up to `TASKS_PER_RUN` tasks. A run also ends at `TIMEOUT`.

## 3. Flags, one by one

Every flag has a short and a long form. A flag overrides the config file, which overrides the built-in default. If you repeat a flag, the last one wins, except `-i`, which adds paths.

### What to do

#### `-r`, `--run`
Start the supervisor loop. It keeps cycling until the build is done, blocked, at a gate, or you stop it. Without `-r`, `-b`, or `-o` the script only previews.
```
./claude-build.sh -r
./claude-build.sh -r -m opus -t 2        run on Opus, two tasks per run
```

#### `-b`, `--background`
Run the loop in the background. The script checks the project and git first, so mistakes show in your terminal, then starts itself again in a detached session and returns after about two seconds. It prints the process id, the log to follow, and the commands to look at the state (`-v`) and to stop it (`-k`). Closing the terminal does not stop it. If a build is already running, it says so and does nothing else. All other flags and the config work as with `-r`.
```
./claude-build.sh -b
./claude-build.sh -b -m opus -t 2 -c ~/builds/blog.conf
```

#### `-k`, `--stop`
Stop the background build for this project. It ends any model run in progress (that task stays `todo` and repeats later) and removes the pid files. If nothing is running it says so. It finds the build through the project's log directory, so give it the same `-c` or `-d` you started with if they differ from the config in use.
```
./claude-build.sh -k
./claude-build.sh -k -c ~/builds/blog.conf
```

#### `-o`, `--once`
Run exactly one cycle and exit. It does one model run if the state is `ready` and no backoff is active. Use it from cron or a timer. Exit codes are as in section 10.
```
./claude-build.sh -o
*/30 * * * * /path/to/project/scripts/claude-build.sh -o        (crontab line)
```

#### `-v`, `--view`
Print the last state and the end of the log, then exit. It shows whether a build loop is running, the status and any blocked reason, any backoff wait, the next task, how many tasks are done, the last five finished tasks, and the last 15 lines of the log with values from `REDACT_FILES` replaced by `[hidden]`. No build is started, no lock is taken, and the model is never called. It works while a build runs in another terminal, in the background, or from cron, and it works after the build has ended.
```
./claude-build.sh -v
./claude-build.sh -v -c ~/builds/blog.conf
```

#### Preview (no flag)
There is no flag to ask for a preview. When you pass flags but not `-r`, `-o`, or `-v`, the script prints the config in use, the project, state counts, settings, context paths, allowed commands, and the exact prompt, then exits. It needs no git repository. Add the flags you want to test.
```
./claude-build.sh -m haiku -t 3 -i docs/spec.md      preview what -r would do with these
./claude-build.sh -c ~/builds/blog.conf               preview another project
```

#### `-h`, `--help`
Print the full help. The same text appears when you run with no arguments.

### Where things are

#### `-c`, `--config FILE`
Use another settings file. A relative path is relative to where you typed the command. Default: `claude-build.conf` beside the real script (not in the current folder). The file is read as shell, so use only your own. A missing file named with `-c` is an error (exit 64).
```
./claude-build.sh -r -c ~/builds/blog.conf
```

#### `-d`, `--project DIR`
The project folder. The script changes into it before doing anything, and every relative path (state file, context paths, prompt file, log directory) is relative to it. A relative `-d` is relative to where you typed the command. Default: `PROJECT_DIR` from the config, else the folder above `scripts/` if that is a git repository, else the script stops. It never defaults to the current folder.
```
./claude-build.sh -r -d ~/Workspace/blog -c ~/builds/blog.conf
```

#### `-S`, `--state FILE`
The state file, relative to the project (or an absolute path). Default `BUILD_STATE.md`. See section 4.
```
./claude-build.sh -r -S planning/PROGRESS.md
```

#### `-l`, `--log-dir DIR`
Where the log, lock, backoff, failure counter, and stop file live. Default `.build`. Give each project, or each build in the same project, its own directory.
```
./claude-build.sh -r -l .build-docs
```

### What each run is told

#### `-P`, `--prompt TEXT`
The instruction given to every run. The default is: read the state file, continue at `NEXT`, do up to N tasks, update the state file and commit after each, set `blocked` at a stop condition, do not deploy or push. A flag prompt replaces a prompt from the config and clears any `PROMPT_FILE`.

Placeholders, filled in before the run starts:

| Placeholder | Becomes |
| --- | --- |
| `{state_file}` | The state file name |
| `{tasks_per_run}` | The value of `-t` |
| `{context}` | A sentence listing the `-i` paths, or nothing if there are none |

```
./claude-build.sh -r -P 'Read {state_file}. {context} Do the NEXT task only, then commit.' -t 1
```

#### `-f`, `--prompt-file FILE`
Read the prompt from a file instead. The same placeholders work inside the file. Use it for long prompts. If a config sets `PROMPT_FILE` and you pass `-P`, the flag wins.
```
./claude-build.sh -r -f prompts/build.txt
```

#### `-i`, `--context PATH`
A file or directory the run should start reading from. Repeat the flag for more. The prompt tells the run to read only the parts the task needs, so listing a directory is cheap. The first `-i` on the command line replaces the config's list. Missing paths are shown as a warning by `-n`.
```
./claude-build.sh -r -i docs/spec.md -i docs/api/ -i planning/
```

### How each run is done

#### `-m`, `--model NAME`
The model for each run, passed to `claude --model`. Default `sonnet`. Use a stronger model for harder work and a smaller one for mechanical work, but choose once, not by retrying.
```
./claude-build.sh -r -m opus
```

#### `-M`, `--permission-mode MODE`
The Claude Code permission mode. Default `acceptEdits`, which accepts file edits without asking. Commands still need to be on the allowed list (section 5).

#### `-t`, `--tasks-per-run N`
How many tasks each run attempts. Default 5. Smaller values mean smaller contexts and more frequent saves. Larger values mean fewer start-ups.
```
./claude-build.sh -r -t 2
```

#### `-T`, `--timeout DURATION`
The longest a single run may take. Default `3h`. Uses the `timeout` command's units: `90s`, `45m`, `3h`. A run killed by the timeout counts as a failed run and backs off.
```
./claude-build.sh -r -T 90m
```

### Timing

#### `-w`, `--interval SECONDS`
How long to wait when there is nothing to do, or after a failed run (the backoff may be longer). Default 1200 (20 minutes).
```
./claude-build.sh -r -w 600
```

#### `-a`, `--after-run SECONDS`
How long to wait after a good run before the next one starts. Default 30.

### Flag summary

| Short | Long | Default |
| --- | --- | --- |
| -r | --run | off |
| -o | --once | off |
| -v | --view | off |
| -b | --background | off |
| -k | --stop | off |
| -h | --help | |
| -c | --config FILE | claude-build.conf beside the script |
| -d | --project DIR | `PROJECT_DIR` in the config, else the folder above scripts/ if it is a git repo |
| -S | --state FILE | BUILD_STATE.md |
| -l | --log-dir DIR | .build |
| -P | --prompt TEXT | built-in prompt |
| -f | --prompt-file FILE | none |
| -i | --context PATH | none |
| -m | --model NAME | sonnet |
| -M | --permission-mode MODE | acceptEdits |
| -t | --tasks-per-run N | 5 |
| -T | --timeout DURATION | 3h |
| -w | --interval SECONDS | 1200 |
| -a | --after-run SECONDS | 30 |

## 4. The state file

The state file is the only thing a project must provide. It is how the build resumes, so the script and the model read and write it, and nothing is kept in a conversation.

```
# Build state

STATUS: ready
NEXT: 0.1
BLOCKED_REASON:

| Id | Milestone | Task | Model | Status | Commit | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| 0.1 | M0 | Scaffold the workspace | Sonnet | todo | | |
| 0.2 | M0 | Configure wrangler | Sonnet | todo | | |
```

| Part | Rules |
| --- | --- |
| `STATUS:` | `ready` runs work. `blocked` waits for a person and needs a reason. `gate` waits for a person to review. `done` ends the loop. The script reads the first line that starts with `STATUS:` |
| `NEXT:` | The id of the next task. The run sets it after each task |
| `BLOCKED_REASON:` | Filled in when `STATUS` is `blocked` |
| Task table | A Markdown table whose header has `Id` and `Status` columns. `Status` is `todo`, `doing`, or `done`. `Task`, `Model`, `Milestone`, and `Commit` are shown by `-v` when present. Other columns are ignored |

Each run updates the table and `NEXT`, and commits, after every task. To change what happens next, edit the file: set a row back to `todo`, add rows, or change `NEXT`.

## 5. The config file

`claude-build.conf` is read as shell: `KEY=value` lines and arrays. It is run, so only trust your own. Order of precedence: built-in default, then this file, then flags. Which file is used: `-c`, else `claude-build.conf` in the folder you are in, else the one beside the script. It must be owned by you and not writable by everyone. For a new project, copy `claude-build.conf.example`, a complete template that documents every setting, lists the other values each can take, and ends with ready-made recipes (cautious, documentation, overnight, patient backoff, long prompt, two builds in one project). `claude-build.conf` in this folder is the working file for this project. The shipped working file documents every setting in place: what it does, where the file or folder it names is stored, its default, and the flag that overrides it. The table below is a summary.

| Key | Default | Meaning |
| --- | --- | --- |
| `PROJECT_NAME` | `build` | Shown in the log and in the `-v` report |
| `PROJECT_DIR` | none (see "Where it runs from") | Same as `-d`. The project folder on this computer, as an absolute path. The state file, context paths, log directory, and redact files are all relative to it |
| `STATE_FILE` | `BUILD_STATE.md` | Same as `-S` |
| `PROMPT` | built-in | Same as `-P`. Placeholders as above |
| `PROMPT_FILE` | none | Same as `-f`. Wins over `PROMPT` |
| `CONTEXT_FILES` | `()` | Array, same as `-i` |
| `MODEL` | `sonnet` | Same as `-m` |
| `PERMISSION_MODE` | `acceptEdits` | Same as `-M` |
| `ALLOWED_TOOLS` | read, edit, write, search, and a few safe git and shell commands | Array. The only tools and commands an unattended run may use. See below |
| `EXTRA_CLAUDE_ARGS` | `()` | Array of extra arguments passed to `claude` |
| `CLAUDE_BIN` | `claude` | The command to run. Set an absolute path if cron cannot find it |
| `TASKS_PER_RUN` | `5` | Same as `-t` |
| `TIMEOUT` | `3h` | Same as `-T` |
| `INTERVAL` | `1200` | Same as `-w` |
| `AFTER_RUN` | `30` | Same as `-a` |
| `BACKOFF_STEPS` | `(3600 7200 14400 21600)` | Seconds to wait after the 1st, 2nd, 3rd, and later failures |
| `LOG_DIR` | `.build` | Same as `-l` |
| `REQUIRE_GIT` | `1` | Set `0` to allow a project that is not a git repository. Not recommended |
| `REDACT_FILES` | `(".env.local")` | Files whose values are hidden if they appear in the log lines that `-v` prints |

### Example for a documentation project

```bash
PROJECT_NAME="docs"
STATE_FILE="docs/PROGRESS.md"
CONTEXT_FILES=("docs/" "STYLE.md")
PROMPT='Read {state_file}. {context} Do the NEXT task, then update {state_file} and commit. Stop at a gate.'
MODEL="haiku"
TASKS_PER_RUN=8
ALLOWED_TOOLS=("Read" "Edit" "Write" "Glob" "Grep" "Bash(git add:*)" "Bash(git commit:*)" "Bash(git status:*)")
```

### The allowed list

`ALLOWED_TOOLS` is how you keep an unattended run safe. Each entry is a tool (`Read`, `Edit`, `Write`, `Glob`, `Grep`, `Agent`) or a command pattern such as `Bash(pnpm:*)`. Anything not listed is refused, and the run fails or stops. Leave out `git push`, deploy commands, and anything that deletes. If a run fails because a command is blocked, `build.log` shows which, and you can add it if it is safe.

## 6. Checking progress

There is no server to run. Progress goes to the terminal and to a log file, and you can look at the state whenever you like.

| What you want | How |
| --- | --- |
| Watch it live | Run with `-r` and read the terminal. A line prints each cycle, such as `running: next task 0.4 (3/66 done)` or `waiting until 18:40 after a failed run` |
| Follow a background build | `tail -f .build/supervisor.log` (the path is printed when you start with `-b`) |
| See everything the model printed | `.build/build.log` |
| Print the last state at any time | `./claude-build.sh -v`. It also works after the build has ended |
| See the state file itself | Open `BUILD_STATE.md` (or your `STATE_FILE`). Each task row and `NEXT` are updated after every task |
| See the work | `git log --oneline`. Every task is a commit |

`-v` prints something like this:

```
inform9 build
  build loop: running (pid 18342)
  status:     ready
  next:       0.4  Settings service
  tasks:      3 of 66 done
  recent:
    0.3  Environment loading
    0.2  Wrangler configs
    0.1  Scaffold

log, last 15 lines (/home/you/project/.build/build.log):
  ...
```

## 7. Everyday tasks

| I want to | Do this |
| --- | --- |
| See what would run | Run it with the flags you want, but without `-r`. For example `./claude-build.sh -m opus -t 1` |
| Look at progress without running | `./claude-build.sh -v` |
| Start and watch | `./claude-build.sh -r` in one terminal, and `./claude-build.sh -v` or `tail -f .build/build.log` in another |
| Run in the background | `./claude-build.sh -b` |
| Stop the background build | `./claude-build.sh -k` |
| Pause after the current run | Set `STATUS: gate` in the state file. Or `touch .build/stop` |
| Stop right now | Ctrl+C. The task in progress is left uncommitted. Run `git status` and restore |
| Continue after a gate | Review, set `STATUS: ready`, run again |
| Fix a block | Read `BLOCKED_REASON`, fix it, set `STATUS: ready` and clear the reason |
| Redo a task | Set its row to `todo` and `NEXT:` to its id |
| Skip a task | Mark its row `done` with a note, and set `NEXT:` to the next id |
| Use a stronger model for one stretch | `./claude-build.sh -r -m opus -t 1` for a task, then go back |
| Take smaller steps | `-t 1` or `-t 2` |
| Work on another project | `-d ~/Workspace/other -c ~/builds/other.conf` |
| Run two builds at once | Give each its own `-l`, for example `-l .build-a` and `-l .build-b` |
| Start from a different folder of documents | `-i path/` (repeat as needed) |

### A gate in practice

1. A run reaches a milestone gate and sets `STATUS: gate`. The loop prints "at a gate" and exits with code 3.
2. You review the work and the commits.
3. Set `STATUS: ready` and start again.

## 8. Running unattended

### In a terminal or tmux

```
./claude-build.sh -r
```

Leave it running. It prints a line each cycle. If the computer sleeps, the loop pauses and continues when it wakes.

### In the background

```
./claude-build.sh -b
```

The script detaches itself, so you do not add `&` or `nohup`. Closing the terminal does not stop it. Stop it with `./claude-build.sh -k`. If the computer restarts, start it again, or use cron or a timer below.

### From cron (survives a restart)

`-o` runs one cycle and exits, so cron can start it often. Most runs end at once because there is nothing to do. cron has a minimal `PATH`, so give the full path to `claude` in the config.

```
# crontab -e
*/30 * * * * /home/you/project/scripts/claude-build.sh -o >> /home/you/project/.build/cron.log 2>&1
```

In `claude-build.conf`:

```bash
CLAUDE_BIN="/home/you/.local/bin/claude"
```

### From a systemd user timer

`~/.config/systemd/user/claude-build.service`:

```
[Service]
Type=oneshot
WorkingDirectory=/home/you/project
ExecStart=/home/you/project/scripts/claude-build.sh -o
```

`~/.config/systemd/user/claude-build.timer`:

```
[Timer]
OnBootSec=5min
OnUnitActiveSec=30min

[Install]
WantedBy=timers.target
```

Then `systemctl --user enable --now claude-build.timer`. Use one scheduler at a time. If two start together, the lock makes the second one exit.

### What happens at a usage limit

The run fails, the script writes a backoff time, and each following cycle prints "waiting until HH:MM" without calling the model. After the wait it tries again from the state file. I cannot see your plan's reset time, so the backoff is a guess: 1, 2, 4, then 6 hours. Lower `BACKOFF_STEPS` if your limit resets sooner.

## 9. Cost and energy

- An idle or finished build costs a few shell commands and no tokens.
- A run starts with a small context. The prompt tells it to read only what the task needs, and `-i` points it at where to look.
- A failed run backs off. It does not loop.
- A run that finishes no task is counted, and the build stops after two.
- Choose the model for the work once. Do not start low and redo on a higher model. Use `-m` to match a stretch of work, and `-t 1` when you want the smallest possible steps.
- A run without `-r` or `-o` only previews, so you can check a change of prompt or flags before spending anything.

## 10. Exit codes and files

| Code | Meaning |
| --- | --- |
| 0 | Done, a stop file was found, or one `-o` cycle finished |
| 1 | Cannot start, for example the project is not a git repository |
| 2 | Blocked: `STATUS` is `blocked`, or two runs made no progress. Read the reason |
| 3 | At a gate. Review, then set `STATUS: ready` |
| 64 | Bad flag, a missing or unsafe config, a missing project or state file, or an unknown `STATUS` |

Files written to the log directory (`.build` by default):

| File | Contents |
| --- | --- |
| `build.log` | Timestamped script messages and all output from the model runs |
| `build.lock` | The process id of the copy that is running |
| `backoff_until` | Unix time before which the loop will not try again |
| `failures` | Count of failed runs in a row |
| `stop` | Create it (`touch`) to stop the loop at the next check |
| `supervisor.log` | Output of a `-b` run (the script's own messages) |

Add the log directory to `.gitignore`.

## 11. Testing without spending tokens

A preview shows what would run. To test the loop itself, point `CLAUDE_BIN` at a stand-in script that edits the state file as a real run would. In a test config:

```bash
CLAUDE_BIN="/path/to/fake-claude.sh"
REQUIRE_GIT=0
```

A stand-in that exits 0 and does nothing lets you see the no-progress guard stop the build after two runs. A stand-in that marks the next task `done` and advances `NEXT` lets you watch a whole build finish. Use `-l` with a scratch directory.

## 12. Troubleshooting

| What you see | Cause | Fix |
| --- | --- | --- |
| The help text prints and nothing starts | You gave no arguments | Add a flag to preview, `-v` to view, or `-r` or `-o` to run |
| `PREVIEW ONLY` and nothing runs | Flags were given without `-r` or `-o` | Add `-r` (loop) or `-o` (one cycle) |
| `refusing to use ... conf` and exit 64 | The config is owned by someone else or anyone can write to it | `chmod o-w` the file, or use your own |
| `cannot run: run git init first` and exit 1 | Not a git repository | `git init` and make a first commit |
| `already running (pid ...)` | A copy holds the lock | Wait, or stop it. If the pid is gone the lock clears itself |
| `No project folder` and exit 64 | No `-d`, no `PROJECT_DIR` in the config, and the script is not inside a git repository | Set `PROJECT_DIR` in the config, or pass `-d FOLDER` |
| `unknown STATUS` and exit 64 | The state file has no valid `STATUS:` line | Fix the first lines of the state file |
| `0 0 done/total` in the preview | The task table has no `Id` and `Status` header | Match the header in section 4 |
| Waiting until HH:MM, again and again | A usage limit or another failure | Read the end of `build.log`. The wait grows to 6 hours |
| `BLOCKED: two runs made no progress` | Runs exit cleanly but finish nothing | Read `build.log` for what the model said, fix it, set `STATUS: ready` |
| A run fails at once | A command is not on the allowed list, or `claude` is not logged in | Read `build.log`. Add the command to `ALLOWED_TOOLS` if it is safe |
| Works in a terminal, fails in cron | cron cannot find `claude` | Set `CLAUDE_BIN` to its full path |
| The same task keeps repeating | Its row never became `done` | Look at the commit and the row. Mark it `done` or change the task |

## 13. Safety

- An unattended run may use only the commands in `ALLOWED_TOOLS`. The default list has no deploy, push, or delete.
- Nothing starts without `-r` or `-o`.
- One copy runs at a time.
- The config file is run as shell. Only use your own.
- Every task is a commit, so any task can be reverted with git.
- Keep secrets out of the state file and the log. `-v` hides values from `REDACT_FILES` in the log tail it prints, but the log file itself is not scrubbed, so keep it out of git and out of screenshots.
