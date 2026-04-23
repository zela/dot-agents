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

# Run evaluation with LLM-as-a-judge and parallel execution
uv run scripts/teal_benchmark.py --models claude-sonnet-4-6 --parallel --judge
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

### CLI Parameters

- `--models` (Optional): Space-separated list of model names to run against (e.g., `claude-sonnet-4-6 gemini-2.5-flash`). If omitted, tests all available models using provided API keys.
- `--prompts` (Optional): Path to a JSON file containing the test prompts. Defaults to `teal-benchmark-prompts.json` in the script directory.
- `--output` (Optional): Path to write the final Markdown report to. If omitted, results are printed to stdout.
- `--system-prompt` (Optional): The baseline system prompt to use for the A/B test. Defaults to standard "expert software engineer" prompt.
- `--parallel` (Optional): Runs queries concurrently using a thread pool. **Note:** May hit rate limits on free-tier API keys. When omitted, runs serially with delay between requests to stay under rate limits.
- `--judge` (Optional): Enables an LLM-as-a-judge (uses `claude-sonnet-4-6`) to blindly evaluate the Baseline vs TEAL outputs based on reasoning quality and correctness, outputting a winner for each prompt.

---

## Initial Benchmark Findings

We measured TEAL's effectiveness by comparing a standard baseline prompt against the TEAL system instructions. Below are highlights from initial runs:

### Claude (claude-sonnet-4-6)
- **Token Savings**: A **33.8%** average reduction in total output tokens across prompts.
- **Latency**: Meaningfully faster response times (due to significantly fewer output tokens generated).
- **Quality (LLM-as-a-judge)**: TEAL **won 3/5** scenarios and tied in 1, demonstrating that the responses were more structurally sound, concise, and architecturally superior despite using fewer tokens.

### Gemini (gemini-2.5-flash)
- **Thinking Tokens**: TEAL reduced internal thinking tokens by **+55.1%** on average.
- **Output Tokens**: Output tokens *increased* (+73.6%), suggesting TEAL forces Gemini Flash to replace endless internal thinking loops with concrete, structured output generation.
- **Latency**: The reduction in thinking tokens led to drastically lower latency (e.g., dropping from 21.4s to 5.8s on complex logic prompts).
