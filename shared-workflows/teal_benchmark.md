---
description: Measure TEAL token savings with real API data across Claude and Gemini.
---

This workflow provides a repeatable method to measure the actual token reduction from TEAL instructions. Unlike inline estimation (where the model guesses its own token usage), this uses real API response metadata — the only reliable source.

### 1. Prepare Test Prompts

Pull 5–8 prompts from real work, covering the same categories as [model_evaluation.md](model_evaluation.md):

| Category              | Example prompt                                                           |
| --------------------- | ------------------------------------------------------------------------ |
| Bug investigation     | "This endpoint returns 500 when limit > 100. Find the cause and fix."    |
| Multi-file feature    | "Add rate limiting middleware to all /api routes."                       |
| Refactor              | "Extract the validation logic from UserController into a shared module." |
| Architecture decision | "Should we use event sourcing or CRUD for the order service? Justify."   |
| Test writing          | "Write integration tests for the payment webhook handler."               |
| Code review           | "Review this PR diff for correctness, security, and style."              |

**Requirements for good test prompts:**

- Must require reasoning (not just code generation)
- Should be self-contained (include enough context in the prompt itself)
- Save prompts to a file (`teal-benchmark-prompts.json`) so runs are reproducible

### 2. Define the Two Conditions

Each prompt is run twice with identical user content but different system prompts:

| Condition    | System prompt                                         |
| ------------ | ----------------------------------------------------- |
| **Baseline** | Your standard system prompt WITHOUT TEAL instructions |
| **TEAL**     | Same system prompt WITH TEAL appended                 |

Keep everything else identical: model, temperature (0 for reproducibility), max tokens.

### 3. Run and Capture Metrics

#### Claude API

```python
response = client.messages.create(
    model="claude-sonnet-4-6-20250514",
    system=system_prompt,
    messages=[{"role": "user", "content": prompt}],
    temperature=0,
    max_tokens=4096,
)

metrics = {
    "input_tokens": response.usage.input_tokens,
    "output_tokens": response.usage.output_tokens,
    # Extended thinking (if enabled)
    "thinking_tokens": getattr(response.usage, "cache_creation_input_tokens", None),
}
```

Note: For Claude models with extended thinking, thinking tokens are billed separately. TEAL primarily targets thinking block compression, so capturing thinking tokens is critical when available via the API.

#### Gemini API (Google AI Studio)

```python
from google import genai
client = genai.Client(api_key=os.environ["GOOGLE_API_KEY"])
response = client.models.generate_content(
    model="gemini-3.1-pro",
    contents=prompt,
    config={"temperature": 0, "max_output_tokens": 4096},
)

metrics = {
    "input_tokens": response.usage_metadata.prompt_token_count,
    "output_tokens": response.usage_metadata.candidates_token_count,
    "thinking_tokens": getattr(response.usage_metadata, "thoughts_token_count", None),
}
```

#### Claude Code CLI (optional)

```bash
claude --output-format json -p "your prompt here" 2>/dev/null | jq '.usage'
```

### 4. Score Output Quality

Token savings are meaningless if the output degrades. For each pair, score both responses:

| Criterion         | 1–5 scale                                                 | What to check |
| ----------------- | --------------------------------------------------------- | ------------- |
| **Correctness**   | Did it reach the right conclusion / produce working code? |
| **Completeness**  | Were any important considerations dropped?                |
| **Actionability** | Can you act on the response without follow-up questions?  |
| **Clarity**       | Is the reasoning chain followable?                        |

A TEAL response that scores within 1 point of baseline on all criteria is a clean win. A response that drops 2+ points on Completeness or Correctness signals TEAL is compressing too aggressively for that task type.

### 5. Analyze Results

Build a comparison table per prompt:

| Prompt                | Model             | Condition | Input tokens | Output tokens | Thinking tokens | Total | Quality avg |
| --------------------- | ----------------- | --------- | ------------ | ------------- | --------------- | ----- | ----------- |
| Bug investigation     | Claude Sonnet 4.6 | Baseline  | 1,200        | 850           | —               | 2,050 | 4.2         |
| Bug investigation     | Claude Sonnet 4.6 | TEAL      | 1,450        | 520           | —               | 1,970 | 4.0         |
| Architecture decision | Gemini 3.1 Pro    | Baseline  | 1,100        | 1,200         | 3,400           | 5,700 | 4.5         |
| Architecture decision | Gemini 3.1 Pro    | TEAL      | 1,350        | 680           | 1,800           | 3,830 | 4.3         |

Then aggregate:

| Metric                     | Calculation                                               |
| -------------------------- | --------------------------------------------------------- |
| **Output token savings**   | `(baseline_output - teal_output) / baseline_output × 100` |
| **Thinking token savings** | Same formula for thinking tokens (where available)        |
| **Net token savings**      | Account for TEAL instructions adding ~800 input tokens    |
| **Quality delta**          | Average quality score difference across all criteria      |
| **Cost savings**           | Apply model-specific pricing to token deltas              |

### 6. Interpret and Adjust

| Finding                                                    | Action                                                                                                         |
| ---------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------- |
| >30% output savings, quality within 1 point                | TEAL working as intended                                                                                       |
| >30% savings but quality drops >1 point on some categories | TEAL too aggressive for those task types — consider exempting them (see TEAL §11: "When NOT to Compress")      |
| <15% savings                                               | TEAL instructions not effectively adopted by the model — review system prompt placement or model compatibility |
| Input token overhead > output savings                      | TEAL is net-negative for short responses — only apply for reasoning-heavy tasks                                |
| Thinking tokens show >40% reduction                        | Primary win — TEAL is compressing internal reasoning as designed                                               |

### 7. Cross-Model Comparison

Run the same prompts across both providers to find model-specific TEAL responsiveness:

| Model             | Avg output savings | Avg thinking savings | Avg quality delta |
| ----------------- | ------------------ | -------------------- | ----------------- |
| Claude Sonnet 4.6 |                    |                      |                   |
| Claude Opus 4.6   |                    |                      |                   |
| Gemini 3.1 Pro    |                    |                      |                   |
| Gemini 3 Flash    |                    |                      |                   |

Some models compress better than others. Models with explicit thinking/reasoning steps (extended thinking, thinking mode) should show the largest gains since TEAL targets internal reasoning.

---

### Reference: What TEAL Claims vs What to Verify

| TEAL claim                         | How to verify                                    |
| ---------------------------------- | ------------------------------------------------ |
| "40-60% reasoning token reduction" | Thinking token comparison (§5 above)             |
| "User-facing output stays natural" | Quality scoring (§4 above)                       |
| "No missed nuance"                 | Completeness score specifically                  |
| Abbreviations understood correctly | Check output doesn't misinterpret TEAL shorthand |
