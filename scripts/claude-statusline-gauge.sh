#!/bin/bash
# Claude Code context-fill gauge.
#
# Reads Claude Code's statusLine JSON on stdin and prints ONE line showing how
# full the context window is — the cue to /compact or /clear before a session
# bloats. See ~/dot-agents/CLAUDE.md "## Context Hygiene".
#
# This is the source of truth. It is invoked from the vibe-island statusline
# script (~/.vibe-island/bin/vibe-island-statusline), which pipes its stdin
# JSON to us so nothing custom stays buried in a third-party app's bin/.
# Can also be wired directly as settings.json "statusLine.command".
#
# Output (color by fill — green <50%, yellow ≥50%, red ≥75%):
#   ctx █████▌░░░░ 55% 550k/1M · consider /compact
#
# Uses the native context_window fields (Claude Code ≥ v2.1.132); no transcript
# parsing. Prints nothing before the first API call or just after /compact.

input=$(cat)

read -r _pct _used _max <<EOF
$(printf '%s' "$input" | jq -r '
  (.context_window.used_percentage // -1) as $p
  | (.context_window.total_input_tokens // 0) as $u
  | (.context_window.context_window_size // 200000) as $m
  | "\(if $p == null then -1 else ($p | floor) end) \($u) \($m)"' 2>/dev/null)
EOF

# No API call yet (fresh session / post-/compact) → nothing to show.
[ "${_pct:--1}" -ge 0 ] 2>/dev/null || exit 0

# humanize a token count → 38k / 550k / 1M / 1.2M
_h() {
  if [ "$1" -ge 1000000 ]; then
    _w=$(( $1 / 1000000 )); _f=$(( ($1 % 1000000) / 100000 ))
    [ "$_f" -eq 0 ] && printf '%dM' "$_w" || printf '%d.%dM' "$_w" "$_f"
  else
    printf '%dk' "$(( $1 / 1000 ))"
  fi
}

if   [ "$_pct" -ge 75 ]; then _c='\033[31m'; _tip=' · /clear or /compact'
elif [ "$_pct" -ge 50 ]; then _c='\033[33m'; _tip=' · consider /compact'
else _c='\033[32m'; _tip=''
fi

# Smooth bar: 10 cells × 8 eighths = 80 steps, so even 1% shows a sliver.
_e=$(( (_pct * 80 + 50) / 100 )); [ "$_e" -gt 80 ] && _e=80
_full=$(( _e / 8 )); _rem=$(( _e % 8 )); _cells=$_full
_bar=''; _i=0
while [ "$_i" -lt "$_full" ]; do _bar="${_bar}█"; _i=$(( _i + 1 )); done
if [ "$_rem" -gt 0 ]; then
  case "$_rem" in 1)_p='▏';;2)_p='▎';;3)_p='▍';;4)_p='▌';;5)_p='▋';;6)_p='▊';;7)_p='▉';; esac
  _bar="${_bar}${_p}"; _cells=$(( _cells + 1 ))
fi
_track=''; _i=$_cells
while [ "$_i" -lt 10 ]; do _track="${_track}░"; _i=$(( _i + 1 )); done

_line="${_c}ctx ${_bar}\033[0m\033[2m${_track}\033[0m ${_c}${_pct}%\033[0m \033[2m$(_h "$_used")/$(_h "$_max")\033[0m${_c}${_tip}\033[0m"
printf '%b\n' "$_line"
