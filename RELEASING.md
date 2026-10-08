# Releasing claude-build

The version lives in one place: `VERSION="x.y.z"` near the top of `claude-build.sh`. Do not edit it by hand. The release script changes it and tags the commit, so the tag and the script always agree.

## Steps

1. Commit everything you want in the release on `main`. The working tree must be clean.
2. Run the release script with the kind of change:
   ```
   scripts/release.sh patch      0.1.0 -> 0.1.1   fixes
   scripts/release.sh minor      0.1.0 -> 0.2.0   new flags or behavior
   scripts/release.sh major      0.1.0 -> 1.0.0   breaking changes
   scripts/release.sh 0.4.0      an exact version
   ```
   It raises `VERSION`, runs `bash -n`, commits "Release vX.Y.Z", and tags `vX.Y.Z`. It does not push.
3. Publish:
   ```
   git push origin main && git push origin vX.Y.Z
   ```
4. GitHub Actions (`.github/workflows/release.yml`) checks that the tag equals `VERSION`, runs the syntax checks, and creates the release with `claude-build.sh`, `install.sh`, and `SHA256SUMS` attached and generated notes.

If the check fails because the tag and `VERSION` differ, delete the tag (`git push origin :refs/tags/vX.Y.Z` and `git tag -d vX.Y.Z`) and use `scripts/release.sh` instead of tagging by hand.

## Why the version matters

`claude-build --check-update` and `--update` compare `VERSION` to the latest release tag. If they differ, installed copies keep reporting an update. The installer names its folder after the tag.
