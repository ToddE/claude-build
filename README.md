# claude-build manual

Created by A. Todd Emerson. Apache-2.0 license. Contributions welcome (section 15).

`claude-build.sh` keeps a Claude Code build going until it is done, blocked, or at a gate. It reads a state file, and while the status is `ready` it starts one bounded `claude -p` session that does the next few tasks, updates the state file, and commits. Then it sleeps and checks again. Sleeping and checking use no model, so an idle or finished build costs almost nothing.

Install it with the script in section 1, edit `claude-build.conf` (set `PROJECT_DIR`), and add a state file (section 4). One installed copy can build any number of projects: point it at a project with `-c` and `-d`.

## Who this is for

`claude-build` suits one project with dependent steps that you want Claude Code to work through while you are away. You describe the work once, in a plan and a task table, and the script runs it in order on your branch, one bounded session at a time. It needs bash, git, and the `claude` command, and no scheduler, database, or Python environment.

It fits when:

- You have a plan with many steps, such as a new service, a documentation set, or a migration, and a person reviews the result at milestones.
- You want to control cost by choosing a model and effort level for each task.
- You want the build to survive usage limits and crashes without watching it.

If you have many independent tasks that should each end on their own branch for review, see claude-automation under Related projects.

### Where the plan comes from

The quality of the build follows the quality of the plan. A build that starts from a clear plan needs fewer retries and less rework. If you do not have one yet, the [claude-skills](https://github.com/ToddE/claude-skills) project is a companion for that step. Its product-management skills take an idea through a Working Backwards PR/FAQ, use case discovery, full use cases, test cases, functional requirements, and an architecture review. Those documents are a good source for a `PLAN.md`.

The full path with claude-skills looks like this:

1. **Plan with claude-skills.** Produce the PR/FAQ, use cases, functional requirements, test cases, and architecture review for your project.
2. **Run the `build-plan` skill.** It reads those documents, asks what it still needs (stack, check commands, protected areas, credentials, gates), and writes `BUILD_STATE.md`, `claude-build.conf`, `CLAUDE.md`, a build plan, and an engineering prompt.
3. **Review the table.** Edit models, effort, order, and the gate rows. Resolve any `## Open questions`.
4. **Preview.** `claude-build -c claude-build.conf -d <project> -v` shows the model, the prompt, and the allowed commands. Nothing starts.
5. **Build.** `claude-build ... -b` runs it in the background. Check progress with `-s`.

If you have only a short plan, skip step 2 and use `claude-build --init PLAN.md -r` to draft the table (see "Before you start"). Questions the plan leaves open are listed in the file, or asked live with `-I`.

[examples/PLAN.md](examples/PLAN.md) shows a plan in a structure that turns into a good table: a goal and scope, conventions, a document map, milestones with tasks that each name what to read, a check that proves they are done and a difficulty, review gates, and open decisions. Its task table is [examples/BUILD_STATE.md](examples/BUILD_STATE.md).

**claude-build **works with any plan. A short `PLAN.md` you wrote by hand is enough to start.

## Why claude-build

Long builds with Claude Code usually fail in the same few ways: the context fills up, a usage limit stops the session, or a task goes wrong and nobody notices until morning. claude-build handles each of these with plain bash and a Markdown state file.

- **A small fresh context for every run.** Each run is one bounded `claude -p` session that does the next few tasks. A crash or usage limit costs at most one task, and the next run starts clean from the state file and git.
- **The script chooses the model, and no model orchestrates.** You write the task table, or have one model draft it once with `--init` and edit the result. Each row names a model and an effort level. The script starts each run with those settings, so routine tasks use cheaper models and hard ones use Opus. [examples/BUILD_STATE.md](examples/BUILD_STATE.md) shows a task list set up this way.
- **Failures are handled for you.** A failed run waits 1, 2, 4, then 6 hours. A task that fails twice is handed to Opus at high effort with a written diagnosis. Two clean runs that finish nothing set the build to `blocked`, with a reason.
- **Waiting costs nothing.** Sleeping and checking use no model, so an idle or finished build costs almost nothing.
- **Designed to be left alone.** Unattended runs may use only the commands on an allowed list, with no push, deploy, or delete by default. One copy runs at a time, and every task is a commit you can revert.
- **Hard to start by accident.** With no flags you get the help. With flags but no run flag you get a preview of the config, the model, and the exact prompt. Only `-r`, `-b`, and `-o` spend tokens.
- **Stops where a person should decide.** The state file has `ready`, `blocked`, `gate`, and `done`. A `gate` pauses the build for a human decision and shows why.
- **Easy to inspect.** `-s` shows the last state, recent tasks, and the log tail while the build runs and after it ends.
- **Small and readable.** It is one bash script with no dependencies beyond standard tools. You can read all of it before you run it.

### Related projects

The idea of calling `claude -p` in a loop with progress kept in files and git is well known as the Ralph Wiggum loop, and several projects build on it. claude-build follows the same pattern and adds the supervision around it: per-task model and effort, backoff, escalation, gates, an allowed-tools list, and a preview mode. Other projects to look at:

- [Ralph Wiggum loop](https://kartit.net/blog/ralph-wiggum-technique.html): the original shell loop, and Anthropic's plugin that runs a similar loop inside one session with a stop hook.
- [loopgen](https://github.com/pro-vi/loopy): generates the prompt, state, and queue files for a long-running loop.
- [claude-automation](https://pypi.org/project/claude-automation/): an overnight pipeline with plan, code, review, and test stages, and one git worktree per task.
- [Orchestra](https://pkg.go.dev/github.com/MochaCosine1206/orchestra): a Go tool that runs `claude -p` rounds with circuit breakers.

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
14. [License and credit](#14-license-and-credit)
15. [Contributing](#15-contributing)

## 1. Quick start

### Before you start: you need a state file

**claude-build** needs a **state file** before it can run: a Markdown file with a status line and a table of tasks (section 4). Without it, the script stops with `state file not found` and starts nothing. A project also needs to be a git repository.

The task table sets the model and effort level for each task. The script reads those cells and starts each run with them. During a build it never asks a model to choose.

The preferred way is the `build-plan` skill from [claude-skills](https://github.com/ToddE/claude-skills) (in `product-management/skills/build-plan`). It takes the use cases, requirements, test cases, and architecture review that the other skills produce and writes `BUILD_STATE.md`, `claude-build.conf`, `CLAUDE.md`, a build plan, and an engineering prompt, with a model and effort for each task, gates, stop conditions, and a coverage check that every requirement has a task. It asks its questions while you can answer them. Use it when you can. The two ways below are for smaller projects or when you do not have those documents.

You have three ways to get a state file:

0. **Use the `build-plan` skill** (preferred, described above).
1. **Write it yourself.** Copy [examples/BUILD_STATE.md](examples/BUILD_STATE.md) into your project as `BUILD_STATE.md` and replace the rows with your tasks.
2. **Have a model draft it with `--init`.** Write your plan in any Markdown file (goals, requirements, the order you want things done), then run:

**Preview.** Shows the model, the files it reads, and the prompt. Starts nothing.

```bash
claude-build -d ~/Workspace/myproject --init PLAN.md -m opus
```

**Run it.** One `claude -p` session writes `BUILD_STATE.md`.

```bash
claude-build -d ~/Workspace/myproject --init PLAN.md -m opus -r
```

**Interactive.** The model asks you questions first.

```bash
claude-build -d ~/Workspace/myproject --init PLAN.md -m opus -I -r
```

What `--init` does, step by step:

1. You give it your plan files, either right after `--init` or with `-i` (repeat `-i` more than once). Files and folders both work.
2. Without `-r` it only previews. It shows the model, the files it would read, and the exact prompt, and starts nothing.
3. With `-r` it starts one Claude session to write the file.
4. The session uses the model from `-m`, or `MODEL` in the config. Set the effort with `-e` or `EFFORT`.

The session is told to:

- read your plan files and the project
- write `BUILD_STATE.md` and nothing else
- choose a model and effort level for each task, by how hard the task is
- put tasks that use the same model next to each other
- add a `GATE` row after each milestone
- not start any task

It can read and write files. It cannot run commands. Use Opus for a large or tricky plan. Sonnet is enough for a simple one.

**Best results come from a plan that already answers the scope questions.** Do the questioning upstream, with a planning step such as claude-skills (see "Where the plan comes from"), so that `--init` only has to write the table. The script prints this reminder whenever you use `--init`. Where the plan leaves something unclear, there are two behaviors:

| Mode | What happens |
| --- | --- |
| Default (`--init -r`) | No one is available to answer, so the model writes its best draft and lists each unclear point under `## Open questions` after the table, with the assumption it made. If it has any, it sets `STATUS: blocked` and the script tells you how many. Answer them by editing the table or the plan, then set `STATUS: ready`. Runs unattended |
| Interactive (`--init -I -r`) | Starts a normal `claude` session in your terminal. The model reads the plan, asks you what is unclear one question at a time, then writes the file. Needs a terminal, so it cannot run from cron or the background |

The script then checks that the file has `STATUS: ready` (or `blocked` with open questions), a `NEXT` id, and a task table with `Id` and `Status` columns, and prints the task count. It refuses to run if the state file already exists, so it never overwrites your work.

**Read and edit the result before you run the build.** The table drives every run, and a vague task wastes a session.

### Stuck?

Run `claude-build --guide`. It opens an interactive Claude session that checks your setup (bash version, missing tools, config, project folder, state file, the end of the log), asks what you want to do, and gives you the exact commands, previews first. It cannot run claude-build for you, and it can only read files.

It uses tokens, so before it starts it shows the model, an estimate of the starting size and of the README if it reads it, and asks `Continue? [y/N]`. Answering no uses nothing. The estimates are the character count divided by 4. The script cannot show a live counter inside the Claude session. Type `/cost` there for real usage and `/context` for the size. Choose the model with `-m` (default is `MODEL` from the config). It needs a terminal and the `claude` command, and it also works before you have a config or a state file. The "no project folder" and "state file not found" errors point to it.

### Requirements

| Needed | Why |
| --- | --- |
| bash 4.4 or newer | The script is pure bash. Check with `bash --version`. macOS ships bash 3.2, so install a newer one with Homebrew |
| `claude` (Claude Code), logged in | Each run is a `claude -p` session |
| `git` | The project must be a git repository. Each task is committed |
| `setsid`, `timeout`, `readlink`, `stat`, `awk`, `sed` | Standard on Linux (util-linux and coreutils). On macOS, install coreutils and util-linux with Homebrew |
| `jq` (optional) | Live progress while a run works (see `-v`). Without it, output appears when each run ends |
| `curl` or `wget` | Only for the install script |

### Install

Run one of these. Each downloads `install.sh` from this repository and runs it:

```bash
curl -fsSL https://raw.githubusercontent.com/ToddE/claude-build/main/install.sh | bash
```
or
```bash
wget -qO- https://raw.githubusercontent.com/ToddE/claude-build/main/install.sh | bash
```

To read the script before running it, download it first:

```
curl -fsSLO https://raw.githubusercontent.com/ToddE/claude-build/main/install.sh
less install.sh
bash install.sh
```

The installer:

1. Checks for bash 4.4 or newer and warns about any missing tool from the table above.
2. Picks the latest GitHub release, or `main` if there is no release yet.
3. Downloads the script, the example config, and this manual to `~/.local/share/claude-build/<version>/`. It refuses a file that is not a bash script or has a syntax error.
4. Links `~/.local/bin/claude-build` to that copy.
5. Tells you if `~/.local/bin` is not on your `PATH`.

Then check it:

```
claude-build --version
claude-build              
```

Options are environment variables placed before `bash`:

| Variable | Default | Meaning |
| --- | --- | --- |
| `CLAUDE_BUILD_VERSION` | latest release, else `main` | A release tag such as `v0.1.0`, or `main` |
| `BIN_DIR` | `~/.local/bin` | Where the `claude-build` link goes |
| `SHARE_DIR` | `~/.local/share/claude-build` | Where the files go |
| `CLAUDE_BUILD_KEEP` | `2` | How many installed versions to keep, newest first |

For example, `curl -fsSL .../install.sh | CLAUDE_BUILD_VERSION=v0.1.0 bash` installs that version.

**Upgrading.** Check with `claude-build --check-update`, which asks GitHub for the latest release, prints whether a newer one exists, and changes nothing. Install it with `claude-build --update`, which shows the installer URL and asks `Continue? [y/N]`. Or run the install command again. Either way the installer downloads into a temporary folder, checks the files, and copies them into place only if every check passes. The new version goes beside the previous one and the link moves. Older versions are removed (see `CLAUDE_BUILD_KEEP`). `--update` pipes the installer straight into bash and does not save a copy of it. To roll back one version, run `ln -sfn ~/.local/share/claude-build/<old version>/claude-build.sh ~/.local/bin/claude-build`. These two flags are the only times the script uses the network, and it never checks on its own, so a build that runs unattended never changes or contacts anything. `--update` works for copies made by the installer. For a git clone it tells you to run `git pull`.

**Your config.** Put a config you want to keep at `~/.local/share/claude-build/claude-build.conf`. The installer links it into each version folder, so it survives upgrades. The installer never overwrites a config. You can also keep configs inside your projects and pass `-c`.

**Uninstall.** Remove the link and the folder: `rm ~/.local/bin/claude-build && rm -r ~/.local/share/claude-build`.

**Without the installer.** Clone the repository and link the script yourself (see "Installing on your PATH" below).

### Commands

```
claude-build                              show the full help. Nothing starts.
claude-build -c blog.conf                 preview using blog.conf. Nothing starts.
claude-build -c blog.conf -s              print the last state and the end of the log. Nothing starts.
claude-build -c blog.conf -r              really run, in this terminal. Quiet: a line per step.
claude-build -v -c blog.conf -r           run verbosely: print the state first and show the model's output live.
claude-build -c blog.conf -b              really run, in the background, and get your terminal back.
claude-build -c blog.conf -k              stop the background build.
```

These examples assume the script is on your `PATH` as `claude-build` (see "Installing on your PATH"). If a `claude-build.conf` sits beside the script, or in the folder you run it from, `-c blog.conf` can be left out.

The script has these modes. Only `-r`, `-b`, and `-o` start work:

| You run | What happens |
| --- | --- |
| no arguments | Prints the full help and exits |
| flags, but not `-r`, `-b`, `-o`, or `-s` | **Preview.** Shows the config in use, the project, the state counts, the settings, and the exact prompt, then exits. Starts nothing. Add `-v` to print the state report first |
| `-s` | **Status.** Prints the last state, the recent tasks, and the end of the log, then exits. Works while a build runs and after it has ended. Starts nothing |
| `-r` | **Really run, in this terminal.** Quiet: a line for each step. Keeps going until the build ends or you press Ctrl+C |
| `-b` | **Really run, in the background.** The script starts itself again, detached from the terminal, and returns to you. No `&` or `nohup` needed |
| `-o` | **Run one cycle** and exit. For cron or a timer |
| `-k` | **Stop** the background build |
| `-v` | **Verbose**, added to a preview or a run flag. Prints the state report first, and with `-r` or `-o` shows the model's output live as well as logging it |

Because preview is the default, a stray command cannot spend tokens. Progress is printed to the terminal and appended to the log file (`.build/build.log`, and `.build/supervisor.log` for `-b`). Follow it with `tail -f`, or look at the state at any time with `-s`.

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

The installer does this for you. To do it by hand, for one user, put a symlink in `~/.local/bin` (not `/usr/local/bin`, which would let every account on the machine start unattended builds with your login):

```
git clone https://github.com/ToddE/claude-build ~/Workspace/claude-build
ln -s ~/Workspace/claude-build/claude-build.sh ~/.local/bin/claude-build
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
Really run the supervisor loop in this terminal. It stays quiet: a line when it starts, a line for each run and wait, and a line when the build ends. It keeps cycling until the build is done, blocked, at a gate, or you stop it. Without `-r`, `-b`, or `-o` the script only previews. Add `-v` for a verbose run: the state report is printed first (whether a loop is running, the status, the next task and the model and effort it will use, the done count, the recent tasks, and the log tail), and the model's output is shown live as well as logged. While a run works, `-r` on a terminal shows an animated line with the task, the model, the elapsed time, and the number of changed files. It is erased when the run ends. With `-v` the progress lines take its place. Background and cron runs show no animation.
```
./claude-build.sh -r
./claude-build.sh -r -m opus -t 2        run on Opus, two tasks per run
```

#### `-b`, `--background`
Really run the loop in the background. The script checks the project and git first, then starts itself again in a detached session and returns after about two seconds. It prints the process id, the log to follow, and the commands to look at the state (`-s`) and to stop it (`-k`). Closing the terminal does not stop it. If a build is already running, it says so and does nothing else. All other flags and the config work as with `-r`. `-b -v` prints the state report before it starts.
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
Run exactly one cycle and exit. It does one model run if the state is `ready` and no backoff is active. Use it from cron or a timer. It is quiet, so cron mail stays small. Add `-v` to print the state report first and show the model's output. Exit codes are as in section 10.
```
./claude-build.sh -o
*/30 * * * * /path/to/project/scripts/claude-build.sh -o        (crontab line)
```

#### `-s`, `--status`
Print the last state and the end of the log, then exit. It shows whether a build loop is running, the status and any blocked reason, any backoff wait, the next task with the model and effort it will use, how many tasks are done, the last five finished tasks, and the last 15 lines of the log with values from `REDACT_FILES` replaced by `[hidden]`. No build is started, no lock is taken, and the model is never called. It works while a build runs in another terminal, in the background, or from cron, and after the build has ended.

It looks in the log directory of the project it resolves to: `PROJECT_DIR/LOG_DIR` (default `.build`), for the project named by `-d`, or by `PROJECT_DIR` in the config that `-c` names, or in the folder-local or script-local config. It does not scan for other builds. Give it the same `-c` (and `-l`, if you set one) you started the build with.
```
claude-build -c ~/builds/blog.conf -s
```
`-s` stands alone. Combining it with `-r`, `-b`, or `-o` is an error.

#### `--watch`

Status that refreshes. It shows the same report as `-s` and redraws it every 5 seconds until you press Ctrl+C (change the interval with `WATCH_EVERY=2 claude-build --watch`). Run it in a second terminal while a build works. Besides the status, next task, and task count, it shows how long the current run has been going and how many files have changed in the project since the last commit, so you can see a task taking shape before it is committed. It needs a terminal and cannot be combined with a run flag.

```
claude-build -c blog.conf --watch
```

#### `-v`, `--verbose`
A modifier, not a mode. With a preview, `-v` prints the state report before the settings and prompt. With `-r` or `-o`, it prints the state report first and shows progress in the terminal as the run works, one line per step: what the model says and each tool it uses, with a time. The same lines are written to the log in every mode, so `tail -f .build/build.log` follows a run even without `-v`. This needs `jq`. Without `jq`, the model's output appears only when each run ends. The raw stream of the latest run is kept in `.build/last-run.jsonl`. Set `STREAM=0` in the config to turn live progress off. With `-b` the state report is printed before backgrounding, and the background copy does not echo to the terminal. Follow it with `tail -f`.
```
claude-build -v -c blog.conf                  verbose preview
claude-build -v -c blog.conf -r               verbose run
```

#### Preview (no flag)
There is no flag to ask for a preview. When you pass flags but not `-r`, `-b`, `-o`, or `-s`, the script prints the config in use, the project, state counts, settings, context paths, allowed commands, and the exact prompt, then exits. It needs no git repository. Add the flags you want to test.
```
./claude-build.sh -m haiku -t 3 -i docs/spec.md      preview what -r would do with these
./claude-build.sh -c ~/builds/blog.conf               preview another project
```

#### `-h`, `--help`
Print the full help. The same text appears when you run with no arguments.

#### `--init [PATH...]`, `-I`, `--interactive`

Draft the state file from your plan (section 1, "Before you start"). `--init` is long form only. Alone it previews: the model, the effort, the paths it will read, the file it will write, whether it will ask questions, and the exact prompt. With `-r` it runs one planning session. Pass the plan as paths after `--init` or with `-i PATH` (repeatable), or set `CONTEXT_FILES` in the config. Choose the model with `-m` or `MODEL`, and the output file with `-S`. It cannot be combined with `-b`, `-o`, `-s`, or `-k`, and it never overwrites an existing state file. The session may use only `Read`, `Glob`, `Grep`, and `Write`, so it cannot run commands.

Unclear points are written under `## Open questions` and the state is set to `blocked`. `-I` (`--interactive`, only with `--init`) starts an interactive session that asks you the questions instead. Answering them in the plan beforehand gives the best table.

#### `--guide`

Interactive help from Claude for a setup that is not working (section 1, "Stuck?"). Long form only. It shows an estimate of the tokens it will use and asks before it starts. It stands alone: it cannot be combined with `--init`, `-r`, `-b`, `-o`, `-s`, or `-k`, and it never starts a build. The session may use only `Read`, `Glob`, and `Grep`. Use `-m` and `-e` to choose the model and effort, and `-c` and `-d` if your config or project is not in the default place.

#### `--check-update`, `--update`

`--check-update` asks GitHub for the latest release and says whether it is newer than the version you run. It changes nothing. `--update` does the same, then asks before it downloads and runs the installer for that release (it needs a terminal). Both are long form only, stand alone, need no config or project, and need `curl` or `wget`. `--update` refuses a git clone and shows the `git pull` command instead.

#### `--version`

Print the version and exit.

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
| `{model}`, `{effort}` | The model and effort chosen for this run |
| `{model_rule}` | Tells the run to do only tasks for its model and to stop before one that needs a different model. Added automatically at the end of your prompt if you do not use it |

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
Force one model for every run, passed to `claude --model`. This turns `MODEL_FROM_STATE` off for the run, so the Model column is ignored. Without `-m`, each run uses the model named for the next task (see "Model and effort per task" below), and the config's `MODEL` is only the fallback. Use a stronger model for harder work and a smaller one for mechanical work, but choose once, not by retrying.
```
./claude-build.sh -r -m opus
```

#### `-e`, `--effort LEVEL`
Force one effort level for every run, passed to `claude --effort`: how much the model reasons before it answers. Levels are `low`, `medium`, `high`, `xhigh`, and `max`. This turns `EFFORT_FROM_STATE` off for the run. Without `-e`, effort comes from the task's Effort cell, else from the model's default in `EFFORT_DEFAULTS`.
```
./claude-build.sh -r -e low
./claude-build.sh -r -m opus -e xhigh
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

### Combining flags

Flags can come in any order, and single-letter flags can be bundled behind one dash: `-rv` is `-r -v`, and `-rvc blog.conf` is `-r -v -c blog.conf`. A letter that takes a value (`-c`, `-d`, `-S`, `-P`, `-f`, `-i`, `-m`, `-M`, `-t`, `-T`, `-w`, `-a`, `-l`, `-e`) must be the last letter in its bundle, and its value is the next argument. `-cv blog.conf` is an error, because `-c` would need to be last. Long flags (`--run`) are never bundled, and a value that starts with a dash, such as a prompt, is taken as written.

Examples of bundles:
```
claude-build -rv -c blog.conf         verbose run
claude-build -vrc blog.conf           the same, with the config last
claude-build -bvc blog.conf           background, verbose start, config
claude-build -sc blog.conf            status for blog.conf
claude-build -kc blog.conf            stop the build for blog.conf
```

A few combinations have a defined meaning, and the script rejects the ones that do not make sense instead of picking one quietly.

| Combination | Result |
| --- | --- |
| `-c FILE` plus any settings flags (`-m`, `-t`, `-i`, ...), no run flag | Preview with those settings. Nothing starts |
| `-v` plus no run flag | Verbose preview: the state report, then the settings and prompt |
| `-s` | Print the state and the log tail, then exit |
| `-r` | Really run in this terminal, quietly |
| `-v -r` | Run verbosely: the state report first, the model's output live |
| `-b` | Really run in the background, quietly. `-b -v` prints the state report first |
| `-o` | Run one cycle, quietly. `-o -v` prints the report and the model's output |
| `-r`, `-b`, and `-o` together (any two) | Error. Choose one |
| `-s` plus `-r`, `-b`, or `-o` | Error. `-s` stands alone |
| `-k` plus any of `-r`, `-b`, `-o`, `-s` | Error. `-k` stands alone |
| `-m` or `-e` plus any run flag | The run uses that model or effort for every task |

```
claude-build -c blog.conf -b -m opus -t 2             background, forced to opus, two tasks per run
claude-build -d ~/Workspace/blog -S docs/PROGRESS.md -i docs/ -r      no config file: say everything on the command line
```

### Flag summary

| Short | Long | Default |
| --- | --- | --- |
| -r | --run | off |
| -o | --once | off |
| -s | --status | off |
| | --watch | off. Status that redraws every 5 seconds |
| -v | --verbose | off |
| -b | --background | off |
| -k | --stop | off |
| -h | --help | |
| -I | --interactive | off. With `--init`, ask questions in the terminal |
| | --check-update | off. Say whether a newer release exists |
| | --update | off. Install the newest release, after asking |
| | --guide | off. Interactive help from Claude. Asks before using tokens |
| | --init | off. Draft the state file from the `-i` paths. Preview unless `-r` |
| | --version | |
| -c | --config FILE | claude-build.conf beside the script |
| -d | --project DIR | `PROJECT_DIR` in the config, else the folder above scripts/ if it is a git repo |
| -S | --state FILE | BUILD_STATE.md |
| -l | --log-dir DIR | .build |
| -P | --prompt TEXT | built-in prompt |
| -f | --prompt-file FILE | none |
| -i | --context PATH | none |
| -m | --model NAME | per task from the state file, fallback sonnet |
| -e | --effort LEVEL | per task from the state file, else by model |
| -M | --permission-mode MODE | acceptEdits |
| -t | --tasks-per-run N | 5 |
| -T | --timeout DURATION | 3h |
| -w | --interval SECONDS | 1200 |
| -a | --after-run SECONDS | 30 |

### Model and effort per task

With `MODEL_FROM_STATE=1` (the default), **the script chooses the model, and no model orchestrates.** Before each run it reads the `Model` cell of the task named in `NEXT` and starts `claude` with that model.

- **Names:** `Sonnet`, `Opus`, and `Haiku` are read as `sonnet`, `opus`, and `haiku`. Extra words are ignored, so `Sonnet (copywriter)` is `sonnet`. Anything else is passed to `claude --model` as written.
- **Batching:** a run does the next task and any later tasks that name the same model, up to `TASKS_PER_RUN`. It stops before a task for a different model, and the script starts a new run on that model. A task list that groups same-model tasks therefore needs few start-ups.
- **Effort:** the same way. The task's `Effort` cell is used if there is one. Otherwise the model's level in `EFFORT_DEFAULTS` is used (`opus=high`, `sonnet=medium`, `haiku=low`).
- **Fallbacks:** a task with no `Model` cell uses `MODEL`. If no level is found, `EFFORT` is used, and if that is empty, the Claude Code default.
- **Forcing:** `-m` forces one model for every run and uses that model's default effort. `-e` forces one effort. A forced run ignores the Model and Effort cells.
- **Visible:** the terminal and the log show it, for example `running: next task 0.8 on opus, effort xhigh (7/66 done)`, and a preview shows `next run: task 0.8 on opus, effort xhigh`.

Choosing the model for each task once, instead of starting low and redoing the work on a higher model, avoids repeat runs.

## 4. The state file

The state file is the only thing a project must provide, and the build does not start without it. The build does not choose your tasks while it runs. You write the file, or draft it once with `--init` (section 1) and edit it. It is how the build resumes, so the script and the model read and write it, and nothing is kept in a conversation.

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
| Task table | A Markdown table whose header has `Id` and `Status` columns. `Status` is `todo`, `doing`, or `done`. Optional `Model` and `Effort` columns say which model and effort level each task should use (below). `Task`, `Milestone`, and `Commit` are shown by `-s` when present. Other columns are ignored |

A complete example with models, effort levels, batching, and a gate is in [examples/BUILD_STATE.md](examples/BUILD_STATE.md), built from the plan in [examples/PLAN.md](examples/PLAN.md). Copy it into your project as `BUILD_STATE.md` and replace the rows. A task row is all the model sees besides the context files and the repository, so each row should say what to read and how to check the result.

A literal `|` inside a cell must be written `\|`, because the table is split on `|`. The preview and `-s` warn about a row whose cell count differs from the header.

Each run updates the table and `NEXT`, and commits, after every task. To change what happens next, edit the file: set a row back to `todo`, add rows, or change `NEXT`.

## 5. The config file

`claude-build.conf` is read as shell: `KEY=value` lines and arrays. It is run, so only trust your own. Order of precedence: built-in default, then this file, then flags. Which file is used: `-c`, else `claude-build.conf` in the folder you are in, else the one beside the script. It must be owned by you and not writable by everyone. For a new project, copy [`examples/claude-build.conf`](examples/claude-build.conf), a complete template that documents every setting, lists the other values each can take, and ends with ready-made recipes (cautious, documentation, overnight, patient backoff, long prompt, two builds in one project). `claude-build.conf` in this folder is the working file for this project. The shipped working file documents every setting in place: what it does, where the file or folder it names is stored, its default, and the flag that overrides it. The table below is a summary.

| Key | Default | Meaning |
| --- | --- | --- |
| `PROJECT_NAME` | `build` | Shown in the log and in the `-s` report |
| `PROJECT_DIR` | none (see "Where it runs from") | Same as `-d`. The project folder on this computer, as an absolute path. The state file, context paths, log directory, and redact files are all relative to it |
| `STATE_FILE` | `BUILD_STATE.md` | Same as `-S` |
| `PROMPT` | built-in | Same as `-P`. Placeholders as above |
| `PROMPT_FILE` | none | Same as `-f`. Wins over `PROMPT` |
| `CONTEXT_FILES` | `()` | Array, same as `-i` |
| `MODEL` | `sonnet` | Same as `-m`. The fallback model, used when `MODEL_FROM_STATE` is `0` or a task has no Model cell |
| `MODEL_FROM_STATE` | `1` | `1` starts each run on the model named in the next task's Model column. `0` uses `MODEL` for every run |
| `EFFORT` | empty | Same as `-e`. The fallback effort level. Empty means the Claude Code default |
| `EFFORT_FROM_STATE` | `1` | `1` uses the next task's Effort cell, else `EFFORT_DEFAULTS`. `0` uses `EFFORT` for every run |
| `EFFORT_DEFAULTS` | `("opus=high" "sonnet=medium" "haiku=low")` | Array of `model=level`. The effort for each model when a task has no Effort cell |
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
| `REDACT_FILES` | `(".env.local")` | Files whose values are hidden if they appear in the log lines that `-s` prints |

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

`-s` prints something like this:

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
| `Choose one of -r, -b, or -o` and exit 64 | Two run flags were given together | Pick one |
| `-k cannot be combined` and exit 64 | `-k` was given with a run or view flag | Run `-k` on its own |
| The help text prints and nothing starts | You gave no arguments | Add a flag to preview, `-s` for the status, or `-r`, `-b`, or `-o` to run |
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
- Keep secrets out of the state file and the log. `-s` hides values from `REDACT_FILES` in the log tail it prints, but the log file itself is not scrubbed, so keep it out of git and out of screenshots.

## 14. License and credit

claude-build is copyright 2026 A. Todd Emerson and licensed under the [Apache License 2.0](LICENSE). If you redistribute it, or a modified version, keep the [LICENSE](LICENSE) and [NOTICE](NOTICE) files with it and keep the copyright notices in the source files. Contributions are accepted under the same license (Apache-2.0, section 5).

## 15. Contributing

Contributions are welcome: bug reports, fixes, documentation, and the open items in [TODO.md](TODO.md) (macOS support is the largest). See [CONTRIBUTING.md](CONTRIBUTING.md) for how to test a change without spending tokens, and for what to include in an issue or pull request.
