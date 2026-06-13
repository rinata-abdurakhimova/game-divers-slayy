# Level 1 Easy Visual And UI Guide

## Goal

Create a clear, cute pixel-art presentation simple enough for a three-person game-jam team.

The player must always be able to answer:

1. What is my target number?
2. Which operation is active?
3. Which operands have I collected?
4. Where should I go next?
5. Did my equation work?

Readability is more important than environmental detail.

## Core Visual Principles

- Strong separation between character, foreground, and background.
- A small character with a clear silhouette.
- One dominant palette per scene state.
- Large color changes for important emotional moments.
- Pixel-art shapes with simple animation.
- Bright particles used sparingly to highlight interaction.

## What We Simplify

Keep the production scope deliberately small.

- One fixed top-down room, not scrolling platforming screens.
- No parallax layers.
- No complex lighting or full-screen shaders.
- No animated waterfalls, rain fields, reflections, or dense foliage.
- No large custom tile set for Level 1.
- No more than three decorative prop types per phase.
- No unique animation for every environment object.
- No detailed character portrait or dialogue system.
- No camera zoom, rotation, or cinematic movement.

The room should remain attractive when built from flat colors and placeholder rectangles.

## Canvas And Scale

- Base resolution: `1152 x 648`.
- Target aspect ratio: `16:9`.
- Test at `1280 x 720`, `1920 x 1080`, and one window smaller than the base resolution.
- Use integer scaling for pixel art where possible.
- Use a `32 x 32` world grid.
- Player visual: approximately `32 x 32`.
- Operand visual: approximately `40 x 40`, including readable number.
- Guardian 10 visual: approximately `80 x 80`.
- Keep important gameplay at least `48` pixels away from screen edges and HUD.

The entire Level 1 arena stays visible. The camera does not follow the player.

## Visual Language

### Land Phase

Mood: warm, safe, readable.

| Purpose | Suggested color |
| --- | --- |
| sand background | `#F3C6A5` |
| light sand variation | `#FFD9B8` |
| rock and boundary | `#563C5C` |
| coral accent | `#D95D9F` |
| vegetation accent | `#4F9B83` |
| UI dark | `#30243D` |
| UI light | `#FFF3E8` |

Use one flat sand background, one darker boundary tile, and a few coral or shell silhouettes. Avoid
texturing every tile.

### Water Phase

Mood: magical, surprising, slightly more intense.

| Purpose | Suggested color |
| --- | --- |
| pink water overlay | `#E78DD2` at partial opacity |
| deep water | `#7756A5` |
| open water path | `#8ECDE0` |
| bubbles and highlights | `#DDFBFF` |
| blocked coral | `#4A345F` |
| active rule accent | `#FFDCF6` |

Water should recolor the existing room rather than replace it with a second detailed environment.
Alina may use:

- one `ColorRect` or large translucent sprite for water;
- one simple wave edge moving upward;
- a small looping bubble particle effect;
- visibility swaps for the dry and flooded route.

## Character

Slay Diver must be the strongest pink shape in the room.

Land version:

- pink suit or hair;
- dark outline;
- one light face or mask area;
- two-frame idle and two- or four-frame movement are enough.

Water version:

- reuse the same body;
- add a small fin, bubble helmet highlight, or tail accessory;
- shift one accent toward cyan;
- do not create a completely separate animation set.

Placeholder fallback: a pink rounded square with a dark outline and a small cyan visor.

## Operands

Operands must be readable before they are decorative.

- Use a light circular or pearl-shaped body with a dark outline.
- Put one large dark number in the center.
- Keep the number upright and unanimated.
- Correct and distractor operands use the same base style.
- Do not reveal correctness through permanent color.
- After `HINT_DELAY_SECONDS`, correct operands may emit one subtle sparkle.
- On collection, scale to `115%` for `0.08` seconds, then disappear into the HUD slot.

Water operands may bob by a few pixels. Do not rotate them because the arithmetic must remain readable.

## Guardian 10

- Large number `10` with a face, crown fragment, or simple shell shield.
- Two visible shield gems represent the two required equations.
- First correct equation cracks one gem.
- Second correct equation removes the remaining shield and plays the defeat animation.
- Guardian remains visible from the starting position.

Minimum animation set:

- idle: gentle two-frame bounce;
- shield hit: white flash and short shake;
- defeated: shrink or fall backward with particles.

## HUD Structure

`HUD.tscn` uses this `Control` structure:

```text
HUD (Control, full rect, mouse filter ignore)
|- SafeMargin (MarginContainer, full rect)
|  `- TopRow (HBoxContainer, top wide)
|     |- TargetPanel (PanelContainer)
|     |  `- TargetLabel
|     |- Spacer
|     |- EquationPanel (PanelContainer)
|     |  `- EquationRow (HBoxContainer)
|     |     |- OperandSlotA
|     |     |- OperationLabel
|     |     |- OperandSlotB
|     |     |- EqualsLabel
|     |     `- TargetRepeatLabel
|     |- Spacer
|     `- RulePanel (PanelContainer)
|        |- RuleLabel
|        `- ShieldRow
`- HintPanel (PanelContainer, bottom center)
   `- HintLabel
```

Responsive rules:

- `HUD` anchors to full rect.
- Top row uses `24` pixel margins at base resolution.
- Target and Rule panels keep fixed minimum widths.
- Equation panel expands in the center.
- Hint panel anchors bottom-center and stays within safe margins.
- HUD never reads Level 1 node paths; it consumes `equation_changed`, `phase_changed`, and
  `shield_changed`.

## HUD Appearance

Keep the HUD compact and visually simple.

- Three compact panels across the top.
- Dark plum panel fill at approximately `90%` opacity.
- Light cream text.
- Pink accent for `COMBINE`.
- Cyan or lavender accent for `SPLIT`.
- One pixel-style font if available; otherwise use a clear bundled sans-serif.
- Minimum gameplay text size: approximately `24` pixels at base resolution.
- Equation operands should be larger than other HUD text.

Example land HUD:

```text
TARGET 10          4 + 6 = 10          COMBINE  ◆◆
```

Example water HUD:

```text
TARGET 10         14 - 4 = 10           SPLIT    ◆◇
```

Use both text and symbols. Never communicate the active rule through color alone.

## UI States

### Default

- Empty equation displays `_ + _ = 10`.
- Current rule and both shield gems are visible.
- Hint panel is hidden after onboarding.

### One Operand

- Filled slot briefly pops.
- Missing slot pulses once.
- For subtraction, show a small `FIRST` marker over the first slot during the water tutorial.

### Ready To Submit

- Equation panel gains a thin bright outline.
- Altar receives a matching pulse in the world.
- Do not cover the player with additional text.

### Correct

- Equation turns mint or cream.
- Short sparkle burst.
- Shield gem cracks.
- Feedback duration: approximately `0.3` seconds before the next state starts.

### Wrong

- Equation turns coral-red.
- Panel shakes for approximately `0.2` seconds.
- Display `TRY AGAIN` briefly.
- Slots clear and operands return without reloading the scene.

### Disabled

- During the tide transition, dim the HUD slightly.
- Keep the completed land equation visible until the rule card appears.
- Ignore interaction input.

### Complete

- Hide normal hints.
- Show the ResultScreen with `GUARDIAN 10 DEFEATED`.
- Default keyboard focus is on `RESTART`.

## Tutorial

Use small contextual prompts, not dialogue boxes.

1. Start: arrow-key icons and `MOVE`.
2. After movement: `FIND TWO NUMBERS THAT MAKE 10`.
3. After first operand: `ONE MORE`.
4. When both slots are full: pulse the altar and show `BRING THE EQUATION HERE`.
5. After flooding: `RULES CHANGED: SPLIT`.
6. Water tutorial: `ORDER MATTERS: FIRST - SECOND`.

Each prompt disappears after the relevant action. Avoid paragraphs during gameplay.

## Tide Transition

This is the one memorable polish beat for Level 1.

Target duration: `2.0` seconds.

1. Guardian flashes and the first shield gem breaks.
2. Movement stops.
3. A simple pink wave rises from the bottom of the room.
4. The land palette shifts toward purple and cyan.
5. A few bubbles cross the screen.
6. Slay Diver gains the water accent.
7. Center card appears: `RULES CHANGED` then `SPLIT: FIRST - SECOND`.
8. Card exits, HUD rule updates, and movement resumes.

The animation must be skippable with `action`, but skipping still applies every final visual and
gameplay state.

Do not add camera shake to the whole transition. Reserve a small shake for the shield break.

## Result Screen

```text
ResultScreen (Control, full rect)
|- DimBackground (ColorRect)
`- CenterCard (PanelContainer)
   `- VBoxContainer
      |- TitleLabel
      |- EquationSummary
      |- RestartButton
      `- NextLevelLabel
```

Content:

- `GUARDIAN 10 DEFEATED`
- `4 + 6 = 10`
- `14 - 4 = 10`
- `RESTART`
- `NEXT LEVEL: COMING SOON`

The overlay must not destroy or search the world scene. It emits `restart_requested`.

## Audio

Route every sound through `AudioBus`.

| Event | Sound direction |
| --- | --- |
| operand collected | short pearl pop |
| equation ready | quiet rising chime |
| wrong equation | soft low two-note response |
| shield break | crisp crack with sparkle |
| tide | short wave sweep and magical swell |
| Guardian defeated | bright three-note success cue |

Keep sounds short. The wrong-answer sound should correct the player without feeling punitive.

## Accessibility

- Never rely on pink, cyan, green, or red alone.
- Always show operation symbols and rule text.
- Maintain strong contrast between numbers and operand bodies.
- Avoid flashing more than three times per second.
- Tide overlay can be skipped.
- Decorative particles never obscure operands, player, altar, or Guardian.
- UI remains readable without a pixel font.

## Asset Budget

Level 1 should need no more than:

- one simple land background or tiny reusable tile set;
- one water overlay and one wave edge;
- one Player base sprite plus one water accent;
- one operand pearl sprite;
- three Guardian states;
- one altar, one ResetShell, one CoralGate;
- three decorative props: coral, shell, and seaweed;
- six short sound effects;
- one font.

Use `ColorRect`, `StyleBoxFlat`, `Label`, simple polygons, and placeholder sprites before waiting for
finished art.

## Test Checklist

- HUD answers all five player questions without opening a tutorial.
- Player, operands, altar, and Guardian remain readable in both palettes.
- Correct and wrong equations are distinguishable without audio.
- Land and water rules are distinguishable without color.
- Tide transition ends in the correct final state when watched or skipped.
- Keyboard focus reaches Restart and activates it.
- UI remains inside safe margins at common `16:9` resolutions.
- Three consecutive restarts do not duplicate overlays, sounds, or signal reactions.

## Scope Warning

Do not add dense environmental detail. Level 1 polish comes from a strong palette shift, clean
silhouettes, readable arithmetic, one good tide animation, and responsive feedback.
