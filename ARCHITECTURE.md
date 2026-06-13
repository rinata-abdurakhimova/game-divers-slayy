# Level 1 Easy Architecture

## Goal

Build one complete vertical slice of `Slay Diver: Rise of 67`:

1. Start from `Main.tscn`.
2. Learn arrow-key movement.
3. Solve `4 + 6 = 10` on land.
4. Watch the pink tide change the rule.
5. Solve `14 - 4 = 10` underwater.
6. Defeat Guardian 10.
7. Reach the result screen and restart reliably.

Only Level 1 Easy is in scope. Do not start Level 2, Hard mode, or Boss 67 until this path passes
`tools/qa.cmd` and the manual test at the end of this document.

## Design Reference

Use the following Celeste principles, not its platforming mechanics:

- simple controls with immediate response;
- short, hand-authored challenges;
- every failure clearly teaches what was wrong;
- fast recovery without replaying unnecessary content;
- strong visual and audio feedback for important state changes.

Our Level 1 is one compact top-down room rather than a platformer. Movement uses arrows only. Arithmetic
choices replace precision jumps.

The provided visual screenshots are mood references only. The binding simplification rules, HUD tree,
palette, tide presentation, responsive layout, and asset budget are defined in `docs/UI_STYLE.md`.
Nobody should reproduce the screenshots' dense backgrounds, lighting, parallax, weather, or large
tile-set requirements for Level 1.

## Ownership

| Role | Member | Owns for Level 1 |
| --- | --- | --- |
| Core Systems | Polina | player, equation state, arithmetic validation, phase state |
| World and Content | Alina | Level 1 layout, operands, Guardian 10, gates, tide-ready world state |
| Experience and Integration | Rinata | Godot project, Main, autoloads, HUD, tutorial, transition, audio, result and restart |

Each member edits only the paths listed in their section. Changes to shared constants, signals, scene
names, or input names require an `INTEGRATION_CONTRACT.md` update before code changes.

## Runtime Scene Tree

```text
Main (Node)
|- LevelContainer (Node)
|  `- Level01 (Node2D)
|     |- Background (Node2D)
|     |  |- SandVisual
|     |  `- WaterVisual
|     |- Navigation (Node2D)
|     |  |- PlayerSpawn (Marker2D)
|     |  |- LandOperandSpawns (Node2D)
|     |  |- WaterOperandSpawns (Node2D)
|     |  |- LandAltarSpawn (Marker2D)
|     |  `- WaterAltarSpawn (Marker2D)
|     |- Actors (Node2D)
|     |  |- Player
|     |  |- Guardian10
|     |  `- ActiveOperands
|     |- Interactions (Node2D)
|     |  |- LandAltar
|     |  |- WaterAltar
|     |  |- ResetShell
|     |  `- CoralGate
|     `- LevelController
|- UI (CanvasLayer)
|  |- HUD
|  |- TutorialOverlay
|  |- RuleChangeOverlay
|  `- ResultScreen
`- Audio (Node)
```

`Main.tscn` is the only authoritative end-to-end entry point. `Player.tscn`, `Operand.tscn`,
`Guardian10.tscn`, `HUD.tscn`, and `Level_01.tscn` must also run in isolation with safe placeholder
defaults.

## Runtime Responsibilities

### Main

- Instantiates Level 1 and UI.
- Starts a new run through `GameState.reset_level_01()`.
- Shows the result screen after `level_completed`.
- Reloads Level 1 after `restart_requested`.
- Does not calculate equations or access child nodes inside Level 1.

### LevelController

- Owns the authored sequence `LAND -> TRANSITION -> WATER -> COMPLETE`.
- Spawns the correct operand set for the active phase.
- Enables the correct altar and route.
- Requests phase changes from `GameState`.
- Does not update HUD labels or play audio directly.

### GameState

- Holds the current Level 1 run snapshot.
- Owns collected operand slots and validates submissions.
- Exposes read-only getters and explicit mutation methods.
- Emits state changes through `GameEvents`.
- Does not own scene nodes, animation, audio files, or spawn positions.

### GameEvents

- Contains global signals only.
- Does not store state or implement gameplay.

### SceneLoader

- Starts Level 1 and reloads it on restart.
- Does not decide whether the player won.

### AudioBus

- Maps stable sound IDs to streams and plays them.
- Gameplay producers request sound IDs; they never load audio files.

## Shared Types And Constants

Create `scripts/gameplay/GameRules.gd` owned by Polina. It is a non-autoload reference containing the
shared enums and immutable Level 1 values.

```gdscript
class_name GameRules
extends RefCounted

enum Phase {
    LAND,
    TRANSITION,
    WATER,
    COMPLETE,
}

enum Operation {
    ADD,
    SUBTRACT,
}

const LEVEL_01_ID: StringName = &"level_01"
const LEVEL_01_TARGET: int = 10
const MAX_OPERAND_SLOTS: int = 2

const LAND_OPERATION: Operation = Operation.ADD
const LAND_CORRECT_OPERANDS: Array[int] = [4, 6]
const LAND_DISTRACTORS: Array[int] = [2, 7]

const WATER_OPERATION: Operation = Operation.SUBTRACT
const WATER_CORRECT_OPERANDS: Array[int] = [14, 4]
const WATER_DISTRACTORS: Array[int] = [8, 3]

const PLAYER_SPEED: float = 220.0
const TIDE_TRANSITION_SECONDS: float = 2.0
const HINT_DELAY_SECONDS: float = 8.0

const SFX_OPERAND_COLLECT: StringName = &"operand_collect"
const SFX_EQUATION_WRONG: StringName = &"equation_wrong"
const SFX_SHIELD_BREAK: StringName = &"shield_break"
const SFX_TIDE: StringName = &"tide"
const SFX_LEVEL_WIN: StringName = &"level_win"
```

Rules:

- No member duplicates these values in another script.
- Level layout positions remain exported values on Alina's scenes, not constants here.
- UI wording remains in Rinata's UI scripts/resources, not constants here.
- If tuning `PLAYER_SPEED` in the inspector is useful, Player may expose it with the constant as its
  default.
- Only exact integer arithmetic is allowed. Level 1 has no negative numbers, fractions, random pairs,
  timer, oxygen, health loss, or procedural generation.

## GameState Contract

Create `scripts/autoload/GameState.gd`, owned by Rinata. Polina supplies and reviews the arithmetic
behavior because it is Core Systems logic.

Required state:

```gdscript
var level_id: StringName
var phase: GameRules.Phase
var target: int
var operation: GameRules.Operation
var operands: Array[int]
var shield_segments: int
var input_enabled: bool
```

Required public methods:

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

Validation:

- Addition accepts either operand order.
- Subtraction preserves collection order: first collected minus second collected.
- Submission requires exactly two operands.
- Correct land submission leaves the phase change to `LevelController`.
- Correct water submission completes the level.
- Wrong submission clears both slots in Easy mode.
- Calls made during `TRANSITION` or `COMPLETE` are ignored.

`get_equation_snapshot()` returns:

```gdscript
{
    "target": int,
    "operation": GameRules.Operation,
    "operands": Array[int],
    "phase": GameRules.Phase,
}
```

Consumers must not mutate returned arrays.

## Signal Contract

All cross-owner signals live in `GameEvents.gd`.

| Signal | Payload | Producer | Consumers |
| --- | --- | --- | --- |
| `run_started` | `level_id: StringName` | Main | level, HUD, tutorial, audio |
| `phase_changed` | `phase: GameRules.Phase` | GameState | LevelController, HUD, player visuals |
| `operand_collected` | `value: int, slot: int` | GameState | HUD, world feedback, audio |
| `operands_cleared` | none | GameState | HUD, operand respawn logic |
| `equation_submitted` | `correct: bool` | GameState | LevelController, HUD, audio |
| `equation_changed` | `snapshot: Dictionary` | GameState | HUD |
| `shield_changed` | `remaining: int` | GameState | Guardian10, HUD, audio |
| `tide_started` | none | LevelController | world visuals, overlay, audio |
| `tide_finished` | none | LevelController | HUD, tutorial, player |
| `level_completed` | `level_id: StringName` | GameState | Main, HUD, audio |
| `restart_requested` | none | ResultScreen/input | SceneLoader |

Signal payloads are contracts. Do not add UI nodes, scene references, or mutable gameplay objects to a
payload.

## Input Contract

Rinata defines these actions in `project.godot`:

| Action | Default keys | Owner consumer |
| --- | --- | --- |
| `move_left` | Left arrow, A | Player |
| `move_right` | Right arrow, D | Player |
| `move_up` | Up arrow, W | Player |
| `move_down` | Down arrow, S | Player |
| `action` | Space, Enter | altar interaction if automatic overlap proves unclear |
| `restart` | R | ResultScreen/Main |
| `pause` | Escape | Main |

The MVP should use automatic operand collection and altar submission on overlap. Keep `action`
reserved as a fallback; do not require it unless playtesting shows accidental submissions.

## Polina: Core Systems Instructions

Owned files:

```text
scenes/actors/Player.tscn
scripts/actors/player/Player.gd
scripts/gameplay/GameRules.gd
scripts/gameplay/EquationService.gd
tests/gameplay/test_equation_service.gd
```

Tasks:

1. Create a `CharacterBody2D` player with typed four-direction movement.
2. Normalize diagonal input so diagonal movement is not faster.
3. Clamp the player to the authored arena using collision boundaries, not screen-size assumptions.
4. Disable movement while `GameState.input_enabled` is false.
5. Change only the player's visual child when entering water; movement logic stays identical.
6. Implement `EquationService` as pure typed functions for addition and subtraction validation.
7. Ensure collection order matters only for subtraction.
8. Provide safe behavior for missing visuals or collision nodes so placeholder tests still run.

Polina emits no UI text and loads no audio.

Isolation test:

- Player moves in four directions and cannot leave a test boundary.
- `4, 6, ADD, 10` succeeds.
- `6, 4, ADD, 10` succeeds.
- `14, 4, SUBTRACT, 10` succeeds.
- `4, 14, SUBTRACT, 10` fails.
- Missing or extra operands fail without crashing.

Handoff to Alina:

- Player root uses collision layer `1`.
- Player detection area uses mask `2` for operands and mask `3` for interactions.
- Alina's scenes must not call Player methods directly.

Handoff to Rinata:

- Player consumes `phase_changed`.
- HUD reads equation state only from `equation_changed`.

## Alina: World And Content Instructions

Owned files:

```text
scenes/world/Level_01.tscn
scripts/world/Level01Controller.gd
scenes/actors/numbers/Operand.tscn
scripts/actors/numbers/Operand.gd
scenes/actors/enemies/Guardian10.tscn
scripts/actors/enemies/Guardian10.gd
scenes/world/interactions/EquationAltar.tscn
scenes/world/interactions/ResetShell.tscn
scenes/world/interactions/CoralGate.tscn
```

Tasks:

1. Build one compact `1152 x 648` authored arena with clear room for the HUD.
2. Place PlayerSpawn, four land operand markers, four water operand markers, two altars, ResetShell,
   Guardian10, CoralGate, and solid outer boundaries.
3. Use `GameRules` values for operand content. Spawn instances at authored markers.
4. Operand exposes `@export var value: int` and reports collection to
   `GameState.try_collect_operand(value)`.
5. Hide or disable an operand only when collection succeeds.
6. On `operands_cleared`, restore the active phase's collected operands.
7. LandAltar is active only in `LAND`; WaterAltar only in `WATER`.
8. A correct land submission starts the tide. A correct water submission completes the level.
9. During transition, disable interactions, close the dry route, animate water, open the coral route,
   swap operand sets, then enter `WATER`.
10. Guardian10 reacts to `shield_changed`; it does not validate arithmetic.

Collision layers:

| Layer | Purpose |
| --- | --- |
| `1` | player body |
| `2` | operands |
| `3` | altars and ResetShell |
| `4` | solid world boundaries and CoralGate |

Level layout requirement:

- The player must see Guardian10 from the starting area.
- `4` and `6` must require movement in different directions.
- `2` and `7` must look equally reachable.
- After flooding, the new route must visually lead toward Guardian10.
- `14` must be collected before `4` in the intended route so subtraction order is taught spatially.
- ResetShell remains reachable in both phases.

Isolation test:

- Running `Level_01.tscn` with placeholder Player and GameState shows all required landmarks.
- Only four operands are active per phase.
- Tide swaps visuals, routes, altars, and operands exactly once.
- Reset returns every world object to its authored state.

Handoff to Polina:

- Operand and interaction scripts call only documented `GameState` methods.

Handoff to Rinata:

- World emits state signals only; Rinata owns overlays, text, audio, and result presentation.

## Rinata: Experience And Integration Instructions

Owned files:

```text
project.godot
scenes/main/Main.tscn
scripts/main/Main.gd
scenes/ui/HUD.tscn
scripts/ui/HUD.gd
scenes/ui/TutorialOverlay.tscn
scripts/ui/TutorialOverlay.gd
scenes/ui/RuleChangeOverlay.tscn
scripts/ui/RuleChangeOverlay.gd
scenes/ui/ResultScreen.tscn
scripts/ui/ResultScreen.gd
scripts/autoload/GameEvents.gd
scripts/autoload/GameState.gd
scripts/autoload/AudioBus.gd
scripts/autoload/SceneLoader.gd
assets/audio/
assets/fonts/
```

Tasks:

1. Create the Godot 4.x project with `Main.tscn` as the main scene and define all input actions.
2. Register only the four agreed autoloads.
3. Compose Level 1 and UI without reaching into Level 1 child paths.
4. HUD displays target `10`, active operation, both operand slots, active rule, and two shield segments.
5. Represent empty slots as `_`, addition as `+`, and subtraction as `-`.
6. Tutorial sequence:
   - show arrow keys until the player moves;
   - explain `Find two numbers that make 10`;
   - explain submission when both slots are filled;
   - after flooding, show `RULES CHANGED: SPLIT`;
   - explain that subtraction uses collection order.
7. Pause gameplay input during the two-second tide overlay.
8. Keep the rule card visible after the overlay closes.
9. Play audio through stable IDs from `GameRules`.
10. ResultScreen shows Level 1 complete and offers restart. Next Level remains disabled or labelled
    `Coming next` until Level 2 exists.
11. Restart must replace the current Level 1 instance and call `reset_level_01()` before resuming.

HUD must consume signals and snapshots. It must not search for Player, Guardian10, operands, or altars.

Isolation test:

- HUD correctly renders snapshots for empty, one-operand, two-operand, land, and water states.
- Rule overlay blocks input, animates, and emits no gameplay result.
- Result screen emits `restart_requested`.
- Missing audio files log a warning and do not stop the game.

Handoff:

- Rinata performs the final integration from `Main.tscn`.
- Any required node-path lookup outside Rinata-owned composition files is an architecture bug.

## Reset And Failure Behavior

Easy Mode has no death state in Level 1.

Wrong equation:

1. `equation_submitted(false)` is emitted.
2. HUD flashes the equation.
3. Audio plays `equation_wrong`.
4. Both slots clear.
5. Collected active-phase operands return to their authored markers.
6. Player remains in place and can retry immediately.

Level restart:

1. Disable input.
2. Remove the current Level 1 instance.
3. Call `GameState.reset_level_01()`.
4. Instantiate a fresh `Level_01.tscn`.
5. Reset HUD/tutorial/result UI.
6. Emit `run_started(GameRules.LEVEL_01_ID)`.
7. Enable input.

No node or signal connection from the old level may survive restart.

## Integration Order

1. Rinata creates `project.godot`, autoload skeletons, input actions, and empty Main composition.
2. Polina adds `GameRules`, `EquationService`, Player, and arithmetic tests.
3. Alina adds Level 1, operands, landmarks, and placeholder interactions.
4. Rinata connects HUD to state signals.
5. Integrate the land equation end to end.
6. Add tide transition and water equation.
7. Add Guardian feedback, tutorial, audio, result, and restart.
8. Run QA and freeze Level 1 before Level 2 work begins.

Parallel work is allowed after steps 1 and 2 publish the shared contracts.

## Manual Main-Scene Test

1. Launch `Main.tscn`.
2. Confirm the arrow tutorial disappears after movement.
3. Collect `4`, then `6`; HUD displays `4 + 6 = 10`.
4. Submit and confirm one shield breaks.
5. Confirm input pauses while the pink tide fills the arena.
6. Confirm the rule card changes to subtraction and the water route opens.
7. Collect `14`, then `4`; HUD displays `14 - 4 = 10`.
8. Submit and confirm Guardian10 is defeated.
9. Restart from the result screen.
10. Confirm the level returns to dry land with empty slots and two shields.
11. Submit a wrong pair and confirm immediate recovery without a crash or scene reload.
12. Run `tools/qa.cmd`.

## Definition Of Done

- All manual steps pass from `Main.tscn`.
- Arithmetic isolation tests pass.
- `tools/qa.cmd` passes on Windows.
- No warnings are caused by stale signal connections after three restarts.
- Every shared name matches `INTEGRATION_CONTRACT.md`.
- Another teammate can replace placeholder art without editing gameplay scripts.

## Scope Warning

Do not add health, oxygen, timers, moving currents, random equations, Level 2, Hard mode, combat,
dialogue systems, save data, or Boss 67 during this slice. The only polish priorities are readability,
responsive movement, the tide moment, equation feedback, and reliable restart.
