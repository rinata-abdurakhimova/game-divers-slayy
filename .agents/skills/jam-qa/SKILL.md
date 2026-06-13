---
name: jam-qa
description: Protect the playable Godot build through contract checks, headless smoke tests, manual core-loop testing, severity triage, and emergency scope cuts. Use for QA, reviews, regressions, build failures, BUG RUN, WE ARE STUCK, feature freeze, or export readiness.
---

# Jam QA

Read `docs/QA_BOT_WORKFLOW.md`, `INTEGRATION_CONTRACT.md`, and `OWNERSHIP.md`.

Run `tools/qa.cmd` on Windows, `bash tools/qa.sh` on macOS/Linux, or `tools/qa.ps1` in CI, then test launch, onboarding, core mechanic,
feedback, success, failure, and restart.
Report build/ref, pass or fail, reproduction, severity, contract regression, owner, fastest safe fix,
fallback or cut, and retest.

For `BUG RUN` or `WE ARE STUCK`:

1. Stop feature proposals.
2. Reproduce the smallest failure.
3. Restore the playable path before improving architecture.
4. Prefer disabling one unstable feature over redesigning multiple systems.
5. Verify boot, core loop, both outcomes, and restart.

Do not expand scope during QA. Blockers and high-severity failures take precedence over polish.
