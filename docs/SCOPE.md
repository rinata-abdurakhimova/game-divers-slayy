# Scope Board

## Selected Concept

**Working title:** `Slay Diver: Rise of 67`

**Format:** 2D top-down arithmetic adventure with three levels.

## Story

Beavers and fish once lived peacefully and used intelligent numbers to build dams, navigate currents,
and share resources. The numbers decided they were more important than everyone else, formed an army,
and took over the coast under their leader, Boss 67.

Slay Diver wakes on the sand and learns that arithmetic is the only way to break the numbers' shields.
The goal is to defeat two number guardians and then confront 67.

## One-Sentence Game

Move Slay Diver around compact 2D arenas, collect number pairs that complete equations, and adapt when
pink water changes the rule from combining numbers to splitting them.

## Screen And Controls

- Top-down 2D view with the entire small arena visible.
- Slay Diver moves with the four arrow keys.
- Touching a number automatically places it into one of two equation slots.
- The current equation is always visible at the top of the screen.
- A nearby reset shell clears the current pair if the player makes a mistake.
- Delivering a completed equation to the target altar checks the answer.
- No separate attack button is required in the MVP. A correct equation automatically damages the
  number enemy.

## Core Level Loop

`See target number -> read current rule -> collect two operands -> submit equation -> break first shield
-> pink tide changes the arena and operation -> solve the new equation -> break final shield -> defeat
number -> next level`

## Land And Water Rule

### Land: Combine

The level begins on warm sand. Numbers are heavy and stationary because they are outside water.

- The active rule card says `COMBINE`.
- The player collects two numbers that combine into the target.
- Level 1 uses addition.
- Level 2 introduces multiplication.
- Correct submission breaks the first enemy shield.

Examples:

- `4 + 6 = 10`
- `3 x 4 = 12`

### Tide Transition

The water change is triggered by breaking the first shield, not by an invisible timer.

1. The enemy becomes angry and calls the pink tide.
2. Play slows or pauses for approximately two seconds.
3. A wave fills the arena from the bottom of the screen.
4. Sand changes to translucent pink water, bubbles appear, and loose numbers begin to float.
5. Slay Diver gains small fish features such as fins and a bubble helmet accent.
6. The HUD replaces `COMBINE` with a large `RULES CHANGED: SPLIT` card.
7. Old operands disappear before play resumes, preventing an unfair answer from carrying between rules.

### Water: Split

Underwater, the current pulls quantities apart.

- The active rule card says `SPLIT`.
- The player must represent the same target using subtraction or division.
- Previously blocked water channels open and reveal the new operands.
- The controls remain unchanged; water changes the puzzle and route, not the movement system.

Examples:

- `14 - 4 = 10`
- `24 / 2 = 12`

A correct water equation breaks the final shield. The enemy becomes vulnerable and is defeated by the
equation's energy beam.

## Reaching The Main Number

The number enemy is visible behind a coral gate at the far end of every level.

- The arena contains a small set of correct operands and believable distractors.
- The first equation opens the flooded route toward the enemy.
- The tide closes the dry route but opens a water channel through the coral.
- The second equation altar is located near the enemy.
- Solving it breaks the final shield and completes the level.

This gives the player a physical sense of approaching the target without requiring combat or a large
map.

## Difficulty Modes

Difficulty changes arithmetic and pressure, but not controls or level layouts.

### Easy: Cozy Current

- Level 1 uses addition and subtraction with numbers from `0` to `20`.
- Level 2 uses multiplication and exact division from the `2`, `3`, and `4` times tables.
- The required operation and equation shape are always visible.
- Only four possible operands appear at once.
- Correct operands have a subtle sparkle after several seconds.
- There is no overall level timer.
- A wrong answer clears the equation slots and plays feedback without removing health.
- Boss 67 uses guided multi-step equations with intermediate values shown.

### Hard: Riptide

- Uses larger operands and less obvious pairs.
- Six to eight operands and stronger distractors appear.
- A generous tide or oxygen timer creates pressure.
- Wrong answers remove health and reshuffle operand positions.
- The operation is shown, but hints and operand sparkles are disabled.
- Boss 67 requires the player to remember intermediate results in a two-operation equation.

Hard mode must never hide the active operation or change controls. Difficulty should test arithmetic,
not whether the player noticed an undocumented rule.

## Level 1: Guardian 10

**Purpose:** teach movement, HUD, collecting, submission, and the first tide change.

### Introduction

- Slay Diver wakes on the beach.
- A beaver shows arrow-key movement.
- The player has a short safe space to walk around and touch a practice number.
- The HUD explains the target, two operand slots, current operation, and health.

### Land Phase

- Target: `10`.
- Rule: `COMBINE` with addition.
- Example correct pair: `4 + 6`.
- Distractors: `2` and `7`.

### Water Phase

- Rule changes to `SPLIT` with subtraction.
- Example correct pair: `14 - 4`.
- The flooded route opens toward Guardian 10.
- Correct submission defeats 10.

Expected duration: approximately one to two minutes.

## Level 2: Guardian 12

**Purpose:** introduce multiplication and division using the same interaction.

### Land Phase

- Target: `12`.
- Rule: `COMBINE` with multiplication.
- Example correct pair: `3 x 4`.

### Water Phase

- Rule changes to `SPLIT` with division.
- Example correct pair: `24 / 2`.
- Small currents move the operands between fixed positions, but do not change player controls.

Expected duration: approximately two minutes.

## Level 3: Boss 67

This level is longer and remixes learned rules. Boss 67 has three shield segments and changes the tide
more aggressively than ordinary enemies.

### Phase 1: The Crown Shield

- The arena begins on sand.
- Rule: `COMBINE` with addition.
- The player creates `60 + 7 = 67`.
- Correct submission destroys the first crown gem.

### Phase 2: The Pink Tide

- 67 floods the arena.
- Rule: `SPLIT` with subtraction.
- The player creates `70 - 3 = 67`.
- Correct submission destroys the second crown gem.

### Phase 3: The Prime Trick

67 boasts that it cannot be split evenly because it is a prime number. This becomes the educational
twist rather than requiring awkward exact multiplication or division.

- Water rises to a deep-purple state and the rule becomes `BUILD IN STEPS`.
- The player first creates a nearby value, then adjusts it to `67`.
- Easy example: `8 x 8 = 64`, then `64 + 3 = 67`.
- Hard example: `9 x 7 = 63`, then `63 + 4 = 67`.
- Each correct step removes part of the final shield.

Between submissions, 67 sends slow waves of hostile digits across the arena. They create movement
pressure, but the equations remain the actual attacks.

After the final equation, the three completed equalities surround 67, break its crown, and release the
captured fish and beavers.

Expected duration: approximately four to five minutes.

## Failure And Recovery

- Health reaches zero on hard mode, or the oxygen timer expires.
- A wrong operand can be removed at the reset shell.
- A wrong submitted equation gives immediate visual and audio feedback.
- Restart reloads the current level with its original operands, dry state, health, and rule.

## Must Ship

- Three playable levels: Guardian 10, Guardian 12, and Boss 67.
- Four-direction Slay Diver movement.
- Two visible operand slots and automatic collection.
- Addition, subtraction, multiplication, and exact division checks.
- One land-to-water transition in each normal level.
- Three readable phases for Boss 67.
- Easy mode fully playable from start to finish.
- Win, lose, current-level restart, and next-level flow.
- Persistent target, operation, equation, health, and rule display.
- Clear water transition and `RULES CHANGED` presentation.

## Should Ship

- Hard mode with timers, health penalties, and more distractors.
- Short beaver tutorial dialogue.
- Fish-like Slay Diver transformation.
- Moving operands in underwater currents.
- Unique reactions for Guardian 10, Guardian 12, and Boss 67.

## Could Ship

- Spoken or animated arithmetic hints.
- A level-select screen after completing the game.
- Stars for accuracy and completion time.
- Additional valid operand pairs selected randomly from a safe authored list.

## Explicitly Cut

- Free-form equation typing.
- Negative numbers, fractions, and non-exact division.
- More than three levels.
- Inventory, weapons, upgrades, shops, and skill trees.
- Complex enemy combat or pathfinding.
- Reversed movement controls or different underwater physics.
- Procedurally generated equations without authored validation.
- More than one simultaneous arithmetic rule.

## Team Split

### Polina: Core Systems

- Player movement and operand collection.
- Equation slots, arithmetic validation, health, and reset behavior.
- Land, water, and boss rule states.
- Level success and failure calculation.

### Alina: World And Content

- Three level layouts, operand placement, distractors, and coral gates.
- Guardian 10, Guardian 12, Boss 67, currents, and hostile digit waves.
- Dry and flooded versions of each arena.

### Rinata: Experience And Integration

- Main scene, difficulty selection, level progression, and restart.
- HUD, tutorial, rule cards, equation presentation, and outcome screens.
- Tide animation, audio feedback, boss presentation, and export health.

## Vertical-Slice Test

Before building Levels 2 and 3, Level 1 must support this complete path:

1. Launch from `Main.tscn`.
2. Learn movement and identify target `10`.
3. Collect `4` and `6`.
4. Submit `4 + 6 = 10` and break the first shield.
5. Watch the arena flood and read `RULES CHANGED: SPLIT`.
6. Follow the newly opened water route.
7. Collect `14` and `4`.
8. Submit `14 - 4 = 10` and defeat Guardian 10.
9. Reach the completion screen and restart the level.
10. Submit a wrong equation and verify clear recovery.

## Scope Warning

Easy mode and the full three-level path take priority over Hard mode. Do not build moving currents,
extra dialogue, random equations, score stars, or elaborate digit attacks until Level 1 passes the
vertical-slice test and Boss 67 can be completed with placeholders.
