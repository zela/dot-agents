"""Realistic trigger test for craft: does the agent invoke the skill before its first edit?

Each run gets its own copy of a fixture project with craft installed as a project skill,
so no two runs share a skills folder. Only read-only tools and Skill are allowed, so the
first Edit/Write is an attempt that the CLI denies: nothing is written.

Usage: python3 -I trigger_real.py <workspace> <cases.json> <runs> <workers>
"""
import json
import os
import shutil
import subprocess
import sys
import tempfile
import time
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

W, CASES, RUNS, WORKERS = Path(sys.argv[1]), Path(sys.argv[2]), int(sys.argv[3]), int(sys.argv[4])
SKILL = Path.home() / "dot-agents/custom-skills/craft"
EDITS = {"Edit", "Write", "MultiEdit", "NotebookEdit"}
TIMEOUT = 240


def run_case(case: dict, n: int) -> dict:
    root = Path(tempfile.mkdtemp(prefix=f"trig-{case['id']}-{n}-", dir=W / "trigger-real"))
    proj = root / "project"
    shutil.copytree(W / "fixtures2" / case["fixture"], proj, symlinks=True)
    shutil.copytree(SKILL, proj / ".claude/skills/craft")
    cmd = ["claude", "-p", case["query"], "--model", "claude-opus-5-5", "--output-format", "stream-json", "--verbose",
           "--no-session-persistence", "--allowedTools", "Read", "Glob", "Grep", "Skill"]
    env = {k: v for k, v in os.environ.items() if k != "CLAUDECODE"}
    proc = subprocess.Popen(cmd, cwd=proj, env=env, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True)
    tools, verdict, start = [], None, time.time()
    try:
        for line in proc.stdout:
            if time.time() - start > TIMEOUT:
                verdict = "timeout"
                break
            try:
                event = json.loads(line)
            except json.JSONDecodeError:
                continue
            if event.get("type") != "assistant":
                continue
            for c in event["message"].get("content", []):
                if c.get("type") != "tool_use":
                    continue
                name, inp = c["name"], c.get("input", {})
                tools.append(name if name != "Skill" else f"Skill({inp.get('skill', '')})")
                if name == "Skill" and "craft" in str(inp.get("skill", "")):
                    verdict = "craft-before-edit"
                elif name in EDITS:
                    verdict = "edit-first"
                if verdict:
                    break
            if verdict:
                break
    finally:
        if proc.poll() is None:
            proc.kill()
            proc.wait()
    return {"id": case["id"], "run": n, "should": case["should_trigger"], "triggered": verdict == "craft-before-edit",
            "verdict": verdict or "ended-without-either", "tools": tools[:12], "seconds": round(time.time() - start, 1)}


cases = json.loads(CASES.read_text())
(W / "trigger-real").mkdir(exist_ok=True)
jobs = [(c, n) for c in cases for n in range(1, RUNS + 1)]
with ThreadPoolExecutor(WORKERS) as pool:
    results = list(pool.map(lambda j: run_case(*j), jobs))
(W / "trigger-real" / "results.json").write_text(json.dumps(results, indent=2))
for c in cases:
    rs = [r for r in results if r["id"] == c["id"]]
    hits = sum(r["triggered"] for r in rs)
    ok = hits == len(rs) if c["should_trigger"] else hits == 0
    print(f"{'PASS' if ok else 'FAIL'}  {hits}/{len(rs)} should={c['should_trigger']!s:5}  {c['id']:16} {[r['verdict'] for r in rs]}")
pos = [r for r in results if r["should"]]
neg = [r for r in results if not r["should"]]
print(f"recall {sum(r['triggered'] for r in pos)}/{len(pos)}  false triggers {sum(r['triggered'] for r in neg)}/{len(neg)}")
