extends Node

signal run_started
signal cutscene_finished
signal score_changed(score_cents: int, display: String)
signal score_operation_applied(operation: StringName, value_cents: int, source: StringName)
signal distance_changed(blocks: int)
signal boss_phase_changed(phase: GameRules.BossPhase)
signal water_started(
	variant: GameRules.WaterVariant,
	complication: GameRules.WaterComplication,
	seconds: float
)
signal water_timer_changed(seconds_left: float)
signal water_finished
signal powerup_started(kind: StringName, seconds: float)
signal powerup_finished(kind: StringName)
signal health_changed(current: int, maximum: int)
signal player_failed(reason: StringName)
signal player_died(reason: StringName)
signal boss_67_defeated
signal level_completed(level_id: StringName)
signal game_over(won: bool, reason: StringName, score_cents: int)
signal restart_requested
