#!/usr/bin/env python3
"""Convert claude.ai conversation JSON (from download.js) to one Markdown file per conversation.

Usage: to_markdown.py INPUT OUT_DIR

INPUT is a bundle file, a single conversation file, or a directory of such files (*.json, non-recursive).

Renders the active branch of each conversation (the path from current_leaf_message_uuid to the root). Messages on other branches go to an appendix. Thinking blocks and attachment contents are folded into <details>.
"""
import json
import re
import sys
from pathlib import Path

ROOT_SENTINEL = "00000000-0000-4000-8000-000000000000"


def slug(text, limit=60):
    s = re.sub(r"[^\w\s-]", "", text or "", flags=re.UNICODE).strip().lower()
    s = re.sub(r"[\s_-]+", "-", s)
    return s[:limit].strip("-") or "untitled"


def fence(text, lang=""):
    text = "" if text is None else str(text)
    ticks = "```"
    while ticks in text:
        ticks += "`"
    return f"{ticks}{lang}\n{text}\n{ticks}"


def details(summary, body):
    return f"<details>\n<summary>{summary}</summary>\n\n{body}\n\n</details>"


def render_tool_result_content(content):
    if isinstance(content, str):
        return content
    if isinstance(content, list):
        parts = []
        for item in content:
            if isinstance(item, dict) and item.get("type") == "text":
                parts.append(item.get("text", ""))
            else:
                parts.append(json.dumps(item, ensure_ascii=False, indent=2))
        return "\n".join(parts)
    return json.dumps(content, ensure_ascii=False, indent=2)


def render_block(block):
    kind = block.get("type")
    if kind == "text":
        return block.get("text", "")
    if kind == "thinking":
        return details("Thinking", block.get("thinking") or block.get("text") or "")
    if kind == "tool_use":
        body = fence(json.dumps(block.get("input"), ensure_ascii=False, indent=2), "json")
        return details(f"Tool call: {block.get('name', '?')}", body)
    if kind == "tool_result":
        body = fence(render_tool_result_content(block.get("content")))
        label = "Tool result" + (" (error)" if block.get("is_error") else "")
        return details(label, body)
    return details(f"Block: {kind}", fence(json.dumps(block, ensure_ascii=False, indent=2), "json"))


def render_message(msg):
    who = {"human": "User", "assistant": "Claude"}.get(msg.get("sender"), msg.get("sender") or "?")
    parts = [f"### {who} · {msg.get('created_at', '')}"]
    content = msg.get("content")
    if isinstance(content, list) and content:
        parts.extend(render_block(b) for b in content if isinstance(b, dict))
    elif msg.get("text"):
        parts.append(msg["text"])
    for att in msg.get("attachments") or []:
        name = att.get("file_name") or "attachment"
        extracted = att.get("extracted_content")
        line = f"**Attachment:** {name}"
        if extracted:
            line += "\n\n" + details("Extracted content", fence(extracted))
        parts.append(line)
    for f in msg.get("files") or []:
        parts.append(f"**File:** {f.get('file_name') or f.get('file_uuid') or json.dumps(f)}")
    return "\n\n".join(p for p in parts if p)


def active_path(messages, leaf_uuid):
    by_uuid = {m.get("uuid"): m for m in messages}
    path = []
    seen = set()
    cur = leaf_uuid
    while cur and cur in by_uuid and cur not in seen:
        seen.add(cur)
        path.append(by_uuid[cur])
        cur = by_uuid[cur].get("parent_message_uuid")
        if cur == ROOT_SENTINEL:
            break
    path.reverse()
    return path


def render_conversation(conv):
    messages = conv.get("chat_messages") or []
    messages_sorted = sorted(messages, key=lambda m: (m.get("index") is None, m.get("index", 0), m.get("created_at", "")))
    main = active_path(messages, conv.get("current_leaf_message_uuid"))
    if not main:
        main = messages_sorted
    main_ids = {m.get("uuid") for m in main}
    other = [m for m in messages_sorted if m.get("uuid") not in main_ids]

    lines = [
        "---",
        f"title: {json.dumps(conv.get('name') or 'Untitled', ensure_ascii=False)}",
        f"uuid: {conv.get('uuid')}",
        f"created: {conv.get('created_at')}",
        f"updated: {conv.get('updated_at')}",
        f"model: {conv.get('model')}",
        f"project_uuid: {conv.get('project_uuid')}",
        f"messages: {len(messages)}",
        "---",
        "",
        f"# {conv.get('name') or 'Untitled'}",
        "",
    ]
    lines.append("\n\n---\n\n".join(render_message(m) for m in main))
    if other:
        lines += ["", "", f"## Other branches ({len(other)} messages)", ""]
        lines.append("\n\n---\n\n".join(render_message(m) for m in other))
    return "\n".join(lines) + "\n"


def load_conversations(src):
    files = sorted(src.glob("*.json")) if src.is_dir() else [src]
    convs = []
    for f in files:
        data = json.loads(f.read_text(encoding="utf-8"))
        if isinstance(data, dict) and "chat_messages" in data:
            convs.append(data)
        elif isinstance(data, dict) and "conversations" in data:
            convs.extend(data["conversations"])
        elif isinstance(data, list):
            convs.extend(c for c in data if isinstance(c, dict) and "chat_messages" in c)
        else:
            print(f"skip {f.name}: not a conversation or bundle", file=sys.stderr)
    return convs


def main():
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    src = Path(sys.argv[1])
    out = Path(sys.argv[2])
    out.mkdir(parents=True, exist_ok=True)
    convs = load_conversations(src)
    written = 0
    for conv in convs:
        created = (conv.get("created_at") or "")[:10] or "undated"
        name = f"{created}-{slug(conv.get('name'))}-{(conv.get('uuid') or '')[:8]}.md"
        (out / name).write_text(render_conversation(conv), encoding="utf-8")
        written += 1
    print(f"wrote {written} files to {out}")


if __name__ == "__main__":
    main()
