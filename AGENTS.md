# Game Divers Agent Guide

This repository is a three-person Godot 4.x game-jam project. Treat every task as part of a shared,
time-boxed production build. Optimize for a small, connected, stable, polished game rather than feature
count.

## Start Here

Before implementation, read:

1. `ARCHITECTURE.md`
2. `INTEGRATION_CONTRACT.md`
3. `OWNERSHIP.md`

Use the repository skill that matches the request:

- Theme or concept selection: `$jam-brainstorm`
- New system, entity, or cross-owner change: `$jam-architecture`
- Gameplay or content implementation: `$jam-implement`
- HUD, menus, onboarding, audio, or game feel: `$jam-ui-polish`
- Testing, triage, `BUG RUN`, or `WE ARE STUCK`: `$jam-qa`
- Demo and presentation preparation: `$jam-pitch`

## Team Model

All three members write code and share product decisions, playtesting, and pitching.

- Polina, Core Systems: player, core mechanic, rules, and gameplay state.
- Alina, World and Content: levels, enemies, obstacles, interactions, and content.
- Rinata, Experience and Integration: UI, audio, main scenes, autoloads, exports, and build health.

These labels describe ownership, not rank. Shared pitching never gives one member unilateral product
authority. Scope decisions use the rule in `OWNERSHIP.md`.

## Required Working Order

Use this order unless fixing an active build failure:

`Theme -> Concepts -> MVP -> Contract -> Vertical slice -> Integration -> Polish -> Pitch`

Do not build parallel features until their scene owner, inputs, outputs, signals, dependencies, and test
path are recorded in `INTEGRATION_CONTRACT.md`.

## Implementation Rules

- Use Godot 4.x and typed GDScript where practical.
- Prefer small scenes, composition, signals, and exported tuning values.
- Keep UI independent from gameplay node paths. UI consumes documented signals or state snapshots.
- Centralize cross-scene events, audio routing, and scene changes in the documented autoloads.
- Avoid new manager classes, inheritance layers, plugins, and dependencies unless they remove immediate
  jam risk.
- Do not edit another member's owned files without coordination recorded in the task or pull request.
- Never silently rename a scene, signal, input action, autoload, or expected asset.
- Keep the game runnable after every integration change.

## Response Contract

For implementation work, report:

1. Goal
2. Acting team role
3. Files and ownership
4. Implementation
5. Signals and dependencies
6. Teammate handoff
7. Test checklist
8. Scope warning, when relevant

Finish with integration notes that name dependencies, emitted signals, consumers, assets, and the
shortest manual test.

## Emergency Mode

When a request contains `BUG RUN` or `WE ARE STUCK`:

1. Stop proposing features.
2. Reproduce and classify the failure.
3. Protect the last playable path.
4. Prefer a small workaround or feature cut over risky redesign.
5. Verify boot, core loop, win/lose, and restart.
6. Record deferred work without blocking the build.

## Definition of Done

A change is done only when its contract is current, owned files are respected, the relevant manual test
passes, `tools/qa.cmd` passes on Windows (or `tools/qa.sh` on macOS/Linux), and another member can
understand how to integrate or exercise it.
