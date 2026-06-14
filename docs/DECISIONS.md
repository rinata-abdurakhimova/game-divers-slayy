# Architecture Decisions

## 2026-06-13: Boss 67 platformer score-fight reset

- Decision: replace the top-down Guardian 10 arithmetic-room plan with a side-view platformer boss
  fight against Boss 67.
- Runtime: placeholder cutscene, safe sand tutorial, Boss 67 appears, player changes score through
  pickups/projectiles, water events introduce rule variants and movement complications.
- Level shape: Level 1 uses the latest board transcription as a 53-column authored route viewed through
  a `12 x 8` camera window. Columns `1-18` are safe-zone/tutorial space; Boss 67 begins at column `19`.
  Only the right edge loops back to column `19`; walking left after the safe start closes must clamp or
  block the player, never wrap them into another chunk.
- Safe start: it exists only on the opening screen and must not leave a visible stone-like block in the
  middle of gameplay after it closes.
- Win condition: score becomes exactly `67.00`.
- Failure condition: score becomes `0.00`.
- Reason: match the board concept and make `67` the central playable goal instead of a later boss.
- Affected owners: Polina, Alina, Rinata.
- Rollback: restore the previous `4 + 6` / `14 - 4` Level 1 contract before any platformer code
  depends on the new names.

## 2026-06-13: Platformer controller reference

- Decision: use the Noasey `Ultimate 2D Platformer Controller` as a reference only, adapting a small
  movement subset into the existing Player.
- Allowed: horizontal movement, gravity, falling, one jump, short hop, coyote time, jump buffering,
  floor/platform collision.
- Cut: dash, roll, crouch, run modifier, wall jump, wall slide, wall latch, permanent double jump,
  ground pound, corner correction.
- Reason: keep movement responsive without importing a large controller or changing ownership.
- Affected owners: Polina, Alina, Rinata.
- Rollback: keep the current Player until the isolated platformer movement test passes.

## 2026-06-13: Platformer visual asset policy

- Decision: platformer packs may provide visual assets only. They do not provide reusable game logic.
- Reason: movement, jumping, score, water, projectiles, restart, and boss behavior must remain owned by
  the team and covered by our contracts.
- Affected owners: all.
- Rollback: use placeholders if asset import delays the playable path.

## 2026-06-13: Minimal third-party visual pass

- Decision: keep prior o_lobster visual attribution, but treat the earlier top-down decoration pass as
  superseded by the platformer reset.
- Reason: the imported art can still inform presentation, but the gameplay contract changed.
- Affected owners: Rinata and Alina.
- Rollback: remove optional art and use placeholder blocks/backgrounds.

## 2026-06-09: Three Coding Owners

Decision: Split ownership into core systems, world/content, and experience/integration. All members code,
playtest, decide scope, and pitch.

Reason: Minimize scene conflicts while keeping each participant directly involved in implementation and
presentation.

Affected owners: All.

Rollback: Update `OWNERSHIP.md` and the integration contract when names, skills, or availability change.

Use this compact template for future decisions:

```text
Date:
Decision:
Reason:
Affected owners:
Rollback:
```
