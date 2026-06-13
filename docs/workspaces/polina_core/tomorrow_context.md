# Tomorrow Context For Polina

Role: Polina, Core Systems.

Current slice: Level 1 Boss 67 platformer score fight for `Slay Diver: Rise of 67`.

Source of truth:

- `ARCHITECTURE.md`
- `INTEGRATION_CONTRACT.md`
- `docs/SCOPE.md`
- `docs/PLATFORMER_CONTROLLER.md`
- `docs/workspaces/polina_core/LEVEL_01_CORE_PLAN.md`

Owned areas:

- `scenes/actors/Player.tscn`
- `scripts/actors/player/`
- `scripts/gameplay/`
- player movement and reset
- score math and exact-67 victory
- zero-score failure
- land/water rule state
- water trigger rules
- power-up timers and core state hooks
- Polina review of score mutation in `GameState`

Current logic:

- The old Guardian10 equation room is replaced.
- Level starts with a placeholder cutscene, then a safe platformer tutorial.
- Level 1 is a 52-cell authored route viewed through a `12 x 8` camera window.
- Only the right edge loops. Walking left after the safe tutorial closes must clamp or block the player.
- Player starts at score `1.00`.
- Goal is exact score `67.00`.
- Score can be negative.
- Score `0.00` means fail/play again.
- Boss 67 appears after the first safe jump tutorial block.
- Safe-start closure must not leave a visible center stone/block.
- First purple projectiles unlock at 18 horizontal blocks.
- First water starts at 28 horizontal blocks.
- Water lasts 10 seconds.
- Later water can start after collecting a land value divisible by 6 or 7.

Reserved inputs:

- `move_left`
- `move_right`
- `move_up`
- `move_down`
- `jump`
- `action`
- `pause`
- `restart`

Movement conversion:

- Adapt only walking, gravity, falling, one jump, short hop, coyote time, jump buffering, and
  floor/platform collision from the Noasey controller reference.
- Do not paste the controller unchanged.
- Do not enable dash, roll, crouch, run modifier, wall mechanics, permanent double jump, ground pound,
  or corner correction.
- Temporary double jump is only a 5-second green up-arrow power-up.

Core signals expected from `GameState`:

- `run_started()`
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
- `level_completed(level_id: StringName)`
- `game_over(won: bool, reason: StringName, score_cents: int)`
- `restart_requested()`

First implementation target after docs are accepted:

```text
ScoreService tests -> platformer movement sandbox -> score mutation through GameState ->
safe tutorial -> Boss 67 land loop -> first water event -> exact 67 victory -> zero failure -> restart
```

Preferred prompt:

```text
I am Polina. Use $jam-architecture, $jam-implement, and $jam-qa. Implement only the Polina-owned
Level 1 Boss 67 core slice: fixed-point ScoreService, WaterRuleService, side-view Player movement
conversion, score failure/victory hooks, and restart-safe core state. Stay inside
scenes/actors/Player.tscn, scripts/actors/player/, scripts/gameplay/, and tests/gameplay/ unless the
contract requires a shared markdown or GameState edit.
```
