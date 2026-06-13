# Tomorrow Context For Polina

Role: Polina, Core Systems.

Current slice: Level 1 Easy for `Slay Diver: Rise of 67`.

Owned areas:

- `scenes/actors/Player.tscn`
- `scripts/actors/player/`
- `scripts/gameplay/`
- player behavior
- core mechanic
- shared rule constants
- arithmetic validation
- phase response for player visuals
- Polina review of equation behavior in `GameState`

Current project status:

- No `project.godot` yet.
- Level 1 Easy architecture and integration contract are locked.
- Existing reserved input actions:
  - `move_left`
  - `move_right`
  - `move_up`
  - `move_down`
  - `action`
  - `pause`
  - `restart`
- Level 1 global signals:
  - `run_started(level_id: StringName)`
  - `phase_changed(phase: GameRules.Phase)`
  - `operand_collected(value: int, slot: int)`
  - `operands_cleared`
  - `equation_submitted(correct: bool)`
  - `equation_changed(snapshot: Dictionary)`
  - `shield_changed(remaining: int)`
  - `tide_started`
  - `tide_finished`
  - `level_completed(level_id: StringName)`
  - `restart_requested`

First implementation target:

Arrow movement -> collect two operands -> validate `4 + 6 = 10` -> trigger tide handoff -> validate
`14 - 4 = 10` -> complete Level 1 -> restart cleanly.

Ask Codex:

Use `$jam-architecture` before changing any boundary with World, UI, autoloads, signals, input, or
collision layers. Use `$jam-implement` for Polina-owned files after Rinata has the Godot project and
autoload skeletons.

Preferred prompt:

```text
I am Polina. Use $jam-architecture and $jam-implement. Implement the Polina-owned Level 1 Easy core
slice: GameRules, EquationService, Player movement, phase visual response, and arithmetic tests.
Use only scenes/actors/Player.tscn, scripts/actors/player/, scripts/gameplay/, and tests/gameplay/
unless the contract requires a shared edit. Start from docs/workspaces/polina_core only as reference.
```
