#!/bin/bash
INPUT=$(cat)
PROMPT=$(echo "$INPUT" | jq -r '.prompt')

if [[ -z "$PROMPT" || "$PROMPT" == /* ]]; then
    exit 0
fi

EVAL=$(claude --print --model haiku "You are a friendly but concise English tutor. The user is writing a prompt to an AI agent. Evaluate it for English grammar and style. If the prompt is fine or just casually colloquial, return completely empty output (no text). If it is very lazy or grammatically poor, return exactly one short sentence suggesting a better phrasing. Do not include quotes, greetings, explanations, or 'Here is a suggestion'. Just the improved phrasing. Prompt to evaluate: $PROMPT")

if [ -n "$EVAL" ] && [ "$EVAL" != " " ]; then
    echo "<grammar_evaluation>"
    echo "Haiku evaluated the user's latest prompt and suggested this improved phrasing: $EVAL"
    echo "Instruction: Gently mention this suggested phrasing to the user in your very first sentence, then proceed to fulfill their request normally."
    echo "</grammar_evaluation>"
fi

exit 0
