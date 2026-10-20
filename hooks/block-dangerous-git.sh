#!/bin/bash
# Claude Code PreToolUse hook (matcher: Bash).
# Guards destructive git commands before Claude runs them. AGENTS.md forbids
# these by policy; this hook makes the policy binding.
# - BLOCKED commands exit 2: Claude must ask the user to run them.
# - ASK commands print a permissionDecision of "ask": the user approves or
#   rejects them in the permission prompt. Auto mode cannot approve them
#   silently. With no one to answer (claude -p), an ask is a denial.
# Plain `git push` is allowed: AGENTS.md permits a push that the user asked for.
# Only force pushes are blocked.
#
# Wired from ~/.claude/settings.json. Test:
#   echo '{"tool_input":{"command":"git clean -fd"}}' | hooks/block-dangerous-git.sh ; echo $?
# Expect exit 2 and a BLOCKED line on stderr.

INPUT=$(cat)
COMMAND=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty')
[ -z "$COMMAND" ] && exit 0

# Quoted text is usually data (a grep pattern, a commit message), so blank it
# before matching. A double-quoted string that holds $( or a backtick runs
# code, so it stays. Backslash escapes are consumed first so \' is not a quote.
STRIPPED=$(printf '%s' "$INPUT" | jq -r '
  .tool_input.command
  | gsub("(?<t>\\\\.|'"'"'[^'"'"']*'"'"'|\"(?:[^\"\\\\]|\\\\.)*\")";
      if (.t | startswith("\\")) then .t
      elif (.t | startswith("\"")) and (.t | test("\\$\\(|`")) then .t
      else "'"''"'" end)')

# A command that can execute a string (a shell, eval, ssh, an interpreter,
# git rebase --exec, a git ! alias, a script made executable in place) is
# scanned unstripped. This list errs strict: a miss only restores the old
# match-anywhere behavior for that command.
EVALUATORS='(^|[^[:alnum:]_.-])(sh|bash|zsh|dash|ksh|fish|eval|exec|source|ssh|xargs|watch|parallel|python[0-9.]*|node|perl|ruby|osascript|chmod)([^[:alnum:]_-]|$)|(^|[;&|({[:space:]])\.[[:space:]]|(^|[[:space:]])(-x|--exec)([[:space:]=]|$)|alias\.'
if [ -n "$STRIPPED" ] && ! printf '%s' "$STRIPPED" | grep -qE "$EVALUATORS"; then
  SCAN=$STRIPPED
else
  SCAN=$COMMAND
fi

# Git global options sit between `git` and the subcommand (git -C dir commit),
# so collapse them before matching: the patterns expect `git <subcommand>`.
GITOPTS='((-C|-c)[[:space:]]+[^[:space:]]+|--(git-dir|work-tree|namespace|exec-path|config-env)(=|[[:space:]]+)[^[:space:]]+|--no-pager|--paginate|-p|-P|--bare|--no-replace-objects|--literal-pathspecs|--no-optional-locks)'
SCAN=$(printf '%s' "$SCAN" | sed -E "s/git([[:space:]]+$GITOPTS)+[[:space:]]+/git /g")

BLOCKED_PATTERNS=(
  'git push[^|;&]*( -f| --force)'
  'git clean -[a-zA-Z]*f'
  'git branch -D'
  'git checkout (-- )?\.( |$)'
  'git restore (-- )?\.( |$)'
  'git stash (drop|clear)'
)

ASK_PATTERNS=(
  'git commit([^-[:alnum:]]|$)'
  'git reset --hard'
)

# BLOCKED wins over ASK, so a chain that holds both is blocked.
for pattern in "${BLOCKED_PATTERNS[@]}"; do
  if printf '%s' "$SCAN" | grep -qE "$pattern"; then
    echo "BLOCKED by ~/dot-agents/hooks/block-dangerous-git.sh: '$COMMAND' matches '$pattern'. This command is destructive. Ask the user to run it themselves." >&2
    exit 2
  fi
done

for pattern in "${ASK_PATTERNS[@]}"; do
  if printf '%s' "$SCAN" | grep -qE "$pattern"; then
    jq -n --arg r "dot-agents guard: this command matches '$pattern' and needs your approval." \
      '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "ask", permissionDecisionReason: $r}}'
    exit 0
  fi
done

exit 0
