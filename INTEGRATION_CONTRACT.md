# Integration Contract

This contract replaces the old top-down arithmetic-room contract. It is locked for the Boss 67
platformer vertical slice. Update it before changing a shared name, payload, input, collision layer,
autoload, scene responsibility, or score rule.

## Core Scenes

| Scene | Owner | Responsibility |
| --- | --- | --- |
| `scenes/main/Main.tscn` | Rinata | composition root, intro flow, restart |
| `scenes/world/Boss67Level.tscn` | Alina | side-view platformer level and authored chunks |
| `scenes/world/PlatformerTestRoom.tscn` | Alina | isolated movement validation room |
| `scenes/actors/Player.tscn` | Polina | platformer player, detection area, phase visual response |
| `scenes/actors/Boss67.tscn` | Alina | Boss 67 presentation and projectile spawn anchors |
| `scenes/actors/numbers/ScorePickup.tscn` | Alina | collectible operation/value item |
| `scenes/actors/numbers/BossProjectile.tscn` | Alina | white and purple boss number projectiles |
| `scenes/actors/powerups/PowerUp.tscn` | Alina | star slow and green double-jump pickups |
| `scenes/ui/HUD.tscn` | Rinata | score, target, rule, water timer, power-up indicators |
| `scenes/ui/CutsceneIntro.tscn` | Rinata | placeholder intro scene |
| `scenes/ui/WaterRuleOverlay.tscn` | Rinata | water rule and complication announcement |
| `scenes/ui/ResultScreen.tscn` | Rinata | victory/failure and restart |

Old scene names such as `Level_01.tscn`, `Level_01_Water.tscn`, `Guardian10.tscn`, `EquationAltar.tscn`,
and `ResetShell.tscn` are legacy and should not be extended for the new design.

## Autoloads

| Name | Path | Owner | Contract |
| --- | --- | --- | --- |
| `GameEvents` | `scripts/autoload/GameEvents.gd` | Rinata | global signal hub only |
| `GameState` | `scripts/autoload/GameState.gd` | Rinata with Polina review | score, run phase, water state, win/fail |
| `AudioBus` | `scripts/autoload/AudioBus.gd` | Rinata | stable sound-ID playback |
| `SceneLoader` | `scripts/autoload/SceneLoader.gd` | Rinata | intro, start run, restart |

No additional autoload is allowed for this slice without agreement from all three members.

## Shared Code

| Type | Path | Owner | Contract |
| --- | --- | --- | --- |
| `GameRules` | `scripts/gameplay/GameRules.gd` | Polina | constants, score operations, water variants, distances |
| `ScoreService` | `scripts/gameplay/ScoreService.gd` | Polina | pure fixed-point score operations and win/fail checks |
| `WaterRuleService` | `scripts/gameplay/WaterRuleService.gd` | Polina | water variant and complication selection |
| `Boss67LevelController` | `scripts/world/Boss67LevelController.gd` | Alina | distance milestones, chunk flow, spawn requests |
| `PlatformerPlayer` | `scripts/actors/player/Player.gd` | Polina | adapted movement controller in existing Player file |

## Inputs

| Action | Default keys | Purpose |
| --- | --- | --- |
| `move_left` | Left, A | walk left |
| `move_right` | Right, D | walk right |
| `jump` | Space, Up, W | jump; hold for higher jump |
| `action` | Enter, E | skip cutscene/overlay or confirm where needed |
| `restart` | R | restart after outcome |
| `pause` | Escape | pause |

`Space` is no longer `action`; it is `jump`.

## Collision Layers

| Layer | Purpose |
| --- | --- |
| `1` | player body |
| `2` | solid terrain and one-way platforms |
| `3` | score pickups and power-ups |
| `4` | boss projectiles |
| `5` | boss body/presentation |
| `6` | water boundaries or water-only collision helpers |

White projectiles collide with terrain. Purple projectiles ignore terrain and are destroyed only by the
floor/water boundary or expiry.

## Run State

Required `GameState` fields:

```gdscript
var score_cents: int
var phase: GameRules.RunPhase
var distance_blocks: int
var water_variant: GameRules.WaterVariant
var water_complication: GameRules.WaterComplication
var water_seconds_left: float
var input_enabled: bool
var outcome_locked: bool
```

Score is stored as fixed-point cents:

```text
1.00 -> 100
67.00 -> 6700
0.00 -> fail
```

Required methods:

```gdscript
func reset_boss_67_run() -> void
func apply_score_operation(operation: StringName, value_cents: int, source: StringName) -> void
func set_distance_blocks(value: int) -> void
func begin_water_event(variant: GameRules.WaterVariant, complication: GameRules.WaterComplication) -> void
func finish_water_event() -> void
func activate_powerup(kind: StringName, seconds: float) -> void
func fail_run(reason: StringName) -> void
func complete_run() -> void
func get_run_snapshot() -> Dictionary
```

No world or UI script may write these fields directly.

## Core Signals

All cross-owner signals live in `GameEvents.gd`.

| Signal | Payload | Producer | Consumers |
| --- | --- | --- | --- |
| `run_started` | none | Main / SceneLoader | HUD, level, audio |
| `cutscene_finished` | none | CutsceneIntro | SceneLoader |
| `score_changed` | `score_cents: int, display: String` | GameState | HUD, audio |
| `score_operation_applied` | `operation: StringName, value_cents: int, source: StringName` | GameState | HUD feedback, audio |
| `distance_changed` | `blocks: int` | LevelController | HUD, boss |
| `boss_phase_changed` | `phase: GameRules.BossPhase` | LevelController | Boss67, HUD, audio |
| `water_started` | `variant: GameRules.WaterVariant, complication: GameRules.WaterComplication, seconds: float` | GameState | HUD, player, world, audio |
| `water_timer_changed` | `seconds_left: float` | GameState | HUD |
| `water_finished` | none | GameState | HUD, player, world |
| `powerup_started` | `kind: StringName, seconds: float` | GameState | player, boss, HUD, audio |
| `powerup_finished` | `kind: StringName` | GameState | player, boss, HUD |
| `health_changed` | `current: int, maximum: int` | GameState | HUD compatibility |
| `player_failed` | `reason: StringName` | GameState | ResultScreen, audio |
| `player_died` | `reason: StringName` | GameState | legacy/QA compatibility |
| `boss_67_defeated` | none | GameState | ResultScreen, audio |
| `level_completed` | `level_id: StringName` | GameState | ResultScreen, audio, QA |
| `game_over` | `won: bool, reason: StringName, score_cents: int` | GameState | ResultScreen, audio, QA |
| `restart_requested` | none | ResultScreen/input | SceneLoader |

Signal payloads are contracts. Do not pass scene nodes or mutable gameplay objects.

Compatibility notes:

- Boss 67 does not use a traditional health bar in the MVP. `health_changed` is retained as a
  compatibility signal for existing QA/HUD expectations and should mirror run survivability, for
  example `1/1` during play and `0/1` after fail.
- `player_died` is an alias-style failure signal for older consumers; new logic should prefer
  `player_failed`.
- Exact `67.00` should emit both `boss_67_defeated` and `level_completed("boss_67_level_01")`.
- Any terminal outcome should emit `game_over` after the specific win/fail signal.

## Numeric Contract

Start:

```text
score = 1.00
target = 67.00
```

Win:

```text
score == 67.00
```

Fail:

```text
score == 0.00
```

Score may be negative. Score may exceed `67.00`. The player continues until exact `67.00` or `0.00`.

Land pickups:

```text
+1, +2, +3, +5, +6, +7
```

Land boss projectiles:

```text
*0, *0.5, *0.8
```

Water variants:

| Variant | Boss projectiles | Floor pickups |
| --- | --- | --- |
| `WATER_A` | `*1.15`, `*1.2`, `*1.3` | `-10`, `-12`, `-8`, `-6` |
| `WATER_B` | `+3`, `+5`, `+6`, `+7` | `*0.5`, `*0.2`, `*0.3`, `*0` |
| `WATER_C` | `-5`, `-1`, `-2`, `-7`, `-10` | `*2`, `*6`, `*3`, `*1` |

All operations round to the nearest cent after application.

## Distance Contract

Progress is measured in horizontal blocks from the boss-run start, after the safe tutorial closes.  
The post-tutorial terrain is a 52-block loop (2496 px). When the player passes the right edge, they
wrap back to the left — the camera smoothing makes the transition seamless. Cumulative distance
(`_total_blocks`) never resets and drives permanent boss-phase milestones.

| Distance | Event |
| --- | --- |
| `0` | Boss 67 appears. |
| `18` | Purple projectiles become available. |

## Water Contract

Water events are triggered by **score**, not distance.  
After every score change, if `score_cents / 100` is divisible by `6` or `7`, a water event begins
(`WATER_A`, lasts 10 s). Water can re-trigger on each new divisor milestone.

## Power-Up Contract

| Kind | Visual | Effect | Duration |
| --- | --- | --- | --- |
| `slow` | star | Boss and projectiles slow down. | `5` seconds |
| `double_jump` | green up arrow | Player gets one temporary extra jump. | `5` seconds |

Power-ups are rare and spawn at high points.

## Stable Asset Roles

Exact filenames may change after import, but these roles are stable:

```text
player idle/run/jump/fall/hit/death strips
player jump dust strips
sand block tileset
pink sky / land background
solid blue water overlay
score pickup orb
boss projectile digit visual
Boss67 visual
star slow powerup
green up-arrow double-jump powerup
result and HUD UI controls
```

The platformer asset pack is visual-only. It does not provide movement, score, water, boss, or restart
logic.

## Integration Gate

The new slice is integrated only when:

- cutscene can be skipped;
- player walks, falls, lands, and jumps in an isolated test room;
- safe start teaches one-block jump;
- Boss 67 appears after the safe start closes;
- land pickups change score;
- white projectiles are blocked by terrain;
- purple projectiles start after `18` blocks and pass through blocks;
- water starts when `score_cents / 100` is divisible by `6` or `7` and lasts `10` seconds;
- one water variant applies correctly;
- score can become negative;
- score `0.00` fails;
- score `67.00` wins;
- restart clears score, projectiles, water, power-ups, and stale listeners;
- `tools/qa.cmd` passes.
