# Platformer Controller Usage

## Source

- Pack: Ultimate 2D Platformer Controller
- Creator: Noasey
- Source: https://noasey.itch.io/ultimate-2d-platformer-controller
- License: MIT
- Target: Godot 4.x; verify with our Godot 4.6.3 project

## Use

Adapt only:

- horizontal movement;
- gravity and falling;
- one jump;
- short hop;
- coyote time;
- jump buffering;
- floor and platform collision.

Disable or remove:

- dash, roll, crouch, and run modifier;
- wall jump, wall slide, and wall latch;
- permanent double jump;
- ground pound;
- corner correction;
- combat/attack behavior.

Temporary double jump exists only as a rare `5` second power-up and must not become the default player
controller.

## Integration

Polina adapts the required movement into the existing `Player.gd`. Do not replace the Player scene
unchanged. Preserve:

- `DetectionArea`;
- `GameState.input_enabled`;
- reset behavior;
- movement signals;
- collision contracts;
- phase/water visual hooks.

Inputs:

| Action | Default |
| --- | --- |
| `jump` | Space, Up, W |
| `action` | Enter, E |
| `move_left` | Left, A |
| `move_right` | Right, D |

Alina builds a small side-view test room before converting the full Boss 67 level. Rinata updates
inputs, tutorial, attribution, and QA.

## Acceptance Test

- Player walks, falls, lands, and jumps on Godot 4.6.3.
- Holding jump produces a higher jump than tapping.
- Coyote time works.
- Jump buffering works.
- The player cannot repeatedly jump in the air unless the temporary double-jump power-up is active.
- Score pickup detection still works.
- Input disabling still works during cutscenes, water transition, outcome, and restart.
- Restart clears velocity, water state, power-ups, and stale listeners.
- `tools/qa.cmd` passes.

Do not merge the platformer conversion into the main scene until the isolated movement test passes.
