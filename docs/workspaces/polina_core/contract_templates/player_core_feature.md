# Level 1 Easy Player/Core Contract Notes

Feature: Level 1 Easy Core Systems

Owner: Polina

Owned scenes/scripts:

- `scenes/actors/Player.tscn`
- `scripts/actors/player/Player.gd`
- `scripts/gameplay/GameRules.gd`
- `scripts/gameplay/EquationService.gd`
- `tests/gameplay/test_equation_service.gd`

Inputs:

- `move_left`
- `move_right`
- `move_up`
- `move_down`
- `action` remains reserved as an altar fallback, but MVP should not require it.

Emits directly:

- Local player movement signals only if needed for tutorial/debug.
- No UI text, audio, score, health, death, or result signals from Player.

Consumes:

- Player input actions.
- `GameEvents.phase_changed(phase)` for water visual response.
- `GameState.input_enabled` or an equivalent integration method when Rinata exposes it.
- World collisions from Alina's authored boundaries.

Assets:

- Placeholder sprite or shape is allowed.
- Expected final names:
  - `assets/sprites/player_idle.png`
  - `assets/sprites/player_water.png`

Reset behavior:

- Position returns to spawn/start position.
- Velocity clears to zero.
- Input is restored unless `GameState.input_enabled` says otherwise.
- Water/land visual matches the current phase.
- Transient listeners do not duplicate.

Isolation test:

1. Run `Player.tscn` or a temporary sandbox scene.
2. Move in four directions.
3. Confirm diagonal movement is not faster than cardinal movement.
4. Confirm collision boundaries stop the player.
5. Emit or simulate `phase_changed(WATER)` and confirm only visual state changes.
6. Reset and confirm the player can move again.
7. Run EquationService checks:
   - `4, 6, ADD, 10` succeeds.
   - `6, 4, ADD, 10` succeeds.
   - `14, 4, SUBTRACT, 10` succeeds.
   - `4, 14, SUBTRACT, 10` fails.
   - missing or extra operands fail without crash.

Main-scene test:

1. Launch from `Main.tscn`.
2. Start a run.
3. Move and collect operands.
4. Submit `4 + 6 = 10`.
5. Complete the tide handoff.
6. Submit `14 - 4 = 10`.
7. Restart without relaunch.

Fallback/cut:

- Keep movement, `GameRules`, `EquationService`, and exact Level 1 arithmetic.
- Cut health, score, timer, action cooldowns, random pairs, and extra operations first.
