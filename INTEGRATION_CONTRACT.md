# Integration Contract

This contract is locked for the Level 1 Easy vertical slice. Update it before changing a shared name,
payload, input, collision layer, autoload, or scene responsibility.

## Core Scenes

| Scene | Owner | Responsibility |
| --- | --- | --- |
| `scenes/main/Main.tscn` | Rinata | composition root and run lifecycle |
| `scenes/world/Level_01.tscn` | Alina | authored Level 1 arena and phase presentation |
| `scenes/actors/Player.tscn` | Polina | player movement and phase visual response |
| `scenes/actors/numbers/Operand.tscn` | Alina | collectible integer operand |
| `scenes/actors/enemies/Guardian10.tscn` | Alina | shield and defeat presentation |
| `scenes/world/interactions/EquationAltar.tscn` | Alina | equation submission trigger |
| `scenes/world/interactions/ResetShell.tscn` | Alina | clear current operands |
| `scenes/ui/HUD.tscn` | Rinata | target, operation, operands, rule, shield display |
| `scenes/ui/TutorialOverlay.tscn` | Rinata | Level 1 onboarding |
| `scenes/ui/RuleChangeOverlay.tscn` | Rinata | tide rule-change presentation |
| `scenes/ui/ResultScreen.tscn` | Rinata | completion and restart |

## Autoloads

| Name | Path | Owner | Contract |
| --- | --- | --- | --- |
| `GameEvents` | `scripts/autoload/GameEvents.gd` | Rinata | global signals only |
| `GameState` | `scripts/autoload/GameState.gd` | Rinata with Polina review | resettable Level 1 state and equation API |
| `AudioBus` | `scripts/autoload/AudioBus.gd` | Rinata | stable sound-ID playback |
| `SceneLoader` | `scripts/autoload/SceneLoader.gd` | Rinata | start and fresh restart |

No additional autoload is allowed for Level 1.

## Shared Code

| Type | Path | Owner | Contract |
| --- | --- | --- | --- |
| `GameRules` | `scripts/gameplay/GameRules.gd` | Polina | enums, constants, Level 1 operands, sound IDs |
| `EquationService` | `scripts/gameplay/EquationService.gd` | Polina | pure addition/subtraction validation |
| `Level01Controller` | `scripts/world/Level01Controller.gd` | Alina | LAND to TRANSITION to WATER to COMPLETE sequence |

## Signals

| Signal | Payload | Producer | Consumers |
| --- | --- | --- | --- |
| `run_started` | `level_id: StringName` | Main | level, HUD, tutorial, audio |
| `phase_changed` | `phase: GameRules.Phase` | GameState | LevelController, HUD, Player |
| `operand_collected` | `value: int, slot: int` | GameState | HUD, world feedback, audio |
| `operands_cleared` | none | GameState | HUD, LevelController |
| `equation_submitted` | `correct: bool` | GameState | LevelController, HUD, audio |
| `equation_changed` | `snapshot: Dictionary` | GameState | HUD |
| `shield_changed` | `remaining: int` | GameState | Guardian10, HUD, audio |
| `tide_started` | none | LevelController | world visuals, overlay, audio |
| `tide_finished` | none | LevelController | HUD, tutorial, Player |
| `level_completed` | `level_id: StringName` | GameState | Main, HUD, audio |
| `restart_requested` | none | ResultScreen/input | SceneLoader |

The repository QA script also reserves these template names for later levels:

| Reserved signal | Level 1 Easy rule |
| --- | --- |
| `player_died` | declare only if required by the QA skeleton; do not emit |
| `health_changed` | declare only if required by the QA skeleton; no health system |
| `score_changed` | declare only if required by the QA skeleton; no score system |
| `game_over` | declare only if required by the QA skeleton; completion uses `level_completed` |

Reserved signals must not create unused gameplay systems in Level 1.

## GameState Methods

```gdscript
func reset_level_01() -> void
func try_collect_operand(value: int) -> bool
func clear_operands() -> void
func submit_equation() -> bool
func begin_tide_transition() -> void
func enter_water_phase() -> void
func complete_level() -> void
func get_equation_snapshot() -> Dictionary
```

No world or UI script may write GameState fields directly.

## Input Actions

| Action | Default keys | Purpose |
| --- | --- | --- |
| `move_left` | Left, A | move left |
| `move_right` | Right, D | move right |
| `move_up` | Up, W | move up |
| `move_down` | Down, S | move down |
| `action` | Space, Enter | reserved altar fallback |
| `restart` | R | restart after completion |
| `pause` | Escape | pause |

## Collision Layers

| Layer | Purpose |
| --- | --- |
| `1` | player body |
| `2` | operands |
| `3` | altars and ResetShell |
| `4` | solid world and CoralGate |

## Level 1 Authored Data

| Phase | Operation | Correct operands | Distractors | Target |
| --- | --- | --- | --- | --- |
| Land | addition | `4`, `6` | `2`, `7` | `10` |
| Water | subtraction in collection order | `14`, `4` | `8`, `3` | `10` |

## Stable Assets

```text
assets/sprites/player_idle.png
assets/sprites/player_water.png
assets/sprites/operand.png
assets/sprites/guardian_10.png
assets/sprites/guardian_10_hurt.png
assets/sprites/guardian_10_defeated.png
assets/sprites/level_01_sand.png
assets/sprites/level_01_water.png
assets/audio/sfx_operand_collect.wav
assets/audio/sfx_equation_wrong.wav
assets/audio/sfx_shield_break.wav
assets/audio/sfx_tide.wav
assets/audio/sfx_level_win.wav
```

Placeholders may replace any asset while preserving its path or updating all consumers in one change.
UI panels and placeholders should use Godot `Control`, `Label`, `ColorRect`, and `StyleBoxFlat`
resources rather than adding image dependencies. Visual implementation must follow `docs/UI_STYLE.md`.

### Third-Party Asset Subset

Only these optional asset roles are approved for the current pass:

```text
assets/third_party/o_lobster/level_01_backdrop.png
assets/third_party/o_lobster/level_01_prop_01.png
assets/third_party/o_lobster/level_01_prop_02.png
assets/third_party/o_lobster/level_01_prop_03.png
THIRD_PARTY_NOTICES.md
```

The prop files are optional; unused slots should not be created. Rinata owns selection, import
settings, filenames, attribution, and license review. Alina owns placement inside
`Level_01.tscn`.

No gameplay code may depend on these files. Missing optional art falls back to the existing
`SandVisual` and `WaterVisual` polygons. No new signal, autoload, input action, collision layer,
TileMap, or node-path contract is introduced.

The o_lobster source is CC BY 4.0 and must be credited. CraftPix files are not approved for repository
commit until their source-file redistribution terms are confirmed for this project.

## Reset Contract

- Wrong Easy-mode submission clears operands and restores active operands without reloading the level.
- Full restart removes the old Level 1 instance, resets GameState, creates a fresh instance, resets UI,
  emits `run_started`, and enables input.
- Transition can happen only once per run.
- Old nodes and signal connections must not survive a full restart.

## Integration Gate

Level 1 is integrated only when:

- `4 + 6 = 10` triggers the tide;
- `14 - 4 = 10` defeats Guardian10;
- wrong answers recover immediately;
- result-screen restart returns to untouched dry state;
- `tools/qa.cmd` passes;
- the twelve-step manual test in `ARCHITECTURE.md` passes.
