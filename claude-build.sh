#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# Copyright 2026 A. Todd Emerson. See LICENSE and NOTICE.
# claude-build.sh: keep a Claude Code build going until it is done, blocked, or at a gate.
# Run it with no arguments for the full help. With flags but no -r, -b, or -o it only previews.
# Pure bash. Progress goes to the terminal and to a log file. Settings: defaults below,
# then claude-build.conf, then command-line flags. See README.md in this folder.

# Author: Todd Emerson (github: ToddE) with coding assistance from Claude Code Sonnet 5.5
set -u
VERSION="0.1.0"

# Where the script lives (symlinks followed) and where the command was typed.
SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
ORIG_PWD="$PWD"
NAME="$(basename "$0")"   # the name you typed, such as claude-build
from_cwd() { case "$1" in /*) readlink -m "$1" ;; *) readlink -m "$ORIG_PWD/$1" ;; esac; }   # path typed on the command line

# ---------- defaults ----------
PROJECT_NAME="build"
PROJECT_DIR=""   # no silent default: see the project folder rules in the README
STATE_FILE="BUILD_STATE.md"
PROMPT=""
PROMPT_FILE=""
CONTEXT_FILES=()
MODEL="sonnet"                 # fallback model, used when a task names none
MODEL_FROM_STATE=1             # 1 = each run uses the Model column of the NEXT task in the state file
EFFORT=""                      # fallback effort level. Empty = the Claude Code default
EFFORT_FROM_STATE=1            # 1 = each run uses the Effort column of the NEXT task, else EFFORT_DEFAULTS
EFFORT_DEFAULTS=("opus=high" "sonnet=medium" "haiku=low")   # effort by model when a task has no Effort cell
PERMISSION_MODE="acceptEdits"
ALLOWED_TOOLS=("Read" "Edit" "Write" "Glob" "Grep" "Bash(ls:*)" "Bash(cat:*)" "Bash(git status:*)" "Bash(git diff:*)" "Bash(git add:*)" "Bash(git commit:*)" "Bash(git log:*)")
EXTRA_CLAUDE_ARGS=()
CLAUDE_BIN="claude"
TASKS_PER_RUN=5
TIMEOUT="3h"
INTERVAL=1200          # seconds to wait when a run failed or there is nothing to do
AFTER_RUN=30           # seconds to wait after a good run
BACKOFF_STEPS=(3600 7200 14400 21600)   # waits after the 1st, 2nd, 3rd, 4th and later failures
LOG_DIR=".build"
REQUIRE_GIT=1
REDACT_FILES=(".env.local")
CONFIG=""              # chosen below: -c, else ./claude-build.conf in the current folder, else the one beside this script
CONFIG_GIVEN=0
ONCE=0; RUN=0; VIEW=0; BACKGROUND=0; STOPIT=0; VERBOSE=0; INIT=0; ASK=0; GUIDE=0; CHECK_UPDATE=0; UPDATE=0; POSITIONAL=()   # VIEW = status-only mode (-s), INIT = plan mode (--init), ASK = interactive plan mode (-I)

# Bundled short flags: -rv is -r -v, and -vrc FILE is -v -r -c FILE. Letters that take a value must come last in a bundle.
expand_flags() {
  local a letters i ch last needs_value=0; EXPANDED=()
  for a in "$@"; do
    if [ $needs_value -eq 1 ]; then EXPANDED+=("$a"); needs_value=0; continue; fi   # the value of the previous flag, copied as written
    case "$a" in
      --*|-|-?) EXPANDED+=("$a"); case "$a" in -[cdSPfimMtTwale]) needs_value=1 ;; esac ;;
      -[A-Za-z][A-Za-z]*)
        letters="${a#-}"
        for ((i=0;i<${#letters};i++)); do
          ch="${letters:i:1}"; last=$(( i == ${#letters}-1 ))
          case "$ch" in
            [robksvhnI]) EXPANDED+=("-$ch") ;;
            [cdSPfimMtTwale]) EXPANDED+=("-$ch"); if [ $last -eq 1 ]; then needs_value=1; else echo "In $a, -$ch takes a value, so it must be the last letter of the bundle (for example -vrc FILE)."; exit 64; fi ;;
            *) echo "unknown option: -$ch in $a (try -h)"; exit 64 ;;
          esac
        done ;;
      *) EXPANDED+=("$a") ;;
    esac
  done
}
expand_flags "$@"
set -- "${EXPANDED[@]+"${EXPANDED[@]}"}"
ORIG_ARGS=("$@")

usage() {
cat <<END_OF_HELP
$NAME: keep a Claude Code build going until it is done, blocked, or at a gate

MODES
  no arguments        this help
  flags, no -r/-b/-o/-s   PREVIEW: shows the project, settings, and the exact prompt. Starts nothing
  -s                  status: print the last state and the end of the log (works after the build ended)
  -r                  really run, in this terminal. Quiet: a line per step
  -b                  really run, in the background, then return to the terminal
  -o                  run one cycle, then exit (for cron or a timer)
  -k                  stop the background build
  --check-update      look for a newer release on GitHub and say so. Changes nothing
  --update            install the newest release (asks first). The only other network use
  --guide             stuck? opens an interactive Claude session that helps you choose flags and fix your setup.
                      Uses tokens, so it shows an estimate and asks first. Never starts a build
  --init PLAN.md      draft the state file from your plan with a model. A preview until you add -r.
                      Unclear points go under "## Open questions" (STATUS: blocked). Add -I to be asked
                      instead, in this terminal. Best results: answer scope questions upstream, in the plan
  -v                  verbose, added to a preview or any run flag: print the state report first, and
                      with -r or -o show the model's output live as well as logging it
  Nothing is ever started unless you pass -r, -b, or -o. Pick only one of those three.
  -k and -s stand alone. Flags can come in any order, and single letters can be bundled:
  -rv is -r -v, and -vrc FILE is -v -r -c FILE (a letter that takes a value goes last).

WHAT IT DOES
  Reads a state file, and while the status is "ready" runs one bounded Claude Code
  session ("claude -p") that does the next few tasks, updates the state file, and
  commits. Then it sleeps and checks again. Sleeping and checking use no model.
  Each run starts with a fresh, small context, so a usage limit or crash costs at
  most one task. After a failed run it waits 1, 2, 4, then 6 hours (BACKOFF_STEPS).
  A run that finishes no task is counted, and the build stops after two of them.

USAGE
  claude-build.sh [flags]          preview only (flags without -r, -b, or -o)
  claude-build.sh -r [flags]       run in this terminal, quietly
  claude-build.sh -v -r [flags]    run in this terminal, verbosely
  claude-build.sh -b [flags]       run in the background, then return to the terminal
  claude-build.sh -o [flags]       one cycle, then exit
  claude-build.sh -s [flags]       show the last state and the log tail
  claude-build.sh -k [flags]       stop the background build
  claude-build.sh -h               this text (also shown when run with no arguments)
  Every flag has a long form too: -r is --run, -v is --verbose, and so on (see FLAGS).

EXAMPLES  (flags can be combined and come in any order)
  $NAME -c blog.conf                       preview using blog.conf. Nothing starts
  $NAME -v -c blog.conf                    verbose preview: the state report, then the settings and prompt
  $NAME -c blog.conf -r                    really run in this terminal, quietly
  $NAME -v -c blog.conf -r                 run verbosely: state first, model output live
  $NAME -c blog.conf -b                    run in the background (the start message shows how to check it)
  $NAME -c blog.conf -s                    last state and log tail, while it runs in the background or after
  $NAME -c blog.conf -k                    stop the background build
  $NAME -c blog.conf -b -m opus -t 2       background, forced to opus, two tasks per run
  $NAME -c blog.conf -m opus -t 1          preview a change of model and task count
  $NAME -d ~/Workspace/blog -S docs/PROGRESS.md -i docs/ -r      work in a project with no config file
  */30 * * * * $SCRIPT_PATH -c /home/you/blog.conf -o            (cron: one cycle every 30 minutes)

FLAGS  (a flag overrides the config file, which overrides the built-in default)
  -r, --run                  really run the loop in this terminal (quietly)
  -b, --background           run the loop in the background and return to the terminal
  -o, --once                 one cycle, then exit
  -s, --status               print the last state and the log tail. Starts no build
  -v, --verbose              verbose: state report first, and the model's output live with -r or -o
  -k, --stop                 stop the background build
  -c, --config FILE          settings file (relative to where you run this)  [${CONFIG_USED}]
  -d, --project DIR          project folder (relative to where you run this) [${PROJECT_DIR:-not set}]
  -S, --state FILE           state file, relative to project   [$STATE_FILE]
  -P, --prompt TEXT          prompt for every run (see PROMPT PLACEHOLDERS)
  -f, --prompt-file FILE     read the prompt from a file
  -i, --context PATH         file or directory to start reading from. Repeat for more
  -m, --model NAME           force one model for every run     [$MODEL, or per task from the state file]
  -e, --effort LEVEL         force one effort level every run  [per task from the state file, else by model]
  -M, --permission-mode M    Claude Code permission mode       [$PERMISSION_MODE]
  -t, --tasks-per-run N      tasks to attempt per run          [$TASKS_PER_RUN]
  -T, --timeout DURATION     longest one run may take, e.g. 3h [$TIMEOUT]
  -w, --interval SECONDS     wait when idle or backing off     [$INTERVAL]
  -a, --after-run SECONDS    wait after a good run             [$AFTER_RUN]
  -l, --log-dir DIR          logs, lock, and stop file         [$LOG_DIR]
  -h, --help                 show this text
      --guide                interactive help from Claude (asks before using tokens)
      --check-update         check GitHub for a newer release (the script never checks on its own)
      --update               install the newest release, after asking
      --version              print the version and exit
      --init [PATH...]       draft the state file from the plan paths (or -i) with the -m model. Add -r to run it
  -I, --interactive          with --init: the model asks you questions in this terminal first

PROMPT PLACEHOLDERS
  {state_file}   the state file name
  {tasks_per_run}  how many tasks to do per run
  {context}      a sentence listing the --context paths (empty if none)
  {model} {effort}  the model and effort chosen for this run
  {model_rule}   tells the run to stop before a task that needs a different model
                 (added automatically at the end if your prompt does not use it)

MODEL AND EFFORT PER TASK
  With MODEL_FROM_STATE=1 (the default) the script reads the Model column of the NEXT
  task in the state file and starts the run with that model. Consecutive tasks with the
  same model share a run. When the next task names a different model, the run ends and
  the script starts a new one. Effort works the same way: the Effort cell of the task,
  else the model's level in EFFORT_DEFAULTS. A task with no Model cell uses MODEL.
  -m forces one model for every run (with that model's effort). -e forces one effort.
  No model orchestrates: the script chooses.

WHERE IT RUNS FROM
  You can run it from any folder. It never assumes the current folder is the project.
  Config file: -c FILE, else claude-build.conf in the folder you are in, else the one
  beside this script (symlinks followed). It is run as shell, so it must be owned by
  you and not writable by everyone. The config in use is shown in the preview.
  Project folder: -d, else PROJECT_DIR in the config, else the folder above this
  script if that is a git repository, else it stops and asks. -c and -d are relative
  to where you typed the command. Every other path (state file, context, log dir) is
  relative to the project folder.

CONFIG FILE
  ${CONFIG_USED}
  Plain shell: KEY=value lines and arrays. It is executed, so only trust your own.
  Keys: PROJECT_NAME PROJECT_DIR STATE_FILE PROMPT PROMPT_FILE CONTEXT_FILES MODEL
  MODEL_FROM_STATE EFFORT EFFORT_FROM_STATE EFFORT_DEFAULTS
  PERMISSION_MODE ALLOWED_TOOLS EXTRA_CLAUDE_ARGS CLAUDE_BIN TASKS_PER_RUN TIMEOUT
  INTERVAL AFTER_RUN BACKOFF_STEPS LOG_DIR REQUIRE_GIT REDACT_FILES

STATE FILE FORMAT  (the only thing a project must provide)
  STATUS: ready          ready, blocked, gate, or done
  NEXT: 0.1              the id of the next task
  BLOCKED_REASON:        why it is blocked, when STATUS is blocked
  ...
  | Id | Task | Status | ...    a Markdown table. Status is todo, doing, or done
  The run updates the file and commits after each task. Only "ready" runs work.

WATCHING PROGRESS
  Progress is printed to the terminal and appended to <project>/$LOG_DIR/build.log
  (and supervisor.log for -b). Follow it with tail -f, or print the state with -s.

WHEN IT STOPS  (exit code)
  0  the build is done, a stop file was found, or one -o cycle finished
  1  it cannot start (for example, the project is not a git repository)
  2  blocked: STATUS is blocked, or two runs made no progress. Read the reason,
     fix it, set STATUS: ready
  3  at a gate: review, then set STATUS: ready
  64 a bad flag, a missing or unsafe config, a missing project or state file,
     or an unknown STATUS

STOPPING IT
  Ctrl+C (foreground), -k (background), touch <project>/$LOG_DIR/stop, or set
  STATUS: gate in the state file.

FILES IT WRITES  (in $LOG_DIR/)
  build.log  supervisor.log  build.lock  backoff_until  failures  stop

SAFETY
  Unattended runs may use only the commands in ALLOWED_TOOLS. The default has no
  deploy, push, or delete. One copy runs at a time (the lock), so cron and a
  terminal cannot overlap. A pid in the lock is checked against the process name
  before it is trusted or signalled. Nothing starts unless you pass -r, -b, or -o;
  with other flags it previews.
END_OF_HELP
}

# ---------- config file, then flags ----------
args=("$@")
for ((i=0;i<${#args[@]};i++)); do
  if [ "${args[i]}" = "--config" ] || [ "${args[i]}" = "-c" ]; then CONFIG="$(from_cwd "${args[i+1]:-}")"; CONFIG_GIVEN=1; fi
done
if [ $CONFIG_GIVEN -eq 0 ]; then
  if [ -f "$ORIG_PWD/claude-build.conf" ]; then CONFIG="$ORIG_PWD/claude-build.conf"
  elif [ -f "$(dirname "$SCRIPT_PATH")/claude-build.conf" ]; then CONFIG="$(dirname "$SCRIPT_PATH")/claude-build.conf"; fi
fi
if [ -n "$CONFIG" ] && [ -f "$CONFIG" ]; then
  # The config is run as shell, so refuse one that someone else owns or that anyone can write to.
  if [ "$(stat -L -c %u "$CONFIG")" != "$(id -u)" ] || [ $(( 0$(stat -L -c %a "$CONFIG") & 002 )) -ne 0 ]; then   # -L: judge the real file behind a symlink
    echo "refusing to use $CONFIG: it must be owned by you and not writable by everyone (chmod o-w)"; exit 64
  fi
  source "$CONFIG"
  # A relative PROJECT_DIR in a config file is relative to the folder holding that config.
  if [ -n "$PROJECT_DIR" ]; then case "$PROJECT_DIR" in /*) ;; *) PROJECT_DIR="$(readlink -m "$(dirname "$(readlink -f "$CONFIG")")/$PROJECT_DIR")" ;; esac; fi
elif [ $CONFIG_GIVEN -eq 1 ]; then echo "config not found: $CONFIG"; exit 64; fi
CONFIG_USED="${CONFIG:-none found}"

[ ${#args[@]} -eq 0 ] && { usage; exit 0; }
CTX_FROM_FLAG=0
while [ $# -gt 0 ]; do
  case "$1" in
    -c|--config) shift 2 ;;
    -d|--project) PROJECT_DIR="$(from_cwd "$2")"; shift 2 ;;
    -S|--state) STATE_FILE="$2"; shift 2 ;;
    -P|--prompt) PROMPT="$2"; PROMPT_FILE=""; shift 2 ;;
    -f|--prompt-file) PROMPT_FILE="$2"; shift 2 ;;
    -i|--context) [ $CTX_FROM_FLAG -eq 0 ] && CONTEXT_FILES=() && CTX_FROM_FLAG=1; CONTEXT_FILES+=("$2"); shift 2 ;;
    -m|--model) MODEL="$2"; MODEL_FROM_STATE=0; shift 2 ;;
    -e|--effort) EFFORT="$2"; EFFORT_FROM_STATE=0; shift 2 ;;
    -M|--permission-mode) PERMISSION_MODE="$2"; shift 2 ;;
    -t|--tasks-per-run) TASKS_PER_RUN="$2"; shift 2 ;;
    -T|--timeout) TIMEOUT="$2"; shift 2 ;;
    -w|--interval) INTERVAL="$2"; shift 2 ;;
    -a|--after-run) AFTER_RUN="$2"; shift 2 ;;
    -l|--log-dir) LOG_DIR="$2"; shift 2 ;;
    -r|--run) RUN=1; shift ;;
    -o|--once) ONCE=1; shift ;;
    -s|--status) VIEW=1; shift ;;
    -v|--verbose) VERBOSE=1; shift ;;
    -b|--background) BACKGROUND=1; shift ;;
    -k|--stop) STOPIT=1; shift ;;
    -h|--help) usage; exit 0 ;;
    --init) INIT=1; shift ;;
    --guide) GUIDE=1; shift ;;
    --check-update) CHECK_UPDATE=1; shift ;;
    --update) UPDATE=1; shift ;;
    -I|--interactive) ASK=1; shift ;;
    --version) printf '%s %s\nCopyright 2026 A. Todd Emerson. Apache-2.0 license.\nhttps://github.com/ToddE/claude-build\n' "$NAME" "$VERSION"; exit 0 ;;
    -*) echo "unknown option: $1 (try -h)"; exit 64 ;;
    *) POSITIONAL+=("$1"); shift ;;   # a plan path after --init, checked below
  esac
done
if [ ${#POSITIONAL[@]} -gt 0 ]; then
  if [ $INIT -eq 0 ]; then echo "unexpected argument: ${POSITIONAL[0]} (plan files go after --init, or use -i PATH)"; exit 64; fi
  [ $CTX_FROM_FLAG -eq 0 ] && CONTEXT_FILES=() && CTX_FROM_FLAG=1
  CONTEXT_FILES+=("${POSITIONAL[@]}")
fi
[ $ASK -eq 1 ] && [ $INIT -eq 0 ] && { echo "-I (interactive) is only for --init."; exit 64; }

# Flags that do not make sense together are an error.
if [ $(( RUN + BACKGROUND + ONCE )) -gt 1 ]; then echo "Choose one of -r (run here), -b (run in the background), or -o (one cycle)."; exit 64; fi
if [ $STOPIT -eq 1 ] && [ $(( RUN + BACKGROUND + ONCE + VIEW )) -gt 0 ]; then echo "-k (stop) cannot be combined with -r, -b, -o, or -s."; exit 64; fi
if [ $VIEW -eq 1 ] && [ $(( RUN + BACKGROUND + ONCE )) -gt 0 ]; then echo "-s (status) cannot be combined with -r, -b, or -o. Add -v to a run flag to see the state before it starts."; exit 64; fi

if [ $GUIDE -eq 1 ] && [ $(( INIT + RUN + BACKGROUND + ONCE + VIEW + STOPIT )) -gt 0 ]; then echo "--guide stands alone. It only helps you choose flags (add -c, -d, -m if needed)."; exit 64; fi
if [ $INIT -eq 1 ] && [ $(( BACKGROUND + ONCE + VIEW + STOPIT )) -gt 0 ]; then echo "--init cannot be combined with -b, -o, -s, or -k. Use --init alone to preview, or --init -r to write the state file."; exit 64; fi

if [ $(( CHECK_UPDATE + UPDATE )) -gt 0 ] && [ $(( GUIDE + INIT + RUN + BACKGROUND + ONCE + VIEW + STOPIT + ASK )) -gt 0 -o $(( CHECK_UPDATE + UPDATE )) -gt 1 ]; then echo "--check-update and --update stand alone, one at a time."; exit 64; fi

# ---------- --check-update and --update: the only network use. Nothing here runs unless you ask ----------
REPO="ToddE/claude-build"
RELEASE_URL="${CLAUDE_BUILD_RELEASE_URL:-https://api.github.com/repos/$REPO/releases/latest}"   # overridable for tests
fetch() { if command -v curl >/dev/null 2>&1; then curl -fsSL "$1"; elif command -v wget >/dev/null 2>&1; then wget -qO- "$1"; else return 127; fi; }
if [ $(( CHECK_UPDATE + UPDATE )) -gt 0 ]; then
  command -v curl >/dev/null 2>&1 || command -v wget >/dev/null 2>&1 || { echo "need curl or wget to check for updates"; exit 1; }
  latest="$(fetch "$RELEASE_URL" 2>/dev/null | sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p' | head -n 1)"
  if [ -z "$latest" ]; then echo "No release found (or GitHub could not be reached). This is version $VERSION. See https://github.com/$REPO/releases"; exit 1; fi
  newest="$(printf '%s\n%s\n' "${latest#v}" "$VERSION" | sort -V | tail -n 1)"
  if [ "${latest#v}" = "$VERSION" ] || [ "$newest" = "$VERSION" ]; then echo "$NAME $VERSION is up to date (latest release: $latest)."; exit 0; fi
  if [ $CHECK_UPDATE -eq 1 ]; then echo "$NAME $VERSION is installed. Version ${latest#v} is available. Update with: $NAME --update"; exit 0; fi
  # --update: only for a copy the installer made. A git clone is updated with git.
  case "$SCRIPT_PATH" in
    */share/claude-build/*) ;;
    *) echo "$SCRIPT_PATH is not an installer copy. Version ${latest#v} is available. If this is a git clone, run: git -C \"$(dirname "$SCRIPT_PATH")\" pull"; exit 1 ;;
  esac
  [ -t 0 ] && [ -t 1 ] || { echo "--update asks for confirmation, so it needs a terminal. Or run the installer directly (see the README)."; exit 64; }
  echo "Update $NAME from $VERSION to ${latest#v}."
  echo "This downloads and runs https://raw.githubusercontent.com/$REPO/$latest/install.sh. Older versions stay in place, and your config is not changed."
  read -r -p "Continue? [y/N] " ans
  case "$ans" in y|Y|yes|YES) ;; *) echo "Not updated."; exit 0 ;; esac
  fetch "https://raw.githubusercontent.com/$REPO/$latest/install.sh" | CLAUDE_BUILD_VERSION="$latest" bash
  exit $?
fi

# ---------- find and enter the project ----------
if [ $GUIDE -eq 1 ]; then   # --guide helps people who are stuck, so a missing project or state file is not an error here
  if [ -z "$PROJECT_DIR" ] && [ -d "$(dirname "$SCRIPT_PATH")/../.git" ]; then PROJECT_DIR="$(readlink -f "$(dirname "$SCRIPT_PATH")/..")"; fi
  if [ -n "$PROJECT_DIR" ] && [ -d "$PROJECT_DIR" ]; then cd "$PROJECT_DIR" || PROJECT_DIR=""; else PROJECT_DIR=""; fi
else
  if [ -z "$PROJECT_DIR" ]; then
    if [ -d "$(dirname "$SCRIPT_PATH")/../.git" ]; then PROJECT_DIR="$(readlink -f "$(dirname "$SCRIPT_PATH")/..")"
    else echo "No project folder. Set PROJECT_DIR in a claude-build.conf (in the current folder or beside the script), or pass -d FOLDER. Not guessing from the current folder. Stuck? Run: $NAME --guide"; exit 64; fi
  fi
  [ -d "$PROJECT_DIR" ] || { echo "project folder not found: $PROJECT_DIR. Stuck? Run: $NAME --guide"; exit 64; }
  cd "$PROJECT_DIR" || exit 64
  [ -f "$STATE_FILE" ] || [ $INIT -eq 1 ] || { echo "state file not found: $STATE_FILE (looked in $(pwd)). It needs STATUS, NEXT, and a task table. See README.md, section 4. To have a model draft one from your plan: $NAME --init PLAN.md. Stuck? Run: $NAME --guide"; exit 64; }
fi
LOG="$LOG_DIR/build.log"; LOCK="$LOG_DIR/build.lock"; BACKOFF="$LOG_DIR/backoff_until"; FAILS="$LOG_DIR/failures"; STOP="$LOG_DIR/stop"

proj_path() { case "$1" in /*) printf %s "$1" ;; *) printf %s "$PWD/$1" ;; esac; }   # absolute path for a project-relative one
stamp() { date '+%H:%M:%S'; }
log_msg()   { echo "[$(stamp)] $*"; mkdir -p "$LOG_DIR"; echo "$(date -Is) $*" >> "$LOG"; }
state() { grep -m1 "^$1:" "$STATE_FILE" | sed "s/^$1: *//"; }
self_cmd() { local c="$SCRIPT_PATH"; [ "$(readlink -f "$(command -v "$NAME" 2>/dev/null)" 2>/dev/null)" = "$SCRIPT_PATH" ] && c="$NAME"; echo "$c$([ "$CONFIG_USED" != "none found" ] && echo " -c $CONFIG_USED")"; }   # how to call this script again with the same config
# Is the process in pid file $1 running AND really ours? $2 is text its command line must contain.
# Checking the command line stops a reused pid (after a reboot or crash) from being mistaken for ours or signalled by -k.
alive() { local pid; [ -f "$1" ] && pid=$(cat "$1") && [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null && tr '\0' ' ' < "/proc/$pid/cmdline" 2>/dev/null | grep -q -- "$2"; }

# The task table is split on "|", so a literal | inside a cell must be written \| . This reads the table with \| turned into a placeholder (\001); show_cell turns it back.
state_table() { sed 's/\\|/\x01/g' "$STATE_FILE"; }
show_cell() { tr '\001' '|'; }
# Prints a warning for each task row whose cell count differs from the header (usually a | inside a cell).
table_warnings() {
  state_table | awk -F'|' '
    !hdr && /^\|[ \t]*Id[ \t]*\|/ { n=NF; hdr=1; next }
    hdr && /^\|[ \t:-]+\|/ && !seen { seen=1; next }
    hdr && /^\|/ { id=$2; gsub(/^[ \t]+|[ \t]+$/,"",id); if (NF!=n) printf "warning: task %s has %d cells but the header has %d. Write a | inside a cell as \\|\n", id, NF-2, n-2; next }
    hdr && !/^\|/ { exit }'
}
# Counts rows of the task table in the state file: prints "done total". The table needs a header with Id and Status columns.
task_counts() {
  state_table | awk -F'|' '
    function trim(s){gsub(/^[ \t]+|[ \t]+$/,"",s);return s}
    !hdr && /^\|[ \t]*Id[ \t]*\|/ { for(i=2;i<NF;i++) if (tolower(trim($i))=="status") sc=i; hdr=1; next }
    hdr && /^\|[ \t:-]+\|/ && !seen { seen=1; next }
    hdr && /^\|/ { if (trim($2)!="") { t++; if (tolower(trim($sc))=="done") d++ } next }
    hdr && !/^\|/ { exit }
    END { printf "%d %d", d+0, t+0 }'
}
# Prints one cell of the task row whose Id is $1, from the column named $2 (empty if the column or row is missing).
task_cell() {
  state_table | awk -F'|' -v id="$1" -v col="$2" '
    function trim(s){gsub(/^[ \t]+|[ \t]+$/,"",s);return s}
    !h && /^\|[ \t]*Id[ \t]*\|/ { for(i=2;i<NF;i++) if (tolower(trim($i))==tolower(col)) c=i; h=1; next }
    h && c && trim($2)==id { print trim($c); exit }' | show_cell
}
# Decide the model and effort for the run that starts at task $1. Sets RUN_MODEL, RUN_EFFORT, RUN_FROM_STATE.
plan_run() {
  local id="$1" m="" e="" kv
  RUN_MODEL="$MODEL"; RUN_EFFORT="$EFFORT"; RUN_FROM_STATE=0
  if [ "$MODEL_FROM_STATE" -eq 1 ]; then
    m=$(task_cell "$id" Model | tr 'A-Z' 'a-z' | tr -d '*' | sed 's/[ ,(].*//')   # "Sonnet (copywriter)" -> sonnet
    [ -n "$m" ] && { RUN_MODEL="$m"; RUN_FROM_STATE=1; }
  fi
  if [ "$EFFORT_FROM_STATE" -eq 1 ]; then
    # A task's own Effort cell applies only when its model also came from the state file.
    [ "$RUN_FROM_STATE" -eq 1 ] && e=$(task_cell "$id" Effort | tr 'A-Z' 'a-z' | tr -d '*' | sed 's/[ ,(].*//')
    if [ -z "$e" ]; then for kv in "${EFFORT_DEFAULTS[@]+"${EFFORT_DEFAULTS[@]}"}"; do [ "${kv%%=*}" = "$RUN_MODEL" ] && e="${kv#*=}"; done; fi
    [ -n "$e" ] && RUN_EFFORT="$e"
  fi
}
# Prints "id|task" for the n most recently finished tasks (last rows marked done), newest first.
recent_done() {
  state_table | awk -F'|' -v n="$1" '
    function trim(s){gsub(/^[ \t]+|[ \t]+$/,"",s);return s}
    !hdr && /^\|[ \t]*Id[ \t]*\|/ { for(i=2;i<NF;i++){c=tolower(trim($i)); if(c=="status")sc=i; if(c=="task")tc=i}; hdr=1; next }
    hdr && /^\|[ \t:-]+\|/ && !seen { seen=1; next }
    hdr && /^\|/ { if (tolower(trim($sc))=="done") { k++; id[k]=trim($2); tk[k]=trim($tc) } next }
    hdr && !/^\|/ { exit }
    END { for (i=k; i>0 && i>k-n; i--) printf "%s|%s\n", id[i], tk[i] }' | show_cell
}
# Replace any value from the REDACT_FILES with [hidden] in the lines read from stdin.
redact_log() {
  local -a vals=(); local f line v
  for f in "${REDACT_FILES[@]+"${REDACT_FILES[@]}"}"; do
    [ -f "$f" ] || continue
    while IFS= read -r line; do case "$line" in [A-Z]*=*) v="${line#*=}"; v="${v%%[[:space:]]#*}"; [ ${#v} -ge 8 ] && vals+=("$v") ;; esac; done < "$f"
  done
  while IFS= read -r line; do for v in "${vals[@]+"${vals[@]}"}"; do line="${line//"$v"/[hidden]}"; done; printf '%s\n' "$line"; done
}

build_prompt() {
  local p="$PROMPT" ctx=""
  [ -n "$PROMPT_FILE" ] && p="$(cat "$PROMPT_FILE")"
  if [ ${#CONTEXT_FILES[@]} -gt 0 ]; then ctx="Start from these paths and read only the parts the task needs: ${CONTEXT_FILES[*]}."; fi
  [ -z "$p" ] && p='Read {state_file}. {context} Continue the build at the NEXT task. Do up to {tasks_per_run} tasks, or stop earlier at a gate or a stop condition. {model_rule} After each task, update {state_file} and commit. If a stop condition applies, set STATUS to blocked with the reason and stop. Do not deploy and do not push.'
  local rule=""
  if [ "${RUN_FROM_STATE:-0}" -eq 1 ]; then rule="This run is on the ${RUN_MODEL} model. Do the NEXT task and any later tasks whose Model column is also ${RUN_MODEL}, up to ${TASKS_PER_RUN}. Stop before a task whose Model column names a different model and leave it for the next run."; fi
  case "$p" in *"{model_rule}"*) ;; *) [ -n "$rule" ] && p="$p {model_rule}" ;; esac
  p="${p//\{model_rule\}/$rule}"; p="${p//\{model\}/$RUN_MODEL}"; p="${p//\{effort\}/${RUN_EFFORT:-default}}"
  p="${p//\{state_file\}/$STATE_FILE}"; p="${p//\{tasks_per_run\}/$TASKS_PER_RUN}"; p="${p//\{context\}/$ctx}"
  printf '%s' "$p"
}

claude_args() {
  printf '%s\0' -p "$(build_prompt)" --model "$RUN_MODEL" --permission-mode "$PERMISSION_MODE" --output-format text
  [ -n "$RUN_EFFORT" ] && printf '%s\0' --effort "$RUN_EFFORT"
  [ ${#ALLOWED_TOOLS[@]} -gt 0 ] && { printf '%s\0' --allowedTools; printf '%s\0' "${ALLOWED_TOOLS[@]}"; }
  [ ${#EXTRA_CLAUDE_ARGS[@]} -gt 0 ] && printf '%s\0' "${EXTRA_CLAUDE_ARGS[@]}"
}

# ---------- --init: have a model draft the state file from your plan (a preview unless -r is given) ----------
init_prompt() {
  local srcs="${CONTEXT_FILES[*]}"
  cat <<END_OF_INIT
You are planning a long build that claude-build will run later, one bounded session at a time. Read these paths: ${srcs}. Then create the file ${STATE_FILE} in the current folder. Do not start any task. Do not create or change any other file.

${STATE_FILE} must follow this format exactly:

# Build state

STATUS: ready
NEXT: <the Id of the first task>
BLOCKED_REASON:

| Id | Milestone | Task | Model | Effort | Status | Commit | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1.1 | M1 Name | What to do, which file to read, and the check that proves it is done | haiku | | todo | | |

Rules:
- Every row has Status todo. Leave Commit and Notes empty.
- Task: one sitting of work. Name the file or section to read and a check that proves it is done, such as a command that passes or a file that exists. A later session sees only this row, the project files, and the repository.
- Model is haiku, sonnet, or opus. Use haiku for mechanical work, sonnet for most implementation and writing, and opus for design, hard debugging, and decisions that are costly to redo.
- Effort is low, medium, high, xhigh, or max. Leave it empty unless the default for the model (opus high, sonnet medium, haiku low) is wrong for that task.
- Put tasks that use the same model next to each other when the order allows, because one session handles consecutive tasks that name the same model.
- Add a row whose Task begins with GATE after each milestone. Leave its Model and Effort empty. A session that reaches it sets STATUS to gate and stops for a person to review.
- Ids are unique and increase in the order the tasks run.
- Never put a | inside a cell. If a command needs one, write \\| instead.

Questions:
END_OF_INIT
  if [ $ASK -eq 1 ]; then cat <<END_OF_ASK
- First read the paths. Then ask me what is unclear, one question at a time, only where the answer would change the scope, the order, or the choice of model. Do not ask about anything the paths already answer. When I have answered, write ${STATE_FILE}.
END_OF_ASK
  else cat <<END_OF_NOASK
- Nobody is available to answer questions during this session. Do not guess silently. Write your best draft. Under a heading "## Open questions" after the table, list each unclear point as a numbered item, with the assumption you made. Only list questions where the answer would change the scope, the order, or the choice of model, and do not repeat what the paths already answer.
- If you listed any open questions, set STATUS to blocked and BLOCKED_REASON to "Answer the open questions in this file, then set STATUS to ready". If you have none, leave STATUS ready.
END_OF_NOASK
  fi
}
init_effort() { local kv; INIT_EFFORT="$EFFORT"; if [ "$EFFORT_FROM_STATE" -eq 1 ]; then for kv in "${EFFORT_DEFAULTS[@]+"${EFFORT_DEFAULTS[@]}"}"; do [ "${kv%%=*}" = "$MODEL" ] && INIT_EFFORT="${kv#*=}"; done; fi; }
if [ $INIT -eq 1 ]; then
  init_effort; INIT_TOOLS=("Read" "Glob" "Grep" "Write")
  if [ $RUN -eq 0 ]; then
    echo "PREVIEW ONLY. Nothing was started."; echo "mode:      --init (draft the state file from your plan)"; echo "config:    $CONFIG_USED"; echo "project:   $(pwd)"
    echo "writes:    $STATE_FILE$([ -f "$STATE_FILE" ] && echo "   (ALREADY EXISTS: --init -r will refuse)")"
    echo "model:     $MODEL, effort ${INIT_EFFORT:-default}   (set with -m and -e, or MODEL and EFFORT in the config)"
    echo "reads:     ${CONTEXT_FILES[*]:-none}   (set with -i PATH, repeatable)"
    for c in "${CONTEXT_FILES[@]+"${CONTEXT_FILES[@]}"}"; do [ -e "$c" ] || echo "  warning: path not found: $c"; done
    echo "asking:    $([ $ASK -eq 1 ] && echo "yes, an interactive session in this terminal (-I): it asks you questions, then writes the file" || echo "no. Unclear points are written under \"## Open questions\" and STATUS is set to blocked. Add -I to be asked instead")"
    echo "allowed:   ${INIT_TOOLS[*]}"; echo "prompt:"; init_prompt | fold -s -w 100 | sed 's/^/  /'; echo
    echo "To start: add -r. Then review $STATE_FILE before you run the build."
    echo "Tip: the best results come from a plan that already answers the scope questions. Do the questioning upstream (see Where the plan comes from in the README), then --init only has to write the table."
    exit 0
  fi
  [ -f "$STATE_FILE" ] && { echo "$STATE_FILE already exists in $(pwd). --init will not overwrite it. Move it, or choose another name with -S."; exit 64; }
  [ ${#CONTEXT_FILES[@]} -gt 0 ] || { echo "Nothing to read. Pass your plan with -i PATH (repeatable), or set CONTEXT_FILES in the config."; exit 64; }
  found=0; for c in "${CONTEXT_FILES[@]}"; do [ -e "$c" ] && found=1; done
  [ $found -eq 1 ] || { echo "None of these paths exist in $(pwd): ${CONTEXT_FILES[*]}"; exit 64; }
  if [ "$REQUIRE_GIT" -eq 1 ] && [ ! -d .git ]; then echo "cannot run: run git init first so each task is checkpointed"; exit 1; fi
  mkdir -p "$LOG_DIR"
  common=(--model "$MODEL" --permission-mode "$PERMISSION_MODE")
  [ -n "$INIT_EFFORT" ] && common+=(--effort "$INIT_EFFORT")
  common+=(--allowedTools "${INIT_TOOLS[@]}")
  [ ${#EXTRA_CLAUDE_ARGS[@]} -gt 0 ] && common+=("${EXTRA_CLAUDE_ARGS[@]}")
  echo "Tip: a plan that already answers the scope questions gives the best table. Do the questioning upstream when you can."
  if [ $ASK -eq 1 ]; then
    [ -t 0 ] && [ -t 1 ] || { echo "-I needs a terminal. Run it from an interactive shell, or drop -I."; exit 64; }
    log_msg "planning (interactive): drafting $STATE_FILE on $MODEL, effort ${INIT_EFFORT:-default}, from ${CONTEXT_FILES[*]}"
    "$CLAUDE_BIN" "$(init_prompt)" "${common[@]}"; code=$?
  else
    log_msg "planning: drafting $STATE_FILE on $MODEL, effort ${INIT_EFFORT:-default}, from ${CONTEXT_FILES[*]}"
    if [ $VERBOSE -eq 1 ]; then timeout "$TIMEOUT" "$CLAUDE_BIN" -p "$(init_prompt)" --output-format text "${common[@]}" 2>&1 | tee -a "$LOG"; code=${PIPESTATUS[0]}
    else timeout "$TIMEOUT" "$CLAUDE_BIN" -p "$(init_prompt)" --output-format text "${common[@]}" >> "$LOG" 2>&1; code=$?; fi
  fi
  [ $code -eq 0 ] || { log_msg "planning failed (code $code). See $LOG"; exit 1; }
  [ -f "$STATE_FILE" ] || { log_msg "planning finished but $STATE_FILE was not created. See $LOG"; exit 1; }
  read -r done_n total <<< "$(task_counts)"
  st=$(state STATUS)
  if { [ "$st" != "ready" ] && [ "$st" != "blocked" ]; } || [ -z "$(state NEXT)" ] || [ "$total" -eq 0 ]; then
    log_msg "$STATE_FILE was written but is not valid (it needs STATUS ready or blocked, a NEXT id, and a task table with Id and Status columns). Edit it, or delete it and try again. See $LOG"; exit 1
  fi
  log_msg "wrote $STATE_FILE: $total tasks, first task $(state NEXT)"
  if [ "$st" = "blocked" ]; then
    nq=$(awk '/^## Open questions/{f=1;next} /^#/{f=0} f&&/^[0-9]+[.)]/{n++} END{print n+0}' "$STATE_FILE")
    echo "The model left $nq open question(s) in $STATE_FILE and set STATUS: blocked. Answer them (edit the table or the plan), then set STATUS: ready."
  fi
  echo "Review and edit $STATE_FILE now. It decides the model, effort, and order of every run."
  echo "Then preview with:  $(self_cmd) -v"
  echo "and start with:     $(self_cmd) -b"
  exit 0
fi

# ---------- --guide: an interactive Claude session that helps you choose flags and fix a setup ----------
guide_snapshot() {
  local t m="" st="" nx="" dn=0 tt=0
  echo "- claude-build version: $VERSION (script: $SCRIPT_PATH, typed as: $NAME)"
  echo "- bash: $BASH_VERSION (needs 4.4 or newer). System: $(uname -sr 2>/dev/null)"
  for t in git setsid timeout readlink stat awk sed; do command -v "$t" >/dev/null 2>&1 || m="$m $t"; done
  echo "- missing tools:${m:- none}"
  echo "- claude command ($CLAUDE_BIN): $(command -v "$CLAUDE_BIN" >/dev/null 2>&1 && echo found || echo NOT FOUND)"
  echo "- config in use: $CONFIG_USED"
  echo "- current folder: $ORIG_PWD"
  if [ -n "$PROJECT_DIR" ]; then
    echo "- project folder: $PROJECT_DIR ($([ -d .git ] && echo "a git repository" || echo "NOT a git repository"))"
    if [ -f "$STATE_FILE" ]; then
      st=$(state STATUS); nx=$(state NEXT); read -r dn tt <<< "$(task_counts)"
      echo "- state file $STATE_FILE: found. STATUS=${st:-missing} NEXT=${nx:-missing} tasks done=$dn of $tt"
      [ "$tt" -eq 0 ] && echo "  (no task table recognized: it needs a header row with Id and Status columns)"
    else echo "- state file $STATE_FILE: NOT FOUND"; fi
    echo "- plan files present: $(ls PLAN.md docs 2>/dev/null | tr '\n' ' ')"
    if [ -f "$LOG" ]; then echo "- last log lines:"; tail -n 10 "$LOG" | redact_log | sed 's/^/    /'; else echo "- log: none yet"; fi
  else echo "- project folder: NOT SET or not found (set PROJECT_DIR in the config, or pass -d FOLDER)"; fi
  echo "- fallback model: $MODEL; context files: ${CONTEXT_FILES[*]:-none}"
}
guide_prompt() {
  local dir; dir="$(dirname "$SCRIPT_PATH")"
  cat <<END_OF_GUIDE
You are the setup guide for claude-build $VERSION, a bash tool that runs a long Claude Code build from a state file. The person talking to you is having trouble getting started or choosing flags. Interview them, use the snapshot below, and give them exact commands to run.

Documentation: the manual is $dir/README.md and examples are in $dir/examples/ (config, plan, state file). Read only the sections you need. Section 1 is the quick start, section 3 explains each flag, section 4 is the state file. The built-in help follows.

Rules:
- Ask one question at a time, and start with what they want to do: set up a first build, fix an error, or change how a build runs. Do not ask for anything the snapshot already shows.
- Give the exact command to type and say what it will do. Always give the preview form first (no -r, -b, or -o). A run flag starts work that spends tokens, so say so when you suggest one.
- You cannot run claude-build for them. You can read files. Do not suggest editing files you have not read.
- If there is no state file and they have a plan, suggest: $NAME --init PLAN.md. If there is no plan, tell them to write one or use a planning step first (the README, "Where the plan comes from").
- Explain in plain language and keep answers short. Mention macOS only to say the tool currently targets Linux.

SNAPSHOT
$(guide_snapshot)

BUILT-IN HELP
$(usage)
END_OF_GUIDE
}
if [ $GUIDE -eq 1 ]; then
  [ -t 0 ] && [ -t 1 ] || { echo "--guide needs a terminal."; exit 64; }
  command -v "$CLAUDE_BIN" >/dev/null 2>&1 || { echo "The claude command ($CLAUDE_BIN) was not found, so the guide cannot start. Install and log in to Claude Code first, then read $(dirname "$SCRIPT_PATH")/README.md, section 1."; exit 1; }
  GUIDE_TEXT="$(guide_prompt)"
  gdir="$(dirname "$SCRIPT_PATH")"; g_prompt_tokens=$(( ${#GUIDE_TEXT} / 4 )); g_readme_tokens=0
  [ -f "$gdir/README.md" ] && g_readme_tokens=$(( $(wc -c < "$gdir/README.md") / 4 ))
  GUIDE_EFFORT="$EFFORT"; if [ "$EFFORT_FROM_STATE" -eq 1 ]; then for kv in "${EFFORT_DEFAULTS[@]+"${EFFORT_DEFAULTS[@]}"}"; do [ "${kv%%=*}" = "$MODEL" ] && GUIDE_EFFORT="${kv#*=}"; done; fi
  echo "$NAME --guide opens an interactive Claude session that helps you choose flags and fix your setup."
  echo "It uses tokens from your Claude plan or API account for the whole conversation. It does not start a build."
  echo
  echo "  model:               $MODEL, effort ${GUIDE_EFFORT:-default}   (change with -m and -e)"
  echo "  starting size:       about $g_prompt_tokens tokens (the instructions, your setup details, and the help text)"
  [ $g_readme_tokens -gt 0 ] && echo "  if it reads the README: about $g_readme_tokens more tokens ($(( g_prompt_tokens + g_readme_tokens )) in all)"
  echo "  as you talk:         every question and answer adds to the conversation, and the conversation is sent again on each turn"
  echo "  estimates only:      characters divided by 4. Inside the session, type /cost for real usage and /context for the size"
  echo
  read -r -p "Continue? [y/N] " ans
  case "$ans" in y|Y|yes|YES) ;; *) echo "Not started. Nothing was used."; exit 0 ;; esac
  gcmd=("$GUIDE_TEXT" --model "$MODEL")
  [ -n "$GUIDE_EFFORT" ] && gcmd+=(--effort "$GUIDE_EFFORT")
  gcmd+=(--add-dir "$gdir" --allowedTools Read Glob Grep)
  exec "$CLAUDE_BIN" "${gcmd[@]}"
fi

# ---------- -k: stop the background build ----------
if [ $STOPIT -eq 1 ]; then
  if alive "$LOCK" claude-build; then
    pid=$(cat "$LOCK"); echo "stopping the build loop (pid $pid)"
    pkill -TERM -P "$pid" 2>/dev/null; kill -TERM "$pid" 2>/dev/null
    for _ in $(seq 1 20); do kill -0 "$pid" 2>/dev/null || break; sleep 0.5; done
    kill -0 "$pid" 2>/dev/null && kill -KILL "$pid" 2>/dev/null
    echo "stopped. Any task in progress stays todo and repeats on the next run."
  else echo "Nothing is running for $PROJECT_NAME."; fi
  exit 0
fi

# ---------- state report: shown by -s, and by -v (verbose) at the start of a preview or run ----------
show_state() {
  local done_n total next status reason nrow rd i t
  read -r done_n total <<< "$(task_counts)"; next=$(state NEXT); status=$(state STATUS); reason=$(state BLOCKED_REASON)
  echo "$PROJECT_NAME build"
  if alive "$LOCK" claude-build; then echo "  build loop: running (pid $(cat "$LOCK"))"; else echo "  build loop: not running"; fi
  echo "  status:     ${status:-unknown}${reason:+ ($reason)}"
  if [ -f "$BACKOFF" ] && [ "$(date +%s)" -lt "$(cat "$BACKOFF")" ]; then echo "  waiting:    until $(date -d @"$(cat "$BACKOFF")" '+%H:%M') after a failed run"; fi
  nrow=$(state_table | awk -F'|' -v id="$next" 'function trim(s){gsub(/^[ \t]+|[ \t]+$/,"",s);return s} /^\|[ \t]*Id[ \t]*\|/{for(i=2;i<NF;i++)if(tolower(trim($i))=="task")tc=i;h=1;next} h&&trim($2)==id{print trim($tc);exit}' | show_cell)
  echo "  next:       ${next:--}${nrow:+  $nrow}"
  plan_run "$next"; echo "  next run:   on $RUN_MODEL, effort ${RUN_EFFORT:-default}"
  echo "  tasks:      $done_n of $total done"
  table_warnings | sed 's/^/  /'
  rd=$(recent_done 5); if [ -n "$rd" ]; then echo "  recent:"; while IFS='|' read -r i t; do echo "    $i  $t"; done <<< "$rd"; fi
  echo; echo "log, last 15 lines ($(proj_path "$LOG")):"
  if [ -f "$LOG" ]; then tail -n 15 "$LOG" | redact_log | sed 's/^/  /'; else echo "  no log yet"; fi
  echo; echo "follow it live: tail -f $(proj_path "$LOG")"
}
# -s: print the report and exit.
if [ $VIEW -eq 1 ]; then show_state; exit 0; fi

# ---------- preview (flags without -r, -b, or -o) ----------
if [ $RUN -eq 0 ] && [ $ONCE -eq 0 ] && [ $BACKGROUND -eq 0 ]; then
  if [ $VERBOSE -eq 1 ]; then show_state; echo; fi
  echo "PREVIEW ONLY. Nothing was started."; echo "config:    $CONFIG_USED"; echo "project:   $(pwd)"; echo "state:     $STATE_FILE   ($(task_counts) done/total)"
  table_warnings
  plan_run "$(state NEXT)"
  echo "settings:  mode=$PERMISSION_MODE tasks/run=$TASKS_PER_RUN timeout=$TIMEOUT interval=${INTERVAL}s after-run=${AFTER_RUN}s"
  echo "model:     $([ "$MODEL_FROM_STATE" -eq 1 ] && echo "from each task's Model column, fallback $MODEL" || echo "$MODEL for every run (fixed)")"
  echo "effort:    $([ "$EFFORT_FROM_STATE" -eq 1 ] && echo "from each task's Effort column, else by model ($(echo "${EFFORT_DEFAULTS[*]}"))" || echo "${EFFORT:-Claude Code default} for every run (fixed)")"
  echo "next run:  task $(state NEXT) on $RUN_MODEL, effort ${RUN_EFFORT:-default}"
  echo "context:   ${CONTEXT_FILES[*]:-none}"
  for c in "${CONTEXT_FILES[@]+"${CONTEXT_FILES[@]}"}"; do [ -e "$c" ] || echo "  warning: context path not found: $c"; done
  echo "allowed:   ${ALLOWED_TOOLS[*]}"; echo "prompt:"; build_prompt | fold -s -w 100 | sed 's/^/  /'; echo
  echo "To start: add -r (run in this terminal), -b (run in the background), or -o (one cycle)."
  echo "To see the last state and the log tail without running anything: -s.  For a verbose run: -v -r"
  exit 0
fi

# ---------- -b: restart the loop in a detached session, then return ----------
if [ $BACKGROUND -eq 1 ]; then
  if [ "$REQUIRE_GIT" -eq 1 ] && [ ! -d .git ]; then echo "cannot run: run git init first so each task is checkpointed"; exit 1; fi
  mkdir -p "$LOG_DIR"
  if alive "$LOCK" claude-build; then echo "Already running (pid $(cat "$LOCK")). Stop it with -k, or look at it with -s."; exit 0; fi
  if [ $VERBOSE -eq 1 ]; then show_state; echo; fi
  pass=(); for a in "${ORIG_ARGS[@]+"${ORIG_ARGS[@]}"}"; do case "$a" in -b|--background|-v|--view) ;; *) pass+=("$a") ;; esac; done
  setsid -f "$SCRIPT_PATH" "${pass[@]+"${pass[@]}"}" -r >> "$LOG_DIR/supervisor.log" 2>&1 < /dev/null
  sleep 2
  if alive "$LOCK" claude-build; then
    echo "Started in the background (pid $(cat "$LOCK")) for $PROJECT_NAME in $(pwd)"
    echo "  watch:  tail -f $(proj_path "$LOG_DIR")/supervisor.log"
    echo "  state:  $(self_cmd) -s"
    echo "  stop:   $(self_cmd) -k"
  else echo "It did not stay running. See $(proj_path "$LOG_DIR")/supervisor.log"; exit 1; fi
  exit 0
fi

# ---------- run: one copy at a time ----------
# The report comes first, so it shows the state before this run takes the lock.
if [ $VERBOSE -eq 1 ]; then show_state; echo; fi
mkdir -p "$LOG_DIR"
if alive "$LOCK" claude-build; then echo "already running (pid $(cat "$LOCK"))"; exit 0; fi
echo $$ > "$LOCK"
cleanup() { rm -f "$LOCK"; log_msg "stopped"; }
trap cleanup EXIT
trap 'exit 130' INT TERM
rm -f "$STOP"

# One bounded model run. Returns 0 if it finished, 1 if the build cannot start, anything else if it failed.
resume_build() {
  if [ "$REQUIRE_GIT" -eq 1 ] && [ ! -d .git ]; then log_msg "cannot run: run git init first so each task is checkpointed"; return 1; fi
  local -a cmd=(); while IFS= read -r -d '' a; do cmd+=("$a"); done < <(claude_args)
  local code
  if [ $VERBOSE -eq 1 ]; then   # verbose: show the model's output live as well as logging it
    timeout "$TIMEOUT" "$CLAUDE_BIN" "${cmd[@]}" 2>&1 | tee -a "$LOG"; code=${PIPESTATUS[0]}
  else
    timeout "$TIMEOUT" "$CLAUDE_BIN" "${cmd[@]}" >> "$LOG" 2>&1; code=$?
  fi
  if [ $code -ne 0 ]; then
    local n=$(( $(cat "$FAILS" 2>/dev/null || echo 0) + 1 )) idx wait
    echo $n > "$FAILS"; idx=$(( n-1 )); [ $idx -ge ${#BACKOFF_STEPS[@]} ] && idx=$(( ${#BACKOFF_STEPS[@]} - 1 ))
    wait=${BACKOFF_STEPS[$idx]}
    echo $(( $(date +%s) + wait )) > "$BACKOFF"
    log_msg "run failed (code $code). Backing off $(( wait/60 )) min"
    return $code
  fi
  rm -f "$FAILS" "$BACKOFF"; log_msg "run finished"; return 0
}

log_msg "started ($PROJECT_NAME in $(pwd)). Checking every $(( INTERVAL/60 )) min. See progress: tail -f $(proj_path "$LOG")   or   $(self_cmd) -s"
log_msg "stop with Ctrl+C, $(self_cmd) -k, or: touch $(proj_path "$STOP")"
NO_PROGRESS=0
while true; do
  [ -f "$STOP" ] && { log_msg "stop file found"; exit 0; }
  status=$(state STATUS); next=$(state NEXT); read -r done_n total <<< "$(task_counts)"
  case "$status" in
    done)    log_msg "build complete ($done_n/$total tasks)"; exit 0 ;;
    blocked) log_msg "BLOCKED: $(state BLOCKED_REASON). Fix it, then set STATUS: ready"; exit 2 ;;
    gate)    log_msg "at a gate ($done_n/$total done). Review, then set STATUS: ready"; exit 3 ;;
    ready)   ;;
    *)       log_msg "unknown STATUS '$status' in $STATE_FILE"; exit 64 ;;
  esac
  if [ -f "$BACKOFF" ] && [ "$(date +%s)" -lt "$(cat "$BACKOFF")" ]; then
    log_msg "waiting until $(date -d @"$(cat "$BACKOFF")" '+%H:%M') after a failed run ($done_n/$total done, next $next)"
  else
    plan_run "$next"
    log_msg "running: next task $next on $RUN_MODEL, effort ${RUN_EFFORT:-default} ($done_n/$total done)"
    resume_build; rc=$?
    [ $rc -eq 1 ] && exit 1
    if [ $rc -eq 0 ]; then
      # A run that exits cleanly but finishes no task would repeat forever and burn tokens. Stop after two.
      read -r done_after total_after <<< "$(task_counts)"
      if [ "$done_after" = "$done_n" ] && [ "$(state NEXT)" = "$next" ] && [ "$(state STATUS)" = "ready" ]; then
        NO_PROGRESS=$(( NO_PROGRESS + 1 ))
        log_msg "no task finished in that run ($NO_PROGRESS of 2 allowed)"
        if [ $NO_PROGRESS -ge 2 ]; then
          reason="Two runs finished without completing a task. See $LOG."; reason=${reason//\\/\\\\}; reason=${reason//&/\\&}; reason=${reason//|/\\|}
          sed -i "s|^STATUS:.*|STATUS: blocked|; s|^BLOCKED_REASON:.*|BLOCKED_REASON: $reason|" "$STATE_FILE"
          log_msg "BLOCKED: two runs made no progress. See $LOG"; exit 2
        fi
      else NO_PROGRESS=0; fi
      [ "$ONCE" -eq 0 ] && { sleep "$AFTER_RUN" & wait $!; continue; }
    fi
  fi
  [ "$ONCE" -eq 1 ] && exit 0
  sleep "$INTERVAL" & wait $!
done
