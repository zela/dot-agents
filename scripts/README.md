# Scripts

Automation scripts for dot-agents workflows. All scripts use [uv](https://docs.astral.sh/uv/) inline dependencies — no venv or install step needed.

## Setup

1. Copy `.env.template` to `.env` and fill in your API keys:

```bash
cp scripts/.env.template scripts/.env
```

2. Source the env file before running scripts:

```bash
source scripts/.env
```

Or export keys directly in your shell.

## Available Scripts

### teal_benchmark.py

Measures actual token savings from TEAL instructions by running A/B tests against Claude and Gemini APIs. See [teal_benchmark.md](../shared-workflows/teal_benchmark.md) for the full methodology.

```bash
# Run against all available models (skips providers with missing keys)
uv run scripts/teal_benchmark.py

# Run against specific models
uv run scripts/teal_benchmark.py --models claude-sonnet-4-6
uv run scripts/teal_benchmark.py --models gemini-3.1-pro gemini-3-flash

# Save results to file
uv run scripts/teal_benchmark.py --output results.md

# Use a custom base system prompt
uv run scripts/teal_benchmark.py --system-prompt "You are a senior engineer."

# Use custom prompts
uv run scripts/teal_benchmark.py --prompts path/to/prompts.json
```

**Supported models:**
- Claude: `claude-sonnet-4-6`, `claude-opus-4-6`
- Gemini: `gemini-3.1-pro`, `gemini-3-flash`

**Prompt format** (`teal-benchmark-prompts.json`):

```json
[
  {
    "category": "Bug investigation",
    "prompt": "Your prompt text here..."
  }
]
```
