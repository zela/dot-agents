---
name: third-opinion
description: Use for a third opinion from an alternative AI CLI (Claude or Copilot).
---

# third-opinion

This skill gets a "third opinion" on a decision, architecture, or code snippet. It asks an alternative AI model that runs on the user's system through a CLI.

## Instructions

When the user asks for a "third opinion":

1. **Summarize Context:** Formulate a highly detailed prompt that includes the current context, the core question/problem, any proposed solutions, and trade-offs.

2. **Select the Alternative Model:**
   - **Default:** Use GitHub Copilot CLI (`copilot`) specifying the `gpt-5.3-codex` model.
   - **Explicit Fallback:** If you already run via GitHub Copilot, ask the user which alternative CLI or model to use instead (for example, Claude Code). Do not auto-detect the fallback. Prompt the user so the choice stays independent.
   - The user can explicitly override the CLI tool or the model in their request (for example, "Get a third opinion using copilot with gpt-4").

3. **Execute the Request:**
   Run the CLI command as a single prompt execution (non-interactive mode) using the `run_command` tool.
   - **Important:** If you use Copilot, always include a `--model` validation step or flag. If the CLI fails (for example "Permission denied", "Model not found", or a non-zero exit code), report the exact error to the user. Then ask the user how to proceed.

   - **For GitHub Copilot CLI (Default):**
     `copilot -p "Evaluate this decision: <summary and context>" -s --model gpt-5.3-codex`
     _(Adjust the `--model` flag if the user specified a different model. Do not include `--yolo` by default unless explicitly requested)._

   - **For Claude Code (Fallback):**
     `claude -p "Evaluate this decision: <summary and context>"`

4. **Review:**
   Wait for the command to finish. Read the output. Then present the alternative model's perspective to the user. Make sure to discuss the new considerations.
