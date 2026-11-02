#!/usr/bin/env bash
# Merges wchill/patcheddit into the current branch, keeping Jeddit's release files and
# the clients it removed. Any other conflict is left for you to resolve.
set -euo pipefail

UPSTREAM_URL=https://github.com/wchill/patcheddit.git
OURS=(CHANGELOG.md gradle.properties patches-bundle.json patches-list.json README.md CONTRIBUTING.md .github/workflows/release.yml)

[ -z "$(git status --porcelain)" ] || { echo "Working tree is not clean." >&2; exit 1; }

git remote get-url upstream > /dev/null 2>&1 || git remote add upstream "$UPSTREAM_URL"
git remote set-url --push upstream DISABLE
git fetch upstream --no-tags

if git merge-base --is-ancestor upstream/main HEAD; then
    echo "Already up to date with upstream/main."
    exit 0
fi

git merge --no-commit --no-ff upstream/main || true

# Files Jeddit removed (modify/delete conflicts) stay removed.
git status --porcelain | sed -n 's/^DU //p' | while read -r f; do git rm -q -- "$f"; done

for f in "${OURS[@]}"; do
    if git status --porcelain -- "$f" | grep -q '^\(UU\|AA\)'; then
        git checkout --ours -- "$f"
        git add -- "$f"
    fi
done

if [ -n "$(git diff --name-only --diff-filter=U)" ]; then
    echo "Resolve these conflicts, then run git commit:" >&2
    git diff --name-only --diff-filter=U >&2
    exit 1
fi

git commit -q -m "chore: Merge upstream patcheddit"
echo "Merged upstream/main. Bump version in gradle.properties to release."
