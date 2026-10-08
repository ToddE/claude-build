# TODO

## macOS support

The script targets Linux. On macOS it needs work before it can be called supported.

- [ ] macOS ships bash 3.2. The script needs 4.4+. Decide whether to require Homebrew bash or remove the bash 4 features.
- [ ] GNU-only commands in `claude-build.sh`: `stat -c`, `date -d`, `readlink -f`, `setsid`, `timeout`. Homebrew installs the GNU versions with a `g` prefix (`gstat`, `gdate`, `greadlink`, `gtimeout`) unless its `gnubin` directory is on `PATH`.
- [ ] `/proc/PID/cmdline` is used to check that a pid is ours (`alive`). macOS has no `/proc`. Use `ps -p PID -o command=`.
- [ ] Choose an approach: Linux only for v0.1.0, documented `gnubin` steps, or shims that detect GNU or BSD tools.
- [ ] Test on a Mac, then fix the macOS notes in the README requirements table.
- [ ] Check `install.sh` on macOS (`curl`, `sed`, `head`).
