# Game Divers Architecture

## Objective

Build one legible, satisfying game loop that can be completed, failed, restarted, and demonstrated
reliably. Architecture serves fast parallel work; it is not a goal by itself.

## Runtime Shape

```text
Main
|- SceneLoader / current level
|- GameSession
|- HUD
`- Audio

Level
|- PlayerSpawn
|- Player
|- World
|- Actors and interactions
`- Goal / failure sources
```

`Main.tscn` is the composition root. Feature scenes should be runnable in isolation when practical, but
the authoritative end-to-end path starts from `Main.tscn`.

## Layers

### Core Systems

Owns player behavior, the core mechanic, game rules, score/health/time state transitions, and gameplay
signals. It must not format HUD text or play audio files directly.

### World and Content

Owns levels, enemies, obstacles, collectibles, encounters, spawn markers, and authored content. It
consumes core APIs and emits documented outcomes rather than reaching into UI.

### Experience and Integration

Owns the composition root, menus, HUD, onboarding, feedback, audio routing, scene transitions,
autoloads, exports, and release build. It consumes gameplay events and exposes stable integration
services.

## Proposed Repository Layout

```text
assets/
  audio/
  fonts/
  sprites/
docs/
scenes/
  actors/
  main/
  ui/
  world/
scripts/
  actors/
  autoload/
  gameplay/
  ui/
  world/
tests/
tools/
```

Create folders only when the first owned feature needs them.

## Communication

- Local parent/child behavior may use direct typed references.
- Cross-feature communication uses signals listed in `INTEGRATION_CONTRACT.md`.
- Global events go through `GameEvents.gd`.
- Durable run state goes through `GameState.gd`.
- Audio requests go through `AudioBus.gd`.
- Scene transitions go through `SceneLoader.gd`.

Autoloads remain thin. They coordinate; they do not become containers for unrelated game logic.

## State Flow

```text
Player input
-> actor/core system
-> rules and state update
-> documented signal
-> world, UI, and audio consumers
-> win/lose decision
-> scene transition or restart
```

Every run must support deterministic reset. Restart must clear transient state, disconnect stale
listeners, and return to a playable scene without relaunching the application.

## Vertical Slice Gate

Before adding secondary content, the build must have:

- one controllable player or equivalent input loop;
- one meaningful interaction;
- one success state;
- one failure state;
- readable HUD or in-world feedback;
- restart from both outcomes;
- one integrated audio or visual feedback moment.

## Scope Rules

- Prefer one polished mechanic with variations over multiple unrelated mechanics.
- Prefer authored parameters over new systems.
- A feature requiring edits across all three ownership zones needs an architecture pass first.
- A feature without a 10-minute integration test is not ready for parallel implementation.
- Freeze new features when the playable path is unstable.

## Architecture Decisions

Record decisions that rename contracts, add autoloads, add dependencies, or change the composition root
in `docs/DECISIONS.md`. Keep entries short: date, decision, reason, affected owners, rollback.
