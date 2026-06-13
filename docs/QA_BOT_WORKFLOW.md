# QA Bot Workflow

The QA bot protects the playable path. It does not judge style or request new features.

## Triggers

- Every pull request and push to `main`
- Manual `BUG RUN`
- Manual `WE ARE STUCK`
- Before feature freeze and every final export

## Automated Pass

Run:

```powershell
tools\qa.cmd
```

On macOS or Linux:

```bash
bash tools/qa.sh
```

The check verifies required team contracts, skill validity basics, unresolved merge markers, and a
headless Godot boot when `project.godot` and a Godot executable are available. CI installs Godot for the
headless pass once the project exists.

## Manual Playable-Path Pass

1. Clean launch into the intended start scene.
2. Understand the goal and controls without developer explanation.
3. Exercise the core mechanic.
4. Trigger damage or equivalent risk feedback.
5. Trigger progress, score, or timer feedback.
6. Reach success.
7. Restart.
8. Reach failure.
9. Restart again.
10. Confirm audio, UI, focus, and input remain correct.

## Severity

| Severity | Meaning | Response |
| --- | --- | --- |
| Blocker | Cannot boot, play, finish, fail, or restart | Stop merges and restore main |
| High | Core mechanic or contract fails consistently | Fix before new feature work |
| Medium | Confusing feedback or broken secondary content | Fix before feature freeze |
| Low | Cosmetic issue with a safe workaround | Queue for polish |

## Bot Report Format

```text
Build/ref:
Result: PASS / FAIL
Playable path:
Blockers:
Contract regressions:
Owner:
Fastest safe fix:
Fallback/cut:
Retest:
```

## Emergency Behavior

On `BUG RUN` or `WE ARE STUCK`, stop feature suggestions. Reproduce the smallest failing path, name the
owner, preserve or restore the last playable build, choose the least invasive fix, and retest boot,
core loop, outcome, and restart.
