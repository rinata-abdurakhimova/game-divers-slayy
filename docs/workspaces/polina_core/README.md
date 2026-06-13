# Polina Core Workspace

Core Systems planning and reusable snippets for Polina. This folder is documentation/support material,
not runtime game code. Treat `ARCHITECTURE.md` and `INTEGRATION_CONTRACT.md` as the source of truth.

## What Is Here

- `LEVEL_01_CORE_PLAN.md`: Polina's Boss 67 first-level implementation and handoff plan.
- `snippets/player_controller_2d.gd.template`: old 4-direction controller reference; do not use for
  the new side-view platformer unless rewriting it intentionally.
- `snippets/health_component.gd.template`: later-mode health reference; do not use in Level 1.
- `snippets/action_cooldown.gd.template`: later/fallback action reference; not required for the MVP.
- `snippets/timer_score_rules.gd.template`: older generic rules reference; prefer the new
  fixed-point `ScoreService` and `WaterRuleService` plan.
- `snippets/core_events_bridge.gd.template`: old bridge reference; prefer documented `GameState`
  signals.
- `snippets/player_sandbox.tscn.template`: copyable isolated scene template if it still fits after
  side-view conversion.
- `contract_templates/player_core_feature.md`: Polina-focused contract notes for the Boss 67 core.
- `manual_tests/player_core_manual_test.md`: shortest manual test for movement, score, water,
  victory, failure, and restart.
- `tomorrow_context.md`: compressed context for the next implementation prompt.

## Safe Use For Boss 67 Level 1

1. Check `ARCHITECTURE.md` and `INTEGRATION_CONTRACT.md` first.
2. Adapt movement only from the documented platformer controller reference:
   - walking
   - gravity/falling
   - one jump
   - short hop
   - coyote time
   - jump buffering
   - floor/platform collision
3. Do not copy full controller logic or enable removed abilities.
4. Copy or write code only into Polina-owned paths:
   - `scripts/actors/player/`
   - `scripts/gameplay/`
   - `scenes/actors/Player.tscn`
   - `tests/gameplay/`
5. Implement `ScoreService`, `WaterRuleService`, Player movement, and tests before integrating the full
   level.
6. Keep UI, audio, world layout, pickups, boss scene, and water visuals behind documented contracts.
7. Run `tools\qa.cmd` after integration and use the manual test in this folder.

## Do Not Do Yet

- Do not create Level 2.
- Do not add weapons or unrelated enemies.
- Do not add health, oxygen, shops, procedural maps, or long cutscenes.
- Do not treat the visual asset pack as gameplay logic.
- Do not edit `project.godot`, `Main.tscn`, or Alina/Rinata owned paths without handoff.
