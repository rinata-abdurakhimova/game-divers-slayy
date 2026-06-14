# Boss 67 Platformer Visual And UI Guide

## Goal

Make the new side-view Boss 67 score fight readable before it is pretty.

The player must always know:

1. Current score.
2. Target score: `67`.
3. Which operations are helpful or dangerous right now.
4. Whether the level is land or water.
5. Whether a power-up is active.
6. How to restart after win or failure.

## Visual Direction

- Land: sand blocks, peach/pink sky, readable platform silhouettes.
- Water: opaque blue rectangle floods the screen while sand blocks remain visible underneath.
- Boss 67: large, readable, threatening, but not visually noisy.
- Player: pink character with cyan diving mask.
- Star icon: slow boss/projectiles.
- Green up-arrow icon: temporary double jump.

## Grid And Scale

- Design grid: `12 x 8`.
- Level 1 route: `53` authored columns from the latest board transcription, shown through the `12 x 8`
  camera window. Columns `1-18` are safe-zone/tutorial space.
- One block = one gameplay unit.
- Player = one gameplay unit.
- Use a clear side-view platform layout.
- Do not make the route read as random floor clutter. Each block should either teach movement, shape
  a jump, block a white projectile, or create a readable pickup choice.
- Avoid dense decoration that hides blocks, projectiles, pickups, or the player.

## HUD

HUD must show:

```text
SCORE: 1.00      TARGET: 67      LAND / WATER      RULE SET      TIMER
```

During water, show:

- selected water variant;
- boss operation set;
- floor pickup operation set;
- water timer counting down from `10`;
- active complication, if any.

Power-up indicators:

- star + seconds left for slow;
- green up arrow + seconds left for double jump.

## Cutscene

Use a simple placeholder card. Story text is TBD.

Requirements:

- skippable with `action`;
- does not start boss projectiles before gameplay begins;
- transitions cleanly to safe start.

## Safe Start

Visuals:

- sand floor;
- pink sky;
- 18 columns of safe tutorial space;
- a reachable jump lesson before column `19`;
- no boss projectiles.

After the first taught jump, visually close or remove the safe start so the boss fight begins.

The safe-start closure must not look like a foreground stone/platform block in the middle of the
screen. Use an invisible backstop, offscreen closure, camera lock, or another clear transition.

## Numbers

All numbers must be readable.

- Use labels for digits and operations.
- Do not bake digits into sprites for the first version.
- White boss digits are blockable.
- Purple boss digits pass through blocks.
- Boss digits should visibly travel from Boss 67 toward the player.
- Make projectile labels large enough for `x1.15`, `x0.5`, `-10`, and `+7`.
- Land pickups should contrast against sand.
- Water pickups should contrast against blue overlay.

## Water

Water is not a new level. It is a timed mode.

- Fill the screen with a blue opaque rectangle.
- Keep sand/block silhouettes visible.
- Show `10` second timer.
- Show current water variant.
- Show complication warning before reversed controls begins.
- Do not show inverted gravity in the MVP; it is deferred until a ceiling route exists.

## Power-Ups

| Visual | Meaning |
| --- | --- |
| Star | Slow boss and projectiles for `5` seconds |
| Green up arrow | Double jump for `5` seconds |

Power-ups should appear rarely at high points. Do not hide them behind decoration.

## Result Screen

Victory:

```text
BOSS 67 DEFEATED
SCORE 67
RESTART
```

Failure:

```text
SCORE HIT 0
PLAY AGAIN
```

## Asset Use

The platformer asset pack is visual-only. It does not provide code.

Minimum useful assets:

- player idle/run/jump/fall/hit/death strips;
- jump dust strips;
- `tileset_32x32(new).png`;
- one land background;
- sand blocks;
- orb pickup;
- star;
- green arrow;
- Boss 67 visual base;
- water overlay/effect.

Do not import the full pack.

## Accessibility

- Never rely on color alone.
- Always show operation text such as `*0.5`, `+7`, `-10`.
- Avoid tiny digits.
- Avoid visual clutter around player and projectiles.
- Water complications must have text/icon warnings.

## Test Checklist

- Player remains readable on land.
- Player remains readable under water overlay.
- All pickups are readable.
- White and purple projectiles are visually distinct.
- Boss projectiles visibly originate from Boss 67.
- Safe-start closure is not visible as a center block.
- Score text is readable while moving.
- Water rule set is understandable within two seconds.
- Power-up icons are distinguishable.
- Win and failure screens are unambiguous.
