---
name: third-opinion
description: Use for a third opinion from another provider's AI CLI (Codex, Claude, or Copilot). Codex and Claude run read-only.
disable-model-invocation: true
---

# third-opinion

Get a third opinion on a decision, a plan, a design, or code from a model of another provider.

## When to use

The model that wrote the work has the same blind spots when it reviews that work. Use a call for one narrow question where such a blind spot can change a decision:

- **The riskiest session doc before a wave**: the doc that changes the deploy shape or shares a contract with another session. Send only that doc through the cross-provider check in `doc-check`.
- **A design fork, after `grill-me` and before `decision-record`**: ask for the strongest objection to the chosen option, and the evidence that proves it wrong.
- **A problem that resisted two attempts with the same approach** (`AGENTS.md` § When Work Fails).

To find a fact, use grep or `--help` instead.

## Steps

1. **Pick the provider.**
   - In Claude Code, use Codex.
   - In Codex, use Claude.
   - If the user names Copilot, use Copilot.
   - If the user names a model, pass a model flag. Otherwise, pass no model flag.
2. **Write the brief.** Make a new directory outside the repository: the host's scratch directory, or `mktemp -d`. The commands in step 3 call its path `DIR`. Write the prompt to `prompt.txt` in `DIR`. The other model does not see this conversation. Make the brief self-contained:
   - One question, and the decision that the answer feeds.
   - The context, the options under consideration, and their trade-offs, without your preference.
   - A request for the strongest objection, not for approval.
   - The files to read, as paths from the repository root.
   - For a problem that resisted two attempts: the reproduction, the evidence, and each approach that failed.
   - The answer format: findings with `file:line` evidence, each marked "checked" or "inferred".
3. **Run the call read-only.** Run it from the repository root. Send the prompt through stdin. Keep stdout and stderr in `DIR`. For a long call, use the host's timeout or background run. Tell the user that the call started. Use only the flags in this step.
   - **Codex.** First run `codex mcp list --json`. If the listing fails, report the error. Then stop. For each server with `"enabled": true`, add `-c mcp_servers.<name>.enabled=false` to the command. The read-only sandbox covers shell commands only, so an MCP server, a plugin or an app can still write.

     ```sh
     codex exec -C "$PWD" -s read-only -c 'approval_policy="never"' \
       --disable apps --disable plugins -c 'notify=[]' --skip-git-repo-check \
       --json -o "$DIR/reply.txt" [-m MODEL] - \
       < "$DIR/prompt.txt" > "$DIR/events.jsonl" 2> "$DIR/stderr.txt"
     ```

   - **Claude.**

     ```sh
     claude -p --safe-mode --strict-mcp-config --mcp-config '{"mcpServers":{}}' \
       --tools Read,Glob,Grep --allowedTools Read,Glob,Grep \
       --permission-mode dontAsk --no-chrome --output-format json [--model MODEL] \
       < "$DIR/prompt.txt" > "$DIR/result.json" 2> "$DIR/stderr.txt"
     ```

   - **Copilot.** `copilot -p "$(cat "$DIR/prompt.txt")" -s --model <MODEL>`. This command is unverified. Copilot has no read-only flag set here. Before you run Copilot, tell the user that Copilot can edit files. Add `--yolo` only if the user asks for it.
4. **Read the result.** A run succeeds only when all of these are true:
   - The exit code is 0.
   - Codex: `events.jsonl` has no `error` or `turn.failed` event, and `reply.txt` is not empty.
   - Claude: `result.json` has `"subtype": "success"`, `"is_error": false`, an empty `permission_denials`, and a non-empty `result`.

   On any other result, report the exact error from the files. Then stop. Do not retry. Do not switch to another model or provider. Report the requested model and the model that ran as two separate facts. Claude names the model that ran in the `modelUsage` keys. Codex does not report it, so write "not reported".
5. **Weigh the opinion.** Before you adopt a finding, open each `file:line` that the reply cites. Then present the view of the other model to the user: what it adds, what it contradicts, and which of its claims you checked. Agreement between the two models is not proof, because models share blind spots. A reply that uses other words for the same decision counts as agreement. A recommendation that you add after you read the reply is yours. Name it as yours.
