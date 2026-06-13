# Polina Core Workspace

Core Systems planning and reusable snippets for Polina. This folder is documentation/support material,
not runtime game code. Copy only selected snippets into Polina-owned paths after the Level 1 contract is
checked.

## What Is Here

- `LEVEL_01_CORE_PLAN.md`: Polina's first-level implementation and handoff plan.
- `snippets/player_controller_2d.gd.template`: reusable 4-direction `CharacterBody2D` controller.
- `snippets/health_component.gd.template`: later-mode health reference; do not use in Level 1 Easy.
- `snippets/action_cooldown.gd.template`: later/fallback action reference; not required for Level 1 MVP.
- `snippets/timer_score_rules.gd.template`: older generic rules reference; prefer `GameRules` and `EquationService`.
- `snippets/core_events_bridge.gd.template`: old bridge reference; Level 1 uses `GameState` and `GameEvents`.
- `snippets/player_sandbox.tscn.template`: copyable isolated scene template.
- `contract_templates/player_core_feature.md`: Polina-focused contract notes for Level 1 Easy.
- `manual_tests/player_core_manual_test.md`: shortest manual test for the player/core slice.
- `tomorrow_context.md`: compressed context for the next implementation prompt.

## Safe Use For Level 1 Easy

1. Treat `ARCHITECTURE.md` and `INTEGRATION_CONTRACT.md` as the source of truth.
2. Pick only movement-safe parts from snippets; do not copy health, timers, score, or cooldown systems
   into Level 1 Easy.
3. Copy them into owned paths:
   - `scripts/actors/player/`
   - `scripts/gameplay/`
   - `scenes/actors/Player.tscn`
4. Implement `GameRules.gd`, `EquationService.gd`, Player movement, and arithmetic tests first.
5. Keep UI, audio, operands, altars, Guardian10, and level layout behind documented contracts.
6. Run `tools\qa.cmd` after integration and use the manual test in this folder.

## Do Not Do Yet

- Do not create Level 2, Hard mode, Boss 67, timers, health, oxygen, or random equations.
- Do not create final enemies, collectibles, levels, or UI here.
- Do not add autoloads from this folder.
- Do not edit `project.godot`, `Main.tscn`, or Alina/Rinata owned paths without handoff.
