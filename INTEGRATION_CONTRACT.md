# Integration Contract

This is the source of truth for parallel work. Update it before merging a breaking contract change.
Names below are reserved; `Planned` means the implementation may not exist yet.

## Core Scenes

| Scene | Status | Owner | Responsibility |
| --- | --- | --- | --- |
| `scenes/main/Main.tscn` | Planned | Rinata | Composition root and run lifecycle |
| `scenes/world/Level_01.tscn` | Planned | Alina | First complete playable level |
| `scenes/actors/Player.tscn` | Planned | Polina | Player and core mechanic entry point |
| `scenes/ui/HUD.tscn` | Planned | Rinata | Run-state presentation |
| `scenes/ui/GameOverScreen.tscn` | Planned | Rinata | Outcome and restart flow |

## Autoloads

| Name | Path | Owner | Contract |
| --- | --- | --- | --- |
| `GameEvents` | `scripts/autoload/GameEvents.gd` | Rinata | Cross-owner signal hub only |
| `GameState` | `scripts/autoload/GameState.gd` | Rinata | Resettable run state and score/health/time values |
| `AudioBus` | `scripts/autoload/AudioBus.gd` | Rinata | Named music and SFX requests |
| `SceneLoader` | `scripts/autoload/SceneLoader.gd` | Rinata | Safe start, retry, and menu transitions |

Do not add another autoload without agreement from all three members.

## Core Signals

Declare global signals in `GameEvents.gd`. Emitters may expose equivalent local signals for isolated
scene testing.

| Signal | Payload | Producer | Consumers |
| --- | --- | --- | --- |
| `run_started` | none | `Main` / `SceneLoader` | HUD, audio, level |
| `player_hit` | `amount: int` | Player or damage system | HUD feedback, audio |
| `health_changed` | `current: int, maximum: int` | `GameState` | HUD |
| `score_changed` | `value: int` | `GameState` | HUD |
| `timer_changed` | `seconds_left: float` | timer/rules system | HUD |
| `player_died` | none | Player or rules system | Main, audio, HUD |
| `level_completed` | none | level goal/rules system | Main, audio, HUD |
| `game_over` | `won: bool, reason: StringName` | Main/rules system | outcome UI, audio |
| `restart_requested` | none | outcome UI/input | `SceneLoader` |

Signal payload changes are breaking changes. Update producers and consumers in the same integration
branch or keep a compatibility adapter until all owners migrate.

## Input Actions

Reserve these action names and adjust only after the concept is locked:

| Action | Purpose |
| --- | --- |
| `move_left`, `move_right`, `move_up`, `move_down` | Directional movement |
| `action` | Primary game mechanic |
| `pause` | Pause or resume |
| `restart` | Fast retry after an outcome |

## Expected Assets

Placeholders are allowed. Keep these stable names until the art/audio pass deliberately replaces the
contract.

- `assets/sprites/player_idle.png`
- `assets/sprites/player_move.png`
- `assets/sprites/enemy_basic.png`
- `assets/sprites/collectible_core.png`
- `assets/audio/sfx_collect.wav`
- `assets/audio/sfx_hit.wav`
- `assets/audio/sfx_win.wav`
- `assets/audio/sfx_lose.wav`

## Feature Contract Template

Add a row or short section before parallel implementation:

```text
Feature:
Owner:
Owned scenes/scripts:
Inputs:
Emits:
Consumes:
Assets:
Reset behavior:
Isolation test:
Main-scene test:
Fallback/cut:
```

## Contract Change Rule

The proposing owner updates this file. Every affected owner acknowledges the change before merge.
Rinata verifies the composition root and restart path after integration.
