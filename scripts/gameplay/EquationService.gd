class_name EquationService
extends RefCounted


static func is_valid_submission(
		operands: Array[int],
		operation: GameRules.Operation,
		target: int
) -> bool:
	if operands.size() != GameRules.MAX_OPERAND_SLOTS:
		return false

	match operation:
		GameRules.Operation.ADD:
			return _sum(operands) == target
		GameRules.Operation.SUBTRACT:
			return operands[0] - operands[1] == target
		_:
			return false


static func is_valid_level_01_submission(
		phase: GameRules.Phase,
		operands: Array[int]
) -> bool:
	if not GameRules.is_submission_phase(phase):
		return false

	return is_valid_submission(
		operands,
		GameRules.operation_for_phase(phase),
		GameRules.LEVEL_01_TARGET
	)


static func get_result(operands: Array[int], operation: GameRules.Operation) -> int:
	if operands.size() != GameRules.MAX_OPERAND_SLOTS:
		return 0

	match operation:
		GameRules.Operation.ADD:
			return _sum(operands)
		GameRules.Operation.SUBTRACT:
			return operands[0] - operands[1]
		_:
			return 0


static func _sum(values: Array[int]) -> int:
	var total: int = 0
	for value: int in values:
		total += value
	return total
