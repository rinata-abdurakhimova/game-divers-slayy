# Polina Level 1 Easy Core Plan

## Skill Pass

- `$jam-brainstorm`: concept is already selected, so do not generate new concepts. Lock scope to
  `Slay Diver: Rise of 67`, Level 1 Easy, Guardian 10.
- `$jam-architecture`: use the locked contract as the boundary. Polina owns Player, rules constants,
  arithmetic validation, and phase response only.
- `$jam-implement`: implement the smallest Polina-owned slice after Rinata creates `project.godot`,
  input actions, autoload skeletons, and `Main.tscn`.
- `$jam-qa`: verify arithmetic isolation first, then the twelve-step Main-scene Level 1 route.

## Goal

Deliver the Polina-owned core for the first level:

```text
move -> collect operands -> validate addition -> tide handoff -> validate subtraction -> complete
```

The first level teaches one readable mechanic: numbers are the attack. Land combines with addition;
water splits with subtraction. No health, score, timer, oxygen, random equations, or Level 2 work.

## Acting Role

Polina, Core Systems.

Primary promise: make the arithmetic and player feel reliable enough that Alina and Rinata can build
world, HUD, audio, and restart around stable contracts.

## Files And Ownership

Polina-owned implementation files:

- `scenes/actors/Player.tscn`
- `scripts/actors/player/Player.gd`
- `scripts/gameplay/GameRules.gd`
- `scripts/gameplay/EquationService.gd`
- `tests/gameplay/test_equation_service.gd`

Shared files Polina may review, not own:

- `scripts/autoload/GameState.gd`: Rinata owns the file; Polina reviews equation mutation behavior.
- `INTEGRATION_CONTRACT.md`: edit only before changing a shared name, payload, input, or layer.

Do not edit for this slice:

- `scenes/world/`, `scripts/world/`, `scenes/actors/enemies/`: Alina.
- `project.godot`, `scenes/main/`, `scripts/autoload/`, `scenes/ui/`, `scripts/ui/`: Rinata.

## Architecture

Smallest scene tree for Polina:

```text
Player (CharacterBody2D)
|- CollisionShape2D
|- LandVisual
`- WaterVisual
```

`Player.gd` responsibilities:

- read `move_left`, `move_right`, `move_up`, `move_down`;
- use `Input.get_vector` so diagonal movement is normalized;
- call `move_and_slide`;
- expose movement tuning with `@export`;
- stop movement when integration disables input;
- react to `phase_changed` by toggling visual children only;
- reset position and velocity safely for isolated tests.

`GameRules.gd` responsibilities:

- define `Phase` and `Operation`;
- define immutable Level 1 constants: target `10`, land `4, 6`, water `14, 4`, distractors, sound IDs;
- avoid layout positions, UI text, or audio streams.

`EquationService.gd` responsibilities:

- provide pure typed validation functions;
- accept addition in either order;
- preserve subtraction collection order;
- fail missing, extra, unknown, or unsupported operands without crashing.

## Implementation Order

1. Wait for Rinata's project skeleton.
   Required before Polina implementation: `project.godot`, input actions, autoload stubs, and main
   scene path exist.
2. Add `GameRules.gd`.
   This unblocks Alina's operand values and Rinata's HUD/audio IDs.
3. Add `EquationService.gd` and tests.
   This is the safest first code because it has no scene coupling.
4. Add `Player.tscn` and `Player.gd`.
   Use placeholders only; no art dependency.
5. Connect phase visual response.
   Consume `GameEvents.phase_changed` if present, but fail safely in isolation.
6. Review `GameState.gd` equation methods with Rinata.
   Confirm it delegates validation to `EquationService` and emits the locked signals.
7. Run isolation tests and `tools\qa.cmd`.
8. Hand off to Alina and Rinata for full Main-scene integration.

## Signals And Dependencies

Polina consumes:

- `phase_changed(phase: GameRules.Phase)` for Player visual response.
- input actions from `project.godot`.
- collision boundaries authored by Alina.

Polina provides:

- `GameRules` constants used by GameState, Level01Controller, operands, HUD, and AudioBus.
- `EquationService` validation used by GameState.
- `Player.tscn` root on collision layer `1`.

Polina does not emit global outcome signals directly in Level 1. `GameState` emits:

- `equation_submitted(correct: bool)`
- `equation_changed(snapshot: Dictionary)`
- `shield_changed(remaining: int)`
- `phase_changed(phase: GameRules.Phase)`
- `level_completed(level_id: StringName)`

## Teammate Handoff

To Alina:

- Player body uses collision layer `1`.
- Operands should be on layer `2`.
- Altars and ResetShell should be on layer `3`.
- Solid world and CoralGate should be on layer `4`.
- World scripts call only documented `GameState` methods; no direct Player method calls.

To Rinata:

- Define all input actions before Player testing.
- Register `GameEvents` and `GameState` before integrated testing.
- HUD reads `equation_changed(snapshot)` and never reads Player or world node paths.
- Restart must create a fresh Level 1 instance and reset GameState before input resumes.

## Test Checklist

Arithmetic isolation:

- `4, 6, ADD, 10` passes.
- `6, 4, ADD, 10` passes.
- `14, 4, SUBTRACT, 10` passes.
- `4, 14, SUBTRACT, 10` fails.
- `[4]`, `[4, 6, 2]`, and empty operands fail without crashing.

Player isolation:

- Player moves in four directions.
- Diagonal movement is not faster.
- Player stops on collision boundaries.
- Input disable clears velocity.
- Water phase changes visuals only.
- Reset clears velocity and restores the correct visual state.

Main-scene route:

- Launch `Main.tscn`.
- Collect `4`, then `6`.
- Submit `4 + 6 = 10`.
- Tide transition starts and input pauses.
- Collect `14`, then `4`.
- Submit `14 - 4 = 10`.
- Guardian10 is defeated.
- Result screen restart returns to dry state.
- Wrong pair clears operands and allows immediate retry.
- `tools\qa.cmd` passes.

## Scope Warning

Keep the first level small. Do not add health, score, timer, oxygen, random equations, combat,
dialogue systems, Boss 67, Level 2, Hard mode, or moving currents until Level 1 Easy passes the manual
Main-scene route and QA.

## Integration Notes

Dependencies:

- Rinata: Godot project skeleton, input actions, autoload stubs, Main composition.
- Alina: authored Level 1 boundaries, operand scenes, altars, ResetShell, Guardian10, CoralGate.

Emitted signals:

- Polina-owned code should not emit global outcome signals directly in Level 1.
- GameState emits the locked equation, shield, phase, and completion signals.

Consumers:

- Player consumes `phase_changed`.
- GameState consumes `EquationService`.
- World, HUD, tutorial, audio, and result screen consume GameEvents.

Assets:

- Player placeholders are allowed.
- Final stable assets remain `assets/sprites/player_idle.png` and `assets/sprites/player_water.png`.

Shortest manual test:

```text
Main.tscn -> move -> 4 + 6 -> tide -> 14 - 4 -> complete -> restart -> wrong pair recovery
```
