# Itch.io Web Release

## Build

1. Use Godot `4.6.3.stable` with matching export templates.
2. Run `tools\qa.cmd`.
3. Create `build/web`, then export the committed `Web` preset to `build/web/index.html`.
4. Test the exported build through a local HTTP server or an itch.io draft page.
5. ZIP the contents of `build/web`, not the containing folder. `index.html` must be at the ZIP root.

## Itch.io Settings

- Kind of project: `HTML`
- Embed in page: enabled
- Click to play: enabled
- Launch in fullscreen: enabled
- Mobile Friendly: disabled for the first desktop release
- Visibility before release: restricted or draft

## Page Credits

Paste this into the itch.io project description:

```text
Slay Diver: Rise of 67 was created by Game Divers.

Platform block art:
"Platformer/Metroidvania Pixel Art Asset Pack" by o_lobster
https://o-lobster.itch.io/platformmetroidvania-pixel-art-asset-pack
Licensed under CC BY 4.0.

Movement implementation references:
"Ultimate 2D Platformer Controller" by Noasey
https://noasey.itch.io/ultimate-2d-platformer-controller
Licensed under MIT.
```

Keep `THIRD_PARTY_NOTICES.md` with the project source and release records.

## Hosted Smoke Test

- Intro and Start button appear.
- Player, land background, water background, and blocks render.
- Keyboard movement and jump work after clicking the game.
- Score starts at `1`; exact `67` wins and exact `0` fails.
- Water lasts `20` seconds and remains readable.
- Restart clears the run from land, water, victory, and failure.
- Fullscreen can be entered and exited without exposing empty page edges.
- Browser console has no missing resource or script errors.
