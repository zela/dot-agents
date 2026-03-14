---
description: Evaluate and compare new or existing models for codebase tasks.
---

This workflow provides a repeatable framework to evaluate and compare new or existing reasoning models (e.g. Gemini 3.1 Pro, Claude Sonnet 4.6, Grok Code Fast 1, GPT-OSS-120b) for software development tasks.

Use this framework to define the roles of different models in your workflow by identifying where they shine and where they struggle.

### 1. Select Representative Tasks

Pick 5–10 representative tasks from your real work to create a comprehensive evaluation set.
Make sure to mix the following types of tasks:

- Small bugfixes in existing code
- "Implement this feature" tasks that touch multiple files
- A tricky refactor
- Writing unit or integration tests
- One or two architecture or "how should we design this?" questions

### 2. Run the Comparison

Run each task with the new model you are evaluating (e.g., Grok Code Fast 1, a new open-source model) and compare it against your baseline model.

- **Baseline suggestions**: Claude Sonnet 4.6 (great for everyday coding), Gemini 3.1 Pro (high) or Claude Opus 4.6 (great for deep reasoning).

### 3. Score the Models

For each task, score both the new model and the baseline model on the following criteria:

- **Correctness & Bugs**: How much manual fixing was needed after the model generated the code?
- **Adherence to Conventions**: Did the model follow your stack's framework best practices, project style, and typing rules?
- **Diff Quality**: Were the changes minimal and focused? Did it avoid pointless churn or rewriting working code?
- **Time to Usable Result**: Consider both the "thinking" time of the model and the actual editing time required to get the code working, not just the model latency.
- **Cost Efficiency**: Rough estimation of token usage multiplied by the model's price per token.

### 4. Analyze Results

Note where the evaluated model shines compared to the baseline and existing models:

- Consistently good diffs almost instantly in 80% of tasks? It's an excellent **day-to-day coder** (similar to Gemini 3 Flash or Claude Sonnet 4.6).
- Struggles with deep reasoning or complex refactors? It requires falling back to a "senior" baseline model for those 20% of tasks (like Gemini 3.1 Pro (high) or Claude Opus 4.6).
- Excels at complex mathematical logic or deep algorithmic work? It's a strong specialized reasoning model (like GPT-OSS-120b).

### 5. Define the Model's Role Explicitly

Based on the analysis, decide the explicit role of the model in your workflow:

- **Primary Fast Coder**: For everyday changes, scaffolding, and boilerplate.
- **Senior Architect Model**: For code reviews, complex refactors, and architecture design.
- **Secondary Helper**: Only for cheap prototyping, fast experiments, or documentation tasks.

---

### Reference: Antigravity Core Models Roles

For comparison, here are the general roles of existing core models in Antigravity:

- **Gemini 3.1 Pro (high)**: Deep reasoning, architectural planning, solving intricate multi-file bugs. Overkill for simple tasks.
- **Gemini 3.1 Pro (low)**: Reliable "daily driver" for senior-level tasks. Balanced reasoning.
- **Gemini 3 Flash**: Rapid prototyping, styling, boilerplate, and routine tests. High velocity, low cost.
- **Claude Sonnet 4.6 (thinking)**: Fast-paced, high-quality full-stack development. Industry favorite for getting things right the first time.
- **Claude Opus 4.6 (thinking)**: Expert-level logic and complex multi-step problem solving. Used for large-scale refinement.
- **GPT-OSS-120b**: Mathematical logic, competitive coding, and complex data transformations.
