extends Node

var level_id: StringName = GameRules.LEVEL_01_ID
var phase: GameRules.Phase = GameRules.Phase.LAND
var target: int = GameRules.LEVEL_01_TARGET
var operation: GameRules.Operation = GameRules.LAND_OPERATION
var operands: Array[int] = []
var shield_segments: int = GameRules.LEVEL_01_STARTING_SHIELDS
var input_enabled: bool = true


func reset_level_01() -> void:
	level_id = GameRules.LEVEL_01_ID
	phase = GameRules.Phase.LAND
	target = GameRules.LEVEL_01_TARGET
	operation = GameRules.LAND_OPERATION
	operands.clear()
	shield_segments = GameRules.LEVEL_01_STARTING_SHIELDS
	input_enabled = true

	GameEvents.phase_changed.emit(phase)
	GameEvents.operands_cleared.emit()
	GameEvents.shield_changed.emit(shield_segments)
	_emit_equation_changed()


func try_collect_operand(value: int) -> bool:
	if not input_enabled or not GameRules.is_submission_phase(phase):
		return false
	if operands.size() >= GameRules.MAX_OPERAND_SLOTS:
		return false

	operands.append(value)
	GameEvents.operand_collected.emit(value, operands.size() - 1)
	_emit_equation_changed()
	return true


func clear_operands() -> void:
	if operands.is_empty():
		return

	operands.clear()
	GameEvents.operands_cleared.emit()
	_emit_equation_changed()


func submit_equation() -> bool:
	if not input_enabled or not GameRules.is_submission_phase(phase):
		return false
	if operands.size() != GameRules.MAX_OPERAND_SLOTS:
		GameEvents.equation_submitted.emit(false)
		clear_operands()
		return false

	var correct: bool = EquationService.is_valid_submission(operands, operation, target)

	if not correct:
		GameEvents.equation_submitted.emit(false)
		clear_operands()
		return false

	shield_segments = maxi(0, shield_segments - 1)
	GameEvents.shield_changed.emit(shield_segments)
	operands.clear()
	_emit_equation_changed()
	GameEvents.equation_submitted.emit(true)

	if phase == GameRules.Phase.WATER:
		complete_level()

	return true


func begin_tide_transition() -> void:
	if phase != GameRules.Phase.LAND:
		return

	phase = GameRules.Phase.TRANSITION
	input_enabled = false
	operands.clear()
	GameEvents.phase_changed.emit(phase)
	GameEvents.operands_cleared.emit()
	_emit_equation_changed()


func enter_water_phase() -> void:
	if phase != GameRules.Phase.TRANSITION:
		return

	phase = GameRules.Phase.WATER
	operation = GameRules.WATER_OPERATION
	input_enabled = true
	GameEvents.phase_changed.emit(phase)
	_emit_equation_changed()


func complete_level() -> void:
	if phase == GameRules.Phase.COMPLETE:
		return

	phase = GameRules.Phase.COMPLETE
	input_enabled = false
	GameEvents.phase_changed.emit(phase)
	_emit_equation_changed()
	GameEvents.level_completed.emit(level_id)


func get_equation_snapshot() -> Dictionary:
	return {
		"target": target,
		"operation": operation,
		"operands": operands.duplicate(),
		"phase": phase,
	}


func _emit_equation_changed() -> void:
	GameEvents.equation_changed.emit(get_equation_snapshot())

