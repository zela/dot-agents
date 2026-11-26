#!/usr/bin/env bash
# CRAP scores and structural duplicates for the TypeScript/JavaScript files
# changed in this project. Run it from the project root (where package.json is).
#
# Usage:
#   check-changed.sh               # working tree against HEAD, plus untracked files
#   check-changed.sh --since main  # everything since the merge base with main
#
# It installs nothing. Coverage comes from the Vitest and coverage provider of
# each package that has them, the root included. If no package writes a report,
# crapper scores complexity only.
# It writes coverage/craft/ (merged LCOV) and .metrics/ (crapper and dryer snapshots).

set -euo pipefail

# Bash keeps one EXIT trap, so every temp path is registered here.
tmp=()
trap 'if [ "${#tmp[@]}" -gt 0 ]; then rm -rf "${tmp[@]}"; fi' EXIT

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

# A local binary and provider only: npx or Vitest's own prompt would install them.
packages=()
while IFS= read -r pkg; do
  [ -x "$pkg/node_modules/.bin/vitest" ] || continue
  [ -d "$pkg/node_modules/@vitest/coverage-istanbul" ] || [ -d "$pkg/node_modules/@vitest/coverage-v8" ] || continue
  packages+=("$pkg")
done < <(
  git ls-files --cached --others --exclude-standard -- package.json '*/package.json' |
    while IFS= read -r p; do dirname "$p"; done | sort -u
)

coverage=(--no-coverage)
if [ "${#packages[@]}" -gt 0 ]; then
  # Each package runs its own tests with its own config (a Workers pool, say),
  # and a test in one package can cover a file in another. crapper keeps only the
  # last report for a file that two reports cover, so the reports are merged
  # here into one, with repo-relative paths.
  root=$(pwd -P)
  raw=$(mktemp -d)
  tmp+=("$raw")
  # A project's coverage thresholds would fail a run that covers only the changed
  # files. The --no- form passes a boolean; --coverage.thresholds=false passes a string.
  args=(run --passWithNoTests --coverage.enabled=true --coverage.reporter=lcov
    --coverage.allowExternal=true --no-coverage.thresholds)
  if [ -n "$since" ]; then args+=("--changed=$base"); else args+=(--changed); fi
  anywhere=()
  for f in "${changed[@]}"; do
    anywhere+=("**/$(printf '%s' "$f" | sed 's/[][\\*?{}()!+@]/\\&/g')")
  done

  i=0
  for pkg in "${packages[@]}"; do
    i=$((i + 1))
    # Istanbul when the package has it: Cloudflare's Workers pool cannot use V8 coverage.
    provider=v8
    [ -d "$pkg/node_modules/@vitest/coverage-istanbul" ] && provider=istanbul
    # Vitest 3 and 4 match an include against the absolute path, and Vitest 5 does
    # so for a file outside the package: the escaped repo path under **/ serves both.
    # Vitest 5 matches a file inside the package by its path from the package, so
    # that file also goes in that form. Nothing names a file outside the package
    # by a path that its glob can reach: Vitest 4 Istanbul then lists the file as
    # untested, cannot transform it, and stops the run.
    pkgargs=()
    j=0
    for f in "${changed[@]}"; do
      pkgargs+=("--coverage.include=${anywhere[$j]}")
      j=$((j + 1))
      if [ "$pkg" = . ]; then
        pkgargs+=("--coverage.include=$f")
      else
        case $f in "$pkg"/*) pkgargs+=("--coverage.include=${f#"$pkg"/}") ;; esac
      fi
    done
    # Without a projects config, a run's default include also finds the tests of
    # each package inside it and runs them under its own config.
    pre=""
    [ "$pkg" = . ] || pre="$pkg/"
    for p in "${packages[@]}"; do
      case $p in .) ;; "$pre"?*) pkgargs+=(--exclude "${p#"$pre"}/**") ;; esac
    done
    echo "craft: coverage from the tests in $pkg ($provider)" >&2
    if ! (cd "$pkg" && node_modules/.bin/vitest "${args[@]}" "${pkgargs[@]}" \
      --coverage.provider="$provider" --coverage.reportsDirectory="$raw/$i" >&2); then
      echo "craft: Vitest failed in $pkg (see its output above), so its coverage is not scored" >&2
      continue
    fi
    [ -f "$raw/$i/lcov.info" ] || continue
    # Vitest writes SF paths relative to the package, or absolute.
    awk -v pkg="$pkg" -v root="$root" '
      function norm(p,   n, i, part, out, k, s) {
        n = split(p, part, "/"); k = 0
        for (i = 1; i <= n; i++) {
          if (part[i] == "" || part[i] == ".") continue
          if (part[i] == ".." && k > 0) { k--; continue }
          out[++k] = part[i]
        }
        s = ""
        for (i = 1; i <= k; i++) s = s (i > 1 ? "/" : "") out[i]
        return s
      }
      /^SF:/ {
        f = substr($0, 4)
        if (index(f, root "/") == 1) f = substr(f, length(root) + 2)
        else if (pkg != ".") f = pkg "/" f
        print "SF:" norm(f); next
      }
      { print }' "$raw/$i/lcov.info" >> "$raw/all.info"
  done

  if [ -f "$raw/all.info" ]; then
    mkdir -p coverage/craft
    # Sum line and branch hits per file across the package reports.
    awk '
      /^SF:/ { f = substr($0, 4); seen[f] = 1; next }
      /^DA:/ { split(substr($0, 4), a, ","); da[f SUBSEP a[1]] += a[2]; next }
      /^BRDA:/ {
        split(substr($0, 6), b, ",")
        k = f SUBSEP b[1] "," b[2] "," b[3]
        br[k] += (b[4] == "-" ? 0 : b[4]); next
      }
      END {
        for (k in da) { split(k, p, SUBSEP); out[p[1]] = out[p[1]] "DA:" p[2] "," da[k] "\n" }
        for (k in br) { split(k, p, SUBSEP); out[p[1]] = out[p[1]] "BRDA:" p[2] "," br[k] "\n" }
        for (f in seen) printf "SF:%s\n%send_of_record\n", f, out[f]
      }' "$raw/all.info" > coverage/craft/lcov.info
    coverage=(--use-existing-coverage)
  else
    echo "craft: no package wrote a coverage report. Scoring complexity only." >&2
  fi
else
  echo "craft: no package has a local Vitest with @vitest/coverage-v8 or @vitest/coverage-istanbul. Scoring complexity only." >&2
fi

# crapper reads every lcov.info under coverage/ and target/coverage/. For a file
# that is in two reports, the report read last replaces the other, in glob order.
stale=$(find coverage target/coverage -name lcov.info -not -path 'coverage/craft/*' 2>/dev/null || true)
if [ -n "$stale" ]; then
  echo "craft: crapper also reads these reports; one can replace this run's coverage, so scores can be stale while they exist:" >&2
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
tmp+=("$list")
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
