# Game Divers

Three-person Godot 4.x game-jam project with contract-first integration and shared pitching.

## Play

`Slay Diver: Rise of 67` is a desktop platformer boss chase. Change the running score and reach
exactly `67`.

| Action | Controls |
| --- | --- |
| Move | `A` / `D` or Left / Right arrows |
| Jump | `Space`, `W`, or Up arrow |
| Action / skip | `Enter` or `E` |
| Restart | `R` |
| Pause | `Escape` |

Start with:

- `AGENTS.md` for assistant and team working rules
- `ARCHITECTURE.md` for the project shape
- `INTEGRATION_CONTRACT.md` for shared scenes, signals, and dependencies
- `OWNERSHIP.md` for the three coding ownership zones
- `docs/QA_BOT_WORKFLOW.md` for build protection and emergency triage

Run the repository preflight with:

```powershell
tools\qa.cmd
```

On macOS or Linux:

```bash
bash tools/qa.sh
```

## Web Export

The release target is a desktop-browser Godot Web build using the Compatibility renderer and the
committed `Web` export preset.

1. Install the Godot `4.6.3.stable` export templates.
2. Run `tools\qa.cmd`.
3. Export:

   ```powershell
   New-Item -ItemType Directory -Path build/web -Force | Out-Null
   Godot_v4.6.3-stable_win64_console.exe --headless --path . --export-release Web build/web/index.html
   ```

4. ZIP the contents of `build/web` so `index.html` is at the root of the archive.
5. Upload it as an itch.io HTML game with click-to-play and click-to-launch fullscreen enabled.

The first release targets desktop browsers. Do not mark it Mobile Friendly until touch controls and
mobile browser testing are complete. See `docs/ITCH_IO_RELEASE.md` for the release checklist and
attribution copy.
