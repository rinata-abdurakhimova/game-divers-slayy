# Ownership and Collaboration

These names and ownership areas are authoritative in issues, branches, and handoffs.

## Polina: Core Systems

Primary areas:

- `scenes/actors/Player.tscn`
- `scripts/actors/player/`
- `scripts/gameplay/`
- core mechanic, player movement, score rules, water state, power-up timers, win/lose calculation

Current asset-pass responsibility:

- Own the side-view Player conversion and preserve documented collision, reset, score, and signal
  contracts. Do not replace the Player scene wholesale with an imported controller.

Pitch segment: hook and core mechanic. Demo responsibility: explain controls and the satisfying player
decision.

## Alina: World and Content

Primary areas:

- `scenes/actors/enemies/`
- `scenes/world/`
- `scripts/actors/enemies/`
- `scripts/world/`
- levels, terrain, obstacles, pickups, projectiles, interactions, encounter pacing

Current asset-pass responsibility:

- Build the side-view Boss 67 Level 1 route, including sand blocks, pickup placement, projectile
  blockers, water-era ceiling blocks when needed, and readable `12 x 8` chunks.
- Keep required jumps within Polina's approved movement contract.
- Do not change score rules, signals, or Player behavior for layout convenience without contract review.

Pitch segment: theme connection and content progression. Demo responsibility: guide the intended route
and point out the strongest theme moment.

## Rinata: Experience and Integration

Primary areas:

- `scenes/main/`
- `scenes/ui/`
- `scripts/autoload/`
- `scripts/ui/`
- `assets/audio/`, `assets/fonts/`
- `project.godot`, `export_presets.cfg`
- `assets/third_party/`, `THIRD_PARTY_NOTICES.md`

Current asset-pass responsibility:

- Select and import only files actually used by Level 1.
- Preserve nearest-neighbor import settings and verify build/export health.
- Own cutscene shell, HUD readability, water overlay, audio feedback, restart flow, and attribution.
- Record source, author, and license; block assets whose repository distribution rights are unclear.

Pitch segment: polish, technical reliability, and close. Demo responsibility: launch the build, recover
from failure, and run the fallback route.

## Shared Areas

All members co-own:

- `AGENTS.md`, `ARCHITECTURE.md`, `INTEGRATION_CONTRACT.md`, `OWNERSHIP.md`
- `docs/SCOPE.md`, `docs/DECISIONS.md`, `docs/PITCH.md`
- playtesting, bug reporting, scope cuts, and final pitch rehearsal

The current task owner may edit shared docs. Contract changes require acknowledgement from every
affected owner.

## Coordination Rules

1. One branch or worktree per feature; use `codex/<short-topic>` for agent-created branches.
2. Do not edit another member's primary area without a handoff or explicit request.
3. Announce shared-file edits before starting and keep them narrowly scoped.
4. Merge a thin end-to-end slice before deepening any one area.
5. Rebase or update before editing `project.godot`, autoloads, or `Main.tscn`.
6. The owner supplies a manual test; the integrator verifies it from `Main.tscn`.
7. Broken main stops feature work until restored.

## Scope Decisions

Any member may propose a cut. A cut is accepted when two members agree, unless the current main build is
broken; then Rinata may temporarily disable the smallest unstable feature and document the decision.

Adding a feature after scope lock requires:

- a named owner;
- a contract and fallback;
- an estimate small enough for the remaining integration window;
- agreement from at least two members.

## Shared Pitching

Every member speaks. Aim for a three-minute presentation:

| Time | Speaker | Content |
| --- | --- | --- |
| 0:00-0:40 | Polina | Hook, controls, core mechanic |
| 0:40-1:20 | Alina | Theme connection, progression, content |
| 1:20-2:20 | Rinata | Live demo, polish, reliability |
| 2:20-3:00 | All | Strongest moment, lessons, close, questions |

Rehearse speaker handoffs and the no-demo fallback. Any member must be able to finish the pitch if a
teammate is occupied with the build.
