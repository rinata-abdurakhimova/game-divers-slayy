# QA Bot Workflow

The QA bot protects the playable path. It does not judge style or request new features.

## Triggers

- Every pull request and push to `main`
- Manual `BUG RUN`
- Manual `WE ARE STUCK`
- Before feature freeze and every final export
- Any contract reset affecting movement, score, water, or restart

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
headless Godot boot when `project.godot` and a Godot executable are available.

## Manual Playable-Path Pass

1. Clean launch into `Main.tscn`.
2. Skip or complete the placeholder cutscene.
3. Spawn in the safe sand area.
4. Walk, fall, land, and jump onto one block.
5. Confirm the safe area closes after the first taught jump.
6. Confirm the safe closure does not leave a visible stone-like block in the middle of the playfield.
7. Walk left after the boss run starts and confirm the player is clamped or blocked, not wrapped.
8. Confirm Boss 67 appears.
9. Confirm boss digits are readable and appear to come from Boss 67.
10. Collect a land pickup and confirm score changes.
11. Touch or simulate a `*0` and confirm score `0.00` fails.
12. Restart.
13. Reach `18` blocks and confirm purple projectiles begin.
14. Reach `28` blocks and confirm water starts for `10` seconds.
15. Confirm the HUD shows the active water rule.
16. Confirm score can become negative without failing.
17. Reach exact `67.00` and confirm victory.
18. Restart again.
19. Confirm input, HUD, water state, projectiles, power-ups, and score reset cleanly.

## Severity

| Severity | Meaning | Response |
| --- | --- | --- |
| Blocker | Cannot boot, move, jump, change score, win, fail, or restart | Stop merges and restore playable path |
| High | Score rules, water rules, projectiles, or contracts fail consistently | Fix before new feature work |
| Medium | Confusing feedback, unclear water rule, or broken secondary content | Fix before feature freeze |
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
movement, score change, water, win/fail, and restart.
