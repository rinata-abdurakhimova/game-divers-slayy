# Polina Level 1 Boss 67 Core Plan

## Skill Pass

- `$jam-brainstorm`: concept is locked. Do not generate new concepts unless the team resets scope.
- `$jam-architecture`: source of truth is `ARCHITECTURE.md` and `INTEGRATION_CONTRACT.md`.
- `$jam-implement`: use only after the platformer contract is accepted and Alina/Rinata have their
  side-view test room, inputs, and scene shell ready.
- `$jam-qa`: required before merging movement conversion, water behavior, boss projectiles, score
  rules, or restart changes.

## Goal

Deliver the Polina-owned core for Level 1:

```text
intro cutscene placeholder -> safe platformer tutorial -> Boss 67 appears -> collect and avoid
arithmetic values -> survive land/water rule shifts -> reach exact score 67 -> victory
```

This is no longer the old two-equation room. Level 1 is a side-view platformer score fight. The player
must build the score to exactly `67.00`. Score may become negative. Score `0.00` means immediate
failure/play-again.

## Acting Role

Polina, Core Systems.

Primary promise: make movement, score math, water rule changes, failure/victory, and restart stable
enough that Alina can build the level around them and Rinata can present them clearly.

## Files And Ownership

Polina-owned implementation files:

- `scenes/actors/Player.tscn`
- `scripts/actors/player/Player.gd`
- `scripts/gameplay/GameRules.gd`
- `scripts/gameplay/ScoreService.gd`
- `scripts/gameplay/WaterRuleService.gd`
- `tests/gameplay/test_score_service.gd`
- `tests/gameplay/test_water_rule_service.gd`

Shared files Polina may edit only with the contract open:

- `scripts/autoload/GameState.gd`: shared runtime state; keep Rinata looped in.
- `INTEGRATION_CONTRACT.md`: update before changing signals, payloads, inputs, methods, or layers.

Do not edit for this slice without explicit handoff:

- `scenes/world/`, `scripts/world/`, terrain, boss placement, hazards, and pickup placement: Alina.
- `project.godot`, `scenes/main/`, `scripts/autoload/`, UI, audio, exports, and build scripts: Rinata.

## Core Rules

Score:

- Start score is `1.00`, not `0.00`.
- Target score is exactly `67.00`.
- `0.00` triggers failure immediately.
- Negative score is valid and should continue.
- Use fixed-point integer cents internally: `1.00 = 100`, `67.00 = 6700`.
- Display up to two decimals, but never use raw floating-point equality for victory/failure.

Movement:

- Side-view `CharacterBody2D`.
- Horizontal movement, gravity, falling, one jump, short hop, coyote time, and jump buffering.
- Temporary double jump exists only from the green up-arrow power-up for 5 seconds.
- Disable dash, roll, crouch, run modifier, wall jump, wall slide, wall latch, double jump by default,
  ground pound, and corner correction from the referenced controller pack.
- Preserve `DetectionArea`, `GameState.input_enabled`, movement/reset signals, collision contracts,
  and phase visuals.

Map/grid assumptions:

- Visible design chunk is `12 x 8` tiles.
- Full Level 1 route is `53` authored columns from the latest board transcription.
- Columns `1-18` are safe-zone/tutorial space. Boss 67 begins at column `19`.
- One tile is one cube.
- Player is `1 x 1` tile.
- Maximum intended terrain stack is 5 tiles high.
- Every required route must be reachable with the approved movement kit.
- After the boss starts, the route wraps on both horizontal edges. Walking left past column `1`
  appears near column `53`, and walking right past column `53` appears near column `1`.

Opening flow:

- A cutscene scene appears first. Story text is deferred.
- The player starts in a safe sand-and-sky tutorial area with no boss-route blocks, pickups,
  projectiles, power-ups, or boss pressure.
- Exactly one tutorial cube teaches walking, falling, and one-block jumping.
- After the player crosses into column `19`, the safe start closes behind the player.
- The safe-start closure must not read as a visible stone/block in the middle of the playfield.
- Boss 67 appears only after the player has demonstrated basic platforming.

## Land Phase

Land pickups:

- `+1`
- `+2`
- `+3`
- `+5`
- `+6`
- `+7`

Spawn density:

- 8 or 9 collectible score values per visible `12 x 8` chunk.
- Pickups may sit on floor/block tops or 2 tiles above a floor/block so the player must jump.
- High-value opportunities should include reachable high points at height `5`, or height `4` with a
  jump.

Boss land projectiles:

- `*0`
- `*0.5`
- `*0.8`

Rules:

- `*0` is rare because it causes immediate failure through score `0.00`.
- White boss digits collide with blocks and are destroyed.
- Boss/projectile difficulty should be readable before it becomes punishing.
- Boss digits should clearly spawn from Boss 67 and use readable labels for long operations such as
  `x1.15`.

## Distance Gates

Distance is counted in horizontal blocks from the start of the boss-run section.

- `0` blocks: Boss 67 appears.
- `18` blocks: purple projectiles become available.
- `28` blocks: first water event starts.

Purple projectile rules:

- Spawn less often than white projectiles.
- Pass through blocks.
- Are destroyed only by the floor/water boundary or an explicit projectile cleanup rule.
- Apply their score operation on player contact.

## Water Phase

Water lasts exactly 10 seconds.

First water:

- Starts when the player reaches 28 horizontal blocks from boss-run start.

Later water:

- May start after the player collects a land pickup whose value is divisible by 6 or 7.
- Use a cooldown so water cannot chain instantly.
- Do not trigger water from boss projectiles.

Water movement:

- Movement becomes smoother/slipperier.
- Jump tuning may feel floatier, but must remain controllable and testable.

Water rule variants:

| Variant | Boss Throws | Floor Pickups |
| --- | --- | --- |
| A | `*1.15`, `*1.2`, `*1.3` | `-10`, `-12`, `-8`, `-6` |
| B | `+3`, `+5`, `+6`, `+7` | `*0.5`, `*0.2`, `*0.3`, `*0` |
| C | `-5`, `-1`, `-2`, `-7`, `-10` | `*2`, `*6`, `*3`, `*1` |

Water complications:

- At most one complication per water event.
- Possible complication 1: reversed controls.
- Inverted gravity is contract-disabled for MVP until ceiling blocks and recovery are stable.
- Current MVP uses reversed controls for water complication visibility. Inverted gravity stays disabled
  until Alina adds a ceiling route and Polina verifies player recovery after water ends.

## Power-Ups

Power-ups are rare and should appear on high or risky routes.

- Star: slows Boss 67 and boss projectiles for 5 seconds.
- Green up arrow: grants temporary double jump for 5 seconds.

Power-ups must expire through timers and reset cleanly on restart.

## Required Core APIs

`ScoreService.gd` should provide pure, typed helpers:

- apply addition, subtraction, and multiplication operations to fixed-point score.
- parse operation definitions without UI strings controlling logic.
- detect exact target score.
- detect zero failure.
- preserve negative score.

`WaterRuleService.gd` should provide pure or mostly pure helpers:

- distance thresholds for boss/purple/water.
- land pickup pools.
- boss projectile pools by phase.
- water variant pools.
- water retrigger checks for values divisible by 6 or 7.

`Player.gd` should provide:

- side-view platformer movement.
- input disable behavior.
- reset behavior.
- phase/complication response hooks.
- temporary double-jump power-up support.
- no direct UI or audio calls.

## Signals And Dependencies

Polina consumes:

- input actions from `project.godot`.
- terrain and collision bodies from Alina.
- `GameState.input_enabled`.
- documented phase/complication state from `GameState`.

Polina provides:

- player movement and reset behavior.
- pure score and progression rules.
- stable constants for pickups, projectiles, thresholds, and target score.
- review for GameState score mutation.

Outcome signals should be emitted by `GameState`, not directly by Player:

- `score_changed(score_cents: int, display: String)`
- `score_operation_applied(operation: StringName, value_cents: int, source: StringName)`
- `distance_changed(blocks: int)`
- `boss_phase_changed(phase: GameRules.BossPhase)`
- `water_started(variant: GameRules.WaterVariant, complication: GameRules.WaterComplication, seconds: float)`
- `water_timer_changed(seconds_left: float)`
- `water_finished()`
- `powerup_started(kind: StringName, seconds: float)`
- `powerup_finished(kind: StringName)`
- `player_failed(reason: StringName)`
- `boss_67_defeated()`
- `level_completed(level_id: StringName)`
- `game_over(won: bool, reason: StringName, score_cents: int)`
- `restart_requested()`

## Implementation Order

1. Confirm docs and contract are accepted by all three owners.
2. Build or update a side-view isolated movement test room before converting Level 1.
3. Implement `ScoreService.gd` with tests.
4. Implement `WaterRuleService.gd` with tests.
5. Convert `Player.gd` movement in isolation.
6. Add score mutation through `GameState` with documented signals.
7. Integrate land pickups and boss projectiles through contract methods, not direct node coupling.
8. Add water timer and one water variant at a time.
9. Add power-up timers.
10. Verify restart from failure, victory, land, and water.
11. Run `tools\qa.cmd`.

## Test Checklist

Score math:

- `1.00 + 6 = 7.00`.
- `67.00` wins exactly.
- `67.01` does not win.
- `0.00` fails.
- Negative scores do not fail by themselves.
- `*0.5`, `*0.2`, `*0.3`, `*0.8`, `*1.15`, `*1.2`, and `*1.3` are deterministic.

Movement:

- Player walks, falls, lands, and jumps.
- Holding jump is higher than tapping jump.
- Coyote time works.
- Jump buffering works.
- Repeated airborne jumps do not happen unless the temporary double-jump power-up is active.
- Input disable clears or freezes motion according to contract.
- Restart restores normal gravity, controls, movement, and score.

Progression:

- Boss appears after the tutorial jump.
- Safe-start closure does not leave a visible center block.
- Walking left after the boss starts wraps the player to the far right of the authored route cleanly.
- Purple projectiles unlock at 18 blocks.
- First water starts at 28 blocks.
- Later water starts only after qualifying land pickups and cooldown.
- Water lasts 10 seconds.
- Victory triggers at exact 67.
- Failure triggers at 0.

## Teammate Handoff

To Alina:

- Build side-view terrain on the `53` authored columns / `12 x 8` readable chunk rule.
- Keep required jumps inside the approved movement ability.
- Use sand/blocks from the selected visual asset pack.
- White projectiles need block collision. Purple projectiles need pass-through behavior.
- Place land pickups using the Polina pool and density rules.

To Rinata:

- Add `jump` input on `Space`, with optional `Up`/`W`.
- Keep `action` on `Enter` or `E`.
- HUD should display score, collected recent operations, water timer, active water rule, and power-up
  timers through signals/state snapshots.
- Restart must fully reset score, water, power-ups, boss phase, projectile cleanup, and input.
- Add attribution for Noasey's controller pack if movement concepts are adapted.

## Scope Warning

Do not add health, weapons, enemies beyond Boss 67, shops, multiple levels, procedural maps, long
cutscenes, or extra boss patterns until this Level 1 path is playable and `tools\qa.cmd` passes.

## Integration Notes

Dependencies:

- Alina: side-view test room, terrain, pickup/projectile scenes, boss placement.
- Rinata: input map, `GameState`, main scene flow, UI/audio, restart, QA/export health.

Assets:

- Visual pack is art only, not reusable gameplay logic.
- Use player, tileset, background, orb/pickup, door/save, and effect assets selectively.
- Star means slow effect. Green up arrow means temporary double jump.

Shortest manual test:

```text
Main.tscn -> cutscene placeholder -> safe jump tutorial -> Boss 67 -> collect/avoid values ->
water at 28 blocks -> reach exact 67 -> restart -> fail by 0 -> restart
```
