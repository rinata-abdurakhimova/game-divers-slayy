# Architecture Decisions

## 2026-06-13: Minimal third-party visual pass

- Decision: use at most one o_lobster background and three static props without changing gameplay,
  scene contracts, collisions, or the top-down format.
- Reason: replace placeholders with a coherent pixel-art layer while protecting the finished Level 1
  loop and avoiding a full art-pack integration.
- Ownership: Rinata selects/imports/credits assets; Alina places world decoration; Polina has no
  required work.
- License: credit o_lobster under CC BY 4.0. Defer CraftPix source files until repository
  redistribution rights are confirmed.
- Fallback: remove optional decoration nodes and keep the current `SandVisual` and `WaterVisual`
  polygons.
- Scope cap: no full ZIP import, platformer hero, enemies, traps, HUD replacement, TileMap conversion,
  parallax, animated weather, or new collisions.

## 2026-06-13: Level 1 Easy vertical-slice contract

- Decision: replace the earlier color-survival prototype plan with one authored arithmetic room.
- Runtime: land addition `4 + 6 = 10`, triggered tide transition, then water subtraction
  `14 - 4 = 10`.
- Structure: `Main` composes Level 1 and signal-driven UI; `GameState` owns equation state;
  `Level01Controller` owns world sequencing.
- Reference principle: use Celeste-like simple controls, hand-authored challenges, clear feedback, and
  fast recovery, without copying its platforming mechanics.
- Affected owners: Polina, Alina, Rinata.
- Rollback: restore the previous architecture and contract before any gameplay files depend on these
  names.

Use this compact template for decisions that affect multiple owners:

```text
Date:
Decision:
Reason:
Affected owners:
Rollback:
```

## 2026-06-09: Three Coding Owners

Decision: Split ownership into core systems, world/content, and experience/integration. All members code,
playtest, decide scope, and pitch.

Reason: Minimize scene conflicts while keeping each participant directly involved in implementation and
presentation.

Affected owners: All.

Rollback: Update `OWNERSHIP.md` and the integration contract when names, skills, or availability change.
