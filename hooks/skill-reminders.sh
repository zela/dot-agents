#!/bin/bash
# Claude Code PreToolUse hook (matcher: Edit|Write|MultiEdit).
# Reminds Claude to load `craft` before the first code edit of a session, and
# `modern-web-guidance` before the first frontend edit. Their descriptions ask
# for this, but descriptions alone rarely trigger them.
# - It only adds context. It never blocks the edit or changes the permission flow.
# - Each reminder fires at most once per session, and once per subagent.
# - Docs, config and data files, and temp-dir files are not code, so they are skipped.
#
# Wired from ~/.claude/settings.json. Test:
#   echo '{"session_id":"t1","tool_input":{"file_path":"/x/App.vue"}}' | hooks/skill-reminders.sh
# Expect JSON with an additionalContext that names both skills. A second run
# with the same session_id prints nothing.

INPUT=$(cat)
FILE=$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // empty')
[ -z "$FILE" ] && exit 0
shopt -s nocasematch
case "$FILE" in
  *.md|*.mdx|*.markdown|*.txt|*.rst) exit 0 ;;
  *.json|*.jsonc|*.yaml|*.yml|*.toml|*.lock|*.gitignore) exit 0 ;;
  /tmp/*|/private/tmp/*|/var/folders/*|/private/var/folders/*) exit 0 ;;
esac

SESSION=$(printf '%s' "$INPUT" | jq -r '.session_id // "none"')
AGENT=$(printf '%s' "$INPUT" | jq -r '.agent_id // empty')
TRANSCRIPT=$(printf '%s' "$INPUT" | jq -r '.transcript_path // empty')
STATE="${TMPDIR:-/tmp}/claude-skill-reminders"
# Without a writable marker, the reminder would repeat on every edit.
mkdir -p "$STATE" || exit 0

# A subagent has its own context, so read its own transcript. Claude Code keeps
# it at <session>/subagents/agent-<id>.jsonl next to <session>.jsonl; the hook
# payload does not give this path.
loaded() {
  local t="$TRANSCRIPT"
  [ -n "$AGENT" ] && t="${TRANSCRIPT%.jsonl}/subagents/agent-$AGENT.jsonl"
  [ -f "$t" ] && grep -qE "\"skill\":\"$1\"|<command-name>/$1</command-name>" "$t"
}

MSG=""
remind() {
  local marker="$STATE/$SESSION${AGENT:+.$AGENT}.$1"
  [ -e "$marker" ] && return
  touch "$marker"
  loaded "$1" && return
  MSG="$MSG$2 "
}

remind craft "dot-agents reminder: this session has not loaded the craft skill. Load it now and run its checks before you make more code edits. For a one-line fix or a mechanical change, craft asks for step 3 only."
case "$FILE" in
  *.vue|*.css|*.scss|*.html|*.tsx|*.jsx|*.svelte)
    remind modern-web-guidance "dot-agents reminder: $FILE is frontend code. Load the modern-web-guidance skill and check this change against it before you continue." ;;
esac

[ -z "$MSG" ] && exit 0
jq -n --arg c "$MSG" '{hookSpecificOutput: {hookEventName: "PreToolUse", additionalContext: $c}}'
