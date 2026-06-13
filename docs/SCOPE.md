# Scope Board

## Selected Concept

**Working title:** `Slay Diver: Rise of 67`

**Format:** 2D side-view platformer boss fight with score arithmetic.

## One-Sentence Game

Run and jump through a sand-and-water platformer arena while Boss 67 throws number operations; collect
and dodge operations until the score becomes exactly `67`.

## Story

Story will be written later. The current build starts with a placeholder cutscene and immediately moves
into the Boss 67 fight.

Boss 67 is powerful, but this is not an unwinnable intro. The player's job is to beat 67 in this first
vertical slice.

## Core Loop

```text
move and jump -> read incoming operations -> collect helpful numbers -> dodge harmful numbers ->
survive water twists -> hit exact 67 -> win or hit 0 -> play again
```

## Score

- Start score: `1.00`.
- Target score: `67.00`.
- Win: score becomes exactly `67.00`.
- Fail: score becomes exactly `0.00`.
- Score can be negative.
- Score can exceed `67.00`; the player continues until exact `67.00` or `0.00`.
- Use fixed-point arithmetic and display up to two decimals.

## Screen And Movement

- Side-view platformer.
- Design grid: `12 x 8`.
- One block is one gameplay unit.
- Player is one gameplay unit.
- Teach walking and one-block jumping before the boss starts.
- Platform stacks may be up to `5` blocks high, but required movement must remain readable.
- Reference controller: `docs/PLATFORMER_CONTROLLER.md`.

## Opening Flow

1. Placeholder cutscene.
2. Safe sand-and-sky start.
3. Player learns to walk and jump onto one block.
4. Safe start closes after the first taught jump.
5. Boss 67 appears.
6. Score chase begins.

## Land Phase

Land pickups:

```text
+1, +2, +3, +5, +6, +7
```

Rules:

- Spawn `6` or `7` collectible numbers per visible `12 x 8` screen chunk.
- Pickups can appear on block tops, floor, or two blocks above a floor/block.
- Boss throws `*0`, `*0.5`, and `*0.8`.
- `*0` is very rare.
- White boss digits are destroyed by blocks.

## Boss Distance Escalation

Distance is measured in horizontal blocks after the safe start.

| Distance | Change |
| --- | --- |
| `0` | Boss 67 appears. |
| `18` | Purple boss digits begin. |
| `28` | First water event begins. |

Purple digits:

- fire less often;
- pass through blocks;
- are destroyed only on the floor / water boundary;
- apply their operation on player contact.

## Water Events

Water lasts `10` seconds.

Water can first appear at `28` blocks. After the first water event, another water event can begin when
the player collects a land number divisible by `6` or `7`, with cooldown.

When water starts:

- an opaque blue rectangle covers the playfield like water;
- sand and blocks remain structurally readable underneath;
- movement becomes smoother/slipperier;
- one water rule variant is selected;
- at most one complication may be selected.

## Water Rule Variants

| Variant | Boss throws | Floor/terrain pickups |
| --- | --- | --- |
| A | `*1.15`, `*1.2`, `*1.3` | `-10`, `-12`, `-8`, `-6` |
| B | `+3`, `+5`, `+6`, `+7` | `*0.5`, `*0.2`, `*0.3`, `*0` |
| C | `-5`, `-1`, `-2`, `-7`, `-10` | `*2`, `*6`, `*3`, `*1` |

The HUD must show which side is dangerous or helpful in the current water event.

## Water Complications

Only one may be active in a water event.

- Reversed controls: horizontal controls swap. Vertical controls swap only if vertical swim input is
  added later.
- Inverted gravity: blocks are on the ceiling and gravity pulls upward.

The first water event should be understandable. Do not combine complications.

## Power-Ups

Power-ups are rare and spawn on high points.

| Visual | Effect | Duration |
| --- | --- | --- |
| Star | Slow Boss 67 and projectiles. | `5` seconds |
| Green up arrow | Temporary double jump. | `5` seconds |

## Must Ship

- Placeholder cutscene.
- Side-view Player movement: walk, fall, land, jump, short hop, coyote time, jump buffering.
- Safe start with one-block jump teaching.
- Boss 67 appears after tutorial.
- Score starts at `1.00`.
- Land pickups and land boss operations.
- Purple projectiles after `18` blocks.
- First water event after `28` blocks.
- At least one water rule variant implemented.
- Score `0.00` fails.
- Score `67.00` wins.
- Restart without relaunch.
- HUD with score, target, phase, water rule, water timer, and active power-up.
- `tools/qa.cmd` passes.

## Should Ship

- All three water variants.
- One water complication.
- Rare star slow power-up.
- Rare green double-jump power-up.
- Basic Boss 67 animations and readable projectile colors.
- Cutscene art pass.

## Could Ship

- Both water complications.
- More authored platform chunks.
- Boss expression changes based on score.
- Sound and particles for each operation type.

## Explicitly Cut

- Old Guardian 10 and Guardian 12 levels.
- Top-down movement.
- Equation altars and two-slot equation rooms.
- Free-form equation typing.
- Health bars.
- Weapons, sword attacks, shops, inventories, upgrades.
- Procedural map generation.
- Multiple bosses.
- Combining both water complications in the same event.

## Team Split

### Polina: Core Systems

- Adapt platformer movement into Player.
- Preserve detection, reset, input enable/disable, signals, and collision contracts.
- Implement score math and fixed-point operations.
- Implement win/fail rules.
- Define water variants and complications.
- Write score and movement isolation tests.

### Alina: World And Content

- Side-view safe start.
- `12 x 8` platform chunks.
- Block layout and pickup positions.
- Boss 67 projectile lanes.
- White/purple projectile world behavior.
- High-point power-up locations.

### Rinata: Experience And Integration

- Cutscene shell.
- Main scene flow.
- Inputs.
- HUD and overlays.
- Water visual overlay.
- Audio.
- Restart and QA.
- Asset import and attribution.

## Vertical-Slice Test

1. Launch from `Main.tscn`.
2. Skip/finish cutscene.
3. Learn walk and one-block jump in safe sand area.
4. Cross first jump and close safe start.
5. Boss 67 appears.
6. Collect land pickups and change score.
7. Avoid a `*0` or prove it fails if touched.
8. Reach `18` blocks and see purple digits begin.
9. Reach `28` blocks and enter water for `10` seconds.
10. Apply one water variant correctly.
11. Reach exact `67.00` and win.
12. Restart and confirm clean state.

## Scope Warning

This is a full design reset. Do not continue old top-down code work until the team accepts this
contract. Keep the first platformer version small enough to test in one room/chase path.
