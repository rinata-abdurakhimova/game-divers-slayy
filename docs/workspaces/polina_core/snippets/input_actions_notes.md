# Input Actions Notes

Use these names because they are reserved in `INTEGRATION_CONTRACT.md`.

## Required Actions

- `move_left`
- `move_right`
- `move_up`
- `move_down`
- `jump`
- `action`
- `pause`
- `restart`

## Suggested Keyboard Defaults

- `move_left`: Left, A
- `move_right`: Right, D
- `move_up`: Up, W
- `move_down`: Down, S
- `jump`: Space
- `action`: Enter, E
- `pause`: Escape
- `restart`: R

## Suggested Controller Defaults

- movement: left stick or D-pad
- `jump`: south face button
- `action`: east/west face button
- `pause`: start/options
- `restart`: select/back or hold action after outcome

Level 1 Boss 67 should use automatic pickup/projectile score application on collision. Keep `action`
reserved for future interact prompts only. Do not rename these after integration without updating
producers and consumers together.
