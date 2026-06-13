---
name: jam-ui-polish
description: Design and implement signal-driven Godot 4 HUDs, menus, onboarding, audio cues, animation feedback, accessibility, and game feel. Use for UI/UX, presentation clarity, feedback, juice, or polish work without coupling UI to gameplay internals.
---

# Jam UI and Polish

Read `ARCHITECTURE.md`, `INTEGRATION_CONTRACT.md`, `OWNERSHIP.md`, and `docs/SCOPE.md`.

1. State the player question the UI or feedback must answer.
2. Define the `Control` node structure and responsive anchors.
3. Consume documented signals or state snapshots; do not traverse gameplay scene paths.
4. Cover default, active, success, failure, disabled, and focus states as relevant.
5. Keep animations short and skippable, text readable, and audio routed through `AudioBus`.
6. Use placeholders when assets would block integration.
7. Test keyboard/controller focus, common aspect ratios, outcome clarity, and restart.

Prioritize onboarding, legibility, response, and one memorable polish beat. End with integration notes.
