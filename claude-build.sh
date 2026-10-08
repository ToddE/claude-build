#!/usr/bin/env bash
# claude-build.sh: keep a Claude Code build going until it is done, blocked, or at a gate.
# Run it with no arguments for the full help. With flags but no -r, -b, or -o it only previews.
# Pure bash. Progress goes to the terminal and to a log file. Settings: defaults below,
# then claude-build.conf, then command-line flags. See README_claude-build.md in this folder.
set -u

# Where this script really lives (symlinks followed) and where the command was typed.
# Nothing here assumes the command is run from the project folder.
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
ONCE=0; RUN=0; VIEW=0; BACKGROUND=0; STOPIT=0
ORIG_ARGS=("$@")

usage() {
cat <<END_OF_HELP
$NAME: keep a Claude Code build going until it is done, blocked, or at a gate

MODES
  no arguments        this help
  any flags, no -r/-b/-o  PREVIEW: shows the project, settings, and the exact prompt, and starts nothing
  -v                  view: print the last state and the end of the log (works after the build ended)
  -r                  run in this terminal until the build ends or you press Ctrl+C
  -b                  run in the background, then return to the terminal
  -o                  run one cycle, then exit (for cron or a timer)
  -k                  stop the background build
  NOTE: Nothing is ever started unless you pass -r, -b, or -o.

WHAT IT DOES
  Reads a state file, and while the status is "ready" runs one bounded Claude Code
  session ("claude -p") that does the next few tasks, updates the state file, and
  commits. Then it sleeps and checks again. Sleeping and checking use no model.
  Each run starts with a fresh, small context, so a usage limit or crash costs at
  most one task. After a failed run it waits 1, 2, 4, then 6 hours (BACKOFF_STEPS).
  A run that finishes no task is counted, and the build stops after two of them.

USAGE
  $NAME -r [flags]       run in this terminal
  $NAME -b [flags]       run in the background, then return to the terminal
  $NAME -o [flags]       one cycle, then exit
  $NAME -v [flags]       show the last state and the log tail
  $NAME -k [flags]       stop the background build
  $NAME [flags]          preview only (flags without -r, -b, or -o)
  $NAME -h               this text (also shown when run with no arguments)
  Every flag has a long form too: -r is --run, -o is --once, and so on (see FLAGS).

EXAMPLES
  $NAME -c blog.conf             preview using blog.conf
  $NAME -m opus -t 1             preview a change of model and task count
  $NAME -r                       run in this terminal. Progress is printed and logged
  $NAME -b                       run in the background (no & or nohup needed)
  $NAME -v                       state and log tail, even after the build ended
  $NAME -k                       stop the background build
  */30 * * * * $SCRIPT_PATH -o                  (cron)
  $NAME -r -m opus -t 2 -i docs/spec.md -i docs/api/         force opus for every run

FLAGS  (a flag overrides the config file, which overrides the built-in default)
  -r, --run                  run the loop in this terminal
  -b, --background           run the loop in the background and return to the terminal
  -o, --once                 one cycle, then exit
  -v, --view                 print the last state and the log tail. Starts no build
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

PROMPT PLACEHOLDERS
  {state_file}   the state file name
  {tasks_per_run}  how many tasks to do per run
  {context}      a sentence listing the --context paths (empty if none)
  {model} {effort}  the model and effort chosen for this run
  {model_rule}   tells the run to stop before a task that needs a different model
                 (added automatically at the end if your prompt does not use it)

MODEL AND EFFORT PER TASK
  With MODEL_FROM_STATE=1 (the default) the script reads the Model column of the NEXT task
  in the state file and starts the run with that model. Consecutive tasks with the same
  model share a run. When the next task names a different model the run ends and the
  script starts a new one. Effort works the same way from an Effort column, else by
  model (EFFORT_DEFAULTS). A task with no Model cell uses MODEL. -m or -e force one value
  for every run. No model orchestrates: the script chooses.

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
  (and supervisor.log for -b). Follow it with tail -f, or print the state with -v.

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
  if [ "$(stat -c %u "$CONFIG")" != "$(id -u)" ] || [ $(( 0$(stat -c %a "$CONFIG") & 002 )) -ne 0 ]; then
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
    -v|--view) VIEW=1; shift ;;
    -b|--background) BACKGROUND=1; shift ;;
    -k|--stop) STOPIT=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "unknown option: $1 (try -h)"; exit 64 ;;
  esac
done

# ---------- find and enter the project ----------
if [ -z "$PROJECT_DIR" ]; then
  if [ -d "$(dirname "$SCRIPT_PATH")/../.git" ]; then PROJECT_DIR="$(readlink -f "$(dirname "$SCRIPT_PATH")/..")"
  else echo "No project folder. Set PROJECT_DIR in a claude-build.conf (in the current folder or beside the script), or pass -d FOLDER. Not guessing from the current folder."; exit 64; fi
fi
[ -d "$PROJECT_DIR" ] || { echo "project folder not found: $PROJECT_DIR"; exit 64; }
cd "$PROJECT_DIR" || exit 64
[ -f "$STATE_FILE" ] || { echo "state file not found: $STATE_FILE (looked in $(pwd)). It needs STATUS, NEXT, and a task table. See README_claude-build.md, section 4."; exit 64; }
LOG="$LOG_DIR/build.log"; LOCK="$LOG_DIR/build.lock"; BACKOFF="$LOG_DIR/backoff_until"; FAILS="$LOG_DIR/failures"; STOP="$LOG_DIR/stop"

proj_path() { case "$1" in /*) printf %s "$1" ;; *) printf %s "$PWD/$1" ;; esac; }   # absolute path for a project-relative one
stamp() { date '+%H:%M:%S'; }
say()   { echo "[$(stamp)] $*"; mkdir -p "$LOG_DIR"; echo "$(date -Is) $*" >> "$LOG"; }
state() { grep -m1 "^$1:" "$STATE_FILE" | sed "s/^$1: *//"; }
self_cmd() { local c="$SCRIPT_PATH"; [ "$(readlink -f "$(command -v "$NAME" 2>/dev/null)" 2>/dev/null)" = "$SCRIPT_PATH" ] && c="$NAME"; echo "$c$([ "$CONFIG_USED" != "none found" ] && echo " -c $CONFIG_USED")"; }   # how to call this script again with the same config
# Is the process in pid file $1 running AND really ours? $2 is text its command line must contain.
# Checking the command line stops a reused pid (after a reboot or crash) from being mistaken for ours or signalled by -k.
alive() { local pid; [ -f "$1" ] && pid=$(cat "$1") && [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null && tr '\0' ' ' < "/proc/$pid/cmdline" 2>/dev/null | grep -q -- "$2"; }

# Counts rows of the task table in the state file: prints "done total". The table needs a header with Id and Status columns.
task_counts() {
  awk -F'|' '
    function trim(s){gsub(/^[ \t]+|[ \t]+$/,"",s);return s}
    !hdr && /^\|[ \t]*Id[ \t]*\|/ { for(i=2;i<NF;i++) if (tolower(trim($i))=="status") sc=i; hdr=1; next }
    hdr && /^\|[ \t:-]+\|/ && !seen { seen=1; next }
    hdr && /^\|/ { if (trim($2)!="") { t++; if (tolower(trim($sc))=="done") d++ } next }
    hdr && !/^\|/ { exit }
    END { printf "%d %d", d+0, t+0 }' "$STATE_FILE"
}
# Prints one cell of the task row whose Id is $1, from the column named $2 (empty if the column or row is missing).
task_cell() {
  awk -F'|' -v id="$1" -v col="$2" '
    function trim(s){gsub(/^[ \t]+|[ \t]+$/,"",s);return s}
    !h && /^\|[ \t]*Id[ \t]*\|/ { for(i=2;i<NF;i++) if (tolower(trim($i))==tolower(col)) c=i; h=1; next }
    h && c && trim($2)==id { print trim($c); exit }' "$STATE_FILE"
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
    e=$(task_cell "$id" Effort | tr 'A-Z' 'a-z' | tr -d '*' | sed 's/[ ,(].*//')
    if [ -z "$e" ]; then for kv in "${EFFORT_DEFAULTS[@]+"${EFFORT_DEFAULTS[@]}"}"; do [ "${kv%%=*}" = "$RUN_MODEL" ] && e="${kv#*=}"; done; fi
    [ -n "$e" ] && RUN_EFFORT="$e"
  fi
}
# Prints "id|task" for the n most recently finished tasks (last rows marked done), newest first.
recent_done() {
  awk -F'|' -v n="$1" '
    function trim(s){gsub(/^[ \t]+|[ \t]+$/,"",s);return s}
    !hdr && /^\|[ \t]*Id[ \t]*\|/ { for(i=2;i<NF;i++){c=tolower(trim($i)); if(c=="status")sc=i; if(c=="task")tc=i}; hdr=1; next }
    hdr && /^\|[ \t:-]+\|/ && !seen { seen=1; next }
    hdr && /^\|/ { if (tolower(trim($sc))=="done") { k++; id[k]=trim($2); tk[k]=trim($tc) } next }
    hdr && !/^\|/ { exit }
    END { for (i=k; i>0 && i>k-n; i--) printf "%s|%s\n", id[i], tk[i] }' "$STATE_FILE"
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

# ---------- -v: print the last state and the end of the log ----------
if [ $VIEW -eq 1 ]; then
  read -r done_n total <<< "$(task_counts)"; next=$(state NEXT); status=$(state STATUS); reason=$(state BLOCKED_REASON)
  echo "$PROJECT_NAME build"
  if alive "$LOCK" claude-build; then echo "  build loop: running (pid $(cat "$LOCK"))"; else echo "  build loop: not running"; fi
  echo "  status:     ${status:-unknown}${reason:+ ($reason)}"
  if [ -f "$BACKOFF" ] && [ "$(date +%s)" -lt "$(cat "$BACKOFF")" ]; then echo "  waiting:    until $(date -d @"$(cat "$BACKOFF")" '+%H:%M') after a failed run"; fi
  nrow=$(awk -F'|' -v id="$next" 'function trim(s){gsub(/^[ \t]+|[ \t]+$/,"",s);return s} /^\|[ \t]*Id[ \t]*\|/{for(i=2;i<NF;i++)if(tolower(trim($i))=="task")tc=i;h=1;next} h&&trim($2)==id{print trim($tc);exit}' "$STATE_FILE")
  echo "  next:       ${next:--}${nrow:+  $nrow}"
  echo "  tasks:      $done_n of $total done"
  rd=$(recent_done 5); if [ -n "$rd" ]; then echo "  recent:"; while IFS='|' read -r i t; do echo "    $i  $t"; done <<< "$rd"; fi
  echo; echo "log, last 15 lines ($(proj_path "$LOG")):"
  if [ -f "$LOG" ]; then tail -n 15 "$LOG" | redact_log | sed 's/^/  /'; else echo "  no log yet"; fi
  echo; echo "follow it live: tail -f $(proj_path "$LOG")"
  exit 0
fi

# ---------- preview (flags without -r, -b, or -o) ----------
if [ $RUN -eq 0 ] && [ $ONCE -eq 0 ] && [ $BACKGROUND -eq 0 ]; then
  echo "PREVIEW ONLY. Nothing was started."; echo "config:    $CONFIG_USED"; echo "project:   $(pwd)"; echo "state:     $STATE_FILE   ($(task_counts) done/total)"
  plan_run "$(state NEXT)"
  echo "settings:  mode=$PERMISSION_MODE tasks/run=$TASKS_PER_RUN timeout=$TIMEOUT interval=${INTERVAL}s after-run=${AFTER_RUN}s"
  echo "model:     $([ "$MODEL_FROM_STATE" -eq 1 ] && echo "from each task's Model column, fallback $MODEL" || echo "$MODEL for every run (fixed)")"
  echo "effort:    $([ "$EFFORT_FROM_STATE" -eq 1 ] && echo "from each task's Effort column, else by model ($(echo "${EFFORT_DEFAULTS[*]}"))" || echo "${EFFORT:-Claude Code default} for every run (fixed)")"
  echo "next run:  task $(state NEXT) on $RUN_MODEL, effort ${RUN_EFFORT:-default}"
  echo "context:   ${CONTEXT_FILES[*]:-none}"
  for c in "${CONTEXT_FILES[@]+"${CONTEXT_FILES[@]}"}"; do [ -e "$c" ] || echo "  warning: context path not found: $c"; done
  echo "allowed:   ${ALLOWED_TOOLS[*]}"; echo "prompt:"; build_prompt | fold -s -w 100 | sed 's/^/  /'; echo
  echo "To start: add -r (run in this terminal), -b (run in the background), or -o (one cycle)."
  echo "To see the last state and the log tail without running anything: -v"
  exit 0
fi

# ---------- -b: start the loop again in a detached session, then return ----------
if [ $BACKGROUND -eq 1 ]; then
  if [ "$REQUIRE_GIT" -eq 1 ] && [ ! -d .git ]; then echo "cannot run: run git init first so each task is checkpointed"; exit 1; fi
  mkdir -p "$LOG_DIR"
  if alive "$LOCK" claude-build; then echo "Already running (pid $(cat "$LOCK")). Stop it with -k, or look at it with -v."; exit 0; fi
  pass=(); for a in "${ORIG_ARGS[@]+"${ORIG_ARGS[@]}"}"; do case "$a" in -b|--background) ;; *) pass+=("$a") ;; esac; done
  setsid -f "$SCRIPT_PATH" "${pass[@]+"${pass[@]}"}" -r >> "$LOG_DIR/supervisor.log" 2>&1 < /dev/null
  sleep 2
  if alive "$LOCK" claude-build; then
    echo "Started in the background (pid $(cat "$LOCK")) for $PROJECT_NAME in $(pwd)"
    echo "  watch:  tail -f $(proj_path "$LOG_DIR")/supervisor.log"
    echo "  state:  $(self_cmd) -v"
    echo "  stop:   $(self_cmd) -k"
  else echo "It did not stay running. See $(proj_path "$LOG_DIR")/supervisor.log"; exit 1; fi
  exit 0
fi

# ---------- run: one copy at a time ----------
mkdir -p "$LOG_DIR"
if alive "$LOCK" claude-build; then echo "already running (pid $(cat "$LOCK"))"; exit 0; fi
echo $$ > "$LOCK"
cleanup() { rm -f "$LOCK"; say "stopped"; }
trap cleanup EXIT
trap 'exit 130' INT TERM
rm -f "$STOP"

# One bounded model run. Returns 0 if it finished, 1 if the build cannot start, anything else if it failed.
resume_build() {
  if [ "$REQUIRE_GIT" -eq 1 ] && [ ! -d .git ]; then say "cannot run: run git init first so each task is checkpointed"; return 1; fi
  local -a cmd=(); while IFS= read -r -d '' a; do cmd+=("$a"); done < <(claude_args)
  timeout "$TIMEOUT" "$CLAUDE_BIN" "${cmd[@]}" >> "$LOG" 2>&1
  local code=$?
  if [ $code -ne 0 ]; then
    local n=$(( $(cat "$FAILS" 2>/dev/null || echo 0) + 1 )) idx wait
    echo $n > "$FAILS"; idx=$(( n-1 )); [ $idx -ge ${#BACKOFF_STEPS[@]} ] && idx=$(( ${#BACKOFF_STEPS[@]} - 1 ))
    wait=${BACKOFF_STEPS[$idx]}
    echo $(( $(date +%s) + wait )) > "$BACKOFF"
    say "run failed (code $code). Backing off $(( wait/60 )) min"
    return $code
  fi
  rm -f "$FAILS" "$BACKOFF"; say "run finished"; return 0
}

say "started ($PROJECT_NAME in $(pwd)). Checking every $(( INTERVAL/60 )) min. See progress: tail -f $(proj_path "$LOG")   or   $(self_cmd) -v"
say "stop with Ctrl+C, $(self_cmd) -k, or: touch $(proj_path "$STOP")"
NO_PROGRESS=0
while true; do
  [ -f "$STOP" ] && { say "stop file found"; exit 0; }
  status=$(state STATUS); next=$(state NEXT); read -r done_n total <<< "$(task_counts)"
  case "$status" in
    done)    say "build complete ($done_n/$total tasks)"; exit 0 ;;
    blocked) say "BLOCKED: $(state BLOCKED_REASON). Fix it, then set STATUS: ready"; exit 2 ;;
    gate)    say "at a gate ($done_n/$total done). Review, then set STATUS: ready"; exit 3 ;;
    ready)   ;;
    *)       say "unknown STATUS '$status' in $STATE_FILE"; exit 64 ;;
  esac
  if [ -f "$BACKOFF" ] && [ "$(date +%s)" -lt "$(cat "$BACKOFF")" ]; then
    say "waiting until $(date -d @"$(cat "$BACKOFF")" '+%H:%M') after a failed run ($done_n/$total done, next $next)"
  else
    plan_run "$next"
    say "running: next task $next on $RUN_MODEL, effort ${RUN_EFFORT:-default} ($done_n/$total done)"
    resume_build; rc=$?
    [ $rc -eq 1 ] && exit 1
    if [ $rc -eq 0 ]; then
      # A run that exits cleanly but finishes no task would repeat forever and burn tokens. Stop after two.
      read -r done_after total_after <<< "$(task_counts)"
      if [ "$done_after" = "$done_n" ] && [ "$(state NEXT)" = "$next" ] && [ "$(state STATUS)" = "ready" ]; then
        NO_PROGRESS=$(( NO_PROGRESS + 1 ))
        say "no task finished in that run ($NO_PROGRESS of 2 allowed)"
        if [ $NO_PROGRESS -ge 2 ]; then
          reason="Two runs finished without completing a task. See $LOG."; reason=${reason//\\/\\\\}; reason=${reason//&/\\&}; reason=${reason//|/\\|}
          sed -i "s|^STATUS:.*|STATUS: blocked|; s|^BLOCKED_REASON:.*|BLOCKED_REASON: $reason|" "$STATE_FILE"
          say "BLOCKED: two runs made no progress. See $LOG"; exit 2
        fi
      else NO_PROGRESS=0; fi
      [ "$ONCE" -eq 0 ] && { sleep "$AFTER_RUN" & wait $!; continue; }
    fi
  fi
  [ "$ONCE" -eq 1 ] && exit 0
  sleep "$INTERVAL" & wait $!
done
