#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# Copyright 2026 A. Todd Emerson. See LICENSE and NOTICE.
# scripts/release.sh: bump VERSION in claude-build.sh, commit, and tag. Does not push.
#   scripts/release.sh patch|minor|major     raise one part of the current version
#   scripts/release.sh 1.2.3                 set an exact version
set -eu

cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/.."
SCRIPT="claude-build.sh"
die() { echo "release: $*" >&2; exit 1; }

[ $# -eq 1 ] || die "usage: scripts/release.sh patch|minor|major|X.Y.Z"
[ -z "$(git status --porcelain)" ] || die "the working tree has uncommitted changes. Commit or stash them first"
[ "$(git rev-parse --abbrev-ref HEAD)" = "main" ] || die "release from the main branch"

current="$(sed -n 's/^VERSION="\([0-9][0-9.]*\)".*/\1/p' "$SCRIPT" | head -n 1)"
[[ "$current" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || die "could not read VERSION from $SCRIPT"
IFS=. read -r ma mi pa <<< "$current"
case "$1" in
  patch) new="$ma.$mi.$((pa+1))" ;;
  minor) new="$ma.$((mi+1)).0" ;;
  major) new="$((ma+1)).0.0" ;;
  *) new="$1" ;;
esac
[[ "$new" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || die "version must look like 1.2.3 (got $new)"
[ "$(printf '%s\n%s\n' "$current" "$new" | sort -V | tail -n 1)" = "$new" ] && [ "$new" != "$current" ] || die "$new is not newer than $current"
git rev-parse "v$new" >/dev/null 2>&1 && die "tag v$new already exists"

sed -i "s/^VERSION=\"$current\"/VERSION=\"$new\"/" "$SCRIPT"
bash -n "$SCRIPT" && bash -n install.sh || { git checkout -- "$SCRIPT"; die "syntax check failed"; }
[ "$(sed -n 's/^VERSION="\([0-9.]*\)".*/\1/p' "$SCRIPT" | head -n 1)" = "$new" ] || { git checkout -- "$SCRIPT"; die "version edit failed"; }

git add "$SCRIPT"
git commit -q -m "Release v$new"
git tag -a "v$new" -m "claude-build $new"
echo "Released $current -> $new locally (commit and tag v$new)."
echo "Publish it with:  git push origin main && git push origin v$new"
