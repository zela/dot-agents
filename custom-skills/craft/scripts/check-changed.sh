#!/usr/bin/env bash
# CRAP scores and structural duplicates for the TypeScript/JavaScript files
# changed in this project. Run it from the project root (where package.json is).
#
# Usage:
#   check-changed.sh               # working tree against HEAD, plus untracked files
#   check-changed.sh --since main  # everything since the merge base with main
#
# It installs nothing. Coverage comes from the project's own Vitest and coverage
# provider. Without them, crapper scores complexity only.
# It writes coverage/craft/ (Vitest LCOV) and .metrics/ (crapper and dryer snapshots).

set -euo pipefail

since=""
case "${1:-}" in
  --since) since="${2:?--since needs a git ref}" ;;
  "") ;;
  *) echo "usage: check-changed.sh [--since <ref>]" >&2; exit 1 ;;
esac

# uv tool links its commands into a directory that a non-login shell may not have on PATH.
command -v uv >/dev/null && PATH="$PATH:$(uv tool dir --bin --color never 2>/dev/null)"

missing=""
for tool in crapper dryer; do
  command -v "$tool" >/dev/null || missing="$missing $tool"
done
if [ -n "$missing" ]; then
  echo "craft: not on PATH:$missing" >&2
  # The pins live in ~/dot-agents/upstream-tools.txt; bootstrap.sh installs them.
  echo "craft: the user installs them with: ~/dot-agents/scripts/agent-tools.sh install" >&2
  exit 3
fi

base=HEAD
[ -n "$since" ] && base=$(git merge-base "$since" HEAD)

# Same test-file rule as crapper and dryer use on a tree walk; they include
# test files that are named explicitly, so the filter has to happen here.
sources() {
  while IFS= read -r f; do
    [ -f "$f" ] || continue
    case "$f" in
      *.d.ts|*.test.*|*.spec.*|__tests__/*|*/__tests__/*) ;;
      *.ts|*.tsx|*.mts|*.cts|*.js|*.jsx|*.mjs|*.cjs) printf '%s\n' "$f" ;;
    esac
  done | sort -u
}

changed=()
while IFS= read -r f; do changed+=("$f"); done < <(
  { git diff --name-only --relative --diff-filter=AM "$base"
    git ls-files --others --exclude-standard; } | sources
)
if [ "${#changed[@]}" -eq 0 ]; then
  echo "craft: no changed TypeScript or JavaScript source files."
  exit 0
fi
echo "craft: ${#changed[@]} changed source file(s) since $base"

coverage=(--no-coverage)
vitest=node_modules/.bin/vitest
if [ -x "$vitest" ] && { [ -d node_modules/@vitest/coverage-v8 ] || [ -d node_modules/@vitest/coverage-istanbul ]; }; then
  # A local binary and provider only: npx or Vitest's own prompt would install them.
  cmd="$vitest run --passWithNoTests --coverage.enabled=true --coverage.reporter=lcov"
  cmd="$cmd --coverage.reportsDirectory=coverage/craft --coverage.reportOnFailure=true"
  if [ -n "$since" ]; then cmd="$cmd --changed=$base"; else cmd="$cmd --changed"; fi
  for f in "${changed[@]}"; do cmd="$cmd --coverage.include=$(printf %q "$f")"; done
  coverage=(--coverage-command "$cmd")
else
  echo "craft: no local Vitest with @vitest/coverage-v8 or @vitest/coverage-istanbul. Scoring complexity only." >&2
fi

# crapper merges every lcov.info under coverage/ and target/coverage/.
stale=$(find coverage target/coverage -name lcov.info -not -path 'coverage/craft/*' 2>/dev/null || true)
if [ -n "$stale" ]; then
  echo "craft: crapper also merges these reports; scores can be stale while they exist:" >&2
  printf '  %s\n' $stale >&2
fi

echo
echo "== CRAP (worst first)"
crapper "${coverage[@]}" "${changed[@]}" || echo "craft: crapper exited $?" >&2

echo
echo "== Duplicates that touch a changed file"
# dryer --changed compares changed files only with each other, so scan every
# source file and keep the pairs with at least one changed side.
all=()
while IFS= read -r f; do all+=("$f"); done < <(
  { git ls-files; git ls-files --others --exclude-standard; } | sources
)
list=$(mktemp)
trap 'rm -f "$list"' EXIT
printf '%s\n' "${changed[@]}" > "$list"
dryer "${all[@]}" | awk -v list="$list" '
  BEGIN { while ((getline f < list) > 0) changed[f] = 1; RS = "" }
  /^DUPLICATE/ {
    n = split($0, line, "\n")
    for (i = 2; i <= n; i++) {
      path = line[i]; sub(/^ +/, "", path); sub(/:[0-9]+-[0-9]+$/, "", path)
      if (path in changed) { print $0 "\n"; found = 1; break }
    }
  }
  END { if (!found) print "No duplicate candidates touch the changed files." }'
