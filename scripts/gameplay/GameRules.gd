class_name GameRules
extends RefCounted

enum Phase {
	LAND,
	TRANSITION,
	WATER,
	COMPLETE,
}

enum Operation {
	ADD,
	SUBTRACT,
}

const LEVEL_01_ID: StringName = &"level_01"
const LEVEL_01_TARGET: int = 10
const MAX_OPERAND_SLOTS: int = 2
const LEVEL_01_STARTING_SHIELDS: int = 2

const LAND_OPERATION: Operation = Operation.ADD
const LAND_CORRECT_OPERANDS: Array[int] = [4, 6]
const LAND_DISTRACTORS: Array[int] = [2, 7]

const WATER_OPERATION: Operation = Operation.SUBTRACT
const WATER_CORRECT_OPERANDS: Array[int] = [14, 4]
const WATER_DISTRACTORS: Array[int] = [8, 3]

const PLAYER_SPEED: float = 220.0
const TIDE_TRANSITION_SECONDS: float = 2.0
const HINT_DELAY_SECONDS: float = 8.0

const SFX_OPERAND_COLLECT: StringName = &"operand_collect"
const SFX_EQUATION_WRONG: StringName = &"equation_wrong"
const SFX_SHIELD_BREAK: StringName = &"shield_break"
const SFX_TIDE: StringName = &"tide"
const SFX_LEVEL_WIN: StringName = &"level_win"


static func is_submission_phase(phase: Phase) -> bool:
	return phase == Phase.LAND or phase == Phase.WATER


static func operation_for_phase(phase: Phase) -> Operation:
	match phase:
		Phase.WATER:
			return WATER_OPERATION
		_:
			return LAND_OPERATION


static func correct_operands_for_phase(phase: Phase) -> Array[int]:
	match phase:
		Phase.WATER:
			return WATER_CORRECT_OPERANDS.duplicate()
		_:
			return LAND_CORRECT_OPERANDS.duplicate()


static func distractors_for_phase(phase: Phase) -> Array[int]:
	match phase:
		Phase.WATER:
			return WATER_DISTRACTORS.duplicate()
		_:
			return LAND_DISTRACTORS.duplicate()
