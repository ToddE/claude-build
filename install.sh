#!/usr/bin/env bash
# install.sh: install claude-build into ~/.local/bin.
#   curl -fsSL https://raw.githubusercontent.com/ToddE/claude-build/main/install.sh | bash
#   wget -qO- https://raw.githubusercontent.com/ToddE/claude-build/main/install.sh | bash
# Options (environment variables):
#   CLAUDE_BUILD_VERSION  a release tag such as v0.1.0, or "main". Default: the latest release, else main
#   BIN_DIR               where the claude-build link goes. Default: ~/.local/bin
#   SHARE_DIR             where the files go. Default: ~/.local/share/claude-build
# Running it again upgrades. An existing claude-build.conf is never touched.
set -eu

REPO="ToddE/claude-build"
BIN_DIR="${BIN_DIR:-$HOME/.local/bin}"
SHARE_DIR="${SHARE_DIR:-$HOME/.local/share/claude-build}"
REF="${CLAUDE_BUILD_VERSION:-}"

say() { printf 'install: %s\n' "$*"; }
die() { printf 'install: %s\n' "$*" >&2; exit 1; }

# fetch URL to stdout, with curl or wget
get() {
  if command -v curl >/dev/null 2>&1; then curl -fsSL "$1"
  elif command -v wget >/dev/null 2>&1; then wget -qO- "$1"
  else die "need curl or wget"; fi
}

# Requirements. Missing tools are listed, not fatal, except bash.
(( BASH_VERSINFO[0] > 4 || (BASH_VERSINFO[0] == 4 && BASH_VERSINFO[1] >= 4) )) || die "bash 4.4 or newer is required (found $BASH_VERSION)"
missing=""
for t in git setsid timeout readlink stat awk sed; do command -v "$t" >/dev/null 2>&1 || missing="$missing $t"; done
[ -n "$missing" ] && say "warning: missing tools:$missing"
command -v claude >/dev/null 2>&1 || say "warning: the claude command was not found on PATH. Install Claude Code before running a build"

# Pick a version: the latest release tag, else main.
if [ -z "$REF" ]; then
  REF="$(get "https://api.github.com/repos/$REPO/releases/latest" 2>/dev/null | sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p' | head -n 1 || true)"
  [ -n "$REF" ] || { REF="main"; say "no release found, using main"; }
fi

DEST="$SHARE_DIR/$REF"
RAW="https://raw.githubusercontent.com/$REPO/$REF"
mkdir -p "$DEST" "$BIN_DIR"

say "downloading $REF"
get "$RAW/claude-build.sh" > "$DEST/claude-build.sh.tmp" || die "download failed: $RAW/claude-build.sh"
head -n 1 "$DEST/claude-build.sh.tmp" | grep -q '^#!.*bash' || die "downloaded file is not the script"
bash -n "$DEST/claude-build.sh.tmp" || die "downloaded script has a syntax error"
mv "$DEST/claude-build.sh.tmp" "$DEST/claude-build.sh"
chmod +x "$DEST/claude-build.sh"
get "$RAW/claude-build.conf.example" > "$DEST/claude-build.conf.example" 2>/dev/null || say "warning: could not fetch claude-build.conf.example"
get "$RAW/README.md" > "$DEST/README.md" 2>/dev/null || true

# Point the command at this version. The script finds its config beside the real file,
# so keep one config for all versions in SHARE_DIR and link it in.
ln -sfn "$DEST/claude-build.sh" "$BIN_DIR/claude-build"
if [ -f "$SHARE_DIR/claude-build.conf" ]; then ln -sfn "$SHARE_DIR/claude-build.conf" "$DEST/claude-build.conf"; fi

say "installed $("$BIN_DIR/claude-build" --version 2>/dev/null || echo "$REF") at $BIN_DIR/claude-build"
case ":$PATH:" in *":$BIN_DIR:"*) ;; *) say "add $BIN_DIR to your PATH, for example: export PATH=\"$BIN_DIR:\$PATH\"" ;; esac
say "next: run claude-build with no arguments for the help. A template config is at $DEST/claude-build.conf.example"
