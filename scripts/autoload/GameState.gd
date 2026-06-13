extends Node

const ScoreServiceScript = preload("res://scripts/gameplay/ScoreService.gd")

var score_cents: int = GameRules.BOSS_67_START_SCORE_CENTS
var phase: GameRules.RunPhase = GameRules.RunPhase.SAFE_START
var distance_blocks: int = 0
var boss_phase: GameRules.BossPhase = GameRules.BossPhase.HIDDEN
var water_variant: GameRules.WaterVariant = GameRules.WaterVariant.NONE
var water_complication: GameRules.WaterComplication = GameRules.WaterComplication.NONE
var water_seconds_left: float = 0.0
var input_enabled: bool = true
var outcome_locked: bool = false
var active_powerups: Dictionary[StringName, float] = {}


func _process(delta: float) -> void:
	_update_water_timer(delta)
	_update_powerup_timers(delta)


func reset_boss_67_run() -> void:
	score_cents = ScoreServiceScript.start_score_cents()
	phase = GameRules.RunPhase.SAFE_START
	distance_blocks = 0
	boss_phase = GameRules.BossPhase.HIDDEN
	water_variant = GameRules.WaterVariant.NONE
	water_complication = GameRules.WaterComplication.NONE
	water_seconds_left = 0.0
	input_enabled = true
	outcome_locked = false
	active_powerups.clear()

	GameEvents.score_changed.emit(score_cents, ScoreServiceScript.format_score(score_cents))
	GameEvents.distance_changed.emit(distance_blocks)
	GameEvents.boss_phase_changed.emit(boss_phase)
	GameEvents.water_timer_changed.emit(water_seconds_left)


func apply_score_operation(
	operation: StringName,
	value_cents: int,
	source: StringName
) -> bool:
	if outcome_locked or not input_enabled:
		return false

	score_cents = ScoreServiceScript.apply_score_operation(score_cents, operation, value_cents)
	GameEvents.score_operation_applied.emit(operation, value_cents, source)
	GameEvents.score_changed.emit(score_cents, ScoreServiceScript.format_score(score_cents))

	if ScoreServiceScript.is_victory_score(score_cents):
		complete_run()
	elif ScoreServiceScript.is_failure_score(score_cents):
		fail_run(&"score_zero")
	return true


func set_distance_blocks(blocks: int) -> void:
	var normalized_blocks: int = maxi(0, blocks)
	if normalized_blocks == distance_blocks:
		return
	distance_blocks = normalized_blocks
	GameEvents.distance_changed.emit(distance_blocks)


func set_boss_phase(new_phase: GameRules.BossPhase) -> void:
	if boss_phase == new_phase:
		return
	boss_phase = new_phase
	GameEvents.boss_phase_changed.emit(boss_phase)


func begin_water_event(
	variant: GameRules.WaterVariant,
	complication: GameRules.WaterComplication = GameRules.WaterComplication.NONE
) -> void:
	if outcome_locked or variant == GameRules.WaterVariant.NONE:
		return

	phase = GameRules.RunPhase.WATER
	water_variant = variant
	water_complication = complication
	water_seconds_left = GameRules.WATER_DURATION_SECONDS
	GameEvents.water_started.emit(water_variant, water_complication, water_seconds_left)
	GameEvents.water_timer_changed.emit(water_seconds_left)


func finish_water_event() -> void:
	if water_variant == GameRules.WaterVariant.NONE:
		return

	phase = GameRules.RunPhase.LAND
	water_variant = GameRules.WaterVariant.NONE
	water_complication = GameRules.WaterComplication.NONE
	water_seconds_left = 0.0
	GameEvents.water_timer_changed.emit(water_seconds_left)
	GameEvents.water_finished.emit()


func activate_powerup(kind: StringName, seconds: float) -> void:
	if outcome_locked or seconds <= 0.0:
		return
	active_powerups[kind] = seconds
	GameEvents.powerup_started.emit(kind, seconds)


func fail_run(reason: StringName) -> void:
	if outcome_locked:
		return
	outcome_locked = true
	input_enabled = false
	phase = GameRules.RunPhase.FAILED
	GameEvents.health_changed.emit(0, 1)
	GameEvents.player_failed.emit(reason)
	GameEvents.player_died.emit(reason)
	GameEvents.game_over.emit(false, reason, score_cents)


func complete_run() -> void:
	if outcome_locked:
		return
	outcome_locked = true
	input_enabled = false
	phase = GameRules.RunPhase.COMPLETE
	boss_phase = GameRules.BossPhase.DEFEATED
	GameEvents.boss_phase_changed.emit(boss_phase)
	GameEvents.boss_67_defeated.emit()
	GameEvents.level_completed.emit(GameRules.BOSS_67_LEVEL_ID)
	GameEvents.game_over.emit(true, &"exact_67", score_cents)


func get_run_snapshot() -> Dictionary:
	return {
		"score_cents": score_cents,
		"score_display": ScoreServiceScript.format_score(score_cents),
		"target_cents": ScoreServiceScript.target_score_cents(),
		"target_display": ScoreServiceScript.format_score(ScoreServiceScript.target_score_cents()),
		"phase": phase,
		"distance_blocks": distance_blocks,
		"boss_phase": boss_phase,
		"water_variant": water_variant,
		"water_complication": water_complication,
		"water_seconds_left": water_seconds_left,
		"active_powerups": active_powerups.duplicate(),
		"input_enabled": input_enabled,
		"outcome_locked": outcome_locked,
	}


func _update_water_timer(delta: float) -> void:
	if water_variant == GameRules.WaterVariant.NONE or outcome_locked:
		return
	water_seconds_left = maxf(0.0, water_seconds_left - delta)
	GameEvents.water_timer_changed.emit(water_seconds_left)
	if is_zero_approx(water_seconds_left):
		finish_water_event()


func _update_powerup_timers(delta: float) -> void:
	if active_powerups.is_empty() or outcome_locked:
		return

	var finished: Array[StringName] = []
	for kind: StringName in active_powerups:
		var seconds_left: float = maxf(0.0, active_powerups[kind] - delta)
		active_powerups[kind] = seconds_left
		if is_zero_approx(seconds_left):
			finished.append(kind)

	for kind: StringName in finished:
		active_powerups.erase(kind)
		GameEvents.powerup_finished.emit(kind)
