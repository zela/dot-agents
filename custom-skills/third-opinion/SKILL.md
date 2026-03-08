---
name: third-opinion
description: Consult an alternative AI model via CLI (Copilot or Claude Code) for a third opinion.
---

# third-opinion

This skill allows the agent to get a "third opinion" on a decision, architecture, or snippet of code by consulting an alternative AI model installed on the user's system via CLI.

## Instructions

When the user asks for a "third opinion":

1. **Summarize Context:** Formulate a highly detailed prompt that includes the current context, the core question/problem, any proposed solutions, and trade-offs.

2. **Select the Alternative Model:**
   - **Default:** Use GitHub Copilot CLI (`copilot`) specifying the `gpt-5.3-codex` model.
   - **Explicit Fallback:** If you (the primary agent) are already running via GitHub Copilot, you MUST explicitly ask the user to confirm which alternative model or CLI tool they want to use instead (e.g., Claude Code). Do not auto-detect the fallback; prompt the user to ensure true independence.
   - The user can explicitly override the CLI tool or the model used by specifying it in their request (e.g., "Get a third opinion using copilot with gpt-4").

3. **Execute the Request:**
   Run the CLI command as a single prompt execution (non-interactive mode) using the `run_command` tool.
   - **Important:** Always include a `--model` validation step or flag if using Copilot. Handle CLI failures gracefully (e.g., "Permission denied", "Model not found", or non-zero exit codes) by reporting the exact error to the user and asking how they would like to proceed.

   - **For GitHub Copilot CLI (Default):**
     `copilot -p "Evaluate this decision: <summary and context>" -s --model gpt-5.3-codex`
     _(Adjust the `--model` flag if the user specified a different model. Do not include `--yolo` by default unless explicitly requested)._

   - **For Claude Code (Fallback):**
     `claude -p "Evaluate this decision: <summary and context>"`

4. **Review:**
   Wait for the command to finish, read the output, and present the alternative model's perspective to the user. Make sure to discuss the new considerations.
