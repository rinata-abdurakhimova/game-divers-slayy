# Level 1 Easy Player/Core Manual Test

Run this after Polina-owned files are implemented in the real project.

## Isolation Test

- [ ] Open the player sandbox or `Player.tscn`.
- [ ] Confirm the scene runs without errors.
- [ ] Press left/right/up/down.
- [ ] Confirm movement speed feels controllable.
- [ ] Hold a diagonal direction and confirm it is not faster than one direction.
- [ ] Walk into a test wall and confirm collision stops the player.
- [ ] Release input.
- [ ] Confirm velocity stops or decelerates as intended.
- [ ] Simulate `phase_changed(GameRules.Phase.WATER)`.
- [ ] Confirm player visuals switch, but movement stays identical.
- [ ] Simulate `phase_changed(GameRules.Phase.LAND)`.
- [ ] Confirm player visuals return safely.
- [ ] Reset the player.
- [ ] Confirm position, velocity, input state, and visuals reset correctly.
- [ ] Run arithmetic checks for addition and subtraction order.

## Integrated Test From Main

- [ ] Launch from `Main.tscn`.
- [ ] Start a run.
- [ ] Move the player.
- [ ] Collect `4`, then `6`.
- [ ] Submit `4 + 6 = 10`.
- [ ] Confirm the first shield breaks and the tide transition starts.
- [ ] Confirm input is disabled during the tide transition.
- [ ] Collect `14`, then `4`.
- [ ] Submit `14 - 4 = 10`.
- [ ] Confirm Guardian10 is defeated and Level 1 completes.
- [ ] Restart.
- [ ] Confirm dry state, empty slots, two shields, and land player visual.
- [ ] Submit a wrong pair.
- [ ] Confirm operands clear and the active phase can be retried without scene reload.
- [ ] Restart again.
- [ ] Run `tools\qa.cmd`.

## Fast Debug Prints To Remove Before Polish

```gdscript
print("player moved")
print("phase changed: %s" % phase)
print("equation checked: %s" % correct)
```
