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

- dash, roll, crouch and run modifier;
- wall jump, wall slide and wall latch;
- double jump, ground pound and corner correction.

## Integration

Polina adapts the required movement into the existing `Player.gd`; do not replace the Player scene
unchanged. Preserve `DetectionArea`, `GameState.input_enabled`, phase visuals, reset behavior,
movement signals, and collision contracts.

`Space` becomes `jump`. Use `Enter` or `E` for `action`.

Alina builds a small side-view test room before converting Level 1. Rinata updates inputs, tutorial,
attribution, and QA.

## Acceptance Test

- Player walks, falls, lands and jumps on Godot 4.6.3.
- Holding jump produces a higher jump than tapping.
- Coyote time and jump buffering work without allowing repeated airborne jumps.
- Operand collection, input disabling and restart still work.
- `tools/qa.cmd` passes.

Do not merge the platformer conversion until the isolated movement test passes.
