#!/usr/bin/env bash
# Install, check, and update the pinned tools in upstream-tools.txt.
#
# Usage:
#   agent-tools.sh install        # install each tool whose installed commit differs from its pin
#   agent-tools.sh check          # compare each pin with upstream HEAD
#   agent-tools.sh update [name]  # move pins to upstream HEAD, then install

set -euo pipefail

PINS=~/dot-agents/upstream-tools.txt

command -v uv >/dev/null || { echo "agent-tools: uv is not installed (brew install uv)" >&2; exit 1; }

pins() {
  grep -Ev '^\s*(#|$)' "$PINS"
}

installed_spec() {
  # A line looks like: crapper v0.1.0 [required:  git+https://...@<commit>]
  uv tool list --show-version-specifiers --color never 2>/dev/null \
    | awk -v n="$1" '$1 == n { sub(/.*required: +/, ""); sub(/\]$/, ""); print }'
}

install() {
  pins | while read -r name url commit; do
    spec="git+$url@$commit"
    if [ "$(installed_spec "$name")" = "$spec" ]; then
      echo "  ✓ $name @ ${commit:0:7}"
    else
      echo "  → $name @ ${commit:0:7}"
      uv tool install --force --quiet "$spec"
    fi
  done
}

check() {
  pins | while read -r name url commit; do
    head=$(git ls-remote "$url" HEAD | cut -f1)
    if [ "$head" = "$commit" ]; then
      echo "  ✓ $name is at upstream HEAD (${commit:0:7})"
    else
      echo "  ↑ $name: pinned ${commit:0:7}, upstream ${head:0:7}"
      echo "    changes: $url/compare/$commit...$head"
    fi
  done
}

update() {
  local moves
  moves=$(pins | while read -r name url commit; do
    if [ $# -gt 0 ] && [[ " $* " != *" $name "* ]]; then continue; fi
    head=$(git ls-remote "$url" HEAD | cut -f1)
    [ "$head" = "$commit" ] && continue
    echo "  ↑ $name ${commit:0:7} → ${head:0:7}  ($url/compare/$commit...$head)" >&2
    echo "$name $head"
  done)
  [ -n "$moves" ] || { echo "  ✓ every pin is at upstream HEAD"; return; }
  # awk instead of sed -i, whose flags differ between BSD and GNU. Write in place,
  # not with mv, so a symlinked pins file keeps its link.
  local updated
  updated=$(awk -v moves="$moves" '
    BEGIN { n = split(moves, m, "\n"); for (i = 1; i <= n; i++) { split(m[i], f, " "); to[f[1]] = f[2] } }
    $1 in to && $0 !~ /^[[:space:]]*#/ { $3 = to[$1] }
    { print }' "$PINS")
  printf '%s\n' "$updated" > "$PINS"
  install
  echo "  Review the pin change with: git -C ~/dot-agents diff upstream-tools.txt"
}

case "${1:-}" in
  install) install ;;
  check) check ;;
  update) shift; update "$@" ;;
  *) echo "usage: agent-tools.sh install | check | update [name ...]" >&2; exit 1 ;;
esac
