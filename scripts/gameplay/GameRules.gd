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
	MULTIPLY,
}

enum RunPhase {
	SAFE_START,
	LAND,
	WATER,
	COMPLETE,
	FAILED,
}

enum BossPhase {
	HIDDEN,
	LAND_WHITE,
	LAND_PURPLE,
	WATER,
	DEFEATED,
}

enum WaterVariant {
	NONE,
	WATER_A,
	WATER_B,
	WATER_C,
}

enum WaterComplication {
	NONE,
	REVERSED_CONTROLS,
	INVERTED_GRAVITY,
}

const LEVEL_01_ID: StringName = &"level_01"
const LEVEL_01_TARGET: int = 10
const MAX_OPERAND_SLOTS: int = 2
const LEVEL_01_STARTING_SHIELDS: int = 2

const BOSS_67_LEVEL_ID: StringName = &"boss_67_level_01"
const BOSS_67_START_SCORE_CENTS: int = 100
const BOSS_67_TARGET_SCORE_CENTS: int = 6700
const BOSS_67_FAILURE_SCORE_CENTS: int = 0

const SCORE_OPERATION_ADD: StringName = &"add"
const SCORE_OPERATION_SUBTRACT: StringName = &"subtract"
const SCORE_OPERATION_MULTIPLY: StringName = &"multiply"

const LAND_PICKUP_VALUES_CENTS: Array[int] = [100, 200, 300, 500, 600, 700]
const LAND_PICKUP_RAW_VALUES: Array[int] = [1, 2, 3, 5, 6, 7]
const LAND_BOSS_MULTIPLIERS_CENTS: Array[int] = [0, 50, 80]

const FIRST_PURPLE_DISTANCE_BLOCKS: int = 18
const FIRST_WATER_DISTANCE_BLOCKS: int = 28
const WATER_DURATION_SECONDS: float = 10.0
const WATER_RETRIGGER_COOLDOWN_SECONDS: float = 4.0
const WATER_RETRIGGER_DIVISORS: Array[int] = [6, 7]

const WATER_A_BOSS_MULTIPLIERS_CENTS: Array[int] = [115, 120, 130]
const WATER_A_FLOOR_VALUES_CENTS: Array[int] = [-1000, -1200, -800, -600]

const WATER_B_BOSS_VALUES_CENTS: Array[int] = [300, 500, 600, 700]
const WATER_B_FLOOR_MULTIPLIERS_CENTS: Array[int] = [50, 20, 30, 0]

const WATER_C_BOSS_VALUES_CENTS: Array[int] = [-500, -100, -200, -700, -1000]
const WATER_C_FLOOR_MULTIPLIERS_CENTS: Array[int] = [200, 600, 300, 100]

const POWERUP_SLOW: StringName = &"slow"
const POWERUP_DOUBLE_JUMP: StringName = &"double_jump"
const POWERUP_DURATION_SECONDS: float = 5.0

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
