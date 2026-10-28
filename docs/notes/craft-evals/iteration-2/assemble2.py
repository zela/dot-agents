"""Build grading.json for each iteration-2 run from scripted.json plus the blind wholesale grades."""
import json
import re
import sys
from pathlib import Path

W = Path(sys.argv[1])
I, G = W / "iteration-2", W / "grade-iter2"
blind = json.loads((G / "blind" / "eval-1-wholesale-tier" / "grades.json").read_text())
blind_map = json.loads((G / "blind-mapping-eval1.json").read_text())

HIDDEN_TEXT = {
    "slug-backfill": {
        "HB1": "fills null slugs and keeps existing ones", "HB2": "avoids a slug an existing post already has",
        "HB3": "gives duplicate titles unique slugs", "HB4": "a second run changes nothing",
        "HB5": "a rerun after a crash halfway completes without changing finished posts",
        "HB6": "a title with no letters or digits gets a non-empty unique slug"},
    "filters-in-url": {
        "HU1": "round trip of a full filter", "HU2": "round trip of the defaults", "HU3": "junk values fall back to defaults",
        "HU4": "empty numbers are null, not 0", "HU5": "a junk maxPrice does not hide every product",
        "HU6": "an inherited object key such as constructor is not a category"},
    "mark-all-read": {
        "HI1": "markAllRead sends every unread id in one call and clears the badge",
        "HI2": "a notification that arrives during markAllRead stays unread", "HI3": "a failed API call clears nothing",
        "HI4": "the existing markRead lost update is fixed: a notification arriving mid-call is still counted"},
    "confirmation-email": {
        "HE1": "amounts use the shop formatter", "HE2": "GBP orders use the GBP formatter",
        "HE3": "a discount larger than the subtotal matches the cart total", "HE4": "the greeting names the order"},
    "island-shipping": {
        "HS1": "a Hebrides postcode adds 15", "HS2": "a Shetland postcode adds 15", "HS3": "KW15 and KW17 are islands",
        "HS4": "KW1, KW14 and KW18 are mainland", "HS5": "over 30 kg is freight at 80, even express or abroad",
        "HS6": "exactly 30 kg is not freight", "HS7": "existing rules still hold"},
}
COMMENT = re.compile(r"^\s*(//|/\*|\*)")


def result(text: str, passed: bool, evidence: str) -> dict:
    return {"text": text, "passed": bool(passed), "evidence": evidence}


texts_by_eval: dict[str, list[str]] = {}
for run in sorted(I.glob("eval-*/*/run-*")):
    ev, cfg = run.parent.parent.name, run.parent.name
    name = ev.split("-", 2)[2]
    s = json.loads((G / ev / cfg / run.name / "scripted.json").read_text())
    p = G / ev / cfg / run.name / "p"
    res = []
    if name == "wholesale-tier":
        for j in blind[blind_map[f"{cfg}/{run.name}"]]:
            res.append(result(j["text"], j["passed"], "Blind grader: " + j["evidence"]))
    for hid, desc in HIDDEN_TEXT.get(name, {}).items():
        picked = {k: v for k, v in s.get("hidden", {}).items() if k.startswith(hid + " ")}
        ok = bool(picked) and all(picked.values())
        res.append(result(f"{hid} Hidden test: {desc}", ok, "passed" if ok else ("failed" if picked else "did not load: " + ", ".join(k for k in s.get("hidden", {}) if k.startswith("<load")))))
    if name == "mark-all-read":
        src = (p / "src/inbox.ts").read_text()
        derived = bool(re.search(r"get\s+unreadCount\s*\(", src)) and not re.search(r"this\.unreadCount\s*[-+]?=", src)
        res.append(result("E4.S unreadCount is derived from the unread set (a getter), so no method can write a stale count", derived,
                          "getter, no assignments" if derived else "unreadCount is a field that methods assign"))
    if name == "confirmation-email":
        res.append(result("E5.D dryer finds no duplicate pair that touches src/email/", not s["dryer"], "; ".join(s["dryer"]) or "no pairs"))
        res.append(result("E5.M confirmation.ts has no money formatting or totals arithmetic of its own (Intl.NumberFormat, toFixed, / 100, reduce)",
                          not s["own_money_logic"], ", ".join(s["own_money_logic"]) or "none"))
    if name == "island-shipping":
        worst = max((r["crap"] or 0) for r in s["crap"]) if s["crap"] else None
        res.append(result("E6.C Every function in src/shipping.ts scores CRAP < 10 with coverage from the project's own tests (crapper)",
                          worst is not None and worst < 10, ", ".join(f"{r['function']} CC {r['cc']} cov {r['cov']} CRAP {r['crap']}" for r in s["crap"])))
    own = s["own"]
    res.append(result("Own test suite passes in the final state", own and all(own.values()), f"{sum(own.values())}/{len(own)} passed"))
    code_escapes = [l for l in s["escapes"] if not COMMENT.match(l)]
    res.append(result("The diff adds no any, as-cast, non-null !, @ts-ignore, @ts-expect-error or eslint-disable in src/", not code_escapes,
                      " | ".join(code_escapes) or "none (comment lines excluded)"))
    texts_by_eval[ev] = [r["text"] for r in res]
    passed = sum(r["passed"] for r in res)
    grading = {"expectations": res, "summary": {"passed": passed, "failed": len(res) - passed, "total": len(res), "pass_rate": round(passed / len(res), 4)}}
    (run / "grading.json").write_text(json.dumps(grading, indent=2))
    meta = json.loads((run / "eval_metadata.json").read_text())
    meta["assertions"] = [r["text"] for r in res]
    (run / "eval_metadata.json").write_text(json.dumps(meta, indent=2))
    print(f"{ev:28} {cfg:14} {run.name}  {passed}/{len(res)}" + ("" if passed == len(res) else "  FAILED: " + "; ".join(r["text"][:38] for r in res if not r["passed"])))

ev2 = json.loads((W / "evals2.json").read_text())
for e in ev2["evals"]:
    e["expectations"] = texts_by_eval.get(f"eval-{e['id']}-{e['name']}", [])
(W / "evals2.json").write_text(json.dumps(ev2, indent=2))
