# claude.ai onboarding lockout (September 2026)

Account ai@zelamundo.org lost web access on 2026-09-01 at about 15:00 CEST. Every web login routed to the onboarding form. Mobile app and Claude Code kept working. Support ticket 129632158. GDPR request sent to privacy@anthropic.com on 2026-09-03.

## Cause

Read from the claude.ai bundles at build bc53ba401f (assets-proxy.anthropic.com/claude-ai/v2/assets/v1), not inferred.

- The router treats `account.settings.has_finished_claudeai_onboarding === false` as "onboarding incomplete". A missing or null flag counts as complete.
- The onboarding page runs an effect on mount: if `has_started_claudeai_onboarding` is not set, it writes `{has_started_claudeai_onboarding: true, has_finished_claudeai_onboarding: false}` to the account.
- Accounts from before the flag existed (this one dates from 2024-03-06; the flag's introduction date is unknown) had neither flag. The first visit to /onboarding while logged in wrote the false value. A normal visit continues to the completed step and writes true again in the same session; the lockout happens when the flow is left before that, which is what the wrong-email detour did. The bootstrap response after the fact showed account `updated_at` 2026-09-01T13:04:12Z and `has_finished_claudeai_onboarding: false`. That the flag was unset before 1 September is inferred from the effect having fired, not observed.
- Trigger was a mistyped email (air@zelamundo.org, delivered by the catch-all inbox), then "Use a different email" on that onboarding page, which carried the return path to /onboarding for the real account.

## Fix

The app completes onboarding with `PATCH /api/account/settings`. Same call from the browser console on any claude.ai tab:

```js
await fetch("/api/account/settings", {
  method: "PATCH",
  credentials: "include",
  headers: { "Content-Type": "application/json" },
  body: JSON.stringify({ has_finished_claudeai_onboarding: true }),
}).then(r => r.status);
```

Fallback: walk through the form. The name step sends `display_name` and only sets `full_name` if empty. The final step sends the same PATCH with the questionnaire answers. No signup or account-creation endpoint is involved.

## Outcome

The PATCH returned 202 on 2026-09-04. The write is asynchronous: the first hard refresh still showed the onboarding form, and the account was restored on the web a short time later. `claude auth status` afterwards still showed the same account, org, and Max subscription.

## Backup

All conversations were exported before any fix attempt with the scripts in `scripts/claude-export/`. The session cookie stays valid while the UI is locked, so the internal API answers in a plain browser tab. Export lives in ~/Downloads/claude-chats: 370 conversations, 2,982 messages, one JSON per conversation plus Markdown in `md/`.
