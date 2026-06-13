# Level 1 Boss 67 Player/Core Manual Test

Run this after Polina-owned files are implemented in the real project.

## Movement Sandbox

- [ ] Open the isolated movement sandbox or `Player.tscn`.
- [ ] Confirm the scene runs without errors.
- [ ] Press left/right.
- [ ] Confirm horizontal movement feels controllable.
- [ ] Walk off a platform.
- [ ] Confirm the player falls and lands.
- [ ] Tap jump.
- [ ] Hold jump.
- [ ] Confirm held jump is higher than tap jump.
- [ ] Walk off a ledge and press jump shortly after leaving it.
- [ ] Confirm coyote time works.
- [ ] Press jump shortly before landing.
- [ ] Confirm jump buffering works.
- [ ] Jump in the air without power-up.
- [ ] Confirm no repeated airborne jump happens.
- [ ] Activate temporary double jump.
- [ ] Confirm one extra air jump works for 5 seconds only.
- [ ] Simulate input disabled.
- [ ] Confirm player movement cannot be controlled.
- [ ] Reset the player.
- [ ] Confirm position, velocity, gravity, controls, power-ups, and visuals reset correctly.

## Score Math

- [ ] Start score is `1.00`.
- [ ] Apply `+1`, `+2`, `+3`, `+5`, `+6`, and `+7`.
- [ ] Apply `*0.5` and confirm deterministic fixed-point result.
- [ ] Apply `*0.8` and confirm deterministic fixed-point result.
- [ ] Apply `*0` and confirm failure by score `0.00`.
- [ ] Apply a water subtraction that makes score negative.
- [ ] Confirm negative score does not fail.
- [ ] Reach exact `67.00`.
- [ ] Confirm victory.
- [ ] Reach `67.01` or `66.99`.
- [ ] Confirm no victory.

## Integrated Main Route

- [ ] Launch from `Main.tscn`.
- [ ] Confirm the cutscene placeholder appears before gameplay.
- [ ] Confirm player starts in the safe sand/sky tutorial area.
- [ ] Walk, fall, land, and jump one block.
- [ ] Confirm the safe start closes after the tutorial jump.
- [ ] Confirm Boss 67 appears.
- [ ] Confirm white boss digits collide with blocks.
- [ ] Reach 18 horizontal blocks from boss-run start.
- [ ] Confirm purple projectiles can appear and pass through blocks.
- [ ] Reach 28 horizontal blocks from boss-run start.
- [ ] Confirm water starts.
- [ ] Confirm water uses one documented variant.
- [ ] Confirm water lasts exactly 10 seconds.
- [ ] Confirm restart during water restores land state.
- [ ] Collect a land value divisible by 6 or 7 after the first water.
- [ ] Confirm later water can trigger only after cooldown.
- [ ] Collect or hit values until exact `67.00`.
- [ ] Confirm level victory.
- [ ] Restart.
- [ ] Force score `0.00`.
- [ ] Confirm failure/play-again state.
- [ ] Restart without relaunching the app.
- [ ] Run `tools\qa.cmd`.

## Fast Debug Prints To Remove Before Polish

```gdscript
print("score changed: %s" % score_snapshot)
print("water started: %s %s" % [variant, complication])
print("player failed: %s" % reason)
```
