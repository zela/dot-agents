#!/bin/bash
# Claude Code PreToolUse hook (matcher: Bash).
# Blocks destructive git commands before Claude runs them. AGENTS.md forbids
# these by policy; this hook makes the policy binding.
# Plain `git push` is allowed: AGENTS.md permits a push that the user asked for.
# Only force pushes are blocked.
#
# Wired from ~/.claude/settings.json. Test:
#   echo '{"tool_input":{"command":"git reset --hard"}}' | hooks/block-dangerous-git.sh ; echo $?
# Expect exit 2 and a BLOCKED line on stderr.

INPUT=$(cat)
COMMAND=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty')
[ -z "$COMMAND" ] && exit 0

DANGEROUS_PATTERNS=(
  'git push[^|;&]*( -f| --force)'
  'git reset --hard'
  'git clean -[a-zA-Z]*f'
  'git branch -D'
  'git checkout (-- )?\.( |$)'
  'git restore (-- )?\.( |$)'
  'git stash (drop|clear)'
)

for pattern in "${DANGEROUS_PATTERNS[@]}"; do
  if printf '%s' "$COMMAND" | grep -qE "$pattern"; then
    echo "BLOCKED by ~/dot-agents/hooks/block-dangerous-git.sh: '$COMMAND' matches '$pattern'. This command is destructive. Ask the user to run it themselves." >&2
    exit 2
  fi
done

exit 0
