# Slay Diver 67 Architecture

## Goal

Build one complete vertical slice of `Slay Diver: Rise of 67` as a side-view platformer boss chase.

The game now starts with:

1. A short cutscene placeholder. Story text is intentionally deferred.
2. Immediate confrontation with Boss 67.
3. A safe sand-and-sky tutorial strip where the player learns walking and one-block jumping.
4. The safe strip closes behind the player after the first taught jump.
5. Boss 67 appears and attacks while the player tries to make the score exactly `67`.
6. The level alternates between land rules and short water-rule bursts.
7. Reaching score `67.00` wins. Reaching score `0.00` fails and shows play-again/restart.

Only this single Boss 67 vertical slice is in scope. Do not build Guardian 10, Guardian 12, multi-level
progression, top-down arenas, altars, equation submission rooms, or the old `4 + 6` / `14 - 4` loop.

## Core Game Idea

The player does not type equations. The player survives platforming pressure and collects or dodges
number operations that change a running score.

```text
platform movement -> choose pickups/dodge attacks -> score changes -> water rule twist -> exact 67 or 0
```

Boss 67 is not an unwinnable tutorial boss. The first playable objective is to beat 67.

## Design Reference

Use Celeste principles, not Celeste mechanics:

- responsive side-view movement;
- short authored platform chunks;
- readable hazards and collectibles;
- fast recovery after failure;
- one clear numeric objective;
- pressure created by space and timing, not complex combat.

The board reference defines the gameplay layout and rule phases. The current visual asset pack provides
only art, not movement or game logic.

## Viewport, Grid, And Scale

- Runtime viewport: `1152 x 648`.
- Gameplay vision window: `12 columns x 8 rows`.
- One block is `1 x 1` gameplay unit.
- Player body is also `1 x 1` gameplay unit.
- MVP tile size may be `48`, `54`, or `64` pixels as long as the visible playfield preserves the
  `12 x 8` decision grid.
- The full Boss 67 route is much longer than one screen. The `12 x 8` grid describes only the readable
  camera window, not the whole map.
- During the chase, keep the player near the horizontal center of the camera view whenever possible so
  the player can read upcoming pickups, projectiles, sand floor, and water changes.
- The latest authored route has `53` unique columns because the board transcription includes `x=53`;
  column `54` is the same wrapped space as column `1`.
- The first `18` columns are safe-zone/tutorial space, and the boss fight starts at column `19`.
- After the safe tutorial closes, the route wraps on both horizontal edges: walking left past column
  `1` appears near column `53`, and walking right past column `53` appears near column `1`.
- Looping must preserve current score, boss phase, water cooldowns, active power-ups, and projectile
  cleanup. Do not restart the whole run unless the player has won, failed, or explicitly pressed
  restart.
- The player initially learns to jump one block.
- Authored terrain `y` values define the top height of a standable sand column. Runtime terrain fills
  every row from the floor up to that top height, so the player can stand and walk on blocks instead
  of seeing unreachable floating collision islands.
- Terrain stacks may be up to `5` blocks high, but every required path must remain reachable with the
  approved movement kit.
- Camera may follow horizontally after the safe tutorial strip, but each screen-length chunk should
  still read as a `12 x 8` board.

## Runtime Scene Shape

```text
Main
|- CutsceneIntro
|- LevelContainer
|  `- Boss67Level
|     |- Background
|     |  |- LandSky
|     |  |- SandLayer
|     |  `- WaterOverlay
|     |- Terrain
|     |  |- Blocks
|     |  |- SafeStart
|     |  `- WaterCeilingBlocks
|     |- Actors
|     |  |- Player
|     |  `- Boss67
|     |- Pickups
|     |- Projectiles
|     `- LevelController
|- UI
|  |- HUD
|  |- TutorialOverlay
|  |- WaterRuleOverlay
|  `- ResultScreen
`- Audio
```

`Main.tscn` remains the authoritative entry point. Feature scenes may run in isolation, but the final
test starts from `Main.tscn`.

## Level Flow

### 1. Cutscene Placeholder

- Show a short non-final cutscene screen.
- Story copy is TBD and must not block implementation.
- Cutscene can be skipped.
- After it ends, load the Boss 67 level.

### 2. Safe Start

- Player spawns in a safe sand-and-pink-sky area.
- No boss projectiles, score pickups, power-ups, or authored boss-route blocks are active.
- The safe start is `18` columns wide. It should read as empty sand/sky plus exactly one tutorial cube,
  used only to teach walking and a one-block jump.
- Teach:
  - move left/right;
  - fall and land;
  - jump onto one block;
  - short hop versus held jump if implemented.
- After the player clears the first one-block jump checkpoint, the safe area closes/deactivates and
  the full authored Boss 67 route appears. Do not leave a foreground stone/platform block in the
  center of the screen as the closure.
- Column `13` contains the single safe-zone jump cube. Boss 67 appears at column `19`.

### 3. Land Boss Phase

Boss 67 throws white number projectiles. White projectiles collide with blocks and are destroyed by
blocks.

Projectile readability requirements:

- Projectiles spawn from visible Boss 67 anchors and travel left toward the player.
- The number operation must be readable against the sky and water overlays.
- White projectiles use high-contrast white/red number treatment.
- Purple projectiles must be visibly purple, less frequent, and visually distinct from pickups.

Land score pickups spawn on:

- block tops;
- floor tiles;
- two tiles above a floor or block so the player must jump to collect them.

There should be `6` or `7` collectible score pickups visible per `12 x 8` screen chunk.

Land pickup values:

```text
+1, +2, +3, +5, +6, +7
```

Land boss attack operations:

```text
*0, *0.5, *0.8
```

`*0` is rare because score `0.00` immediately fails the run.

### 4. Distance Milestones

Progress is measured in horizontal blocks from the start of the boss run.

| Distance | Change |
| --- | --- |
| `0` | Boss 67 appears after the safe jump. |
| `18` blocks | Boss starts adding rare purple projectiles. |
| `28` blocks | First water event starts. |

Current authored block correction: include the missing board block at `x=30, y=4`.

Purple projectiles:

- are fired less often than white projectiles;
- pass through blocks;
- are destroyed only by the floor or the water/ceiling boundary;
- apply their operation if they touch the player before being destroyed.

### 5. Water Events

Water lasts exactly `10` seconds.

When water starts:

- a solid blue, opaque water rectangle covers the playfield;
- the sand and blocks remain visible enough to show the terrain silhouette;
- movement becomes smoother/slipperier;
- a water rule set is selected;
- at most one water complication is active.

First water event:

- starts at the `28` block distance milestone;
- should be readable and not overloaded;
- may use no complication if playtesting shows the first water is too chaotic.

Later water events:

- can start after the first water has ended;
- trigger when the player, while on land, collects a number divisible by `6` or `7`;
- use a cooldown so collecting multiple qualifying pickups does not stack water events.

### 6. Water Rule Sets

Choose one water rule set per water event.

| Variant | Boss throws | Floor / terrain pickups |
| --- | --- | --- |
| Water A | `*1.15`, `*1.2`, `*1.3` | `-10`, `-12`, `-8`, `-6` |
| Water B | `+3`, `+5`, `+6`, `+7` | `*0.5`, `*0.2`, `*0.3`, `*0` |
| Water C | `-5`, `-1`, `-2`, `-7`, `-10` | `*2`, `*6`, `*3`, `*1` |

The rule set must be displayed clearly in the HUD. The player should know whether Boss 67 and the
floor are currently helpful or dangerous.

### 7. Water Complications

Each water event can optionally use one complication:

| Complication | Behavior |
| --- | --- |
| Reversed controls | `left` becomes `right`, `right` becomes `left`, `up/jump` and `down` swap only if the final controls include vertical swim input. |
| Inverted gravity | Deferred. It requires a ceiling-block route and manual recovery test before it can be selected. |

MVP rule:

- never combine both complications in the same water event;
- first water uses the gentler reversed-controls complication so the UI can prove the condition is
  visible without risking the current inverted-gravity disappearance bug;
- inverted gravity is disabled for the current MVP until a ceiling-block route is implemented,
  the player can recover after water ends, and the path is manually verified;
- always show a clear icon/text before enabling the complication.

### 8. Score Rules

- Score starts at `1.00`.
- Score can be negative.
- Score `0.00` is immediate failure / play again.
- Score `67.00` is immediate victory.
- Score may exceed `67`; the player can continue until another operation brings it to exactly `67`.
- Use fixed-point arithmetic internally, rounded to two decimal places, to avoid floating-point drift.
- Display score with up to two decimals.
- When a projectile or pickup would produce `0.00`, show the failure state after applying the effect.

### 9. Power-Ups

Power-ups are rare and appear on high or risky platform points.

| Icon | Meaning | Duration |
| --- | --- | --- |
| Star | Slow Boss 67 and all projectiles. | `5` seconds |
| Green up arrow | Temporary double jump. | `5` seconds |

Do not add more power-ups until the core score chase works.

## Ownership

| Role | Member | Owns |
| --- | --- | --- |
| Core Systems | Polina | platformer player adaptation, score math, score effects, win/fail rules, water rule selection |
| World and Content | Alina | side-view level chunks, blocks, pickup spawn positions, boss/projectile authored lanes, safe tutorial |
| Experience and Integration | Rinata | intro cutscene shell, Main composition, HUD, water overlay, inputs, audio, restart, attribution, QA |

Shared docs and contracts must be updated before code changes.

## Platformer Controller Integration

Use `docs/PLATFORMER_CONTROLLER.md`.

Only adapt:

- horizontal movement;
- gravity and falling;
- one jump;
- short hop;
- coyote time;
- jump buffering;
- floor/platform collision.

Do not add dash, roll, crouch, wall jump, wall slide, wall latch, double jump by default, ground pound,
or corner correction unless explicitly accepted later. The temporary double-jump power-up is a game
effect, not a permanent movement ability.

## Assets

The attached platformer pack contains visual assets only. It does not provide movement, score logic,
Boss 67 AI, water mode, projectiles, pickup behavior, or restart behavior.

Use:

- player strips, recolored pink with a cyan diving mask;
- `tileset_32x32(new).png` for sand blocks and platforms;
- `background.png` or 2-3 recolored background layers for land;
- opaque blue rectangle overlay for water;
- star icon for slow effect;
- green up-arrow icon for temporary double jump.

Do not import the full pack. Keep minimum asset import documented in `THIRD_PARTY_NOTICES.md`.

## Reset And Failure

Failure:

- score becomes `0.00`;
- player is hit by an explicitly fatal hazard if one is later approved;
- player falls out of the world.

Victory:

- score becomes exactly `67.00`.

Restart:

- reset score to `1.00`;
- clear projectiles, pickups, power-ups, water timers, and complications;
- return to the post-cutscene safe start or replay cutscene depending on the menu setting;
- no stale signal connections survive.

## Integration Order

1. Update docs and contract. No code until the team accepts this reset.
2. Rinata updates inputs: `jump`, `action`, movement, restart.
3. Polina creates isolated side-view Player movement test.
4. Alina creates a small side-view test room with sand blocks and a one-block jump.
5. Polina adds score math and operation application tests.
6. Alina adds Boss 67 projectile lanes and pickup placement rules.
7. Rinata connects HUD score/rule/water timer/restart.
8. Integrate first land segment to 18 blocks.
9. Add purple projectiles from 18 blocks.
10. Add first water event at 28 blocks.
11. Add one water complication only after the water event is understandable.
12. Run QA and manual playtest.

## Manual Main-Scene Test

1. Launch `Main.tscn`.
2. Skip or finish the placeholder cutscene.
3. Spawn in safe sand-and-sky area.
4. Walk, fall, land, and jump onto one block.
5. Confirm safe start closes after the first taught jump.
6. Confirm there is no visible stone-like wall/block left in the center of the playfield after closure.
7. Walk left after the boss run starts and confirm the player wraps to the far right of the authored
   route without losing score, boss phase, or movement.
8. Confirm Boss 67 appears.
9. Confirm boss projectiles visibly originate from Boss 67 and their operations are readable.
10. Collect land pickups and avoid `*0`, `*0.5`, `*0.8`.
11. Reach 18 blocks and confirm rare purple projectiles begin.
12. Reach 28 blocks and confirm water lasts `10` seconds.
13. Confirm the selected water rule set is shown in the HUD.
14. Confirm score can go negative but `0.00` fails.
15. Reach exactly `67.00` and confirm victory.
16. Restart and confirm a clean run.
17. Run `tools\qa.cmd`.

## Scope Warning

Do not build multiple levels, old Guardian fights, top-down rooms, altar equations, weapons, shops,
health bars, inventories, dialogue trees, or procedural maps. The vertical slice is one platformer
boss fight where the player wins by making score `67`.
