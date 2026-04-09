# /// script
# requires-python = ">=3.11"
# dependencies = [
#     "anthropic>=0.40",
#     "google-genai>=1.0",
# ]
# ///
"""
TEAL Benchmark — Measure token savings from TEAL instructions.

Runs each prompt twice per model (baseline vs TEAL system prompt),
captures real token usage from API response metadata, and outputs
a markdown comparison table.

Usage:
    uv run scripts/teal_benchmark.py
    uv run scripts/teal_benchmark.py --models claude-sonnet-4-6
    uv run scripts/teal_benchmark.py --output results.md
"""

import argparse
import json
import os
import sys
import time
from dataclasses import dataclass, field
from pathlib import Path

TEAL_PATH = Path.home() / "dot-agents" / "TEAL.md"
PROMPTS_PATH = Path(__file__).parent / "teal-benchmark-prompts.json"

CLAUDE_MODELS = ["claude-sonnet-4-6", "claude-opus-4-6"]
GEMINI_MODELS = ["gemini-3.1-pro", "gemini-3-flash"]

BASELINE_SYSTEM = "You are an expert software engineer. Think step by step."


@dataclass
class RunResult:
    category: str
    model: str
    condition: str  # "baseline" or "teal"
    input_tokens: int = 0
    output_tokens: int = 0
    thinking_tokens: int = 0
    total_tokens: int = 0
    latency_s: float = 0.0
    response_preview: str = ""


@dataclass
class BenchmarkResults:
    runs: list[RunResult] = field(default_factory=list)


def load_teal_instructions() -> str:
    if not TEAL_PATH.exists():
        print(f"Warning: TEAL file not found at {TEAL_PATH}", file=sys.stderr)
        return ""
    return TEAL_PATH.read_text()


def load_prompts(path: Path) -> list[dict]:
    with open(path) as f:
        return json.load(f)


# ── Claude ──────────────────────────────────────────────────────────


def run_claude(model: str, system: str, prompt: str) -> RunResult:
    import anthropic

    client = anthropic.Anthropic()
    t0 = time.monotonic()
    response = client.messages.create(
        model=model,
        max_tokens=4096,
        temperature=0,
        system=system,
        messages=[{"role": "user", "content": prompt}],
    )
    latency = time.monotonic() - t0

    usage = response.usage
    output_tokens = usage.output_tokens
    input_tokens = usage.input_tokens
    # Extended thinking tokens are included in output_tokens for Claude
    # but there's no separate field exposed in the standard API response.
    # We capture what's available.
    thinking_tokens = 0

    preview = ""
    for block in response.content:
        if block.type == "text":
            preview = block.text[:200]
            break

    return RunResult(
        category="",
        model=model,
        condition="",
        input_tokens=input_tokens,
        output_tokens=output_tokens,
        thinking_tokens=thinking_tokens,
        total_tokens=input_tokens + output_tokens,
        latency_s=latency,
        response_preview=preview,
    )


# ── Gemini (Google AI Studio) ──────────────────────────────────────


def run_gemini(model: str, system: str, prompt: str) -> RunResult:
    from google import genai
    from google.genai import types

    client = genai.Client(api_key=os.environ["GOOGLE_API_KEY"])
    t0 = time.monotonic()
    response = client.models.generate_content(
        model=model,
        contents=prompt,
        config=types.GenerateContentConfig(
            system_instruction=system,
            temperature=0,
            max_output_tokens=4096,
        ),
    )
    latency = time.monotonic() - t0

    meta = response.usage_metadata
    input_tokens = meta.prompt_token_count or 0
    output_tokens = meta.candidates_token_count or 0
    thinking_tokens = getattr(meta, "thoughts_token_count", 0) or 0

    preview = ""
    if response.text:
        preview = response.text[:200]

    return RunResult(
        category="",
        model=model,
        condition="",
        input_tokens=input_tokens,
        output_tokens=output_tokens,
        thinking_tokens=thinking_tokens,
        total_tokens=input_tokens + output_tokens + thinking_tokens,
        latency_s=latency,
        response_preview=preview,
    )


# ── Runner ─────────────────────────────────────────────────────────


def run_benchmark(
    models: list[str],
    prompts: list[dict],
    base_system: str,
    teal_instructions: str,
) -> BenchmarkResults:
    results = BenchmarkResults()

    has_anthropic = bool(os.environ.get("ANTHROPIC_API_KEY"))
    has_google = bool(os.environ.get("GOOGLE_API_KEY"))

    if not has_anthropic and not has_google:
        print(
            "Error: Set ANTHROPIC_API_KEY and/or GOOGLE_API_KEY",
            file=sys.stderr,
        )
        sys.exit(1)

    teal_system = f"{base_system}\n\n{teal_instructions}"

    for p in prompts:
        category = p["category"]
        prompt_text = p["prompt"]

        for model in models:
            is_claude = model.startswith("claude-")
            is_gemini = not is_claude

            if is_claude and not has_anthropic:
                continue
            if is_gemini and not has_google:
                continue

            run_fn = run_claude if is_claude else run_gemini

            for condition, system in [
                ("baseline", base_system),
                ("teal", teal_system),
            ]:
                label = f"  [{condition:8s}] {model:25s} | {category}"
                print(label, end="", flush=True, file=sys.stderr)

                try:
                    result = run_fn(model, system, prompt_text)
                    result.category = category
                    result.condition = condition
                    results.runs.append(result)
                    print(
                        f" → {result.output_tokens:,} out, {result.thinking_tokens:,} think, {result.latency_s:.1f}s",
                        file=sys.stderr,
                    )
                except Exception as e:
                    print(f" → ERROR: {e}", file=sys.stderr)

                # Small delay to avoid rate limits
                time.sleep(1)

    return results


# ── Output ─────────────────────────────────────────────────────────


def format_results(results: BenchmarkResults) -> str:
    lines = []
    lines.append("# TEAL Benchmark Results\n")
    lines.append(f"Date: {time.strftime('%Y-%m-%d %H:%M')}\n")

    # Per-prompt table
    lines.append("## Per-Prompt Results\n")
    lines.append(
        "| Category | Model | Condition | Input | Output | Thinking | Total | Latency |"
    )
    lines.append(
        "|---|---|---|---:|---:|---:|---:|---:|"
    )

    for r in results.runs:
        lines.append(
            f"| {r.category} | {r.model} | {r.condition} "
            f"| {r.input_tokens:,} | {r.output_tokens:,} "
            f"| {r.thinking_tokens:,} | {r.total_tokens:,} "
            f"| {r.latency_s:.1f}s |"
        )

    # Aggregate by model
    lines.append("\n## Aggregate Savings by Model\n")
    lines.append(
        "| Model | Avg Output Baseline | Avg Output TEAL | Output Savings | Avg Thinking Baseline | Avg Thinking TEAL | Thinking Savings |"
    )
    lines.append("|---|---:|---:|---:|---:|---:|---:|")

    models_seen = []
    for r in results.runs:
        if r.model not in models_seen:
            models_seen.append(r.model)

    for model in models_seen:
        baseline = [r for r in results.runs if r.model == model and r.condition == "baseline"]
        teal = [r for r in results.runs if r.model == model and r.condition == "teal"]

        if not baseline or not teal:
            continue

        avg_out_base = sum(r.output_tokens for r in baseline) / len(baseline)
        avg_out_teal = sum(r.output_tokens for r in teal) / len(teal)
        avg_think_base = sum(r.thinking_tokens for r in baseline) / len(baseline)
        avg_think_teal = sum(r.thinking_tokens for r in teal) / len(teal)

        out_savings = (
            (avg_out_base - avg_out_teal) / avg_out_base * 100
            if avg_out_base > 0
            else 0
        )
        think_savings = (
            (avg_think_base - avg_think_teal) / avg_think_base * 100
            if avg_think_base > 0
            else 0
        )

        lines.append(
            f"| {model} "
            f"| {avg_out_base:,.0f} | {avg_out_teal:,.0f} | {out_savings:+.1f}% "
            f"| {avg_think_base:,.0f} | {avg_think_teal:,.0f} | {think_savings:+.1f}% |"
        )

    # Net savings accounting for TEAL prompt overhead
    teal_text = load_teal_instructions()
    # Rough estimate: ~1.3 tokens per word
    teal_overhead_est = int(len(teal_text.split()) * 1.3)
    lines.append(f"\n**TEAL instructions overhead:** ~{teal_overhead_est:,} tokens (estimated)")
    lines.append(
        "Net savings = output savings minus the additional input tokens from TEAL instructions.\n"
    )

    return "\n".join(lines)


# ── CLI ────────────────────────────────────────────────────────────


def main():
    parser = argparse.ArgumentParser(description="TEAL Benchmark Runner")
    parser.add_argument(
        "--models",
        nargs="+",
        default=None,
        help="Models to test (default: all available)",
    )
    parser.add_argument(
        "--prompts",
        type=Path,
        default=PROMPTS_PATH,
        help="Path to prompts JSON file",
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=None,
        help="Output file (default: stdout)",
    )
    parser.add_argument(
        "--system-prompt",
        default=BASELINE_SYSTEM,
        help="Base system prompt for baseline condition",
    )
    args = parser.parse_args()

    # Determine models
    if args.models:
        models = args.models
    else:
        models = []
        if os.environ.get("ANTHROPIC_API_KEY"):
            models.extend(CLAUDE_MODELS)
        if os.environ.get("GOOGLE_API_KEY"):
            models.extend(GEMINI_MODELS)

    if not models:
        print("No models available. Set API keys.", file=sys.stderr)
        sys.exit(1)

    prompts = load_prompts(args.prompts)
    teal = load_teal_instructions()

    print(f"Running TEAL benchmark:", file=sys.stderr)
    print(f"  Models: {', '.join(models)}", file=sys.stderr)
    print(f"  Prompts: {len(prompts)}", file=sys.stderr)
    print(f"  Conditions: baseline, teal", file=sys.stderr)
    print(f"  Total runs: {len(prompts) * len(models) * 2}", file=sys.stderr)
    print(file=sys.stderr)

    results = run_benchmark(models, prompts, args.system_prompt, teal)
    output = format_results(results)

    if args.output:
        args.output.write_text(output)
        print(f"\nResults written to {args.output}", file=sys.stderr)
    else:
        print(output)


if __name__ == "__main__":
    main()
