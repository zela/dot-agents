"""Scripted grading for iteration 2: own tests, hidden tests, type escapes, crapper, dryer.

Usage: python3 -I grade2.py <workspace>
Writes grade-iter2/<eval>/<cfg>/<run>/scripted.json; assemble2.py merges blind grades.
"""
import json
import os
import re
import shutil
import subprocess
import sys
from pathlib import Path

W = Path(sys.argv[1])
I, G, H = W / "iteration-2", W / "grade-iter2", W / "hidden2"
ANSI = re.compile(r"\x1b\[[0-9;]*m")
ESCAPE = re.compile(r"(:|<|\()\s*any\b|\bas (any|unknown|[A-Z][A-Za-z]*|\{)|[A-Za-z0-9_)\]]!\.|[A-Za-z0-9_)\]]!\)|@ts-ignore|@ts-expect-error|eslint-disable")
ENV = {**os.environ, "PATH": os.environ["PATH"] + ":" + str(Path.home() / ".local/bin")}
HIDDEN = {"slug-backfill": "backfill", "filters-in-url": "filters", "mark-all-read": "inbox", "confirmation-email": "email", "island-shipping": "shipping"}


def sh(cmd: list[str], cwd: Path) -> subprocess.CompletedProcess:
    return subprocess.run(cmd, cwd=cwd, env=ENV, capture_output=True, text=True)


def vitest_results(cwd: Path, files: list[str]) -> dict[str, bool]:
    out = sh(["node_modules/.bin/vitest", "run", "--reporter=json", "--outputFile=vitest.json", *files], cwd)
    report = cwd / "vitest.json"
    if not report.exists():
        return {"<load error>": False}
    results = {}
    for suite in json.loads(report.read_text())["testResults"]:
        if not suite["assertionResults"] and suite.get("status") == "failed":
            results["<load error> " + Path(suite["name"]).name] = False
        for t in suite["assertionResults"]:
            results[t["title"]] = t["status"] == "passed"
    return results


def added_src_lines(diff: str) -> list[str]:
    lines, in_src = [], False
    for line in diff.splitlines():
        if line.startswith("+++ b/"):
            in_src = "/src/" in "/" + line[6:]
        elif in_src and line.startswith("+") and not line.startswith("+++"):
            lines.append(line[1:])
    return lines


def crap_rows(cwd: Path, target: str) -> list[dict]:
    cmd = f"node_modules/.bin/vitest run --coverage.enabled=true --coverage.reporter=lcov --coverage.reportsDirectory=coverage/grade --coverage.include={target}"
    out = sh(["crapper", "--coverage-command", cmd, target], cwd).stdout
    rows = []
    for line in ANSI.sub("", out).splitlines():
        m = re.match(r"^(\S+)\s+(\S+)\s+(\d+)\s+([\d.]+%|N/A)\s+([\d.]+|N/A)$", line.strip())
        if m:
            rows.append({"function": m.group(1), "cc": int(m.group(3)), "cov": m.group(4), "crap": None if m.group(5) == "N/A" else float(m.group(5))})
    return rows


def dryer_pairs(cwd: Path, focus: str) -> list[str]:
    files = [str(p.relative_to(cwd)) for p in (cwd / "src").rglob("*.ts")]
    out = ANSI.sub("", sh(["dryer", *files], cwd).stdout)
    return [b.strip() for b in out.split("\n\n") if b.startswith("DUPLICATE") and focus in b]


for run in sorted(I.glob("eval-*/*/run-*")):
    ev, cfg = run.parent.parent.name, run.parent.name
    name = ev.split("-", 2)[2]
    out = G / ev / cfg / run.name
    p = out / "p"
    if p.exists() or not (run / "outputs" / "response.md").exists():
        continue
    out.mkdir(parents=True, exist_ok=True)
    shutil.copytree(run / "outputs" / "project", p, symlinks=True, ignore=shutil.ignore_patterns("coverage", ".metrics", "vitest.json"))
    sh(["git", "add", "-A"], p)
    diff = sh(["git", "diff", "--cached"], p).stdout
    (run / "outputs" / "diff.patch").write_text(diff)
    res: dict = {"own": vitest_results(p, [])}
    res["escapes"] = [l.strip() for l in added_src_lines(diff) if ESCAPE.search(l)]
    if name in HIDDEN:
        h = out / "h"
        shutil.copytree(p, h, symlinks=True, ignore=shutil.ignore_patterns(".git"))
        shutil.copy(H / f"{HIDDEN[name]}.hidden.test.ts", h / "tests")
        res["hidden"] = vitest_results(h, [f"tests/{HIDDEN[name]}.hidden.test.ts"])
    if name == "island-shipping":
        res["crap"] = crap_rows(p, "src/shipping.ts")
    if name == "confirmation-email":
        res["dryer"] = dryer_pairs(p, "src/email/")
        email = p / "src/email/confirmation.ts"
        src = email.read_text() if email.exists() else ""
        res["own_money_logic"] = re.findall(r"Intl\.NumberFormat|toFixed\(|/\s*100\b|\.reduce\(", src)
    (out / "scripted.json").write_text(json.dumps(res, indent=2))
    hid = res.get("hidden", {})
    print(f"{ev:28} {cfg:14} {run.name}  own {sum(res['own'].values())}/{len(res['own'])}  hidden {sum(hid.values())}/{len(hid)}  escapes {len(res['escapes'])}"
          + (f"  maxCRAP {max((r['crap'] or 0) for r in res['crap']) if res['crap'] else 'n/a'}" if "crap" in res else "")
          + (f"  dryer {len(res['dryer'])} money {res['own_money_logic']}" if "dryer" in res else ""))
