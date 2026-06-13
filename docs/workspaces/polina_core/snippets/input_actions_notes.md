# Input Actions Notes

Use these names because they are reserved in `INTEGRATION_CONTRACT.md`.

## Required Actions

- `move_left`
- `move_right`
- `move_up`
- `move_down`
- `action`
- `pause`
- `restart`

## Suggested Keyboard Defaults

- `move_left`: Left, A
- `move_right`: Right, D
- `move_up`: Up, W
- `move_down`: Down, S
- `action`: Space, Enter
- `pause`: Escape
- `restart`: R

## Suggested Controller Defaults

- movement: left stick or D-pad
- `action`: south face button
- `pause`: start/options
- `restart`: select/back or hold action after outcome

Level 1 Easy should use automatic operand collection and altar submission on overlap. Keep `action`
reserved as a fallback only. Do not rename these after integration without updating producers and
consumers together.
