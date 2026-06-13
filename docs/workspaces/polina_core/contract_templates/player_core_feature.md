# Level 1 Boss 67 Player/Core Contract Notes

Feature: Boss 67 platformer score-fight core systems

Owner: Polina

Owned scenes/scripts:

- `scenes/actors/Player.tscn`
- `scripts/actors/player/Player.gd`
- `scripts/gameplay/GameRules.gd`
- `scripts/gameplay/ScoreService.gd`
- `scripts/gameplay/WaterRuleService.gd`
- `tests/gameplay/test_score_service.gd`
- `tests/gameplay/test_water_rule_service.gd`

Inputs:

- `move_left`
- `move_right`
- `move_up`
- `move_down`
- `jump`
- `action`
- `pause`
- `restart`

Keyboard defaults:

- `move_left`: Left, A
- `move_right`: Right, D
- `move_up`: Up, W
- `move_down`: Down, S
- `jump`: Space
- `action`: Enter, E
- `pause`: Escape
- `restart`: R

Player emits directly:

- local movement/debug signals only if useful for tutorial or tests.
- no HUD text, audio playback, final score display, or scene changes.

Player consumes:

- input actions.
- `GameState.input_enabled`.
- current water/complication state exposed by `GameState`.
- world collisions from Alina.

Core gameplay provides:

- fixed-point score math.
- exact `67.00` victory detection.
- exact `0.00` failure detection.
- negative score support.
- distance thresholds for boss/purple/water gates.
- land and water operation pools.
- water retrigger logic for land values divisible by 6 or 7.

Assets:

- Placeholder sprite or shape is allowed during movement tests.
- Final visuals should use selected pack assets, but the pack supplies visuals only.
- Star power-up means 5-second slow.
- Green up arrow power-up means 5-second temporary double jump.

Reset behavior:

- Score returns to `1.00`.
- Position returns to the correct spawn/checkpoint.
- Velocity clears.
- Input is restored unless disabled by current scene flow.
- Gravity returns to normal.
- Controls return to normal.
- Water timer stops.
- Active water variant/complication clears.
- Temporary power-ups expire.
- Movement listeners/timers do not duplicate.

Isolation test:

1. Run the movement sandbox or `Player.tscn`.
2. Walk left and right.
3. Fall from a ledge.
4. Land on a floor/platform.
5. Jump once.
6. Confirm tap jump is shorter than held jump.
7. Confirm coyote time.
8. Confirm jump buffering.
9. Confirm no repeated airborne jump without active double-jump power-up.
10. Activate temporary double jump and confirm it expires after 5 seconds.
11. Simulate reversed controls and restore normal controls.
12. Simulate inverted gravity and restore normal gravity.
13. Reset and confirm movement state is clean.

Score test:

1. Start score at `1.00`.
2. Apply land pickups: `+1`, `+2`, `+3`, `+5`, `+6`, `+7`.
3. Apply land boss multipliers: `*0`, `*0.5`, `*0.8`.
4. Apply all three water variants.
5. Confirm exact `67.00` wins.
6. Confirm `67.01` and `66.99` do not win.
7. Confirm exact `0.00` fails.
8. Confirm negative scores continue.

Main-scene test:

1. Launch from `Main.tscn`.
2. See the placeholder cutscene first.
3. Enter the safe tutorial area.
4. Walk, fall, and jump one block.
5. Confirm safe start closes behind the player.
6. Confirm Boss 67 appears.
7. Reach 18 blocks and confirm purple projectiles are enabled.
8. Reach 28 blocks and confirm first water starts.
9. Confirm water lasts 10 seconds.
10. Reach exact `67.00` and confirm victory.
11. Trigger score `0.00` and confirm failure.
12. Restart without relaunching the app.
13. Run `tools\qa.cmd`.

Fallback/cut:

- Keep movement, score math, exact 67 victory, zero failure, one land loop, one water variant, and
  restart.
- Cut rare power-ups, water complications, purple projectiles, extra water variants, and cinematic
  story first if the build is unstable.
